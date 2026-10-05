local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local cannon_Z = FX:WaitForChild("Cannon").Cannon_Z
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }

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

local function mockRootPart(_, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	return part
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local random = Random.new()
return function(player)
	local origin = player.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stunTime = player.stunTime
	local explosionCount = player.explosionCount
	local projectileSpeed = player.projectileSpeed
	local projectileLifetime = player.projectileLifetime
	local hrphit = player.hrphit
	local folder = Instance.new("Folder")
	folder.Name = "CannonChainEffect"
	folder.Parent = _WorldOrigin
	local equippedAttachment = Util.GetEquippedAttachment(player.Character, player.Attachment)
	local worldPosition

	if equippedAttachment then
		worldPosition = equippedAttachment.WorldPosition
	else
		worldPosition = player.origin
	end

	local hrp = player.hrp
	local cFrame = CFrame.lookAt(worldPosition, player.targetPosition) * CFrame.new(0, 0, -0.75)
	local clone = cannon_Z.Start:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	part.Parent = folder

	if player.player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(10, 20, 0.1, 0.3)
	end

	TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
		Range = 0,
		Brightness = 0
	}):Play()
	sound:Play("BF_WPN_Cannon_ChainDetonationFire_01_V2", cFrame.Position)
	local clone2 = cannon_Z.StartBeam:Clone()
	local clone3 = cannon_Z.EndBeam:Clone()
	clone2.CFrame = cFrame
	clone2.Weld.Part0 = part
	clone3.CFrame = cFrame
	clone2.Beam.Attachment0 = clone2.Attachment
	clone2.Beam.Attachment1 = clone3.Attachment
	clone2.Parent = folder
	clone3.Parent = folder
	local lastTime = os.clock()
	local heartbeatConnection = nil
	local lastTime2 = tick()

	if hrphit then
		clone3.CFrame = CFrame.lookAt(cFrame.Position, hrphit.Position)
	end

	local raycastResult = nil
	local position = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		raycastResult = workspace:Raycast(clone3.Position, createVector(0, -10, 0), raycastParams)

		if raycastResult then
			if position then
				if (raycastResult.Position - position).Magnitude >= 18 and (raycastResult.Position - position).Magnitude <= 25 then
					local clone4 = cannon_Z.FloorFire:Clone()
					clone4.CFrame = CFrame.lookAt((raycastResult.Position + position) / 2, raycastResult.Position)
					clone4.Size = Vector3.new(15, 0.1, (raycastResult.Position - position).Magnitude)
					clone4.Parent = folder
					task.delay(0.8, function()
						local folder2 = clone4

						for _, emitter in pairs(folder2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						TweenService:Create(clone4.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
							Brightness = 0
						}):Play()
					end)
					position = raycastResult.Position
				elseif (raycastResult.Position - position).Magnitude >= 25 then
					position = raycastResult.Position
				end
			else
				position = raycastResult.Position
			end
		end

		clone3.CFrame *= CFrame.new(0, 0, -projectileSpeed * dt)

		if projectileLifetime <= os.clock() - lastTime then
			heartbeatConnection:Disconnect()
			local position2 = clone3.Position
			local lastTime3 = tick()

			while tick() - lastTime3 < 0.15 do
				local v4 = (tick() - lastTime3) / 0.15
				clone3.Position = position2 + (clone2.Position - position2) * v4
				task.wait()
			end

			local folder2 = clone3

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone2.Beam:Destroy()
			task.wait(5)
			folder:Destroy()
		end

		if hrphit and tick() - lastTime2 >= player.duration then
			heartbeatConnection:Disconnect()
			clone3.Anchored = false
			clone3.Position = hrphit.Position
			clone3.Anchored = true
			local clone4 = cannon_Z.Hit:Clone()
			clone4.CFrame = clone3.CFrame
			clone4.Parent = folder

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			sound:Play("BF_WPN_Cannon_Chain_Detonation_Hit_01_V2", clone4.Position)

			for _ = 1, 4 do
				task.spawn(function()
					local clone5 = cannon_Z.Trail:Clone()
					local position2 = clone2.Position
					local position3 = clone2.Position
					local v4 = position3 + (clone3.Position - position3) * 0.3 + Vector3.new(
						random:NextNumber(-40, 40),
						random:NextNumber(-40, 40),
						random:NextNumber(-40, 40)
					)
					local position4 = clone2.Position
					local v5 = position4 + (clone3.Position - position4) * 0.6 + Vector3.new(
						random:NextNumber(-20, 20),
						random:NextNumber(-20, 20),
						random:NextNumber(-20, 20)
					)
					local position5 = clone3.Position
					clone5.Position = position2
					clone5.Parent = folder
					local v6 = 1 / (stunTime / 0.015) * 0.015
					local lastTime3 = tick()

					while tick() - lastTime3 < v6 do
						local v7 = (tick() - lastTime3) / v6
						local v8 = position2 + (v4 - position2) * v7
						local v9 = v4 + (v5 - v4) * v7
						local v10 = v5 + (position5 - v5) * v7
						local v11 = v8 + (v9 - v8) * v7
						clone5.Position = v11 + (v9 + (v10 - v9) * v7 - v11) * v7
						task.wait()
					end

					clone5.Position = position5

					for _, emitter in pairs(clone5:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
			end

			clone2.Weld:Destroy()
			clone2.Anchored = true

			for i = 1, explosionCount do
				local clone5 = cannon_Z.SmallExplosion:Clone()
				local position2 = (hrp.CFrame * CFrame.new(0, 0, -4)).Position
				local position3 = clone3.Position
				local v4 = i / explosionCount
				clone5.Position = position2 + (position3 - position2) * v4 + Vector3.new(
					random:NextNumber(-5, 5),
					random:NextNumber(-5, 5),
					random:NextNumber(-5, 5)
				)
				local v5 = clone2
				local position4 = (hrp.CFrame * CFrame.new(0, 0, -4)).Position
				local position5 = clone3.Position
				local v6 = i / explosionCount
				v5.Position = position4 + (position5 - position4) * v6
				clone5.Parent = folder

				for _, emitter in pairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				TweenService:Create(clone5.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					Range = 0,
					Brightness = 0
				}):Play()

				if (workspace.CurrentCamera.CFrame.p - hrphit.CFrame.Position).Magnitude < 100 then
					local clone6 = FX:WaitForChild("Musket").Musket_Z.ColorCorrection:Clone()
					clone6.Brightness = 0.03
					clone6.TintColor = clone6.TintColor:Lerp(Color3.new(1, 1, 1), 0.93)
					clone6.Parent = game:GetService("Lighting")
					TweenService:Create(clone6, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
						TintColor = Color3.new(1, 1, 1),
						Brightness = 0
					}):Play()
					task.delay(0.2, clone6.Destroy, clone6)
					Util.CameraShaker:ShakeOnce(8, 12, 0.1, 0.3)
				end

				task.wait(stunTime / explosionCount)
			end

			if (workspace.CurrentCamera.CFrame.p - hrphit.CFrame.Position).Magnitude < 100 then
				local clone5 = FX:WaitForChild("Musket").Musket_Z.ColorCorrection:Clone()
				clone5.Parent = game:GetService("Lighting")
				TweenService:Create(clone5, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					TintColor = Color3.new(1, 1, 1),
					Brightness = 0
				}):Play()
				Util.CameraShaker:ShakeOnce(20, 10, 0.1, 0.3)
				task.delay(0.3, clone5.Destroy, clone5)
			end

			local clone5 = cannon_Z.BigExplosion:Clone()
			clone5.CFrame = hrphit.CFrame
			clone5.Parent = folder

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			TweenService:Create(clone5.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Range = 0,
				Brightness = 0
			}):Play()
			local folder2 = clone3

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(0.2)
			TweenService:Create(clone2.Beam, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			task.wait(5)
			folder:Destroy()
		end
	end)
end