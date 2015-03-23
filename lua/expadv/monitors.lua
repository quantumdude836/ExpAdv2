/* --- --------------------------------------------------------------------------------
	@: EXPADV Monitors:
	@: This is borrowed from wiremods code, I take no credit for this.
	@: Source: https://github.com/wiremod/wire/blob/master/lua/wire/wireMonitors.lua
   --- */

require( "vector2" )

EXPADV.Monitors = {}

function EXPADV.Addmonitor(name, model, tof, tou, tor, trs, x1, x2, y1, y2, rot)
	if !rot then rot = Angle(0,90,90) elseif !isangle(rot) then rot = Angle(0,90,0) end

	local RatioX = (y2-y1)/(x2-x1)

	EXPADV.Monitors[model] = {
		Name = name,
		offset = Vector(tof, -tor, tou),
		RS = trs,
		RatioX = RatioX,
		x1 = x1,
		x2 = x2,
		y1 = y1,
		y2 = y2,
		z = tof,
		rot = rot,
	}
end

/* --- --------------------------------------------------------------------------------
	@: Moitor List
   --- */

if WireLib then -- Steal wirelibs Monitors.
	EXPADV.Monitors = WireGPU_Monitors
else -- No Wire so we need to add these manualy.
	EXPADV.Addmonitor("Small TV",          "models/props_lab/monitor01b.mdl",                6.53, 0.45 , 1.0, 0.0185, -5.535  , 3.5    , -4.1   , 5.091 )
	EXPADV.Addmonitor("monitor Small",     "models/kobilica/wireMonitorsmall.mdl",           0.3 , 5.0  , 0  , 0.0175, -4.4    , 4.5    , 0.6    , 9.5   )
	EXPADV.Addmonitor("LCD monitor (4:3)", "models/props/cs_office/computer_monitor.mdl",    3.3 , 16.7 , 0  , 0.031 , -10.5   , 10.5   , 8.6    , 24.7  )
	EXPADV.Addmonitor("monitor Big",       "models/kobilica/wiremonitorbig.mdl",             0.2 , 13   , 0  , 0.045 , -11.5   , 11.6   , 1.6    , 24.5  )
	EXPADV.Addmonitor("Plasma TV (4:3)",   "models/blacknecro/tv_plasma_4_3.mdl",            0.1 , -0.5 , 0  , 0.082 , -27.87  , 27.87  , -20.93 , 20.93 )
	EXPADV.Addmonitor("Plasma TV (16:10)", "models/props/cs_office/tv_plasma.mdl",           6.1 , 18.93, 0  , 0.065 , -28.5   , 28.5   , 2      , 36    )
	EXPADV.Addmonitor("Billboard",         "models/props/cs_assault/billboard.mdl",          1   , 0    , 0  , 0.23  , -110.512, 110.512, -57.647, 57.647)
	EXPADV.Addmonitor("Cube 1x1x1",        "models/hunter/blocks/cube1x1x1.mdl",             24  , 0    , 0  , 0.09  , -48     , 48     , -48    , 48    )
	EXPADV.Addmonitor("Panel 1x1",         "models/hunter/plates/plate1x1.mdl",              0   , 1.7  , 0  , 0.09  , -48     , 48     , -48    , 48    , true)
	EXPADV.Addmonitor("Panel 2x2",         "models/hunter/plates/plate2x2.mdl",              0   , 1.7  , 0  , 0.182 , -48     , 48     , -48    , 48    , true)
	EXPADV.Addmonitor("Panel 0.5x0.5",     "models/hunter/plates/plate05x05.mdl",            0   , 1.7  , 0  , 0.045 , -48     , 48     , -48    , 48    , true)
end

/* --- --------------------------------------------------------------------------------
	@: Helpers
   --- */

local function mindimension(vec)
	if vec.x-0.002 < vec.y then
		if vec.x-0.002 < vec.z then
			return Vector(1,0,0)
		else
			return Vector(0,0,1)
		end
	else
		if vec.y < vec.z then
			return Vector(0,1,0)
		else
			return Vector(0,0,1)
		end
	end
end

local function maxdimension(vec)
	if vec.x-0.002 > vec.y then
		if vec.x > vec.z then
			return Vector(1,0,0)
		else
			return Vector(0,0,1)
		end
	else
		if vec.y+0.002 > vec.z then
			return Vector(0,1,0)
		else
			return Vector(0,0,1)
		end
	end
end

