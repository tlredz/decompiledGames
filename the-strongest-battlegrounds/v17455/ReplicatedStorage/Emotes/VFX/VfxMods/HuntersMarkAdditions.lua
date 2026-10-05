local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local library = require(game.ReplicatedStorage.library)
local playAttachment = library.PlayAttachment
local FrameMarker = require(ReplicatedStorage.Resources.FrameMarker)

local function fn(chargeUp, color: Color3?, value: number?, value2: number?, p: number?, value3: number?)
	local v = value or 1
	local pointLight = Instance.new("PointLight")
	pointLight.Enabled = true
	pointLight.Color = color or Color3.fromRGB(105, 195, 255)
	pointLight.Range = value2 or 10
	pointLight.Brightness = value3 or 2
	pointLight.Parent = chargeUp
	TweenService:Create(pointLight, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = p or (value2 or 10) * 1.5
	}):Play()
	Debris:AddItem(pointLight, v)
	return pointLight
end

local function fn2(brightness: number, saturation: number, contrast: number, color: Color3, value: number)
	local v = value or 0.2
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Brightness = brightness
	colorCorrectionEffect.Saturation = saturation
	colorCorrectionEffect.Contrast = contrast
	colorCorrectionEffect.TintColor = color or Color3.fromRGB(255, 255, 255)
	colorCorrectionEffect.Parent = game.Lighting
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Brightness = 0,
		Saturation = 0,
		Contrast = 0,
		TintColor = Color3.fromRGB(255, 255, 255)
	}):Play()
	Debris:AddItem(colorCorrectionEffect, v)
end

local function fn3(p, color: Color3?, color2: Color3?, value: number?, occluded, value2: number?)
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

local function fn4(instance, data, p)
	local clone = instance:Clone()
	clone.Parent = workspace.Thrown
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

local Mesh = require(game.ReplicatedStorage.Resources.CosmicUtils.ZLib.Mesh)

local function fn5(folder)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.TimeScale = emitter:GetAttribute("TimeScale") or 1
		end
	end
end

local function getBezierCFrame(value: number, cframe: CFrame, cframe2: CFrame, cframe3: CFrame, cframe4: CFrame)
	local DISTANCE_EPSILON = 0.001
	local v2 = 1 - value
	local v3 = v2 * v2
	local v4 = v3 * v2
	local v5 = value * value
	local v6 = v5 * value
	local v7 = cframe.Position * v4 + cframe2.Position * (v3 * 3 * value) + cframe3.Position * (v2 * 3 * v5) + cframe4.Position * v6
	local unit = (cframe2.Position - cframe.Position) * (v3 * 3) + (cframe3.Position - cframe2.Position) * (v2 * 6 * value) + (cframe4.Position - cframe3.Position) * (v5 * 3)

	if unit.Magnitude < DISTANCE_EPSILON then
		if value < 0.5 then
			unit = (cframe2.Position - cframe.Position).Unit
		else
			unit = (cframe4.Position - cframe3.Position).Unit
		end

		if unit.Magnitude < DISTANCE_EPSILON then
			local v8 = cframe4.Position - cframe.Position
			unit = v8.Magnitude < DISTANCE_EPSILON and createVector(0, 0, -1) or v8
		end
	end

	return CFrame.lookAt(v7, v7 + unit)
end

