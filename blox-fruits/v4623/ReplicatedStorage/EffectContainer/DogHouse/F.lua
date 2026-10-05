local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local F = FX:WaitForChild("DogHouse").F
local sound = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
local rock2 = Util.Rock2
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local superhumanV2Travel = Effect.new("SuperhumanV2.Travel")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function charInRange(p, p2)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cameraInRange(p, p2)
	return (workspace.CurrentCamera.CFrame.p - p).Magnitude < p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ringMesh(cFrame, p)
	task.spawn(function()
		local clone = F.FireRing:Clone()
		debris:AddItem(clone, 5)
		clone.Size = createVector(1, 0.4, 1)
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, p, "DragonFruitVFXColor")
		local lastTime = tick()
		local v = 0.016666666666666666

		while tick() - lastTime < 0.3333333333333333 do
			local v2 = v * 60
			local v3 = (tick() - lastTime) / 0.3333333333333333 * 60
			clone.CFrame *= CFrame.Angles(0, math.rad(v2 * 35), 0)
			local v4 = v3 / 60
			clone.Size = createVector(1, 10, 1) + createVector(29, -8, 29) * v4
			clone.Transparency = 0 + 1 * (v3 / 60)
			v = RunService.RenderStepped:Wait()
		end

		if clone then
			clone:Destroy()
		end
	end)
end

local function AlignCFrame(data, norm)
	local v = not (norm and norm.Magnitude > 0 and norm) and createVector(0, 1, 0) or norm
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local function throwDart(cframe, magnitude, flightDuration, player)
	local cframe2 = CFrame.Angles(1.5707963267948966, 0, 0)
	local clone = F.ThrowCones:Clone()
	Util.Debris:AddItem(clone, 2)

	if not clone.PrimaryPart then
		clone.PrimaryPart = clone:FindFirstChild("Cone")
	end

	clone:SetPrimaryPartCFrame(cframe * cframe2)
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "DragonFruitVFXColor")

	for i, child in pairs(clone:GetChildren()) do
		local tween = TweenService:Create(
			child,
			TweenInfo.new(flightDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = child.CFrame * CFrame.new(0, -magnitude, 0)
			}
		)
		local v = child
		tween.Completed:Connect(function()
			if v then
				v:Destroy()
			end
		end)
		tween:Play()

		for i2, child2 in pairs(child:GetChildren()) do
			if child2.Name == "Mesh" then
				local tween2 = TweenService:Create(
					child2,
					TweenInfo.new(flightDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Scale = Vector3.new(child2.Scale.X - 1, 5, child2.Scale.Z - 1)
					}
				)
				local v2 = child
				tween2.Completed:Connect(function()
					if v2 then
						v2:Destroy()
					end
				end)
				tween2:Play()
			elseif child2.Name == "Decal" then
				local tween2 = TweenService:Create(
					child2,
					TweenInfo.new(flightDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 1
					}
				)
				local v2 = child
				tween2.Completed:Connect(function()
					if v2 then
						v2:Destroy()
					end
				end)
				tween2:Play()
			end
		end
	end
end

local function ExplosionFlameRocks(cFrame, _WorldOrigin2, player)
	for i = 1, 10 do
		local clone = F.ExplosionTrail:Clone()
		clone.Position = cFrame.Position + Vector3.new(math.random(-25, 25), math.random(1, 15), math.random(-25, 25))
		Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "DragonFruitVFXColor")
		clone.Anchored = false
		clone.CanCollide = true
		rocks:ApplyCollision(clone, nil, true)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
		bodyVelocity.P = 1600
		Util.SetParentOverrideWithColor(bodyVelocity, clone, player, "DragonFruitVFXColor")
		bodyVelocity.Velocity = CFrame.new(
			clone.Position,
			(CFrame.new(clone.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
				0,
				0,
				-30
			)).Position + Vector3.new(math.random(-10, 10) / 4, math.random(80, 250), math.random(-10, 10) / 4)
		).LookVector * math.random(50, 225) * 1.15
		task.delay(0.1, function()
			bodyVelocity:Destroy()
		end)

		for i2, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
			elseif effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		local folder = clone
		task.spawn(function()
			task.wait(1.75 + math.random() * 1.25)

			for i2, effect in pairs(folder:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				elseif effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			task.wait(3)
			folder:Destroy()
		end)
	end
end

local function TornadoSlash(folder, data, player)
	local multiplier = data.Multiplier
	local multiplier2 = data.Multiplier2
	local mutliplier2Time = data.Mutliplier2Time
	local beamOutTime = data.BeamOutTime
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local slashType = data.SlashType
	local slashCFrame = data.SlashCFrame
	local slashSpeed = data.SlashSpeed
	local slashSpeed2 = data.SlashSpeed2
	local spinIterations = data.SpinIterations
	local clone = slashType:Clone()
	clone.CFrame = slashCFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")

	for i, descendant in pairs(clone:GetDescendants()) do
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

	for i, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.Enabled = true
			local v = descendant
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						CurveSize0 = v.CurveSize0 * multiplier2,
						CurveSize1 = v.CurveSize1 * multiplier2,
						Width0 = v.Width0 * multiplier2,
						Width1 = v.Width1 * multiplier2
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				tween:Play()
			end)
		elseif descendant:IsA("Attachment") then
			print(mutliplier2Time)
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

	for i = 1, spinIterations do
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

	for i, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v = beam
		task.spawn(function()
			local tween = TweenService:Create(
				v,
				TweenInfo.new(beamOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = 0
				}
			)
			tween:Play()
			tween.Completed:Wait()
			v:Destroy()
		end)
	end

	TweenService:Create(clone, TweenInfo.new(slashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * slashAngle2
	}):Play()
