local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Lighting_2 = {}

function Lighting_2.colorCorrectionFlash(brightness: number, saturation: number, contrast: number, color: Color3, value: number)
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

function Lighting_2.PointLight(parent, color: Color3?, value: number?, value2: number?, p: number?, value3: number?)
	local v = value or 1
	local pointLight = Instance.new("PointLight")
	pointLight.Enabled = true
	pointLight.Color = color or Color3.fromRGB(105, 195, 255)
	pointLight.Range = value2 or 10
	pointLight.Brightness = value3 or 2
	pointLight.Parent = parent
	TweenService:Create(pointLight, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = p or (value2 or 10) * 1.5
	}):Play()
	Debris:AddItem(pointLight, v)
	return pointLight
end

return Lighting_2