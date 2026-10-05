return {
	Name = "Haunted Flame",
	TowerName = "Soulvester",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	HolidayYear = 2025,
	OverwriteAnimations = {
		Run = "rbxassetid://133253678576937",
		Walk = "rbxassetid://70520238008961",
		Idle = "rbxassetid://87619555490099",
		Quirk = "rbxassetid://98381789513693",
		Decode = "rbxassetid://109213385520053"
	},
	FaceTextures = {
		Normal = "rbxassetid://75387101103288",
		Blink = "rbxassetid://119853473353111",
		Hurt = "rbxassetid://128243972325841"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
		local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
		local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
		local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
		local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")

		if pointLight then
			pointLight.Color = Color3.fromRGB(240, 210, 245)
		end

		if pointLight2 then
			pointLight2.Color = Color3.fromRGB(240, 210, 245)
		end
	end
}