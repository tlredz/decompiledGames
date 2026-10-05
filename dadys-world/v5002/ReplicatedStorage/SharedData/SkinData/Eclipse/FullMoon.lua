local FullMoon = {
	Name = "Full Moon",
	TowerName = "Eclipse",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	HolidayYear = 2025,
	OverwriteAnimations = {
		Walk = "rbxassetid://80227782431048",
		Run = "rbxassetid://113933928349907",
		Quirk = "rbxassetid://134729240113033",
		Idle = "rbxassetid://101297586465019",
		Decode = "rbxassetid://119301286398499"
	},
	FaceTextures = {
		Normal = "rbxassetid://134998968896270",
		Blink = "rbxassetid://90045851893990",
		Hurt = "rbxassetid://93053102219394",
		TransformNormal = "rbxassetid://114827039132468",
		TransformHurt = "rbxassetid://93053102219394",
		TransformBlink = "rbxassetid://90045851893990"
	},
	USE_SKIN_MODEL = true
}

function FullMoon.ApplySkin(instance)
	local config = instance:WaitForChild("Config")
	local transformBlinkTexture = config:WaitForChild("TransformBlinkTexture")
	local transformHurtTexture = config:WaitForChild("TransformHurtTexture")
	local transformNormalTexture = config:WaitForChild("TransformNormalTexture")
	transformBlinkTexture.Texture = FullMoon.FaceTextures.TransformBlink
	transformHurtTexture.Texture = FullMoon.FaceTextures.TransformHurt
	transformNormalTexture.Texture = FullMoon.FaceTextures.TransformNormal
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
	local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
	local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
	local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")

	if pointLight then
		pointLight.Color = Color3.fromRGB(252, 238, 178)
	end

	if pointLight2 then
		pointLight2.Color = Color3.fromRGB(252, 238, 178)
	end
end

return FullMoon