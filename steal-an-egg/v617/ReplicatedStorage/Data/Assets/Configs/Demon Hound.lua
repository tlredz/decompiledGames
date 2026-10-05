local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)

-- equivalent calls inferred from this helper; original call sites unknown
local function makeAnimation(animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	return animation
end

return table.freeze({
	_id = "Demon Hound",
	WalkSound = table.freeze({
		Data = table.freeze({
			Looped = true,
			MaxDistance = 20,
			Speed = 1,
			Volume = 1.5
		}),
		SoundId = 91021680910561
	}),
	RandomIdleSound = table.freeze({
		Data = table.freeze({
			MaxDistance = 20,
			Volume = 1.5
		}),
		SoundId = 109891701674473
	}),
	DisplayName = "Demon Hound",
	Icon = "rbxassetid://97830965844787",
	Egg = table.freeze({
		DisplayName = "Demon Hound Egg",
		Icon = "rbxassetid://81200150769664",
		ModelName = "Demon Hound",
		GrowthTime = 1200,
		WeightKg = 5
	}),
	EarningRate = 25000000,
	IndexSpeedReward = 20000000,
	DropWeight = 0,
	VisualOdds = 7.163323782234957,
	ModelWeight = 9000,
	Animations = table.freeze({
		Idle = makeAnimation("rbxassetid://71097341870152"),
		Walk = makeAnimation("rbxassetid://88651036276589")
	}),
	Rarity = Rarity.Rarities.Cosmic,
	BaseModelScale = 1,
	LimitedEggViewportScale = 1,
	LimitedEggViewportVerticalOffset = 0,
	AlbinosColorFullWhite = true,
	BaseModelColor = Color3.fromRGB(149, 68, 60),
	PossibleModelColors = table.freeze({
		table.freeze({ Color3.fromRGB(149, 68, 60), 80 }),
		table.freeze({ Color3.fromRGB(108, 46, 40), 19 }),
		table.freeze({ Color3.fromRGB(255, 255, 255), 1 })
	})
})