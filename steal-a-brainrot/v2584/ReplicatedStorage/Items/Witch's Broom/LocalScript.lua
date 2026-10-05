local createVector = vector.create
Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
local Players2 = game:GetService("Players")
Players = Players2
local RunService2 = game:GetService("RunService")
RunService = RunService2
local Workspace = game:GetService("Workspace")
Camera = Workspace.CurrentCamera
Animations = {}
LocalObjects = {}
ClientControl = Tool:WaitForChild("ClientControl")
Rate = 0.016666666666666666
SpeedMultiplier = 1.65
CameraSpeed = {
	X = 40 * SpeedMultiplier,
	Z = 60 * SpeedMultiplier
}
Controls = {
	Forward = {
		Mode = false,
		Keys = {
			Key = "w",
			ByteKey = 17
		}
	},
	Backward = {
		Mode = false,
		Keys = {
			Key = "s",
			ByteKey = 18
		}
	},
	Left = {
		Mode = false,
		Keys = {
			Key = "a",
			ByteKey = 20
		}
	},
	Right = {
		Mode = false,
		Keys = {
			Key = "d",
			ByteKey = 19
		}
	}
}
ToolEquipped = false

function HandleFlightControl()
	if not CheckIfAlive() then
		return
	end

	if FightMonitor then
		FightMonitor:disconnect()
	end

	FightMonitor = Torso.ChildAdded:connect(function(p)
		if Flying then
			return
		end

		if p.Name == "FlightHold" then
			local flightSpin = Torso:FindFirstChild("FlightSpin")
			local flightPower = Torso:FindFirstChild("FlightPower")
			local flightHold = Torso:FindFirstChild("FlightHold")

			if not (flightSpin and flightPower and flightHold) then
				return
			end

			Flying = true
			Humanoid.WalkSpeed = 0
			Humanoid.PlatformStand = true
			Humanoid.AutoRotate = false
			DisableJump(true)
			Torso.Velocity = createVector(0, 0, 0)
			Torso.RotVelocity = createVector(0, 0, 0)

			while Flying and flightSpin.Parent and flightPower.Parent and flightHold.Parent and CheckIfAlive() do
				local v = createVector(0, 0, 0)
				local vectorToWorldSpace = Camera.CoordinateFrame:vectorToWorldSpace(createVector(0, 0, -1))
				local vectorToWorldSpace2 = Camera.CoordinateFrame:vectorToWorldSpace(createVector(-1, 0, 0))
				local coordinateFrame = Camera.CoordinateFrame
				local vectorToObjectSpace = CFrame.new(
					createVector(0, 0, 0),
					coordinateFrame.lookVector * createVector(1, 0, 1)
				):vectorToObjectSpace(Humanoid.MoveDirection)
				local v2 = v + (vectorToWorldSpace * CameraSpeed.Z * -vectorToObjectSpace.z or v)
				local velocity = v2 + (vectorToWorldSpace2 * CameraSpeed.X * -vectorToObjectSpace.x or v2)
				flightSpin.cframe = CFrame.new(createVector(0, 0, 0), vectorToWorldSpace)

				if velocity.magnitude < 1 then
					flightHold.maxForce = Vector3.new(flightHold.P, flightHold.P, flightHold.P)
					flightPower.maxForce = createVector(0, 0, 0)
					flightHold.position = Torso.Position
				else
					flightHold.maxForce = createVector(0, 0, 0)
					flightPower.maxForce = Vector3.new(flightPower.P * 100, flightPower.P * 100, flightPower.P * 100)
				end

				flightPower.velocity = velocity
				wait(Rate)
			end

			Flying = false

			if CheckIfAlive() then
				Torso.Velocity = createVector(0, 0, 0)
				Torso.RotVelocity = createVector(0, 0, 0)
				Humanoid.WalkSpeed = 16
				Humanoid.PlatformStand = false
				Humanoid.AutoRotate = true
				DisableJump(false)
				Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			end
		end
	end)
end

function SetAnimation(p, data)
	if p == "PlayAnimation" and data and ToolEquipped and Humanoid then
		for k, v in pairs(Animations) do
			if v.Animation ~= data.Animation then
				continue
			end

			v.AnimationTrack:Stop()
			table.remove(Animations, k)
		end

		local track = Humanoid:LoadAnimation(data.Animation)
		table.insert(Animations, {
			Animation = data.Animation,
			AnimationTrack = track
		})
		track:Play(data.FadeTime, data.Weight, data.Speed)
	elseif p == "StopAnimation" and data then
		for k, v in pairs(Animations) do
			if v.Animation ~= data.Animation then
				continue
			end

			v.AnimationTrack:Stop()
			table.remove(Animations, k)
		end
	end
end

function DisableJump(p)
	if PreventJump then
		PreventJump:disconnect()
	end

	if p then
		PreventJump = Humanoid.Changed:connect(function(p2)
			if p2 == "Jump" then
				Humanoid.Jump = false
			end
		end)
	end
end

function CheckIfAlive()
	if Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent then
		return true
	end

	return false
end

function KeyPress(value, mode)
	local v = string.lower(value)
	local v2 = string.byte(v)

	for k, v3 in pairs(Controls) do
		if v == v3.Keys.Key or v2 == v3.Keys.ByteKey then
			Controls[k].Mode = mode
		end
	end
end

function Equipped(p)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	ToolEquipped = true

	if not CheckIfAlive() then
		return
	end

	p.KeyDown:connect(function(p2)
		KeyPress(p2, true)
	end)
	p.KeyUp:connect(function(p2)
		KeyPress(p2, false)
	end)
	Spawn(HandleFlightControl)
end

function Unequipped()
	Flying = false
	LocalObjects = {}

	for _, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end

	for _, v in pairs({ PreventJump, FightMonitor }) do
		if v then
			v:disconnect()
		end
	end

	for k, _ in pairs(Controls) do
		Controls[k].Mode = false
	end

	Animations = {}
	ToolEquipped = false
end

function OnClientInvoke(p, object)
	if p == "PlayAnimation" and object and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", object)
	elseif p == "StopAnimation" and object then
		SetAnimation("StopAnimation", object)
	elseif p == "PlaySound" and object then
		object:Play()
	elseif p == "StopSound" and object then
		object:Stop()
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)