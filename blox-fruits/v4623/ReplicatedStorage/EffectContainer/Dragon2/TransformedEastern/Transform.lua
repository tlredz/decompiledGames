local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("Dragon2").TransformedEastern.Transform
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 100) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
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
	destroyAfter(part, 14)
	return part
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local cFrame = hrp.CFrame
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	destroyAfter(part, 14)
	local _ = part.Parent
	local currentCamera = Workspace.CurrentCamera

	if (part.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 2000 then
		return
	end

	local transform = FX:WaitForChild("EasternDragon").Transform

	local function ScaleParticle(emitter, p)
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

	local function quadBezier(p, p2, p3, p4)
		return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
	end

	local function lerp(p, p2, p3)
		return p + (p2 - p) * p3
	end

	local function cubicBezier(p, position2, p2, p3, position3)
		local v2 = position2 + (p2 - position2) * p
		local v3 = p2 + (p3 - p2) * p
		local v4 = p3 + (position3 - p3) * p
		local v5 = v2 + (v3 - v2) * p
		return v5 + (v3 + (v4 - v3) * p - v5) * p
	end

	local function TrailSpin(part2, folder)
		local v2 = {}

		for _ = 1, 5 do
			local clone = transform.Phase1.SpinTrail:Clone()
			clone.CFrame = part2.CFrame
			Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)
			clone.Anchored = false
			clone.Weld.Part1 = part2

			for _, effect in ipairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			clone.SpinTrail2.WeldConstraint.Enabled = false
			clone.SpinTrail2.CFrame = clone.CFrame * CFrame.new(
				math.random(-40, -20),
				math.random(25, 50),
				math.random(10, 25)
			)
			clone.SpinTrail2.WeldConstraint.Enabled = true
			clone.Weld.C0 = clone.Weld.C0 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
			local v3 = math.random(1, 3)

			if v3 == 1 then
				clone.Trail.Color = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(248, 44, 17), player, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(255, 89, 23), player, "DragonFruitVFXColor")
				)
			elseif v3 == 2 then
				clone.Trail.Color = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(221, 106, 29), player, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(255, 191, 89), player, "DragonFruitVFXColor")
				)
			elseif v3 == 3 then
				clone.Trail.Color = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(156, 25, 15), player, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(214, 92, 21), player, "DragonFruitVFXColor")
				)
			end

			local v4 = math.random(7, 15)
			clone.SpinTrail2.Attach0.Position = Vector3.new(v4, 0, 0)
			clone.SpinTrail2.Attach1.Position = Vector3.new(-v4, 0, 0)
			clone.Trail.Lifetime = math.random(15, 30) / 100
			v2[clone] = math.random(12, 25)
		end

		local v3 = 0.7 + tick()
		local v4 = time()

		for _ = 1, 600 do
			for k, v5 in pairs(v2) do
				k.Weld.C0 = k.Weld.C0 * CFrame.new(0, 1, 0) * CFrame.Angles(0, math.rad(v5), 0)
			end

			task.wait(0.001)

			if v3 - tick() <= 0 or time() - v4 > 10 then
				break
			end
		end

		for folder2, _ in pairs(v2) do
			for _, effect in ipairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end
	end

	local function RandomTrails(p, p2)
		local trails = transform.Phase1.Trails
		task.spawn(function()
			local count = #trails:GetChildren()

			for _ = 1, 10 do
				task.spawn(function()
					local cFrame2 = p.CFrame * CFrame.new(
						math.random(-25, 25) * 3,
						math.random(0, 25) * 3,
						math.random(-25, 25) * 3
					)
					local position2 = p.CFrame.Position
					local v3 = math.random(50, 70) / 10
					local v4 = math.random(1, count)
					local clone = trails["Trail" .. tostring(v4)]:Clone()
					clone.CFrame = cFrame2
					Util.SetParentOverrideWithColor(clone, p2, player, "DragonFruitVFXColor")
					destroyAfter(clone, 7)
					local position3 = clone.Position
					local magnitude = (position3 - position2).Magnitude
					clone.CFrame = CFrame.new(position3, position2)
					local v5 = (position3 - position2) / 2
					local position4 = CFrame.new(CFrame.new(position3) * (v5 / -1.5)).Position
					local position5 = CFrame.new(CFrame.new(position2) * (v5 / 1.5)).Position
					local v6 = position4 + Vector3.new(
						math.random(-magnitude, magnitude),
						math.random(-magnitude / 2, magnitude),
						math.random(-magnitude, magnitude)
					)
					local v7 = position5 + Vector3.new(
						math.random(-magnitude, magnitude),
						math.random(-magnitude / 2, magnitude),
						math.random(-magnitude, magnitude)
					)
					local lastTime = tick()
					local v8 = magnitude / v3 / 60
					local v9 = time()

					for _ = 1, 600 do
						if not (tick() - lastTime < v8) or time() - v9 > 10 then
							break
						end

						local v10 = (tick() - lastTime) / v8
						local v11 = cubicBezier(v10, position3, v6, v7, position2)
						clone.CFrame = clone.CFrame:Lerp(CFrame.new(v11, position2), v10)
						task.wait()
					end

					TweenService:Create(clone, TweenInfo.new(0.1), {
						Position = position2
					}):Play()

					for _, emitter in ipairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
			end
		end)
	end

	local function SkyClouds(cframe, folder, p)
		task.spawn(function()
			local clone = transform.Phase2.Cloud:Clone()
			clone.CFrame = cframe * CFrame.new(0, data.flyUpBy - 25, 0)
			Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)
			local emittersByEmitter = {}

			for _, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter:IsDescendantOf(clone.UpperCloud) then
					emitter.Enabled = true
					emittersByEmitter[emitter] = emitter
				else
					emitter.Enabled = false
					emitter:Emit(10)
				end
			end

			local v2 = p - 0.15 + tick()
			local v3 = time()

			for _ = 1, 600 do
				for _, _ in pairs(emittersByEmitter) do

				end

				task.wait(0.05)

				if v2 - tick() <= 0 or time() - v3 > 10 then
					break
				end
			end

			for _, v4 in pairs(emittersByEmitter) do
				v4.Enabled = false
				local v5 = v4
				task.spawn(function()
					for i = 1, 50 do
						v5.Transparency = NumberSequence.new(i / 50, i / 50)
						task.wait()
					end
				end)
			end
		end)
		task.spawn(function()
			local clone = transform.Phase2.CloudRingBeam:Clone()
			clone.CFrame = cframe * CFrame.new(0, data.flyUpBy - 25, 0)
			Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.Enabled = true
					local v2 = descendant
					task.spawn(function()
						local tween = TweenService:Create(
							v2,
							TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								CurveSize0 = v2.CurveSize0,
								CurveSize1 = v2.CurveSize1,
								Width0 = v2.Width0,
								Width1 = v2.Width1
							}
						)
						v2.CurveSize0 *= 0.25
						v2.CurveSize1 *= 0.25
						v2.Width0 = v2.Width0 * 0.25 / 10
						v2.Width1 = v2.Width1 * 0.25 / 10
						tween:Play()
					end)
				elseif descendant:IsA("Attachment") then
					local tween = TweenService:Create(
						descendant,
						TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(descendant.Position.X, descendant.Position.Y, descendant.Position.Z)
						}
					)
					descendant.Position = Vector3.new(
						descendant.Position.X * 0.25,
						descendant.Position.Y * 0.25,
						descendant.Position.Z * 0.25
					)
					tween:Play()
				end
			end

			task.wait(p - 0.35)

			for _, folder2 in ipairs(clone:GetChildren()) do
				local v2 = math.random(10, 70) / 100
				local v3 = math.random(70, 190) / 100

				for _, beam in ipairs(folder2:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local v4 = v2
					local v5 = beam
					task.spawn(function()
						task.wait(v4)
						local numberValue = Instance.new("NumberValue")
						numberValue.Value = 0.025
						TweenService:Create(numberValue, TweenInfo.new(0.25), {
							Value = 0.0005
						}):Play()

						for i = 0, 100, 5 do
							v5.Transparency = NumberSequence.new(i / 100, i / 100)
							task.wait(numberValue.Value)
						end

						numberValue:Destroy()
						task.wait(1)
						v5.Enabled = false
					end)
					local v6 = beam
					local v7 = v3
					task.spawn(function()
						task.wait(0.15)
						TweenService:Create(v6, TweenInfo.new(v7), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				end
			end
		end)
		task.spawn(function()
			local screenColorDV = Lighting:FindFirstChild("ScreenColorDV") or transform.Phase2.ScreenColorDV:Clone()

			if (Workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude < 200 then
				Util.SetParentOverrideWithColor(screenColorDV, Lighting, player, "DragonFruitVFXColor")
			end

			destroyAfter(screenColorDV, 7)
			screenColorDV:SetAttribute("UsedTimes", screenColorDV:GetAttribute("UsedTimes") + 1)
			local usedTimes = screenColorDV:GetAttribute("UsedTimes")
			TweenService:Create(screenColorDV, TweenInfo.new(0.5), {
				Brightness = -0.01,
				Contrast = 0.1,
				Saturation = 0.1,
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(209, 209, 209),
					player,
					"DragonFruitVFXColor"
				)
			}):Play()
			task.wait(p)

			if screenColorDV:GetAttribute("UsedTimes") == usedTimes then
				local tween = TweenService:Create(screenColorDV, TweenInfo.new(1.5), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"DragonFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tween:Play()
				tween.Completed:Wait()

				if screenColorDV:GetAttribute("UsedTimes") == usedTimes then
					screenColorDV:Destroy()
				end
			end
		end)
	end

	local function SkyPortal(p, p2, p3)
		task.spawn(function()
			local clone = transform.Phase2.Portal:Clone()
			clone.CFrame = p * CFrame.new(0, data.flyUpBy - 5, 0)
			Util.SetParentOverrideWithColor(clone, p2, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)
			local emittersByEmitter = {}

			for _, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emittersByEmitter[emitter] = emitter
			end

			local v2 = p3 - 0.15 + tick()
			local v3 = time()

			for _ = 1, 600 do
				for _, v4 in pairs(emittersByEmitter) do
					v4:Emit(1)
				end

				task.wait(0.07)

				if v2 - tick() <= 0 or time() - v3 > 10 then
					break
				end
			end

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	end

	local function JumpUp(cFrame2, p, part2)
		task.spawn(function()
			local clone = transform.Phase2.AlignMover:Clone()
			clone.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone, p, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)
			clone.Anchored = false
			clone.Weld.Part0 = part2
			local flyUpBy = data.flyUpBy
			heartbeatLoopFor2(flyUpBy / clone.AlignPosition.MaxVelocity, function(_, _, p2)
				part.CFrame = cFrame2 + Vector3.new(0, flyUpBy, 0) * p2
			end, function()
				part.CFrame = cFrame2 + Vector3.new(0, flyUpBy, 0) * 1
			end)
			task.wait(1.5)
			clone:Destroy()
		end)
	end

	local function TornadoSlash(p, data2)
		local multiplier = data2.Multiplier
		local multiplier2 = data2.Multiplier2
		local mutliplier2Time = data2.Mutliplier2Time
		local beamOutTime = data2.BeamOutTime
		local slashAngle = data2.SlashAngle
		local slashAngle2 = data2.SlashAngle2
		local slashType = data2.SlashType
		local slashCFrame = data2.SlashCFrame
		local slashSpeed = data2.SlashSpeed
		local slashSpeed2 = data2.SlashSpeed2
		local spinIterations = data2.SpinIterations
		local clone = slashType:Clone()
		clone.CFrame = slashCFrame
		Util.SetParentOverrideWithColor(clone, p, player, "DragonFruitVFXColor")
		destroyAfter(clone, 7)
		Util.Sound:Play("BF_V3_Dragon_Full_WhiteGlove_Sweep_01", slashCFrame.Position)

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("Beam") then
				descendant.CurveSize0 *= multiplier
				descendant.CurveSize1 *= multiplier
				descendant.Width0 *= multiplier
				descendant.Width1 *= multiplier
			elseif descendant:IsA("Attachment") then
				descendant.Position = Vector3.new(
					descendant.Position.X * multiplier,
					descendant.Position.Y * multiplier,
					descendant.Position.Z * multiplier
				)
			end
		end

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("Beam") then
				descendant.Enabled = true
				local v2 = descendant
				task.spawn(function()
					local tween = TweenService:Create(
						v2,
						TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							CurveSize0 = v2.CurveSize0 * multiplier2,
							CurveSize1 = v2.CurveSize1 * multiplier2,
							Width0 = v2.Width0 * multiplier2,
							Width1 = v2.Width1 * multiplier2
						}
					)
					v2.Width0 = 0
					v2.Width1 = 0
					tween:Play()
				end)
			elseif descendant:IsA("Attachment") then
				TweenService:Create(
					descendant,
					TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Position = Vector3.new(
							descendant.Position.X * multiplier2,
							descendant.Position.Y * multiplier2,
							descendant.Position.Z * multiplier2
						)
					}
				):Play()
			end
		end

		for _ = 1, spinIterations do
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(slashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * slashAngle
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end

		for _, beam in ipairs(clone:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local v2 = beam
			task.spawn(function()
				local tween = TweenService:Create(
					v2,
					TweenInfo.new(beamOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v2:Destroy()
			end)
		end

		TweenService:Create(clone, TweenInfo.new(slashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * slashAngle2
		}):Play()
	end

	local function RingBeam(cframe, folder)
		task.spawn(function()
			local slashCFrame = cframe * CFrame.new(0, 5, 0)
			TornadoSlash(folder, {
				Multiplier = 2.5,
				Multiplier2 = 2.5,
				Mutliplier2Time = 0.2,
				BeamOutTime = 0.2,
				SlashAngle = CFrame.new(0, 10, 0) * CFrame.Angles(0, 2.6179938779914944, 0),
				SlashAngle2 = CFrame.new(0, 15, 0) * CFrame.Angles(0, 2.6179938779914944, 0),
				SlashType = transform.Phase1.BeamSlash,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.05,
				SlashSpeed2 = 0.5,
				SpinIterations = 2
			})
		end)
		task.spawn(function()
			local slashCFrame = cframe * CFrame.new(0, 10, 0)
			TornadoSlash(folder, {
				Multiplier = 1.75,
				Multiplier2 = 3,
				Mutliplier2Time = 0.15,
				BeamOutTime = 0.15,
				SlashAngle = CFrame.new(0, 15, 0) * CFrame.Angles(0, 2.6179938779914944, 0),
				SlashAngle2 = CFrame.new(0, 15, 0) * CFrame.Angles(0, 0.8726646259971648, 0),
				SlashType = transform.Phase1.BeamSlash,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.1,
				SlashSpeed2 = 0.35,
				SpinIterations = 3
			})
		end)
		task.wait(0.185)

		for i = 1, 3 do
			local v2 = nil
			local v3 = nil
			local v4 = nil
			local v5 = nil
			local v6 = nil
			local v7 = nil
			local v8 = nil
			local width = nil
			local width2 = nil
			local cFrame2 = nil
			local v12 = nil
			local clone = transform.Phase1.RingBeam:Clone()
			clone.CFrame = cframe
			Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)
			local color3Constructor = Util.WrapColor3Constructor(
				Color3.fromRGB(255, 62, 23),
				player,
				"DragonFruitVFXColor"
			)

			if i == 1 then
				cFrame2 = cframe * CFrame.new(0, data.flyUpBy - 25, 0)
				clone.CFrame = cframe * CFrame.new(0, 25, 0)
				v2 = 1
				v12 = 0
				width = 50
				v5 = 0.125
				v3 = 2.5
				width2 = 150
				v8 = 0.05
				v6 = 0.049999999999999996
				v4 = 1.1
				v7 = 0.5
			elseif i == 2 then
				color3Constructor = Util.WrapColor3Constructor(
					Color3.fromRGB(94, 38, 235),
					player,
					"DragonFruitVFXColor"
				)
				cFrame2 = cframe * CFrame.new(0, data.flyUpBy - 125, 0)
				clone.CFrame = cframe * CFrame.new(0, 25, 0)
				v2 = 1.3
				v12 = 0
				width = 50
				v5 = 0.16666666666666666
				v3 = 2.5
				width2 = 170
				v8 = 0.06666666666666667
				v6 = 0.049999999999999996
				v4 = 1.1
				v7 = 0.6666666666666666
			elseif i == 3 then
				color3Constructor = Util.WrapColor3Constructor(
					Color3.fromRGB(203, 20, 20),
					player,
					"DragonFruitVFXColor"
				)
				task.wait(0.05)
				cFrame2 = cframe * CFrame.new(0, 25, 0)
				clone.CFrame = cframe * CFrame.new(0, data.flyUpBy - 25, 0)
				v2 = 0.5
				v12 = 0
				width = 25
				v5 = 0.27999999999999997
				v3 = 5
				width2 = 100
				v8 = 0.05
				v6 = 0.075
				v4 = 1.5
				v7 = 0.5599999999999999
			end

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.Color = ColorSequence.new(color3Constructor, color3Constructor)
					descendant.CurveSize0 *= v2
					descendant.CurveSize1 *= v2
					descendant.Transparency = NumberSequence.new(v12, v12)
					descendant.Width0 = width
					descendant.Width1 = width
					local v13 = descendant
					task.spawn(function()
						TweenService:Create(v13, TweenInfo.new(v5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							CurveSize0 = v13.CurveSize0 * v3,
							CurveSize1 = v13.CurveSize1 * v3,
							Width0 = width2,
							Width1 = width2
						}):Play()
						task.wait(v8)
						TweenService:Create(v13, TweenInfo.new(v6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
							CurveSize0 = v13.CurveSize0 * v4,
							CurveSize1 = v13.CurveSize1 * v4,
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * v2,
						descendant.Position.Y * v2,
						descendant.Position.Z * v2
					)
					local v13 = descendant
					task.spawn(function()
						TweenService:Create(v13, TweenInfo.new(v5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Position = Vector3.new(v13.Position.X * v3, v13.Position.Y * v3, v13.Position.Z * v3)
						}):Play()
						task.wait(v8)
						TweenService:Create(v13, TweenInfo.new(v6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
							Position = Vector3.new(v13.Position.X * v4, v13.Position.Y * v4, v13.Position.Z * v4)
						}):Play()
					end)
				end
			end

			TweenService:Create(clone, TweenInfo.new(v7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				CFrame = cFrame2
			}):Play()
		end
	end

	local function AlignCFrame(data2, normal)
		local v2 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
		local p = data2.p
		local unit = data2.LookVector:Cross(v2).Unit
		local unit2 = (unit.Magnitude > 0.001 and unit or data2.RightVector).Unit
		local unit3 = unit2:Cross(v2).Unit
		return CFrame.fromMatrix(p, unit2, v2, unit3)
	end

	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DragonFruitVFXColor")
	destroyAfter(folder, 15)
	local part3 = part
	local cframe = CFrame.new(part3.Position, part3.Position + part3.CFrame.LookVector * createVector(1, 0, 1))
	sound:Play("BF_V3_Dragon_Full_WhiteGlove_Activate_01", part)
	local trails = transform.Phase1.Trails
	task.spawn(function()
		local count = #trails:GetChildren()

		for _ = 1, 10 do
			task.spawn(function()
				local cFrame2 = part3.CFrame * CFrame.new(
					math.random(-25, 25) * 3,
					math.random(0, 25) * 3,
					math.random(-25, 25) * 3
				)
				local position2 = part3.CFrame.Position
				local v4 = math.random(50, 70) / 10
				local v5 = math.random(1, count)
				local clone = trails["Trail" .. tostring(v5)]:Clone()
				clone.CFrame = cFrame2
				Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
				destroyAfter(clone, 7)
				local position3 = clone.Position
				local magnitude = (position3 - position2).Magnitude
				clone.CFrame = CFrame.new(position3, position2)
				local v6 = (position3 - position2) / 2
				local position4 = CFrame.new(CFrame.new(position3) * (v6 / -1.5)).Position
				local position5 = CFrame.new(CFrame.new(position2) * (v6 / 1.5)).Position
				local v7 = position4 + Vector3.new(
					math.random(-magnitude, magnitude),
					math.random(-magnitude / 2, magnitude),
					math.random(-magnitude, magnitude)
				)
				local v8 = position5 + Vector3.new(
					math.random(-magnitude, magnitude),
					math.random(-magnitude / 2, magnitude),
					math.random(-magnitude, magnitude)
				)
				local lastTime = tick()
				local v9 = magnitude / v4 / 60
				local v10 = time()

				for _ = 1, 600 do
					if not (tick() - lastTime < v9) or time() - v10 > 10 then
						break
					end

					local v11 = (tick() - lastTime) / v9
					local v12 = cubicBezier(v11, position3, v7, v8, position2)
					clone.CFrame = clone.CFrame:Lerp(CFrame.new(v12, position2), v11)
					task.wait()
				end

				TweenService:Create(clone, TweenInfo.new(0.1), {
					Position = position2
				}):Play()

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end
	end)
	task.spawn(function()
		local clone = transform.Phase1.StartAura:Clone()
		clone.CFrame = cframe
		Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
		destroyAfter(clone, 7)
		local emittersByEmitter = {}

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emittersByEmitter[emitter] = emitter
		end

		local v3 = 0.2 + tick()
		local v4 = time()

		for _ = 1, 600 do
			for _, v5 in pairs(emittersByEmitter) do
				v5:Emit(1)
			end

			task.wait(0.1)

			if v3 - tick() <= 0 or time() - v4 > 10 then
				break
			end
		end

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	task.spawn(function()
		task.wait(0.15)
		local raycastResult = Workspace:Raycast(
			cframe.Position + createVector(0, 1, 0),
			createVector(-0, -50, -0),
			raycastParams
		)

		if raycastResult then
			local v3 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.001
			local cframe2 = CFrame.new(v3.Position, v3.Position + cframe.LookVector)
			local clone = transform.Phase1.GroundShockwaveModel:Clone()
			local groundShockwave = clone.GroundShockwave
			groundShockwave.CFrame = cframe2
			Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)
			local emittersByEmitter = {}
			local emittersByEmitter2 = {}

			for _, emitter in ipairs(groundShockwave:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emittersByEmitter[emitter] = emitter

				if emitter.Parent ~= groundShockwave.Shockwave2 then
					continue
				end

				destroyAfter(emitter, 7)
				emittersByEmitter2[emitter] = emitter
			end

			task.spawn(function()
				for i = 10, 15 do
					clone:ScaleTo(i / 10)
					task.wait(0.1)
				end
			end)
			local v4 = 0.35 + tick()
			local v5 = time()

			for _ = 1, 600 do
				for _, v6 in pairs(emittersByEmitter) do
					v6:Emit(1)
				end

				for _, v6 in pairs(emittersByEmitter2) do
					v6:Emit(2)
				end

				task.wait(0.05)

				if v4 - tick() <= 0 or time() - v5 > 10 then
					break
				end
			end

			for _, emitter in ipairs(groundShockwave:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	end)

	local function ScreenEffect(p)
		if player == game.Players.LocalPlayer or (Workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude < 300 then
			local lastTime = tick()
			task.spawn(function()
				while tick() - lastTime < 2.25 do
					Util.CameraShaker:ShakeOnce(9, 15, 0.2, 0.7)
					task.wait(0.1)
				end
			end)

			if player == game.Players.LocalPlayer then
				local lastTime2 = tick()
				task.spawn(function()
					while tick() - lastTime2 < 2 do
						local v3 = (tick() - lastTime2) / 2
						game.Players.LocalPlayer.CameraMaxZoomDistance = 350
						game.Players.LocalPlayer.CameraMinZoomDistance = 100 + v3 ^ 0.5 * 250
						task.wait()
					end

					game.Players.LocalPlayer.CameraMinZoomDistance = 350
					local lastTime3 = tick()

					while tick() - lastTime3 < 0.4 do
						local v3 = ((tick() - lastTime3) / 0.4) ^ 2
						local v4 = 350 - v3 * 100
						game.Players.LocalPlayer.CameraMinZoomDistance = v4
						game.Players.LocalPlayer.CameraMaxZoomDistance = v4
						Workspace.CurrentCamera.FieldOfView = 70 - v3 * 30
						task.wait()
					end

					Workspace.CurrentCamera.FieldOfView = 40
					game.Players.LocalPlayer.CameraMinZoomDistance = 250
					local lastTime4 = tick()

					while tick() - lastTime4 < 0.6 do
						local v3 = ((tick() - lastTime4) / 0.6) ^ 2
						local v4 = 250 - v3 * 100
						Workspace.CurrentCamera.FieldOfView = 40 + v3 * 30
						game.Players.LocalPlayer.CameraMinZoomDistance = v4
						game.Players.LocalPlayer.CameraMaxZoomDistance = v4
						task.wait()
					end

					game.Players.LocalPlayer.CameraMinZoomDistance = 150
					Workspace.CurrentCamera.FieldOfView = 70
					game.Players.LocalPlayer.CameraMaxZoomDistance = 350
					game.Players.LocalPlayer.CameraMinZoomDistance = 75
				end)
			end

			local screenColorDV2 = Lighting:FindFirstChild("ScreenColorDV2") or transform.Phase2.ScreenColorDV2:Clone()
			Util.SetParentOverrideWithColor(screenColorDV2, Lighting, player, "DragonFruitVFXColor")
			destroyAfter(screenColorDV2, 7)
			screenColorDV2:SetAttribute("UsedTimes", screenColorDV2:GetAttribute("UsedTimes") + 1)
			local usedTimes = screenColorDV2:GetAttribute("UsedTimes")
			TweenService:Create(screenColorDV2, TweenInfo.new(0.15), {
				Brightness = -0.01,
				Contrast = 0.1,
				Saturation = 0.1,
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(231, 185, 159),
					player,
					"DragonFruitVFXColor"
				)
			}):Play()
			local currentCamera2 = Workspace.CurrentCamera
			local clone = transform.Phase2.CameraFocus:Clone()
			Util.SetParentOverrideWithColor(clone, p, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				clone.CFrame = currentCamera2.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
			end)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.spawn(function()
				task.wait(2.2)

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(0.5)
				renderSteppedConnection:Disconnect()
				clone:Destroy()
			end)
			task.wait(2.25)
			task.spawn(function()
				task.spawn(function()
					local clone2 = transform.Phase3.ScreenColor:Clone()

					if player == game.Players.LocalPlayer or (Workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude < 300 then
						Util.SetParentOverrideWithColor(clone2, Lighting, player, "DragonFruitVFXColor")
					end

					destroyAfter(clone2, 7)
					local tween = TweenService:Create(clone2, TweenInfo.new(0.025), {
						Brightness = clone2.Brightness,
						Contrast = clone2.Contrast,
						Saturation = clone2.Saturation,
						TintColor = clone2.TintColor
					})
					clone2.Brightness = 0
					clone2.Contrast = 0
					clone2.Saturation = 0
					clone2.TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"DragonFruitVFXColor"
					)
					tween:Play()
					task.wait(0.05)
					local tween2 = TweenService:Create(clone2, TweenInfo.new(0.0125), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							player,
							"DragonFruitVFXColor"
						),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					})
					tween2:Play()
					tween2.Completed:Wait()
					clone2:Destroy()
				end)
				task.spawn(function()
					local clone2 = transform.Phase3.Bloom:Clone()

					if player == game.Players.LocalPlayer or (Workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude < 300 then
						Util.SetParentOverrideWithColor(clone2, Lighting, player, "DragonFruitVFXColor")
					end

					destroyAfter(clone2, 7)
					local tween = TweenService:Create(clone2, TweenInfo.new(0.15), {
						Size = 50,
						Threshold = 1.5
					})
					tween:Play()
					tween.Completed:Wait()
					task.wait(0.15)
					local tween2 = TweenService:Create(clone2, TweenInfo.new(0.25), {
						Size = 24,
						Threshold = 2
					})
					tween2:Play()
					tween2.Completed:Wait()
					clone2:Destroy()
				end)
				task.wait(0.065)
				local clone2 = transform.Phase3.ScreenColor2:Clone()

				if player == game.Players.LocalPlayer or (Workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude < 300 then
					Util.SetParentOverrideWithColor(clone2, Lighting, player, "DragonFruitVFXColor")
				end

				destroyAfter(clone2, 7)
				local tween = TweenService:Create(clone2, TweenInfo.new(0.07), {
					Brightness = clone2.Brightness,
					Contrast = clone2.Contrast,
					Saturation = clone2.Saturation,
					TintColor = clone2.TintColor
				})
				clone2.Brightness = 0
				clone2.Contrast = 0
				clone2.Saturation = 0
				clone2.TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 255, 255),
					player,
					"DragonFruitVFXColor"
				)
				tween:Play()
				tween.Completed:Wait()
				task.wait(0.07)
				local tween2 = TweenService:Create(clone2, TweenInfo.new(0.05), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"DragonFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tween2:Play()
				tween2.Completed:Wait()
				clone2:Destroy()
			end)

			if screenColorDV2:GetAttribute("UsedTimes") == usedTimes then
				local tween = TweenService:Create(screenColorDV2, TweenInfo.new(1.5), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"DragonFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tween:Play()
				tween.Completed:Wait()

				if screenColorDV2:GetAttribute("UsedTimes") == usedTimes then
					screenColorDV2:Destroy()
				end
			end
		end
	end

	task.spawn(ScreenEffect, folder)
	task.wait(0.15)
	task.spawn(function()
		TrailSpin(part3, folder)
	end)
	local clone = transform.Phase1.StartImpact:Clone()
	clone.CFrame = cframe
	Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
	destroyAfter(clone, 7)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		task.spawn(function()
			if v3:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			v3:Emit(v3:GetAttribute("EmitCount"))
		end)
	end

	task.wait(0.07)
	local clone2 = transform.Phase1.JumpImpact:Clone()
	clone2.CFrame = cframe
	Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
	destroyAfter(clone2, 7)

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		task.spawn(function()
			if v3:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			v3:Emit(v3:GetAttribute("EmitCount"))
		end)
	end

	task.spawn(function()
		local clone3 = transform.Phase2.AlignMover:Clone()
		clone3.CFrame = cframe
		Util.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")
		destroyAfter(clone3, 7)
		clone3.Anchored = false
		clone3.Weld.Part0 = part3
		local flyUpBy = data.flyUpBy
		heartbeatLoopFor2(flyUpBy / clone3.AlignPosition.MaxVelocity, function(_, _, p)
			part.CFrame = cframe + Vector3.new(0, flyUpBy, 0) * p
		end, function()
			part.CFrame = cframe + Vector3.new(0, flyUpBy, 0) * 1
		end)
		task.wait(1.5)
		clone3:Destroy()
	end)
	task.spawn(function()
		RingBeam(cframe, folder)
	end)
	task.wait(0.05)
	local clone3 = transform.Phase1.Pillar:Clone()
	clone3.CFrame = cframe
	Util.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")
	destroyAfter(clone3, 7)

	for _, emitter in ipairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		task.spawn(function()
			v3.Enabled = true
			task.wait(0.15)
			v3.Enabled = false
		end)
	end

	task.wait(0.05)
	local clone4 = transform.Phase2.PortalStartImpact:Clone()
	clone4.CFrame = cframe * CFrame.new(0, data.flyUpBy - 20, 0)
	Util.SetParentOverrideWithColor(clone4, folder, player, "DragonFruitVFXColor")
	destroyAfter(clone4, 7)

	for _, emitter in ipairs(clone4:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		task.spawn(function()
			if v3:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			v3:Emit(v3:GetAttribute("EmitCount"))
		end)
	end

	task.spawn(function()
		local clone5 = transform.Phase3.AreaSparks:Clone()
		clone5.CFrame = cframe * CFrame.new(0, data.flyUpBy + 25, 0)
		Util.SetParentOverrideWithColor(clone5, folder, player, "DragonFruitVFXColor")
		destroyAfter(clone5, 7)
		local v3 = {}

		for _, emitter in ipairs(clone5:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			v3[emitter] = emitter
		end

		local clone6 = transform.Phase3.ThunderBoltImpact:Clone()
		Util.SetParentOverrideWithColor(clone6, folder, player, "DragonFruitVFXColor")
		destroyAfter(clone6, 7)
		local thunderBolts = transform.Phase3.ThunderBolts
		local v4 = 1.05 + tick()
		local v5 = time()

		for _ = 1, 600 do
			task.spawn(function()
				task.wait(math.random(0, 50) / 100)
				local v6 = data.flyUpBy + 30
				local raycastResult = Workspace:Raycast(
					(cframe * CFrame.new(
						math.random(-250, 250) / 1.25,
						data.flyUpBy + 15,
						math.random(-250, 250) / 1.25
					)).Position + createVector(0, 1, 0),
					createVector(0, 1, 0) * -v6,
					raycastParams
				)

				if raycastResult then
					local v8 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.001
					local cframe2 = CFrame.new(v8.Position, v8.Position + cframe.LookVector)
					local v9 = math.random(1, 6)
					local clone7 = thunderBolts["Thunder" .. tostring(v9)]:Clone()
					clone7.CFrame = cframe2
					Util.SetParentOverrideWithColor(clone7, folder, player, "DragonFruitVFXColor")
					Util.Sound:Play(
						"BF_V3_Dragon_Full_WhiteGlove_Thunder_0" .. tostring(math.random(1, 3)),
						clone7.Position
					)
					destroyAfter(clone7, 7)

					for _, emitter in ipairs(clone7:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						ScaleParticle(emitter, data.flyUpBy / 275)
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end

					clone6.CFrame = cframe2

					for _, emitter in ipairs(clone6:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v10 = emitter
						task.spawn(function()
							if v10:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v10:GetAttribute("EmitDelay"))
							end

							v10:Emit(v10:GetAttribute("EmitCount"))
						end)
					end
				end
			end)
			task.wait(0.1)

			if v4 - tick() <= 0 or time() - v5 > 10 then
				break
			end
		end

		for _, emitter in ipairs(clone5:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	SkyClouds(cframe, folder, 1.75)
	local v3 = 1.75
	task.spawn(function()
		local clone5 = transform.Phase2.Portal:Clone()
		clone5.CFrame = cframe * CFrame.new(0, data.flyUpBy - 5, 0)
		Util.SetParentOverrideWithColor(clone5, folder, player, "DragonFruitVFXColor")
		destroyAfter(clone5, 7)
		local emittersByEmitter = {}

		for _, emitter in ipairs(clone5:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emittersByEmitter[emitter] = emitter
		end

		local v4 = v3 - 0.15 + tick()
		local v5 = time()

		for _ = 1, 600 do
			for _, v6 in pairs(emittersByEmitter) do
				v6:Emit(1)
			end

			task.wait(0.07)

			if v4 - tick() <= 0 or time() - v5 > 10 then
				break
			end
		end

		for _, emitter in ipairs(clone5:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	task.wait(0.5)
	local clone5 = transform.Phase2.PortalImpact:Clone()
	clone5.CFrame = cframe * CFrame.new(0, data.flyUpBy - 5, 0)
	Util.SetParentOverrideWithColor(clone5, folder, player, "DragonFruitVFXColor")
	destroyAfter(clone5, 7)

	for _, emitter in ipairs(clone5:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = emitter
		task.spawn(function()
			if v4:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v4:GetAttribute("EmitDelay"))
			end

			v4:Emit(v4:GetAttribute("EmitCount"))
		end)
	end
end