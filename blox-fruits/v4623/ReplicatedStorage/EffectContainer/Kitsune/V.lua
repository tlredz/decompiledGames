local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local FX = require(ReplicatedStorage.FX)
local kitsuneSkillV = FX:WaitForChild("Kitsune").KitsuneSkillV
local _WorldOrigin = workspace._WorldOrigin
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")

local function scaleParticle(emitter, p)
	local keypoints = emitter.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	emitter.Size = NumberSequence.new(numberSequenceKeypoints)
	emitter.Speed = NumberRange.new(emitter.Speed.Min * p, emitter.Speed.Max * p)
	emitter.Acceleration *= p
end

for _, emitter in pairs(kitsuneSkillV:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		scaleParticle(emitter, 2)
	end
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function NearGround(cframe, folder, _, raycastParams, p)
	for _ = 1, 9 do
		local clone = kitsuneSkillV.Rock:Clone()
		clone.Position = cframe.Position + Vector3.new(math.random(-50, 50), 0, math.random(-50, 50))
		local raycastResult = workspace:Raycast(
			clone.Position + createVector(0, 1, 0),
			CFrame.new(clone.Position).UpVector * -5,
			raycastParams
		)

		if not raycastResult then
			continue
		end

		clone.Position = raycastResult.Position
		clone.Size = Vector3.new(math.random(20, 30) / 10, math.random(20, 30) / 10, math.random(20, 30) / 10) * 1.75
		local color = clone.Color
		Util.SetParentOverrideWithColor(clone, folder, p, "KitsuneFruitVFXColor")
		clone.Color = color
		rocks:ApplyCollision(clone, nil, true)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
		bodyVelocity.P = 2600
		Util.SetParentOverrideWithColor(bodyVelocity, clone, p, "KitsuneFruitVFXColor")
		bodyVelocity.Velocity = CFrame.new(clone.Position, clone.Position + createVector(0, 250, 0)).LookVector * math.random(
			15,
			35
		)
		clone.Attachment0.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
		local clone2 = kitsuneSkillV.RockBeam:Clone()
		clone2.Position = raycastResult.Position
		clone2.RockBeam2.Position = raycastResult.Position
		Util.SetParentOverrideWithColor(clone2, folder, p, "KitsuneFruitVFXColor")
		local curveSize = math.random(-10, 10) * 1.25
		local curveSize2 = math.random(-10, 10) * 1.25
		local folder2 = clone2
		coroutine.wrap(function()
			local lastTime = os.clock()
			local beamsByBeam = {}

			for i, beam in pairs(folder2:GetDescendants()) do
				if beam:IsA("Beam") then
					beamsByBeam[beam] = beam
				end
			end

			while true do
				curveSize = math.random(-10, 10) * 0.75
				curveSize2 = math.random(-10, 10) * 0.75

				for k, beam in pairs(beamsByBeam) do
					if beam:IsA("Beam") then
						TweenService:Create(
							beam,
							TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CurveSize0 = curveSize,
								CurveSize1 = curveSize2
							}
						):Play()
					end
				end

				task.wait(0.15)

				if not (os.clock() - lastTime >= 0.75) then
					continue
				end

				for i, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					elseif effect:IsA("Beam") then
						TweenService:Create(
							effect,
							TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 0,
								Width1 = 0
							}
						):Play()
					end
				end

				break
			end
		end)()
		local clone3 = bodyVelocity:Clone()
		Util.SetParentOverrideWithColor(clone3, clone2.RockBeam2, p, "KitsuneFruitVFXColor")
		local v3 = clone
		coroutine.wrap(function()
			local v5 = math.random(60, 120)
			local v6 = math.random(60, 120)
			local v7 = math.random(60, 120)
			local v8 = v5 / 10
			local v9 = v6 / 10
			local v10 = v7 / 10

			for i = 1, 6 do
				v5 = math.clamp(v5 - v8, 0, 120)
				v6 = math.clamp(v6 - v9, 0, 120)
				v7 = math.clamp(v7 - v10, 0, 120)
				local tween = TweenService:Create(
					v3.Attachment0,
					TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = v3.Attachment0.CFrame * CFrame.Angles(math.rad(v5), math.rad(v6), (math.rad(v7)))
					}
				)
				tween:Play()
				tween.Completed:Wait()
				tween:Destroy()
			end

			v3.AlignOrientation:Destroy()
			bodyVelocity:Destroy()
			v3.CanCollide = true
			task.wait(1.5)
			local rockBurn = v3.RockBurn

			for i, emitter in pairs(rockBurn:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			Util.Sound:Play("V Attacks- Rock flames ", v3)
			task.wait(0.25)
			TweenService:Create(v3, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 0)
			}):Play()
			task.wait(0.35)
			v3.Transparency = 1

			for i, emitter in pairs(rockBurn:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			Util.Debris:AddItem(v3, 2)
		end)()
		task.wait(0.015)
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
return function(data)
	local player = data.Player
	local root = data.Root
	local v = player or game.Players:GetPlayerFromCharacter(root.Parent)
	local toggle = data.Toggle
	local sphereScaleMod = data.SphereScaleMod or 1

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 and not data.Scene or toggle == false then
		return
	end

	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, v, "KitsuneFruitVFXColor")
	Util.Debris:AddItem(folder, 7)
	local cframe = CFrame.new(root.CFrame.Position)
	Util.Sound:Play("V Attacks- Explosion", cframe)
	coroutine.wrap(function()
		task.wait(0.15)
		local raycastResult = workspace:Raycast(
			cframe.Position + createVector(0, 1, 0),
			CFrame.new(cframe.Position).UpVector * -10,
			raycastParams
		)

		if raycastResult then
			NearGround(cframe, folder, raycastResult.Position, raycastParams, v)
		end
	end)()
	coroutine.wrap(function()
		for _ = 1, 20 do
			local v2 = math.random(10, 50) / 100
			local v3 = 2 * math.random(100, 250) / 100
			local v4 = math.random(30, 40) / 10
			local v5 = math.random(1, #kitsuneSkillV.Trails:GetChildren())
			local clone = kitsuneSkillV.Trails["Trail" .. v5]:Clone()
			clone.CFrame = cframe * CFrame.new(0, math.random(0, 10), 0) * CFrame.new(0, math.random(10, 200) / 50, 0) * CFrame.Angles(
				0,
				math.rad((math.random(-180, 180))),
				0
			)
			Util.SetParentOverrideWithColor(clone, folder, v, "KitsuneFruitVFXColor")

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					local tween = TweenService:Create(
						descendant,
						TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							CurveSize0 = descendant.CurveSize0 * v3,
							CurveSize1 = descendant.CurveSize1 * v3
						}
					)
					descendant.CurveSize0 /= v4
					descendant.CurveSize1 /= v4
					tween:Play()
				elseif descendant:IsA("Attachment") then
					local tween = TweenService:Create(
						descendant,
						TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(
								descendant.Position.X * v3,
								descendant.Position.Y * v3,
								descendant.Position.Z * v3
							)
						}
					)
					descendant.Position = Vector3.new(
						descendant.Position.X / v4,
						descendant.Position.Y / v4,
						descendant.Position.Z / v4
					)
					tween:Play()
				end
			end

			coroutine.wrap(function()
				local v6 = math.random(50, 80)

				for i = 1, 12 do
					if i == 11 then
						coroutine.wrap(function()
							for _, beam in pairs(clone:GetDescendants()) do
								if beam:IsA("Beam") then
									TweenService:Create(
										beam,
										TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
										{
											Width0 = 0,
											Width1 = 0
										}
									):Play()
								end
							end

							task.wait(0.3)
							clone:Destroy()
						end)()
						break
					end

					local tween = TweenService:Create(
						clone,
						TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone.CFrame * CFrame.Angles(0, math.rad(-v6), 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end
			end)()
			task.wait(0.00015)
		end
	end)()
	coroutine.wrap(function()
		local clone = kitsuneSkillV.Aura2Start:Clone()
		clone.CFrame = cframe * CFrame.new(0, 37.6875, 0)
		Util.SetParentOverrideWithColor(clone, folder, v, "KitsuneFruitVFXColor")

		if data.Tool and data.Tool:FindFirstChild("IsRedMutant") and data.Tool:FindFirstChild("IsRedMutant").Value == true then
			clone.Attachment.Particle_1.Color = ColorSequence.new(Color3.fromRGB(255, 57, 57))
		end

		if data.Tool and data.Tool:FindFirstChild("IsGalaxy") and data.Tool:FindFirstChild("IsGalaxy").Value == true then
			clone.Attachment.Particle_1.Color = ColorSequence.new(Color3.fromRGB(116, 16, 255))
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.1)
		local clone2 = kitsuneSkillV.Aura2:Clone()
		clone2.CFrame = clone.CFrame
		Util.SetParentOverrideWithColor(clone2, folder, v, "KitsuneFruitVFXColor")

		if data.Tool and data.Tool:FindFirstChild("IsRedMutant") and data.Tool:FindFirstChild("IsRedMutant").Value == true then
			clone2.Attachment.Particle_1.Color = ColorSequence.new(Color3.fromRGB(255, 57, 57))
		end

		if data.Tool and data.Tool:FindFirstChild("IsGalaxy") and data.Tool:FindFirstChild("IsGalaxy").Value == true then
			clone2.Attachment.Particle_1.Color = ColorSequence.new(Color3.fromRGB(116, 16, 255))
			clone2.Attachment.Particle_2.Color = ColorSequence.new(Color3.fromRGB(26, 167, 255))
			clone2.Attachment.Particle_3.Color = ColorSequence.new(Color3.fromRGB(16, 19, 204))
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter:Emit(1)
		end

		local currentCamera = workspace.CurrentCamera
		local cFrame = clone2.CFrame
		local lastTime = os.clock()

		while os.clock() - lastTime < 0.75 do
			clone2.CFrame = (cFrame - currentCamera.CFrame.LookVector * 14) * CFrame.new(
				0,
				(os.clock() - lastTime) * 2,
				0
			)
			local RunService2 = game:GetService("RunService")
			RunService2.RenderStepped:Wait()
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		clone2.Attachment.Particle_3:Destroy()
		task.delay(1, function()
			clone2:Destroy()
		end)
		local clone3 = kitsuneSkillV.Aura2Explosion:Clone()
		clone3.CFrame = clone2.CFrame * CFrame.new(0, 3, 0)
		Util.SetParentOverrideWithColor(clone3, folder, v, "KitsuneFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
			end
		end
	end)()
	coroutine.wrap(function()
		task.wait(0.15)
		local clone = kitsuneSkillV.Aura:Clone()
		clone.CFrame = cframe
		Util.SetParentOverrideWithColor(clone, folder, v, "KitsuneFruitVFXColor")

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("PointLight") then
				TweenService:Create(
					descendant,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 20, true),
					{
						Range = descendant.Range + 50
					}
				):Play()
			end
		end

		task.wait(0.5)

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false

				if descendant.Parent ~= clone.Focus2 then
					descendant:Destroy()
				end
			elseif descendant:IsA("PointLight") then
				TweenService:Create(descendant, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Brightness = 0
				}):Play()
			end
		end
	end)()
	coroutine.wrap(function()
		local clone = kitsuneSkillV.AuraStart:Clone()
		clone.CFrame = cframe
		Util.SetParentOverrideWithColor(clone, folder, v, "KitsuneFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Util.EmitFix(emitter, emitter:GetAttribute("EmitCount"))
			end
		end

		local clone2 = kitsuneSkillV.Sphere:Clone()
		clone2.Size *= sphereScaleMod
		clone2.CFrame = cframe
		Util.SetParentOverrideWithColor(clone2, folder, v, "KitsuneFruitVFXColor")
		task.delay(0.05, function()
			local highlight = clone2:FindFirstChildOfClass("Highlight", true)

			if highlight then
				Util.ColorShiftObjectDescendants(highlight, v, "KitsuneFruitVFXColor", true)
			end
		end)
		local tween = TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = clone2.Size
		})
		clone2.Size = createVector(0, 0, 0)
		tween:Play()
		coroutine.wrap(function()
			tween.Completed:Wait()
			tween = TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = clone2.Size * 2
			})
			tween:Play()
		end)()

		if player == localPlayer then
			coroutine.wrap(function()
				local currentCamera = workspace.CurrentCamera
				local tween2 = TweenService:Create(currentCamera, TweenInfo.new(0.75), {
					FieldOfView = 140
				})
				tween2:Play()
				tween2.Completed:Wait()
				TweenService:Create(currentCamera, TweenInfo.new(0.25), {
					FieldOfView = 70
				}):Play()
			end)()
		end

		task.wait(0.75)
		clone2:Destroy()
		local clone3 = kitsuneSkillV.Explosion:Clone()
		clone3.CFrame = cframe
		Util.SetParentOverrideWithColor(clone3, folder, v, "KitsuneFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			coroutine.wrap(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				Util.EmitFix(v2, v2:GetAttribute("EmitCount"))
			end)()
		end

		if player == localPlayer then
			coroutine.wrap(function()
				local clone4 = kitsuneSkillV.Bloom:Clone()
				Util.SetParentOverrideWithColor(clone4, game.Lighting, v, "KitsuneFruitVFXColor")
				local tween2 = TweenService:Create(clone4, TweenInfo.new(0.1), {
					Size = 70,
					Threshold = 0.25
				})
				tween2:Play()
				tween2.Completed:Wait()
				task.wait(0.15)
				local tween3 = TweenService:Create(clone4, TweenInfo.new(0.35), {
					Size = 24,
					Threshold = 2
				})
				tween3:Play()
				tween3.Completed:Wait()
				clone4:Destroy()
			end)()
			Util.CameraShaker:ShakeOnce(10, 7, 0.5, 0.25)
		end

		coroutine.wrap(function()
			for _ = 1, 3 do
				local v2 = math.random(10, 50) / 250
				local v3 = 2 * math.random(100, 250) / 100
				local v4 = math.random(30, 40) / 10
				local clone4 = kitsuneSkillV.SpinTornado:Clone()
				clone4.CFrame = cframe * CFrame.new(0, math.random(5, 15), 0) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				Util.SetParentOverrideWithColor(clone4, folder, v, "KitsuneFruitVFXColor")

				for _, descendant in pairs(clone4:GetDescendants()) do
					if descendant:IsA("Beam") then
						local tween2 = TweenService:Create(
							descendant,
							TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								CurveSize0 = descendant.CurveSize0 * v3,
								CurveSize1 = descendant.CurveSize1 * v3
							}
						)
						descendant.CurveSize0 /= v4
						descendant.CurveSize1 /= v4
						tween2:Play()
					elseif descendant:IsA("Attachment") then
						local tween2 = TweenService:Create(
							descendant,
							TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Position = Vector3.new(
									descendant.Position.X * v3,
									descendant.Position.Y * v3,
									descendant.Position.Z * v3
								)
							}
						)
						descendant.Position = Vector3.new(
							descendant.Position.X / v4,
							descendant.Position.Y / v4,
							descendant.Position.Z / v4
						)
						tween2:Play()
					end
				end

				coroutine.wrap(function()
					for i = 1, 10 do
						local tween2 = TweenService:Create(
							clone4,
							TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone4.CFrame * CFrame.new(0, math.clamp(20 - i * 4, 0, 20), 0) * CFrame.Angles(
									0,
									math.rad(-math.random(80, 120)),
									0
								)
							}
						)
						tween2:Play()
						tween2.Completed:Wait()
					end
				end)()
				local folder2 = clone4
				coroutine.wrap(function()
					task.wait(v2 * math.random(50, 70) / 100)

					for i, beam in pairs(folder2:GetDescendants()) do
						if beam:IsA("Beam") then
							TweenService:Create(
								beam,
								TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Width0 = 0,
									Width1 = 0
								}
							):Play()
						end
					end

					task.wait(0.3)
					folder2:Destroy()
				end)()
			end
		end)()
	end)()
	coroutine.wrap(function()
		local clone = kitsuneSkillV.PillarFlame:Clone()
		clone.CFrame = cframe * CFrame.new(0, clone.Size.Y / 2, 0) * CFrame.new(0, -10, 0)
		Util.SetParentOverrideWithColor(clone, folder, v, "KitsuneFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		TweenService:Create(clone.Attach_0A, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = createVector(0, -40, 0)
		}):Play()
		local tween = TweenService:Create(
			clone.Attach_1A,
			TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.1),
			{
				Position = createVector(0, 100, 0)
			}
		)
		clone.Attach_1A.Position = createVector(0, 0, 0)
		tween:Play()

		for _, beam in pairs(clone:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local tween2 = TweenService:Create(
				beam,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = beam.Width0 * 2.5,
					Width1 = beam.Width1 * 2.5
				}
			)
			beam.Width0 = 0
			beam.Width1 = 0
			tween2:Play()
		end

		task.wait(0.15)

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
				local v2 = effect
				coroutine.wrap(function()
					task.wait(0.5)
					v2.Enabled = false
				end)()
			elseif effect:IsA("Beam") then
				local v2 = effect
				coroutine.wrap(function()
					task.wait(0.3)
					TweenService:Create(
						v2,
						TweenInfo.new(
							0.25 + math.random(10, 100) / 100,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						),
						{
							Width0 = 0,
							Width1 = 0
						}
					):Play()
				end)()
			end
		end
	end)()

	for _ = 1, 10 do
		coroutine.wrap(function()
			task.wait(math.random(10, 100) / 200)
			local clone = kitsuneSkillV.AuraTrail:Clone()
			clone.Position = cframe.Position + Vector3.new(
				math.random(-100, 100) / 2,
				math.random(-5, 25),
				math.random(-100, 100) / 2
			)
			Util.SetParentOverrideWithColor(clone, folder, v, "KitsuneFruitVFXColor")
			local position = clone.Position
			local position2 = cframe.Position
			local magnitude = (position - position2).Magnitude
			clone.CFrame = CFrame.new(position, position2)
			local v2 = (position - position2) / 2
			local position3 = CFrame.new(CFrame.new(position) * (v2 / -1.5)).Position
			local position4 = CFrame.new(CFrame.new(position2) * (v2 / 1.5)).Position
			local v3 = magnitude * 1.15
			local v4 = position3 + Vector3.new(math.random(-v3, v3), math.random(1, 2), math.random(-v3, v3))
			local v5 = position4 + Vector3.new(math.random(-v3, v3), math.random(1, 2), math.random(-v3, v3))

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
					effect.Enabled = true
				end
			end

			local v6 = math.random(30, 60) / 10
			local lastTime = tick()
			local v7 = magnitude / v6 / 60

			while tick() - lastTime < v7 do
				local v8 = (tick() - lastTime) / v7
				local v9 = cubicBezier(v8, position, v4, v5, position2)
				local v10 = v8 + 0.001
				local v11 = cubicBezier(v10, position, v4, v5, position2)
				clone.CFrame = clone.CFrame:Lerp(CFrame.new(v9, position2), v8)
				clone.CFrame = CFrame.new(clone.Position, v11)
				RunService.Heartbeat:Wait()
			end

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end
		end)()
	end
end