local April1 = {
	Name = "Colorful April",
	Cost = 600,
	DandyStore = true,
	TrackSource = true,
	OverwriteAnimations = {
		Run = "rbxassetid://121887597056169",
		Walk = "rbxassetid://113493276030799",
		Idle = "rbxassetid://94672939370149",
		Quirk = "rbxassetid://120524896657767",
		Decode = "rbxassetid://81195350931735"
	},
	FaceTextures = {
		Normal = "rbxassetid://96363435547428",
		Hurt = "rbxassetid://94167604508877",
		Blink = "rbxassetid://93245111716223"
	},
	USE_SKIN_MODEL = true
}

function April1.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = April1.FaceTextures.Normal
		end
	end
end

return April1