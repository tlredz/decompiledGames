local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local bazooka_Z = FX:WaitForChild("Bazooka").Bazooka_Z
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local _ = Util.Rock2

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
	local origin = data.origin
	local dir = data.dir

	if (currentCamera.CFrame.p - origin).Magnitude > 1000 then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Map }

	if data.stage == 1 then
		local beamRange = data.beamRange
		local beamTime = data.beamTime
		local _ = data.hrp
		local folder = Instance.new("Folder")
		folder.Name = "BazookaEffects"
		folder.Parent = _WorldOrigin
		local cFrame = CFrame.new(origin, origin + dir) * CFrame.new(0, 0, -5)
		local clone = bazooka_Z.Start:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if data.player == game.Players.LocalPlayer then
			local clone2 = FX:WaitForChild("Musket").Musket_Z.ColorCorrection:Clone()
			clone2.TintColor = clone2.TintColor:Lerp(Color3.new(1, 1, 1), 0.95)
			clone2.Brightness = 0.03
			clone2.Parent = game:GetService("Lighting")
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				TintColor = Color3.new(1, 1, 1),
				Brightness = 0
			}):Play()
			task.delay(0.5, clone2.Destroy, clone2)
		end

		sound:Play("BF_WPN_Bazooka_HeatWave_Fire_01_V2", cFrame.Position)
		TweenService:Create(clone.PointLight, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
			Brightness = 0,
			Range = 0
		}):Play()
		local clone2 = bazooka_Z.BeamPart1:Clone()
		local clone3 = bazooka_Z.BeamPart2:Clone()
		clone2.CFrame = cFrame
		clone3.CFrame = cFrame

		for _, beam in clone2:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			local v2 = string.sub(beam.Parent.Name, 1, 1)
			beam.Attachment0 = beam.Parent
			beam.Attachment1 = clone3[v2 .. 2]
		end

		clone2.Parent = folder
		clone3.Parent = folder
		task.spawn(function()
			local v2 = beamTime + tick()
			local lastTime = tick()
			local position = nil

			while tick() < v2 do
				local v3 = (tick() - lastTime) / beamTime
				local raycastResult = workspace:Raycast(
					cFrame * Vector3.new(0, 0, -beamRange * v3),
					createVector(0, -15, 0),
					raycastParams
				)

				if raycastResult then
					if position then
						if (raycastResult.Position - position).Magnitude >= 18 and (raycastResult.Position - position).Magnitude <= 25 then
							local magnitude = (raycastResult.Position - position).Magnitude
							local clone4 = bazooka_Z.FloorFire:Clone()
							clone4.CFrame = CFrame.lookAt(
								(raycastResult.Position + position) / 2,
								raycastResult.Position + raycastResult.Normal
							) * CFrame.Angles(1.5707963267948966, 0, 0)
							clone4.Size = Vector3.new(magnitude, 30, 0.001)
							clone4.Parent = folder
							task.delay(0.8, function()
								local folder2 = clone4

								for i, emitter in pairs(folder2:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							position = raycastResult.Position
						elseif (raycastResult.Position - position).Magnitude >= 25 then
							position = raycastResult.Position
						end
					else
						position = raycastResult.Position
					end
				end

				task.wait()
			end
		end)
		TweenService:Create(clone3, TweenInfo.new(beamTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = cFrame * CFrame.new(0, 0, -beamRange)
		}):Play()
		local total = 3
		local total2 = 0.005
		coroutine.wrap(function()
			for i = 1, 11 do
				if data.player == game.Players.LocalPlayer then
					Util.CameraShaker:ShakeOnce(2, 4, 0.1, 0.5)
				end

				local raycastResult = workspace:Raycast(
					clone3.CFrame * CFrame.new(-14 - i, 0, 0).Position,
					createVector(0, -15, 0),
					raycastParams
				)
				local raycastResult2 = workspace:Raycast(
					clone3.CFrame * CFrame.new(i + 14, 0, 0).Position,
					createVector(0, -15, 0),
					raycastParams
				)

				if raycastResult then
					local instance = raycastResult.Instance
					local position = raycastResult.Position
					local part = Instance.new("Part")
					part.CFrame = CFrame.new(position) * CFrame.Angles(
						math.random(-5, 5),
						math.random(-5, 5),
						math.random(-5, 5)
					)
					part.Material = instance.Material
					part.Color = instance.Color
					part.Size = Vector3.new()
					part.CanCollide = false
					part.Anchored = true
					part.Parent = folder
					TweenService:Create(part, TweenInfo.new(0.3), {
						Size = createVector(2.162, 4.62, 11.558)
					}):Play()
					coroutine.wrap(function()
						wait(2)
						local tween = TweenService:Create(part, TweenInfo.new(0.3), {
							Size = Vector3.new()
						})
						tween:Play()
						tween:Destroy()
						Util.Debris:AddItem(part, 0.35)
					end)()
				end

				if raycastResult2 then
					local instance = raycastResult2.Instance
					local position = raycastResult2.Position
					local part = Instance.new("Part")
					part.CFrame = CFrame.new(position) * CFrame.Angles(
						math.random(-5, 5),
						math.random(-5, 5),
						math.random(-5, 5)
					)
					part.Material = instance.Material
					part.Color = instance.Color
					part.Size = Vector3.new()
					part.CanCollide = false
					part.Anchored = true
					part.Parent = folder
					TweenService:Create(part, TweenInfo.new(0.3), {
						Size = createVector(2.162, 4.62, 11.558)
					}):Play()
					coroutine.wrap(function()
						wait(2)
						TweenService:Create(part, TweenInfo.new(0.3), {
							Size = Vector3.new()
						}):Play()
						wait(0.35)
						part:Destroy()
					end)()
				end

				total += 2.5
				task.wait(total2)
				total2 += 0.004
			end
		end)()
		local clone4 = bazooka_Z.BeamParticles:Clone()
		clone4.CFrame = cFrame
		clone4.Parent = folder
		TweenService:Create(clone4, TweenInfo.new(beamTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = cFrame * CFrame.new(0, 0, -beamRange / 2),
			Size = clone4.Size + Vector3.new(0, 0, beamRange)
		}):Play()
		task.wait(0.2)

		for _, beam in clone2:GetDescendants() do
			if beam:IsA("Beam") then
				TweenService:Create(beam, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
					CurveSize0 = 0,
					CurveSize1 = 0,
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		task.wait(0.1)

		for _, emitter in pairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(5)
		folder:Destroy()
	else
		local folder = Instance.new("Folder")
		folder.Name = "BazookaExplosion"
		folder.Parent = _WorldOrigin
		local clone = bazooka_Z.Explode:Clone()
		clone.CFrame = CFrame.lookAt(data.position, data.position + data.nor)
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if (workspace.CurrentCamera.CFrame.p - clone.CFrame.Position).Magnitude < 100 then
			local clone2 = FX:WaitForChild("Musket").Musket_Z.ColorCorrection:Clone()
			clone2.Parent = game:GetService("Lighting")
			TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				TintColor = Color3.new(1, 1, 1),
				Brightness = 0
			}):Play()
			Util.CameraShaker:ShakeOnce(18, 12, 0.1, 0.3)
			task.delay(0.3, clone2.Destroy, clone2)
		end

		sound:Play("BF_WPN_Bazooka_Explosion_02", clone.Position)
		local clone2 = bazooka_Z.FloorFire:Clone()
		clone2.CFrame = clone.CFrame
		clone2.Parent = folder
		task.wait(data.floordur)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()
		task.wait(5)
		folder:Destroy()
	end
end