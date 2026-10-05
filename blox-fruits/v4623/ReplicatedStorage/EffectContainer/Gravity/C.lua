local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Beziers = require(script.Parent.Modules.Beziers)
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage2:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
require(script.Parent.Modules.RockRipple)
local UselessRocksShouldntEvenBeUsedForGravity = require(script.Parent.Modules.UselessRocksShouldntEvenBeUsedForGravity)
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
local NumSeqMap = require(interpolationScheme.Parent:WaitForChild("SequenceMaps"):WaitForChild("NumSeqMap"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local x_Un = FX:WaitForChild("Gravity").X_Un
local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
local X_ULT = FX2:WaitForChild("Gravity").X_ULT
local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
local WINDRIBBONS = FX3:WaitForChild("Gravity").WINDRIBBONS
local GravityRock = require(game.ReplicatedStorage.Util.GravityRock)

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

local function ScaleAttachmentsAndEmittersWithin(folder, p: number)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= p
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, p)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setParentGravityCWithColor(p, p2, p3, flag: boolean?)
	Util.SetParentOverrideWithColor(p, p2, p3, "GravityFruitVFXColor", flag)
end

local function tweenBeamTransparency(instance, tweenInfo, p: number)
	if instance:GetAttribute("BeamTransparency") == nil then
		instance:SetAttribute("BeamTransparency", instance.Transparency == NumberSequence.new(1) and 1 or 0)
		instance:SetAttribute("OriginalBeamTransparencyNumberSequence", instance.Transparency)
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = instance:GetAttribute("BeamTransparency")
	local changedConnection = numberValue.Changed:Connect(function(beamTransparency)
		local numberSequenceKeypoints = {}

		for i, keypoint in ipairs(instance:GetAttribute("OriginalBeamTransparencyNumberSequence").Keypoints) do
			numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
				keypoint.Time,
				keypoint.Value + (1 - keypoint.Value) * beamTransparency
			)
		end

		instance.Transparency = NumberSequence.new(numberSequenceKeypoints)
		instance:SetAttribute("BeamTransparency", beamTransparency)
	end)
	local v = game.TweenService:Create(numberValue, tweenInfo, {
		Value = p
	})
	v:Play()
	v.Completed:Once(function()
		changedConnection:Disconnect()
		changedConnection = nil
		numberValue:Destroy()
		numberValue = nil
	end)
end

