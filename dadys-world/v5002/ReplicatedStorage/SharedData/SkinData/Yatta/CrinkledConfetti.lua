local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Crinkled Confetti",
	TowerName = "Yatta",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Requirement1 = { "Baskets", 1200 },
	Requirement2 = { "Coin", 1200 },
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W4,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://121887597056169",
		Walk = "rbxassetid://113493276030799",
		Idle = "rbxassetid://94672939370149",
		Quirk = "rbxassetid://120524896657767",
		Decode = "rbxassetid://81195350931735"
	},
	FaceTextures = {
		Normal = "rbxassetid://113943149131298",
		Blink = "rbxassetid://88634530591097",
		Hurt = "rbxassetid://76000836398496"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}