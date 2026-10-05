return {
	Name = "Gourd Guard",
	TowerName = "Soulvester",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	HolidayYear = 2025,
	OverwriteAnimations = {
		Decode = "rbxassetid://120171311729021",
		Quirk = "rbxassetid://106258561577482",
		Idle = "rbxassetid://74680862622107",
		Walk = "rbxassetid://137616571439337",
		Run = "rbxassetid://86577380003350"
	},
	FaceTextures = {
		Hurt = "rbxassetid://83745790213706",
		Blink = "rbxassetid://118068307634173",
		Normal = "rbxassetid://114711351029160"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
		local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
		local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
		local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
		local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")

		if pointLight then
			pointLight.Color = Color3.fromRGB(219, 153, 48)
		end

		if pointLight2 then
			pointLight2.Color = Color3.fromRGB(219, 153, 48)
		end
	end
}