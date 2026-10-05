return {
	Name = "Cosmic Signal",
	DandyStore = true,
	Cost = 600,
	OverwriteAnimations = {
		Run = "rbxassetid://72678141337718",
		Walk = "rbxassetid://97897738117999",
		Idle = "rbxassetid://122419845627963",
		Quirk = "rbxassetid://79933173901382",
		Decode = "rbxassetid://106108686337103",
		Ability = "rbxassetid://91119874129522"
	},
	FaceTextures = {
		Normal = "rbxassetid://79836272795363",
		Hurt = "rbxassetid://78617770629832",
		Blink = "rbxassetid://76390371833357"
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
		local color = Color3.fromRGB(121, 110, 207)

		if pointLight then
			pointLight.Color = color
		end

		if pointLight2 then
			pointLight2.Color = color
		end
	end
}