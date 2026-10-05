return {
	Name = "Zapped Creation",
	TowerName = "Vee",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	HolidayYear = 2025,
	OverwriteAnimations = {
		Run = "rbxassetid://86662733665997",
		Walk = "rbxassetid://136156814853091",
		Idle = "rbxassetid://119218890257775",
		Quirk = "rbxassetid://109455351146531",
		Decode = "rbxassetid://109091769645972",
		Ability = "rbxassetid://104046145475069"
	},
	FaceTextures = {
		Normal = "rbxassetid://93296441177635",
		Hurt = "rbxassetid://129678438592785",
		Blink = "rbxassetid://134409485069961"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance, instance2)
		local clone = instance2:WaitForChild("Head"):WaitForChild("StaticScreen"):Clone()
		clone.Parent = instance:WaitForChild("Head")
		clone.RigidConstraint.Attachment0 = instance:WaitForChild("RootPart"):WaitForChild("root"):WaitForChild("torso"):WaitForChild("chest"):WaitForChild("head"):WaitForChild("HeadBoneAttachment")
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
		local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
		local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
		local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
		local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")
		local color = Color3.fromRGB(198, 210, 114)

		if pointLight then
			pointLight.Color = color
		end

		if pointLight2 then
			pointLight2.Color = color
		end
	end
}