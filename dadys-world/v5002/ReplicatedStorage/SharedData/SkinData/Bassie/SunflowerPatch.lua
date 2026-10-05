local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Sunflower Patch",
	TowerName = "Bassie",
	Cost = 600,
	Easter = true,
	HolidaySkin = true,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W1,
	OverwriteAnimations = {
		Run = "rbxassetid://71397186149314",
		Walk = "rbxassetid://116154959418045",
		Idle = "rbxassetid://91607428267819",
		Quirk = "rbxassetid://98222240635544",
		Decode = "rbxassetid://121524398419165",
		Sit_Idle = "rbxassetid://109897991611464",
		Sit_Wave = "rbxassetid://123607724551733"
	},
	FaceTextures = {
		Normal = "rbxassetid://120650312074424",
		Blink = "rbxassetid://127632207289185",
		Hurt = "rbxassetid://77707437142274"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}