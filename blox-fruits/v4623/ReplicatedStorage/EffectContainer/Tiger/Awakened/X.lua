local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local superhumanV2Travel = Effect.new("SuperhumanV2.Travel")
local _WorldOrigin = workspace._WorldOrigin
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { _WorldOrigin, workspace.Characters, workspace.Enemies }
local RockRipple = require(script.Parent.Parent.Modules.RockRipple)
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local tigerEffects = FX:WaitForChild("TigerEffects")
return function(player)
	local player2 = player.player
	local origin = player.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = player.Stage
	local _ = player.RigModel
	local root = player.Root
	local TweenService = game:GetService("TweenService")

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

	local function enableAll(folder, enabled: boolean)
		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = enabled
			end
		end
	end

	if stage == 1 then
		local holding = player.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder", _WorldOrigin)
		local tigerRig = root.Parent.TigerRig:FindFirstChild("TigerRig")
		local clone = tigerEffects.X_Awak.ChargeMouth:Clone()
		Util.SetParentOverrideWithColor(clone, folder, player2, "LeopardFruitVFXColor")
		clone.RigidConstraint.Attachment0 = clone.Attachment
		clone.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Torso1.Torso2.Torso3.Neck1.Neck2.Neck3.Head.Jaw
		emitAll(clone.Impact)
		Util.Sound:Play("BF_TigerFt_AWK_X_Activate_01", root)
		local v = Util.Sound:Play("BF_TigerFt_AWK_X_Held_02", root)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(v, TweenInfo.new(1), {
			Volume = 1
		}):Play()
		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.035
					root.Parent:FindFirstChild("RightHand")

					if root.Parent == game.Players.LocalPlayer.Character then
						Util.CameraShaker:ShakeOnce(
							1.7,
							1.4,
							0.05,
							0.1,
							createVector(0.3, 0.3, 0.3),
							createVector(0.3, 0.3, 0.3)
						)
					end
				end
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)
		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.5
					emitAll(clone.Charge.IntervalPulse)
				end
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)

		repeat
			task.wait()
		until not (holding.Value and holding)

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		enableAll(clone, false)
		task.delay(0.3, function()
			folder:Destroy()
		end)
	elseif stage == 2 then
		local folder = Instance.new("Folder", _WorldOrigin)
		Util.Debris:AddItem(folder, 10)
		local speed = player.Speed
		local lifetime = player.Lifetime
		local _ = player.ExplosionDur
		local endPosition = player.EndPosition
		local _ = player.Character
		local _ = player.Root
		local startCFrame = player.StartCFrame
		Util.Sound:Play("BF_TigerFt_AWK_X_ReleaseRoar_0" .. tostring(math.random(1, 2)), root)
		task.spawn(function()
			if root.Parent == game.Players.LocalPlayer.Character then
				Util.CameraShaker:ShakeOnce(12, 13, 0.05, 1, createVector(1.4, 1.6, 1.6), createVector(0.9, 0.9, 0.9))
				task.spawn(function()
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							FieldOfView = 107
						}
					):Play()
					task.wait(0.1)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
				end)
				task.spawn(function()
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					Util.SetParentOverrideWithColor(
						colorCorrectionEffect,
						game.Lighting,
						player2,
						"LeopardFruitVFXColor"
					)
					Util.Debris:AddItem(colorCorrectionEffect, 0.3)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(197, 65, 255),
								player2,
								"LeopardFruitVFXColor"
							),
							Brightness = -3,
							Saturation = -1,
							Contrast = 8
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 166, 93),
								player2,
								"LeopardFruitVFXColor"
							),
							Brightness = 0.4,
							Saturation = 0,
							Contrast = 1
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 255, 255),
								player2,
								"LeopardFruitVFXColor"
							),
							Brightness = 0,
							Saturation = 0,
							Contrast = 0
						}
					):Play()
				end)
			end
		end)
		local tigerRig = root.Parent.TigerRig:WaitForChild("TigerRig")
		local clone = tigerEffects.X_Awak.Mouth:Clone()
		Util.SetParentOverrideWithColor(clone, folder, player2, "LeopardFruitVFXColor")
		clone.RigidConstraint.Attachment0 = clone.Attachment
		clone.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Torso1.Torso2.Torso3.Neck1.Neck2.Neck3.Head.Jaw
		emitAll(clone)
		local clone2 = tigerEffects.X_Awak.TigerStart:Clone()
		clone2.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone2, folder, player2, "LeopardFruitVFXColor")
		emitAll(clone2)
		Util.Debris:AddItem(clone2, 2)
		local clone3 = tigerEffects.X_Awak.tiger:Clone()
		local scale = clone3:GetScale()
		clone3:ScaleTo(0.5)
		local primaryPart = clone3.PrimaryPart
		primaryPart.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone3, folder, player2, "LeopardFruitVFXColor")
		local v = Util.Sound:Play("BF_TigerFt_AWK_X_FlyingLoop_01", primaryPart)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(v, TweenInfo.new(1), {
			Volume = 1
		}):Play()
		local tigerAwakenedXHeadLoop = Util.Anims:Get(clone3, "TigerAwakened_XHeadLoop")
		tigerAwakenedXHeadLoop.Priority = Enum.AnimationPriority.Idle
		tigerAwakenedXHeadLoop.Looped = true
		tigerAwakenedXHeadLoop:Play()
		emitAll(clone3.VFX.Back.Eyes)
		os.clock()
		local _ = clone3.Tiger.TrailRotate.C0
		local now = 0
		local flag = false
		local lastTime = os.clock()
		local v2 = false
		local heartbeatConnection = nil
		local scale2 = clone3:GetScale()
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = scale2
		Util.SetParentOverrideWithColor(numberValue, workspace._WorldOrigin, player2, "LeopardFruitVFXColor")
		Util.Debris:AddItem(numberValue, 2)
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(numberValue, TweenInfo.new(0.35, Enum.EasingStyle.Bounce, Enum.EasingDirection.In), {
			Value = scale
		}):Play()
		superhumanV2Travel:replicate({
			Root = primaryPart,
			Color = Util.WrapColor3Constructor(Color3.new(1, 1, 1), player2, "LeopardFruitVFXColor"),
			Scale = 6,
			Duration = lifetime,
			IgnoreParticles = true,
			IgnoreTrail = true,
			StopWithoutSurface = true
		})
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			local v3 = os.clock() - lastTime

			if lifetime <= v3 then
				flag = true
				heartbeatConnection:Disconnect()
			else
				if lifetime - v3 <= 0.21 and not v2 then
					v2 = true

					if tigerAwakenedXHeadLoop then
						tigerAwakenedXHeadLoop:Stop()
					end

					Util.Anims:Get(clone3, "TigerAwakened_XHeadEnd"):Play()
				end

				if clone3:GetScale() ~= scale then
					clone3:ScaleTo(numberValue.Value)
				end

				local _ = v3 * 4
				primaryPart.CFrame *= CFrame.new(0, 0, -speed * dt)

				if os.clock() - now >= 0.015 then
					now = os.clock()
					local clone4 = tigerEffects.X_Awak.Floor:Clone()
					local ray = Util.Ray
					local v4 = primaryPart.Position + createVector(0, 2, 0)
					local v5 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
					local v6, v7, _ = ray(v4, createVector(-0, -25, -0), v5, false)

					if v6 then
						clone4.CFrame = CFrame.new(v7)
						Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player2, "LeopardFruitVFXColor")
						Util.Debris:AddItem(clone4, 2.8)
						emitAll(clone4)
					end
				end
			end
		end)
		task.spawn(function()
			task.wait(0.3)

			for _, beam in pairs(clone3.beams:GetDescendants()) do
				if beam:IsA("Beam") then
					TweenService:Create(beam, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end
		end)

		repeat
			task.wait()
		until flag

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		if tigerAwakenedXHeadLoop then
			tigerAwakenedXHeadLoop:Stop()
		end

		primaryPart.Position = endPosition

		for _, part in pairs(clone3:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.Transparency = 1
			end
		end

		task.spawn(function()
			for _, beam in pairs(clone3.beams:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = false
				end
			end
		end)
		task.spawn(function()
			local function lerp(p, p2, p3)
				return p + (p2 - p) * p3
			end

			local position = primaryPart.Position
			local v3 = primaryPart.Position + createVector(0, 40, 0)
			local magnitude = (position - v3).magnitude
			local ray, v4, _ = Util.Ray(
				position,
				CFrame.new(position, v3).LookVector.Unit * (magnitude + 8),
				{ workspace.Characters, workspace.Enemies }
			)
			local back = Util.Tween.ease.inout.back

			for i = 1, 3 do
				local v5 = i
				task.spawn(function()
					if 20 % v5 ~= 0 then
						local v6 = CFrame.new(position, v4) * CFrame.new(
							0,
							0,
							-math.random(5, (math.max(14, magnitude)))
						) * CFrame.Angles(1.5707963267948966, 0, 0)
					end

					local v7 = v5 % 2 == 0
					local clone4

					if v7 then
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone4 = FX2:WaitForChild("TigerEffects").X_Awak.SwirlCrescent:Clone()
					elseif v5 % 3 == 0 then
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone4 = FX2:WaitForChild("TigerEffects").X_Awak.WindV2:Clone()
					else
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone4 = FX2:WaitForChild("TigerEffects").X_Awak.WindFragments:Clone()
					end

					Util.Debris:AddItem(clone4, 2)
					local part = clone4.Part
					part.Transparency = 1
					local v8 = false
					local v9 = v5 / 3
					local v10

					if v9 < 0.75 then
						v10 = math.min(1, (v9 / 0.75) ^ 0.8 + 0.2)
					else
						v10 = 1 - (v9 - 0.75) / 0.25
						v8 = true
					end

					local v11 = back(v10, 0.01, 1.59, 1, 11)
					clone4:ScaleTo((math.max(v11, v8 and 2.5 or 0.1)))
					task.spawn(function()
						local v13 = {
							"beam1",
							"beam2",
							"beam3",
							"beam4",
							"beam5",
							"beam6"
						}

						for k, v14 in pairs(v13) do
							TweenService:Create(
								part[v14].Beam,
								TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Width0 = (v14 == "beam3" or v14 == "beam6") and math.random(20, 30) * v11 or 17.6 * v11,
									Width1 = v14 ~= "beam3" and v14 ~= "beam6" and 0 or 6 * v11 or 0
								}
							):Play()
						end

						task.wait(0.05)

						for k, v14 in pairs(v13) do
							TweenService:Create(
								part[v14].Beam,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Width0 = 0,
									Width1 = 0
								}
							):Play()
						end
					end)
					task.spawn(function()
						emitAll(clone4)
						task.wait(0.2)

						for i2, emitter in pairs(clone4:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.LockedToPart = false
							end
						end
					end)
					local cframe = CFrame.Angles(
						math.rad((math.random(0, 360))),
						math.rad((math.random(0, 360))),
						(math.rad((math.random(0, 360))))
					)
					part.CFrame = CFrame.new(v3) * cframe
					local v13 = ({ -1, 1 })[math.random(1, 2)] * 179
					local tween = TweenService:Create(
						part,
						TweenInfo.new(v7 and 0.35 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(5, v7 and 1 or 3, 5),
							Position = position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)),
							Transparency = 1
						}
					)
					local tween2 = TweenService:Create(
						part,
						TweenInfo.new(v7 and 0.1 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1),
						{
							Orientation = part.Orientation + Vector3.new(0, v13, 0)
						}
					)
					tween2.Completed:Connect(function()
						if part then
							tween2 = TweenService:Create(
								part,
								TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									Orientation = part.Orientation + Vector3.new(0, v13, 0)
								}
							)
							tween2:Play()
						end
					end)
					tween.Completed:Connect(function()
						if not ray then
							task.spawn(function()
								for i2, beam in pairs(clone4:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone4:Destroy()
							end)
							return
						end

						local tween3 = TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Transparency = 1,
								CFrame = part.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
									math.rad((math.random(-5, 5))),
									v13,
									(math.rad((math.random(-5, 5))))
								)
							}
						)
						tween3.Completed:Connect(function()
							task.spawn(function()
								for i2, beam in pairs(clone4:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone4:Destroy()
							end)
						end)
						tween3:Play()
					end)
					Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player2, "LeopardFruitVFXColor")
					tween:Play()
					tween2:Play()
				end)
				wait(0.025)
			end
		end)
		task.spawn(function()
			if root.Parent == game.Players.LocalPlayer.Character then
				Util.CameraShaker:ShakeOnce(12, 13, 0.05, 0.6, createVector(1.4, 1.6, 1.6), createVector(0.9, 0.9, 0.9))
				task.spawn(function()
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							FieldOfView = 86
						}
					):Play()
					task.wait(0.1)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
				end)
				task.spawn(function()
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					Util.SetParentOverrideWithColor(
						colorCorrectionEffect,
						game.Lighting,
						player2,
						"LeopardFruitVFXColor"
					)
					Util.Debris:AddItem(colorCorrectionEffect, 1.4)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(169, 70, 202),
								player2,
								"LeopardFruitVFXColor"
							),
							Brightness = -1,
							Saturation = -0.5,
							Contrast = 3
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 121, 26),
								player2,
								"LeopardFruitVFXColor"
							),
							Brightness = 0.4,
							Saturation = 0,
							Contrast = 1
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 255, 255),
								player2,
								"LeopardFruitVFXColor"
							),
							Brightness = 0,
							Saturation = 0,
							Contrast = 0
						}
					):Play()
				end)
			end
		end)
		local ray = Util.Ray
		local v3 = primaryPart.Position + createVector(0, 2, 0)
		local v4 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
		local v5, v6, v7 = ray(v3, createVector(-0, -10, -0), v4, false)

		if v5 ~= nil then
			local cframe = CFrame.new(v6)
			local clone4 = tigerEffects.X_Awak.XFloor:Clone()
			clone4.CFrame = cframe
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player2, "LeopardFruitVFXColor")
			emitAll(clone4)
			Util.Debris:AddItem(clone4, 4.5)
		end

		enableAll(clone3, false)
		local cFrame = primaryPart.CFrame
		Util.Sound:Play("BF_TigerFt_AWK_X_Explode_01", cFrame.Position)
		local clone4 = tigerEffects.X_Awak.Explode:Clone()
		clone4.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone4, folder, player2, "LeopardFruitVFXColor")
		emitAll(clone4)
		Util.Debris:AddItem(clone4, 2)
		task.spawn(function()
			local part = Instance.new("Part")
			part.Name = "BAMPROCK"
			part.CanTouch = false
			part.CanQuery = false
			part.CanCollide = false
			part.Anchored = true
			RockRipple.createRippleEffect(part, v6, 12, 5, 4, 3)
		end)
		local v8 = CFrame.new(v6, v6 + v7) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local random = Random.new()

		for i = 1, 45 do
			local v9 = 6.283185307179586 * (i / 45)
			local v10 = Rock2.new({
				Type = "Ground",
				FadeOut = { 0.25, 0.5 },
				FadeIn = { 0.25, 0.5 },
				Lifetime = { 1, 2.5 },
				Size = Vector3.new(random:NextNumber(1, 2), random:NextNumber(1, 2), random:NextNumber(1, 2)),
				Scale = { 3.75, 7.5 }
			})

			if random:NextInteger(1, 20) % 4 == 0 then
				local unit = Vector3.new(
					math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
					random:NextNumber(0, 1) * 1.25,
					math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
				).Unit
				v10.Type = "Flying"
				v10:Spawn(v8 * CFrame.Angles(0, v9, 0) * CFrame.new(0, 0, -34.199999999999996))
				v10:Eject({
					Velocity = Util.Misc.Physics.Velocity(
						Vector3.new(),
						unit * random:NextNumber(30, 120),
						Vector3.new(0, -workspace.Gravity * random:NextNumber(0.25, 1), 0),
						0.25 + random:NextNumber(0, 2)
					),
					AngularVelocity = Vector3.new(
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1)
					) * 2 * 3.141592653589793 * (1 / v10.Scale)
				})
			else
				v10:Spawn(v8 * CFrame.Angles(0, v9, 0) * CFrame.new(0, 0, -34.199999999999996))
				v10:TweenShift((v8 * CFrame.Angles(0, v9, 0)).LookVector * 15 * random:NextNumber(1, 2), 0.25)
			end
		end
	end
end