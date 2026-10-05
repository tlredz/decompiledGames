local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Bright Dawn",
	TowerName = "Brightney",
	Cost = 600,
	Easter = true,
	HolidaySkin = true,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W2,
	OverwriteAnimations = {
		Run = "rbxassetid://113929697033897",
		Walk = "rbxassetid://90628619847725",
		Idle = "rbxassetid://77721941644513",
		Quirk = "rbxassetid://131213389028603",
		Decode = "rbxassetid://117147334925696",
		Ability = "rbxassetid://103874463800397"
	},
	FaceTextures = {
		Normal = "rbxassetid://75253258733420",
		Blink = "rbxassetid://132426476498735",
		Hurt = "rbxassetid://112757156367420"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(folder)
		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(165, 162, 141)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(165, 162, 141))
				})
			elseif descendant:IsA("Light") then
				descendant.Color = Color3.fromRGB(165, 162, 141)
			end
		end
	end
}