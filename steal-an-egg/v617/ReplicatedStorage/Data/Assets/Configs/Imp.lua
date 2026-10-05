local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)

-- equivalent calls inferred from this helper; original call sites unknown
local function makeAnimation(animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	return animation
end

return table.freeze({
	_id = "Imp",
	WalkSound = table.freeze({
		Data = table.freeze({
			Looped = true,
			MaxDistance = 20,
			Speed = 1,
			Volume = 1.5
		}),
		SoundId = 122896507255411
	}),
	RandomIdleSound = table.freeze({
		Data = table.freeze({
			MaxDistance = 20,
			Volume = 1.5
		}),
		SoundId = 87783014657179
	}),
	DisplayName = "Imp",
	Icon = "rbxassetid://80756597804671",
	Egg = table.freeze({
		DisplayName = "Imp Egg",
		Icon = "rbxassetid://86008838296332",
		ModelName = "Imp",
		GrowthTime = 900,
		WeightKg = 5
	}),
	EarningRate = 16000000,
	IndexSpeedReward = 8000000,
	DropWeight = 0,
	VisualOdds = 5.9417706476530014,
	ModelWeight = 9000,
	Animations = table.freeze({
		Idle = makeAnimation("rbxassetid://99392172664963"),
		Walk = makeAnimation("rbxassetid://72516808870539")
	}),
	Rarity = Rarity.Rarities.Cosmic,
	BaseModelScale = 1,
	LimitedEggViewportScale = 1,
	LimitedEggViewportVerticalOffset = 0,
	AlbinosColorFullWhite = true,
	BaseModelColor = Color3.fromRGB(165, 38, 40),
	PossibleModelColors = table.freeze({
		table.freeze({ Color3.fromRGB(165, 38, 40), 80 }),
		table.freeze({ Color3.fromRGB(125, 45, 38), 19 }),
		table.freeze({ Color3.fromRGB(255, 255, 255), 1 })
	})
})