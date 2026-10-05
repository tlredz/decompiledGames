return {
	Name = "Lilac Haunting",
	TowerName = "Connie",
	Cost = 600,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Walk = "rbxassetid://91313979152047",
		Idle = "rbxassetid://96412679901902",
		Run = "rbxassetid://71819089910283",
		Quirk = "rbxassetid://113665293377170",
		Decode = "rbxassetid://94798510366959"
	},
	FaceTextures = {
		Blink = "rbxassetid://92701651982193",
		Hurt = "rbxassetid://106022233381525",
		Normal = "rbxassetid://81072404342708"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		instance:SetAttribute(
			"AlternateColor",
			(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(227, 212, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(161, 130, 217))
			}))
		)

		if instance.HumanoidRootPart:FindFirstChild("ToonLight") then
			instance.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(161, 130, 217)
		end

		if instance.HumanoidRootPart:FindFirstChild("ExtraLight") then
			instance.HumanoidRootPart.ExtraLight.PointLight.Color = Color3.fromRGB(161, 130, 217)
		end
	end
}