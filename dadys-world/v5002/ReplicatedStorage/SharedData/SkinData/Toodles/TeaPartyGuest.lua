local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Tea Party Guest",
	TowerName = "Toodles",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W5,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://85986601115527",
		Walk = "rbxassetid://99299644396610",
		Idle = "rbxassetid://84593222400973",
		Quirk = "rbxassetid://107940532389587",
		Decode = "rbxassetid://94309796351268",
		Ability = "rbxassetid://124005268456653"
	},
	FaceTextures = {
		Normal = "rbxassetid://111968760057580",
		Blink = "rbxassetid://89083902752160",
		Hurt = "rbxassetid://133800907540252"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}