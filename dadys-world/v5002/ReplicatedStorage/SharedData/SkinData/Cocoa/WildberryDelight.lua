local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Wildberry Delight",
	TowerName = "Cocoa",
	Cost = 600,
	Easter = true,
	HolidaySkin = true,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W1,
	OverwriteAnimations = {
		Run = "rbxassetid://106296018216054",
		Walk = "rbxassetid://122786131919623",
		Idle = "rbxassetid://124966645905392",
		Quirk = "rbxassetid://135206913100225",
		Decode = "rbxassetid://78766397787381",
		Ability = "rbxassetid://139178228834787"
	},
	FaceTextures = {
		Normal = "rbxassetid://84063381517655",
		Blink = "rbxassetid://103991320583591",
		Hurt = "rbxassetid://115414173032208"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}