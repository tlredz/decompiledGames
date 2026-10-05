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
local Spikes = require(script.Parent.Modules.Spikes)

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

return function(data)
	local player = data.player
	local hrp = data.hrp
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1000 then
		return
	end

	local V = FX:WaitForChild("YetiEffects").V

	if data.Stage == 1 then
		local clone = V.HRPFX.Charge:Clone()
		Util.SetParentOverrideWithColor(clone, hrp, player, "YetiFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 2)
		Util.Sound:Play("YETI_Transformation_01", hrp.Position)
		task.spawn(function()
			local clone2 = V.HRPFX.Impact:Clone()
			local clone3 = V.HRPFX.Impact2:Clone()
			local clone4 = V.HRPFX.Impact3:Clone()
			local clone5 = V.HRPFX.Roar:Clone()
			Util.SetParentOverrideWithColor(clone2, hrp, player, "YetiFruitVFXColor")
			Util.SetParentOverrideWithColor(clone3, hrp, player, "YetiFruitVFXColor")
			Util.SetParentOverrideWithColor(clone4, hrp, player, "YetiFruitVFXColor")
			Util.SetParentOverrideWithColor(clone5, hrp, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone2, 3)
			Util.Debris:AddItem(clone3, 3)
			Util.Debris:AddItem(clone4, 3)
			Util.Debris:AddItem(clone5, 3)
			task.wait(0.107)
			emitAll(clone2)
			task.wait(0.15)
			emitAll(clone3)
			task.wait(0.319)
			emitAll(clone4)
			emitAll(clone5)
		end)
		task.spawn(function()
			local player2 = data.Player
			local Players = game:GetService("Players")

			if player2 == Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(4, 5, 0.15, 1.9, createVector(0.8, 0.8, 0.8), createVector(0.8, 0.8, 0.8))
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.653, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						FieldOfView = 53
					}
				):Play()
				local clone2 = script.LTN:Clone()
				Util.SetParentOverrideWithColor(clone2, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone2, 2)
				task.spawn(function()
					task.wait(0.6000000000000001)
					local clone3 = script.DOF:Clone()
					Util.SetParentOverrideWithColor(clone3, game.Lighting, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone3, 2)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.833, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							FarIntensity = 0,
							FocusDistance = 0,
							InFocusRadius = 0,
							NearIntensity = 0
						}
					):Play()
					TweenService:Create(
						clone2,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(201, 246, 255),
								player,
								"YetiFruitVFXColor"
							),
							Brightness = 0.6,
							Contrast = 0,
							Saturation = -1
						}
					):Play()
					Util.CameraShaker:ShakeOnce(12, 14, 0.05, 0.9, createVector(1, 1, 1), createVector(1, 1, 1))
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
					task.wait(0.1)
					TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							player,
							"YetiFruitVFXColor"
						),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					}):Play()
				end)
			end

			task.wait(0.267)
			local clone2 = V.BillboardGui:Clone()
			local imageLabel = clone2:WaitForChild("ImageLabel")
			Util.SetParentOverrideWithColor(clone2, hrp, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone2, 4)
			imageLabel.Size = UDim2.new(0, 0, 0, 0)
			imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
			TweenService:Create(
				imageLabel,
				TweenInfo.new(0.416, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					ImageTransparency = 1
				}
			):Play()
		end)
		local player2 = data.Player
		local Players = game:GetService("Players")

		if player2 == Players.LocalPlayer then
			task.spawn(function()
				local WAIT_INTERVAL = 0.05
				task.wait(0.107)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 40
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 70
					}
				):Play()
				task.wait(0.15)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 40
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 70
					}
				):Play()
				task.wait(0.319)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 40
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 70
					}
				):Play()
			end)
		end

		task.spawn(function()
			local lookVector = hrp.CFrame.LookVector
			local v = hrp.Position + lookVector * 1
			local rayMap, v2, vector2 = Util.RayMap(v, createVector(0, -15, 0))

			if rayMap or data.Scene then
				local v3 = vector2 * 0.1
				local _ = hrp.CFrame
				local clone2 = V.CracksGround:Clone()

				if data.Scene then
					v2 += createVector(0, 8, 0)
				end

				local cframe = CFrame.new(Vector3.new(), vector2:Cross(createVector(0, 1, 0)), vector2)
				clone2.CFrame = CFrame.new(v2 + v3) * cframe

				if player:GetAttribute("RedYeti") then
					for _, emitter in ipairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Color = ColorSequence.new(Color3.new(1, 0, 0))

						if emitter.Orientation == Enum.ParticleOrientation.VelocityPerpendicular then
							emitter.LightEmission = math.min(0.2, emitter.LightEmission)
						end
					end

					clone2.Parent = _WorldOrigin
				else
					Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
				end

				Util.Debris:AddItem(clone2, 5.3)
				local clone3 = V.HRPFX.ImpactFloor:Clone()
				local clone4 = V.HRPFX.Impact2Floor:Clone()
				local clone5 = V.HRPFX.Impact3Floor:Clone()
				Util.SetParentOverrideWithColor(clone3, clone2, player, "YetiFruitVFXColor")
				Util.SetParentOverrideWithColor(clone4, clone2, player, "YetiFruitVFXColor")
				Util.SetParentOverrideWithColor(clone5, clone2, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone3, 3)
				Util.Debris:AddItem(clone4, 3)
				Util.Debris:AddItem(clone5, 3)
				task.wait(0.107)
				emitAll(clone3)
				Spikes.Ring(player, 8, 1, clone2, nil, 7, 8, 9, 2, nil, _WorldOrigin)
				task.wait(0.15)
				emitAll(clone4)
				Spikes.Ring(player, 8, 2, clone2, nil, 12, 12, 9, 2, nil, _WorldOrigin)
				task.wait(0.319)
				emitAll(clone5)
				Spikes.Ring(player, 8, 2, clone2, nil, 28, 23, 9, 2, "DefrostBear", _WorldOrigin)
				Spikes.Ring(player, 12, 2, clone2, nil, 39, 11, 9, 4, nil, _WorldOrigin)
				emitAll(clone2.Floor)
				local clone6 = V.DecalRingBlue1.ring1_1:Clone()
				local clone7 = V.DecalRingBlue1.ring1_2:Clone()
				clone6.CFrame = clone2.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
					0,
					-1.5707963267948966,
					3.141592653589793
				)
				clone7.CFrame = clone2.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
					0,
					1.5707963267948966,
					3.141592653589793
				)
				Util.SetParentOverrideWithColor(clone6, _WorldOrigin, player, "YetiFruitVFXColor")
				Util.SetParentOverrideWithColor(clone7, _WorldOrigin, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone6, 1)
				Util.Debris:AddItem(clone7, 1)
				TweenService:Create(clone6, TweenInfo.new(0.517, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
					CFrame = clone6.CFrame * CFrame.new(0, -15, 0)
				}):Play()
				TweenService:Create(clone7, TweenInfo.new(0.517, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
					CFrame = clone6.CFrame * CFrame.new(0, -15, 0)
				}):Play()
				TweenService:Create(
					clone6.ring1_1,
					TweenInfo.new(0.517, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
					{
						Scale = createVector(-168.827, 0.742, -168.827)
					}
				):Play()
				TweenService:Create(
					clone7.ring1_2,
					TweenInfo.new(0.517, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
					{
						Scale = createVector(168.827, 0.742, 168.827)
					}
				):Play()
				TweenService:Create(
					clone6.Decal1_1,
					TweenInfo.new(0.55, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
					{
						Transparency = 1
					}
				):Play()
				TweenService:Create(
					clone7.Decal1_2,
					TweenInfo.new(0.55, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
					{
						Transparency = 1
					}
				):Play()
			end
		end)
		task.spawn(function()
			task.wait(0.5760000000000001)

			for _ = 1, 35 do
				local clone2 = V.IceWind:Clone()
				clone2.CFrame = hrp.CFrame * CFrame.Angles(
					math.rad(math.random(-3600, 3600) / 10),
					math.rad(math.random(-3600, 3600) / 10),
					(math.rad(math.random(-3600, 3600) / 10))
				)
				clone2.Position = hrp.position
				clone2.Anchored = false
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
				local v = math.random(2, 5) / 5
				local v2 = math.random(20, 40) / 5

				if math.random(2) == 1 then
					v2 *= -1
				end

				for _, descendant in pairs(clone2:GetDescendants()) do
					if descendant:IsA("Attachment") then
						descendant.Position = Vector3.new(0, descendant.Name == "Top" and v or -v, 0)
						descendant.Position += Vector3.new(0, v2, 0)
					end

					if descendant:IsA("Trail") then
						descendant.WidthScale = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 5),
							NumberSequenceKeypoint.new(1, 0)
						})
					end
				end

				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
				bodyVelocity.Velocity = clone2.CFrame.LookVector * math.random(250, 340)
				Util.SetParentOverrideWithColor(bodyVelocity, clone2, player, "YetiFruitVFXColor")
				local v3 = math.random(15, 25) / 1.5
				clone2.RotVelocity = clone2.CFrame.LookVector * v3
				coroutine.resume(coroutine.create(function()
					task.wait(math.random(20, 60) / 100)
					clone2.Anchored = true
					Util.Debris:AddItem(clone2, 1.5)
				end))
			end
		end)
	elseif data.Stage == 2 then
		local rig = data.Rig
		task.spawn(function()
			task.wait(0.185)
			emitAll(rig.TransformParticlesQuick)
		end)
		task.spawn(function()
			task.wait(0.35)
			emitAll(rig.TransformParticles)
		end)
		task.spawn(function()
			local function lerp(p, p2, p3)
				return p + (p2 - p) * p3
			end

			local position = hrp.Position
			local v = hrp.Position + createVector(0, 40, 0)
			local magnitude = (position - v).magnitude
			local ray, v2, _ = Util.Ray(
				position,
				CFrame.new(position, v).LookVector.Unit * (magnitude + 8),
				{ workspace.Characters, workspace.Enemies }
			)
			local back = Util.Tween.ease.inout.back

			for i = 1, 25 do
				local v3 = i
				task.spawn(function()
					if 20 % v3 ~= 0 then
						local v4 = CFrame.new(position, v2) * CFrame.new(
							0,
							0,
							-math.random(5, (math.max(14, magnitude)))
						) * CFrame.Angles(1.5707963267948966, 0, 0)
					end

					local v5 = v3 % 2 == 0
					local clone

					if v5 then
						clone = FX:WaitForChild("YetiEffects").V.SwirlCrescent:Clone()
					elseif v3 % 3 == 0 then
						clone = FX:WaitForChild("YetiEffects").V.WindV2:Clone()
					else
						clone = FX:WaitForChild("YetiEffects").V.WindFragments:Clone()
					end

					Util.Debris:AddItem(clone, 2)
					local part = clone.Part
					part.Transparency = 1
					local v6 = false
					local v7 = v3 / 24
					local v8

					if v7 < 0.75 then
						v8 = math.min(1, (v7 / 0.75) ^ 0.8 + 0.2)
					else
						v8 = 1 - (v7 - 0.75) / 0.25
						v6 = true
					end

					local v9 = back(v8, 0.01, 1.59, 1, 11)
					clone:ScaleTo((math.max(v9, v6 and 2.5 or 0.1)))
					task.spawn(function()
						local beam = part.beam1.Beam
						local beam2 = part.beam2.Beam
						local beam3 = part.beam3.Beam
						local beam4 = part.beam4.Beam
						local beam5 = part.beam5.Beam
						local beam6 = part.beam6.Beam
						TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 17.6 * v9,
							Width1 = 0
						}):Play()
						TweenService:Create(
							beam2,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v9,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam3,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = math.random(20, 30) * v9,
								Width1 = 6 * v9
							}
						):Play()
						TweenService:Create(
							beam4,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v9,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam5,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v9,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam6,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = math.random(20, 30) * v9,
								Width1 = 6 * v9
							}
						):Play()
						task.wait(0.05)
						TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam3, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam4, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam5, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam6, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
					task.spawn(function()
						emitAll(clone)
						task.wait(0.2)

						for i2, emitter in pairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.LockedToPart = false
							end
						end
					end)
					local cframe = CFrame.Angles(
						math.rad((math.random(-15, 15))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-15, 15))))
					)
					part.CFrame = CFrame.new(v) * cframe
					local v11 = ({ -1, 1 })[math.random(1, 2)] * 179
					local tween = TweenService:Create(
						part,
						TweenInfo.new(v5 and 0.35 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = Vector3.new(5, v5 and 1 or 3, 5),
							Position = position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)),
							Transparency = 1
						}
					)
					local tween2 = TweenService:Create(
						part,
						TweenInfo.new(v5 and 0.1 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, false, 0),
						{
							Orientation = part.Orientation + Vector3.new(0, v11, 0)
						}
					)
					tween2.Completed:Connect(function()
						if part then
							tween2 = TweenService:Create(
								part,
								TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
								{
									Orientation = part.Orientation + Vector3.new(0, v11, 0)
								}
							)
							tween2:Play()
						end
					end)
					tween.Completed:Connect(function()
						if not ray then
							task.spawn(function()
								for i2, beam in pairs(clone:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone:Destroy()
							end)
							return
						end

						local tween3 = TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
							{
								Transparency = 1,
								CFrame = part.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
									math.rad((math.random(-5, 5))),
									v11,
									(math.rad((math.random(-5, 5))))
								)
							}
						)
						tween3.Completed:Connect(function()
							task.spawn(function()
								for i2, beam in pairs(clone:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone:Destroy()
							end)
						end)
						tween3:Play()
					end)
					Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
					tween:Play()
					tween2:Play()
					task.delay(5, function()
						pcall(tween.Destroy, tween)
						pcall(tween2.Destroy, tween2)
					end)
				end)
				task.wait(0.025)
			end
		end)
	end
end