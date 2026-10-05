local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local FrameMarker = require(ReplicatedStorage.Resources.FrameMarker)

local function fn(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitDelay = emitter:GetAttribute("EmitDelay")

		if emitDelay then
			local v = emitter
			task.delay(emitDelay, function()
				v:Emit(v:GetAttribute("EmitCount"))
			end)
		else
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end

local function fn2(effect)
	if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
		effect.Enabled = true
	end

	for _, effect2 in effect:GetDescendants() do
		if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Trail") or effect2:IsA("Beam")) then
			continue
		end

		effect2.Enabled = true
	end
end

local function fn3(effect)
	if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
		effect.Enabled = false
	end

	for _, effect2 in effect:GetDescendants() do
		if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Trail") or effect2:IsA("Beam")) then
			continue
		end

		effect2.Enabled = false
	end
end

local function fn4(slamVFX, color: Color3?, value: number?, value2: number?, p: number?, value3: number?)
	local v = value or 1
	local pointLight = Instance.new("PointLight")
	pointLight.Enabled = true
	pointLight.Color = color or Color3.fromRGB(105, 195, 255)
	pointLight.Range = value2 or 10
	pointLight.Brightness = value3 or 2
	pointLight.Parent = slamVFX
	TweenService:Create(pointLight, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = p or (value2 or 10) * 1.5
	}):Play()
	Debris:AddItem(pointLight, v)
	return pointLight
end

local function fn5(brightness: number, saturation: number, contrast: number, color: Color3, value: number)
	local v = value or 0.2
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Brightness = brightness
	colorCorrectionEffect.Saturation = saturation
	colorCorrectionEffect.Contrast = contrast
	colorCorrectionEffect.TintColor = color or Color3.fromRGB(255, 255, 255)
	colorCorrectionEffect.Parent = Lighting
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Brightness = 0,
		Saturation = 0,
		Contrast = 0,
		TintColor = Color3.fromRGB(255, 255, 255)
	}):Play()
	Debris:AddItem(colorCorrectionEffect, v)
end

local function fn6(p, color: Color3?, color2: Color3?, value: number?, occluded, value2: number?)
	local v = value or 1
	local highlight = Instance.new("Highlight")
	highlight.Adornee = p
	highlight.DepthMode = occluded or Enum.HighlightDepthMode.Occluded
	highlight.FillColor = color or Color3.new(1, 1, 1)
	highlight.OutlineColor = color2 or Color3.new(1, 1, 1)
	highlight.FillTransparency = value2 or 0
	highlight.OutlineTransparency = 0
	highlight.Parent = p
	TweenService:Create(highlight, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		FillTransparency = 1,
		OutlineTransparency = 1
	}):Play()
	Debris:AddItem(highlight, v)
	return highlight
end

local function fn7(instance, data, p)
	local clone = instance:Clone()
	clone.Parent = Effects
	local v = p or clone.CFrame

	for _, beam in clone:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		local v2 = {
			Width0 = beam.Width0,
			Width1 = beam.Width1,
			TextureSpeed = beam.TextureSpeed,
			Brightness = beam.Brightness,
			LightEmission = beam.LightEmission
		}
		local tween = TweenService:Create(
			beam,
			TweenInfo.new(data.Duration, Enum.EasingStyle[data.Easing], Enum.EasingDirection[data.EasingDirection]),
			data.Properties
		)
		tween:Play()
		local v3 = beam
		tween.Completed:Once(function()
			v3.Enabled = false

			for k, v5 in v2 do
				v3[k] = v5
			end
		end)
	end

	TweenService:Create(
		clone,
		TweenInfo.new(data.Duration, Enum.EasingStyle[data.Easing], Enum.EasingDirection[data.EasingDirection]),
		{
			Position = (v * data.Offset).Position
		}
	):Play()
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		clone.CFrame *= CFrame.Angles(0, 0, (math.rad(data.RotationSpeed)))
		total += dt

		if total > 5 and heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end)
	Debris:AddItem(clone, 5)
end

local function fn8(folder, tweenInfo, timeScale)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:SetAttribute("TimeScale", emitter.TimeScale)
		TweenService:Create(emitter, tweenInfo, {
			TimeScale = timeScale
		}):Play()
	end
