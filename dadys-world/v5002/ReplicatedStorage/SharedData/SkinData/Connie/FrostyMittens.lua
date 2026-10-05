return {
	Name = "Frosty Mittens",
	TowerName = "Connie",
	Description = "Connie bundled up in cozy mittens for the holidays",
	Mastery = false,
	Cost = 600,
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Walk = "rbxassetid://91313979152047",
		Idle = "rbxassetid://96412679901902",
		Run = "rbxassetid://71819089910283",
		Quirk = "rbxassetid://113665293377170",
		Decode = "rbxassetid://94798510366959"
	},
	FaceTextures = {
		Blink = "rbxassetid://135022145474790",
		Hurt = "rbxassetid://85761097152398",
		Normal = "rbxassetid://103702366962904"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		instance:SetAttribute(
			"AlternateColor",
			(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(248, 221, 244)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(252, 192, 243))
			}))
		)

		if instance.HumanoidRootPart:FindFirstChild("ToonLight") then
			instance.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(252, 192, 243)
		end

		if instance.HumanoidRootPart:FindFirstChild("ExtraLight") then
			instance.HumanoidRootPart.ExtraLight.PointLight.Color = Color3.fromRGB(252, 192, 243)
		end
	end
}