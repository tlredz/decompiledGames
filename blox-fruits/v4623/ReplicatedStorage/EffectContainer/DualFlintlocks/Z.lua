local Players = game:GetService("Players")
Players = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage.Util)
local FX = require(ReplicatedStorage.FX)
local dualFlintlocks_Z = FX:WaitForChild("DualFlintlocks").DualFlintlocks_Z

local function ParticleState(folder, enabled, p, p2)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			if emitter:GetAttribute("FloorHit") == true and p2 then
				emitter:Emit((emitter:GetAttribute("EmitCount") or 0) * 0.8)
			elseif emitter:GetAttribute("FloorHit") ~= true then
				emitter:Emit((emitter:GetAttribute("EmitCount") or 0) * 0.8)
			end
		else
			emitter.Enabled = enabled
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
local random = Random.new()
local Util = require(game.ReplicatedStorage.Util)

for _, child in pairs(dualFlintlocks_Z:GetChildren()) do
	if child:IsA("Model") then
		child:ScaleTo(0.5)
	elseif child:IsA("BasePart") then
		Util.ResizeModel(child, 0.5, child.Position)
	end
end

return function(data)
	local root = data.root
	local holding = data.holding
	local cframe = data.cframe

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "EffectsFolder"
	folder.Parent = workspace._WorldOrigin

	if data.stage == 1 then
		local clone = dualFlintlocks_Z.StartPart:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, 1, -8)
		clone.Parent = folder
		local v = Util.Sound:Play("BF_WPN_RefFlintlock_SplitBeamHold_01", clone)

		repeat
			clone.CFrame = root.CFrame * CFrame.new(0, 1, -8)
			task.wait()
		until not holding or holding.Value == false or not holding:IsDescendantOf(workspace)

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(2)
		folder:Destroy()
	elseif data.stage == 2 then
		local clone = dualFlintlocks_Z.WindUp:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, 1, -8)
		clone.Parent = folder
		ParticleState(clone)
		task.wait(0.2)
		local humanoidRootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

		if data.root == humanoidRootPart then
			local clone2 = FX:WaitForChild("Musket").Musket_Z.ColorCorrection:Clone()
			clone2.TintColor = Color3.fromRGB(125, 155, 255):Lerp(Color3.new(1, 1, 1), 0.95)
			clone2.Brightness = 0.03
			clone2.Parent = game:GetService("Lighting")
			TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				TintColor = Color3.new(1, 1, 1),
				Brightness = 0
			}):Play()
			task.delay(0.3, clone2.Destroy, clone2)
		end

		Util.Sound:Play("BF_WPN_RefFlintlock_Fire_01", cframe.Position)

		for i = -1, 1, 2 do
			local cFrame = cframe * CFrame.new(0, 2, -6)
			local clone2 = dualFlintlocks_Z.ShotModel:Clone()
			local shot = clone2.Shot
			shot.CFrame = cFrame
			clone2.Parent = folder
			local clone3 = dualFlintlocks_Z.Start:Clone()
			local clone4 = dualFlintlocks_Z.EndModel:Clone()
			local v2 = clone4.End

			for _, beam in clone3:GetChildren() do
				if beam:IsA("Beam") then
					beam.Attachment1 = v2.Attachment
				end
			end

			clone3.CFrame = cFrame
			v2.CFrame = cFrame
			clone3.Parent = folder
			clone4.Parent = folder
			local clone5 = dualFlintlocks_Z.BeamParticlesModel:Clone()
			local beamParticles = clone5.BeamParticles
			beamParticles.CFrame = cFrame
			clone5.Parent = folder
			local clone6 = dualFlintlocks_Z.FloorTrail:Clone()
			local v3 = false
			local raycastResult = nil
			local total = 0
			local v4 = 100
			local v5 = false

			for _, beam in clone3:GetDescendants() do
				if beam:IsA("Beam") then
					TweenService:Create(beam, TweenInfo.new(0.5833333333333334, Enum.EasingStyle.Linear), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end

			local v6 = nil
			local lastTime = os.clock()
			local lastTime2 = os.clock()
			local heartbeatConnection = nil
			local v8 = os.clock()
			local v13 = i
			local v18 = i
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if v3 == false then
					raycastResult = workspace:Raycast(v2.Position, v2.CFrame.LookVector * dt * 1000, raycastParams)
					v2.CFrame *= CFrame.new(0, 0, -dt * 1000)
					v6 = 1000 * (os.clock() - v8)
					beamParticles.CFrame = cFrame * CFrame.new(0, 0, -v6 / 2)
					beamParticles.Size = Vector3.new(beamParticles.Size.X, beamParticles.Size.Y, v6)
					beamParticles.Start.Position = Vector3.new(0, 0, v6 / 2)
					beamParticles.End.Position = Vector3.new(0, 0, -v6 / 2)
				else
					total += 270 * dt
					v4 -= 220 * dt

					if total >= 90 then
						local folder2 = v2

						for i2, emitter in pairs(folder2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						local folder3 = shot

						for i2, emitter in pairs(folder3:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						local folder4 = beamParticles

						for i2, emitter in pairs(folder4:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						ParticleState(beamParticles)
						local folder5 = clone6

						for i2, emitter in pairs(folder5:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						heartbeatConnection:Disconnect()
					end

					local cFrame2 = cframe * CFrame.Angles(0, math.rad(total * v13), 0) * CFrame.new(0, 0, -14)
					clone2:ScaleTo((math.max(0.1, clone2:GetScale() - dt * 0.3333333333333333 * 6)))
					clone3.CFrame = cFrame2
					shot.CFrame = cFrame2
					raycastResult = workspace:Raycast(cFrame2.Position, cFrame2.LookVector * v4, raycastParams)

					if raycastResult and heartbeatConnection.Connected == true then
						v2.CFrame = cFrame2 * CFrame.new(0, 0, -(raycastResult.Position - cFrame.Position).Magnitude)

						if v5 == false then
							local folder2 = clone6

							for i2, emitter in pairs(folder2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							v5 = true
							clone6.Trail.Enabled = true
						end

						if clone6.Parent ~= folder then
							clone6.Parent = folder
						end

						clone6.CFrame = CFrame.lookAt(
							raycastResult.Position,
							raycastResult.Position + raycastResult.Normal
						)
					else
						clone4:ScaleTo((math.max(0.1, clone4:GetScale() - dt * 0.3333333333333333 * 4)))
						v2.CFrame = cFrame2 * CFrame.new(0, 0, -v4)

						if v5 == true then
							local folder2 = clone6

							for i2, emitter in pairs(folder2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							v5 = false
							clone6.Trail.Enabled = false
						end
					end

					v6 = v4
					clone5:ScaleTo((math.max(0.1, clone5:GetScale() - dt * 0.3333333333333333 * 4)))
					beamParticles.Start.Position = Vector3.new(0, 0, v6 / 2)
					beamParticles.End.Position = Vector3.new(0, 0, -v6 / 2)
					beamParticles.CFrame = cFrame2 * CFrame.new(0, 0, -v6 / 2)
					beamParticles.Size = Vector3.new(beamParticles.Size.X, beamParticles.Size.Y, v6)
				end

				if (raycastResult or v6 >= 100) and v3 == false then
					v3 = true
					local clone7 = dualFlintlocks_Z.Explosion:Clone()
					clone7.CFrame = raycastResult and CFrame.lookAt(
						raycastResult.Position,
						raycastResult.Position + raycastResult.Normal
					) or v2.CFrame
					clone7.Parent = folder
					ParticleState(clone7, nil, nil, raycastResult)
					ParticleState(beamParticles)

					if v13 == 1 and (workspace.CurrentCamera.CFrame.Position - clone7.Position).Magnitude <= 120 then
						local clone8 = FX:WaitForChild("Musket").Musket_Z.ColorCorrection:Clone()
						clone8.TintColor = Color3.fromRGB(125, 155, 255)
						clone8.Parent = game:GetService("Lighting")
						TweenService:Create(clone8, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
							TintColor = Color3.new(1, 1, 1),
							Brightness = 0
						}):Play()
						Util.CameraShaker:ShakeOnce(14, 14, 0.1, 0.3)
						task.delay(0.3, clone8.Destroy, clone8)
					end
				end

				if os.clock() - lastTime2 >= random:NextNumber(0.02, 0.04) then
					lastTime2 = os.clock()
					local clone7 = dualFlintlocks_Z.Beams:Clone()
					local number = random:NextNumber(0, v4)
					clone7.CFrame = clone3.CFrame * CFrame.new(0, 0, -number) * CFrame.Angles(
						0,
						0,
						random:NextNumber(0, 6.283185307179586)
					)
					clone7.Parent = folder
					local width = random:NextNumber(7, 14) * v4 / 100
					clone7.MainSlash.Width0 = width
					clone7.MainSlash.Width1 = width
					local v21 = random:NextNumber(12, 15) * v4 / 100
					clone7.MainSlash.CurveSize0 = v21 * 1.3636363636363635
					clone7.MainSlash.CurveSize1 = -v21 * 1.3636363636363635
					clone7.A.Position = Vector3.new(-v21, 0, 0)
					clone7.B.Position = Vector3.new(v21, 0, 0)
					TweenService:Create(clone7, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
						Orientation = clone7.Orientation + Vector3.new(0, 0, random:NextNumber(360, 720))
					}):play()
					TweenService:Create(clone7.MainSlash, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
						Width0 = 0,
						Width1 = 0
					}):Play()
					local number2 = random:NextNumber(0, 100)
					local lastTime3 = os.clock()
					local heartbeatConnection2 = nil
					heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt2)
						number += number2 * dt2
						clone7.Position = (clone3.CFrame * CFrame.new(0, 0, -number)).Position

						if os.clock() - lastTime3 >= 0.3 then
							heartbeatConnection2:Disconnect()
						end
					end)
				end

				if os.clock() - lastTime >= random:NextNumber(0.02, 0.04) then
					lastTime = os.clock()
					local clone7 = dualFlintlocks_Z.Trail:Clone()
					local v19 = clone3.CFrame * CFrame.new(0, 0, random:NextNumber(0, -v6)) * CFrame.Angles(
						random:NextNumber(0, 6.283185307179586),
						random:NextNumber(0, 6.283185307179586),
						random:NextNumber(0, 6.283185307179586)
					)
					clone7.Parent = folder
					local number = random:NextNumber(0, 360)
					local number2 = random:NextNumber(360, 720)
					local number3 = random:NextNumber(5, 10)
					local number4 = random:NextNumber(5, 10)
					local total2 = 0
					local number5 = random:NextNumber(30, 150)
					clone7.CFrame = v19 * CFrame.new(
						math.cos((math.rad(number))) * number3,
						math.sin((math.rad(number))) * number4,
						-total2
					)
					clone7.Parent = folder
					local number6 = random:NextNumber(0.5, 1.3)
					local lastTime3 = os.clock()
					local heartbeatConnection2 = nil
					heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt2)
						number += number2 * dt2
						total2 += number5 * dt2
						clone7.CFrame = v19 * CFrame.new(
							math.cos((math.rad(number))) * number3,
							math.sin((math.rad(number))) * number4,
							-total2
						)

						if number6 <= os.clock() - lastTime3 then
							heartbeatConnection2:Disconnect()
							local folder2 = clone7

							for i2, emitter in pairs(folder2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end
					end)
				end
			end)
		end

		task.wait(3)
		folder:Destroy()
	end
end