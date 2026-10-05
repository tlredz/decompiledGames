return {
	Name = "Wish Bear",
	RobuxCost = script:GetAttribute("RobuxCost") or -1,
	Unlocks = DateTime.fromUniversalTime(2026, 5, 26, 19, 0, 0),
	ProductId = 3576327340,
	OverwriteAnimations = {
		Walk = "rbxassetid://88140844483455",
		Quirk = "rbxassetid://71738075714464",
		Run = "rbxassetid://88245199188233",
		Idle = "rbxassetid://125686660526683",
		Decode = "rbxassetid://98963387488985",
		Ability = "rbxassetid://92455041576210"
	},
	FaceTextures = {
		Normal = "rbxassetid://99100918675981",
		Blink = "rbxassetid://84029405150866",
		Hurt = "rbxassetid://73147509495635"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(p)
		if p.HumanoidRootPart:FindFirstChild("ToonLight") then
			p.HumanoidRootPart.ToonLight.PointLight.Color = Color3.fromRGB(93, 200, 205)
		end
	end
}