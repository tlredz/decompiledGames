local VintageWaxwell = {
	Name = "Vintage Waxwell",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://112328500220799",
		Blink = "rbxassetid://76825632279992",
		Hurt = "rbxassetid://73045589338258"
	},
	LightColor = Color3.fromRGB(255, 255, 255),
	USE_SKIN_MODEL = false,
	AbilityTrailGreyscale = true
}

function VintageWaxwell.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageWaxwell.FaceTextures.Normal
		end
	end

	task.spawn(function()
		local rootPart = folder:WaitForChild("RootPart", 5)
		local root_jnt = rootPart and rootPart:FindFirstChild("root_jnt")
		local torso_jnt = root_jnt and root_jnt:FindFirstChild("torso_jnt")
		local chest_jnt = torso_jnt and torso_jnt:FindFirstChild("chest_jnt")
		local head_jnt = chest_jnt and chest_jnt:FindFirstChild("head_jnt")
		local lightAttachment = head_jnt and head_jnt:FindFirstChild("LightAttachment")
		local vFXAttachment = head_jnt and head_jnt:FindFirstChild("VFXAttachment")
		local pointLight = lightAttachment and lightAttachment:FindFirstChild("PointLight")
		local particleEmitter = vFXAttachment and vFXAttachment:FindFirstChild("ParticleEmitter")

		if pointLight then
			pointLight.Color = VintageWaxwell.LightColor
			pointLight.Brightness = 0.2
			pointLight.Range = 12
			pointLight.Shadows = false
		end

		if particleEmitter then
			local colorSequenceKeypoints = {}

			for _, keypoint in ipairs(particleEmitter.Color.Keypoints) do
				local value = keypoint.Value
				local v = 0.299 * value.R + 0.587 * value.G + 0.114 * value.B
				table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(keypoint.Time, Color3.new(v, v, v)))
			end

			particleEmitter.Color = ColorSequence.new(colorSequenceKeypoints)
		end
	end)
end

return VintageWaxwell