end

local function fn9(folder)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.TimeScale = emitter:GetAttribute("TimeScale") or 1
		end
	end
end

local Debris2 = game:GetService("Debris")
local TweenService2 = game:GetService("TweenService")
local thrown = workspace.Thrown
local distortionMesh = script.DistortionMesh
local v = {
	Play = function(self)
		local clone = distortionMesh:Clone()
		clone.CFrame = self.Position
		clone.Parent = thrown
		clone.Transparency = self.StartDistortion
		clone.Size = Vector3.new(self.StartRadius, self.StartRadius, self.StartRadius)
		TweenService2:Create(clone, TweenInfo.new(self.Duration, self.EasingStyle, self.EasingDirection), {
			Size = Vector3.new(self.EndRadius, self.EndRadius, self.EndRadius),
			Transparency = self.EndDistortion
		}):Play()
		Debris2:AddItem(clone, self.Duration)
	end
}
local MeshEmitNew = require(ReplicatedStorage.Resources.MeshEmitNew)
local preloadedTextures = script.PreloadedTextures
local random = Random.new()

local function InterpolateSequences(sequence, sequence2, p)
	local numberSequenceKeypoints = {}

	if #sequence.Keypoints ~= #sequence2.Keypoints then
		warn("Mismatch in keypoint counts between sequences")
		return sequence
	end

	for i, keypoint in ipairs(sequence.Keypoints) do
		local keypoint2 = sequence2.Keypoints[i]

		if not keypoint2 then
			continue
		end

		local v2 = keypoint.Value + (keypoint2.Value - keypoint.Value) * p
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, v2))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function TweenNumberSequence(p, p2: number, p3: string, sequence)
	if not (p and p[p3] and sequence) then
		warn("Invalid parameters provided to TweenNumberSequence")
		return
	end

	local lastTime = tick()
	local v2 = p[p3]

	if #v2.Keypoints ~= #sequence.Keypoints then
		warn("Start and target sequences have different keypoint counts")
		return
	end

	local heartbeatConnection = nil
	local RunService2 = game:GetService("RunService")
	heartbeatConnection = RunService2.Heartbeat:Connect(function()
		local v3 = math.clamp((tick() - lastTime) / p2, 0, 1)
		p[p3] = InterpolateSequences(v2, sequence, v3)

		if v3 >= 1 then
			heartbeatConnection:Disconnect()
		elseif not (p and p[p3]) then
			warn("Tween interrupted: Property or instance became nil")
			heartbeatConnection:Disconnect()
		end
	end)
end

local function Flipbook(decal, p: string, value, number: number, callback)
	local v2 = number or nil
	local module = require(preloadedTextures[p]:Clone())
	local v3 = type(value) == "number" and value or value and 1e999 or 1
	local v4 = true
	task.spawn(function()
		if module then
			for _ = 1, v3 do
				for i = 1, #module do
					if not v4 then
						return
					end

					local v5 = module[i]

					if decal:IsA("ImageLabel") then
						decal.Image = v5
					elseif decal:IsA("BasePart") then
						decal.Decal.Texture = v5
					elseif decal:IsA("MeshPart") then
						decal.TextureID = v5
					elseif decal:IsA("ParticleEmitter") then
						decal.Texture = v5
					elseif decal:IsA("Decal") then
						decal.Texture = v5
					elseif decal:IsA("Beam") then
						decal.Texture = v5
					elseif decal:IsA("SpecialMesh") then
						decal.MeshId = v5
					else
						print("not supported flipbookformat")
					end

					task.wait(v2)
				end

				if not decal.Parent then
					break
				end
			end

			if v4 and callback then
				callback()
			end
		end
	end)
	return {
		forcestop = function()
			v4 = false
		end,
		updatespeed = function(p2)
			v2 = p2
		end
	}
end

