local VfxUtils = {
	Tween = function(p, p2, p3)
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(p, p2, p3)
		tween:Play()
		tween:Destroy()
		return tween
	end
}

function VfxUtils.BeamPlay(folder, duration, p, duration2)
	task.spawn(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local width0 = beam.Width0
			local width1 = beam.Width1
			beam.Width0 = 0
			beam.Width1 = 0
			beam.Enabled = true
			VfxUtils.Tween(beam, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Width0 = width0,
				Width1 = width1
			})
			local v = beam
			task.delay(duration + p, function()
				VfxUtils.Tween(v, TweenInfo.new(duration2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Width0 = 0,
					Width1 = 0
				})
				task.delay(duration2, function()
					v.Enabled = false
				end)
			end)
		end
	end)
end

function VfxUtils.BeamPlayNormal(folder, duration)
	task.spawn(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local v = beam
			task.delay(duration, function()
				v.Enabled = false
			end)
		end
	end)
end

function VfxUtils.TrailEnabled(folder, duration)
	task.spawn(function()
		for _, trail in pairs(folder:GetDescendants()) do
			if not trail:IsA("Trail") then
				continue
			end

			trail.Enabled = true
			local v = trail
			task.delay(duration, function()
				v.Enabled = false
			end)
		end
	end)
end

function VfxUtils.ParticleEnabled(folder, duration)
	task.spawn(function()
		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			local v = emitter
			task.delay(duration, function()
				v.Enabled = false
			end)
		end
	end)
end

function VfxUtils.ParticleEmit(folder, duration)
	task.spawn(function()
		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.delay(duration, function()
				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end
	end)
end

function VfxUtils.PointLightEnabled(folder, duration)
	task.spawn(function()
		for _, light in pairs(folder:GetDescendants()) do
			if not light:IsA("PointLight") then
				continue
			end

			light.Enabled = true
			local v = light
			task.delay(duration, function()
				VfxUtils.Tween(v, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Brightness = 0
				})
			end)
		end
	end)
end

local v = { "ParticleEmitter", "Beam", "Trail" }

function VfxUtils:Emit(p: string)
	if self == nil then
		warn("Enter the path to the object.")
		return
	end

	for _, descendant in pairs(self:GetDescendants()) do
		if not table.find(v, descendant.ClassName) then
			continue
		end

		local emitCount = tonumber(descendant:GetAttribute("EmitCount")) or tonumber(descendant.Name) or 0
		local emitDelay = tonumber(descendant:GetAttribute("EmitDelay")) or 0
		local emitDuration = tonumber(descendant:GetAttribute("EmitDuration")) or 0
		local emitter = descendant
		task.delay(emitDelay, function()
			if p and emitter.Name ~= p then
				return
			end

			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitCount)
			end

			if emitDuration > 0 then
				task.defer(function()
					emitter.Enabled = true
					task.wait(emitDuration)
					emitter.Enabled = false
				end)
			end
		end)
	end
end

local RunService = game:GetService("RunService")
local BoatTween = require(game.ReplicatedStorage.BoatTween)

function VfxUtils.ColorCorrection(data)
	if data == nil then
		warn("Enter the arguments.")
		return
	end

	local fadeOut = data.fadeOut or 0.1
	local easingStyle = data.easingStyle or "Cubic"
	local easingDirection = data.easingDirection or "Out"
	local brightness = data.brightness or 0
	local saturation = data.saturation or 0
	local contrast = data.contrast or 0
	local tint = data.tint or Color3.fromRGB(255, 255, 255)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = game.Lighting
	colorCorrectionEffect.Brightness = brightness
	colorCorrectionEffect.Saturation = saturation
	colorCorrectionEffect.Contrast = contrast
	colorCorrectionEffect.TintColor = tint
	colorCorrectionEffect.Enabled = true
	BoatTween:Create(colorCorrectionEffect, {
		Time = fadeOut,
		EasingStyle = easingStyle,
		EasingDirection = easingDirection,
		StepType = "Heartbeat",
		Goal = {
			Brightness = 0,
			Saturation = 0,
			Contrast = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}
	}):Play()
	task.delay(fadeOut, function()
		colorCorrectionEffect:Destroy()
	end)
