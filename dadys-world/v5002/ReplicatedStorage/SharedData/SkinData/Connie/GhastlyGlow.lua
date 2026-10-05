return {
	Name = "Ghastly Glow",
	TowerName = "Connie",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	HolidayYear = 2025,
	GeneratorOffset = {
		Y = 0,
		Z = -0.6
	},
	TreadmillGeneratorOffset = {
		Y = 0,
		Z = 1
	},
	OverwriteAnimations = {
		Run = "rbxassetid://132716257399112",
		Walk = "rbxassetid://91313979152047",
		Idle = "rbxassetid://93387303075117",
		Quirk = "rbxassetid://85490364673330",
		Decode = "rbxassetid://133500601575506"
	},
	FaceTextures = {
		Blink = "rbxassetid://74551710989470",
		Hurt = "rbxassetid://87138482960611",
		Normal = "rbxassetid://130099326342245"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		instance:SetAttribute(
			"AlternateColor",
			(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(198, 198, 222)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(198, 198, 222))
			}))
		)

		if instance.HumanoidRootPart:FindFirstChild("ToonLight") then
			instance.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(198, 198, 222)
		end

		if instance.HumanoidRootPart:FindFirstChild("ExtraLight") then
			instance.HumanoidRootPart.ExtraLight.PointLight.Color = Color3.fromRGB(198, 198, 222)
		end
	end
}