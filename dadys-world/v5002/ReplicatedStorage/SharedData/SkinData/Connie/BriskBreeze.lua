return {
	Name = "Brisk Breeze",
	TowerName = "Connie",
	Description = "No description yet",
	Mastery = false,
	DandyStore = true,
	Cost = 600,
	OverwriteAnimations = {
		Run = "rbxassetid://135520521675955",
		Walk = "rbxassetid://102597759660729",
		Idle = "rbxassetid://128280431056105",
		Quirk = "rbxassetid://138757579963518",
		Decode = "rbxassetid://95863938993300"
	},
	FaceTextures = {
		Blink = "rbxassetid://138816854069723",
		Hurt = "rbxassetid://127326731308971",
		Normal = "rbxassetid://89381841361277"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		instance:SetAttribute(
			"AlternateColor",
			(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(203, 186, 145)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(203, 186, 145))
			}))
		)

		if instance.HumanoidRootPart:FindFirstChild("ToonLight") then
			instance.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(203, 186, 145)
		end

		if instance.HumanoidRootPart:FindFirstChild("ExtraLight") then
			instance.HumanoidRootPart.ExtraLight.PointLight.Color = Color3.fromRGB(203, 186, 145)
		end
	end
}