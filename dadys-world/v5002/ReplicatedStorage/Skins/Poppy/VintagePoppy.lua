return {
	Name = "Vintage Poppy",
	Mastery = true,
	FaceTextures = {
		Normal = "rbxassetid://17675710022",
		Blink = "rbxassetid://102790143676193",
		Hurt = "rbxassetid://17675712871"
	},
	OverwriteAnimations = {},
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://17675710022"
			end
		end
	end
}