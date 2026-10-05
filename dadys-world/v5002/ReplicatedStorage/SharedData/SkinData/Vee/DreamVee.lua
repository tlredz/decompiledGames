return {
	Name = "Star-Time Vee",
	OverwriteAnimations = {
		Run = "rbxassetid://72678141337718",
		Walk = "rbxassetid://97897738117999",
		Idle = "rbxassetid://87154718270671",
		Quirk = "rbxassetid://81440563810050",
		Decode = "rbxassetid://130774656853296",
		Ability = "rbxassetid://80384613174821"
	},
	FaceTextures = {
		Normal = "rbxassetid://72149025329181",
		Hurt = "rbxassetid://103502030158286",
		Blink = "rbxassetid://132944666704356"
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
		local color = Color3.fromRGB(117, 160, 207)

		if pointLight then
			pointLight.Color = color
		end

		if pointLight2 then
			pointLight2.Color = color
		end
	end
}