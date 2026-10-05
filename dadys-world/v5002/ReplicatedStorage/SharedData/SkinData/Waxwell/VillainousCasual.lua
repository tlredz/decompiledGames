local VillainousCasual = {
	Name = "Villainous Casual",
	TowerName = "Waxwell",
	Cost = 600,
	DandyStore = true,
	LightColor = Color3.fromRGB(170, 0, 26),
	FlameColorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
		ColorSequenceKeypoint.new(0.31, Color3.new(0.882353, 0, 0)),
		ColorSequenceKeypoint.new(0.46, Color3.new(1, 0, 0)),
		ColorSequenceKeypoint.new(0.75, Color3.new(0.219608, 0.027451, 0.282353)),
		ColorSequenceKeypoint.new(1, Color3.new(0.219608, 0.027451, 0.282353))
	}),
	OverwriteAnimations = {
		Decode = "rbxassetid://74242509577120",
		Idle = "rbxassetid://70934688090803",
		Walk = "rbxassetid://132923545921733",
		Run = "rbxassetid://123946013267251",
		Quirk = "rbxassetid://87851431704922"
	},
	FaceTextures = {
		Blink = "rbxassetid://84994518859612",
		Normal = "rbxassetid://121394390304720",
		Hurt = "rbxassetid://98368887220411"
	},
	USE_SKIN_MODEL = true
}

function VillainousCasual.ApplySkin(instance)
	task.spawn(function()
		local rootPart = instance:WaitForChild("RootPart", 5)
		local root_jnt = rootPart and rootPart:FindFirstChild("root_jnt")
		local torso_jnt = root_jnt and root_jnt:FindFirstChild("torso_jnt")
		local chest_jnt = torso_jnt and torso_jnt:FindFirstChild("chest_jnt")
		local head_jnt = chest_jnt and chest_jnt:FindFirstChild("head_jnt")
		local lightAttachment = head_jnt and head_jnt:FindFirstChild("LightAttachment")
		local vFXAttachment = head_jnt and head_jnt:FindFirstChild("VFXAttachment")
		local pointLight = lightAttachment and lightAttachment:FindFirstChild("PointLight")

		if vFXAttachment then
			vFXAttachment:FindFirstChild("ParticleEmitter")
		end

		if pointLight then
			pointLight.Color = VillainousCasual.LightColor
			pointLight.Brightness = 0.2
			pointLight.Range = 12
			pointLight.Shadows = false
		end
	end)
end

return VillainousCasual