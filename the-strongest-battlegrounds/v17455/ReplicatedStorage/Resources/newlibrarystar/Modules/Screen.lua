local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
return {
	flash = function(brightness: number, saturation: number, contrast: number, color: Color3?, value: number?)
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
}