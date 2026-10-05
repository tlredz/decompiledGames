local createVector = vector.create
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local magmaGunZ = FX:WaitForChild("MagmaGun").MagmaGunZ
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

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

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

return function(data)
	local cFrame = data.CFrame
	local duration = data.Duration
	local random2 = Random.new(data.Seed)

	if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "EffectsFolder"
	folder.Parent = workspace._WorldOrigin
	local clone = magmaGunZ.Start:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	ParticleState(clone)
	Util.Sound:Play("BF_WPN_RefMusket_ScorchingBurstFire_01", cFrame.Position)
	local player = data.player
	local Players2 = game:GetService("Players")

	if player == Players2.LocalPlayer then
		Effect.new("ShakeCam"):play({
			8,
			12,
			0.05,
			0.2
		})
	end

	local clone2 = magmaGunZ.Projectile:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = folder
	local lastTime = os.clock()
	local lastTime2 = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		clone2.CFrame *= CFrame.new(0, 0, -500 * dt)

		if os.clock() - lastTime >= random:NextNumber(0.04, 0.2) then
			lastTime = os.clock()
			local clone3 = magmaGunZ.Drip:Clone()
			clone3.CFrame = clone2.CFrame * CFrame.new(
				random:NextNumber(-clone2.Size.X / 2, clone2.Size.X / 2),
				random:NextNumber(-clone2.Size.Y / 2, clone2.Size.Y / 2),
				random:NextNumber(-clone2.Size.Z / 2, clone2.Size.Z / 2)
			)
			clone3.Parent = folder
			ParticleState(clone3)
			local raycastResult = nil
			local lastTime3 = os.clock()
			local heartbeatConnection2 = nil
			heartbeatConnection2 = RunService.Heartbeat:Connect(function()
				raycastResult = workspace:Raycast(clone3.Position, clone3.Velocity.Unit * 5, raycastParams)

				if raycastResult or os.clock() - lastTime3 >= 2 then
					heartbeatConnection2:Disconnect()
					local folder2 = clone3

					for _, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					if raycastResult then
						local clone4 = magmaGunZ.FloorMiniMagma:Clone()
						clone4.CFrame = CFrame.lookAt(
							raycastResult.Position,
							raycastResult.Position + raycastResult.Normal
						)
						clone4.Parent = folder
						local clone5 = magmaGunZ.MiniExplosions:Clone()
						clone5.CFrame = clone4.CFrame
						clone5.Parent = folder
						ParticleState(clone5)
						Util.Sound:Play(
							"BF_WPN_RefMusket_Scorching_Explosions_0" .. tostring(math.random(1, 3)) .. "_V2",
							clone5.Position
						)
						task.delay(1, function()
							local folder3 = clone4

							for _, effect in pairs(folder3:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end)
					end
				end
			end)
		end

		if duration < os.clock() - lastTime2 then
			heartbeatConnection:Disconnect()
			local folder2 = clone2

			for _, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			local clone3 = magmaGunZ.AirExplosion:Clone()
			clone3.CFrame = clone2.CFrame
			clone3.Parent = folder
			ParticleState(clone3)
			Util.Sound:Play("BF_WPN_RefMusket_ScorchingBurstExplosion_01", clone3.Position)
			print("blew up here")
			task.wait(0.1)
			local v2 = {
				Position = data.RayData.Pos,
				Hit = data.RayData.Hit,
				Normal = data.RayData.Nor,
				PlayerHit = data.RayData.PlayerHit
			}

			if v2 and (v2.Hit or v2.PlayerHit) then
				local cframe = CFrame.lookAt(v2.Position, v2.Position + v2.Normal)
				local clone4

				if v2.Hit then
					clone4 = magmaGunZ.FloorMagma:Clone()
					clone4.CFrame = cframe
					clone4.Parent = folder
				else
					clone4 = nil
				end

				if not v2.Hit then
					v2.Normal = createVector(0, 1, 0)
					cframe = CFrame.lookAt(v2.Position, v2.Position + v2.Normal)
				end

				task.spawn(function()
					task.wait(0.2)
					local lastTime3 = os.clock()

					while os.clock() - lastTime3 <= 0.4 do
						local clone5 = magmaGunZ.Trail:Clone()
						local number = random:NextNumber(0, 360)
						local number2 = random:NextNumber(800, 1200)
						clone5.Trail.Lifetime = random:NextNumber(0.1, 0.2)
						local total = 0
						local number3 = random:NextNumber(100, 250)
						local number4 = random:NextNumber(5, 20)
						clone5.CFrame = cframe * CFrame.new(
							math.sin((math.rad(number))) * number4,
							math.cos((math.rad(number))) * number4,
							-total
						)
						clone5.Parent = folder
						local number5 = random:NextNumber(0.15, 0.3)
						local heartbeatConnection2 = nil
						local v7 = os.clock()
						heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt2)
							total += number3 * dt2
							number += number2 * dt2
							clone5.CFrame = cframe * CFrame.new(
								math.sin((math.rad(number))) * number4,
								math.cos((math.rad(number))) * number4,
								-total
							)

							if number5 <= os.clock() - v7 then
								heartbeatConnection2:Disconnect()
							end
						end)
						task.wait(random:NextNumber(0.02, 0.06))
					end
				end)

				if clone4 then
					task.delay(0.2, function()
						local folder3 = clone4

						for _, effect in pairs(folder3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
				end

				if (currentCamera.CFrame.Position - clone2.Position).Magnitude <= 110 then
					local clone5 = magmaGunZ.ColorCorrection:Clone()
					clone5.Parent = game:GetService("Lighting")
					TweenService:Create(clone5, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
						TintColor = Color3.new(1, 1, 1),
						Brightness = 0
					}):Play()
					task.delay(0.2, clone5.Destroy, clone5)
				end

				task.wait(0.2)

				if clone4 then
					local folder3 = clone4

					for _, effect in pairs(folder3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end

				for _ = 1, 7 do
					local clone5 = magmaGunZ.MiniMagma:Clone()
					clone5.CFrame = cframe * CFrame.Angles(
						math.rad((random2:NextNumber(-55, 55))),
						math.rad((random2:NextNumber(-55, 55))),
						0
					)
					clone5.Parent = folder
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = clone5.CFrame.LookVector * random2:NextNumber(200, 400)
					bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
					bodyVelocity.Parent = clone5
					TweenService:Create(bodyVelocity, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
						Velocity = createVector(0, -200, 0)
					}):Play()
					task.delay(0.5, bodyVelocity.Destroy, bodyVelocity)
					local raycastResult = nil
					local heartbeatConnection2 = nil
					local v4 = os.clock()
					heartbeatConnection2 = RunService.Heartbeat:Connect(function()
						raycastResult = workspace:Raycast(clone5.Position, clone5.Velocity.Unit * 5, raycastParams)

						if raycastResult or os.clock() - v4 >= 2 then
							heartbeatConnection2:Disconnect()
							local folder3 = clone5

							for i, effect in pairs(folder3:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end

							if raycastResult then
								local clone6 = magmaGunZ.FloorMiniMagma:Clone()
								clone6.CFrame = CFrame.lookAt(
									raycastResult.Position,
									raycastResult.Position + raycastResult.Normal
								)
								clone6.Parent = folder
								local clone7 = magmaGunZ.MiniExplosions:Clone()
								clone7.CFrame = clone6.CFrame
								clone7.Parent = folder
								ParticleState(clone7)
								Util.Sound:Play(
									"BF_WPN_RefMusket_Scorching_Explosions_0" .. tostring(math.random(1, 3)) .. "_V2",
									clone7.Position
								)
								local clone8 = magmaGunZ.MiniFloorMagma:Clone()
								clone8.CFrame = clone6.CFrame
								clone8.Parent = folder
								task.delay(0.2, function()
									local folder4 = clone8

									for i, effect in pairs(folder4:GetDescendants()) do
										if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
											effect.Enabled = false
										end
									end

									local clone9 = magmaGunZ.SmallVolcanoe:Clone()
									clone9.CFrame = clone8.CFrame
									clone9.Parent = folder
									ParticleState(clone9)
									Util.Sound:Play(
										"BF_WPN_RefMusket_Scorching_Explosions_0" .. tostring(math.random(1, 3)) .. "_V2",
										clone8.Position,
										nil,
										math.random(12, 15) / 10
									)
								end)
								task.delay(1, function()
									local folder4 = clone6

									for i, effect in pairs(folder4:GetDescendants()) do
										if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
											effect.Enabled = false
										end
									end
								end)
							end
						end
					end)
				end

				task.wait(0.1)
				local clone5 = magmaGunZ.Volcanoe:Clone()
				clone5.CFrame = cframe
				clone5.Parent = folder
				ParticleState(clone5)
			else
				for _ = 1, 7 do
					local clone4 = magmaGunZ.MiniMagma:Clone()
					clone4.CFrame = clone2.CFrame * CFrame.Angles(
						math.rad((random2:NextNumber(0, 360))),
						math.rad((random2:NextNumber(0, -360))),
						(math.rad((random2:NextNumber(0, 360))))
					)
					clone4.Parent = folder
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = clone4.CFrame.LookVector * random2:NextNumber(20, 60)
					bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
					bodyVelocity.Parent = clone4
					task.delay(0.1, bodyVelocity.Destroy, bodyVelocity)
					local raycastResult = nil
					local heartbeatConnection2 = nil
					local v4 = os.clock()
					heartbeatConnection2 = RunService.Heartbeat:Connect(function()
						raycastResult = workspace:Raycast(clone4.Position, clone4.Velocity.Unit * 5, raycastParams)

						if raycastResult or os.clock() - v4 >= 2 then
							heartbeatConnection2:Disconnect()
							local folder3 = clone4

							for i, effect in pairs(folder3:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end

							if raycastResult then
								local clone5 = magmaGunZ.FloorMiniMagma:Clone()
								clone5.CFrame = CFrame.lookAt(
									raycastResult.Position,
									raycastResult.Position + raycastResult.Normal
								)
								clone5.Parent = folder
								local clone6 = magmaGunZ.MiniExplosions:Clone()
								clone6.CFrame = clone5.CFrame
								clone6.Parent = folder
								ParticleState(clone6)
								task.delay(1, function()
									local folder4 = clone5

									for i, effect in pairs(folder4:GetDescendants()) do
										if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
											effect.Enabled = false
										end
									end
								end)
							end
						end
					end)
				end
			end

			task.wait(4)
			folder:Destroy()
		end
	end)
end