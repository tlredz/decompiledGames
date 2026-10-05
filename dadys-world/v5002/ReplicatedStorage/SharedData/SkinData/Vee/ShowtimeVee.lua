return {
	Name = "Show-Time Vee",
	OverwriteAnimations = {
		Run = "rbxassetid://72678141337718",
		Walk = "rbxassetid://97897738117999",
		Idle = "rbxassetid://87154718270671",
		Quirk = "rbxassetid://81440563810050",
		Decode = "rbxassetid://106108686337103",
		Ability = "rbxassetid://80384613174821"
	},
	FaceTextures = {
		Normal = "rbxassetid://106448416543653",
		Hurt = "rbxassetid://90112425374978",
		Blink = "rbxassetid://72292209716999"
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
		local color = Color3.fromRGB(207, 207, 168)

		if pointLight then
			pointLight.Color = color
		end

		if pointLight2 then
			pointLight2.Color = color
		end
	end
}