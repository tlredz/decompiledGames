local PropertyMap = {
	SunRaysEffect = {
		Intensity = 0,
		Spread = 0
	},
	ColorCorrectionEffect = {
		Brightness = 0,
		Contrast = 0,
		Saturation = 0,
		TintColor = Color3.new(1, 1, 1)
	},
	DepthOfFieldEffect = {
		FarIntensity = 0,
		FocusDistance = 0.05000000074505806,
		InFocusRadius = 10,
		NearIntensity = 0
	},
	Atmosphere = {
		Density = 0,
		Offset = 0,
		Color = Color3.new(0.7843000292778015, 0.666700005531311, 0.4235000014305115),
		Decay = Color3.new(0.36079999804496765, 0.2353000044822693, 0.05490000173449516),
		Glare = 0,
		Haze = 0
	},
	BlurEffect = {
		Size = 0
	},
	BloomEffect = {
		Intensity = 0,
		Size = 0,
		Threshold = 0
	},
	Clouds = {
		Cover = 0,
		Density = 0,
		Color = Color3.new(1, 1, 1)
	}
}

for k, _ in pairs(PropertyMap) do
	if k ~= "Clouds" and k ~= "Atmosphere" then
		PropertyMap[k] = nil
	end

	if k == "Clouds" then
		PropertyMap.Clouds = nil
	end
end

return PropertyMap