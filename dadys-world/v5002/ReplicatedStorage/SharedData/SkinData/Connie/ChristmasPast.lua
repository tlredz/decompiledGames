local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Christmas Past",
	TowerName = "Connie",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W4,
	Christmas = true,
	HolidaySkin = true,
	GeneratorOffset = {
		Y = 0,
		Z = -0.7
	},
	TreadmillGeneratorOffset = {
		Y = 0,
		Z = 1
	},
	OverwriteAnimations = {
		Run = "rbxassetid://125405568827708",
		Walk = "rbxassetid://101786356879714",
		Idle = "rbxassetid://96412679901902",
		Quirk = "rbxassetid://113665293377170",
		Decode = "rbxassetid://133500601575506"
	},
	FaceTextures = {
		Blink = "rbxassetid://86773043621424",
		Hurt = "rbxassetid://108260989278774",
		Normal = "rbxassetid://116207182734348"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(folder)
		local color = Color3.fromRGB(162, 183, 211)

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.Color = color
			end
		end
	end
}