local function FromBoxHelper(name, model, boxmin, boxmax, rot)
	local boxcenter = (boxmin+boxmax)*0.5
	local offset = Vector(boxcenter.x,boxcenter.y,boxmax.z+0.2)

	boxmin = boxmin - offset
	boxmax = boxmax - offset

	local x1, y1 = boxmin.x, boxmin.y
	local x2, y2 = boxmax.x, boxmax.y

	offset:Rotate(rot)

	local monitor = {
		Name = name,
		offset = offset,
		RS = (y2-y1)/512,
		RatioX = (y2-y1)/(x2-x1),

		x1 = x1,
		x2 = x2,
		y1 = y1,
		y2 = y2,

		z = offset.z,

		rot = rot,
	}

	EXPADV.Monitors[model] = monitor

	return monitor
end

/* --- --------------------------------------------------------------------------------
	@: FromBox
   --- */

local function FromBox(name, model, boxmin, boxmax)
	local dim = boxmax-boxmin
	local mindim, maxdim = mindimension(dim), maxdimension(dim)

	-- get an angle with up=mindim
	local rot = mindim:Angle()+Angle(90,0,0)

	-- make sure forward=maxdim
	if math.abs(maxdim:Dot(rot:Forward())) < 0.01 then
		rot:RotateAroundAxis(mindim, 90)
	end

	-- unrotate boxmin/max
	local box1 = WorldToLocal(boxmin, Angle(0,0,0), Vector(0,0,0), rot)
	local box2 = WorldToLocal(boxmax, Angle(0,0,0), Vector(0,0,0), rot)

	-- sort boxmin/max
	local boxmin = Vector(math.min(box1.x,box2.x), math.min(box1.y,box2.y), math.min(box1.z,box2.z))
	local boxmax = Vector(math.max(box1.x,box2.x), math.max(box1.y,box2.y), math.max(box1.z,box2.z))

	-- make a new gpu screen
	return FromBoxHelper(name, model, boxmin, boxmax, rot)
end

local function FromRotatedBox(name, model, box1, box2, box3, box4, rot)
	if isvector(rot) then
		rot = Vector:Angle()
	end

	local box1 = WorldToLocal(box1, Angle(0,0,0), Vector(0,0,0), rot)
	local box2 = WorldToLocal(box2, Angle(0,0,0), Vector(0,0,0), rot)
	local box3 = WorldToLocal(box3, Angle(0,0,0), Vector(0,0,0), rot)
	local box4 = WorldToLocal(box4, Angle(0,0,0), Vector(0,0,0), rot)

	local boxmin = Vector(
		math.min(box1.x,box2.x,box3.x,box4.x),
		math.min(box1.y,box2.y,box3.y,box4.y),
		math.min(box1.z,box2.z,box3.z,box4.z)
	)

	local boxmax = Vector(
		math.max(box1.x,box2.x,box3.x,box4.x),
		math.max(box1.y,box2.y,box3.y,box4.y),
		math.max(box1.z,box2.z,box3.z,box4.z)
	)

	return FromBoxHelper(name, model, boxmin, boxmax, rot)
end

/* --- --------------------------------------------------------------------------------
	@: GetMonitor
   --- */

local gap = Vector(0.25,0.25,0.25)

function EXPADV.GetMonitor(ent)
	local model = ent:GetModel()
	local monitor = EXPADV.Monitors[model]

	if !monitor then
		local name = ent:GetModel():match("([^/]*)$")
		monitor = FromBox( name, model, ent:OBBMins() + gap, ent:OBBMaxs() - gap, true)
	end

	-- GUI screens need the min and max positions, so lets get these.

	if !monitor.min then
		local Vec2 = (Vector2(0,0) - Vector2(256, 256)) * Vector2( monitor.RS / monitor.RatioX, monitor.RS )

		local Vec = Vector( Vec2.x, -Vec2.y, 0 )

		Vec:Rotate( monitor.rot )

		monitor.min = Vec + monitor.offset
	end

	if !monitor.max then
		local Vec2 = (Vector2(512, 512) - Vector2(256, 256)) * Vector2( monitor.RS / monitor.RatioX, monitor.RS )

		local Vec = Vector( Vec2.x, -Vec2.y, 0 )

		Vec:Rotate( monitor.rot )

		monitor.max = Vec + monitor.offset
	end

	return monitor
end

/* --- --------------------------------------------------------------------------------
	@: Add Monitor Hook
   --- */

EXPADV.MonitorFromBox = FromBox
EXPADV.MonitorFromRotatedBox = FromRotatedBox
EXPADV.CallHook("AddMonitors", EXPADV.Monitors)