local function windRibbon(player, cFrame, p, p2, folder, folder2)
	Util.Debris:AddItem(folder2, 2)
	folder2.Part.Color = Color3.fromRGB(0, 0, 0)
	folder2.Part.CFrame = cFrame
	folder2.Part.Transparency = 1
	local tween = TweenService:Create(
		folder2.Part,
		TweenInfo.new(math.random(1, 2) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CFrame = folder2.Part.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			),
			Size = folder2.Part.Size * math.random(6, 8),
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = 1
		}
	)
	Util.ResizeModel(folder2, math.random(p, p2), folder2.Part.Position)
	task.spawn(function()
		for _, beam in pairs(folder2:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local v = beam
			task.spawn(function()
				task.wait(0.1)
				tweenBeamTransparency(v, TweenInfo.new(0.1), 1)
			end)
		end

		local beam = folder2.Part.beam1.Beam
		local beam2 = folder2.Part.beam2.Beam
		local beam3 = folder2.Part.beam3.Beam
		local beam4 = folder2.Part.beam4.Beam
		local beam5 = folder2.Part.beam5.Beam
		local beam6 = folder2.Part.beam6.Beam
		TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		task.wait(0.05)
		TweenService:Create(beam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
	end)
	tween.Completed:Connect(function()
		folder2:Destroy()
	end)
	setParentGravityCWithColor(folder2, folder, player, nil) -- equivalent call inferred; original call site unknown
	tween:Play()
end

local function fn(data)
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 4000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local root = data.Root
		local holding = data.Holding

		if not (holding or holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		local clone = x_Un.BLACKHOLEBAMP:Clone()
		setParentGravityCWithColor(clone, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
		local clone2 = x_Un.BLACKHOLEBAMPWELD:Clone()
		clone2.Parent = root
		clone2.Part0 = root
		clone2.Part1 = clone
		local v = Util.Sound:Play("GravFruit_C_Hold_LowPower_01", root)
		task.spawn(function()
			emitAll(clone)
		end)
		local clones = {}
		table.insert(clones, clone)
		task.spawn(function()
			local now = tick()

			repeat
				task.wait()

				if now < tick() then
					now = tick() + 0.035
					root.Parent:FindFirstChild("RightHand")

					if root.Parent == game.Players.LocalPlayer.Character then
						Util.CameraShaker:ShakeOnce(
							1,
							1,
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
					now = tick() + 0.175

					if root.Parent == game.Players.LocalPlayer.Character then
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
		local v2 = false

		if data.CanUltimate then
			task.delay(1, function()
				if not v2 then
					if v then
						Util.Sound:FadeOut(v, 0.1)
					end

					Util.Sound:Play("GravFruit_C_Hold_IncreasePower_Notification_01_V2", root)
					v = Util.Sound:Play("GravFruit_C_Hold_HighPower_01", root)
					Util.ResizeModel(clone, 0.3)
					emitAll(clone)

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
				end
			end)
		end

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		v2 = true
		task.wait(0.05)

		if v then
			Util.Sound:FadeOut(v, 0.1)
		end

		clone.Distortion:Destroy()

		for _, folder2 in pairs(clones) do
			if folder2:IsDescendantOf(workspace) then
				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			end

			local v3 = folder2
			task.spawn(function()
				task.wait(1)
				v3:Destroy()
			end)
		end

		task.wait(1)
		clone2:Destroy()
		task.wait(2)
		folder:Destroy()
	elseif stage == 2 then
		local v = data.Duration - (workspace:GetServerTimeNow() - data.Timestamp)

		if v < 0.5 then
			return
		end

		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 20)
		local root = data.Root
		local cFrame = data.CFrame
		local clone = x_Un.BLACKHOLE:Clone()
		local primaryPart = clone.PrimaryPart
		primaryPart.CFrame = cFrame
		setParentGravityCWithColor(clone, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
		Util.Debris:AddItem(clone, v + 3)
		local v2 = Util.Sound:Play("GravFruit_C_ReleaseBlackHole_03", primaryPart)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(v2, TweenInfo.new(v * 0.8), {
			RollOffMinDistance = 110,
			Volume = 1.5
		}):Play()
		task.spawn(function()
			local clone2 = x_Un.hrppush.EmitTop:Clone()
			setParentGravityCWithColor(clone2, root, data.Player, nil) -- equivalent call inferred; original call site unknown
			Util.Debris:AddItem(clone2, 1.4)
			emitAll(clone2)
		end)
		task.spawn(function()
			if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 80 then
				Util.CameraShaker:ShakeOnce(2, 4, 0.05, 0.185, createVector(1.5, 1.5, 1.5), createVector(1.5, 1.5, 1.5))
				Util.CameraShaker:ShakeOnce(11, 12, 0.65, 1.9, createVector(0.9, 0.9, 0.9), createVector(0.9, 0.9, 0.9))
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				Util.Debris:AddItem(colorCorrectionEffect, 2.5)
				task.spawn(function()
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.3, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
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
					task.wait(0.3)
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
					task.delay(1, function()
						colorCorrectionEffect:Destroy()
					end)
				end)
				task.spawn(function()
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							FieldOfView = 93
						}
					):Play()
					task.wait(0.4)
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
		task.spawn(function()
			local clone2 = x_Un.PulseDistortBig:Clone()
			setParentGravityCWithColor(clone2, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
			clone2.CFrame = primaryPart.CFrame
			Util.Debris:AddItem(clone2, 1.5)
			TweenService:Create(clone2, TweenInfo.new(0.065, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Size = createVector(0, 0, 0)
			}):Play()
		end)
		task.spawn(function()
			for _ = 1, 4 do
				task.spawn(function()
					for _ = 1, 5 do
						local clone2 = x_Un.partfly2:Clone()
						clone2.CFrame = primaryPart.CFrame * CFrame.new(
							math.random(-65, 65),
							math.random(-34.5, 65),
							math.random(-65, 65)
						)
						setParentGravityCWithColor(clone2, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
						Util.Debris:AddItem(clone2, 2)
						local v4 = math.random(13, 26) / 100
						Beziers.Interpolate(
							"Cubic",
							v4,
							100,
							v4,
							nil,
							clone2.CFrame,
							clone2.CFrame * CFrame.new(math.random(-95, 95), math.random(-34, 15), math.random(-95, 95)),
							clone2.CFrame * CFrame.new(math.random(-45, 45), math.random(-34, 15), math.random(-45, 45)),
							primaryPart.CFrame * CFrame.new(
								math.random(-15, 15),
								math.random(-14, 15),
								math.random(-15, 15)
							),
							clone2,
							"CFrame"
						)
					end
				end)
				task.wait(0.0015)
			end
		end)
		local ray = Util.Ray
		local v3 = root.Position + createVector(0, 2, 0)
		local v4 = { workspace.Characters, workspace.Enemies, folder }
		local v5, _, _ = ray(v3, createVector(-0, -70, -0), v4, false)

		if v5 ~= nil then
			task.spawn(function()
				for _, emitter in pairs(primaryPart:GetDescendants()) do
					if not (emitter:IsA("ParticleEmitter") and emitter.Name == "smoke") then
						continue
					end

					local v6 = emitter
					task.spawn(function()
						v6.Color = ColorSequence.new(v5.Color)
						v6.Enabled = true
					end)
					local v7 = emitter
					task.spawn(function()
						task.wait(0.7)
						v7.Enabled = false
					end)
				end
			end)
		end

		task.spawn(function()
			task.wait(0.5)

			for _ = 0, v - 0.7, 0.045 do
				local clone2 = x_Un.Floor:Clone()
				local ray2 = Util.Ray
				local v6 = primaryPart.Position + createVector(0, 2, 0)
				local v7 = { workspace.Characters, workspace.Enemies, folder }
				local v8, v9, _ = ray2(v6, createVector(-0, -52, -0), v7, false)

				if v8 ~= nil then
					local v10 = v9
					local v11 = clone2
					task.spawn(function()
						v11.CFrame = CFrame.new(v10)
						setParentGravityCWithColor(v11, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
						Util.Debris:AddItem(v11, 2.8)
						emitAll(v11)
					end)
				end

				task.wait(0.045)
			end
		end)
		local v6 = 1
		local size = primaryPart.Distortion.Size
		task.spawn(function()
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = clone:GetScale()
			local tween = TweenService:Create(
				numberValue,
				TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Value = 11
				}
			)
			tween.Completed:Connect(function()
				numberValue:Destroy()
			end)
			tween:Play()
			numberValue:GetPropertyChangedSignal("Value"):Connect(function()
				clone:ScaleTo(numberValue.Value)
			end)
		end)
		task.spawn(function()
			local emitters = {}

			for _, emitter in ipairs(primaryPart:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					table.insert(emitters, emitter)
				end
			end

			local v7 = NumSeqMap.new(script.SizeGraph:GetAttribute("Sequence"), 60)
			awaitHeartbeatLoopFor(v, function(_, _, p)
				local v8 = v7:GetValue(p) * 3.5
				local v9 = v8 / v6

				for _, v10 in ipairs(emitters) do
					if not (v10.Name ~= "FlamesTrailDark2" and v10.Name ~= "FlamesTrailDark" and v10.Name ~= "FlamesAir" and v10.Name ~= "SmokeAir") then
						continue
					end

					if not (v10.Name ~= "Smoke" and v10.Name ~= "Flames") then
						continue
					end

					ScaleParticle(v10, v9)
				end

				primaryPart.Distortion.Size = size * clone:GetScale() * v9
				v6 = v8
			end, function()
				local v8 = v7:GetValue(1) * 3.5 / v6

				for _, v9 in ipairs(emitters) do
					if not (v9.Name ~= "FlamesTrailDark2" and v9.Name ~= "FlamesTrailDark" and v9.Name ~= "FlamesAir" and v9.Name ~= "SmokeAir") then
						continue
					end

					if not (v9.Name ~= "Smoke" and v9.Name ~= "Flames") then
						continue
					end

					ScaleParticle(v9, v8)
				end
			end)
		end)
		local v7 = {}
		task.spawn(function()
			task.wait(0.35)

			for _ = 1, 17 do
				local v8 = GravityRock.new(primaryPart.CFrame, {
					Chaotic = true,
					GravityStrength = math.random(50, 80),
					OrbitRadius = math.random(70, 90),
					RotationSpeed = math.random(5, 10)
				})
				v8.Part.Size = createVector(1, 1, 1) * math.random(5, 11)
				v8:Orbit(primaryPart)
				table.insert(v7, v8)
				task.spawn(function()
					task.wait(v - 0.15)

					for _, v9 in ipairs(v7) do
						v9:Destroy()
					end

					table.clear(v7)
				end)
				task.wait(0.1)
			end
		end)
		task.spawn(function()
			tick()
			local v8 = 0

			while data.Proxy and data.Proxy:IsDescendantOf(workspace) do
				primaryPart.CFrame = primaryPart.CFrame:Lerp(
					data.Proxy.Value + createVector(0, 1, 0) * (data.Proxy:GetAttribute("Height") or 0),
					v8 * 15
				)
				v8 = task.wait(0.016666666666666666)
			end
		end)
		task.spawn(function()
			task.wait(v)
			task.defer(function()
				primaryPart.Distortion:Destroy()
			end)

			for _, emitter in pairs(primaryPart:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		task.spawn(function()
			local WAIT_INTERVAL = 0.01
			task.wait(v - 0.15)
			local clone2 = x_Un.explode.Pop:Clone()
			Util.ResizeModel(clone2, 0.9, clone2.WorldPosition)
			setParentGravityCWithColor(clone2, primaryPart, data.Player, nil) -- equivalent call inferred; original call site unknown
			emitAll(clone2)
			local play = Util.Sound:Play("GravFruit_C_BlackHoleExplode_04", primaryPart.Position)
			play.Volume = 2.5
			task.spawn(function()
				local clone3 = x_Un.explode:Clone()
				Util.ResizeModel(clone3, 0.9)
				clone3.CFrame = primaryPart.CFrame
				setParentGravityCWithColor(clone3, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
				TweenService:Create(clone3, TweenInfo.new(0.245, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Size = createVector(440, 440, 440),
					Transparency = 1
				}):Play()
				task.wait(0.25)
				clone3:Destroy()
			end)
			local v9 = false

			if data.Player == game.Players.LocalPlayer then
				local _, v10 = workspace.CurrentCamera:WorldToViewportPoint(primaryPart.Position)
				v9 = v10 and true or false
			end

			if (primaryPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 300 or v9 then
				Util.CameraShaker:ShakeOnce(
					18,
					15,
					0.05,
					1.75,
					createVector(1.5, 1.5, 1.5),
					createVector(1.5, 1.5, 1.5)
				)
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				Util.Debris:AddItem(colorCorrectionEffect, 1.5)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Brightness = -0.75,
						Contrast = 1,
						Saturation = -1,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(195, 193, 255),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Brightness = -2555,
						Contrast = 10000,
						Saturation = -1,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(8, 8, 11),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Brightness = -2555,
						Contrast = 10000,
						Saturation = -1,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(8, 8, 11),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Brightness = -0.75,
						Contrast = 1,
						Saturation = -1,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(195, 193, 255),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.723, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
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
		task.wait(v - 0.15)
		local ray2 = Util.Ray
		local v8 = primaryPart.Position + createVector(0, 2, 0)
		local v9 = { workspace.Characters, workspace.Enemies, folder }
		local v10, v11, v12 = ray2(v8, createVector(-0, -60, -0), v9, false)

		if v10 ~= nil then
			local clone2 = x_Un.BurstFloor:Clone()
			Util.ResizeModel(clone2, 0.9)
			clone2.CFrame = CFrame.new(v11)
			setParentGravityCWithColor(clone2, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
			Util.Debris:AddItem(clone2, 3.5)
			clone2.FloorSmoke.FloorDelaySmoke.Color = ColorSequence.new(v10.Color)
			emitAll(clone2)
			UselessRocksShouldntEvenBeUsedForGravity(v11, {
				RandomOffset = 0.2,
				Radius = 121,
				Size = 22.5,
				Duration = 3.5,
				Amount = 25
			})
			local v13 = CFrame.new(v11, v11 + v12) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local random = Random.new()
			local v14 = 81
			local v15 = math.max(6, v14 / 3)
			local v16 = v14 / 8

			for i = 1, v16 do
				local v18 = Rock2.new({
					Type = "Ground",
					FadeOut = { 0.25, 0.5 },
					FadeIn = { 0.25, 0.5 },
					Lifetime = { 1, 2.5 },
					Size = Vector3.new(random:NextNumber(1, 2), random:NextNumber(1, 2), random:NextNumber(1, 2)),
					Scale = { v15 / 4, v15 / 2 }
				})
				local unit = Vector3.new(
					math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793),
					random:NextNumber(0.666, 1),
					(math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793))
				).Unit
				v18.Type = "Flying"
				v18:Spawn(v13 * CFrame.Angles(0, 6.283185307179586 * (i / v16), 0) * CFrame.new(0, 0, -60.75))
				v18:Eject({
					Velocity = Util.Misc.Physics.Velocity(
						Vector3.new(),
						unit * random:NextNumber(v15 * 3.5, v15 * 6.5),
						Vector3.new(0, -workspace.Gravity * random:NextNumber(0.45, 1.3), 0),
						0.25 + random:NextNumber(0, 2)
					),
					AngularVelocity = Vector3.new(
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1)
					) * 2 * 3.141592653589793 * (1 / v18.Scale)
				})
			end
		end
	elseif stage == 3 then
		local root = data.Root
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 20)
		local cFrame = data.CFrame
		local v = math.max(0.1, data.RiseTime - (workspace:GetServerTimeNow() - data.Timestamp))
		local formTime = data.FormTime
		local v2 = formTime / 5
		local v3 = formTime / 2.5
		local _ = formTime - v2 - v3
		local heatUpTime = data.HeatUpTime
		local v4 = X_ULT
		local clone = v4.XRockRise:Clone()
		local primaryPart = clone.PrimaryPart
		primaryPart.CFrame = root.CFrame * CFrame.new(0, 0, -6)
		setParentGravityCWithColor(clone, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
		Util.Sound:Play("GravFruit_C_RockFormation_ReleaseIntoAir_03", primaryPart)
		emitAll(primaryPart.Emit)
		TweenService:Create(primaryPart, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			CFrame = cFrame
		}):Play()
		task.spawn(function()
			for _ = 0, v / 2, 0.05 do
				task.spawn(function()
					local clone2 = v4.partfly2:Clone()

					for i, attachment in pairs(clone2:GetDescendants()) do
						if attachment:IsA("Attachment") then
							attachment.Position *= 0.4 + math.random() * 0.6 + i * 0.4
						end
					end

					clone2.CFrame = primaryPart.CFrame * CFrame.new(
						math.random(-65, 65),
						math.random(-34.5, 65),
						math.random(-65, 65)
					)
					setParentGravityCWithColor(clone2, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
					Util.Debris:AddItem(clone2, 2)
					local v6 = math.random(13, 26) / 100
					Beziers.Interpolate(
						"Cubic",
						v6,
						100,
						v6,
						nil,
						clone2.CFrame,
						clone2.CFrame * CFrame.new(
							math.random(-125, 125),
							math.random(-34, -25),
							math.random(-125, 125)
						),
						clone2.CFrame * CFrame.new(math.random(-95, 95), math.random(-34, 95), math.random(-95, 95)),
						primaryPart.CFrame * CFrame.new(
							math.random(-15, 15),
							math.random(-14, 15),
							math.random(-15, 15)
						),
						clone2,
						"CFrame"
					)
				end)
				task.wait(0.05)
			end
		end)
		task.spawn(function()
			if (origin - workspace.CurrentCamera.CFrame.Position).Magnitude < 90 then
				Util.CameraShaker:ShakeOnce(6, 6, 0.05, 1.75, createVector(1, 1, 1), createVector(1, 1, 1))
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				Util.Debris:AddItem(colorCorrectionEffect, 1.5)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(1.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
					{
						Brightness = -0.1,
						Contrast = 0.2,
						Saturation = 0,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(211, 194, 255),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
				task.wait(1.5)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
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
			if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 800 then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				Util.Debris:AddItem(colorCorrectionEffect, 6.5)
				TweenService:Create(
					game.Workspace.Camera,
					TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 50
					}
				):Play()
				task.wait(v)
				Util.CameraShaker:ShakeOnce(3, 3, 0.05, formTime, createVector(1, 1, 1), createVector(1, 1, 1))
				TweenService:Create(
					game.Workspace.Camera,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 110
					}
				):Play()
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Brightness = 1.5,
						Contrast = 0,
						Saturation = 0,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(151, 125, 255),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
				task.wait(0.1)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
					{
						Brightness = 0.2,
						Contrast = 0.6,
						Saturation = -0.2,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(203, 185, 255),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
				TweenService:Create(
					game.Workspace.Camera,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 70
					}
				):Play()
				task.wait(0.125)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(formTime / 2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
					{
						Brightness = -0.2,
						Contrast = 0,
						Saturation = 0,
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(211, 215, 255),
							data.Player,
							"GravityFruitVFXColor"
						)
					}
				):Play()
				TweenService:Create(
					game.Workspace.Camera,
					TweenInfo.new(formTime / 1.1, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
					{
						FieldOfView = 90
					}
				):Play()
				task.spawn(function()
					task.wait(formTime / 2)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(formTime / 2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
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
				task.wait(formTime / 1.1)
				TweenService:Create(
					game.Workspace.Camera,
					TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						FieldOfView = 70
					}
				):Play()
			end
		end)
		task.spawn(function()
			clone:ScaleTo(0.1)
			task.wait()
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = clone:GetScale()
			local tween = TweenService:Create(
				numberValue,
				TweenInfo.new(v / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Value = 1
				}
			)
			tween.Completed:Connect(function()
				numberValue:Destroy()
			end)
			tween:Play()
			numberValue:GetPropertyChangedSignal("Value"):Connect(function()
				clone:ScaleTo(numberValue.Value)
			end)
		end)
		task.spawn(function()
			task.spawn(function()
				task.wait(v / 2)
				task.spawn(function()
					local emitters = {}

					for _, emitter in ipairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							table.insert(emitters, emitter)
						end
					end

					local v5 = NumSeqMap.new(script.SizeGraph2:GetAttribute("Sequence"), 90)
					local v6 = 1
					awaitHeartbeatLoopFor(v / 2, function(_, _, p)
						local v7 = v5:GetValue(p) * 3.5
						local v8 = v7 / v6

						for _, v9 in ipairs(emitters) do
							if not (v9.Name ~= "FlamesTrailDark2" and v9.Name ~= "FlamesTrailDark" and v9.Name ~= "FlamesAir" and v9.Name ~= "SmokeAir") then
								continue
							end

							if not (v9.Name ~= "Smoke" and v9.Name ~= "Flames") then
								continue
							end

							ScaleParticle(v9, v8)
						end

						v6 = v7
					end, function()
						local v7 = v5:GetValue(1) * 3.5 / v6

						for _, v8 in ipairs(emitters) do
							if not (v8.Name ~= "FlamesTrailDark2" and v8.Name ~= "FlamesTrailDark" and v8.Name ~= "FlamesAir" and v8.Name ~= "SmokeAir") then
								continue
							end

							if not (v8.Name ~= "Smoke" and v8.Name ~= "Flames") then
								continue
							end

							ScaleParticle(v8, v7)
						end
					end)
				end)
				task.wait(v / 2 - 0.15)
				local clone2 = v4.PULLIN:Clone()
				clone2.CFrame = primaryPart.CFrame
				setParentGravityCWithColor(clone2, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
				Util.Debris:AddItem(clone2, 5.25)
				emitAll(clone2.PullStart)
				local play = Util.Sound:Play("GravFruit_C_RockFormation_03", clone2.Position)
				play.Volume = 2.5
				task.spawn(function()
					task.wait(0.065)

					for _, emitter in pairs(clone2.PULL:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					task.wait(formTime * 0.35)

					for _, emitter in pairs(clone2.PULL:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							Util.ScaleParticle({
								Emitter = emitter,
								Scale = 0,
								Time = formTime * 0.65,
								EasingStyle = Enum.EasingStyle.Back,
								EasingDirection = Enum.EasingDirection.In
							})
						end
					end
				end)
				task.wait(formTime)
				clone:Destroy()

				for _, emitter in pairs(clone2.PULL:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end)
		task.wait(v)

		local function lerp(p, p2, p3)
			return p + (p2 - p) * p3
		end

		local function Curve(p, p2, p3, p4)
			return p2:Lerp(p3, p):Lerp(p3:Lerp(p4, p), p)
		end

		local clone2 = v4.GravXFloor:Clone()
		local ray = Util.Ray
		local v5 = cFrame.Position + createVector(0, 1, 0)
		local v6 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v7, v8, v9 = ray(v5, createVector(-0, -696969700, -0), v6)

		if v7 ~= nil then
			clone2.CFrame = CFrame.new(v8, v8 + v9) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 0, 0)
			setParentGravityCWithColor(clone2, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
			emitAll(clone2.Small)
			clone2.Small.Attachment.FloorDelaySmoke.Color = ColorSequence.new(v7.Color)
			Util.Debris:AddItem(clone2, 10)
			local clone3 = v4.BoneBoulder:Clone()
			local primaryPart2 = clone3.PrimaryPart
			clone3:PivotTo(cFrame)
			setParentGravityCWithColor(clone3, folder, data.Player, nil) -- equivalent call inferred; original call site unknown

			local function tweenRock(instance, tweenInfo, p, _)
				local _ = Util.Tween.ease["in"].quad
				local back = Util.Tween.ease.inout.back
				local transformedWorldCFrame = instance.TransformedWorldCFrame
				local v10 = math.random(250, 500)
				local v11 = math.random() * 3.141592653589793 * 2
				local lastTime = tick()

				if p.CFrame then
					p.CFrame = instance.WorldCFrame:Inverse() * p.CFrame
				end

				task.spawn(function()
					instance:SetAttribute("Animating", true)
					local rocks = clone3:FindFirstChild("Rocks")

					while tick() - lastTime < tweenInfo.Time * 3 and not instance:GetAttribute("FakeAnchor") do
						local v13 = back((tick() - lastTime) / (tweenInfo.Time * 3), 0, 1, 1)
						local v14 = CFrame.lookAt(transformedWorldCFrame.Position, p.CFrame.Position) * CFrame.Angles(
							0,
							v11,
							0
						) * CFrame.new(0, v10, 0)
						local v15 = instance.WorldCFrame:Inverse() * v14
						local v16 = instance
						local v17 = instance.WorldCFrame:Inverse() * transformedWorldCFrame
						local cFrame2 = p.CFrame
						v16.Transform = v17:Lerp(v15, v13):Lerp(v15:Lerp(cFrame2, v13), v13)

						if rocks:GetAttribute("Stop") then
							local lastTime2 = tick()

							while tick() - lastTime2 < 0.3 do
								instance.Transform = instance.WorldCFrame:Inverse() * instance.TransformedWorldCFrame:Lerp(
									p.CFrame,
									(tick() - lastTime2) / 0.3
								)
								task.wait()
							end

							instance.Transform = p.CFrame
							break
						else
							local v18 = task.wait()
							v11 += v18
						end
					end

					instance:SetAttribute("Animating", false)
					instance:SetAttribute("FakeAnchor")
				end)
			end

			task.spawn(function()
				local layers = clone3:FindFirstChild("Layers")
				local worldCFramesByBone = {}

				for _, bone in ipairs(layers["layer.014"].Root:GetChildren()) do
					if not bone:IsA("Bone") then
						continue
					end

					local clone = v4.SMOKELayer:Clone()
					clone.Parent = bone
					worldCFramesByBone[bone] = bone.WorldCFrame
					local vector2 = Vector3.new(math.random(-200, 200), 40, math.random(-200, 200))
					local v10 = clone2.CFrame * CFrame.new(vector2)
					bone.Transform = bone.WorldCFrame:Inverse() * v10
					bone:SetAttribute("StartCFrame", v10)
					local ray2 = Util.Ray
					local v11 = root.Position + createVector(0, 1, 0)
					local v12 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
					local v13, _, _ = ray2(v11, createVector(-0, -50, -0), v12)

					if v13 == nil then
						continue
					end

					local v14 = bone
					local v15 = v13
					task.spawn(function()
						v14.SMOKELayer.Enabled = true
						v14.SMOKELayer.Color = ColorSequence.new(v15.Color)
						task.wait(0.6)
						v14.SMOKELayer.Enabled = false
					end)
				end

				for k, v10 in pairs(worldCFramesByBone) do
					local v11 = k
					local cFrame2 = v10
					coroutine.wrap(function()
						local v13 = math.random(v2, v2 * 120) / 100
						task.wait(v13)
						tweenRock(
							v11,
							TweenInfo.new(math.random(40, 120) / 100, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								CFrame = cFrame2
							}
						)
					end)()
				end
			end)
			task.spawn(function()
				local rocks = clone3:FindFirstChild("Rocks")
				local worldCFramesByBone = {}

				for _, bone in ipairs(rocks["outside.038"]:GetDescendants()) do
					if not (bone:IsA("Bone") and bone.Name ~= "Root ") then
						continue
					end

					local clone = v4.SMOKE:Clone()
					clone.Parent = bone
					local clone_2 = v4.SMOKE2:Clone()
					clone_2.Parent = bone
					worldCFramesByBone[bone] = bone.WorldCFrame
					local vector2 = Vector3.new(math.random(-200, 200), 40, math.random(-200, 200))
					local v10 = clone2.CFrame * CFrame.new(vector2)
					bone.Transform = bone.WorldCFrame:Inverse() * v10
					bone:SetAttribute("StartCFrame", v10)
					local ray2 = Util.Ray
					local v11 = root.Position + createVector(0, 1, 0)
					local v12 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
					local v13, _, _ = ray2(v11, createVector(-0, -50, -0), v12)

					if v13 == nil then
						continue
					end

					local v14 = bone
					local v15 = v13
					task.spawn(function()
						v14.SMOKE.Enabled = true
						v14.SMOKE.Color = ColorSequence.new(v15.Color)
						task.wait(0.6)
						v14.SMOKE.Enabled = false
					end)
				end

				task.spawn(function()
					task.wait(formTime)
					clone3.Dust.Smoke1.Enabled = true
					clone3.Dust.Smoke2.Enabled = true
					clone3.Dust.Rocks.Enabled = true
					task.wait(1.5)
					clone3.Dust.Smoke1.Enabled = false
					clone3.Dust.Smoke2.Enabled = false
					clone3.Dust.Rocks.Enabled = false
				end)
				task.spawn(function()
					task.wait(formTime + 2)
					TweenService:Create(
						clone3.Neon,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Color = Util.WrapColor3Constructor(
								Color3.fromRGB(255, 110, 53),
								data.Player,
								"GravityFruitVFXColor"
							)
						}
					):Play()
					task.wait(0.2)
					TweenService:Create(
						clone3.Neon,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Color = Util.WrapColor3Constructor(
								Color3.fromRGB(255, 155, 116),
								data.Player,
								"GravityFruitVFXColor"
							)
						}
					):Play()
				end)
				task.spawn(function()
					task.wait(formTime + 2)
					TweenService:Create(
						clone3.Rocks["outside.038"].SurfaceAppearance,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Color = Util.WrapColor3Constructor(
								Color3.fromRGB(255, 107, 49),
								data.Player,
								"GravityFruitVFXColor"
							)
						}
					):Play()
					TweenService:Create(
						clone3.Neon,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Color = Util.WrapColor3Constructor(
								Color3.fromRGB(255, 107, 49),
								data.Player,
								"GravityFruitVFXColor"
							)
						}
					):Play()

					for _, descendant in pairs(clone3.Neon:GetDescendants()) do
						if descendant.Name == "PointLight" then
							TweenService:Create(
								descendant,
								TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Brightness = 10
								}
							):Play()
						end
					end
				end)

				for k, v10 in pairs(worldCFramesByBone) do
					local v11 = k
					local cFrame2 = v10
					coroutine.wrap(function()
						local v13 = math.random(formTime, formTime * 85) / 100
						task.wait(v13)
						local tweenInfo = TweenInfo.new(
							math.random(40, 90) / 100,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.In
						)
						task.spawn(function()
							v11.SMOKE2.Enabled = true
							task.wait(1.5)
							v11.SMOKE2.Enabled = false
						end)
						tweenRock(v11, tweenInfo, {
							CFrame = cFrame2
						})
					end)()
				end

				task.spawn(function()
					task.spawn(function()
						local WAIT_INTERVAL = 0.15
						task.wait(formTime + 1.8)
						emitAll(primaryPart2.new)
						task.wait(0.45)
						TweenService:Create(
							clone3.Distortion,
							TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Size = createVector(350, 350, 350)
							}
						):Play()
						task.wait(WAIT_INTERVAL)
						TweenService:Create(
							clone3.Distortion,
							TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Size = createVector(150, 150, 150)
							}
						):Play()
						task.wait(WAIT_INTERVAL)
						TweenService:Create(
							clone3.Distortion,
							TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Size = createVector(350, 350, 350)
							}
						):Play()
						task.wait(WAIT_INTERVAL)
						TweenService:Create(
							clone3.Distortion,
							TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Size = createVector(150, 150, 150)
							}
						):Play()
						task.wait(WAIT_INTERVAL)
						TweenService:Create(
							clone3.Distortion,
							TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Size = createVector(350, 350, 350)
							}
						):Play()
						TweenService:Create(
							clone3.Distortion,
							TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Size = createVector(0.01, 0.01, 0.01)
							}
						):Play()
					end)
					task.wait(formTime + 2)
					emitAll(primaryPart2.Pop2)
					clone3.Highlight.Enabled = true
					TweenService:Create(
						clone3.Highlight,
						TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							FillTransparency = 1
						}
					):Play()
					TweenService:Create(
						clone3.Neon,
						TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					clone3.Layers:Destroy()
					emitAll(primaryPart2.Close)
					task.spawn(function()
						if (primaryPart2.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 800 then
							local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
							colorCorrectionEffect.Parent = game.Lighting
							Util.Debris:AddItem(colorCorrectionEffect, 1.5)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.017, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
								{
									Brightness = 0,
									Contrast = 0,
									Saturation = 0.1,
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(211, 194, 255),
										data.Player,
										"GravityFruitVFXColor"
									)
								}
							):Play()
							task.wait(0.017)
							local bloomEffect = Instance.new("BloomEffect")
							bloomEffect.Name = "LeopardZBloom"
							bloomEffect.Intensity = 0.3
							bloomEffect.Threshold = 0.2
							bloomEffect.Size = 14
							bloomEffect.Parent = game.Lighting
							heartbeatLoopFor2(0.1, function(_, _, p)
								bloomEffect.Intensity = 4 - 4 * p
								bloomEffect.Threshold = 0.4 + 0.6 * p
								bloomEffect.Size = 25 - 25 * p
							end, function()
								bloomEffect:Destroy()
							end)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.867, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
								{
									Brightness = 0.176,
									Contrast = 0.16,
									Saturation = 0.2,
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 213, 187),
										data.Player,
										"GravityFruitVFXColor"
									)
								}
							):Play()
							task.wait(0.867)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.03, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
								{
									Brightness = -10,
									Contrast = 100,
									Saturation = -1,
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 8, 0),
										data.Player,
										"GravityFruitVFXColor"
									)
								}
							):Play()
							task.wait(0.03)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.03, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
								{
									Brightness = 10,
									Contrast = 2,
									Saturation = 2,
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 108, 108),
										data.Player,
										"GravityFruitVFXColor"
									)
								}
							):Play()
							task.wait(0.03)
							TweenService:Create(
								game.Workspace.Camera,
								TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									FieldOfView = 70
								}
							):Play()
							Util.CameraShaker:ShakeOnce(
								12,
								15,
								0.05,
								1.75,
								createVector(1.5, 1.5, 1.5),
								createVector(1.5, 1.5, 1.5)
							)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
								{
									Brightness = 0.3,
									Contrast = 0.5,
									Saturation = 0.4,
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 145, 108),
										data.Player,
										"GravityFruitVFXColor"
									)
								}
							):Play()
							task.wait(0.05)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(2.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
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
						local rocks2 = clone3:FindFirstChild("Rocks")

						if not rocks2 then
							warn("No 'Rocks' model found!")
							return
						end

						rocks2:SetAttribute("Stop", true)
						local play = Util.Sound:Play("GravFruit_C_RockExplosion_05", clone2.Position)
						play.Volume = 3.5
						task.wait(0.3)

						for _, bone in ipairs(rocks2:GetDescendants()) do
							if not (bone:IsA("Bone") and bone.Name ~= "Root") then
								continue
							end

							bone:SetAttribute("FakeAnchor", true)
							local v10 = bone
							coroutine.wrap(function()
								local worldCFrame = v10.WorldCFrame
								local v11 = heatUpTime - 0.35
								local v12 = tick() + v11
								local lastTime = tick()
								local v13 = worldCFrame + (cFrame.Position - worldCFrame.Position).Unit * -20

								while tick() < v12 do
									if v10:GetAttribute("Animating") then
										task.wait(0.05)
									else
										local v14 = 1 - (tick() - lastTime) / v11
										local v15 = (math.random() * 2 - 1) * 0.3
										local v16 = (math.random() * 2 - 1) * 0.3
										local v17 = (math.random() * 2 - 1) * 0.3
										local cframe = CFrame.Angles(math.rad(v15), math.rad(v16), (math.rad(v17)))
										v10.Transform = v10.WorldCFrame:Inverse() * worldCFrame:Lerp(
											worldCFrame * CFrame.new(v15 * 3 * v14, v16 * 3 * v14, v17 * 3 * v14) * cframe,
											v14
										):Lerp(
											v13,
											(tick() - lastTime) / v11
										)
										task.wait()
									end
								end

								if not v10:GetAttribute("Animating") then
									v10.Transform = v10.WorldCFrame:Inverse() * v13
								end
							end)()
						end
					end)
					task.wait(9.956 - (workspace:GetServerTimeNow() - data.Timestamp))
					clone2.Big.Attachment.FloorDelaySmoke.Color = ColorSequence.new(v7.Color)
					task.spawn(function()
						task.wait(0.075)
						emitAll(primaryPart2.Pop)
					end)
					emitAll(clone2)
					clone3.Neon.Transparency = 1

					for _, descendant in pairs(clone3.Neon:GetDescendants()) do
						if descendant.Name == "PointLight" then
							TweenService:Create(
								descendant,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Brightness = 0
								}
							):Play()
						end
					end

					task.spawn(function()
						task.wait(0.085)

						for i = 1, 8 do
							local v10 = i
							task.spawn(function()
								if 20 % v10 ~= 0 then
									local v11 = CFrame.new(primaryPart2.Position) * CFrame.new(
										0,
										0,
										-math.random(5, 14)
									) * CFrame.Angles(1.5707963267948966, 0, 0)
									task.spawn(function()
										windRibbon(
											data.Player,
											CFrame.new(v11.p),
											6,
											10,
											folder,
											WINDRIBBONS.Ribbon:Clone()
										)
										windRibbon(
											data.Player,
											CFrame.new(v11.p),
											7,
											10,
											folder,
											WINDRIBBONS.RibbonFire2:Clone()
										)
									end)
								end
							end)
						end
					end)
					local random = Random.new(data.Seed)
					clone3.Rocks["outside.038"].Transparency = 1
					local v10 = {}

					for k in pairs(worldCFramesByBone) do
						local match = k.Name:match("%d%d%d")

						if match then
							table.insert(v10, { tonumber(match), k })
						end
					end

					table.sort(v10, function(a, b)
						return a[1] < b[1]
					end)
					local v11 = {}

					for _, v12 in pairs(v10) do
						if not (random:NextNumber() < 0.4) then
							v11[v12[2]] = {
								CFrame = worldCFramesByBone[v12[2]],
								Velocity = Vector3.new(
									random:NextNumber(-200, 200),
									random:NextNumber(100, 250),
									random:NextNumber(-200, 200)
								)
							}
						end
					end

					for k, v12 in pairs(v11) do
						local velocity = v12.Velocity
						local _ = v12.CFrame
						local v13 = k
						coroutine.wrap(function()
							local clone4 = X_ULT.RngRocks:GetChildren()[math.random(1, #X_ULT.RngRocks:GetChildren())]:Clone()
							clone4.Massless = true
							clone4.CFrame = v13.TransformedWorldCFrame
							setParentGravityCWithColor(clone4, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
							v13:Destroy()
							task.spawn(function()
								for i, descendant in pairs(clone4:GetDescendants()) do
									if descendant.Name ~= "Trail" then
										continue
									end

									descendant.Enabled = true
									descendant.Lifetime = 0.45
								end
							end)
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.MaxForce = createVector(10000000, 10000000, 10000000)
							bodyVelocity.Velocity = velocity
							bodyVelocity.Parent = clone4
							task.delay(0.15, function()
								bodyVelocity:Destroy()
							end)
							local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
							bodyAngularVelocity.MaxTorque = createVector(1000000, 1000000, 1000000)
							bodyAngularVelocity.AngularVelocity = Vector3.new(
								math.random(-10, 10),
								math.random(-10, 10),
								math.random(-10, 10)
							)
							bodyAngularVelocity.Parent = clone4
							task.delay(1, function()
								bodyAngularVelocity:Destroy()
							end)
							task.wait(0.15)
							clone4.CanTouch = true
							local flag = false
							local touchedConnection = nil
							touchedConnection = clone4.Touched:Connect(function(otherPart)
								if flag then
									return
								end

								if otherPart and otherPart:IsDescendantOf(workspace.Map) then
									flag = true
									touchedConnection:Disconnect()
									local clone5 = X_ULT.HitImpact:Clone()
									clone5.CFrame = clone4.CFrame
									setParentGravityCWithColor(clone5, folder, data.Player, nil) -- equivalent call inferred; original call site unknown
									Util.Sound:Play(
										"GravFruit_C_MeteorImpact_Small_0" .. tostring(math.random(1, 5)),
										clone5.Position
									)
									emitAll(clone5.HitFX)
									clone4.Anchored = true
									clone4.Transparency = 1
									clone4.CanCollide = false
									clone4.CanTouch = false
									task.spawn(function()
										for i, descendant in pairs(clone4:GetDescendants()) do
											if descendant.Name == "Trail" then
												descendant.Enabled = false
											end
										end

										task.wait(1.8)
										clone4:Destroy()
									end)
								end
							end)
						end)()
					end
				end)
			end)
		end
	end
end

if not commandbar then
	return fn
end

local localPlayer = game.Players.LocalPlayer
local humanoidRootPart = localPlayer.Character.HumanoidRootPart
local mousePos = humanoidRootPart.CFrame * createVector(0, 0, -100)
local cframe = CFrame.lookAt(humanoidRootPart.Position, mousePos)
fn({
	Origin = humanoidRootPart.Position,
	Player = localPlayer,
	Root = humanoidRootPart,
	MousePos = mousePos,
	CFrame = cframe,
	Stage = 3
})