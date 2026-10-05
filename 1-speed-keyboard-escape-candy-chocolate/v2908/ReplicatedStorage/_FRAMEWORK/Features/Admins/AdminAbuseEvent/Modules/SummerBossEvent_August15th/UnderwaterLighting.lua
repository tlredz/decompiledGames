local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local quad = Enum.EasingStyle.Quad
local inOut = Enum.EasingDirection.InOut
local v = {
	Ambient = Color3.fromRGB(70, 120, 160),
	OutdoorAmbient = Color3.fromRGB(80, 140, 180),
	FogColor = Color3.fromRGB(70, 140, 180),
	FogStart = 100,
	FogEnd = 650
}
local v2 = {
	Density = 0.3,
	Color = Color3.fromRGB(90, 160, 200),
	Decay = Color3.fromRGB(50, 100, 140),
	Haze = 0.5,
	Glare = 0
}
local v3 = {
	TintColor = Color3.fromRGB(150, 210, 255),
	Saturation = -0.05,
	Contrast = 0,
	Brightness = 0.05
}
local v4 = {
	TintColor = Color3.new(1, 1, 1),
	Saturation = 0,
	Contrast = 0,
	Brightness = 0
}

-- equivalent calls inferred from this helper; original call sites unknown
local function captureLightingSnapshot()
	return {
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		FogColor = Lighting.FogColor,
		FogStart = Lighting.FogStart,
		FogEnd = Lighting.FogEnd
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function captureAtmosphereSnapshot(data)
	return {
		Density = data.Density,
		Color = data.Color,
		Decay = data.Decay,
		Haze = data.Haze,
		Glare = data.Glare
	}
end

return {
	apply = function()
		local v5 = captureLightingSnapshot() -- equivalent call inferred; original call site unknown
		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or nil
		local v6 = atmosphere and captureAtmosphereSnapshot(atmosphere) or nil
		TweenService:Create(Lighting, TweenInfo.new(2, quad, inOut), v):Play()

		if atmosphere then
			TweenService:Create(atmosphere, TweenInfo.new(2, quad, inOut), v2):Play()
		end

		local summerBossEvent_August15th_UnderwaterCC = Lighting:FindFirstChild("SummerBossEvent_August15th_UnderwaterCC")

		if summerBossEvent_August15th_UnderwaterCC then
			summerBossEvent_August15th_UnderwaterCC:Destroy()
		end

		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "SummerBossEvent_August15th_UnderwaterCC"
		colorCorrectionEffect.TintColor = v4.TintColor
		colorCorrectionEffect.Saturation = v4.Saturation
		colorCorrectionEffect.Contrast = v4.Contrast
		colorCorrectionEffect.Brightness = v4.Brightness
		colorCorrectionEffect.Parent = Lighting
		TweenService:Create(colorCorrectionEffect, TweenInfo.new(2, quad, inOut), v3):Play()
		local flag = false
		return {
			destroy = function()
				if flag then
					return
				end

				flag = true
				TweenService:Create(Lighting, TweenInfo.new(1.5, quad, inOut), v5):Play()

				if atmosphere and atmosphere.Parent and v6 then
					TweenService:Create(atmosphere, TweenInfo.new(1.5, quad, inOut), v6):Play()
				end

				local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(1.5, quad, inOut), v4)
				tween.Completed:Once(function()
					if colorCorrectionEffect.Parent then
						colorCorrectionEffect:Destroy()
					end
				end)
				tween:Play()
			end
		}
	end
}