local v = {
	Fire = function(model, cframe: CFrame, cframe2: CFrame, options)
		if not (model and model:IsA("Model") and (cframe and cframe2)) then
			return nil
		end

		local v2 = options or {}
		local clone = model:Clone()
		local primaryPart = clone.PrimaryPart

		if not primaryPart then
			clone:Destroy()
			return nil
		end

		primaryPart.CFrame = cframe * (v2.Offset or CFrame.new())
		clone.Parent = v2.Parent or workspace
		local cFrame = primaryPart.CFrame
		local lifetime = v2.Lifetime or 5
		local duration = v2.Duration or 1
		local easingStyle = v2.EasingStyle or Enum.EasingStyle.Quad
		local easingDirection = v2.EasingDirection or Enum.EasingDirection.Out

		if v2.ControlPoints and #v2.ControlPoints >= 2 then
			local controlPoint = v2.ControlPoints[1]
			local controlPoint2 = v2.ControlPoints[2]
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0
			numberValue.Name = "ProjectileBezierProgress"
			numberValue.Parent = nil
			local tween = TweenService:Create(
				numberValue,
				TweenInfo.new(duration, easingStyle, easingDirection, 0, false, 0),
				{
					Value = 1
				}
			)
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if primaryPart and primaryPart.Parent and tween.PlaybackState == Enum.PlaybackState.Playing then
					primaryPart.CFrame = getBezierCFrame(
						numberValue.Value,
						cFrame,
						controlPoint,
						controlPoint2,
						cframe2
					)
				elseif heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			end)
			tween:Play()
			tween.Completed:Connect(function()
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end

				numberValue:Destroy()
			end)
		else
			local tween = TweenService:Create(
				primaryPart,
				TweenInfo.new(duration, easingStyle, easingDirection, 0, false, 0),
				{
					CFrame = cframe2
				}
			)
			tween:Play()
			tween.Completed:Connect(function(p)
				local _ = p == Enum.TweenStatus.Completed
			end)
		end

		Debris:AddItem(clone, lifetime)
		return clone
	end
}
local _ = {
	Create = function(self: CFrame, options)
		local v2 = options or {}

		if typeof(self) ~= "CFrame" then
			warn("BezierChargeEffect.Create: 'targetCFrame' must be a CFrame value, but received an " .. typeof(self) .. ". Did you pass a Part/Instance instead of Part.CFrame?")
			return
		end

		local count = v2.Count or 30
		local spawnRadius = v2.SpawnRadius or 20
		local minDuration = v2.MinDuration or 0.8
		local maxDuration = v2.MaxDuration or 1.5
		local lifetime = v2.Lifetime or 2
		local particleTemplate = v2.ParticleTemplate
		local controlPointHeight = v2.ControlPointHeight or 15
		local randomControlOffset = v2.RandomControlOffset or 8
		local parent = v2.Parent or workspace.Thrown
		local easingStyle = v2.EasingStyle or Enum.EasingStyle.Quart
		local easingDirection = v2.EasingDirection or Enum.EasingDirection.Out
		local spawnDelay = v2.SpawnDelay or 0.05
		local colorSequence = v2.ColorSequence
		local transparencySequence = v2.TransparencySequence
		local swirlStrength = v2.SwirlStrength or 0

		if particleTemplate and particleTemplate:IsA("BasePart") then
			for i = 1, count do
				local v3 = i
				task.spawn(function()
					if spawnDelay > 0 then
						task.wait(v3 * spawnDelay)
					end

					local clone = particleTemplate:Clone()
					Debris:AddItem(clone, lifetime)
					clone.Anchored = false
					clone.CanCollide = false
					clone.CanTouch = false
					clone.Massless = true
					clone.Parent = parent
					local v4 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1).Unit * math.random(
						0,
						spawnRadius
					)
					local cframe2 = CFrame.new(self.Position + v4)
					clone.CFrame = cframe2
					local v5 = math.random(minDuration * 100, maxDuration * 100) / 100
					local v6 = self
					local lerped = cframe2:Lerp(v6, 0.5)
					local v7 = math.abs(randomControlOffset)
					local v8 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1).Unit * (math.random() * v7)
					local v9 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1).Unit * (math.random() * v7)
					local unit = (v6.Position - cframe2.Position).Unit
					local cross = unit:Cross(createVector(0, 1, 0))

					if cross.Magnitude < 0.001 then
						cross = unit:Cross(createVector(0, 0, -1))
					end

					local unit2 = cross.Unit
					local v10 = unit2 * (math.random() * 2 - 1) * swirlStrength
					local v11 = unit2 * (math.random() * 2 - 1) * swirlStrength
					local v12 = cframe2.Position:Lerp(lerped.Position, 0.3) + Vector3.new(0, controlPointHeight, 0) + v8 + v10
					local v13 = lerped.Position:Lerp(v6.Position, 0.7) + Vector3.new(0, controlPointHeight, 0) + v9 + v11
					local cframe3 = CFrame.new(v12)
					local cframe4 = CFrame.new(v13)
					local numberValue = Instance.new("NumberValue")
					numberValue.Value = 0
					numberValue.Parent = nil
					local tween = TweenService:Create(
						numberValue,
						TweenInfo.new(v5, easingStyle, easingDirection, 0, false, 0),
						{
							Value = 1
						}
					)
					local heartbeatConnection = nil
					heartbeatConnection = RunService.Heartbeat:Connect(function()
						if clone and clone.Parent and tween.PlaybackState == Enum.PlaybackState.Playing then
							clone.CFrame = getBezierCFrame(numberValue.Value, cframe2, cframe3, cframe4, v6)
						elseif heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end)
					task.delay(5, function()
						if heartbeatConnection then
							return heartbeatConnection:Disconnect()
						end
					end)
					local trail = colorSequence and clone:FindFirstChildOfClass("Trail")

					if trail then
						trail.Color = colorSequence
					end

					local trail2 = transparencySequence and clone:FindFirstChildOfClass("Trail")

					if trail2 then
						trail2.Transparency = transparencySequence
					end

					tween:Play()
					tween.Completed:Connect(function()
						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end

						numberValue:Destroy()
					end)
				end)
			end
		else
			warn("BezierChargeEffect.Create: ParticleTemplate is required and must be a BasePart.")
		end
	end
}