end

local function ScaleParticle(state, p)
	local keypoints = state.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	state.Size = NumberSequence.new(numberSequenceKeypoints)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Acceleration *= p
end

local function ScreenEffect(_WorldOrigin2, duration, player)
	local clone = F.Extra.ScreenColorDX:Clone()
	Util.SetParentOverrideWithColor(clone, game.Lighting, player, "DragonFruitVFXColor")
	clone:SetAttribute("UsedTimes", clone:GetAttribute("UsedTimes") + 1)
	TweenService:Create(clone, TweenInfo.new(0.15), {
		Brightness = -0.015,
		Contrast = 0.15,
		Saturation = 0.15,
		TintColor = Util.WrapColor3ConstructorForTintColor(Color3.fromRGB(231, 185, 159), player, "DragonFruitVFXColor")
	}):Play()
	local currentCamera = workspace.CurrentCamera
	local clone2 = F.Extra.CameraFocus:Clone()
	Util.SetParentOverrideWithColor(clone2, _WorldOrigin2, player, "DragonFruitVFXColor")
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone2.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
	end)

	for i, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if emitter.Parent == clone2.Aura1 then
			emitter.Enabled = true
			local v = emitter
			task.delay(0.9, function()
				v.Enabled = false
			end)
		elseif emitter.Parent == clone2.Aura3 then
			local v = emitter
			task.delay(0.9, function()
				v.Enabled = true
			end)
		end
	end

	task.spawn(function()
		task.wait(duration - 0.9)

		for i, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(1.5)
		renderSteppedConnection:Disconnect()
		clone2:Destroy()
	end)
	task.wait(duration)
	local tween = TweenService:Create(clone, TweenInfo.new(1.5), {
		TintColor = Util.WrapColor3ConstructorForTintColor(Color3.fromRGB(255, 255, 255), player, "DragonFruitVFXColor"),
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	})
	tween:Play()
	tween.Completed:Wait()
	clone:Destroy()
end

