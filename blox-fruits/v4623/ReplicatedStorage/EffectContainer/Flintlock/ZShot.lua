local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local flintlockZ = FX:WaitForChild("Flintlock").FlintlockZ
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

local function RetrieveShootAttachment(parent)
	if parent:FindFirstChild("EquippedWeapon") then
		for _, descendant in pairs(parent.EquippedWeapon:GetDescendants()) do
			if descendant.Name == "ShootAttachment" then
				return descendant
			end
		end
	end

	return nil
end

local random = Random.new()

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
Util.ResizeModel(flintlockZ.Implode, 0.6, flintlockZ.Implode.Position)
Util.ResizeModel(flintlockZ.Impact, 0.6, flintlockZ.Impact.Position)
Util.ResizeModel(flintlockZ.Start, 0.6, flintlockZ.Start.Position)
Util.ResizeModel(flintlockZ.Launch, 0.6, flintlockZ.Launch.Position)
Util.ResizeModel(flintlockZ.Beam, 0.6, flintlockZ.Beam.Position)
Util.ResizeModel(flintlockZ.Beam2, 0.6, flintlockZ.Beam2.Position)
Util.ResizeModel(flintlockZ.SmallerProjectile, 0.6, flintlockZ.SmallerProjectile.Position)
Util.ResizeModel(flintlockZ.SmallerImpact, 0.6, flintlockZ.SmallerImpact.Position)
Util.Recolor(flintlockZ, Color3.fromRGB(255, 86, 44), 1)
return function(data)
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	if data.stage == 1 then
		local tool = data.tool
		local holding = data.holding or tool and tool:FindFirstChild("Holding")

		if not holding then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "FlintlockZHold"
		folder.Parent = _WorldOrigin
		local clone = flintlockZ.Start:Clone()
		clone.Anchored = true
		clone.Parent = folder
		local retrieveShootAttachment = RetrieveShootAttachment(data.hrp.Parent)
		local v2 = sound:Play("BF_WPN_Flintlock_Skill_Hold_01", origin)

		while (tool or holding) and holding and holding.Value and retrieveShootAttachment and data.hrp and clone and folder do
			clone.CFrame = retrieveShootAttachment.WorldCFrame
			task.wait()
		end

		if v2 then
			sound:FadeOut(v2, 0.2)
		end

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		task.wait(5)

		if folder then
			folder:Destroy()
		end
	elseif data.stage == 2 then
		local projectileSpeed = data.projectileSpeed
		local projectileLifetime = data.projectileLifetime
		local folder = Instance.new("Folder")
		folder.Name = "FlintlockZEffect"
		folder.Parent = _WorldOrigin
		local startCFrame = data.startCFrame
		local clone = flintlockZ.Launch:Clone()
		clone.CFrame = startCFrame
		clone.Parent = folder
		ParticleState(clone)

		if data.hrp == game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			Util.CameraShaker:ShakeOnce(3, 9, 0.05, 0.2)
		end

		sound:Play("BF_WPN_Flintlock_Z_Fire_01", startCFrame.Position)
		local clone2 = flintlockZ.Beam:Clone()
		clone2.CFrame = clone.CFrame
		clone2.Parent = folder

		for _, beam in clone2:GetDescendants() do
			if beam:IsA("Beam") then
				TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		local clone3 = flintlockZ.Beam2:Clone()
		clone3.CFrame = clone.CFrame
		clone3.Parent = folder

		for _, beam in clone3:GetDescendants() do
			if beam:IsA("Beam") then
				TweenService:Create(beam, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			CFrame = clone3.CFrame * CFrame.new(0, 0, -3)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
			CFrame = clone3.CFrame * CFrame.new(0, 0, -6)
		}):Play()
		local clone4 = flintlockZ.Projectile:Clone()
		clone4.CFrame = startCFrame
		clone4.Parent = folder
		local lastTime = os.clock()
		local lastTime2 = os.clock()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if os.clock() - lastTime >= random:NextNumber(0.05, 0.1) then
				lastTime = os.clock()
				local clone5 = flintlockZ.SmallFireTrail:Clone()
				local number = random:NextNumber(0, 360)
				local number2 = random:NextNumber(360, 720)
				local number3 = random:NextNumber(2, 8)
				local number4 = random:NextNumber(2, 8)
				local number5 = random:NextNumber(2, 8)
				clone5.CFrame = clone4.CFrame * CFrame.new(
					math.sin((math.rad(number))) * number3,
					math.cos((math.rad(number))) * number4,
					math.sin((math.rad(number))) * number5
				)
				clone5.Parent = folder
				clone5.Trail.Lifetime = random:NextNumber(0.15, 0.3)
				local lastTime3 = os.clock()
				local heartbeatConnection2 = nil
				heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt2)
					number += number2 * dt2
					clone5.CFrame = clone4.CFrame * CFrame.new(
						math.sin((math.rad(number))) * number3,
						math.cos((math.rad(number))) * number4,
						math.sin((math.rad(number))) * number5
					)

					if os.clock() - lastTime3 >= random:NextNumber(0.5, 0.9) or heartbeatConnection.Connected == false then
						heartbeatConnection2:Disconnect()
						local folder2 = clone5

						for _, effect in pairs(folder2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end
				end)
			end

			if projectileLifetime <= os.clock() - lastTime2 then
				heartbeatConnection:Disconnect()
				local folder2 = clone4

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				TweenService:Create(clone4.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					Range = 0,
					Brightness = 0
				}):Play()
				task.wait(5)
				folder:Destroy()
			end

			clone4.CFrame *= CFrame.new(0, 0, -dt * projectileSpeed)
		end)
	elseif data.stage == 3 then
		local miniSpeed = data.miniSpeed
		local burstCount = data.burstCount
		local miniLifetime = data.miniLifetime
		local folder = Instance.new("Folder")
		folder.Name = "FlintlockZExplosion"
		folder.Parent = _WorldOrigin
		local clone = flintlockZ.Implode:Clone()
		clone.Position = data.explodeAt
		clone.Parent = folder
		ParticleState(clone)
		sound:Play("BF_WPN_Flintlock_Z_Explosion_01", data.explodeAt)
		local _ = data.targetTable

		for _ = 1, 12 do
			local clone2 = flintlockZ.StartBeam:Clone()
			local clone3 = flintlockZ.End:Clone()
			clone2.Position = clone.Position
			clone3.Position = clone.Position + Vector3.new(
				random:NextNumber(-70, 70),
				random:NextNumber(-70, 70),
				random:NextNumber(-70, 70)
			) * 0.6
			clone2.Beam.Width0 = 0
			clone2.Beam.Width1 = 0
			clone2.Beam.Attachment1 = clone3.b
			clone2.Parent = folder
			clone3.Parent = folder
			local number = random:NextNumber(0.1, 0.25)
			local number2 = random:NextNumber(3, 8)
			TweenService:Create(clone2.Beam, TweenInfo.new(number, Enum.EasingStyle.Linear), {
				Width1 = number2
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(number * 2 / 3, Enum.EasingStyle.Linear), {
				Position = clone2.Position
			}):Play()
		end

		local rayResult = data.RayResult

		for _ = 1, 6 do
			task.spawn(function()
				local clone2 = flintlockZ.Bezier:Clone()
				local position = data.explodeAt + Vector3.new(
					random:NextNumber(-50, 50),
					random:NextNumber(-50, 50),
					random:NextNumber(-50, 50)
				) * 0.6
				local position2 = data.explodeAt + Vector3.new(
					random:NextNumber(-50, 50),
					random:NextNumber(-50, 50),
					random:NextNumber(-50, 50)
				) * 0.6
				local position3 = data.explodeAt + Vector3.new(
					random:NextNumber(-50, 50),
					random:NextNumber(-50, 50),
					random:NextNumber(-50, 50)
				) * 0.6
				local explodeAt = data.explodeAt

				if rayResult then
					position = (CFrame.lookAt(rayResult.Position, rayResult.Position + rayResult.Normal) * CFrame.Angles(
						random:NextNumber(-1.5707963267948966, 1.5707963267948966),
						random:NextNumber(-1.5707963267948966, 1.5707963267948966),
						0
					) * CFrame.new(0, 0, -random:NextNumber(12, 50))).Position
					position2 = (CFrame.lookAt(rayResult.Position, rayResult.Position + rayResult.Normal) * CFrame.Angles(
						random:NextNumber(-1.5707963267948966, 1.5707963267948966),
						random:NextNumber(-1.5707963267948966, 1.5707963267948966),
						0
					) * CFrame.new(0, 0, -random:NextNumber(12, 50))).Position
					position3 = (CFrame.lookAt(rayResult.Position, rayResult.Position + rayResult.Normal) * CFrame.Angles(
						random:NextNumber(-1.5707963267948966, 1.5707963267948966),
						random:NextNumber(-1.5707963267948966, 1.5707963267948966),
						0
					) * CFrame.new(0, 0, -random:NextNumber(12, 50))).Position
				end

				clone2.Position = position
				clone2.Parent = folder
				local lastTime = tick()

				while tick() - lastTime < 0.15 do
					local v = (tick() - lastTime) / 0.15
					local v2 = position + (position2 - position) * v
					local v3 = position2 + (position3 - position2) * v
					local v4 = position3 + (explodeAt - position3) * v
					local v5 = v2 + (v3 - v2) * v
					clone2.Position = v5 + (v3 + (v4 - v3) * v - v5) * v
					task.wait()
				end

				clone2.Position = explodeAt
			end)
			task.wait(random:NextNumber(0.015, 0.02))
		end

		local clone2 = flintlockZ.Impact:Clone()
		clone2.Position = data.explodeAt
		clone2.Parent = folder
		ParticleState(clone2)

		if (currentCamera.CFrame.Position - clone2.Position).Magnitude <= 70 then
			local clone3 = FX:WaitForChild("Musket").Musket_Z.ColorCorrection:Clone()
			clone3.Parent = game:GetService("Lighting")
			TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				TintColor = Color3.new(1, 1, 1),
				Brightness = 0
			}):Play()
			Util.CameraShaker:ShakeOnce(20, 10, 0.1, 0.3)
			task.delay(0.3, clone3.Destroy, clone3)
		end

		for i = 1, burstCount do
			local v = i
			task.spawn(function()
				local clone3 = flintlockZ.SmallerProjectile:Clone()

				if data.burstAngles[1] then
					clone3.CFrame = data.burstAngles[v]
				elseif rayResult then
					clone3.CFrame = CFrame.lookAt(rayResult.Position, rayResult.Position + rayResult.Normal) * CFrame.Angles(
						random:NextNumber(-1.5707963267948966, 1.5707963267948966),
						random:NextNumber(-1.5707963267948966, 1.5707963267948966),
						0
					)
				else
					clone3.CFrame = clone2.CFrame * CFrame.Angles(
						random:NextNumber(0, 6.283185307179586),
						random:NextNumber(0, 6.283185307179586),
						random:NextNumber(0, 6.283185307179586)
					)
				end

				clone3.Parent = folder
				local raycastResult = workspace:Raycast(
					clone3.Position,
					clone3.CFrame.LookVector * miniSpeed * 1 / 60,
					raycastParams
				)
				local lastTime = os.clock()
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					raycastResult = workspace:Raycast(
						clone3.Position,
						clone3.CFrame.LookVector * miniSpeed * 1 / 60,
						raycastParams
					)
					clone3.CFrame *= CFrame.new(0, 0, -dt * miniSpeed)
					local clone4, folder2

					if raycastResult then
						heartbeatConnection:Disconnect()

						if raycastResult then
							clone3.Position = raycastResult.Position
						end

						clone4 = flintlockZ.SmallerImpact:Clone()
						clone4.CFrame = clone3.CFrame
						clone4.Parent = folder
						ParticleState(clone4)
						TweenService:Create(clone3.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
							Range = 0,
							Brightness = 0
						}):Play()
						folder2 = clone3

						for i2, effect in pairs(folder2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end

						TweenService:Create(clone3.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
							Range = 0,
							Brightness = 0
						}):Play()
					elseif miniLifetime <= os.clock() - lastTime or data.targetHit then
						heartbeatConnection:Disconnect()

						if raycastResult then
							clone3.Position = raycastResult.Position
						end

						clone4 = flintlockZ.SmallerImpact:Clone()
						clone4.CFrame = clone3.CFrame
						clone4.Parent = folder
						ParticleState(clone4)
						TweenService:Create(clone3.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
							Range = 0,
							Brightness = 0
						}):Play()
						folder2 = clone3

						for i2, effect in pairs(folder2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end

						TweenService:Create(clone3.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
							Range = 0,
							Brightness = 0
						}):Play()
					end
				end)
			end)
		end

		task.wait(6)
		folder:Destroy()
	end
end