local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)

-- equivalent calls inferred from this helper; original call sites unknown
local function makeAnimation(animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	return animation
end

return table.freeze({
	_id = "Jellyfish",
	WalkSound = table.freeze({
		Data = table.freeze({
			Looped = true,
			MaxDistance = 20,
			Speed = 1,
			Volume = 1.5
		}),
		SoundId = 119456513629592
	}),
	RandomIdleSound = table.freeze({
		Data = table.freeze({
			MaxDistance = 20,
			Volume = 1.5
		}),
		SoundId = 120392356663478
	}),
	DisplayName = "Pure Jellyfish",
	Icon = "rbxassetid://125711705647799",
	Egg = table.freeze({
		DisplayName = "Pure Jellyfish Egg",
		Icon = "rbxassetid://128249019051623",
		ModelName = "Jellyfish",
		GrowthTime = 10800,
		WeightKg = 10
	}),
	EarningRate = 225000000,
	IndexSpeedReward = 30000000,
	DropWeight = 0,
	VisualOdds = 22.935779816513758,
	ModelWeight = 10000,
	Animations = table.freeze({
		Idle = makeAnimation("rbxassetid://138191306409960"),
		Walk = makeAnimation("rbxassetid://86698796056796")
	}),
	Rarity = Rarity.Rarities.Secret,
	BaseModelScale = 1,
	LimitedEggViewportScale = 1,
	LimitedEggViewportVerticalOffset = 0,
	AlbinosColorFullWhite = true,
	BaseModelColor = Color3.fromRGB(243, 243, 210),
	PossibleModelColors = table.freeze({
		table.freeze({ Color3.fromRGB(243, 243, 210), 80 }),
		table.freeze({ Color3.fromRGB(232, 228, 197), 19 }),
		table.freeze({ Color3.fromRGB(255, 255, 255), 1 })
	})
})