local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local vector2 = Vector3.new()
local inverse = CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local cDash = FX:WaitForChild("PhoenixEffects").CDash
local cTornado = FX:WaitForChild("PhoenixEffects").CTornado
local phoenixExplosion = FX:WaitForChild("PhoenixEffects").PhoenixExplosion
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
local PlaySchemes = require(interpolationScheme:WaitForChild("PlaySchemes"))
local TornadoElectrons = require(script.Parent.Modules:WaitForChild("TornadoElectrons"))
local Shockwaves = require(script.Parent.Modules:WaitForChild("Shockwaves"))

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local function StopBodyVelocity(char, instance)
	instance:Set(vector2)
	heartbeatLoopFor2(0.05, function(_)
		char.HumanoidRootPart.AssemblyLinearVelocity = vector2
	end, function()
		instance:Destroy()
	end)
	char.Humanoid.PlatformStand = false
end

local function CheckIfShouldTornado(instance)
	return instance:FindFirstChild("PhoenixCshouldTornado") ~= nil
end

local function adjustDuration(p, p2)
	local v = math.max(0.01, p - p2)
	return v, p2 - (p - v)
end

return function(data)
	local timeStamp = data.TimeStamp
	local player = data.player
	local _ = data.victimRootParts
	local char = data.char
	local origin = data.origin
	local humanoidRootPart = char.HumanoidRootPart
	local v = math.max(0, Workspace:GetServerTimeNow() - timeStamp - 0.2)

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1200 then
		return
	end

	local humanoid = char.Humanoid
	local v2 = true
	local _ = data.syncedStartTime
	local syncedEndTime = data.syncedEndTime
	local position = nil
	local heartbeatConnection = nil
	local RunService = game:GetService("RunService")
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local serverTimeNow = Workspace:GetServerTimeNow()

		if syncedEndTime - 0.1 < serverTimeNow then
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			v2 = false

			if not (char:FindFirstChild("PhoenixCshouldTornado") ~= nil and humanoidRootPart ~= nil) then
				return
			end

			task.wait(0.25)
			local flag

			if position == nil then
				flag = false
				position = humanoidRootPart.Position
			else
				flag = true
			end

			local clone = phoenixExplosion:Clone()
			clone:SetPrimaryPartCFrame(CFrame.Angles(0, random:NextNumber(0, 6.283185307179586), 0) + position)

			if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 240 then
				Util.CameraShaker:ShakeOnce(25, 25, 0.1, 0.8)
			end

			if flag then
				task.spawn(Shockwaves, position, 18, 2, Color3.fromRGB(0, 197, 255), Color3.fromRGB(255, 200, 0))
			else
				clone.Shockwave:Destroy()
			end

			clone.Parent = _WorldOrigin
			destroyAfter(clone, PlaySchemes(clone:GetDescendants()) + 1)
		end
	end)
	local fireDir = data.fireDir
	local dashTime = data.dashTime
	local distanceForward = data.distanceForward
	local _ = data.dragRadius
	local clone = cDash:Clone()
	clone:SetPrimaryPartCFrame(CFrame.lookAt(Vector3.new(), fireDir) * inverse + origin + createVector(0, 5, 0))
	clone.Parent = _WorldOrigin
	destroyAfter(clone, PlaySchemes(clone:GetDescendants()) + 1)
	local v4 = math.max(0.01, dashTime - v)
	local _ = v - (dashTime - v4)
	local velocity = fireDir * (v4 < 0.016666666666666666 and 0 or distanceForward / v4)
	local cFrame, v7, v8

	if localPlayer == player then
		local cFrame2 = CFrame.lookAt(Vector3.new(), fireDir) * CFrame.Angles(-1.5707963267948966, 0, 0) + origin
		humanoidRootPart.CFrame = cFrame2
		cFrame = cFrame2 - cFrame2.p
		v7 = Util.BodyMover.new(char):Create("BodyGyro", {
			Duration = 4,
			Priority = 100,
			CFrame = cFrame,
			MaxTorque = createVector(1048576, 1048576, 1048576)
		})
		v8 = Util.BodyMover.new(char):Create("BodyVelocity", {
			Duration = 4,
			Priority = 100,
			Velocity = velocity,
			MaxForce = createVector(1048576, 1048576, 1048576)
		})
	else
		cFrame = nil
		v7 = nil
		v8 = nil
	end

	task.wait()
	awaitHeartbeatLoopFor(v4, function(_)
		if localPlayer == player then
			cFrame *= CFrame.Angles(0, -0.5, 0)
			v7:Set(cFrame)
		end
	end, function()
		if localPlayer == player then
			local v9 = origin + fireDir * distanceForward
			v8:Set((Vector3.new()))
			humanoidRootPart.CFrame = CFrame.new(v9) * (humanoidRootPart.CFrame - humanoidRootPart.CFrame.p)
		end
	end)
	task.wait()
	local v9 = origin + fireDir * distanceForward

	if localPlayer == player then
		local cframe = CFrame.lookAt(Vector3.new(), fireDir * createVector(1, 0.01, 1))

		if cframe ~= cframe then
			cframe = humanoidRootPart.CFrame - humanoidRootPart.CFrame.p
		end

		cFrame = cframe
		v7:Set(cframe)
		humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * cframe
		task.wait()
	end

	if localPlayer == player then
		StopBodyVelocity(char, v8)
	end

	local spiralUpTime = data.spiralUpTime
	local flyUpDistance = data.flyUpDistance
	local v10 = math.max(0.01, spiralUpTime - v)
	local _ = v - (spiralUpTime - v10)

	if char:FindFirstChild("PhoenixCshouldTornado") ~= nil then
		clone = cTornado:Clone()
		local magnitude = (v9 - origin).Magnitude
		clone:SetPrimaryPartCFrame(CFrame.new(origin + fireDir * magnitude) - createVector(0, 2, 0))

		for _, part in ipairs(clone:GetDescendants()) do
			if not (part.Name ~= "Shock" and part:IsA("BasePart") or part.Name == "BasePart") then
				continue
			end

			part:SetAttribute("SizeMultiplierGoal", part:GetAttribute("SizeMultiplierGoal") * 0.5)
			part:SetAttribute("SpeedInitial", part:GetAttribute("SpeedInitial") * 0.5)
			part:SetAttribute("SpeedGoal", part:GetAttribute("SpeedGoal") * 0.5)
		end

		clone.Parent = _WorldOrigin
		destroyAfter(clone, PlaySchemes(clone:GetDescendants()) + 1)
	end

	if char:FindFirstChild("PhoenixCshouldTornado") ~= nil then
		if localPlayer == player then
			local v11 = v10 < 0.016666666666666666 and 0 or flyUpDistance / v10
			local velocity2 = createVector(0, 1, 0) * v11 * 1.5
			v8 = Util.BodyMover.new(char):Create("BodyVelocity", {
				Duration = 4,
				Velocity = velocity2,
				MaxForce = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
			})
		end

		task.spawn(function()
			for _ = 1, 5 do
				TornadoElectrons(clone.PrimaryPart.Position)
				TornadoElectrons(clone.PrimaryPart.Position)
				TornadoElectrons(clone.PrimaryPart.Position)
				TornadoElectrons(clone.PrimaryPart.Position)
				task.wait(0.15)
			end
		end)
		awaitHeartbeatLoopFor(v10, function(p)
			local v11 = math.min(1, p / v10)

			if localPlayer == player then
				local _ = v9 + createVector(0, 1, 0) * flyUpDistance * v11
				cFrame *= CFrame.Angles(0, -0.5, 0)
				v7:Set(cFrame)
				humanoid.Sit = false
				humanoid.PlatformStand = true
			end
		end, function()
			if localPlayer == player then
				local v11 = v9 + createVector(0, 1, 0) * flyUpDistance
				v8:Set((Vector3.new()))
				v7:Set(cFrame)
				humanoidRootPart.CFrame = CFrame.new(v11) * (cFrame - cFrame.p)
			end
		end)
		local rayCastWhitelist, v11, _ = Util.RayCastWhitelist(
			humanoidRootPart.Position,
			createVector(0, -1, 0) * flyUpDistance * 1.1,
			{ Workspace.Map }
		)

		if rayCastWhitelist == nil then
			v11 = nil
		end

		position = v11
	elseif localPlayer == player then
		task.defer(function()
			pcall(function()
				v7:Destroy()
			end)
			pcall(function() end)
		end)
	end

	if char:FindFirstChild("PhoenixCshouldTornado") ~= nil then
		if localPlayer == player then
			StopBodyVelocity(char, v8)
		end

		local timeSlam = data.timeSlam
		local v11 = math.max(0.01, timeSlam - v)
		local _ = v - (timeSlam - v11)
		local v12 = v11 * 1.4
		local v13 = v9 + createVector(0, 1, 0) * flyUpDistance
		local _, v14, _ = Util.RayCastWhitelist(v13, createVector(0, -1, 0) * flyUpDistance * 2, { Workspace.Map })
		local magnitude = (v14 - v13).Magnitude
		local v15 = -(4 - v14.Y)

		if v15 < 15 then
			magnitude += v15 - 15
		end

		local v16

		if localPlayer == player then
			local v17 = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)) * CFrame.Angles(1.5707963267948966, 0, 0)
			v7:Set(v17)
			cFrame = v17
			humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * v17
			local v18 = v12 < 0.016666666666666666 and 0 or magnitude / v12
			local velocity2 = createVector(-0, -1, -0) * v18
			v16 = Util.BodyMover.new(char):Create("BodyVelocity", {
				Duration = 4,
				Priority = 100,
				Velocity = velocity2,
				MaxForce = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
			})
		else
			v16 = nil
		end

		local v17 = false
		awaitHeartbeatLoopFor(v12, function(p, p2)
			local v18 = math.min(1, p / v12)

			if localPlayer == player then
				local _ = v9 + createVector(0, 1, 0) * flyUpDistance - createVector(0, 1, 0) * magnitude * v18
				local position2

				if v17 then
					position2 = v9 + createVector(0, 1, 0) * flyUpDistance - createVector(0, 1, 0) * magnitude

					if not v17 then
						v16:Set((Vector3.new()))
						humanoidRootPart.Velocity = Vector3.new()
						v17 = Util.BodyMover.new(char):Create("BodyPosition", {
							Duration = 4,
							Priority = 100,
							Position = position2,
							MaxForce = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
						})
						v17:Set(position2)
					end

					v17:Set(position2)
					humanoidRootPart.CFrame = CFrame.new(position2) * cFrame
				elseif magnitude <= math.abs(((humanoidRootPart.Position - v13):Dot(createVector(-0, -1, -0)))) + humanoidRootPart.Velocity.Y * (p2 / 2) then
					position2 = v9 + createVector(0, 1, 0) * flyUpDistance - createVector(0, 1, 0) * magnitude

					if not v17 then
						v16:Set((Vector3.new()))
						humanoidRootPart.Velocity = Vector3.new()
						v17 = Util.BodyMover.new(char):Create("BodyPosition", {
							Duration = 4,
							Priority = 100,
							Position = position2,
							MaxForce = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
						})
						v17:Set(position2)
					end

					v17:Set(position2)
					humanoidRootPart.CFrame = CFrame.new(position2) * cFrame
				end

				cFrame *= CFrame.Angles(0, -0.5, 0)
				v7:Set(cFrame)
				humanoid.Sit = false
				humanoid.PlatformStand = true
			end
		end, function()
			if localPlayer == player then
				local v18 = v9 + createVector(0, 1, 0) * flyUpDistance - createVector(0, 1, 0) * magnitude
				v16:Set((Vector3.new()))
				v7:Set(cFrame)
				humanoidRootPart.CFrame = CFrame.new(v18) * cFrame
			end
		end)

		if localPlayer == player then
			if v17 then
				v17:Destroy()
			end

			StopBodyVelocity(char, v16)
			humanoid.PlatformStand = false
			v7:Destroy()
			heartbeatLoopFor2(0.4, function(_)
				humanoidRootPart.Velocity = vector2
				humanoidRootPart.CFrame = CFrame.lookAt(
					humanoidRootPart.Position,
					humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * createVector(1, 0.1, 1)
				)
			end, function()
				humanoidRootPart.CFrame = CFrame.lookAt(
					humanoidRootPart.Position,
					humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * createVector(1, 0.1, 1)
				)
			end)
		end
	elseif localPlayer == player then
		task.defer(function()
			pcall(function() end)
			pcall(function()
				v7:Destroy()
			end)
		end)
	end

	task.wait()

	if localPlayer == player then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end