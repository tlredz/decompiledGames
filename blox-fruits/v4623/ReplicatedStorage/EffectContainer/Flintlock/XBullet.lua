local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local flintlockX = FX:WaitForChild("Flintlock").FlintlockX
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function ParticleState(folder, enabled, p)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if p and effect:GetAttribute("Color") == true then
			effect.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end
	end
end

local random = Random.new()
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies }
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
return function(data)
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local bulletSpeed = data.BulletSpeed
	local bulletLifetime = data.BulletLifetime
	local _ = data.TimeBetweenShots
	local folder = Instance.new("Folder")
	folder.Name = "FlintlockXEffect"
	folder.Parent = _WorldOrigin
	local startCFrame = data.startCFrame
	local folder2 = Instance.new("Folder")
	folder2.Name = "BulletFolder"
	folder2.Parent = folder
	local clone = flintlockX.StartBeam:Clone()
	local clone2 = flintlockX.EndBeam:Clone()
	clone.CFrame = startCFrame
	clone2.CFrame = clone.CFrame
	local clone3 = flintlockX.Launch:Clone()
	clone3.CFrame = clone.CFrame
	clone3.Parent = folder
	ParticleState(clone3)

	if data.i == 1 then
		Util.Sound:Play("BF_WPN_Flintlock_X_Explosion_01", clone3.Position)
	end

	if data.i == 1 and data.hrp == game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local clone4 = FX:WaitForChild("Musket").Musket_Z.ColorCorrection:Clone()
		clone4.Parent = game:GetService("Lighting")
		TweenService:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			TintColor = Color3.new(1, 1, 1),
			Brightness = 0
		}):Play()
		Util.CameraShaker:ShakeOnce(10, 6, 0.1, 0.3)
		task.delay(0.3, clone4.Destroy, clone4)
	end

	local target = data.Target
	local raycastResult = nil
	clone.Beam.Attachment1 = clone2.b
	clone.Parent = folder2
	clone2.Parent = folder2
	local lastTime = os.clock()
	local lastTime2 = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		raycastResult = workspace:Raycast(clone2.Position, clone2.CFrame.LookVector * bulletSpeed * dt, raycastParams)

		if target and (target[2] - clone2.Position).Magnitude <= 5 then
			heartbeatConnection:Disconnect()
			local folder3 = clone

			for _, effect in pairs(folder3:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			TweenService:Create(clone.Beam, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			local folder4 = clone2

			for _, effect in pairs(folder4:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			local clone4 = flintlockX.BulletHit:Clone()
			clone4.CFrame = clone2.CFrame
			clone4.Parent = folder
			ParticleState(clone4)
			TweenService:Create(clone4.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Range = 0,
				Brightness = 0
			}):Play()
		end

		if os.clock() - lastTime2 >= 0.05 and target and (clone2.Position - startCFrame.Position).Magnitude >= target[1] and heartbeatConnection.Connected == true then
			lastTime2 = os.clock()
			TweenService:Create(clone.Beam, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			local folder3 = clone

			for _, effect in pairs(folder3:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			clone = flintlockX.StartBeam:Clone()
			clone.CFrame = CFrame.lookAt(clone2.Position, target[2]) * CFrame.Angles(
				random:NextNumber(-0.17453292519943295, 0.17453292519943295),
				random:NextNumber(-0.17453292519943295, 0.17453292519943295),
				0
			)
			local folder4 = clone2

			for _, effect in pairs(folder4:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			clone2 = flintlockX.EndBeam:Clone()
			clone.Beam.Attachment1 = clone2.b
			clone2.CFrame = clone.CFrame
			clone.Parent = folder2
			clone2.Parent = folder2
			local clone4 = flintlockX.Bounce:Clone()
			clone4.CFrame = clone.CFrame
			clone4.Parent = folder2
			ParticleState(clone4)
		end

		if bulletLifetime <= os.clock() - lastTime or raycastResult then
			heartbeatConnection:Disconnect()
			local folder3 = clone2

			for _, effect in pairs(folder3:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			local folder4 = clone

			for _, effect in pairs(folder4:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			TweenService:Create(clone.Beam, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			local clone4 = flintlockX.BulletHit:Clone()
			clone4.CFrame = clone2.CFrame
			clone4.Parent = folder
			ParticleState(clone4)
			TweenService:Create(clone4.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Range = 0,
				Brightness = 0
			}):Play()

			if raycastResult then
				local clone5 = flintlockX.FloorHit:Clone()
				clone5.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
				clone5.Parent = folder
				ParticleState(clone5)
			end
		end

		clone2.CFrame *= CFrame.new(0, 0, -bulletSpeed * dt)
	end)
	task.wait(4)
	folder:Destroy()
end