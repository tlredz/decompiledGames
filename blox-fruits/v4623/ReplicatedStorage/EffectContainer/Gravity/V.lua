local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local currentCamera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
require(script.Parent.Modules.Beziers)
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage2:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local RockRipple = require(script.Parent.Modules.RockRipple)
local UselessRocksShouldntEvenBeUsedForGravity = require(script.Parent.Modules.UselessRocksShouldntEvenBeUsedForGravity)
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
require(script.Parent.Modules.FloorRipple)
require(interpolationScheme.Parent:WaitForChild("SequenceMaps"):WaitForChild("NumSeqMap"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local c_Un = FX:WaitForChild("Gravity").C_Un
local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
local V_ULT = FX2:WaitForChild("Gravity").V_ULT
local tweenProperty = Util.xmc_Helper.TweenProperty

local function lerp(p, p2, p3)
	return p:Lerp(p2, p3)
end

local function lerp2(p, p2, p3)
	return p + (p2 - p) * p3
end

function bezier(p, p2, p3, p4)
	return (p2:Lerp(p3, p):Lerp(p3:Lerp(p4, p), p))
end

local function RotateTowards(lookVector: Vector3, lookVector2: Vector3, p: number, p2: number)
	local unit = lookVector.Unit
	local unit2 = lookVector2.Unit
	local v = math.acos((math.clamp(unit:Dot(unit2), -1, 1)))

	if v == 0 then
		return unit2
	end

	local v2 = math.min(p * p2, v)
	local vector2 = unit:Cross(unit2)

	if vector2.Magnitude == 0 then
		vector2 = math.abs(unit.X) > math.abs(unit.Z) and Vector3.new(-unit.Y, unit.X, 0) or Vector3.new(
			0,
			-unit.Z,
			unit.Y
		)
	end

	return CFrame.fromAxisAngle(vector2.Unit, v2) * unit
end

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
					TweenService:Create(v2, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Width0 = 0
					}):Play()
					TweenService:Create(v2, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Width1 = 0
					}):Play()
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

local function Emit(folder)
	for _, effect in folder:GetDescendants() do
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
		elseif effect:IsA("ParticleEmitter") then
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

-- equivalent calls inferred from this helper; original call sites unknown
local function ScaleParticle(descendant, p)
	local keypoints = descendant.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	descendant.Size = NumberSequence.new(numberSequenceKeypoints)
	descendant.Speed = NumberRange.new(descendant.Speed.Min * p, descendant.Speed.Max * p)
	descendant.Acceleration *= p
end

local function ScaleAttachmentsAndEmittersWithin(folder, p: number)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= p
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, p)
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

local function tweenClock(p, p2, p3)
	local lastTime = tick()

	while tick() - lastTime < p3 do
		local v = (tick() - lastTime) / p3
		local clockTime = p + (p2 - p) * v
		local Lighting = game:GetService("Lighting")
		Lighting.ClockTime = clockTime
		local RunService2 = game:GetService("RunService")
		RunService2.RenderStepped:Wait()
	end
end