local function Move1(part, _, p)
	local character = game.Players.LocalPlayer.Character
	local v2 = character == part.Parent or character == p
	local clone = script.Move1Fx.PartFx:Clone()
	game.Debris:AddItem(clone, 10)
	clone.Parent = workspace.Thrown
	clone.CFrame = part.CFrame
	local weld = Instance.new("Weld")
	weld.Part0 = part
	clone.Anchored = false
	clone.Massless = true
	weld.Part1 = clone
	weld.Parent = clone
	return FrameMarker.new({
		Framerate = 60
	}):Chain({
		[2] = function()
			playAttachment(clone.SwingKick)
			fn3(
				part.Parent["Right Leg"],
				Color3.fromRGB(0, 0, 0),
				Color3.fromRGB(190, 22, 22),
				0.6,
				Enum.HighlightDepthMode.Occluded,
				0
			)

			if v2 then
				fn2(0.03, 0.32, 0.13, Color3.fromRGB(255, 255, 255), 0.15)
			end

			local root = script.SwingKick.Mesh.SideWindBeams.Root
			root.CFrame = part.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(1.5707963267948966, 0, 0.5759586531581288)
			fn4(root, {
				Properties = {
					Brightness = 0,
					LightEmission = 1,
					TextureSpeed = 0.62,
					Width0 = 1,
					Width1 = 13
				},
				RotationSpeed = -0.4,
				Rotation = true,
				Offset = CFrame.new(0, 0, 0),
				Duration = 0.8,
				Easing = "Sine",
				EasingDirection = "Out"
			})
			local clone2 = script.SwingKick.Mesh.BigSwing:Clone()
			Mesh.new(clone2):Emit(clone.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			local clone3 = script.SwingKick.Mesh.BlurImpactHit1:Clone()
			Mesh.new(clone3):Emit(clone.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			local clone4 = script.SwingKick.Mesh.ImpactMesh:Clone()
			Mesh.new(clone4):Emit(clone.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
			local clone5 = script.SwingKick.Mesh.HardImpactFinal:Clone()
			Mesh.new(clone5):Emit(clone.CFrame * CFrame.new(clone5:GetAttribute("Offset")))
			local clone6 = script.SwingKick.Mesh.ImpactHit1:Clone()
			Mesh.new(clone6):Emit(clone.CFrame * CFrame.new(clone6:GetAttribute("Offset")))

			for _, v3 in pairs({
				clone2,
				clone3,
				clone4,
				clone5,
				clone6
			}) do
				game.Debris:AddItem(v3, 6)
			end

			weld.C0 = CFrame.new(0, 0, -5)
		end,
		[20] = function()
			fn5(clone.SwingKick)
			wait(0.1)

			if v2 then
				fn2(0.05, 0.32, 0.13, Color3.fromRGB(255, 212, 212), 0.7)
			end

			fn3(
				part.Parent,
				Color3.fromRGB(0, 0, 0),
				Color3.fromRGB(190, 22, 22),
				0.6,
				Enum.HighlightDepthMode.Occluded,
				0
			)
			fn(clone.ChargeUp, Color3.fromRGB(255, 39, 39), 0.4, 6, 8, 5)
			playAttachment(clone.ChargeUp)
		end,
		[53] = function()
			weld.C0 = CFrame.new()
			playAttachment(clone.DoubleFist)
			fn3(
				part.Parent["Left Arm"],
				Color3.fromRGB(0, 0, 0),
				Color3.fromRGB(190, 22, 22),
				0.6,
				Enum.HighlightDepthMode.Occluded,
				0
			)
			fn3(
				part.Parent["Right Arm"],
				Color3.fromRGB(0, 0, 0),
				Color3.fromRGB(190, 22, 22),
				0.6,
				Enum.HighlightDepthMode.Occluded,
				0
			)

			if v2 then
				fn2(0.2, 0.5, 0.5, Color3.fromRGB(255, 211, 211), 0.5)
			end

			task.spawn(function()
				local windBeams = script.DoubleFist.Mesh.WindBeams
				windBeams.CFrame = part.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 0, 0)
				fn4(windBeams, {
					Properties = {
						Brightness = 0,
						LightEmission = 1,
						TextureSpeed = 0.4,
						Width0 = 3,
						Width1 = 11
					},
					RotationSpeed = 2,
					Rotation = true,
					Offset = CFrame.new(0, 0, -11),
					Duration = 1.3,
					Easing = "Sine",
					EasingDirection = "Out"
				})
				local _ = script.DoubleFist.Mesh.PullWindBeams
				windBeams.CFrame = part.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 0, 0)
				fn4(windBeams, {
					Properties = {
						Brightness = 0,
						LightEmission = 1,
						TextureSpeed = 0.1,
						Width0 = 3,
						Width1 = 11
					},
					RotationSpeed = 2,
					Rotation = true,
					Offset = CFrame.new(0, 0, -22),
					Duration = 1,
					Easing = "Quad",
					EasingDirection = "Out"
				})
				local clone2 = script.DoubleFist.Mesh.BlurImpactHit1:Clone()
				Mesh.new(clone2):Emit(clone.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
				local clone3 = script.DoubleFist.Mesh.ImpactMesh:Clone()
				Mesh.new(clone3):Emit(clone.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
				local clone4 = script.DoubleFist.Mesh.HardImpactFinal:Clone()
				Mesh.new(clone4):Emit(clone.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
				local clone5 = script.DoubleFist.Mesh.ImpactHit1:Clone()
				Mesh.new(clone5):Emit(clone.CFrame * CFrame.new(clone5:GetAttribute("Offset")))
				local clone6 = script.DoubleFist.Mesh.ImpactMesh2:Clone()
				Mesh.new(clone6):Emit(clone.CFrame * CFrame.new(clone6:GetAttribute("Offset")))

				for _, v3 in pairs({
					clone6,
					clone2,
					clone3,
					clone4,
					clone5
				}) do
					game.Debris:AddItem(v3, 6)
				end
			end)
		end,
		[500] = function(instance)
			clone:Destroy()
			instance:Destroy()
		end
	})
end

return Move1