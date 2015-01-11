/* --- --------------------------------------------------------------------------------
	@: Motion Sensor
   --- */

local MSComponent = EXPADV.AddComponent( "motionsensor", true )

MSComponent.Author = "Rusketh"
MSComponent.Description = "Adds support for xbox kinect interaction."

/* --- --------------------------------------------------------------------------------
	@: Client
   --- */

if CLIENT then
	MSComponent.AllowMSesnor = CreateClientConVar( "expadv_allow_msensor", 0, true, true )
	MSComponent.StatusMSesnor = CreateClientConVar( "expadv_status_msensor", 0, false, true )

	timer.Create( "Lemon_Kinect", 0.5, 0, function( )
		if MSComponent.AllowMSesnor:GetInt( ) == 0 then
			if MSComponent.StatusMSesnor:GetInt( ) ~= 0 then
				RunConsoleCommand( "expadv_status_msensor", 0 )
			end
		elseif !motionsensor.IsAvailable( ) then
			if MSComponent.StatusMSesnor:GetInt( ) ~= 0 then
				RunConsoleCommand( "expadv_status_msensor", 0 )
			end
		elseif motionsensor.IsActive( ) then
			if MSComponent.StatusMSesnor:GetInt( ) ~= 2 then
				RunConsoleCommand( "expadv_status_msensor", 2 )
			end
		elseif MSComponent.StatusMSesnor:GetInt( ) ~= 1 then
			RunConsoleCommand( "expadv_status_msensor", 1 )
		end
	end )
end

/* --- --------------------------------------------------------------------------------
	@: List of bones
   --- */

local BONES = {
	LeftSholder = SENSORBONE.SHOULDER_Right,
	RightSholder = SENSORBONE.SHOULDER_Left,
	CenterShoulder = SENSORBONE.SHOULDER,
	LeftHip = SENSORBONE.HIP_Left,
	RightHip = SENSORBONE.HIP_Right,
	CenterHip = SENSORBONE.HIP,
	LeftElbow = SENSORBONE.ELBOW_Left,
	RightElbow = SENSORBONE.ELBOW_Right,
	LeftKnee = SENSORBONE.KNEE_Left,
	RightKnee = SENSORBONE.KNEE_Right,
	RightWrist = SENSORBONE.WRIST_Right,
	LeftAnkle = SENSORBONE.ANKLE_Left,
	LeftFoot = SENSORBONE.FOOT_Left,
	LeftWrist = SENSORBONE.WRIST_Left,
	RightFoor = SENSORBONE.FOOT_Right,
	RightHand = SENSORBONE.HAND_Right,
	LeftHand = SENSORBONE.HAND_Left,
	RightAnkle = SENSORBONE.ANKLE_Right,
	CenterSpine = SENSORBONE.SPINE,
	Head = SENSORBONE.HEAD,

}

/* --- --------------------------------------------------------------------------------
	@: Server Only Functions
   --- */

EXPADV.ServerOperators( )

MSComponent:AddInlineFunction( "hasMotionSensor", "ply:", "b", "(IsValid( @value 1 ) and @value 1:( 'expadv_status_msensor', 0) >= 1)")
MSComponent:AddFunctionHelper( "hasMotionSensor", "ply:", "returns true if player has a motion sensor." )

MSComponent:AddPreparedFunction( "startMotionSensor", "ply:", "", [[if IsValid( @value 1 ) and @value 1:( 'expadv_status_msensor', 0) >= 1) then
	@value 1:SendLua( 'motionsensor.Start( )' )
end]] )

MSComponent:AddFunctionHelper( "startMotionSensor", "ply:", "Starts the players motion sensor, player has enabled 'expadv_allow_msensor'." )

for Name, Num in pairs( BONES ) do
	local function Virtual( Context, Trace, Player )
		if !IsValid( Player ) or ( Player:GetInfoNum( 'expadv_status_msensor', 0) ~= 2 ) and Player ~= Context.player then
			return Vector( 0, 0, 0 )
		end

		return Player:MotionSensorPos( Num )
	end

	MSComponent:AddVMFunction( "getSensor" .. Name, "ply:", "v", Virtual )
	MSComponent:AddFunctionHelper( "getSensor" .. Name, "ply:", "returns the " .. Name .. " from the players motion sensor." )
end

/* --- --------------------------------------------------------------------------------
	@: Shared Functions
   --- */

EXPADV.SharedOperators( )

if SERVER then
	MSComponent:AddInlineFunction( "hasMotionSensor", "", "b", "(IsValid( Context.player ) and Context.player:( 'expadv_status_msensor', 0) >= 1)")

	MSComponent:AddPreparedFunction( "startMotionSensor", "", "", [[if IsValid( Context.player ) and Context.player:( 'expadv_status_msensor', 0) >= 1) then
		Context.player:SendLua( 'motionsensor.Start( )' )
	end]] )
end

if CLIENT then
	MSComponent:AddInlineFunction( "hasMotionSensor", "", "b", "(GetConVarNumber( 'expadv_status_msensor' ) >= 1)")
	MSComponent:AddFunctionHelper( "hasMotionSensor", "", "Same as player:hasMotionSensor( ), uses owner as player serverside and localplayer clientside." )

	MSComponent:AddPreparedFunction( "startMotionSensor", "", "", [[if IsValid( Context.player ) and Context.player:( 'expadv_status_msensor', 0) >= 1) then
		$motionsensor.Start( )
	end]] )

	MSComponent:AddFunctionHelper( "startMotionSensor", "", "Same as player:startMotionSensor( ), uses owner as player serverside and localplayer clientside." )
end

for Name, Num in pairs( BONES ) do

	if SERVER then
			MSComponent:AddVMFunction( "getSensor" .. Name, "", "v", function( Context, Trace )
				if !IsValid( Context.player ) or ( Context.player:GetInfoNum( 'expadv_status_msensor', 0) ~= 2 ) then
					return Vector( 0, 0, 0 )
				end

				return Context.player:MotionSensorPos( Num )
			end )
	end

	if CLIENT then
		MSComponent:AddVMFunction( "getSensor" .. Name, "", "v", function( Context, Trace )
			if !IsValid( Player ) or ( GetConVarNumber( 'expadv_status_msensor' ) ~= 2 ) then
				return Vector( 0, 0, 0 )
			end

			return LocalPlayer:MotionSensorPos( Num )
		end )

		MSComponent:AddFunctionHelper( "getSensor" .. Name, "", "same as player:" .. Name .. "(), uses owner as player serverside and localplayer clientside." )
	end

end