return function(data)
	local DELAY_DURATION = 1
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 5000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		require(game.ReplicatedStorage.Util.GravityRock)
		local root = data.Root
		local holding = data.Holding

		if not (holding or holding.Value) then
			return
		end

		local leftHand = root.Parent:FindFirstChild("LeftHand")
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		local FloorRipple = require(script.Parent.Modules.FloorRipple)
		FloorRipple({
			CFrame = root.CFrame,
			Holding = holding
		})
		local clone = c_Un.handpart.Enable:Clone()
		Util.SetParentOverrideWithColor(clone, leftHand, data.Player, "GravityFruitVFXColor")
		local flag = false
		local v = true

		for _, particlEmitter in pairs(clone:GetDescendants()) do
			if particlEmitter:IsA("ParticlEmitter") then
				particlEmitter.Enabled = true
			end
		end

		local v2 = Util.Sound:Play("GravFruit_V_Hold_01", root)
		local clone2 = c_Un.GravityFloor:Clone()
		local primaryPart = clone2.PrimaryPart
		local ray = Util.Ray
		local v3 = root.Position + createVector(0, 2, 0)
		local v4 = { workspace.Characters, workspace.Enemies, folder }
		local v5, v6, v7 = ray(v3, createVector(-0, -20, -0), v4, false)

		if v5 ~= nil then
			emitAll(primaryPart.emit)
			primaryPart.CFrame = CFrame.new(v6, v6 + v7)
			Util.SetParentOverrideWithColor(clone2, folder, data.Player, "GravityFruitVFXColor")
		end

		local clones = {}
		table.insert(clones, clone)
		table.insert(clones, clone2)
		task.spawn(function()
			local now = tick()
			local now2 = tick()

			while true do
				task.wait()

				if now < tick() then
					now = tick() + 0.035

					if root.Parent == game.Players.LocalPlayer.Character then
						Util.CameraShaker:ShakeOnce(
							1,
							1,
							0.05,
							0.1,
							createVector(0.5, 0.5, 0.5),
							createVector(0.5, 0.3, 0.3)
						)
					end
				end

				if now2 < tick() then
					now2 = tick() + 0.1
					local clone3 = c_Un.PulseDistortBig:Clone()
					clone3.CFrame = leftHand.CFrame
					Util.SetParentOverrideWithColor(clone3, folder, data.Player, "GravityFruitVFXColor")
					local tween = TweenService:Create(
						clone3,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					)
					tween.Completed:Connect(function()
						clone3:Destroy()
					end)
					tween:Play()
				end

				if holding:IsDescendantOf(workspace) and holding.Value then
					continue
				end

				task.wait(5)
				folder:Destroy()
				break
			end
		end)
		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.175

					if root.Parent == game.Players.LocalPlayer.Character then
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						colorCorrectionEffect.Parent = game.Lighting
						Util.Debris:AddItem(colorCorrectionEffect, 2.5)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.05, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Brightness = -0.085,
								Contrast = 0.07,
								Saturation = -0.07,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(211, 207, 248),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
						task.wait(0.05)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Brightness = 0,
								Contrast = 0,
								Saturation = 0,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 255, 255),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
					end
				end
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)
		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.415

					if clone:FindFirstChild("Emit") then
						emitAll(clone.Emit)
					end
				end
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)
		local v8 = false
		local clone3 = nil
		local clone4 = nil
		local clone5 = nil

		if data.CanUltimate then
			task.delay(DELAY_DURATION, function()
				if not v8 then
					flag = true
					Util.Sound:Play("gravityultswitch", root.Position)

					if root.Parent == game.Players.LocalPlayer.Character then
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						colorCorrectionEffect.Parent = game.Lighting
						Util.Debris:AddItem(colorCorrectionEffect, 0.5)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.03, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								Brightness = -10,
								Contrast = 1,
								Saturation = -1,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(189, 169, 255),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
						task.wait(0.03)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								Brightness = 3,
								Contrast = 2,
								Saturation = 2,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(169, 140, 255),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
						task.wait(0.1)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Brightness = 0,
								Contrast = 0,
								Saturation = 0,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 255, 255),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
					end

					clone:Destroy()
					local rightHand = root.Parent:FindFirstChild("RightHand")
					local leftHand2 = root.Parent:FindFirstChild("LeftHand")
					clone3 = c_Un.handpart2.Attachment1:Clone()
					clone4 = c_Un.handpart2.Attachment2:Clone()
					Util.SetParentOverrideWithColor(clone3, leftHand2, data.Player, "GravityFruitVFXColor")
					Util.SetParentOverrideWithColor(clone4, rightHand, data.Player, "GravityFruitVFXColor")
					local ray2 = Util.Ray
					local position = root.Position
					local v9 = { workspace.Characters, workspace.Enemies, folder }
					local v10, v11, v12 = ray2(position, createVector(-0, -20, -0), v9, false)

					if v10 ~= nil then
						clone5 = V_ULT.FloorCharge:Clone()
						local cFrame = CFrame.new(v11, v11 + v12) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
							0,
							0,
							0
						)
						clone5.CFrame = cFrame
						Util.SetParentOverrideWithColor(clone5, folder, data.Player, "GravityFruitVFXColor")
					end

					local FloorRipple2 = require(script.Parent.Modules.FloorRipple)
					FloorRipple2({
						CFrame = root.CFrame,
						Holding = holding,
						Segments = 6,
						Scale = 1.75,
						InitialGap = 15,
						SpeedFactor = 2,
						Narrowness = 0.5,
						Strength = 10
					})

					if root.Parent == game.Players.LocalPlayer.Character then
						local localPlayer = game.Players.LocalPlayer
						root:SetAttribute("GravityUlt", 1)
						v = false
						local flag2 = false
						local mouse = localPlayer:GetMouse()
						local position2 = mouse.Hit.Position
						local unit = (position2 * createVector(1, 0, 1) - root.Position * createVector(1, 0, 1)).Unit

						if (position2 * createVector(1, 0, 1) - root.Position * createVector(1, 0, 1)).Magnitude > 250 then
							position2 = root.Position + unit * 250
						end

						local _, v13 = Util.Ray(
							position2,
							position2 + createVector(-0, -1000, -0),
							{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
						)
						local position3 = v13
						local v14 = position3
						local clone6 = c_Un.MOUSEBAMPDICATOR:Clone()
						clone6.CFrame = CFrame.new(createVector(0, 0, 0), createVector(0, 1, 0)) * CFrame.Angles(
							-1.5707963267948966,
							0.0001,
							0.0001
						) + v14 + createVector(0, 0.25, 0)
						Util.SetParentOverrideWithColor(clone6, folder, data.Player, "GravityFruitVFXColor")
						task.spawn(function()
							while root:GetAttribute("GravityUlt") < 3 and holding.Value do
								local v16 = task.wait()
								position3 = mouse.Hit.Position
								local unit2 = (position3 * createVector(1, 0, 1) - root.Position * createVector(1, 0, 1)).Unit

								if (position3 * createVector(1, 0, 1) - root.Position * createVector(1, 0, 1)).Magnitude > 250 then
									position3 = root.Position + unit2 * 250
								end

								local ray3 = Util.Ray
								local v17 = position3 + createVector(0, 1, 0)
								local v18 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
								local _, v19 = ray3(v17, createVector(-0, -1000, -0), v18)
								position3 = v19

								if position3.Y < -1 then
									position3 = Vector3.new(position3.X, -1, position3.Z)
								end

								v14 = v14:Lerp(position3, v16 * 30)
								clone6.CFrame = CFrame.new(createVector(0, 0, 0), createVector(0, 1, 0)) * CFrame.Angles(
									-1.5707963267948966,
									0.0001,
									0.0001
								) + v14 + createVector(0, 0.25, 0)

								if flag2 then
									for _, emitter in pairs(clone6:GetDescendants()) do
										if not emitter:IsA("ParticleEmitter") then
											continue
										end

										local v20 = 60.75000000000001 * emitter.Lifetime.Min * (math.cos((tick() + emitter.ZOffset) * 16) * 0.05 + 1)
										local v21 = 0.625 * emitter.Lifetime.Max / 3 * (math.sin((tick() + emitter.ZOffset) * 24) * 0.25 + 1)
										emitter.Size = NumberSequence.new(v20, v20)
										emitter.Transparency = NumberSequence.new(v21, v21)
									end
								end

								if flag2 then
									continue
								end

								flag2 = true

								for _, emitter in pairs(clone6:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v20 = 30.375000000000004 * emitter.Lifetime.Min * (math.cos((tick() + emitter.ZOffset) * 16) * 0.05 + 1)
									local v21 = 0.625 * emitter.Lifetime.Max / 3 * (math.sin((tick() + emitter.ZOffset) * 24) * 0.25 + 1)
									emitter.Size = NumberSequence.new(v20, v20)
									emitter.Transparency = NumberSequence.new(v21, v21)
									emitter.TimeScale = 0.01
									emitter:Emit(1)
								end
							end

							local position4 = clone6.Position
							clone6:Destroy()
							local clone7 = V_ULT.PULLDOWN:Clone()
							clone7.Position = position4
							clone7.Size = createVector(1, 1, 1)
							clone7.Transparency = 1
							clone7.Anchored = true
							clone7.CanCollide = false
							Util.SetParentOverrideWithColor(clone7, folder, data.Player, "GravityFruitVFXColor")
							emitAll(clone7)
							Util.Debris:AddItem(clone7, 5)
						end)
						task.delay(1.2, function()
							root:SetAttribute("GravityUlt", 2)
							v = true
						end)
						Util.CameraShaker:ShakeOnce(9, 9, 0.05, 0.2, createVector(1, 1, 1), createVector(1, 1, 1))
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						colorCorrectionEffect.Parent = game.Lighting
						Util.Debris:AddItem(colorCorrectionEffect, 0.5)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.05, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Brightness = 0,
								Contrast = 0.07,
								Saturation = -0.07,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(205, 172, 212),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
						task.wait(0.05)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Brightness = 0,
								Contrast = 0,
								Saturation = 0,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 255, 255),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
					end
				end
			end)
		end

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value) and v == true

		if flag then
			task.spawn(function()
				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(
						2,
						4,
						0.05,
						0.185,
						createVector(1.5, 1.5, 1.5),
						createVector(1.5, 1.5, 1.5)
					)
					Util.CameraShaker:ShakeOnce(
						11,
						12,
						0.65,
						1.9,
						createVector(0.9, 0.9, 0.9),
						createVector(0.9, 0.9, 0.9)
					)
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					colorCorrectionEffect.Parent = game.Lighting
					Util.Debris:AddItem(colorCorrectionEffect, 2.5)
					task.spawn(function()
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Brightness = 2.3,
								Contrast = 0.9,
								Saturation = -0.9,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(143, 139, 193),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
						task.wait(0.1)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Brightness = -0.3,
								Contrast = 0.9,
								Saturation = -0.9,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(143, 139, 193),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
						task.wait(0.2)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Brightness = 0,
								Contrast = 0,
								Saturation = 0,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 255, 255),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
					end)
					task.spawn(function()
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								FieldOfView = 110
							}
						):Play()
						task.wait(0.4)
						task.spawn(function()
							task.wait(0.4)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
								{
									Brightness = 1.3,
									Contrast = 0.9,
									Saturation = -0.9,
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(143, 139, 193),
										data.Player,
										"GravityFruitVFXColor"
									)
								}
							):Play()
							task.wait(0.1)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{
									Brightness = 0,
									Contrast = 0,
									Saturation = 0,
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 255, 255),
										data.Player,
										"GravityFruitVFXColor"
									)
								}
							):Play()
							task.delay(1, function()
								colorCorrectionEffect:Destroy()
							end)
						end)
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
							{
								FieldOfView = 70
							}
						):Play()
					end)
				end
			end)
			pcall(function()
				clone3:Destroy()
			end)
			pcall(function()
				clone4:Destroy()
			end)
			pcall(function()
				clone5:Destroy()
			end)
			local ray2 = Util.Ray
			local position = root.Position
			local v9 = { workspace.Characters, workspace.Enemies, folder }
			local v10, v11, v12 = ray2(position, createVector(-0, -20, -0), v9, false)

			if v10 ~= nil then
				Util.Sound:Play("gravityultrelease", v11)
				local clone6 = V_ULT.FloorRelease:Clone()
				clone6.CFrame = CFrame.new(v11, v11 + v12) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
					0,
					0,
					0
				)
				Util.SetParentOverrideWithColor(clone6, folder, data.Player, "GravityFruitVFXColor")
				Util.Debris:AddItem(clone6, 2.5)
				emitAll(clone6)
			end
		end

		v8 = true
		task.wait(0.05)

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		task.wait(0.15)

		for _, folder2 in pairs(clones) do
			if folder2:IsDescendantOf(workspace) then
				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			end

			local v9 = folder2
			task.spawn(function()
				task.wait(1)
				v9:Destroy()
			end)
		end
	elseif stage == 2 then
		local root = data.Root
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 30)
		Util.Sound:Play("GravFruit_V_Release_SkyLaser_01", root.Position)
		task.spawn(function()
			if (origin - workspace.CurrentCamera.CFrame.Position).Magnitude < 90 then
				Util.CameraShaker:ShakeOnce(11, 11, 0.05, 1.45, createVector(1, 1, 1), createVector(1, 1, 1))
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				Util.Debris:AddItem(colorCorrectionEffect, 1.5)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
					{
						Brightness = 0.4,
						Contrast = 0.2,
						Saturation = 0,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(124, 80, 255),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
				task.wait(0.1)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Brightness = 0,
						Contrast = 0,
						Saturation = 0,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
			end
		end)
		task.spawn(function()
			task.wait(0.3)
			local ray = Util.Ray
			local v = root.Position + createVector(0, 2, 0)
			local v2 = { workspace.Characters, workspace.Enemies, folder }
			local v3, _, _ = ray(v, createVector(-0, -20, -0), v2, false)

			if v3 ~= nil then
				task.spawn(function()
					for _ = 1, 9 do
						task.spawn(function()
							local clone = c_Un.SPINWIND:Clone()
							clone.CFrame = root.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
							Util.SetParentOverrideWithColor(clone, folder, data.Player, "GravityFruitVFXColor")
							Util.Debris:AddItem(clone, 2)
							TweenService:Create(
								clone,
								TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
								{
									CFrame = clone.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(
										0,
										-3.0543261909900767,
										0
									)
								}
							):Play()
							TweenService:Create(
								clone.Mesh,
								TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									Scale = createVector(34.852, 94.222, 34.037)
								}
							):Play()
							TweenService:Create(
								clone.Decal,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{
									Transparency = 1
								}
							):Play()
						end)
						task.wait(0.015)
					end
				end)
			end

			if (origin - workspace.CurrentCamera.CFrame.Position).Magnitude < 90 then
				Util.CameraShaker:ShakeOnce(11, 11, 0.05, 1.45, createVector(1, 1, 1), createVector(1, 1, 1))
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				Util.Debris:AddItem(colorCorrectionEffect, 1.5)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
					{
						Brightness = -0.6,
						Contrast = 0.2,
						Saturation = 0,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(124, 80, 255),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
				task.wait(0.1)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Brightness = 0,
						Contrast = 0,
						Saturation = 0,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
			end
		end)
		task.spawn(function()
			task.wait(0.3)
			local ray = Util.Ray
			local v = root.Position + createVector(0, 2, 0)
			local v2 = { workspace.Characters, workspace.Enemies, folder }
			local v3, v4, _ = ray(v, createVector(-0, -40, -0), v2, false)

			if v3 ~= nil then
				local part = Instance.new("Part")
				part.Name = "BAMPROCK"
				part.CanTouch = false
				part.CanQuery = false
				part.CanCollide = false
				part.Anchored = true
				RockRipple.createRippleEffect(part, v4, 16, 5, 4, 3)
			end
		end)

		if root.Parent == game.Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(7, 7, 0.05, 0.4, createVector(1.5, 1.5, 1.5), createVector(0.5, 0.3, 0.3))
		end

		local clone = c_Un.GRAVUP:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, folder, data.Player, "GravityFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 2.2)
		local clone2 = c_Un.handpart.Emit:Clone()
		Util.SetParentOverrideWithColor(clone2, root.Parent.RightHand, data.Player, "GravityFruitVFXColor")
		emitAll(clone2)
		Util.Debris:AddItem(clone2, 1.2)
		local clone3 = c_Un.BLASTUP:Clone()
		clone3.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone3, folder, data.Player, "GravityFruitVFXColor")
		Util.Debris:AddItem(clone3, 7)
		emitAll(clone3)
		local ray = Util.Ray
		local position = root.Position
		local v = { workspace.Characters, workspace.Enemies, folder }
		local v2, v3, v4 = ray(position, createVector(-0, -20, -0), v, false)

		if v2 ~= nil then
			local clone4 = c_Un.BLASTUPFLOOR:Clone()
			clone4.CFrame = CFrame.new(v3, v3 + v4) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, 0, 0)
			Util.SetParentOverrideWithColor(clone4, folder, data.Player, "GravityFruitVFXColor")
			Util.Debris:AddItem(clone4, 2.5)
			emitAll(clone4)
			Util.Sound:Play("GravFruit_GenericDebrisLayer_Large_05", v3)
		end

		local clone4 = c_Un.BLASTUP2:Clone()
		clone4.Position = clone3.Position
		Util.SetParentOverrideWithColor(clone4, folder, data.Player, "GravityFruitVFXColor")
		Util.Debris:AddItem(clone4, 7)

		if data.NpcMode then
			return
		end

		task.wait(0.385)

		if root.Parent == game.Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(9, 9, 0.05, 0.2, createVector(1.5, 1.5, 1.5), createVector(1.5, 1.3, 1.3))
		end

		task.wait(0.9)
		local instance = data.Ray.Instance
		local position2 = data.Ray.Position
		local normal = data.Ray.Normal

		if instance ~= nil then
			local clone5 = c_Un.BLASTUPFLOOR:Clone()
			clone5.CFrame = CFrame.new(position2)
			Util.SetParentOverrideWithColor(clone5, folder, data.Player, "GravityFruitVFXColor")
			Util.Debris:AddItem(clone5, 4)
			local spawnOrigin = data.SpawnOrigin
			local v5 = spawnOrigin + createVector(0, 1000, 0)
			local primaryPart = c_Un.METEORBAMP:Clone().PrimaryPart
			primaryPart.CFrame = CFrame.lookAt(v5, spawnOrigin)
			primaryPart.Anchored = true
			Util.SetParentOverrideWithColor(primaryPart, folder, data.Player, "GravityFruitVFXColor")
			Util.Debris:AddItem(primaryPart, 20)
			local meteor = primaryPart.Meteor
			primaryPart.Motor6D:Destroy()
			meteor.Anchored = true
			meteor.Parent = folder
			local clone6 = c_Un.MOUSEBAMPDICATOR:Clone()
			clone6.CFrame = CFrame.new(createVector(0, 0, 0), normal) * CFrame.Angles(-1.5707963267948966, 0, 0) + position2
			Util.SetParentOverrideWithColor(clone6, folder, data.Player, "GravityFruitVFXColor")
			Util.Debris:AddItem(clone5, 20)
			task.spawn(function()
				local position3 = primaryPart.Position
				Util.Sound:Play("GravFruit_V_MeteorFlying_Loop_01", primaryPart)
				local lastTime = os.clock()
				local random = Random.new()
				local cFrame = primaryPart.CFrame

				local function ScaleParticle2(child, p)
					ScaleParticle(child, p) -- equivalent call inferred; original call site unknown
				end

				local v6 = 0.016666666666666666
				local v7 = false
				local now = 0
				local now2 = 0
				local flag = false

				for _, child in pairs(primaryPart.BAMPLASH:GetChildren()) do
					ScaleParticle2(child, 5)
				end

				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				local v8 = {}
				local now3 = 0
				local v9 = 1
				local total = 1

				for i = 0, 2 do
					table.insert(
						v8,
						meteor.Neon.Color:Lerp(
							Util.WrapColor3Constructor(
								Color3.fromRGB(152, 79, 255),
								data.Player,
								"GravityFruitVFXColor"
							),
							i / 2
						)
					)
				end

				local v10 = position2
				local v11 = { workspace.Characters, workspace.Enemies }

				local function ignore(p, p2)
					if p and #v11 < 10 and p2.Y > root.Position.Y then
						table.insert(v11, p)
						p = nil
					end

					return p
				end

				local spring = Util.Spring.new(1, 3, primaryPart.Position)
				local v12 = false
				local ancestryChangedConnection = nil

				if root then
					ancestryChangedConnection = root.AncestryChanged:Once(function()
						ancestryChangedConnection:Disconnect()
						v12 = true
					end)
				end

				while os.clock() - lastTime < 30 and not v12 do
					local v13 = os.clock() - lastTime + 0.01
					local value = data.MousePos.Value
					local ray2, v14, _ = Util.Ray(
						value - (value - root.Position).Unit,
						createVector(-0, -2999, -0),
						v11
					)

					if ray2 then
						v10 = v14
					end

					local _ = spawnOrigin + createVector(0, 500, 0)

					if v13 > 1.3 then
						local rotateTowards = RotateTowards(
							cFrame.LookVector,
							CFrame.lookAt(cFrame.Position, v10).LookVector,
							math.rad(math.min(70, (v13 - 1.3) * 70) + 5),
							v6
						)
						cFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + rotateTowards)

						if not v7 then
							emitAll(clone4)
							Util.Sound:Play("GravFruit_V_Meteor_CloudPuncture_04", clone4.Clouds.Big.WorldPosition)
							v7 = true
						end

						if tick() - now3 > 0.08323333333333333 then
							now3 = tick()
							total += v9 * 1

							if #v8 <= total or total <= 1 then
								v9 *= -1
							end
						end

						if tick() - now > 0.15 then
							now = tick()
							task.spawn(function()
								local v16 = 2 + math.random() * 3.5
								local v17 = cFrame
								local cframe = CFrame.new(0, 0, 22.5)
								local cframe2 = CFrame.Angles(
									0,
									random:NextNumber(-3.141592653589793, 3.141592653589793),
									0
								)
								local number = random:NextNumber(10, 15)
								local clone7 = V_ULT.FireRing:Clone()
								clone7:SetPrimaryPartCFrame(v17 * cframe * CFrame.Angles(1.5707963267948966, 0, 0) * cframe2)
								Util.SetParentOverrideWithColor(
									clone7,
									workspace._WorldOrigin,
									data.Player,
									"GravityFruitVFXColor"
								)
								local v18 = {}

								for _, child in pairs(clone7:GetChildren()) do
									if child ~= clone7.PrimaryPart then
										v18[child] = {
											Offset = clone7.PrimaryPart.CFrame:ToObjectSpace(child.CFrame),
											Decal = {
												Transparency = child.Decal.Transparency
											},
											Mesh = {
												Scale = child.Mesh.Scale,
												Offset = child.Mesh.Offset
											}
										}
									end
								end

								local lastTime2 = tick()

								while true do
									local v19 = math.min(1, (tick() - lastTime2) / 1.35)
									local sine = Util.Tween.ease.out.sine(v19, 0, 1, 1)
									local quint = Util.Tween.ease.out.quint(v19, 0, 1, 1)

									for k, v20 in pairs(v18) do
										k.CFrame = clone7.PrimaryPart.CFrame * Util.Misc.ScaleCFrame(v20.Offset, 22.5)
										k.Mesh.Scale = v20.Mesh.Scale * 22.5 * 1.75 + v20.Mesh.Scale * 1 * 22.5 * Vector3.new(
											1.5 * sine,
											1.6 * number * sine,
											1.5 * sine
										)
										k.Decal.Color3 = Util.WrapColor3Constructor(
											Color3.fromRGB(v16 * (225 - 55 * quint) / 2, 0, v16 * (255 - 55 * quint)),
											data.Player,
											"GravityFruitVFXColor"
										)
										k.Decal.Transparency = sine
									end

									clone7:SetPrimaryPartCFrame(v17 * cframe * CFrame.new(0, 0, 5.625 * number * sine) * CFrame.Angles(
										1.5707963267948966,
										0,
										0
									) * cframe2)

									if v19 == 1 then
										clone7:Destroy()
										break
									else
										RunService.RenderStepped:Wait()
									end
								end
							end)
						end
					else
						local rotateTowards = RotateTowards(
							cFrame.LookVector,
							CFrame.lookAt(cFrame.Position, v10).LookVector,
							0.08726646259971647,
							v6
						)
						cFrame = CFrame.lookAt(cFrame.Position, cFrame.Position + rotateTowards)
					end

					cFrame *= CFrame.new(0, 0, v6 * -333.3333333333333 * 1)
					local cFrame2

					if data.Proxy and data.Proxy.Parent then
						spring:SetGoal(data.Proxy.Value.Position)
						spring:Update(v6)
						cFrame2 = CFrame.new(spring:GetPosition()) * primaryPart.CFrame.Rotation:Lerp(
							data.Proxy.Value.Rotation,
							v6 * 15
						)
						cFrame = cFrame2 * CFrame.Angles(1.5707963267948966, -3.141592653589793, 0)

						if data.Proxy:GetAttribute("Destroyed") then
							primaryPart.CFrame = data.Proxy.Value
							break
						end
					end

					local v16 = primaryPart

					if not cFrame2 then
						cFrame2 = CFrame.lookAt(cFrame.Position, position3) * CFrame.Angles(
							-1.5707963267948966,
							3.141592653589793,
							0
						)
					end

					v16.CFrame = cFrame2
					meteor.CFrame = CFrame.new(primaryPart.Position) * CFrame.Angles(v13 * 1.2, v13 * 1.2, v13 * 1.2)
					position3 = primaryPart.Position
					local position4 = cFrame.Position
					local v17 = 1 - math.clamp((position4 - workspace.CurrentCamera.CFrame.p).Magnitude / 500, 0, 1)
					colorCorrectionEffect.Brightness = v17 * 0.3
					colorCorrectionEffect.Contrast = v17 * 0.5
					colorCorrectionEffect.Saturation = v17 * 0.1
					colorCorrectionEffect.TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.new(1, 1, 1):Lerp(Color3.fromRGB(255, 201, 83), v17),
						data.Player,
						"GravityFruitVFXColor"
					)
					local ray3, v18, v19 = Util.Ray(primaryPart.Position, cFrame.LookVector * 2999, v11)

					if ray3 and #v11 < 10 and v18.Y > root.Position.Y then
						table.insert(v11, ray3)
						ray3 = nil
					end

					if ray3 then
						clone6.CFrame = CFrame.new(createVector(0, 0, 0), v19) * CFrame.Angles(
							-1.5707963267948966,
							0.001,
							0.001
						) + v18 + v19 * 0.2
						local magnitude = (v18 - cFrame.Position).Magnitude
						local v20 = math.clamp((magnitude / 500) ^ 0.9, 0, 1)
						local v21 = magnitude > 500 and (magnitude - 500) / 500 or 0

						if flag then
							for _, emitter in pairs(clone6:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v22 = v20 * 45 * emitter.Lifetime.Min * (math.cos((tick() + emitter.ZOffset) * 16) * 0.05 + 1)
								local v23 = (1 - v20 * 0.75) * emitter.Lifetime.Max / 3 * (math.sin((tick() + emitter.ZOffset) * 24) * 0.25 + 1) + v21
								emitter.Size = NumberSequence.new(v22, v22)
								emitter.Transparency = NumberSequence.new(v23, v23)
							end
						end

						if not flag then
							flag = true

							for _, emitter in pairs(clone6:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v22 = v20 * 45 * emitter.Lifetime.Min * (math.cos((tick() + emitter.ZOffset) * 16) * 0.05 + 1)
								local v23 = (1 - v20 * 0.75) * emitter.Lifetime.Max / 3 * (math.sin((tick() + emitter.ZOffset) * 24) * 0.25 + 1) + v21
								emitter.Size = NumberSequence.new(v22, v22)
								emitter.Transparency = NumberSequence.new(v23, v23)
								emitter.TimeScale = 0.01
								emitter:Emit(1)
							end
						end
					end

					if tick() - now2 > 0.08333333333333333 then
						local ray4, v20, _ = Util.Ray(cFrame.Position, cFrame.LookVector * 150, v11)

						if ray4 and #v11 < 10 and v20.Y > root.Position.Y then
							table.insert(v11, ray4)
							ray4 = nil
						end

						if ray4 then
							now2 = tick()
							emitAll(primaryPart.BAMPLASH)
							local clone7 = c_Un.HEATWAVE:Clone()
							clone7.CFrame = CFrame.new(v20)
							Util.SetParentOverrideWithColor(clone7, folder, data.Player, "GravityFruitVFXColor")
							Util.Debris:AddItem(clone7, 2.5)
							emitAll(clone7)
						end
					end

					local ray4, v20, v21 = Util.Ray(
						primaryPart.Position + createVector(0, 0.1, 0),
						createVector(-0, -20, -0),
						v11
					)

					if not ray4 then
						ray4, v20, v21 = Util.Ray(primaryPart.Position, cFrame.LookVector * 20, v11)
					end

					if ray4 and #v11 < 10 and v20.Y > root.Position.Y then
						table.insert(v11, ray4)
						ray4 = nil
					end

					if ray4 then
						primaryPart.CFrame = CFrame.new(createVector(0, 0, 0), v21) * CFrame.Angles(
							-1.5707963267948966,
							0.001,
							0
						) + v20
						break
					else
						v6 = task.wait()
					end
				end

				if data.Proxy then
					primaryPart.CFrame = data.Proxy.Value
					cFrame = primaryPart.CFrame * CFrame.Angles(1.5707963267948966, -3.141592653589793, 0)
				end

				colorCorrectionEffect:Destroy()
				meteor.CFrame = primaryPart.CFrame

				if ancestryChangedConnection then
					ancestryChangedConnection:Disconnect()
				end

				local ray2 = Util.Ray
				local v13 = clone6.Position + createVector(0, 1, 0)
				local v14 = { workspace.Characters, workspace.Enemies }
				local v15, v16, v17 = ray2(v13, createVector(-0, -50, -0), v14)

				if not v15 then
					v15, v16, v17 = Util.Ray(
						primaryPart.Position,
						cFrame.LookVector * 50,
						{ workspace.Characters, workspace.Enemies }
					)
				end

				if v15 ~= nil then
					local cFrame2 = CFrame.new(v16, v16 + v17) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
					local clone7 = c_Un.MeteorExplodeFloor:Clone()
					clone7.CFrame = cFrame2
					Util.SetParentOverrideWithColor(clone7, folder, data.Player, "GravityFruitVFXColor")
					Util.Debris:AddItem(clone7, 7)
					emitAll(clone7)
					UselessRocksShouldntEvenBeUsedForGravity(v16, {
						RandomOffset = 0.35,
						Radius = 110,
						Size = 25,
						Duration = 3.5,
						Amount = 40
					})
					local v19 = CFrame.new(v16, v16 + v17) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
					local random2 = Random.new()
					local v20 = 70
					local v21 = math.max(6, v20 / 3)
					local v22 = v20 / 8

					for i = 1, v22 do
						local v24 = Rock2.new({
							Type = "Ground",
							FadeOut = { 0.25, 0.5 },
							FadeIn = { 0.25, 0.5 },
							Lifetime = { 1, 2.5 },
							Size = Vector3.new(
								random2:NextNumber(1, 2),
								random2:NextNumber(1, 2),
								random2:NextNumber(1, 2)
							),
							Scale = { v21 / 4, v21 / 2 }
						})
						local unit = Vector3.new(
							math.sin(random2:NextNumber(-1, 1) * 2 * 3.141592653589793),
							random2:NextNumber(0.666, 1),
							(math.cos(random2:NextNumber(-1, 1) * 2 * 3.141592653589793))
						).Unit
						v24.Type = "Flying"
						v24:Spawn(v19 * CFrame.Angles(0, 6.283185307179586 * (i / v22), 0) * CFrame.new(0, 0, -52.5))
						v24:Eject({
							Velocity = Util.Misc.Physics.Velocity(
								Vector3.new(),
								unit * random2:NextNumber(v21 * 3.5, v21 * 6.5),
								Vector3.new(0, -workspace.Gravity * random2:NextNumber(0.45, 1.3), 0),
								0.25 + random2:NextNumber(0, 2)
							),
							AngularVelocity = Vector3.new(
								random2:NextNumber(-1, 1),
								random2:NextNumber(-1, 1),
								random2:NextNumber(-1, 1)
							) * 2 * 3.141592653589793 * (1 / v24.Scale)
						})
					end
				end

				for _, emitter in pairs(clone6:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.TimeScale = 1
					emitter:Clear()
				end

				if (primaryPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 500 then
					local Effect = require(game.ReplicatedStorage.Effect)
					Effect.new("ColorCorrection"):replicate({
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(1, 1, 1),
							data.Player,
							"GravityFruitVFXColor"
						),
						Brightness = -200,
						Contrast = 3000,
						Saturation = -1.3,
						FadeIn = 0,
						FadeOut = 0,
						Lifetime = 0.1
					})
				end

				task.wait(0.05)
				task.spawn(function()
					if (primaryPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 500 then
						Util.CameraShaker:ShakeOnce(18, 18, 0.05, 2, createVector(1, 1, 1), createVector(1, 1, 1))
						local colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect")
						colorCorrectionEffect2.Parent = game.Lighting
						Util.Debris:AddItem(colorCorrectionEffect2, 1.5)
						TweenService:Create(
							colorCorrectionEffect2,
							TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
							{
								Brightness = 0.4,
								Contrast = 0.2,
								Saturation = 0,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 146, 83),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
						task.wait(0.1)
						TweenService:Create(
							colorCorrectionEffect2,
							TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Brightness = 0,
								Contrast = 0,
								Saturation = 0,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 255, 255),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
						local Effect = require(game.ReplicatedStorage.Effect)
						Effect.new("ColorCorrection"):replicate({
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(191, 111, 0),
								data.Player,
								"GravityFruitVFXColor"
							),
							Brightness = 1,
							Contrast = 1,
							Saturation = -1,
							FadeIn = 0,
							FadeOut = 0.3,
							Lifetime = 0
						})
					end
				end)
				local clone7 = c_Un.MeteorExplode:Clone()
				clone7.CFrame = primaryPart.CFrame
				Util.SetParentOverrideWithColor(clone7, folder, data.Player, "GravityFruitVFXColor")
				Util.Debris:AddItem(clone7, 7)
				emitAll(clone7)
				local play = Util.Sound:Play("GravFruit_V_Release_Meteor_Gigantic_Explosion_01", clone7.Position)
				play.Volume = 2
				meteor:Destroy()
				primaryPart:Destroy()
			end)
		end
	elseif stage == 3 then
		local folder_2 = Instance.new("Folder")
		folder_2.Parent = workspace._WorldOrigin
		local _ = data.Root
		require(game.ReplicatedStorage.Util.GravityRock)
		local root = data.Root
		local holding = data.Holding

		if not (holding or holding.Value) then
			return
		end

		local leftHand = root.Parent:FindFirstChild("LeftHand")
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		local FloorRipple = require(script.Parent.Modules.FloorRipple)
		FloorRipple({
			CFrame = root.CFrame,
			Holding = holding
		})
		local clone = V_ULT.handpart.Enable:Clone()
		Util.SetParentOverrideWithColor(clone, leftHand, data.Player, "GravityFruitVFXColor")

		for _, particlEmitter in pairs(clone:GetDescendants()) do
			if particlEmitter:IsA("ParticlEmitter") then
				particlEmitter.Enabled = true
			end
		end

		local clones = {}
		table.insert(clones, clone)
		task.spawn(function()
			local now = tick()
			local now2 = tick()
			local highlightGroup = Util.HighlightGroup.new(
				c_Un.PulseDistortBig.Highlight,
				workspace._WorldOrigin,
				"GravityDistortionBubble"
			)

			while true do
				task.wait()

				if now < tick() then
					now = tick() + 0.035

					if root.Parent == game.Players.LocalPlayer.Character then
						Util.CameraShaker:ShakeOnce(
							1,
							1,
							0.05,
							0.1,
							createVector(0.5, 0.5, 0.5),
							createVector(0.5, 0.3, 0.3)
						)
					end
				end

				if now2 < tick() then
					now2 = tick() + 0.1
					local clone2 = c_Un.PulseDistortBig:Clone()
					clone2.CFrame = leftHand.CFrame
					Util.SetParentOverrideWithColor(clone2, folder, data.Player, "GravityFruitVFXColor")
					highlightGroup:Insert(clone2)
					local tween = TweenService:Create(
						clone2,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					)
					tween.Completed:Connect(function()
						clone2:Destroy()
					end)
					tween:Play()
				end

				if holding:IsDescendantOf(workspace) and holding.Value then
					continue
				end

				task.wait(5)
				folder:Destroy()
				break
			end
		end)
		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.175

					if root.Parent == game.Players.LocalPlayer.Character then
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						colorCorrectionEffect.Parent = game.Lighting
						Util.Debris:AddItem(colorCorrectionEffect, 2.5)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.05, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
							{
								Brightness = -0.085,
								Contrast = 0.07,
								Saturation = -0.07,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(211, 207, 248),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
						task.wait(0.05)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Brightness = 0,
								Contrast = 0,
								Saturation = 0,
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 255, 255),
									data.Player,
									"GravityFruitVFXColor"
								)
							}
						):Play()
					end
				end
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)
		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.415
					emitAll(clone.Emit)
				end
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)

		if data.CanUltimate then
			task.delay(DELAY_DURATION, function()
				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(9, 9, 0.05, 0.2, createVector(1, 1, 1), createVector(1, 1, 1))
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					colorCorrectionEffect.Parent = game.Lighting
					Util.Debris:AddItem(colorCorrectionEffect, 0.5)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Brightness = 0,
							Contrast = 0.07,
							Saturation = -0.07,
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(205, 172, 212),
								data.Player,
								"GravityFruitVFXColor"
							)
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Brightness = 0,
							Contrast = 0,
							Saturation = 0,
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 255, 255),
								data.Player,
								"GravityFruitVFXColor"
							)
						}
					):Play()
				end
			end)
		end

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		task.wait(0.05)
		task.wait(0.15)

		for _, folder2 in pairs(clones) do
			if folder2:IsDescendantOf(workspace) then
				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			end

			local v = folder2
			task.spawn(function()
				task.wait(1)
				v:Destroy()
			end)
		end
	elseif stage == 4 then
		local root = data.Root
		local folder = Instance.new("Folder")
		folder.Name = root.Parent.Name .. "_GravUlt"
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 24.2)
		root:SetAttribute("GravityUlt", 3)
		local gravCachedUltimate = game.ReplicatedStorage.Assets.GravCachedUltimate
		local Lighting = game:GetService("Lighting")
		local sky = Lighting:FindFirstChildWhichIsA("Sky")
		local v = {
			"http://www.roblox.com/asset/?id=9709135895",
			"http://www.roblox.com/asset/?id=9709150401",
			"http://www.roblox.com/asset/?id=9709143733",
			"http://www.roblox.com/asset/?id=9709149052",
			"http://www.roblox.com/asset/?id=9709149431",
			"http://www.roblox.com/asset/?id=9709149680",
			"http://www.roblox.com/asset/?id=9709150086",
			"http://www.roblox.com/asset/?id=9709139597"
		}

		if data.NightShift then
			local caughtLighting = data.CaughtLighting
			local flag = false

			for _, v3 in pairs(caughtLighting) do
				local Players = game:GetService("Players")

				if v3 ~= Players.LocalPlayer then
					continue
				end

				flag = true
				break
			end

			if flag then
				local Lighting2 = game:GetService("Lighting")
				local clockTime = Lighting2.ClockTime
				local v3 = clockTime

				for _ = 1, 15.6 do
					v3 += 0.016666666666666666
				end

				task.spawn(function()
					sky.MoonTextureId = v[5]
					tweenClock(clockTime, 0, 1)
					tweenClock(0, 0, 14.6)
					v3 += 0.016666666666666666
					tweenClock(0, v3, 1)
					sky.MoonTextureId = v[game.Lighting:GetAttribute("MoonPhase")] or v[1]
				end)
			end
		end

		local sound = Util.Sound
		local Players = game:GetService("Players")
		local v2 = sound:Play("GravFruit_Ability_Cutscene_01_V2", Players.LocalPlayer.PlayerGui)
		local v3 = Util.Sound:Play("GravFruit_Ability_Cutscene_01_V2", root)
		task.wait(0.6)
		local flag = false

		for _, v5 in pairs(data.CaughtCutscene) do
			local Players2 = game:GetService("Players")

			if v5 ~= Players2.LocalPlayer then
				continue
			end

			flag = true
			break
		end

		if flag then
			Util.Sound:FadeOut(v3, 1)
		else
			Util.Sound:FadeOut(v2, 1)
		end

		local Players2 = game:GetService("Players")
		local localPlayer = Players2.LocalPlayer
		local v5 = false
		local renderSteppedConnection = nil
		local _ = currentCamera.CFrame

		if flag then
			currentCamera.CameraType = Enum.CameraType.Scriptable
		end

		local clone = gravCachedUltimate.UltimateModel:Clone()
		clone:PivotTo(root.CFrame)

		if not flag then
			clone["Biggest Asteroid"]:PivotTo(CFrame.lookAt(
				createVector(0, 0, 0),
				clone["Biggest Asteroid"].RootPart.CFrame.LookVector
			) + data.TargetPosition)
			clone["supporting asteroids"].PrimaryPart.Position = data.TargetPosition
			clone["additional landign rocks"].PrimaryPart.Position = data.TargetPosition
		end

		Util.SetParentOverrideWithColor(clone, folder, data.Player, "GravityFruitVFXColor")
		Util.Debris:AddItem(clone, 23.2)
		local clone2 = nil
		local v6 = nil
		local clone3 = gravCachedUltimate.Atmosphere:Clone()
		clone3:SetAttribute("Intensity", flag and 1 or 0)
		clone3:SetAttribute("ZIndex", flag and 15 or 0)
		local setParentOverrideWithColor = Util.SetParentOverrideWithColor
		local Lighting2 = game:GetService("Lighting")
		setParentOverrideWithColor(clone3, Lighting2.LightingLayers, data.Player, "GravityFruitVFXColor")
		Util.Debris:AddItem(clone3, 15.2)
		local clone4

		if flag then
			clone2 = gravCachedUltimate.BampBloom:Clone()
			clone2.Parent = game:GetService("Lighting")
			clone4 = gravCachedUltimate.GravityColor:Clone()
			clone4.Parent = game:GetService("Lighting")
			Util.Debris:AddItem(clone2, 15.2)
			Util.Debris:AddItem(clone4, 15.2)
		else
			clone4 = nil
		end

		local clone5 = gravCachedUltimate.Aurora:Clone()
		Util.SetParentOverrideWithColor(clone5, folder, data.Player, "GravityFruitVFXColor")
		local humanoid = root.Parent.Humanoid
		local v7 = root.Size.Y * 0.5 + humanoid.HipHeight + 0.5
		local clone6 = gravCachedUltimate.burnfloor:Clone()
		clone6.CanCollide = false
		Util.SetParentOverrideWithColor(clone6, folder, data.Player, "GravityFruitVFXColor")
		clone6.CFrame = CFrame.new(data.TargetPosition) * CFrame.new(0, 2, 0)
		local ray, v8 = Util.Ray(
			root.Position,
			createVector(0, 1, 0) * -(v7 + 1),
			{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		)
		local clone7 = gravCachedUltimate.vFloor:Clone()
		clone7.CanCollide = false
		Util.SetParentOverrideWithColor(clone7, folder, data.Player, "GravityFruitVFXColor")
		clone7.CFrame = root.CFrame * CFrame.new(0, -v7 / 2 + 0.2, 0)

		if ray then
			clone6.Position = Vector3.new(clone6.Position.X, v8.Y + 3.7, clone6.Position.Z)
			clone7.Position = Vector3.new(clone7.Position.X, v8.Y + 0.05, clone7.Position.Z)
		end

		local clone8 = gravCachedUltimate.HandEffects:Clone()
		local folder2 = Instance.new("Folder")
		folder2.Name = "BFBlend"
		folder2.Parent = clone
		clone8.Name = "LeftHand"
		clone8.CFrame = root.Parent.LeftHand.CFrame
		Util.SetParentOverrideWithColor(clone8, folder2, data.Player, "GravityFruitVFXColor")
		local clone9 = gravCachedUltimate.RootEffects:Clone()
		clone9.CanCollide = false
		clone9.CFrame = root.CFrame
		clone9.Name = "HumanoidRootPart"
		Util.SetParentOverrideWithColor(clone9, folder2, data.Player, "GravityFruitVFXColor")
		Util.Debris:AddItem(clone8, 16.2)
		local descendants = clone:GetDescendants()
		local v9 = {}
		local characterRemovingConnection = nil

		for _, instance in descendants do
			if instance:IsA("BasePart") then
				if instance.Transparency < 1 then
					table.insert(v9, { instance, instance.Transparency })
					instance.Transparency = 1
				end

				instance.CanCollide = false
				instance.CanQuery = false
				instance.CanTouch = false
			elseif (instance:IsA("Trail") or instance:IsA("Beam")) and instance.Enabled then
				instance.Enabled = false
				table.insert(v9, { instance })
			end
		end

		if not flag then
			clone.CameraPart.Flash.SpotLight.Enabled = false
		end

		task.delay(4, function()
			if not flag then
				for _, instance in descendants do
					if instance:IsA("BasePart") then
						instance.Transparency = 1
					elseif instance:IsA("Trail") or instance:IsA("Beam") then
						instance.Enabled = false
					end
				end

				task.wait(7)
			end

			for _, v10 in v9 do
				local instance = v10[1]

				if instance:IsA("BasePart") then
					instance.Transparency = v10[2]
				elseif instance:IsA("Trail") or instance:IsA("Beam") then
					instance.Enabled = true
				end
			end

			if not flag then
				clone["supporting asteroids"]["Plane.004"].Transparency = 0
				clone["additional landign rocks"]["Medium.002"].Transparency = 0
				clone["Large meteors more"]["Medium.001"].Transparency = 0
				clone["Biggest Asteroid"]["Plane.001"].Transparency = 0
			end

			task.wait(9)

			for _, v10 in v9 do
				local instance = v10[1]

				if instance:IsA("BasePart") then
					instance.Transparency = 1
				elseif instance:IsA("Trail") or instance:IsA("Beam") then
					instance.Enabled = false
				end
			end

			clone["additional landign rocks"]["Medium.002"].Transparency = 1

			for _, effect in pairs(clone["additional landign rocks"].trails:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			v9 = nil
		end)
		task.spawn(function()
			local lastTime = tick()
			pcall(function()
				while tick() - lastTime < 14.2 and not v5 do
					clone8.CFrame = root.Parent.LeftHand.CFrame
					clone9.CFrame = root.CFrame
					RunService.Heartbeat:Wait()
				end
			end)
		end)
		local v10 = false
		task.delay(flag and 12 or 0.1, function()
			if not v5 then
				v10 = true
				clone.BloxMoon:Destroy()
				clone.BloxEarth:Destroy()
				clone.MediumRocks:Destroy()
				clone.SmallRocks:Destroy()
			end
		end)
		local part = nil

		local function clear()
			v5 = true
			task.spawn(function()
				TweenService:Create(workspace.Camera, TweenInfo.new(0.2), {
					FieldOfView = 70
				}):Play()
				task.wait()
				TweenService:Create(workspace.Camera, TweenInfo.new(0.2), {
					FieldOfView = 70
				}):Play()
				task.wait()
				TweenService:Create(workspace.Camera, TweenInfo.new(1), {
					FieldOfView = 70
				}):Play()
			end)

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end

			if characterRemovingConnection then
				characterRemovingConnection:Disconnect()
			end

			if clone2 then
				clone2:Destroy()
			end

			if v6 then
				v6:Destroy()
			end

			if clone4 then
				clone4:Destroy()
			end

			if clone3 then
				clone3:SetAttribute("Intensity", 0)
				clone3:SetAttribute("ZIndex", -1)
				task.delay(3, function()
					clone3:Destroy()
				end)
			end

			pcall(function()
				part:Destroy()
			end)
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.FieldOfView = 70

			if v2 then
				Util.Sound:FadeOut(v2, 0.5)
			end

			if v3 then
				Util.Sound:FadeOut(v3, 0.5)
			end

			task.delay(5, function()
				if folder then
					folder:Destroy()
				end
			end)
		end

		local now = false
		task.spawn(function()
			task.wait()
			os.clock()
			local v11 = {}
			local v12 = {
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.SmallRocks,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.MediumRocks,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxEarth,
				game.Workspace.CurrentCamera,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.CameraPart,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["Large meteors more"],
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon.MoonExplode.neonmoon,
				{},
				game.Lighting:FindFirstChild("GravityColor"),
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon.MoonExplode.lightbamp.PointLight,
				game.Lighting:FindFirstChild("BampBloom"),
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon.MoonExplode.Aurora.Fire,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["Biggest Asteroid"],
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"],
				game.Workspace._WorldOrigin[folder.Name].Aurora,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["supporting asteroids"],
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m14.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m13.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m12.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m11.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m10.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m9.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m8.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m7.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m6.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m5.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m4.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m3.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m2.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m15.Attachment.t2.SpikyTrail,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel["additional landign rocks"].trails.m1.Attachment.t2.SpikyTrail,
				game.Lighting,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.CameraPart.Cam.around.Flash,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.CameraPart.Cam.around.Flash2,
				clone3,
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.HumanoidRootPart.Attachment.PointLight
			}
			local v13 = tweenProperty
			local fn = not flag and function(p, ...)
				if not p then
					return
				end

				if p == v12[6] or p == v12[10] or p == v12[11] or p == v12[12] or p == v12[13] or p == v12[34] or p == v12[37] then
					return
				end

				v13(p, ...)
			end or tweenProperty
			v12[6].FieldOfView = 70
			v12[9].Transparency = 0

			if flag then
				v12[11].TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 255, 255),
					data.Player,
					"GravityFruitVFXColor"
				)
				v12[11].Brightness = 0
				v12[11].Saturation = 0
				v12[11].Contrast = 0
				v12[12].Range = 60
				v12[12].Brightness = 11.420000076293945
				v12[13].Threshold = 2
				v12[13].Intensity = 1
				v12[13].Size = 24
			end

			v12[14].Enabled = false
			v12[17].CFrame = root.CFrame * CFrame.new(9000, 9000, 9000)
			v12[19].Enabled = true
			v12[20].Enabled = true
			v12[21].Enabled = true
			v12[22].Enabled = true
			v12[23].Enabled = true
			v12[24].Enabled = true
			v12[25].Enabled = true
			v12[26].Enabled = true
			v12[27].Enabled = true
			v12[28].Enabled = true
			v12[29].Enabled = true
			v12[30].Enabled = true
			v12[31].Enabled = true
			v12[32].Enabled = true
			v12[33].Enabled = true
			v12[35].Enabled = flag
			v12[36].Enabled = flag

			if flag then
				v12[37].Density = 0.25
			end

			v12[38].Color = Util.WrapColor3Constructor(
				Color3.fromRGB(148, 94, 255),
				data.Player,
				"GravityFruitVFXColor"
			)
			v12[38].Brightness = 3.0799999237060547
			v12[38].Range = 8

			v11[0] = function()
				fn(v12[6], "FieldOfView", 90, 0.45, "Linear", nil)
				fn(v12[9], "Transparency", 1, 3.96667, "Linear", nil)
				fn(v12[12], "Range", 0, 3.9, "Linear", nil)
				fn(v12[12], "Brightness", 0, 3.9, "Linear", nil)
				fn(v12[14], "Enabled", false, 7.8, "Constant", nil)
				fn(v12[19], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[20], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[21], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[22], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[23], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[24], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[25], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[26], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[27], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[28], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[29], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[30], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[31], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[32], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[33], "Enabled", false, 10.06667, "Constant", nil)
				fn(v12[35], "Enabled", false, 10.38333, "Constant", nil)
				fn(v12[36], "Enabled", false, 10.38333, "Constant", nil)
				fn(v12[37], "Density", 0.25, 0.41667, "Linear", nil)
				fn(
					v12[38],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(148, 94, 255), data.Player, "GravityFruitVFXColor"),
					0.46667,
					"Linear",
					nil
				)
				fn(v12[38], "Brightness", 0, 0.46667, "Linear", nil)
				fn(v12[38], "Range", 8, 0.46667, "Linear", nil)
			end

			v11[20] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.LeftHand.EmitFirst)
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(182, 115, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", -0.5, 0.03333, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.03333, "Linear", nil)
				fn(v12[11], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v11[22] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(107, 74, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.7, 0.03333, "Linear", nil)
				fn(v12[11], "Saturation", -0.7, 0.03333, "Linear", nil)
				fn(v12[11], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v11[24] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(212, 169, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.19999999999999998, 0.01667, "Linear", nil)
				fn(v12[11], "Saturation", -0.39999999999999997, 0.01667, "Linear", nil)
				fn(v12[11], "Contrast", 0.3, 0.01667, "Linear", nil)
			end

			v11[25] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.81667,
					"Bounce",
					"In"
				)
				fn(v12[11], "Brightness", -0.19999999999999998, 0.81667, "Bounce", "In")
				fn(v12[11], "Saturation", 0, 0.81667, "Bounce", "In")
				fn(v12[11], "Contrast", 0, 0.81667, "Bounce", "In")
				fn(v12[37], "Density", 0.7, 0.48333, "Linear", nil)
			end

			v11[27] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.LeftHand.EnableFirst)
				fn(v12[6], "FieldOfView", 40, 0.78333, "Quint", "In")
			end

			v11[28] = function()
				fn(
					v12[38],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(66, 4, 255), data.Player, "GravityFruitVFXColor"),
					0.13333,
					"Linear",
					nil
				)
				fn(v12[38], "Brightness", 8, 0.13333, "Linear", nil)
				fn(v12[38], "Range", 8, 0.13333, "Linear", nil)
			end

			v11[36] = function()
				fn(
					v12[38],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(148, 94, 255), data.Player, "GravityFruitVFXColor"),
					0.63333,
					"Bounce",
					"In"
				)
				fn(v12[38], "Brightness", 0, 0.63333, "Bounce", "In")
				fn(v12[38], "Range", 8, 0.63333, "Bounce", "In")
			end

			v11[54] = function()
				fn(v12[37], "Density", 0.25, 0.38333, "Linear", nil)
			end

			v11[74] = function()
				fn(v12[6], "FieldOfView", 120, 0.11667, "Linear", nil)
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(132, 102, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 2, 0.01667, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.01667, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.01667, "Linear", nil)
				fn(
					v12[38],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(66, 4, 255), data.Player, "GravityFruitVFXColor"),
					0.08333,
					"Linear",
					nil
				)
				fn(v12[38], "Brightness", 4, 0.08333, "Linear", nil)
				fn(v12[38], "Range", 8, 0.08333, "Linear", nil)
			end

			v11[75] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.LeftHand.EnableSecond)
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.13333,
					"Bounce",
					"In"
				)
				fn(v12[11], "Brightness", -0.7, 0.13333, "Bounce", "In")
				fn(v12[11], "Saturation", 0, 0.13333, "Bounce", "In")
				fn(v12[11], "Contrast", 0, 0.13333, "Bounce", "In")
			end

			v11[76] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.LeftHand.Pop)
			end

			v11[77] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].vFloor)
				fn(v12[37], "Density", 0.25, 9.33333, "Linear", nil)
			end

			v11[79] = function()
				fn(
					v12[38],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(66, 4, 255), data.Player, "GravityFruitVFXColor"),
					0.8,
					"Bounce",
					"In"
				)
				fn(v12[38], "Brightness", 8, 0.8, "Bounce", "In")
				fn(v12[38], "Range", 8, 0.8, "Bounce", "In")
			end

			v11[81] = function()
				fn(v12[6], "FieldOfView", 60, 0.11667, "Linear", nil)
			end

			v11[83] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.2,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.09999999999999999, 0.2, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.2, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.2, "Linear", nil)
			end

			v11[88] = function()
				fn(v12[6], "FieldOfView", 60, 0.3, "Linear", nil)
			end

			v11[95] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(188, 139, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					1.03333,
					"Bounce",
					"In"
				)
				fn(v12[11], "Brightness", -0.19999999999999998, 1.03333, "Bounce", "In")
				fn(v12[11], "Saturation", 0, 1.03333, "Bounce", "In")
				fn(v12[11], "Contrast", 0, 1.03333, "Sine", "In")
			end

			v11[106] = function()
				fn(v12[6], "FieldOfView", 40, 0.83333, "Linear", nil)
			end

			v11[127] = function()
				fn(
					v12[38],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(148, 94, 255), data.Player, "GravityFruitVFXColor"),
					1.25,
					"Bounce",
					"In"
				)
				fn(v12[38], "Brightness", 0, 1.25, "Bounce", "In")
				fn(v12[38], "Range", 8, 1.25, "Bounce", "In")
			end

			v11[156] = function()
				fn(v12[6], "FieldOfView", 95, 0.06667, "Back", "InOut", 1.70158)
			end

			v11[157] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(182, 115, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", -0.5, 0.03333, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.03333, "Linear", nil)
				fn(v12[11], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v11[159] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(107, 74, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 3, 0.01667, "Linear", nil)
				fn(v12[11], "Saturation", -0.7, 0.03333, "Linear", nil)
				fn(v12[11], "Contrast", 1, 0.03333, "Linear", nil)
			end

			v11[160] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.LeftHand.EnableThird)
				fn(v12[6], "FieldOfView", 40, 0.05, "Back", "InOut", 1.70158)
				fn(v12[11], "Brightness", 0.19999999999999998, 0.03333, "Linear", nil)
			end

			v11[161] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(212, 169, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				fn(v12[11], "Saturation", -0.39999999999999997, 0.01667, "Linear", nil)
				fn(v12[11], "Contrast", 0.3, 0.01667, "Linear", nil)
			end

			v11[162] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 177, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.6,
					"Bounce",
					"In"
				)
				fn(v12[11], "Brightness", -0.19999999999999998, 0.6, "Bounce", "In")
				fn(v12[11], "Saturation", -0.002209641970694065, 0.6, "Bounce", "In")
				fn(v12[11], "Contrast", 0.0016572315944358706, 0.6, "Bounce", "In")
			end

			v11[163] = function()
				fn(v12[6], "FieldOfView", 110, 0.56667, "Cubic", "In")
			end

			v11[197] = function()
				fn(v12[6], "FieldOfView", 70, 0.01667, "Linear", nil)
			end

			v11[198] = function()
				fn(v12[6], "FieldOfView", 65, 0.41667, "Linear", nil)
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.01667,
					"Bounce",
					"In"
				)
				fn(v12[11], "Brightness", 0, 0.01667, "Bounce", "In")
				fn(v12[11], "Saturation", 0, 0.01667, "Bounce", "In")
				fn(v12[11], "Contrast", 0, 0.01667, "Bounce", "In")
			end

			v11[199] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.5,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0, 0.5, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.5, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.5, "Linear", nil)
			end

			v11[201] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxEarth.earth.emit2)
			end

			v11[202] = function()
				fn(
					v12[38],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(66, 4, 255), data.Player, "GravityFruitVFXColor"),
					1.48333,
					"Linear",
					nil
				)
				fn(v12[38], "Brightness", 8, 1.48333, "Linear", nil)
				fn(v12[38], "Range", 8, 1.48333, "Linear", nil)
			end

			v11[208] = function() end

			v11[210] = function() end

			v11[214] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon.MoonExplode.dre)
			end

			v11[223] = function()
				fn(v12[6], "FieldOfView", 75, 0.13333, "Quad", "In")
			end

			v11[224] = function()
				fn(v12[13], "Threshold", 1.6859999895095825, 0.58333, "Linear", nil)
				fn(v12[13], "Intensity", 1, 0.58333, "Linear", nil)
				fn(v12[13], "Size", 55, 0.58333, "Linear", nil)
			end

			v11[229] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(217, 208, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.3, 0.01667, "Linear", nil)
				fn(v12[11], "Saturation", -0.800000011920929, 0.01667, "Linear", nil)
				fn(v12[11], "Contrast", 0.4000000059604645, 0.01667, "Linear", nil)
			end

			v11[230] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(176, 96, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.05,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0, 0.05, "Linear", nil)
				fn(v12[11], "Saturation", -0.800000011920929, 0.05, "Linear", nil)
				fn(v12[11], "Contrast", 0.4000000059604645, 0.05, "Linear", nil)
			end

			v11[231] = function()
				fn(v12[6], "FieldOfView", 40, 0.05, "Linear", nil)
			end

			v11[232] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon.MoonExplode.pre)
			end

			v11[233] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.1,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0, 0.1, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.1, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.1, "Linear", nil)
			end

			v11[234] = function()
				fn(v12[6], "FieldOfView", 70, 0.13333, "Sine", "Out")
				fn(v12[12], "Range", 60, 0.3, "Linear", nil)
				fn(v12[12], "Brightness", 15, 0.3, "Expo", "In")
			end

			v11[236] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon.MoonExplode.part)
			end

			v11[238] = function()
				fn(v12[9], "Transparency", 0, 0.9, "Linear", nil)
			end

			v11[239] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 3, 0.01667, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.01667, "Linear", nil)
				fn(v12[11], "Contrast", 3, 0.01667, "Linear", nil)
			end

			v11[240] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", -0.5, 0.01667, "Linear", nil)
				fn(v12[11], "Contrast", -1, 0.01667, "Linear", nil)
			end

			v11[241] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(146, 113, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.5, 0.01667, "Linear", nil)
				fn(v12[11], "Contrast", 3, 0.01667, "Linear", nil)
			end

			v11[242] = function()
				fn(v12[6], "FieldOfView", 95, 0.83333, "Cubic", "In")
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.19999999999999998, 0.01667, "Linear", nil)
				fn(v12[11], "Saturation", 1.2, 0.01667, "Linear", nil)
				fn(v12[11], "Contrast", 0.5, 0.01667, "Linear", nil)
			end

			v11[243] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(176, 159, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.81667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.3, 0.81667, "Linear", nil)
				fn(v12[11], "Saturation", -0.5, 0.81667, "Linear", nil)
				fn(v12[11], "Contrast", 1, 0.81667, "Bounce", "In")
			end

			v11[252] = function() end

			v11[259] = function()
				fn(v12[13], "Threshold", 1.6859999895095825, 5.61667, "Linear", nil)
				fn(v12[13], "Intensity", 1, 5.61667, "Linear", nil)
				fn(v12[13], "Size", 55, 5.61667, "Linear", nil)
			end

			v11[270] = function() end

			v11[276] = function() end

			v11[291] = function()
				fn(
					v12[38],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(148, 94, 255), data.Player, "GravityFruitVFXColor"),
					0.86667,
					"Bounce",
					"InOut"
				)
				fn(v12[38], "Brightness", 0, 0.86667, "Bounce", "InOut")
				fn(v12[38], "Range", 8, 0.86667, "Bounce", "InOut")
			end

			v11[292] = function()
				fn(v12[6], "FieldOfView", 75, 0.01667, "Linear", nil)
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0, 0.01667, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.01667, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.01667, "Linear", nil)
			end

			v11[293] = function()
				fn(v12[6], "FieldOfView", 120, 0.73333, "Linear", nil)
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.71667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", -0.19999999999999998, 0.71667, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.71667, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.71667, "Linear", nil)
			end

			v11[334] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.LeftHand.Pop2)
			end

			v11[336] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(132, 102, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.01667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 2, 0.01667, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.01667, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.01667, "Linear", nil)
			end

			v11[337] = function()
				fn(v12[6], "FieldOfView", 40, 0.03333, "Linear", nil)
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.13333,
					"Bounce",
					"In"
				)
				fn(v12[11], "Brightness", -0.7, 0.13333, "Bounce", "In")
				fn(v12[11], "Saturation", 0, 0.13333, "Bounce", "In")
				fn(v12[11], "Contrast", 0, 0.13333, "Bounce", "In")
			end

			v11[339] = function()
				fn(v12[6], "FieldOfView", 111, 0.58333, "Linear", nil)
			end

			v11[343] = function()
				fn(
					v12[38],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(66, 4, 255), data.Player, "GravityFruitVFXColor"),
					0.33333,
					"Linear",
					nil
				)
				fn(v12[38], "Brightness", 8, 0.33333, "Linear", nil)
				fn(v12[38], "Range", 8, 0.33333, "Linear", nil)
			end

			v11[344] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.LeftHand.EnableFirst)
			end

			v11[345] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.LeftHand.EnableSecond)
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.2,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.09999999999999999, 0.2, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.2, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.2, "Linear", nil)
			end

			v11[357] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.88333,
					"Bounce",
					"In"
				)
				fn(v12[11], "Brightness", 0.10000000149011612, 0.88333, "Bounce", "In")
				fn(v12[11], "Saturation", 0, 0.88333, "Bounce", "In")
				fn(v12[11], "Contrast", 0, 0.88333, "Bounce", "In")
			end

			v11[363] = function()
				fn(
					v12[38],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(66, 4, 255), data.Player, "GravityFruitVFXColor"),
					4.05,
					"Bounce",
					"InOut"
				)
				fn(v12[38], "Brightness", 8, 4.05, "Bounce", "InOut")
				fn(v12[38], "Range", 8, 4.05, "Bounce", "InOut")
			end

			v11[374] = function()
				fn(v12[6], "FieldOfView", 80, 0.01667, "Linear", nil)
			end

			v11[375] = function()
				fn(v12[6], "FieldOfView", 60, 0.6, "Quad", "Out")
			end

			v11[376] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.CameraPart.Cam.beamszoom)
			end

			v11[379] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon.MoonExplode.pre2)
			end

			v11[383] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.CameraPart.Cam.pop)
			end

			v11[388] = function()
				task.spawn(
					Emit,
					game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon.MoonExplode.glowup.first
				)
			end

			v11[395] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon.MoonExplode.bre)
			end

			v11[410] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.15,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 1.5, 0.15, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.15, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.15, "Linear", nil)
			end

			v11[411] = function()
				fn(v12[6], "FieldOfView", 16, 0.13333, "Linear", nil)
			end

			v11[419] = function()
				fn(v12[6], "FieldOfView", 120, 0.01667, "Linear", nil)
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.13333,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.10000000149011612, 0.13333, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.13333, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.13333, "Linear", nil)
			end

			v11[420] = function()
				fn(v12[6], "FieldOfView", 85, 0.78333, "Linear", nil)
			end

			v11[427] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.65,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.10000000149011612, 0.65, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.65, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.65, "Linear", nil)
			end

			v11[432] = function()
				task.spawn(
					Emit,
					game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon.MoonExplode.glowup.second
				)
			end

			v11[466] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 124, 63),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.05,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 1.7999999999999998, 0.05, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.05, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.05, "Linear", nil)
			end

			v11[467] = function()
				fn(v12[6], "FieldOfView", 90, 0.01667, "Linear", nil)
			end

			v11[468] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxMoon.MoonExplode.tre)
				fn(v12[6], "FieldOfView", 45, 2.16667, "Expo", "In")
				fn(v12[14], "Enabled", true, 0.03333, "Constant", nil)
			end

			v11[469] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.36667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.10000000149011612, 0.36667, "Sine", "Out")
				fn(v12[11], "Saturation", 0, 0.36667, "Linear", nil)
				fn(v12[11], "Contrast", 0, 0.36667, "Linear", nil)
			end

			v11[470] = function() end

			v11[484] = function() end

			v11[491] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					1.73333,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.10000000149011612, 1.73333, "Linear", nil)
				fn(v12[11], "Saturation", 0, 1.73333, "Linear", nil)
				fn(v12[11], "Contrast", 0, 1.73333, "Linear", nil)
			end

			v11[544] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BloxEarth.earth.emit)
			end

			v11[562] = function() end

			v11[574] = function()
				if flag then
					local v15 = root.CFrame * CFrame.new(-173.276, 417.793, 276.775) * CFrame.Angles(
						0.1297652298857784,
						1.0134079768779876,
						-2.341306831672833
					)
					fn(v12[17], "CFrame", v15, 0.01667, "Linear", nil)
				else
					local v15 = (CFrame.lookAt(createVector(0, 0, 0), root.CFrame.LookVector) + data.TargetPosition) * CFrame.new(
						-173.276,
						417.793,
						276.775
					) * CFrame.Angles(0.1297652298857784, 1.0134079768779876, -2.341306831672833)
					fn(v12[17], "CFrame", v15, 0.01667, "Linear", nil)
				end
			end

			v11[575] = function() end

			v11[594] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.LeftHand.EnableFirst)
			end

			v11[595] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.06667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 1, 0.06667, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.06667, "Linear", nil)
				fn(v12[11], "Contrast", 0.5, 0.06667, "Linear", nil)
			end

			v11[596] = function()
				fn(v12[13], "Threshold", 1.6859999895095825, 0.21667, "Linear", nil)
				fn(v12[13], "Intensity", 1, 0.21667, "Linear", nil)
				fn(v12[13], "Size", 25, 0.21667, "Linear", nil)
			end

			v11[598] = function()
				fn(v12[6], "FieldOfView", 45, 0.01667, "Linear", nil)
			end

			v11[599] = function()
				fn(v12[6], "FieldOfView", 60, 1.56667, "Back", "InOut", 1.70158)
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.86667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.10000000149011612, 0.86667, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.86667, "Linear", nil)
			end

			v11[600] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel["supporting asteroids"])
			end

			v11[604] = function()
				fn(v12[19], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[20], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[21], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[22], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[23], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[24], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[25], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[26], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[27], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[28], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[29], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[30], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[31], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[32], "Enabled", true, 0.01667, "Constant", nil)
				fn(v12[33], "Enabled", true, 0.01667, "Constant", nil)
			end

			v11[605] = function()
				fn(v12[19], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[20], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[21], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[22], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[23], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[24], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[25], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[26], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[27], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[28], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[29], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[30], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[31], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[32], "Enabled", false, 3.91667, "Constant", nil)
				fn(v12[33], "Enabled", false, 3.91667, "Constant", nil)
			end

			v11[606] = function()
				fn(
					v12[38],
					"Color",
					Util.WrapColor3Constructor(Color3.fromRGB(255, 95, 20), data.Player, "GravityFruitVFXColor"),
					0.46667,
					"Bounce",
					"InOut"
				)
				fn(v12[38], "Brightness", 0, 0.46667, "Bounce", "InOut")
				fn(v12[38], "Range", 8, 0.46667, "Bounce", "InOut")
			end

			v11[609] = function()
				fn(v12[13], "Threshold", 1.6859999895095825, 2.55, "Linear", nil)
				fn(v12[13], "Intensity", 1, 2.55, "Linear", nil)
				fn(v12[13], "Size", 55, 2.55, "Linear", nil)
			end

			v11[623] = function()
				fn(v12[35], "Enabled", true, 0.1, "Constant", nil)
				fn(v12[36], "Enabled", true, 0.1, "Constant", nil)
			end

			v11[629] = function()
				fn(v12[35], "Enabled", false, 2.91667, "Constant", nil)
				fn(v12[36], "Enabled", false, 2.91667, "Constant", nil)
			end

			v11[634] = function() end

			v11[637] = function()
				fn(v12[37], "Density", 0, 0.43333, "Linear", nil)
			end

			v11[651] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.7,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.10000000149011612, 0.7, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.7, "Linear", nil)
			end

			v11[663] = function() end

			v11[693] = function()
				fn(v12[6], "FieldOfView", 60, 0.08333, "Linear", nil)
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.33333,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 2, 0.01667, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.33333, "Linear", nil)
			end

			v11[694] = function()
				fn(v12[11], "Brightness", 0.10000000149011612, 0.08333, "Linear", nil)
			end

			v11[695] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.HumanoidRootPart.first)
			end

			v11[698] = function()
				fn(v12[6], "FieldOfView", 60, 1.01667, "Linear", nil)
			end

			v11[699] = function()
				fn(v12[11], "Brightness", 0.10000000149011612, 0.23333, "Linear", nil)
			end

			v11[701] = function() end

			v11[713] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.46667,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 2, 0.01667, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.46667, "Linear", nil)
			end

			v11[714] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.HumanoidRootPart.second)
				fn(v12[11], "Brightness", 0.10000000149011612, 0.08333, "Linear", nil)
			end

			v11[719] = function()
				fn(v12[11], "Brightness", 0.10000000149011612, 0.36667, "Linear", nil)
			end

			v11[741] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(218, 197, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.33333,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 2, 0.01667, "Linear", nil)
				fn(v12[11], "Saturation", 0, 0.33333, "Linear", nil)
			end

			v11[742] = function()
				fn(v12[11], "Brightness", 0.10000000149011612, 0.08333, "Linear", nil)
			end

			v11[744] = function()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.HumanoidRootPart.third)
			end

			v11[747] = function()
				fn(v12[11], "Brightness", 0.10000000149011612, 0.23333, "Linear", nil)
			end

			v11[759] = function()
				fn(v12[6], "FieldOfView", 100, 0.05, "Linear", nil)
			end

			v11[761] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 122, 107),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.03333,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", -2, 0.01667, "Linear", nil)
			end

			v11[762] = function()
				fn(v12[6], "FieldOfView", 70, 1.65, "Back", "In", 1.70158)
				fn(v12[11], "Brightness", 2, 0.01667, "Linear", nil)
				fn(v12[13], "Threshold", 0.800000011920929, 0.15, "Linear", nil)
				fn(v12[13], "Intensity", 1, 0.15, "Linear", nil)
				fn(v12[13], "Size", 55, 0.15, "Linear", nil)
			end

			v11[763] = function()
				fn(
					v12[11],
					"TintColor",
					Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						data.Player,
						"GravityFruitVFXColor"
					),
					0.63333,
					"Linear",
					nil
				)
				fn(v12[11], "Brightness", 0.10000000149011612, 0.46667, "Sine", "Out")
			end

			v11[764] = function()
				now = tick()
				game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.HumanoidRootPart.fourth.HitFX.WorldPosition = game.Workspace._WorldOrigin[folder.Name].burnfloor.Position + createVector(
					0,
					4,
					0
				)
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].UltimateModel.BFBlend.HumanoidRootPart.fourth)
			end

			v11[771] = function()
				fn(v12[13], "Threshold", 1.6859999895095825, 1.5, "Linear", nil)
				fn(v12[13], "Intensity", 1, 1.5, "Linear", nil)
				fn(v12[13], "Size", 55, 1.5, "Linear", nil)
			end

			v11[772] = function()
				clone5:Destroy()
				task.spawn(Emit, game.Workspace._WorldOrigin[folder.Name].burnfloor)

				for _, part2 in pairs(descendants) do
					if part2:IsA("BasePart") then
						part2.Transparency = 1
					end
				end

				for _, descendant in pairs(clone:GetDescendants()) do
					if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("SpotLight")) then
						continue
					end

					descendant.Enabled = false
				end

				task.spawn(function()
					local v15 = Util.Sound:Play("GravFruit_VFloor", clone6.Position)
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(v15, TweenInfo.new(1), {
						Volume = 1.2
					}):Play()
					task.wait(4)
					Util.Sound:FadeOut(v15, 1)
				end)
				local ray2 = Util.Ray
				local v15 = clone6.Position + createVector(0, 1, 0)
				local v16 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
				local v17, v18, v19 = ray2(v15, createVector(-0, -20, -0), v16)

				if v17 then
					local v20 = CFrame.new(v18, v18 + v19) * CFrame.Angles(-1.5707963267948966, 0, 0)
					local random = Random.new()
					local v21 = 200
					local v22 = math.max(6, v21 / 3)
					local v23 = v21 / 4

					for i = 1, v23 do
						local v24 = 6.283185307179586 * (i / v23)
						local v25 = Rock2.new({
							Type = "Ground",
							FadeOut = { 0.5, 1 },
							FadeIn = { 0.5, 1 },
							Lifetime = { 1.5, 4.5 },
							Size = Vector3.new(
								random:NextNumber(1, 2),
								random:NextNumber(1, 2),
								random:NextNumber(1, 2)
							),
							Scale = { v22 / 4, v22 / 2 }
						})

						if random:NextInteger(1, 8) % 4 == 0 then
							local unit = Vector3.new(
								math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
								random:NextNumber(0, 1) * 1.25,
								math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
							).Unit
							v25.Type = "Flying"
							v25:Spawn(v20 * CFrame.Angles(0, v24, 0) * CFrame.new(0, 0, -150 * math.random(1, 4) * 0.25))
							v25:Eject({
								Velocity = Util.Misc.Physics.Velocity(
									Vector3.new(),
									unit * random:NextNumber(v22 * 2, v22 * 8) * 1.25,
									Vector3.new(0, -workspace.Gravity * random:NextNumber(0.25, 1), 0),
									0.25 + random:NextNumber(0, 2)
								),
								AngularVelocity = Vector3.new(
									random:NextNumber(-1, 1),
									random:NextNumber(-1, 1),
									random:NextNumber(-1, 1)
								) * 2 * 3.141592653589793 * (1 / v25.Scale)
							})
						else
							v25:Spawn(v20 * CFrame.Angles(0, v24, 0) * CFrame.new(0, 0, -150 * math.random(1, 4) * 0.25))
							v25:TweenShift(
								(v20 * CFrame.Angles(0, v24, 0)).LookVector * v22 * random:NextNumber(1, 2),
								0.5
							)
						end
					end
				end
			end

			v11[791] = function() end

			v11[801] = function() end

			v11[804] = function()
				fn(v12[35], "Enabled", false, 0.95, "Constant", nil)
				fn(v12[36], "Enabled", false, 0.95, "Constant", nil)
			end

			v11[840] = function() end

			v11[861] = function()
				folder.Name = "ENDED"

				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()

					if characterRemovingConnection then
						characterRemovingConnection:Disconnect()
					end

					pcall(function()
						part:Destroy()
					end)
					currentCamera.CameraType = Enum.CameraType.Custom
				end
			end

			if flag then
				_G.updateMusic2(true)
			end

			local total = 0
			local v15 = -1

			while not v5 do
				local v16 = total * 60 // 1
				local v17 = v16 - v15

				if v17 > 0 then
					for i = v15 + 1, v15 + v17 do
						local v18 = v11[i]

						if v18 then
							pcall(v18)
						end
					end

					v15 = v16
				end

				total += RunService.RenderStepped:Wait() * 1

				if v16 > 861 then
					break
				end
			end

			if flag then
				_G.updateMusic2(false)
			end
		end)
		Util.Anims:Get(clone.CameraPart, "GravUltimateCamera"):Play(0)
		Util.Anims:Get(clone.BloxMoon, "GravUltimateMoon"):Play(0)
		Util.Anims:Get(clone.BloxEarth, "GravUltimateEarth"):Play(0)
		Util.Anims:Get(clone.SmallRocks, "GravUltimateSmallRocks"):Play(0)
		Util.Anims:Get(clone.MediumRocks, "GravUltimateMediumRocks"):Play(0)
		Util.Anims:Get(clone["Biggest Asteroid"], "GravUltimateGiantAsteroid"):Play(0)
		Util.Anims:Get(clone["Large meteors more"], "GravUltimateLargeRocks"):Play(0)
		local gravUltimateAddRocks = Util.Anims:Get(clone["additional landign rocks"], "GravUltimateAddRocks")
		gravUltimateAddRocks.Looped = false
		gravUltimateAddRocks:Play()
		Util.Anims:Get(clone["supporting asteroids"], "GravUltimate5Asteroids"):Play(0)

		if flag then
			v2.TimePosition = 0
			v2.Volume = flag and 1 or 0
			task.delay(DELAY_DURATION, function()
				for _, part2 in pairs(descendants) do
					if not part2:IsA("BasePart") or part2.Parent == clone.CameraPart or part2.Name == "RootPart" or part2:GetAttribute("Invisible") then
						continue
					end

					part2.Transparency = 0

					if not (part2.Name == "Cloud" and flag) then
						continue
					end

					part2.CFrame = clone.BloxEarth.RootPart.Controller.TransformedWorldCFrame * CFrame.new(12, 130, -5)
					part2.Transparency = 0
				end
			end)
		else
			v3.TimePosition = 0
			v3.Volume = 1
		end

		local gravUltimatePlayer = Util.Anims:Get(root.Parent, "GravUltimatePlayer")
		gravUltimatePlayer.Priority = Enum.AnimationPriority.Action4
		gravUltimatePlayer:Play()

		if flag then
			part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.new()
			part.Size = createVector(1, 1, 1)
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.Scale = createVector(2500, 2500, 2500)
			specialMesh.MeshType = Enum.MeshType.FileMesh
			specialMesh.MeshId = "rbxassetid://10691561431"
			specialMesh.Parent = part
			part.Parent = workspace._WorldOrigin
		end

		local _ = localPlayer == data.Caster
		characterRemovingConnection = localPlayer.CharacterRemoving:Once(function()
			clear()
		end)
		local lastTime = tick()
		renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
			if tick() - lastTime > 14.2 then
				renderSteppedConnection:Disconnect()

				if characterRemovingConnection then
					characterRemovingConnection:Disconnect()
				end

				if flag then
					currentCamera.CameraType = Enum.CameraType.Custom
					pcall(function()
						part:Destroy()
					end)
				end
			end

			if flag then
				currentCamera.CFrame = clone.CameraPart.Cam.CFrame

				if now then
					local v11 = math.min(1, (tick() - now) / 0.5)
					currentCamera.CFrame = CFrame.lookAt(
						currentCamera.CFrame.Position + createVector(0, 30, 0) * v11,
						data.TargetPosition
					) * CFrame.new(0, 0, v11 * 30)
				end

				part.CFrame = currentCamera.CFrame
			end
		end)
	elseif stage == 5 then
		return
	end
end