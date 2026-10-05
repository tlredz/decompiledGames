local LoneWolf = {
	Name = "Howling Moonstone",
	TowerName = "Eclipse",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	HolidayYear = 2025,
	OverwriteAnimations = {
		Decode = "rbxassetid://119301286398499",
		Idle = "rbxassetid://101297586465019",
		Quirk = "rbxassetid://134729240113033",
		Run = "rbxassetid://113933928349907",
		Walk = "rbxassetid://80227782431048"
	},
	FaceTextures = {
		TransformNormal = "rbxassetid://106538004133545",
		TransformHurt = "rbxassetid://108744971281791",
		TransformBlink = "rbxassetid://70368848884343",
		Normal = "rbxassetid://131555929989578",
		Hurt = "rbxassetid://108744971281791",
		Blink = "rbxassetid://70368848884343"
	},
	USE_SKIN_MODEL = true
}

function LoneWolf.ApplySkin(instance)
	local config = instance:WaitForChild("Config")
	local transformBlinkTexture = config:WaitForChild("TransformBlinkTexture")
	local transformHurtTexture = config:WaitForChild("TransformHurtTexture")
	local transformNormalTexture = config:WaitForChild("TransformNormalTexture")
	transformBlinkTexture.Texture = LoneWolf.FaceTextures.TransformBlink
	transformHurtTexture.Texture = LoneWolf.FaceTextures.TransformHurt
	transformNormalTexture.Texture = LoneWolf.FaceTextures.TransformNormal
end

return LoneWolf