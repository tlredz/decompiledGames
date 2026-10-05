local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local RocksModule = require(game.ReplicatedStorage.Util.RocksModule)

local function debrisPart(data, p, p2)
	local v = math.random(20, 40) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 5)
	part.Material = data.Material
	part.Transparency = data.Transparency
	part.Reflectance = data.Reflectance
	part.Color = data.Color
	part.Size = Vector3.new(v, v, v)
	part.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	part.CanCollide = false
	part.Parent = _WorldOrigin
	part.Velocity = part.CFrame.lookVector.Unit * Vector3.new(
		math.random(180, 250),
		math.random(80, 160),
		math.random(180, 250)
	)
	part.RotVelocity = Vector3.new(math.random(-7, 7), math.random(-7, 7), math.random(-7, 7))
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	return part
end

local function hit(plr, hrp, _, _, mammoth, stage)
	local M1 = FX:WaitForChild("Mammoth").M1
	local clone = M1.one:Clone()
	local clone2 = M1.two:Clone()
	Util.Debris:AddItem(clone, 0.35)
	local children = plr.Character:FindFirstChild("Mammoth").Mammoth:GetChildren()

	local function lightup()
		local bindableFunction = Instance.new("BindableFunction")

		function bindableFunction.OnInvoke()
			return false
		end

		for _, part in pairs(children) do
			if not (part:IsA("MeshPart") and (part.Name == "Plane.010" or part.Name:find("Crystal") or part.Name:find("ArmorBlue"))) then
				continue
			end

			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					Color = Color3.fromRGB(255, 255, 255)
				}
			)
			tween:Play()

			function bindableFunction.OnInvoke()
				return tween.PlaybackState == Enum.PlaybackState.Cancelled
			end

			local v2 = tween
			local v3 = part
			task.spawn(function()
				task.wait(0.05)

				if v2.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				local tween2 = TweenService:Create(
					v3,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Color = Color3.fromRGB(255, 57, 57)
					}
				)
				tween2:Play()

				function bindableFunction.OnInvoke()
					return tween2.PlaybackState == Enum.PlaybackState.Cancelled
				end

				task.wait(0.1)

				if tween2.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				local tween3 = TweenService:Create(
					v3,
					TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Color = Color3.fromRGB(112, 22, 22)
					}
				)
				tween3:Play()

				function bindableFunction.OnInvoke()
					return tween3.PlaybackState == Enum.PlaybackState.Cancelled
				end

				task.wait(0.25)

				if tween3.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				local tween4 = TweenService:Create(
					v3,
					TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
					{
						Color = Color3.fromRGB(113, 22, 22)
					}
				)
				tween4:Play()

				function bindableFunction.OnInvoke()
					return tween4.PlaybackState == Enum.PlaybackState.Cancelled
				end

				task.wait(0.6)

				function bindableFunction.OnInvoke()
					return false
				end
			end)
		end

		return function()
			return bindableFunction:Invoke()
		end
	end

	local function lightoff()
		for _, part in pairs(children) do
			if not (part:IsA("MeshPart") and (part.Name == "Plane.010" or part.Name:find("Crystal") or part.Name:find("ArmorBlue"))) then
				continue
			end

			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Color = Color3.fromRGB(13, 105, 172)
			}):Play()
		end
	end

	if stage == 1 then
		task.spawn(function()
			local v = lightup()
			task.wait(1)

			if not v() then
				lightoff()
			end
		end)
		task.wait(0.285)
		Util.Sound:Play("MammothSwipe1", hrp, 25, 1 + math.random(-5, 5) / 100, 1)

		if plr == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(12, 5, 0.1, 0.6, createVector(0.5, 0.2, 0.1), createVector(0.5, 0.5, 0.5))
		end

		clone.CFrame = hrp.CFrame * CFrame.new(0, 8, -10) * CFrame.Angles(
			-1.8325957145940461,
			3.141592653589793,
			-0.3490658503988659
		)
		clone.Parent = _WorldOrigin
		Util.Debris:AddItem(clone, 3)
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			CFrame = clone.CFrame * CFrame.Angles(0, 0, -2.181661564992912)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Size = createVector(74, 74, 5)
		}):Play()

		for _, decal in pairs(clone:GetChildren()) do
			if decal:IsA("Decal") then
				TweenService:Create(decal, TweenInfo.new(0.23, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play()
			end
		end

		local lookVector = plr.Character.PrimaryPart.CFrame.LookVector
		local v = hrp.Position + lookVector * 2
		local v2 = hrp.Size.Y * 0.5 + hrp.Parent.Humanoid.HipHeight + 5
		local rayMap, v3, _ = Util.RayMap(v, createVector(0, -1, 0.5) * v2)

		if rayMap then
			local function groundEffects(_, rayMap2)
				if rayMap2 then
					mammoth["body4.002"].SmokeL.SmokeL:Emit(40)
					mammoth["body4.002"].SmokeL.SmokeL.Color = ColorSequence.new(rayMap2.Color)
					mammoth["body4.002"].SmokeFront.Smoke.Color = ColorSequence.new(rayMap2.Color)
					task.spawn(function()
						for _, child in pairs(mammoth["body4.002"].Wind:GetChildren()) do
							child:Emit(child:GetAttribute("EmitCount"))
						end

						task.wait(0.016)
						mammoth["body4.002"].SmokeFront.Smoke:Emit(30)
					end)
				end
			end

			groundEffects(v3, rayMap)
		end

		for _, child in pairs(clone.emit:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		for _, child in pairs(clone.emit2:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end
	elseif stage == 2 then
		task.spawn(function()
			local v = lightup()
			task.wait(1)

			if not v() then
				lightoff()
			end
		end)
		Util.Sound:Play("MammothSwipe2", hrp, 25, 1 + math.random(-5, 5) / 100, 1)
		task.wait(0.285)

		if plr == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(12, 5, 0.1, 0.6, createVector(-0.5, 0.2, 0.1), createVector(0.5, 0.5, 0.5))
		end

		clone2.CFrame = hrp.CFrame * CFrame.new(0, 5, -10) * CFrame.Angles(-1.8325957145940461, 0, -1.2217304763960306)
		clone2.Parent = _WorldOrigin
		Util.Debris:AddItem(clone2, 0.35)
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			CFrame = clone2.CFrame * CFrame.Angles(0, 0, -2.181661564992912)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Size = createVector(74, 74, 5)
		}):Play()

		for _, decal in pairs(clone2:GetChildren()) do
			if decal:IsA("Decal") then
				TweenService:Create(decal, TweenInfo.new(0.23, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play()
			end
		end

		local lookVector = plr.Character.PrimaryPart.CFrame.LookVector
		local v = hrp.Position + lookVector * 2
		local v2 = hrp.Size.Y * 0.5 + hrp.Parent.Humanoid.HipHeight + 5
		local rayMap, v3, _ = Util.RayMap(v, createVector(0, -1, 0.5) * v2)

		if rayMap then
			local function groundEffects(_, rayMap2)
				if rayMap2 then
					mammoth["body4.002"].SmokeR.SmokeR.Color = ColorSequence.new(rayMap2.Color)
					mammoth["body4.002"].SmokeFront.Smoke.Color = ColorSequence.new(rayMap2.Color)
					mammoth["body4.002"].SmokeR.SmokeR:Emit(40)
					task.spawn(function()
						task.wait(0.016)

						for _, child in pairs(mammoth["body4.002"].Wind:GetChildren()) do
							child:Emit(child:GetAttribute("EmitCount"))
						end

						mammoth["body4.002"].SmokeFront.Smoke:Emit(30)
					end)
				end
			end

			groundEffects(v3, rayMap)
		end

		for _, child in pairs(clone2.emit:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		for _, child in pairs(clone2.emit2:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end
	elseif stage == 3 then
		task.spawn(function()
			local v = lightup()
			task.wait(1)

			if not v() then
				lightoff()
			end
		end)
		task.wait(0.36)
		mammoth["body4.002"].LinesDown:Emit(20)

		if plr == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(12, 15, 0.1, 0.3, createVector(0.7, 0.7, 0.7), createVector(0.7, 0.7, 0.7))
		end

		local clone3 = M1.Stomp:Clone()
		local clone4 = M1.Stomp:Clone()
		task.spawn(function()
			local lookVector = plr.Character.PrimaryPart.CFrame.LookVector
			local v = hrp.Position + lookVector * 2
			local v2 = hrp.Size.Y * 0.5 + hrp.Parent.Humanoid.HipHeight + 5
			local rayMap, _, _ = Util.RayMap(v, createVector(0, -1, 0.5) * v2)

			if rayMap then
				Util.Sound:Play("MammothStomp", hrp, 25, 1 + math.random(-5, 5) / 100, 1)
				Util.Sound:Play("MammothDebris", hrp, 25, 1 + math.random(-5, 5) / 100, 0.9)
				local rayMap2, v3, v4 = Util.RayMap(
					mammoth["body4.002"].Foot1.WorldPosition + createVector(0, 1, 0),
					createVector(-0, -3, -0)
				)
				local v5 = v3 + createVector(0, 0.1, 0)
				clone3.CFrame = CFrame.new(v5, v5 + (not rayMap2 and createVector(0, 1, 0) or v4)) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
				clone3.Parent = _WorldOrigin
				Util.Debris:AddItem(clone3, 1.5)
				TweenService:Create(
					clone3,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
					{
						Size = createVector(20, 0.05, 20)
					}
				):Play()
				TweenService:Create(
					clone3.Decal,
					TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
					{
						Transparency = 1
					}
				):Play()
				local rayMap3, v6, v7 = Util.RayMap(
					mammoth["body4.002"].Foot2.WorldPosition + createVector(0, 1, 0),
					createVector(-0, -3, -0)
				)
				local v8 = v6 + createVector(0, 0.1, 0)
				clone4.CFrame = CFrame.new(v8, v8 + (not rayMap3 and createVector(0, 1, 0) or v7)) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
				clone4.Parent = _WorldOrigin
				Util.Debris:AddItem(clone4, 1.5)
				TweenService:Create(
					clone4,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
					{
						Size = createVector(20, 0.05, 20)
					}
				):Play()
				TweenService:Create(
					clone4.Decal,
					TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
					{
						Transparency = 1
					}
				):Play()
				local ground = RocksModule.Ground
				local v9 = clone3.Position + createVector(0, 1, 0)
				local v10 = { workspace.Map }
				ground(v9, 14, createVector(5, 3, 4), v10, 6, false, 0.7, false)
				local ground2 = RocksModule.Ground
				local v11 = clone4.Position + createVector(0, 1, 0)
				local v12 = { workspace.Map }
				ground2(v11, 14, createVector(5, 3, 4), v12, 6, false, 0.7, false)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function groundEffects(_, rayMap4)
					if rayMap4 then
						mammoth["body4.002"].Foot1.ParticleEmitter.Color = ColorSequence.new(rayMap4.Color)
						mammoth["body4.002"].Foot2.ParticleEmitter.Color = ColorSequence.new(rayMap4.Color)
					end
				end

				for _, child in pairs(mammoth["body4.002"].Foot1:GetChildren()) do
					child:Emit(child:GetAttribute("EmitCount"))
				end

				for _, child in pairs(mammoth["body4.002"].Foot2:GetChildren()) do
					child:Emit(child:GetAttribute("EmitCount"))
				end

				groundEffects(nil, rayMap3) -- equivalent call inferred; original call site unknown
			else
				Util.Sound:Play("MammothBlast", hrp, 25, 1 + math.random(-5, 5) / 100, 1.1)
			end
		end)
	elseif stage == 4 then
		task.spawn(function()
			local v = lightup()
			task.wait(1)

			if not v() then
				lightoff()
			end
		end)
		Util.Sound:Play("MammothMiniRoar", hrp, 25, 1 + math.random(-5, 5) / 100, 1.3)
		task.wait(0.09)
		mammoth.Sphere.EyeL.eye2:Emit(2)
		mammoth.Sphere.EyeR.eye2:Emit(2)

		if plr == game.Players.LocalPlayer then
			task.spawn(function()
				task.wait(0.05)
				local camera = workspace.Camera

				for i = 1, 11 do
					camera.FieldOfView = i * 8
					task.wait(0.016666666666666666)
				end

				task.wait(0.25)

				for i = 1, 10 do
					camera.FieldOfView = 88 - i * 1.8
					task.wait(0.016666666666666666)
				end
			end)
		end

		task.wait(0.13)
		task.spawn(function()
			for _ = 1, 3 do
				task.wait(0.03)
				local clone3 = M1.Ringp:Clone()
				clone3.CFrame = hrp.CFrame * CFrame.new(0, -4, 0)
				clone3.Size = createVector(10.901, 3.141, 9.901)
				clone3.Parent = _WorldOrigin
				Util.Debris:AddItem(clone3, 0.5)
				TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = hrp.CFrame * CFrame.new(0, -8, 0),
					Size = createVector(184, 2, 184),
					Transparency = 1
				}):Play()
				local clone4 = M1.SPIKESHOCK:Clone()
				clone4.CFrame = hrp.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(0, 0, 0)
				clone4.Parent = _WorldOrigin
				Util.Debris:AddItem(clone4, 0.5)
				TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = clone4.CFrame * CFrame.new(0, -7, 0),
					Size = createVector(174, 7, 174),
					Transparency = 1
				}):Play()
				local clone5 = M1.Wind:Clone()
				clone5.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
				clone5.Parent = _WorldOrigin
				Util.Debris:AddItem(clone5, 0.5)
				TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = hrp.CFrame * CFrame.new(0, -2, 0),
					Size = createVector(160, 10, 160),
					Transparency = 1
				}):Play()
				local clone6 = M1.purple:Clone()
				clone6.CFrame = hrp.CFrame
				clone6.Parent = _WorldOrigin
				clone6.Transparency = 0
				Util.Debris:AddItem(clone6, 0.5)
				TweenService:Create(clone6, TweenInfo.new(0.31, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(280, 280, 280),
					Transparency = 1
				}):Play()
				local clone7 = M1.WindBurst:Clone()
				clone7.CFrame = hrp.CFrame
				clone7.Parent = _WorldOrigin
				Util.Debris:AddItem(clone7, 0.5)
				TweenService:Create(clone7, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Size = createVector(120, 120, 120),
					CFrame = clone7.CFrame * CFrame.Angles(
						math.rad((math.random(-360, 360))),
						math.rad((math.random(-360, 360))),
						(math.rad((math.random(-360, 360))))
					),
					Transparency = 1
				}):Play()
				task.spawn(function()
					local children2 = mammoth["body4.002"].blast:GetChildren()

					for _, v in pairs(children2) do
						local emitCount = v:GetAttribute("EmitCount") or 0
						local emitDelay = v:GetAttribute("EmitDelay") or 0

						if emitDelay > 0 then
							local v2 = emitDelay
							local v3 = v
							local v4 = emitCount
							task.spawn(function()
								task.wait(v2)
								v3:Emit(v4)
							end)
						else
							v:Emit(emitCount)
						end
					end
				end)
			end

			if plr == game.Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(7, 18, 0.1, 1.1, createVector(1, 1, 1), createVector(1.4, 1.4, 1.4))
				task.wait(0.0443)
				local clone3 = script.Blur:Clone()
				local Debris = game:GetService("Debris")
				Debris:AddItem(clone3, 1)
				clone3.Parent = game.Lighting
				TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = 0
				}):Play()
			end
		end)

		if plr == game.Players.LocalPlayer then
			task.spawn(function()
				task.wait(0.07)
				local clone3 = script.LTN:Clone()
				clone3.Parent = game.Lighting
				Util.Debris:AddItem(clone3, 2)
				TweenService:Create(clone3, TweenInfo.new(0.015), {
					TintColor = Color3.fromRGB(225, 9, 9),
					Brightness = 4,
					Contrast = 1,
					Saturation = -2
				}):Play()
				task.wait(0.012)
				TweenService:Create(clone3, TweenInfo.new(0.005), {
					TintColor = Color3.fromRGB(53, 53, 53),
					Brightness = 0.3,
					Contrast = 1,
					Saturation = -2
				}):Play()
				task.wait(0.001)
				TweenService:Create(clone3, TweenInfo.new(0.087), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}):Play()
				Util.Debris:AddItem(clone3, 1)
			end)
		end

		task.spawn(function()
			local v = hrp.Size.Y * 0.5 + hrp.Parent.Humanoid.HipHeight + 5
			local _, _, _ = Util.RayMap(hrp.Position, createVector(0, 1, 0) * -v)
			local clone3 = M1.CracksGround:Clone()
			local clone4 = M1.RedCracksGround:Clone()
			local lookVector = plr.Character.PrimaryPart.CFrame.LookVector
			local v2 = hrp.Position + lookVector * 0
			local v3 = hrp.Size.Y * 0.5 + hrp.Parent.Humanoid.HipHeight + 5
			local rayMap, v4, v5 = Util.RayMap(v2, createVector(0, -1, 0) * v3)

			if rayMap then
				local v6 = v5 * 0.1
				local _ = plr.Character.PrimaryPart.CFrame
				clone3.CFrame = CFrame.new(v4, v4 + v6) * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone3.Parent = _WorldOrigin
				Util.Debris:AddItem(clone3, 2.3)
				clone4.CFrame = clone3.CFrame * CFrame.new(0, 0.05, 0)
				clone4.Parent = _WorldOrigin
				Util.Debris:AddItem(clone4, 2.3)
				task.spawn(function()
					local _, _ = Util.RayMap(clone.Position, createVector(0, -5, 0))

					for _ = 1, 14 do
						debrisPart(rayMap, v4, v5)
					end
				end)
				task.wait(0.1)
				local _ = clone3.CFrame
				local _ = clone3.Position
				coroutine.resume(coroutine.create(function()
					for i = 1, 8 do
						local v7 = clone3.Position + createVector(0, 11, 0)
						local v9 = CFrame.new(v7) * CFrame.Angles(0, math.rad(i * 45), 0)
						coroutine.resume(coroutine.create(function()
							local total = 35
							local total2 = 3.5

							for i2 = 1, 3 do
								local v10 = math.random(-360, 360) / 100
								local clone5 = M1.SpikeGround:Clone()
								clone5.CFrame = v9 * CFrame.new(v10, -6, -total) * CFrame.Angles(
									math.rad(math.random(-150, 150) / 10),
									math.rad((math.random(170, 190))),
									(math.rad(math.random(-150, 150) / 10))
								)
								clone5.Size *= total2
								clone5.Material = "Neon"
								clone5.Color = Color3.new(0.815686, 0.105882, 0.105882)
								task.delay(0.1, function()
									clone5.BrickColor = rayMap.BrickColor
									clone5.Material = rayMap.Material
								end)
								clone5.Transparency = 0
								clone5.Parent = _WorldOrigin
								TweenService:Create(
									clone5,
									TweenInfo.new(0.175, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
									{
										CFrame = clone5.CFrame * CFrame.new(0, 5, 0),
										Size = clone5.Size * 1.15
									}
								):Play()
								local v12 = clone5
								coroutine.resume(coroutine.create(function()
									task.wait(math.random(170, 189) / 100)
									local tween = TweenService:Create(
										v12,
										TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
										{
											CFrame = v12.CFrame * CFrame.new(0, -25, 0),
											Size = createVector(0, 0, 0)
										}
									)
									tween.Completed:Connect(function()
										v12:Destroy()
									end)
									tween:Play()
								end))
								total += 9
								total2 += 2
							end
						end))
					end
				end))
				task.wait(0.1)
				task.spawn(function()
					TweenService:Create(
						clone3,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = createVector(110, 0.05, 110)
						}
					):Play()
					TweenService:Create(
						clone4,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = createVector(110, 0.05, 110)
						}
					):Play()
					task.wait(0.2)
					TweenService:Create(
						clone4.Decal,
						TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						clone3.Decal,
						TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
						{
							Color3 = Color3.new(0, 0, 0)
						}
					):Play()
					task.wait(0.7)
					TweenService:Create(
						clone3.Decal,
						TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
						{
							Transparency = 1
						}
					):Play()
				end)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function groundEffects(_, rayMap2)
					if rayMap2 then
						clone3.blastdown.SMOKE.Color = ColorSequence.new(rayMap2.Color)
					end
				end

				for _, child in pairs(clone3.blastdown:GetChildren()) do
					child:Emit(child:GetAttribute("EmitCount"))
				end

				groundEffects(nil, rayMap) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

return function(data)
	local plr = data.plr
	local hrp = data.hrp
	local cFrame = data.CFrame
	local mouse = data.mouse
	local stage = data.stage

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 or not hrp then
		return
	end

	local mammoth = hrp.Parent:FindFirstChild("Mammoth").Mammoth

	if not mammoth then
		return
	end

	hit(plr, hrp, cFrame, mouse, mammoth, stage)
end