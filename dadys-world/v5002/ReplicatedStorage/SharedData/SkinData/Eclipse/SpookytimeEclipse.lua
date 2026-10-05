local SpookytimeEclipse = {
	Name = "Spooky-Time Eclipse",
	TowerName = "Eclipse",
	Description = "No description yet",
	Mastery = false,
	OverwriteAnimations = {
		Decode = "rbxassetid://139931190483060",
		Idle = "rbxassetid://124573565324170",
		Quirk = "rbxassetid://108117659391395",
		Run = "rbxassetid://87911662432317",
		Walk = "rbxassetid://110599988371204"
	},
	FaceTextures = {
		Normal = "rbxassetid://123045627706021",
		Hurt = "rbxassetid://84521144943045",
		Blink = "rbxassetid://132089351256223",
		TransformNormal = "rbxassetid://91283677439909",
		TransformHurt = "rbxassetid://84521144943045",
		TransformBlink = "rbxassetid://132089351256223"
	},
	USE_SKIN_MODEL = true
}

function SpookytimeEclipse.ApplySkin(instance, _)
	local config = instance:FindFirstChild("Config")
	local transformNormalTexture = config and config:FindFirstChild("TransformNormalTexture")
	local transformBlinkTexture = config and config:FindFirstChild("TransformBlinkTexture")
	local transformHurtTexture = config and config:FindFirstChild("TransformHurtTexture")

	if not (transformNormalTexture and transformBlinkTexture and transformHurtTexture) then
		warn("[SpookytimeEclipse] rig has no Config Transform face textures - werewolf form keeps the default face")
		return
	end

	transformNormalTexture.Texture = SpookytimeEclipse.FaceTextures.TransformNormal
	transformBlinkTexture.Texture = SpookytimeEclipse.FaceTextures.TransformBlink
	transformHurtTexture.Texture = SpookytimeEclipse.FaceTextures.TransformHurt
end

return SpookytimeEclipse