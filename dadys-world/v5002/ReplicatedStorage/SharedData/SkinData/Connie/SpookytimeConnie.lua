local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(227, 212, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(161, 130, 217))
})
local color = Color3.fromRGB(161, 130, 217)
return {
	Name = "Spooky-Time Connie",
	TowerName = "Connie",
	Description = "No description yet",
	Mastery = false,
	OverwriteAnimations = {
		Decode = "rbxassetid://120294969105835",
		Quirk = "rbxassetid://129501809775524",
		Idle = "rbxassetid://77077838646046",
		Walk = "rbxassetid://109384593585761",
		Run = "rbxassetid://131734364030531"
	},
	FaceTextures = {
		Hurt = "rbxassetid://123095695808169",
		Blink = "rbxassetid://123601575062673",
		Normal = "rbxassetid://98093862216762"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance, _)
		instance:SetAttribute("AlternateColor", colorSequence)

		if instance.HumanoidRootPart:FindFirstChild("ToonLight") then
			instance.HumanoidRootPart.ToonLight.PointLight.Color = color
		end

		if instance.HumanoidRootPart:FindFirstChild("ExtraLight") then
			instance.HumanoidRootPart.ExtraLight.PointLight.Color = color
		end
	end
}