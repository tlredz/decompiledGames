local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)

-- equivalent calls inferred from this helper; original call sites unknown
local function makeAnimation(animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	return animation
end

return table.freeze({
	_id = "Ringlord",
	WalkSound = table.freeze({
		Data = table.freeze({
			Looped = true,
			MaxDistance = 20,
			Speed = 1,
			Volume = 1.5
		}),
		SoundId = 118578341930967
	}),
	RandomIdleSound = table.freeze({
		Data = table.freeze({
			MaxDistance = 20,
			Volume = 1.5
		}),
		SoundId = 82083136808152
	}),
	DisplayName = "Ringlord",
	Icon = "rbxassetid://91756381949392",
	Egg = table.freeze({
		DisplayName = "Ringlord Egg",
		Icon = "rbxassetid://126807681611943",
		ModelName = "Ringlord",
		GrowthTime = 21600,
		WeightKg = 80
	}),
	EarningRate = 825000000,
	IndexSpeedReward = 0,
	DropWeight = 0,
	VisualOdds = 1,
	ModelWeight = 80,
	Animations = table.freeze({
		Idle = makeAnimation("rbxassetid://116695407509351"),
		Walk = makeAnimation("rbxassetid://116861024650521")
	}),
	Rarity = Rarity.Rarities.Secret,
	BaseModelScale = 1,
	LimitedEggViewportScale = 1,
	LimitedEggViewportVerticalOffset = 0,
	BaseModelColor = Color3.fromRGB(90, 87, 83),
	PossibleModelColors = table.freeze({
		table.freeze({ Color3.fromRGB(90, 87, 83), 80 }),
		table.freeze({ Color3.fromRGB(110, 98, 78), 19 }),
		table.freeze({ Color3.fromRGB(255, 255, 255), 1 })
	}),
	AlbinosColorFullWhite = true,
	DontRoll = true
})