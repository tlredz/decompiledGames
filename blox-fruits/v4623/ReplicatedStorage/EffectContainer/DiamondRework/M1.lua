local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local beamingTackle = FX:WaitForChild("Diamond").BeamingTackle
local _WorldOrigin = workspace._WorldOrigin
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function ParticleState(folder, enabled, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end
	end
end

return function(data)
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local stage = data.Stage
	local player = data.Player

	if stage == 1 then
		local HRP = data.HRP
		local parent = HRP.Parent
		local t = data.t or tick()
		local v = math.clamp(tick() - t, 0, 1) * 0.5 + 1
		local folder = Instance.new("Folder")
		folder.Name = "DiamondTAPEffect"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DiamondFruitVFXColor")
		local clone = beamingTackle.RootAttach:Clone()
		clone.CFrame = HRP.CFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "DiamondFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		sound:Play("Diamond.DiamondM1", HRP.Position)
		local velocity = data.Direction.lookVector * 100 * v * 5
		local v3 = velocity.Magnitude * 0.2
		local v4 = Util.BodyMover.new(parent):Create("BodyVelocity", {
			Velocity = velocity
		})
		local raycastResult = nil
		local flag = false

		local function clear()
			local Players = game:GetService("Players")

			if Players.LocalPlayer ~= data.Local or flag then
				return
			end

			if v4 then
				flag = true
				task.spawn(function()
					v4:Set(data.Direction.LookVector * 90 * v * 5 * 0.33)
					wait()
					v4:Destroy()
				end)
			end
		end

		local lastTime = os.clock()
		local position = HRP.Position
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			raycastResult = workspace:Raycast(HRP.Position, HRP.Velocity * dt, raycastParams)

			if clone then
				clone.CFrame = CFrame.lookAt(HRP.Position, HRP.Position + HRP.Velocity)
			end

			local v5 = v3 <= (HRP.Position - position).Magnitude

			if raycastResult or v5 or os.clock() - lastTime >= 0.2 then
				if clone then
					clone.Trail.Enabled = false
				end

				clear()
				heartbeatConnection:Disconnect()
			end
		end)
		task.wait(0.2)
		clear()

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		clone.Trail.Enabled = false
		TweenService:Create(clone.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()
		task.wait(3)
		folder:Destroy()
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Name = "DiamondTAPEffect"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DiamondFruitVFXColor")
		local hitPosition = data.HitPosition
		local hitNormal = data.HitNormal
		local clone = beamingTackle.Impact:Clone()
		clone.CFrame = CFrame.lookAt(hitPosition, hitPosition + hitNormal)
		Util.SetParentOverrideWithColor(clone, folder, player, "DiamondFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		sound:Play("Diamond.DiamondM1Explosion", hitPosition)
		TweenService:Create(clone.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()

		for _ = 1, 16 do
			local clone2 = beamingTackle.Shard:Clone()
			clone2.Size = createVector(1, 1, 1) * random:NextNumber(2, 5)
			clone2.Orientation = Vector3.new(
				random:NextNumber(-360, 360),
				random:NextNumber(-360, 360),
				random:NextNumber(-360, 360)
			)
			clone2.Position = hitPosition
			rocks:ApplyCollision(clone2, nil, true)
			Util.SetParentOverrideWithColor(clone2, folder, player, "DiamondFruitVFXColor")
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = (CFrame.lookAt(hitPosition, hitPosition + hitNormal) * CFrame.Angles(
				math.rad((random:NextNumber(-30, 30))),
				math.rad((random:NextNumber(-30, 30))),
				0
			)).LookVector * random:NextNumber(40, 80)
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			Util.SetParentOverrideWithColor(bodyVelocity, clone2, player, "DiamondFruitVFXColor")
			task.delay(0.1, function()
				bodyVelocity:Destroy()
				task.wait(random:NextNumber(0.3, 0.6))
				TweenService:Create(clone2, TweenInfo.new(random:NextNumber(0.2, 0.5), Enum.EasingStyle.Linear), {
					Size = createVector(0, 0, 0)
				}):Play()
			end)
		end

		task.wait(8)
		folder:Destroy()
	elseif stage == 3 then
		local folder = Instance.new("Folder")
		folder.Name = "DiamondTAPHitEffect"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DiamondFruitVFXColor")
		local clone = beamingTackle.EnemyRootAttach:Clone()
		Util.SetParentOverrideWithColor(clone, folder, player, "DiamondFruitVFXColor")
		local victimRoot = data.VictimRoot
		local position = victimRoot.Position
		local clone2 = beamingTackle.PlayerHit:Clone()
		clone2.Position = victimRoot.Position
		Util.SetParentOverrideWithColor(clone2, folder, player, "DiamondFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			clone.CFrame = CFrame.lookAt(victimRoot.Position, position)
		end)
		task.delay(0.4, function()
			heartbeatConnection:Disconnect()
			local folder2 = clone

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		task.wait(5)
		folder:Destroy()
	end
end