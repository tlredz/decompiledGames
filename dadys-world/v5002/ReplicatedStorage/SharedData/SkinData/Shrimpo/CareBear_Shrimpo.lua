return {
	Name = "Grumpy Bear",
	RobuxCost = script:GetAttribute("RobuxCost") or -1,
	ProductId = 3367980037,
	OverwriteAnimations = {
		Walk = "rbxassetid://83797003369894",
		Run = "rbxassetid://118408617438325",
		Quirk = "rbxassetid://118596195257950",
		Idle = "rbxassetid://104855983361844",
		Decode = "rbxassetid://82115028837237"
	},
	FaceTextures = {
		Blink = "rbxassetid://110627976829983",
		Hurt = "rbxassetid://107948085163445",
		Normal = "rbxassetid://83634183817594"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}