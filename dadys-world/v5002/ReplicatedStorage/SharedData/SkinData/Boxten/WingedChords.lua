local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Winged Chords",
	TowerName = "Boxten",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W2,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://123088431322768",
		Walk = "rbxassetid://123141912082344",
		Idle = "rbxassetid://95727319423093",
		Decode = "rbxassetid://103776095142099",
		Quirk = "rbxassetid://109390279112826"
	},
	FaceTextures = {
		Normal = "rbxassetid://97944092662465",
		Blink = "rbxassetid://117629407561472",
		Hurt = "rbxassetid://84757306597357"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}