end

function VfxUtils.Highlight(parent, data)
	if parent == nil or data == nil then
		warn("Enter the arguments.")
		return
	end

	local fadeOut = data.fadeOut or 0.1
	local delay = data.delay or 0
	local easingStyle = data.easingStyle or "Cubic"
	local easingDirection = data.easingDirection or "Out"
	local fillColor = data.fillColor or Color3.fromRGB(255, 255, 255)
	local outlineColor = data.outlineColor or Color3.fromRGB(255, 255, 255)
	local fillTransparency = data.fillTransparency or 0
	local outlineTransparency = data.outlineTransparency or 0
	local highlight = Instance.new("Highlight")
	highlight.Parent = parent
	highlight.FillColor = fillColor
	highlight.OutlineColor = outlineColor
	game.Debris:AddItem(highlight, 15)
	highlight.FillTransparency = fillTransparency
	highlight.OutlineTransparency = outlineTransparency
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Enabled = true
	task.delay(delay, function()
		BoatTween:Create(highlight, {
			Time = fadeOut,
			EasingStyle = easingStyle,
			EasingDirection = easingDirection,
			StepType = "Heartbeat",
			Goal = {
				OutlineTransparency = 1,
				FillTransparency = 1
			}
		}):Play()
		task.delay(fadeOut, function()
			highlight:Destroy()
		end)
	end)
end

function VfxUtils.RGBGradient(folder, data)
	if folder == nil or data == nil then
		warn("Enter the arguments.")
		return
	end

	local duration = data.duration or 1
	local speed = data.speed or 0.5
	local saturation = data.saturation or 1
	local brightness = data.brightness or 1
	local multiplier = data.multiplier or 1
	local v2 = {
		ParticleEmitter = true,
		Beam = true,
		Decal = true,
		BasePart = true,
		MeshPart = true,
		PointLight = true,
		SpotLight = true,
		SurfaceLight = true
	}

	for _, descendant in pairs(folder:GetDescendants()) do
		if not v2[descendant.ClassName] then
			continue
		end

		local heartbeatConnection = nil
		local v3 = tick()
		local instance = descendant
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			local v4 = tick() - v3

			if duration < v4 then
				heartbeatConnection:Disconnect()
				return
			end

			local v5 = v4 / speed % 1
			local color = Color3.fromHSV(v5 * multiplier, saturation * multiplier, brightness * multiplier)

			if instance:IsA("ParticleEmitter") or instance:IsA("Beam") then
				if instance:GetAttribute("rgbGradientFalse") then
					return
				end

				instance.Color = ColorSequence.new(color)
			elseif instance:IsA("Decal") then
				instance.Color3 = color
			else
				instance.Color = color
			end
		end)
	end
end

local MeshEmitV2 = require(script.MeshEmitV2)

function VfxUtils.MeshEmit(folder, _: number, _: number)
	if folder == nil then
		warn("Enter the path to the object.")
		return
	end

	if not folder:IsA("Folder") then
		MeshEmitV2(folder.Start)
		return
	end

	for _, child in folder:GetChildren() do
		MeshEmitV2(child.Start)
	end
end

function VfxUtils.BeamFade(folder, data)
	if folder == nil or data == nil then
		warn("Enter the arguments.")
		return
	end

	local fadeOut = data.fadeOut or 0.1
	local easingStyle = data.easingStyle or "Cubic"
	local easingDirection = data.easingDirection or "Out"
	local delayTime = data.delayTime or 0

	for _, beam in pairs(folder:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local brightness = beam.Brightness
		beam.Enabled = true
		local v2 = beam
		task.delay(delayTime, function()
			BoatTween:Create(v2, {
				Time = fadeOut,
				EasingStyle = easingStyle,
				EasingDirection = easingDirection,
				StepType = "Heartbeat",
				Goal = {
					Brightness = 0
				}
			}):Play()
			task.delay(fadeOut + 0.1, function()
				v2.Enabled = false
				v2.Brightness = brightness
			end)
		end)
	end
end

return VfxUtils