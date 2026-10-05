local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)

-- equivalent calls inferred from this helper; original call sites unknown
local function makeAnimation(animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	return animation
end

return table.freeze({
	_id = "Ring Guard",
	WalkSound = table.freeze({
		Data = table.freeze({
			Looped = true,
			MaxDistance = 20,
			Speed = 1,
			Volume = 1.5
		}),
		SoundId = 107135546418104
	}),
	RandomIdleSound = table.freeze({
		Data = table.freeze({
			MaxDistance = 20,
			Volume = 1.5
		}),
		SoundId = 108615491098304
	}),
	DisplayName = "Ring Guard",
	Icon = "rbxassetid://97967732679537",
	Egg = table.freeze({
		DisplayName = "Ring Guard Egg",
		Icon = "rbxassetid://105780316822746",
		ModelName = "Ring Guard",
		GrowthTime = 1140,
		WeightKg = 80
	}),
	EarningRate = 15000000,
	IndexSpeedReward = 0,
	DropWeight = 0,
	VisualOdds = 1,
	ModelWeight = 80,
	Animations = table.freeze({
		Idle = makeAnimation("rbxassetid://105537650706847"),
		Walk = makeAnimation("rbxassetid://127903082838058")
	}),
	Rarity = Rarity.Rarities.Cosmic,
	BaseModelScale = 1,
	LimitedEggViewportScale = 1,
	LimitedEggViewportVerticalOffset = 0,
	BaseModelColor = Color3.fromRGB(107, 97, 78),
	PossibleModelColors = table.freeze({
		table.freeze({ Color3.fromRGB(107, 97, 78), 80 }),
		table.freeze({ Color3.fromRGB(91, 84, 70), 19 }),
		table.freeze({ Color3.fromRGB(255, 255, 255), 1 })
	}),
	AlbinosColorFullWhite = true,
	DontRoll = true
})