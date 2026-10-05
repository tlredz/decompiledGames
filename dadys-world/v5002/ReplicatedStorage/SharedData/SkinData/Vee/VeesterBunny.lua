local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Vee-ster Bunny",
	TowerName = "Vee",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W3,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://72678141337718",
		Walk = "rbxassetid://97897738117999",
		Idle = "rbxassetid://87154718270671",
		Quirk = "rbxassetid://81440563810050",
		Decode = "rbxassetid://106108686337103",
		Ability = "rbxassetid://80384613174821"
	},
	FaceTextures = {
		Normal = "rbxassetid://118944150266120",
		Blink = "rbxassetid://79715343205988",
		Hurt = "rbxassetid://108093790741723"
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
		local color = Color3.fromRGB(194, 153, 206)

		if pointLight then
			pointLight.Color = color
		end

		if pointLight2 then
			pointLight2.Color = color
		end
	end
}