local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local F = FX:WaitForChild("EasternDragon").F
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt

if not F:GetAttribute("ScaledUp") then
	F:SetAttribute("ScaledUp", true)

	for _, child in pairs(F:GetChildren()) do
		local v = child.Name == "Phase3" and 2.5 or 2
		local v2 = child.Name == "Phase2" and 1.75 or v

		if child:IsA("Folder") then
			for _, part in pairs(child:GetChildren()) do
				if part:IsA("BasePart") then
					Util.ResizeModel(part, v2, part.Position)
				end
			end
		elseif child:IsA("BasePart") then
			Util.ResizeModel(child, v2, child.Position)
		end
	end
end

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

local function RingBeam(p, p2, p3, p4)
	local _ = p * CFrame.new(0, 0, -150)
	local v = F
	local clone

	if p3 then
		clone = v.Phase2.RingBeamModel:Clone()
	else
		clone = v.Phase2.RingBeamModel2:Clone()
	end

	local v2 = TweenService
	local cFrame = p * CFrame.new(0, 0, -150)
	clone.PrimaryPart.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, p2, p4, "DragonFruitVFXColor")
	local v4 = {}

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v5 = beam
		task.spawn(function()
			local v6 = v2:Create(v5, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
				Width0 = v5.Width0 * 7,
				Width1 = v5.Width1 * 7
			})
			v6:Play()
			v6.Completed:Wait()
			local v7 = v2:Create(v5, TweenInfo.new(0.075, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
				Width0 = v5.Width0 * 15,
				Width1 = v5.Width1 * 15
			})
			v7:Play()
			v7.Completed:Wait()
			v2:Create(v5, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
				Width0 = v5.Width0 * 0,
				Width1 = v5.Width1 * 0
			}):Play()
		end)
		v4[beam] = beam
	end

	task.spawn(function()
		if p3 then
			local v5 = v2:Create(
				clone.PrimaryPart,
				TweenInfo.new(0.175, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 168.75)
				}
			)
			v5:Play()
			v5.Completed:Wait()
		else
			local v5 = v2:Create(
				clone.PrimaryPart,
				TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 112.5)
				}
			)
			v5:Play()
			v5.Completed:Wait()
		end

		v2:Create(clone.PrimaryPart, TweenInfo.new(0.075, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 37.5)
		}):Play()
	end)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0.0001
	Util.SetParentOverrideWithColor(numberValue, clone, p4, "DragonFruitVFXColor")
	v2:Create(numberValue, TweenInfo.new(0.35), {
		Value = 0.1
	}):Play()
	task.spawn(function()
		for i = 10, 43.75, 15 do
			clone:ScaleTo(i / 10)
			task.wait(numberValue.Value)
		end

		for i = 43.75, 175, 5 do
			clone:ScaleTo(i / 10)
			task.wait(numberValue.Value)
		end
	end)
end

