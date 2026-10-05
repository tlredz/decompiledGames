local ToxicExperiment = {
	Name = "Toxic Experiment",
	TowerName = "Waxwell",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	HolidayYear = 2026,
	LightColor = Color3.fromRGB(85, 255, 0),
	FlameColorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 0)),
		ColorSequenceKeypoint.new(0.31, Color3.fromRGB(85, 255, 0)),
		ColorSequenceKeypoint.new(0.46, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(56, 7, 72)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(56, 7, 72))
	}),
	OverwriteAnimations = {
		Run = "rbxassetid://91025610857791",
		Walk = "rbxassetid://103553061379176",
		Idle = "rbxassetid://94234248045624",
		Quirk = "rbxassetid://127398588644157",
		Decode = "rbxassetid://108610568172787"
	},
	FaceTextures = {
		Normal = "rbxassetid://79439527769818",
		Blink = "rbxassetid://84511759994549",
		Hurt = "rbxassetid://102273130561794"
	},
	USE_SKIN_MODEL = true
}

function ToxicExperiment.ApplySkin(instance)
	task.spawn(function()
		local rootPart = instance:WaitForChild("RootPart", 5)
		local root_jnt = rootPart and rootPart:FindFirstChild("root_jnt")
		local torso_jnt = root_jnt and root_jnt:FindFirstChild("torso_jnt")
		local chest_jnt = torso_jnt and torso_jnt:FindFirstChild("chest_jnt")
		local head_jnt = chest_jnt and chest_jnt:FindFirstChild("head_jnt")
		local lightAttachment = head_jnt and head_jnt:FindFirstChild("LightAttachment")
		local pointLight = lightAttachment and lightAttachment:FindFirstChild("PointLight")

		if pointLight then
			pointLight.Color = ToxicExperiment.LightColor
			pointLight.Brightness = 0.2
			pointLight.Range = 12
			pointLight.Shadows = false
		end
	end)
end

return ToxicExperiment