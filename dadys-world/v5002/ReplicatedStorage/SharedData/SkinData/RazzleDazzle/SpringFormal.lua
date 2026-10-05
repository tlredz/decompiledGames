local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Spring Formal",
	TowerName = "RazzleDazzle",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W1,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Dazzle_Run = "rbxassetid://134714665469933",
		Dazzle_Walk = "rbxassetid://109753602785063",
		Idle = "rbxassetid://123101626847955",
		Razzle_Quirk = "rbxassetid://77597199950787",
		Lobby_run = "rbxassetid://112834415232107",
		Dazzle_Quirk = "rbxassetid://106726185123532",
		Lobby_walk = "rbxassetid://128708825627409",
		Razzle_Decode = "rbxassetid://105816926501555",
		Dazzle_Decode = "rbxassetid://117093472408004",
		Razzle_Run = "rbxassetid://131008610884429",
		Razzle_Walk = "rbxassetid://139284449676655",
		Decode = "rbxassetid://117093472408004",
		Quirk = "rbxassetid://127250156825692",
		Run = "rbxassetid://131008610884429",
		Walk = "rbxassetid://109753602785063"
	},
	FaceTextures = {
		Normal = "rbxassetid://140613799113757",
		Blink = "rbxassetid://93838368453180",
		Hurt = "rbxassetid://102112530507985"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}