return function(data)
	local player = data.player
	local _ = data.hrp
	local cFrame = data.hrp.CFrame
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

	if part == nil or part.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = part.Parent
	local currentCamera = Workspace.CurrentCamera

	if (part.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	local connection

	if localPlayer == player then
		connection = heartbeatLoopFor2(10, function()
			part.CFrame = data.dragonCF.DragonCFrameWithoutOffsetClient.Value
		end)
	else
		connection = heartbeatLoopFor2(10, function()
			part.CFrame = data.dragonCF.DragonCFrameWithoutOffsetOtherClient.Value
		end)
	end

	local v = F

	local function AlignCFrame(data2, p)
		local v2 = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
		local p2 = data2.p
		local unit = data2.LookVector:Cross(v2).Unit
		local unit2 = (unit.Magnitude > 0.001 and unit or data2.RightVector).Unit
		local unit3 = unit2:Cross(v2).Unit
		return CFrame.fromMatrix(p2, unit2, v2, unit3)
	end

	local function viewerIsClose(p, p2, callback)
		local character = localPlayer.Character

		if character ~= nil then
			local rootPart = character:FindFirstChildOfClass("Humanoid").RootPart

			if rootPart and (rootPart.Position - p).Magnitude <= p2 * 1.45 then
				callback()
			end
		end
	end

	local function DeleteImpactAfterDuration(folder)
		task.spawn(function()
			local v2 = 0

			for _, emitter in ipairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					v2 = math.max(v2, emitter.Lifetime.Max)
				end
			end

			task.wait(v2)
			folder:Destroy()
		end)
	end

	local function Flight(p)
		local skillVisuals = p.SkillVisuals
		local fActive = data.FActive
		local v2 = nil
		local v3 = {}
		local flag = false

		local function FallingDown()
			local clone = v.Phase2.Dash:Clone()
			clone.CFrame = part.CFrame
			Util.SetParentOverrideWithColor(clone, skillVisuals, player, "DragonFruitVFXColor")
			destroyAfter(clone, 12)
			clone.Anchored = false
			clone.Weld.Part0 = part
			local emittersByEmitter = {}

			for _, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = false
				emittersByEmitter[emitter] = emitter
			end

			task.spawn(function()
				local v4 = tick() + 10
				local v5 = time()
				local v6 = false

				while true do
					if flag == true then
						if v6 == false then
							v6 = true

							for k, _ in pairs(v3) do
								local v7 = math.random(1, 3)

								if v7 == 1 then
									k.Trail.Color = ColorSequence.new(
										Util.WrapColor3Constructor(
											Color3.fromRGB(248, 42, 45),
											player,
											"DragonFruitVFXColor"
										),
										Util.WrapColor3Constructor(
											Color3.fromRGB(255, 95, 40),
											player,
											"DragonFruitVFXColor"
										)
									)
								elseif v7 == 2 then
									k.Trail.Color = ColorSequence.new(
										Util.WrapColor3Constructor(
											Color3.fromRGB(248, 54, 67),
											player,
											"DragonFruitVFXColor"
										),
										Util.WrapColor3Constructor(
											Color3.fromRGB(255, 47, 20),
											player,
											"DragonFruitVFXColor"
										)
									)
								elseif v7 == 3 then
									k.Trail.Color = ColorSequence.new(
										Util.WrapColor3Constructor(
											Color3.fromRGB(156, 75, 17),
											player,
											"DragonFruitVFXColor"
										),
										Util.WrapColor3Constructor(
											Color3.fromRGB(255, 40, 25),
											player,
											"DragonFruitVFXColor"
										)
									)
								end
							end

							for _, v7 in pairs(emittersByEmitter) do
								v7.Enabled = true
							end
						end

						for _, v7 in pairs(emittersByEmitter) do
							v7:Emit(1)
						end
					elseif flag == false and v6 == true then
						v6 = false

						for _, v7 in pairs(emittersByEmitter) do
							v7.Enabled = false
						end

						for k, _ in pairs(v3) do
							local v7 = math.random(1, 3)

							if v7 == 1 then
								k.Trail.Color = ColorSequence.new(
									Util.WrapColor3Constructor(
										Color3.fromRGB(248, 42, 45),
										player,
										"DragonFruitVFXColor"
									),
									Util.WrapColor3Constructor(
										Color3.fromRGB(255, 95, 40),
										player,
										"DragonFruitVFXColor"
									)
								)
							elseif v7 == 2 then
								k.Trail.Color = ColorSequence.new(
									Util.WrapColor3Constructor(
										Color3.fromRGB(189, 182, 159),
										player,
										"DragonFruitVFXColor"
									),
									Util.WrapColor3Constructor(
										Color3.fromRGB(255, 47, 20),
										player,
										"DragonFruitVFXColor"
									)
								)
							elseif v7 == 3 then
								k.Trail.Color = ColorSequence.new(
									Util.WrapColor3Constructor(
										Color3.fromRGB(156, 150, 138),
										player,
										"DragonFruitVFXColor"
									),
									Util.WrapColor3Constructor(
										Color3.fromRGB(255, 40, 25),
										player,
										"DragonFruitVFXColor"
									)
								)
							end
						end
					end

					task.wait(0.05)

					if not (v4 - tick() <= 0 or flag == nil or fActive.Value ~= true or time() - v5 > 10) then
						continue
					end

					clone.Weld.Enabled = false
					clone.Anchored = true

					for _, effect in ipairs(clone:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					emittersByEmitter = nil
					break
				end
			end)
		end

		FallingDown()
		local clone = v.Phase1.Flight:Clone()
		clone.CFrame = part.CFrame
		Util.SetParentOverrideWithColor(clone, skillVisuals, player, "DragonFruitVFXColor")
		sound:Play("BF_V3_WhiteGlove_F_Dash_Start_02", clone)
		local v4 = sound:Play("BF_V3_WhiteGlove_F_Dash_Loop_01", clone)
		TweenService:Create(v4, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
			Volume = 1.2
		}):Play()
		destroyAfter(clone, 12)
		clone.Anchored = false
		clone.Weld.Part0 = part

		for _, effect in ipairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		for _ = 1, 5 do
			local clone2 = v.Phase1.SpinTrail:Clone()
			clone2.CFrame = part.CFrame
			Util.SetParentOverrideWithColor(clone2, skillVisuals, player, "DragonFruitVFXColor")
			destroyAfter(clone2, 12)
			clone2.Anchored = false
			clone2.Weld.Part1 = part

			for _, effect in ipairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			clone2.SpinTrail2.WeldConstraint.Enabled = false
			clone2.SpinTrail2.CFrame = clone2.CFrame * CFrame.new(
				math.random(-40, -20) * 1.45,
				math.random(-15, 15) * 1.45,
				math.random(10, 25) * 1.45
			)
			clone2.SpinTrail2.WeldConstraint.Enabled = true
			clone2.Weld.C0 = clone2.Weld.C0 * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
			local v5 = math.random(1, 3)

			if v5 == 1 then
				clone2.Trail.Color = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(248, 42, 45), player, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(255, 95, 40), player, "DragonFruitVFXColor")
				)
			elseif v5 == 2 then
				clone2.Trail.Color = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(99, 96, 89), player, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(255, 47, 20), player, "DragonFruitVFXColor")
				)
			elseif v5 == 3 then
				clone2.Trail.Color = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(49, 49, 49), player, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(255, 40, 25), player, "DragonFruitVFXColor")
				)
			end

			local v6 = math.random(7, 15) * 1.45
			clone2.SpinTrail2.Attach0.Position = Vector3.new(v6, 0, 0)
			clone2.SpinTrail2.Attach1.Position = Vector3.new(-v6, 0, 0)
			clone2.Trail.Lifetime = math.random(15, 30) / 100 * 1.45
			v3[clone2] = math.random(14, 17)
		end

		local _ = tick() + 0.5
		local v5 = tick() + 10
		local now = tick()
		local v6 = time()
		local v7 = 0.016666666666666666
		local v8 = false

		while true do
			local value = data.dragonCF.Value
			local _ = value.LookVector

			if math.acos(((createVector(-0, -1, -0)):Dot(value.LookVector))) < math.rad(data.DOWNWARD_ANGLE_MAX_OFFSET) then
				flag = true
			else
				flag = false
			end

			for k, v9 in pairs(v3) do
				k.Weld.C0 = k.Weld.C0 * CFrame.Angles(0, 0, math.rad(v9) * v7 * 60)
			end

			if flag then
				if now - tick() <= 0 then
					now = tick() + 0.15

					if v4 and not v8 then
						TweenService:Create(v4, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
							Volume = 0.85
						}):Play()
						v8 = true
					end

					if not v2 then
						v2 = sound:Play("Transformed_F_Dash_Loop_MeteorFireLayer_01", clone)
						TweenService:Create(v2, TweenInfo.new(0.2), {
							Volume = 3
						}):Play()
					end

					local v9 = value
					task.spawn(function()
						local clone2 = v.Phase2.RingMesh:Clone()
						clone2.CFrame = v9 * CFrame.new(0, 0, -100) * CFrame.Angles(
							90,
							math.rad((math.random(-180, 180))),
							0
						)
						clone2.Color = Util.WrapColor3Constructor(
							Color3.fromRGB(255, 76, 21),
							player,
							"DragonFruitVFXColor"
						)
						clone2.Size *= 1.15
						Util.SetParentOverrideWithColor(clone2, skillVisuals, player, "DragonFruitVFXColor")
						task.spawn(function()
							local tween = TweenService:Create(
								clone2,
								TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone2.CFrame * CFrame.new(0, 25, 0) * CFrame.Angles(
										0,
										-0.8726646259971648,
										0
									),
									Size = clone2.Size * 9
								}
							)
							tween:Play()
							tween.Completed:Wait()
							local tween2 = TweenService:Create(
								clone2,
								TweenInfo.new(0.075, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone2.CFrame * CFrame.new(0, 37.5, 0) * CFrame.Angles(
										0,
										-0.8726646259971648,
										0
									),
									Size = clone2.Size * 1
								}
							)
							tween2:Play()
							tween2.Completed:Wait()
							TweenService:Create(
								clone2,
								TweenInfo.new(0.075, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									CFrame = clone2.CFrame * CFrame.new(0, 16.666666666666668, 0) * CFrame.Angles(
										0,
										-0.8726646259971648,
										0
									),
									Size = clone2.Size * 1.25,
									Transparency = 1
								}
							):Play()
						end)
					end)
					local v10 = value
					task.spawn(function()
						local clone2 = v.Phase2.RingMesh:Clone()
						clone2.CFrame = v10 * CFrame.new(0, 0, -200) * CFrame.Angles(
							90,
							math.rad((math.random(-180, 180))),
							0
						)
						clone2.Color = Util.WrapColor3Constructor(
							Color3.fromRGB(255, 114, 43),
							player,
							"DragonFruitVFXColor"
						)
						clone2.Size *= 1.5
						Util.SetParentOverrideWithColor(clone2, skillVisuals, player, "DragonFruitVFXColor")
						task.spawn(function()
							local tween = TweenService:Create(
								clone2,
								TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone2.CFrame * CFrame.new(0, 75, 0) * CFrame.Angles(
										0,
										0.8726646259971648,
										0
									),
									Size = clone2.Size * 9
								}
							)
							tween:Play()
							tween.Completed:Wait()
							local tween2 = TweenService:Create(
								clone2,
								TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone2.CFrame * CFrame.new(0, 75, 0) * CFrame.Angles(
										0,
										0.8726646259971648,
										0
									),
									Size = clone2.Size * 1
								}
							)
							tween2:Play()
							tween2.Completed:Wait()
							TweenService:Create(
								clone2,
								TweenInfo.new(0.075, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									CFrame = clone2.CFrame * CFrame.new(0, 16.666666666666668, 0) * CFrame.Angles(
										0,
										0.8726646259971648,
										0
									),
									Size = clone2.Size * 1.25,
									Transparency = 1
								}
							):Play()
						end)
					end)
				end
			else
				if v2 then
					sound:FadeOut(v2, 0.2)
					v2 = nil
				end

				if v4 and v8 then
					TweenService:Create(v4, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
						Volume = 1
					}):Play()
					v8 = false
				end
			end

			v7 = task.wait()

			if not (v5 - tick() <= 0 or fActive.Value == false or time() - v6 > 10) then
				continue
			end

			for _, effect in ipairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			if v2 then
				sound:FadeOut(v2, 0.2)
			end

			if v4 then
				sound:FadeOut(v4, 0.3)
			end

			for folder, _ in pairs(v3) do
				for _, effect in ipairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end

			if p.Result == nil then
				return false
			end

			if p.Result == nil then
				break
			else
				return true
			end
		end
	end

	local function SpinSlash(cFrame2, p)
		local function TailWhip(p2, clone, data2)
			local v2 = data2.Multiplier * 1.45
			local slashAngle = data2.SlashAngle
			local slashAngle2 = data2.SlashAngle2
			local v3 = data2.YPosition * 1.45
			local slashType = data2.SlashType
			local slashIterations = data2.SlashIterations
			local slashSpinAngle = data2.SlashSpinAngle
			local slashFinalSpinAngle = data2.SlashFinalSpinAngle
			local slashEndSpeed = data2.SlashEndSpeed
			local clone2 = slashType:Clone()
			clone2.CFrame = clone.CFrame
			clone2.Anchored = false
			clone2.Weld.Part0 = clone
			clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * CFrame.new(0, v3, 0) * slashAngle * slashAngle2
			Util.SetParentOverrideWithColor(clone2, p2, player, "DragonFruitVFXColor")
			destroyAfter(clone2, 7)

			for _, descendant in ipairs(clone2:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= v2
					descendant.CurveSize1 *= v2
					descendant.Width0 *= v2
					descendant.Width1 *= v2
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * v2,
						descendant.Position.Y * v2,
						descendant.Position.Z * v2
					)
				end
			end

			for _, descendant in ipairs(clone2:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.Enabled = true
					local startDelay = descendant:GetAttribute("StartDelay")
					local v4 = descendant
					local v5 = descendant:GetAttribute("EndDelay")
					task.spawn(function()
						local tween = TweenService:Create(
							v4,
							TweenInfo.new(v5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Width0 = v4.Width0 * 2.175,
								Width1 = v4.Width1 * 2.175,
								CurveSize0 = v4.CurveSize0 * 2.175,
								CurveSize1 = v4.CurveSize1 * 2.175
							}
						)
						v4.Width0 = 0
						v4.Width1 = 0
						task.wait(startDelay)
						tween:Play()
					end)
				elseif descendant:IsA("Attachment") then
					TweenService:Create(
						descendant,
						TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(
								descendant.Position.X * 2.175,
								descendant.Position.Y * 2.175,
								descendant.Position.Z * 2.175
							)
						}
					):Play()
				end
			end

			for _ = 1, slashIterations do
				local tween = TweenService:Create(
					clone2.Weld,
					TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * CFrame.Angles(
							0,
							math.rad(slashSpinAngle),
							0
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end

			clone2.Weld.Enabled = false
			clone2.Anchored = true
			TweenService:Create(
				clone2,
				TweenInfo.new(slashEndSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					CFrame = clone2.CFrame * CFrame.Angles(0, math.rad(slashFinalSpinAngle), 0)
				}
			):Play()

			for _, effect in ipairs(clone2:GetDescendants()) do
				if effect:IsA("Beam") then
					local v4 = effect
					task.spawn(function()
						local endDelay = v4:GetAttribute("EndDelay")
						local tween = TweenService:Create(
							v4,
							TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v4:Destroy()
					end)
				elseif effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end
		end

		local clone = v.Phase4.TailSpin:Clone()
		clone.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone, p, player, "DragonFruitVFXColor")
		destroyAfter(clone, 7)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.spawn(function()
			task.wait(0.07)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		local clone2 = v.Phase4.StartImpact:Clone()
		clone2.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone2, p, player, "DragonFruitVFXColor")
		destroyAfter(clone2, 7)

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		task.spawn(function()
			TailWhip(p, clone2, {
				Multiplier = 4.35,
				SlashAngle = CFrame.Angles(0, math.rad((math.random(-170, -150))), 0),
				SlashAngle2 = CFrame.Angles(math.rad(math.random(1, 5) / 100), 0, 0),
				YPosition = 7.25,
				SlashType = v.Phase4.TailWhipSlash,
				SlashIterations = 3,
				SlashSpinAngle = 50,
				SlashFinalSpinAngle = 70,
				SlashEndSpeed = 0.25
			})
		end)
		task.spawn(function()
			task.wait(0.15)
			TailWhip(p, clone2, {
				Multiplier = 5.075,
				SlashAngle = CFrame.new(0, 7.25, 0) * CFrame.Angles(0, 2.6179938779914944, 0),
				SlashAngle2 = CFrame.Angles(0.08726646259971647, 0, 0),
				YPosition = 21.75,
				SlashType = v.Phase4.SmallTailWhipSlash,
				SlashIterations = 3,
				SlashSpinAngle = 120,
				SlashFinalSpinAngle = 150,
				SlashEndSpeed = 0.75
			})
		end)
		task.wait(0.15)
		local clone3 = v.Phase4.StartImpact2:Clone()
		clone3.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone3, p, player, "DragonFruitVFXColor")
		destroyAfter(clone3, 7)

		for _, emitter in ipairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		local clone4 = v.Phase4.EndSpin:Clone()
		clone4.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone4, p, player, "DragonFruitVFXColor")
		destroyAfter(clone4, 7)

		for _, emitter in ipairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end
	end

	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DragonFruitVFXColor")
	destroyAfter(folder, 15)
	local _ = part.CFrame
	local _ = Flight({
		SkillVisuals = folder,
		params = raycastParams
	}) == false
	task.delay(1, function()
		if connection then
			connection:Disconnect()
		end
	end)
end