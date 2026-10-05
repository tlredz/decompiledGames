local VintageEggson = {
	Name = "Vintage Eggson",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://128146525809209",
		Hurt = "rbxassetid://101795888598713",
		Blink = "rbxassetid://100077565980255"
	},
	USE_SKIN_MODEL = false
}

function VintageEggson.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageEggson.FaceTextures.Normal
		end
	end
end

return VintageEggson