local function TrinityTearFinisher(p, p2, p3)
	local humanoidRootPart = p.HumanoidRootPart
	local humanoidRootPart2 = p2.HumanoidRootPart
	return FrameMarker.new({
		Framerate = 60
	}):Chain({
		[0] = function()
			if not (p3 and p3.IsPlaying) then
				return
			end

			local clone = script.StartSlam.PartFx:Clone()
			clone.Parent = thrown
			clone.CFrame = humanoidRootPart.CFrame
			fn(clone.SlamVFX)
			Debris2:AddItem(clone, 15)
			fn4(clone.SlamVFX, Color3.fromRGB(255, 81, 0), 0.4, 13, 21, 3)
			fn6(
				humanoidRootPart2.Parent,
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(255, 255, 255),
				0.7,
				Enum.HighlightDepthMode.Occluded,
				0.3
			)
			local windBeams = script.StartSlam.Mesh.WindBeams
			windBeams.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(-0.6108652381980153, 0, 0)
			fn7(windBeams, {
				Properties = {
					Brightness = 0,
					LightEmission = 1,
					TextureSpeed = 0.2,
					Width0 = 4,
					Width1 = 11
				},
				RotationSpeed = 1,
				Rotation = true,
				Offset = CFrame.new(0, 0, 0),
				Duration = 1.4,
				Easing = "Quad",
				EasingDirection = "Out"
			})
			local clone2 = script.StartSlam.Mesh.ImpactShockwave:Clone()
			MeshEmitNew.new(clone2):Emit(humanoidRootPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			local clone3 = script.StartSlam.Mesh.WindDecal1:Clone()
			MeshEmitNew.new(clone3):Emit(humanoidRootPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			local clone4 = script.StartSlam.Mesh.WindDecal2:Clone()
			MeshEmitNew.new(clone4):Emit(humanoidRootPart.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
			fn5(0.05, 0.2, 0.45, Color3.fromRGB(255, 255, 255), 0.5)
		end,
		[36] = function()
			if not (p3 and p3.IsPlaying) then
				return
			end

			local clone = script.ArmRipper.PartFx:Clone()
			clone.Parent = thrown
			clone.CFrame = humanoidRootPart.CFrame
			clone.Anchored = false
			clone.Massless = true
			local weld = Instance.new("Weld")
			weld.Parent = clone
			weld.Part0 = humanoidRootPart
			weld.Part1 = clone
			fn(clone.SpiderLegs)
			fn(clone.ArmRip)
			Debris2:AddItem(clone, 15)
			task.wait(0.3)
			local windBeams = script.ArmRipper.Mesh.WindBeams
			windBeams.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 6, -3) * CFrame.Angles(-0.4363323129985824, 0, 0)
			fn7(windBeams, {
				Properties = {
					Brightness = 0,
					LightEmission = 1,
					TextureSpeed = 0.2,
					Width0 = 4,
					Width1 = 11
				},
				RotationSpeed = 2,
				Rotation = true,
				Offset = CFrame.new(0, 0, -5),
				Duration = 0.9,
				Easing = "Quad",
				EasingDirection = "Out"
			})
			local clone2 = script.ArmRipper.Mesh.ImpactShockwave:Clone()
			MeshEmitNew.new(clone2):Emit(humanoidRootPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			local color = Color3.fromRGB(255, 193, 69)
			fn6(humanoidRootPart.Parent.LeftClaw, color, color, 0.3, Enum.HighlightDepthMode.Occluded, 0.2)
			fn6(
				humanoidRootPart2.Parent,
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(255, 255, 255),
				0.1,
				Enum.HighlightDepthMode.Occluded,
				0
			)
			local clone3 = script.ArmRipper.Mesh.PlayerWind:Clone()
			local v2 = MeshEmitNew.new(clone3)
			v2:Emit(humanoidRootPart2.Parent.Torso)
			task.wait(0.05)
			fn6(humanoidRootPart.Parent.RightClaw, color, color, 0.3, Enum.HighlightDepthMode.Occluded, 0.2)
			fn6(
				humanoidRootPart2.Parent,
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(255, 255, 255),
				0.5,
				Enum.HighlightDepthMode.Occluded,
				0
			)
			v2:Emit(humanoidRootPart2.Parent.Torso)
			task.wait(0.1)
			local clone4 = script.ArmRipper.Mesh.ImpactShockwave2:Clone()
			MeshEmitNew.new(clone4):Emit(humanoidRootPart.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
			task.wait(0.4)
			local clone5 = script.ArmRipper.Mesh.PlayerWind2End:Clone()
			MeshEmitNew.new(clone5):Emit(humanoidRootPart2.Parent.Torso)
			local windBeams2 = script.ArmRipper.Mesh.WindBeams2
			windBeams2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 4, -3) * CFrame.Angles(3.141592653589793, 0, 0)
			fn7(windBeams2, {
				Properties = {
					Brightness = 0,
					LightEmission = 1,
					TextureSpeed = 0.4,
					Width0 = 4,
					Width1 = 13
				},
				RotationSpeed = 1,
				Rotation = true,
				Offset = CFrame.new(0, 0, -4),
				Duration = 0.6,
				Easing = "Quad",
				EasingDirection = "Out"
			})
			local clone6 = script.ArmRipper.Mesh.ImpactShockwave3:Clone()
			MeshEmitNew.new(clone6):Emit(humanoidRootPart.CFrame * CFrame.new(clone6:GetAttribute("Offset")))
			fn5(0.02, 0.2, 0.25, Color3.fromRGB(255, 255, 255), 0.3)
		end,
		[113] = function()
			if not (p3 and p3.IsPlaying) then
				return
			end

			local clone = script.Throw.PartFx:Clone()
			clone.Parent = thrown
			clone.CFrame = humanoidRootPart.CFrame
			fn(clone.ThrowFx)
			Debris2:AddItem(clone, 15)
			local windBeams = script.Throw.Mesh.WindBeams
			windBeams.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 7, -6) * CFrame.Angles(1.4835298641951802, 0, 0)
			fn7(windBeams, {
				Properties = {
					Brightness = 0,
					LightEmission = 1,
					TextureSpeed = 0.5,
					Width0 = 4,
					Width1 = 22
				},
				RotationSpeed = -1,
				Rotation = true,
				Offset = CFrame.new(0, 0, -9),
				Duration = 0.85,
				Easing = "Sine",
				EasingDirection = "Out"
			})
			local clone2 = script.Throw.Mesh.WindThroweey:Clone()
			MeshEmitNew.new(clone2):Emit(humanoidRootPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			local clone3 = script.Throw.Mesh.RingMesh:Clone()
			MeshEmitNew.new(clone3):Emit(humanoidRootPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			local clone4 = script.Throw.Mesh.RingMesh2:Clone()
			MeshEmitNew.new(clone4):Emit(humanoidRootPart.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
			local clone5 = script.Throw.Mesh.RingMesh3:Clone()
			MeshEmitNew.new(clone5):Emit(humanoidRootPart.CFrame * CFrame.new(clone5:GetAttribute("Offset")))
			local clone6 = script.Throw.Mesh.ImpactShockwave:Clone()
			MeshEmitNew.new(clone6):Emit(humanoidRootPart.CFrame * CFrame.new(clone6:GetAttribute("Offset")))
			local clone7 = script.Throw.Mesh.WindThroweey2:Clone()
			MeshEmitNew.new(clone7):Emit(humanoidRootPart.CFrame * CFrame.new(clone7:GetAttribute("Offset")))
			local clone8 = script.Throw.Mesh.PlayerWind:Clone()
			MeshEmitNew.new(clone8):EmitRate(3, 0.8, humanoidRootPart2.Parent.Torso)
			local clone9 = script.Throw.Mesh.PlayerRing:Clone()
			MeshEmitNew.new(clone9):EmitRate(7, 0.8, humanoidRootPart2.Parent.Torso)
		end,
		[134] = function()
			if not (p3 and p3.IsPlaying) then
				return
			end

			local clone = script.Landing.PartFx:Clone()
			clone.Parent = thrown
			clone.CFrame = humanoidRootPart.CFrame
			fn(clone.LandFx)
			Debris2:AddItem(clone, 15)
			local clone2 = script.Landing.Mesh.ImpactShockwave:Clone()
			MeshEmitNew.new(clone2):Emit(humanoidRootPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			local clone3 = script.Landing.Mesh.WindDecal1:Clone()
			MeshEmitNew.new(clone3):Emit(humanoidRootPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			local clone4 = script.Landing.Mesh.WindDecal2:Clone()
			MeshEmitNew.new(clone4):Emit(humanoidRootPart.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
		end,
		[156] = function()
			if not (p3 and p3.IsPlaying) then
				return
			end

			local clone = script.FourStabs.PartFx:Clone()
			clone.Parent = thrown
			clone.CFrame = humanoidRootPart.CFrame
			fn(clone.Stabs)
			Debris2:AddItem(clone, 15)
			fn6(
				humanoidRootPart2.Parent,
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(255, 255, 255),
				0.25,
				Enum.HighlightDepthMode.Occluded,
				0
			)
			local clone2 = script.FourStabs.Mesh.PlayerWind:Clone()
			local v2 = MeshEmitNew.new(clone2)
			v2:Emit(humanoidRootPart2.Parent.Torso)
			local clone3 = script.FourStabs.Mesh.ImpactShockwaveTuff:Clone()
			local v3 = MeshEmitNew.new(clone3)
			v3:Emit(humanoidRootPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			task.wait(0.2)
			fn6(
				humanoidRootPart2.Parent,
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(255, 255, 255),
				0.25,
				Enum.HighlightDepthMode.Occluded,
				0
			)
			v2:Emit(humanoidRootPart2.Parent.Torso)
			v3:Emit(humanoidRootPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			task.wait(0.2)
			fn6(
				humanoidRootPart2.Parent,
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(255, 255, 255),
				0.25,
				Enum.HighlightDepthMode.Occluded,
				0
			)
			v2:Emit(humanoidRootPart2.Parent.Torso)
			v3:Emit(humanoidRootPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			task.wait(0.3)
			fn6(
				humanoidRootPart2.Parent,
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(255, 255, 255),
				0.8,
				Enum.HighlightDepthMode.Occluded,
				0
			)
			local clone4 = script.FourStabs.Mesh.PlayerWind2End:Clone()
			local v4 = MeshEmitNew.new(clone4)
			v4:Emit(humanoidRootPart2.Parent.Torso)
			v4:Emit(humanoidRootPart2.Parent.Torso)
			local clone5 = script.FourStabs.Mesh.SphereMesh:Clone()
			MeshEmitNew.new(clone5):Emit(humanoidRootPart2.Parent.Torso)
			v3:Emit(humanoidRootPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
		end,
		[192] = function()
			if not (p3 and p3.IsPlaying) then
				return
			end

			local clone = script.Charging.PartFx:Clone()
			clone.Parent = thrown
			clone.CFrame = humanoidRootPart.CFrame
			fn2(clone.ChargeFx.Charge.PartFx)
			Debris2:AddItem(clone, 15)
			fn5(0.02, 0.2, 0.25, Color3.fromRGB(255, 228, 216), 0.3)
			task.spawn(function() end)
			task.spawn(function()
				local zIndex = 4

				for _ = 1, 4 do
					task.spawn(function()
						for _ = 1, 1 do
							local clone2 = script.Charging.Mesh.SwirlFlipbook:Clone()
							clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, 5) * CFrame.Angles(
								math.rad((random:NextNumber(0, 360, 0))),
								math.rad((random:NextNumber(0, 360, 0))),
								(math.rad((random:NextNumber(0, 360, 0))))
							))
							clone2.Parent = thrown
							game.Debris:AddItem(clone2, 1)
							local root = clone2.Root
							local meshflip = clone2.meshflip
							local decal = meshflip.Decal
							local mesh = meshflip.Mesh
							decal.ZIndex = zIndex
							zIndex -= 1
							local number = random:NextNumber(5, 12)
							local number2 = random:NextNumber(0.75, 6)
							Flipbook(decal, "Childemperorstylizedmeshflip", false, (random:NextNumber(0.01, 0.015)))
							TweenService2:Create(
								mesh,
								TweenInfo.new(number2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Scale = mesh.Scale * number
								}
							):Play()
							TweenService2:Create(
								root,
								TweenInfo.new(number2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = root.CFrame * CFrame.Angles(0, math.rad((random:NextNumber(90, 180))), 0)
								}
							):Play()
							task.delay(number2 * 0.15, function()
								TweenService2:Create(
									decal,
									TweenInfo.new(number2 * 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Color3 = Color3.fromRGB(1255, 80, 0)
									}
								):Play()
							end)
							local decal2 = decal
							local v6 = number2
							task.delay(number2 * 0.4, function()
								TweenService2:Create(
									decal2,
									TweenInfo.new(v6 * 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Color3 = Color3.fromRGB(0, 0, 0)
									}
								):Play()
							end)
							task.wait(0.025)
						end
					end)
				end
			end)
			task.wait(0.5)
			fn3(clone.ChargeFx.Charge.PartFx)
		end,
		[234] = function()
			if not (p3 and p3.IsPlaying) then
				return
			end

			local clone = script.Uppercut.PartFx:Clone()
			clone.Parent = thrown
			clone.CFrame = humanoidRootPart.CFrame
			fn(clone.UppercutFx.Impact)
			fn8(clone.UppercutFx, TweenInfo.new(0.09, Enum.EasingStyle.Circular, Enum.EasingDirection.In), 0.01)
			Debris2:AddItem(clone, 15)
			task.wait(0.425)
			fn9(clone.UppercutFx)
			local windBeams2 = script.Uppercut.Mesh.WindBeams2
			windBeams2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 4, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
			fn7(windBeams2, {
				Properties = {
					Brightness = 0,
					LightEmission = 1,
					TextureSpeed = 0.5,
					Width0 = 3,
					Width1 = 18
				},
				RotationSpeed = 0.23,
				Rotation = true,
				Offset = CFrame.new(0, 0, -5),
				Duration = 1,
				Easing = "Sine",
				EasingDirection = "Out"
			})
			local clone2 = script.Uppercut.Mesh.ImpactShockwave:Clone()
			MeshEmitNew.new(clone2):Emit(humanoidRootPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			local clone3 = script.Uppercut.Mesh.RingMesh:Clone()
			MeshEmitNew.new(clone3):Emit(humanoidRootPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			local clone4 = script.Uppercut.Mesh.WindThroweey:Clone()
			local v2 = MeshEmitNew.new(clone4)
			v2:Emit(humanoidRootPart.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
			v2:Emit(humanoidRootPart.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
			local clone5 = script.Uppercut.Mesh.ImpactShockwave2:Clone()
			MeshEmitNew.new(clone5):Emit(humanoidRootPart.CFrame * CFrame.new(clone5:GetAttribute("Offset")))
			local clone6 = script.Uppercut.Mesh.WindDecal2:Clone()
			MeshEmitNew.new(clone6):Emit(humanoidRootPart.CFrame * CFrame.new(clone6:GetAttribute("Offset")))
			local clone7 = script.Uppercut.Mesh.RingMesh2:Clone()
			MeshEmitNew.new(clone7):Emit(humanoidRootPart.CFrame * CFrame.new(clone7:GetAttribute("Offset")))
			fn5(0.02, 0.2, 0.25, Color3.fromRGB(255, 255, 255), 0.5)
			fn6(
				humanoidRootPart.Parent,
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(255, 255, 255),
				0.8,
				Enum.HighlightDepthMode.Occluded,
				0.3
			)
		end,
		[289] = function()
			if not (p3 and p3.IsPlaying) then
				return
			end

			local clone = script.EndLanding.PartFx:Clone()
			clone.Parent = thrown
			clone.CFrame = humanoidRootPart.CFrame
			fn(clone.LandFx)
			Debris2:AddItem(clone, 15)
			local clone2 = script.EndLanding.Mesh.ImpactShockwave:Clone()
			MeshEmitNew.new(clone2):Emit(humanoidRootPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			local clone3 = script.EndLanding.Mesh.WindDecal1:Clone()
			MeshEmitNew.new(clone3):Emit(humanoidRootPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			local clone4 = script.EndLanding.Mesh.WindDecal2:Clone()
			MeshEmitNew.new(clone4):Emit(humanoidRootPart.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
			local clone5 = script.EndLanding.Mesh.RingMesh:Clone()
			MeshEmitNew.new(clone5):Emit(humanoidRootPart.CFrame * CFrame.new(clone5:GetAttribute("Offset")))
		end,
		[500] = function(instance)
			instance:Destroy()
		end
	})
end

return TrinityTearFinisher