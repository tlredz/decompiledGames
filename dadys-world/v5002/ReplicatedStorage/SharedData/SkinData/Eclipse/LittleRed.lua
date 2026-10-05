local LittleRed = {
	Name = "Little Red",
	TowerName = "Eclipse",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	HolidayYear = 2025,
	OverwriteAnimations = {
		Walk = "rbxassetid://80227782431048",
		Run = "rbxassetid://138408303971140",
		Quirk = "rbxassetid://134729240113033",
		Idle = "rbxassetid://101297586465019",
		Decode = "rbxassetid://119301286398499"
	},
	FaceTextures = {
		Normal = "rbxassetid://99307621298150",
		Blink = "rbxassetid://125483290859492",
		Hurt = "rbxassetid://112812686636876",
		TransformBlink = "rbxassetid://125483290859492",
		TransformHurt = "rbxassetid://112812686636876",
		TransformNormal = "rbxassetid://92113188663412"
	},
	USE_SKIN_MODEL = true
}

function LittleRed.ApplySkin(instance)
	local config = instance:WaitForChild("Config")
	local transformBlinkTexture = config:WaitForChild("TransformBlinkTexture")
	local transformHurtTexture = config:WaitForChild("TransformHurtTexture")
	local transformNormalTexture = config:WaitForChild("TransformNormalTexture")
	transformBlinkTexture.Texture = LittleRed.FaceTextures.TransformBlink
	transformHurtTexture.Texture = LittleRed.FaceTextures.TransformHurt
	transformNormalTexture.Texture = LittleRed.FaceTextures.TransformNormal
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
	local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
	local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
	local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")

	if pointLight then
		pointLight.Color = Color3.fromRGB(220, 84, 112)
	end

	if pointLight2 then
		pointLight2.Color = Color3.fromRGB(220, 84, 112)
	end
end

return LittleRed