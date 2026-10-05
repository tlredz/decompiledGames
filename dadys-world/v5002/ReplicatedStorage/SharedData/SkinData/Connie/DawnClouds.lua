local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Dawn Clouds",
	TowerName = "Connie",
	Description = "No description",
	Mastery = false,
	Cost = 600,
	Easter = true,
	HolidaySkin = true,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W4,
	OverwriteAnimations = {
		Walk = "rbxassetid://94176169625312",
		Idle = "rbxassetid://96412679901902",
		Run = "rbxassetid://100856079668466",
		Quirk = "rbxassetid://113665293377170",
		Decode = "rbxassetid://94798510366959"
	},
	FaceTextures = {
		Normal = "rbxassetid://95102569610587",
		Blink = "rbxassetid://117539406972781",
		Hurt = "rbxassetid://76952341634896"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		instance:SetAttribute(
			"AlternateColor",
			(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(252, 192, 243)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(217, 155, 232)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 219, 243))
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