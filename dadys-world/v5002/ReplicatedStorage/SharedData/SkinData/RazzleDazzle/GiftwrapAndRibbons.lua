local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Giftwrap and Ribbons",
	TowerName = "RazzleDazzle",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W3,
	Requirement1 = { "Christmas2025Ornaments", 1200 },
	Requirement2 = { "Coin", 1200 },
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Dazzle_Decode = "rbxassetid://102093930218778",
		Dazzle_Quirk = "rbxassetid://95746943843071",
		Dazzle_Run = "rbxassetid://86690915505364",
		Dazzle_Walk = "rbxassetid://114059287282182",
		Decode = "rbxassetid://102093930218778",
		Idle = "rbxassetid://135585409793203",
		Lobby_run = "rbxassetid://86968906076390",
		Lobby_walk = "rbxassetid://125212922407080",
		Quirk = "rbxassetid://138533487627039",
		Razzle_Decode = "rbxassetid://114966830888827",
		Razzle_Quirk = "rbxassetid://138533487627039",
		Razzle_Run = "rbxassetid://120582662667682",
		Razzle_Walk = "rbxassetid://105050348467936",
		Run = "rbxassetid://120582662667682",
		Walk = "rbxassetid://114059287282182"
	},
	FaceTextures = {
		Blink = "rbxassetid://104925666503045",
		Hurt = "rbxassetid://71066225221141",
		Normal = "rbxassetid://89809741236697"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}