Util.ResizeModel(F.StartImpact, 0.6)
Util.ResizeModel(F.StartImpactH, 0.925)
Util.ResizeModel(F.HoldAuraH, 1.375)
local clone = F.GrabPrime:Clone()
Util.ResizeModel(clone, 1.75)
return function(player)
	local player2 = player.player
	local ID = player.ID

	if ID == 1 then
		local character = player.Character
		local holdValue = player.HoldValue
		local chargeTime = player.ChargeTime or 0

		if character and holdValue then
			local humanoid = character:FindFirstChild("Humanoid")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoidRootPart then
				if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 500 then
					return
				end

				Util.Sound:Play("BF_V3_Dragon_X_Charge_01", humanoidRootPart)
				local v = Util.Sound:Play("BF_V3_Dragon_X_Hold_02", humanoidRootPart)
				TweenService:Create(v, TweenInfo.new(0.5), {
					Volume = 1
				}):Play()
				local clone2 = (humanoid.Parent:FindFirstChild("DragonHybrid") and clone or F.GrabPrime).Charge:Clone()
				Util.SetParentOverrideWithColor(clone2, humanoidRootPart, player2, "DragonFruitVFXColor")
				local diedConnection = nil
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
					diedConnection = nil
				end)
				local lastTime = tick()

				local function running()
					return tick() - lastTime < chargeTime or diedConnection and holdValue and holdValue.Value == true
				end

				local clone3 = nil

				if humanoid.Parent:FindFirstChild("DragonHybrid") then
					local clone4 = F.StartImpactH:Clone()
					debris:AddItem(clone4, 3)
					clone4.CFrame = humanoidRootPart.CFrame
					Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player2, "DragonFruitVFXColor")

					for i, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit((math.ceil(emitter:GetAttribute("EmitCount") * 0.7)))
						end
					end

					clone3 = F.HoldAuraH:Clone()
					clone3.CFrame = humanoidRootPart.CFrame
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player2, "DragonFruitVFXColor")

					for i, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				else
					local clone4 = F.StartImpact:Clone()
					debris:AddItem(clone4, 3)
					clone4.CFrame = humanoidRootPart.CFrame
					Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player2, "DragonFruitVFXColor")

					for i, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit((math.ceil(emitter:GetAttribute("EmitCount") * 0.7)))
						end
					end
				end

				local now = tick() - 1

				while (tick() - lastTime < chargeTime or diedConnection and holdValue and holdValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and humanoid and character do
					if tick() - now > 0.08 then
						for i, emitter in pairs(clone2:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						now = tick()
					end

					if clone3 then
						clone3.CFrame = humanoidRootPart.CFrame
					end

					RunService.RenderStepped:Wait()
				end

				task.wait(0.1)

				if v then
					sound:FadeOut(v, 0.1)
				end

				if clone3 then
					for i, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				Util.Debris:AddItem(clone2, 3)

				if diedConnection then
					diedConnection:Disconnect()
					diedConnection = nil
				end
			end
		end
	elseif ID == 2 then
		local character = player.Character
		local time = player.Time
		local look = player.Look
		local duration = player.Duration
		local v = look - look.p

		if character then
			if (look.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				Util.Sound:Play("BF_V3_Dragon_X_Release_01", humanoidRootPart)
			end

			humanoidRootPart.CFrame = look
			local folder = Instance.new("Folder")
			folder.Name = "DragonXDashStarted"
			Util.SetParentOverrideWithColor(folder, character, player2, "DragonFruitVFXColor")
			debris:AddItem(folder, 5)
			local position = humanoidRootPart.Position
			local v2 = Util.BodyMover.new(character):Create("BodyVelocity", {
				Priority = 10,
				Duration = duration + 1,
				Velocity = createVector(0, 0, 0)
			})
			local v3 = Util.BodyMover.new(character):Create("BodyGyro", {
				Priority = 10,
				Duration = duration + 1,
				CFrame = look
			})
			local v4 = duration - (time - workspace:GetServerTimeNow())
			local v5 = duration * player.DashSpeed / v4
			superhumanV2Travel:replicate({
				Root = humanoidRootPart,
				IgnoreParticles = true,
				IgnoreTrail = true,
				Color = Util.WrapColor3Constructor(Color3.new(1, 0.470588, 0.0901961), player2, "DragonFruitVFXColor"),
				ForceRockSpawn = true,
				NoFlyingRocks = true,
				Burnt = 0.05,
				Scale = 4,
				Duration = duration,
				FadeInMod = 0.1
			})
			local clone2 = F.DashTrail:Clone()
			debris:AddItem(clone2, duration + 1)
			clone2.CFrame = humanoidRootPart.CFrame
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "DragonFruitVFXColor")
			clone2.RightTrail.Enabled = true
			clone2.LeftTrail.Enabled = true
			local clone3 = F.Dash:Clone()
			debris:AddItem(clone3, duration + 3)
			clone3.CFrame = humanoidRootPart.CFrame
			Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player2, "DragonFruitVFXColor")
			clone3.Anchored = false
			clone3.Weld.Part0 = humanoidRootPart

			for i, effect in pairs(clone3:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			local clone4 = F.Floor:Clone()
			Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player2, "DragonFruitVFXColor")
			local descendants = clone4:GetDescendants()

			for k, emitter in pairs(descendants) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			humanoidRootPart.Anchored = true
			local position2 = humanoidRootPart.Position
			task.spawn(function()
				local lastTime = tick()
				local lastTime2 = tick()
				local lastTime3 = tick()
				local now = tick()
				local lastTime4 = os.clock()
				local v6 = 0.016666666666666666
				local v7 = false

				while os.clock() - lastTime4 < v4 do
					if humanoidRootPart then
						local lookVector = look.LookVector
						local ray, v8, v9 = Util.Ray(
							position2,
							look.LookVector * v5 * v6 + lookVector,
							{ workspace.Characters, workspace.Enemies }
						)
						local v10 = v8 - lookVector

						if v7 then
							local ray2, v11 = Util.Ray(
								position2 - v7 * player.Height,
								v7 * player.Height,
								{ workspace.Characters, workspace.Enemies }
							)
							_ = ray2
							position2 = v11
							v10 = position2
							v7 = false
						elseif ray then
							look = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), look.LookVector), v9)
							v = look - look.p
							v10 += v9 * player.Height
							v7 = v9
						end

						position2 = v10

						if not humanoidRootPart:GetAttribute("CFrameGrab") then
							humanoidRootPart.CFrame = CFrame.new(v10) * v
						end

						clone2.CFrame = humanoidRootPart.CFrame

						if tick() - lastTime > 0.05 then
							if clone2 and clone2:FindFirstChild("LinesDark") then
								for k, v11 in pairs({ clone2.LinesDark, clone2.LinesColor }) do
									v11:Emit(v11:GetAttribute("EmitCount"))
								end
							end

							lastTime = tick()
						end

						if tick() - lastTime2 > 0.08 then
							if character == game.Players.LocalPlayer.Character then
								Util.CameraShaker:ShakeOnce(1.2, 8, 0.3, 0.3)
							end

							if clone2 and clone2:FindFirstChild("Center") then
								for i, child in pairs(clone2.Center:GetChildren()) do
									child:Emit(child:GetAttribute("EmitCount"))
								end
							end

							ringMesh(
								CFrame.new(humanoidRootPart.Position) * v * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
									0,
									math.rad((math.random(0, 360))),
									0
								),
								player2
							) -- equivalent call inferred; original call site unknown
							lastTime2 = tick()
						end

						if tick() - lastTime3 > 0.03 then
							local ray2, v11, v12 = Util.Ray(
								humanoidRootPart.Position,
								createVector(0, 1, 0) * -humanoidRootPart.Size.Y * 3,
								{ workspace.Characters, workspace.Enemies }
							)

							if ray2 then
								clone4.CFrame = CFrame.new(v11 + v12 * 0.5, v11 + v12) * CFrame.Angles(
									1.5707963267948966,
									0,
									0
								)

								for k, emitter in pairs(descendants) do
									if emitter:IsA("ParticleEmitter") then
										emitter:Emit(1)
									end
								end

								if now - tick() <= 0 then
									now = tick() + 0.03
									local clone5 = F.Extra.DashGroundBurn:Clone()
									clone5.CFrame = CFrame.new(v11 + v12 * 0.5, v11 + v12) * CFrame.Angles(
										1.5707963267948966,
										0,
										0
									)
									clone5.CFrame *= CFrame.new(math.random(-10, 10), 0, 0)
									clone5.Size += Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
									Util.SetParentOverrideWithColor(
										clone5,
										_WorldOrigin,
										player2,
										"DragonFruitVFXColor"
									)
									local folder2 = clone5
									task.spawn(function()
										for i, emitter in pairs(folder2:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") then
												emitter.Enabled = true
											end
										end

										task.wait(0.5 + math.random(-3, 3) / 10)

										for i, emitter in pairs(folder2:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") then
												emitter.Enabled = false
											end
										end

										task.wait(1)
										folder2:Destroy()
									end)
								end
							end

							lastTime3 = tick()
						end
					end

					v6 = RunService.PreSimulation:Wait()

					if character:FindFirstChild("DragonXDashGrabbed") then
						break
					end
				end

				humanoidRootPart.Anchored = false

				if v3 then
					v3:Destroy()
				end

				if v2 then
					v2:Destroy()
				end

				task.delay(2, function()
					clone4:Destroy()
				end)
				clone3.Weld.Enabled = false
				clone3.Anchored = true

				for i, effect in pairs(clone3:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				local v8 = {
					LeftTrail = true,
					RightTrail = true,
					BottomBeam = true,
					LeftBeam = true,
					RightBeam = true,
					TopBeam = true
				}

				if clone2 then
					local lastTime5 = tick()

					while tick() - lastTime5 < 0.3333333333333333 do
						local v9 = (tick() - lastTime5) / 0.3333333333333333

						if not clone2 then
							break
						end

						for i, child in pairs(clone2:GetChildren()) do
							if v8[child.Name] then
								child.Transparency = NumberSequence.new(v9)
							end
						end

						RunService.RenderStepped:Wait()
					end

					for i, child in pairs(clone2:GetChildren()) do
						if v8[child.Name] then
							child.Enabled = false
						end
					end
				end

				task.delay(1, function()
					if clone2 then
						clone2:Destroy()
					end
				end)

				if character:FindFirstChild("DragonXDashGrabbed") then
					character:FindFirstChild("DragonXDashGrabbed"):Destroy()
				end

				if v3 then
					v3:Destroy()
				end

				if v2 then
					v2:Set(createVector(0, 0, 0))
					task.wait()
					v2:Destroy()
				end
			end)
		end
	elseif ID == 3 then
		local character = player.Character
		local humanoidRootPart = character.HumanoidRootPart

		if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
			return
		end

		local victimCharacter = player.VictimCharacter
		local time = player.Time
		local cFrame = humanoidRootPart.CFrame
		local duration = player.Duration
		local throwDelay = player.ThrowDelay
		local caughtPos = player.CaughtPos
		local userLook = player.UserLook
		local userMouse = player.UserMouse
		local v = cFrame - cFrame.p
		local duration2 = math.max(0.016666666666666666, duration - (workspace:GetServerTimeNow() - time))

		if character and victimCharacter then
			local folder = Instance.new("Folder")
			folder.Name = "DragonXDashGrabbed"
			Util.SetParentOverrideWithColor(folder, character, player2, "DragonFruitVFXColor")
			debris:AddItem(folder, 5)
			local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")
			local rightHand = character:FindFirstChild("RightHand")
			local humanoidRootPart3 = victimCharacter:FindFirstChild("HumanoidRootPart")
			local humanoid2 = victimCharacter:FindFirstChild("Humanoid")
			local v3 = math.min(9, humanoidRootPart2.Size.Y * 0.5 + humanoid.HipHeight) + 1

			if humanoidRootPart2 and humanoid and humanoidRootPart3 and humanoid2 then
				humanoidRootPart2.CFrame = CFrame.new(humanoidRootPart2.Position) * v
				local play = Util.Sound:Play("BuddhaGrab", humanoidRootPart3.Position, nil, 2, 1)
				play.TimePosition = 0.2
				Util.BodyMover.new(character):Create("BodyVelocity", {
					Priority = 12,
					Duration = duration2,
					Velocity = createVector(0, 0, 0)
				})
				local v4 = Util.BodyMover.new(character):Create("BodyGyro", {
					Priority = 12,
					Duration = duration2,
					CFrame = cFrame
				})
				local ray, v5, v6 = Util.Ray(
					humanoidRootPart2.Position,
					createVector(0, 1, 0) * -v3,
					{ workspace.Characters, workspace.Enemies },
					false
				)
				local clone2 = F.GrabDrag:Clone()
				debris:AddItem(clone2, duration2 + 5)
				clone2.CFrame = CFrame.new(v5) * v
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "DragonFruitVFXColor")
				local clone3 = F.DashTrail:Clone()
				debris:AddItem(clone3, duration2 + 3)
				clone3.CFrame = humanoidRootPart2.CFrame
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player2, "DragonFruitVFXColor")
				clone3.RightTrail.Enabled = true
				clone3.LeftTrail.Enabled = true
				local clone4 = F.Dash:Clone()
				debris:AddItem(clone4, duration2 + 3)
				clone4.CFrame = humanoidRootPart2.CFrame
				Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player2, "DragonFruitVFXColor")
				clone4.Anchored = false
				clone4.Weld.Part0 = humanoidRootPart2
				local clone5 = F.GroundImpact:Clone()
				debris:AddItem(clone5, duration2 + 3)
				clone5.Size *= createVector(0.5, 1, 1)
				clone5.CFrame = humanoidRootPart2.CFrame
				Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player2, "DragonFruitVFXColor")
				local lastTime = tick()

				for i, effect in pairs(clone4:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				local v7 = {
					[clone2.LeftDust] = { tick() - 0.06, 0.06 },
					[clone2.RightDust] = { tick() - 0.06, 0.06 },
					[clone2.Drag] = { tick() - 0.1, 0.1 }
				}
				superhumanV2Travel:replicate({
					Root = humanoidRootPart3,
					Color = Util.WrapColor3Constructor(
						Color3.new(1, 0.470588, 0.0901961),
						player2,
						"DragonFruitVFXColor"
					),
					IgnoreParticles = true,
					ForceRockSpawn = true,
					ForceFlyingRocks = true,
					Burnt = 0.05,
					Scale = 2,
					Duration = duration2
				})
				superhumanV2Travel:replicate({
					Root = humanoidRootPart3,
					Color = Util.WrapColor3Constructor(Color3.new(0, 0, 0), player2, "DragonFruitVFXColor"),
					IgnoreParticles = true,
					ForceRockSpawn = true,
					Burnt = 0.05,
					Scale = 4,
					Duration = duration2,
					FadeInMod = 0.1
				})
				Util.Sound:Play("BF_V3_Dragon_X_TargetHit_02", humanoidRootPart2)
				local cframe = CFrame.new(humanoidRootPart2.Position, userMouse.Value)
				local v8 = cframe.LookVector:Dot(humanoidRootPart2.CFrame.LookVector) < 0
				local ray2, v9, v10 = Util.Ray(
					humanoidRootPart2.Position,
					createVector(0, 1, 0) * -v3,
					{ workspace.Characters, workspace.Enemies },
					false
				)
				local v11

				if ray2 then
					cframe = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), cframe.LookVector), v10)
					v11 = 1
				else
					v11 = 2
				end

				local clone6 = F.Floor:Clone()
				Util.SetParentOverrideWithColor(clone6, _WorldOrigin, player2, "DragonFruitVFXColor")
				local descendants = clone6:GetDescendants()

				for k, emitter in pairs(descendants) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.spawn(function()
					if game.Players.LocalPlayer.Character == victimCharacter or game.Players.LocalPlayer.Character == character then
						ScreenEffect(_WorldOrigin, 2.25, player2)
					end
				end)

				if humanoidRootPart3 == game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and not humanoidRootPart3.Parent:FindFirstChild("AntiMover") then
					humanoidRootPart3.Anchored = true
				end

				local lastTime2 = tick()
				local lastTime3 = tick()
				local lastTime4 = tick()
				local lastTime5 = tick()
				local v12 = 0.016666666666666666

				while tick() - lastTime3 < duration2 and character and victimCharacter and humanoidRootPart2 and rightHand and humanoidRootPart3 and not humanoidRootPart3:FindFirstChild("ThrowCompleted") and not (humanoid.Health <= 0) and humanoid2 and not (humanoid2.Health <= 0) do
					local v13 = (1 - 0.333 * (tick() - lastTime3) / duration2) ^ 1.333
					local cframe2 = CFrame.new(humanoidRootPart2.Position, userMouse.Value)
					local v14 = cframe2.LookVector:Dot(humanoidRootPart2.CFrame.LookVector) < 0
					local ray3, v15, v16 = Util.Ray(
						humanoidRootPart2.Position,
						createVector(0, 1, 0) * -v3,
						{ workspace.Characters, workspace.Enemies },
						false
					)
					local v17

					if ray3 then
						local alignCFrame = Util.Misc.AlignCFrame(
							CFrame.new(createVector(0, 0, 0), cframe2.LookVector),
							v16
						)

						if v11 == 1 then
							cframe = cframe:Lerp(alignCFrame, v12 * 3)
						else
							cframe = alignCFrame
						end

						v17 = cframe - cframe.p
						v11 = 1
					else
						if v11 == 2 then
							cframe = cframe:Lerp(cframe2, v12 * 3)
						else
							cframe = cframe2
						end

						v17 = cframe - cframe.p
						v11 = 2
					end

					local ray4, v18, v19 = Util.Ray(
						humanoidRootPart2.Position,
						cframe.LookVector * (5 + humanoidRootPart2.Size.Z + humanoidRootPart2.Velocity.Magnitude * v12 * 1.5),
						{ workspace.Characters, workspace.Enemies }
					)

					if ray4 then
						cframe = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), cframe.LookVector), v19)
						v17 = cframe - cframe.p
						v4:Set(cframe)
					end

					local v20 = cframe.LookVector * 0.1
					local ray5, v21 = Util.Ray(
						humanoidRootPart2.Position - v20,
						cframe.LookVector * v12 * player.DashSpeed + v20,
						{ workspace.Characters, workspace.Enemies }
					)

					if not (humanoidRootPart2:GetAttribute("CFrameGrab") or humanoidRootPart3:GetAttribute("CFrameGrab")) then
						humanoidRootPart2.CFrame = CFrame.new(v21) * v17

						if not humanoidRootPart3.Parent:FindFirstChild("AntiMover") then
							humanoidRootPart3.CFrame = rightHand.CFrame * CFrame.new(0, -1, -1) * CFrame.Angles(
								1.5707963267948966,
								0,
								0
							)
						end
					end

					clone3.CFrame = humanoidRootPart2.CFrame

					if tick() - lastTime4 > 0.05 then
						if clone3 then
							for k, v22 in pairs({ clone3.LinesDark, clone3.LinesColor, clone3.LinesLight }) do
								v22:Emit(v22:GetAttribute("EmitCount"))
							end

							if player.Hybrid then
								for i, child in pairs(clone3.Center2:GetChildren()) do
									child:Emit(child:GetAttribute("EmitCount"))
								end
							end
						end

						lastTime4 = tick()
					end

					if tick() - lastTime5 > 0.08 then
						if character == game.Players.LocalPlayer.Character then
							Util.CameraShaker:ShakeOnce(1.2, 12, 0.4, 0.4)
						end

						if clone3 then
							for i, child in pairs(clone3.Center:GetChildren()) do
								child:Emit(child:GetAttribute("EmitCount"))
							end
						end

						ringMesh(
							CFrame.new(humanoidRootPart2.Position) * v17 * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
								0,
								math.rad((math.random(0, 360))),
								0
							),
							player2
						) -- equivalent call inferred; original call site unknown
						lastTime5 = tick()
					end

					local ray6, v22, v23 = Util.Ray(
						humanoidRootPart2.Position,
						createVector(0, 1, 0) * -v3,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if ray6 then
						if tick() - lastTime >= 0.05 then
							lastTime = tick()
							clone5.CFrame = CFrame.new(v22) * v17

							for i, emitter in pairs(clone5:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit((math.min(1, emitter:GetAttribute("EmitCount") * 0.666)))
								end
							end
						end

						if clone2 then
							clone2.CFrame = CFrame.new(v22) * v17

							for i, attachment in pairs(clone2:GetChildren()) do
								if not (attachment:IsA("Attachment") and tick() - v7[attachment][1] > v7[attachment][2]) then
									continue
								end

								for i2, child in pairs(attachment:GetChildren()) do
									if child:isA("ParticleEmitter") then
										child:Emit(child:GetAttribute("EmitCount"))
									end
								end

								v7[attachment][1] = tick()
							end
						end

						if tick() - lastTime2 > 0.03 then
							clone6.CFrame = CFrame.new(v22 + v23 * 0.5, v22 + v23) * CFrame.Angles(
								1.5707963267948966,
								0,
								0
							)

							for k, emitter in pairs(descendants) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(1)
								end
							end

							lastTime2 = tick()
						end
					end

					v12 = RunService.PreSimulation:Wait()
				end

				task.delay(2, function()
					clone6:Destroy()
				end)
				clone4.Weld.Enabled = false
				clone4.Anchored = true

				for i, effect in pairs(clone4:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				if clone3 then
					local v13 = {
						BottomBeam = true,
						LeftBeam = true,
						RightBeam = true,
						TopBeam = true
					}

					for i, child in pairs(clone3:GetChildren()) do
						if v13[child.Name] then
							child.Enabled = false
						end
					end
				end

				task.delay(1, function()
					if clone2 then
						clone2:Destroy()
					end

					if clone3 then
						clone3:Destroy()
					end
				end)

				if character and humanoidRootPart2 then
					local ray3, v13 = Util.Ray(
						humanoidRootPart2.Position,
						humanoidRootPart2.CFrame.LookVector * 50 + createVector(0, 25, 0),
						{ workspace.Enemies, workspace.Characters }
					)
					local clone7 = F.Jump:Clone()
					debris:AddItem(clone7, duration2 + 3)
					clone7.CFrame = CFrame.new(humanoidRootPart2.Position, v13)
					Util.SetParentOverrideWithColor(clone7, _WorldOrigin, player2, "DragonFruitVFXColor")

					for i, emitter in pairs(clone7:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					local v14 = Util.BodyMover.new(character):Create("BodyGyro", {
						Priority = 10,
						CFrame = cframe
					})
					local v15 = Util.BodyMover.new(character):Create("BodyPosition", {
						Priority = -10,
						Position = humanoidRootPart2.Position
					})

					if rightHand then
						local clone8 = F.GrabPrime.Charge:Clone()
						debris:AddItem(clone8, throwDelay + 1)
						Util.SetParentOverrideWithColor(clone8, rightHand, player2, "DragonFruitVFXColor")
						clone8.Lines.Size = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 36, 0),
							NumberSequenceKeypoint.new(1, 0, 0)
						})
						clone8.Lines.Brightness = 15
						clone8.Lines.Lifetime = NumberRange.new(0.15)
						task.delay(throwDelay / 2, function()
							Util.Sound:Play("Engulf", humanoidRootPart2, nil, 1.5, 0.3)
						end)
						local position = humanoidRootPart2.Position
						tick()
						local lastTime6 = tick()
						local cFrame2 = humanoidRootPart2.CFrame

						if humanoidRootPart3 == game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and not humanoidRootPart3.Parent:FindFirstChild("AntiMover") then
							humanoidRootPart3.Anchored = true
						end

						tick()

						while tick() - lastTime6 < throwDelay + 0.5 and character.Parent and victimCharacter.Parent and userLook and humanoidRootPart2 and rightHand and humanoidRootPart3 and not humanoidRootPart3:FindFirstChild("ThrowCompleted") and not (humanoid.Health <= 0) and humanoid2 and not (humanoid2.Health <= 0) do
							local v16 = math.clamp(((tick() - lastTime6) / throwDelay) ^ 0.25, 0, 1)

							if not (humanoidRootPart2:GetAttribute("CFrameGrab") or humanoidRootPart3:GetAttribute("CFrameGrab")) then
								humanoidRootPart2.CFrame = CFrame.new(position:Lerp(v13, v16)) * (humanoidRootPart2.CFrame - humanoidRootPart2.Position)
								v15:Set(position:Lerp(v13, v16))

								if v14 then
									v14:Set(cFrame2:Lerp(CFrame.new(v13, userMouse.Value), v16))
								end

								if not humanoidRootPart3.Parent:FindFirstChild("AntiMover") then
									humanoidRootPart3.CFrame = rightHand.CFrame * CFrame.new(0, -1, -1) * CFrame.Angles(
										1.5707963267948966,
										0,
										0
									)
								end
							end

							RunService.PreSimulation:Wait()
						end

						if humanoidRootPart3 == game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
							humanoidRootPart3.Anchored = false
						end

						v15:Set(v13)
						v14:Set(CFrame.new(v13, v13 + userLook.Value.LookVector))
						task.delay(1, function()
							if clone8 then
								clone8:Destroy()
							end
						end)
						task.wait(0.2)
					end

					if v14 then
						v14:Destroy()
					end

					if v15 then
						v15:Destroy()
					end
				end
			end
		end
	elseif ID == 4 then
		local hit = player.Hit
		local pos = player.Pos
		local norm = player.Norm
		local origin = player.Origin
		local root = player.Root

		if cameraInRange(pos, 800) then
			local folder = Instance.new("Folder")
			folder.Name = "ThrowCompleted"
			Util.SetParentOverrideWithColor(folder, root, player2, "DragonFruitVFXColor")
			task.delay(0.5, function()
				folder:Destroy()
			end)
			TweenService:Create(root, TweenInfo.new(player.FlightDuration), {
				CFrame = CFrame.new(pos, origin) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			local flightDuration = player.FlightDuration
			local cframe = CFrame.new(origin, pos)
			throwDart(cframe, (origin - pos).Magnitude, flightDuration, player2)
			task.spawn(function()
				local clone2 = F.ThrowImpact:Clone()
				debris:AddItem(clone2, 3)
				clone2.CFrame = cframe * CFrame.new(0, 0, -3)
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "DragonFruitVFXColor")

				for i, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)

			if (player.Player == game.Players.LocalPlayer or cameraInRange(pos, 200)) and player.Player == game.Players.LocalPlayer then
				Effect.new("ColorCorrection"):replicate({
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player2,
						"DragonFruitVFXColor"
					),
					Brightness = -1,
					Saturation = -1,
					Contrast = 6,
					FadeIn = 0,
					FadeOut = 0.3332,
					Lifetime = 0.1666
				})
			end

			task.spawn(function()
				local magnitude = (origin - pos).Magnitude
				local clone2 = F.ThrownBodyParticles:Clone()
				Util.ResizeModel(clone2, 1.75)
				debris:AddItem(clone2, 3)
				clone2.CFrame = CFrame.new(origin, pos)
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "DragonFruitVFXColor")
				local lastTime = tick()
				local lastTime2 = tick()

				while tick() - lastTime2 < flightDuration do
					local origin2 = origin
					local v3 = (tick() - lastTime2) / flightDuration
					clone2.Position = origin2 + (pos - origin2) * v3

					if tick() - lastTime > 0.016666666666666666 then
						for i, child in pairs(clone2.Attachment:GetChildren()) do
							child:Emit(child:GetAttribute("EmitCount"))
						end

						if player.Hybrid then
							for i, child in pairs(clone2.Attachment2:GetChildren()) do
								child:Emit(child:GetAttribute("EmitCount"))
							end
						end

						lastTime = tick()
					end

					RunService.RenderStepped:Wait()
				end

				for i, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					elseif effect:IsA("Beam") then
						effect.Enabled = false
					end
				end

				task.delay(2, function()
					if clone2 then
						clone2:Destroy()
					end
				end)
			end)

			if player.Player == game.Players.LocalPlayer or cameraInRange(pos, 120) then
				Util.CameraShaker:ShakeOnce(3, 12, 0.01, 0.5)
			end

			if hit == nil then
				if root then
					local clone2 = F.Firecracker:Clone()
					clone2.Position = pos
					Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "DragonFruitVFXColor")
					debris:AddItem(clone2, 2)
					local clone3 = F.AirExplosion:Clone()
					debris:AddItem(clone3, 3)
					clone3.Position = pos
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player2, "DragonFruitVFXColor")

					for i, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							Util.Misc.ScaleParticle(emitter, player.Hybrid and 1.6 or 1.1)
						end
					end

					for i = 1, player.Hybrid and 8 or 5 do
						if i % 2 == 1 then
							local v2 = Util.Sound:Play("BF_V3_Dragon_X_Explosion_03", pos)
							task.spawn(function()
								task.wait(0.5)
								Util.Sound:FadeOut(v2, 0.75)
							end)
						end

						if not (root and clone2) then
							break
						end

						local clone4 = clone2.Attach:Clone()
						Util.SetParentOverrideWithColor(clone4, clone2, player2, "DragonFruitVFXColor")

						for i2 = 1, 2 do
							local v = math.random(0, 360)
							local clone5 = clone2.Glint:Clone()
							Util.SetParentOverrideWithColor(clone5, clone2, player2, "DragonFruitVFXColor")
							clone5.WorldPosition = pos + Vector3.new(
								math.random(-15, 15),
								math.random(-15, 15),
								math.random(-15, 15)
							) * 1.33 * (player.Hybrid and 1.5 or 1)

							for i3, child in pairs(clone5:GetChildren()) do
								Util.Misc.ScaleParticle(child, 1.1)
								child.Rotation = NumberRange.new(v)
								child:Emit(child:GetAttribute("EmitCount"))
							end
						end

						clone4.WorldPosition = pos + Vector3.new(
							math.random(-25, 25),
							math.random(-25, 25),
							math.random(-25, 25)
						) * 1.33 * (player.Hybrid and 1.5 or 1)

						for i2, child in pairs(clone4:GetChildren()) do
							child:Emit(child:GetAttribute("EmitCount"))
						end

						task.spawn(function()
							for i2 = 1, 2 do
								clone3.Position = pos + Vector3.new(
									math.random(-25, 25),
									math.random(-25, 25),
									math.random(-25, 25)
								) * 1.33 * (player.Hybrid and 1.5 or 1)

								for i3, emitter in pairs(clone3:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") and (player.Hybrid or emitter.Name ~= "Lightning") then
										emitter:Emit(emitter:GetAttribute("EmitCount"))
									end
								end

								task.wait(0.025)
							end
						end)

						if player.Player == game.Players.LocalPlayer or cameraInRange(pos, 180) then
							Util.CameraShaker:ShakeOnce(4.8, 24, 0.1, 1)
						end

						task.wait(0.05)
					end
				end
			else
				task.spawn(function()
					local clone2 = F.Extra.ExplosionStartImpact:Clone()
					debris:AddItem(clone2, 3)
					clone2.CFrame = CFrame.new(pos) * CFrame.new(0, 5, 0)
					Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "DragonFruitVFXColor")

					for i, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						Util.Misc.ScaleParticle(emitter, player.Hybrid and 1.05 or 0.925)
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end

					task.wait(player.FlightDuration)

					if player.Player == game.Players.LocalPlayer then
						Util.CameraShaker:ShakeOnce(
							(player.Player == game.Players.LocalPlayer and 0.4 or 1) * 21.599999999999998,
							28,
							0.01,
							2.5
						)
					elseif cameraInRange(pos, 200) then
						Util.CameraShaker:ShakeOnce(
							(player.Player == game.Players.LocalPlayer and 0.4 or 1) * 21.599999999999998,
							28,
							0.01,
							2.5
						)
					end

					task.wait(0.1)
					local clone3 = F.GroundExplosion:Clone()
					debris:AddItem(clone3, 5)
					clone3.CFrame = CFrame.new(pos, pos + norm) * CFrame.Angles(-1.5707963267948966, 0, 0)
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player2, "DragonFruitVFXColor")

					for i, emitter in pairs(clone3:GetDescendants()) do
						if not (emitter:IsA("ParticleEmitter") and (player.Hybrid or emitter.Name ~= "Lightning") and (player.Hybrid or emitter.Name ~= "TatterRingOut")) then
							continue
						end

						Util.Misc.ScaleParticle(emitter, player.Hybrid and 1.05 or 0.925)
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end

					local clone4 = F.GroundBurn:Clone()
					Util.Debris:AddItem(clone4, 5)
					clone4.CFrame = clone3.CFrame
					Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player2, "DragonFruitVFXColor")

					for i, emitter in pairs(clone4:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v = emitter
						task.spawn(function()
							v.Enabled = true
							task.wait(3)
							v.Enabled = false
						end)
					end

					local cFrame = AlignCFrame(CFrame.new(pos), norm) + norm * 0.01
					local clone5 = F.GroundBurn2:Clone()
					Util.Debris:AddItem(clone5, 5)
					clone5.CFrame = cFrame
					Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player2, "DragonFruitVFXColor")

					for i, emitter in pairs(clone5:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v2 = emitter
						task.spawn(function()
							v2.Enabled = true
							task.wait(2.25)
							v2.Enabled = false
						end)
					end

					ExplosionFlameRocks(clone3.CFrame, _WorldOrigin, player2)

					if player.Hybrid then
						local v2 = clone3.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
						task.spawn(function()
							local folder2 = Instance.new("Folder", workspace._WorldOrigin)
							Util.Debris:AddItem(folder2, 2)
							local slashCFrame = v2 * CFrame.new(0, 0, -5)
							TornadoSlash(folder2, {
								Multiplier = 2.9375,
								Multiplier2 = 0.9375,
								Mutliplier2Time = 0.15,
								BeamOutTime = 0.15,
								SlashAngle = CFrame.new(0, 0, -12.5) * CFrame.Angles(0, 0, -0.8726646259971648),
								SlashAngle2 = CFrame.new(0, 0, -7.5) * CFrame.Angles(0, 0, -1.7453292519943295),
								SlashType = F.BeamSlash,
								SlashCFrame = slashCFrame,
								SlashSpeed = 0.05,
								SlashSpeed2 = 1,
								SpinIterations = 4
							}, player2)
						end)
						task.spawn(function()
							local folder2 = Instance.new("Folder", workspace._WorldOrigin)
							Util.Debris:AddItem(folder2, 2)
							local slashCFrame = v2 * CFrame.new(0, 0, -25)
							TornadoSlash(folder2, {
								Multiplier = 2.1875,
								Multiplier2 = 1.5625,
								Mutliplier2Time = 0.15,
								BeamOutTime = 0.15,
								SlashAngle = CFrame.new(0, 0, -8.75) * CFrame.Angles(0, 0, 0.8726646259971648),
								SlashAngle2 = CFrame.new(0, 0, -12.5) * CFrame.Angles(0, 0, 1.7453292519943295),
								SlashType = F.BeamSlash,
								SlashCFrame = slashCFrame,
								SlashSpeed = 0.025,
								SlashSpeed2 = 0.35,
								SpinIterations = 4
							}, player2)
						end)
					end
				end)
				task.wait(0.075)
				local clone2 = F.GrabSlam:Clone()
				debris:AddItem(clone2, 5)
				clone2.CFrame = CFrame.new(pos, pos + norm) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.rad((math.random(0, 360))),
					0
				)
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "DragonFruitVFXColor")

				for i, emitter in pairs(clone2.FloorAttach:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					Util.Misc.ScaleParticle(emitter, player.Hybrid and 1.8 or 1.6)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				Util.Sound:Play("BF_V3_Dragon_X_Explosion_02", clone2)

				if hit then
					local v = player.Hybrid and 42 or 36
					local v2 = player.Hybrid and 22 or 18
					local v3 = pos + createVector(0, 1, 0)

					for i = 1, v2 do
						local v4 = 360 / v2 * i
						local v5 = CFrame.new(v3, v3 + norm * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
							0,
							math.rad(v4),
							0
						) * CFrame.new(0, 0, -v)
						local ray, v6, v7 = Util.Ray(
							v5.Position,
							v5.upVector.Unit * -30,
							{ workspace.Characters, workspace.Enemies },
							false
						)

						if not ray then
							continue
						end

						local v8 = rock2.new({
							FadeIn = { 0.5, 1 },
							Lifetime = 1.4 * math.random(25, 30) / 10,
							FadeOut = { 0.4, 0.5 },
							Size = Vector3.new(math.random(3, 4), 2, math.random(3, 4)) * 1.7 * (player.Hybrid and 1.2 or 1),
							Scale = { 1, 2 }
						})
						v8:Spawn(
							CFrame.new(v6, v6 + v7) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, 0, 0),
							0.05
						)

						if not (math.random(1, 100) <= 25) then
							continue
						end

						v8.Type = "Flying"
						v8:Eject({
							Velocity = v5.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v8.Part.CFrame.lookVector * math.random(
								10,
								20
							) * 1.8,
							RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
						})
					end
				end
			end
		end
	end
end