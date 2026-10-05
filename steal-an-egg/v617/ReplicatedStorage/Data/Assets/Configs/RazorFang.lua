local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)

-- equivalent calls inferred from this helper; original call sites unknown
local function makeAnimation(animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	return animation
end

return table.freeze({
	_id = "RazorFang",
	DisplayName = "RazorFang",
	Icon = "rbxassetid://102849850756685",
	Egg = table.freeze({
		DisplayName = "RazorFang Egg",
		Icon = "rbxassetid://78651457785123",
		ModelName = "RazorFang",
		GrowthTime = 12600,
		WeightKg = 5
	}),
	EarningRate = 350000000,
	IndexSpeedReward = 90000000,
	DropWeight = 0,
	VisualOdds = 135.13513513513513,
	ModelWeight = 12000,
	Animations = table.freeze({
		Idle = makeAnimation("rbxassetid://136791371854597"),
		Walk = makeAnimation("rbxassetid://103039030085527")
	}),
	Rarity = Rarity.Rarities.Secret,
	BaseModelScale = 1,
	LimitedEggViewportScale = 1,
	LimitedEggViewportVerticalOffset = 0,
	AlbinosColorFullWhite = true,
	BaseModelColor = Color3.fromRGB(85, 78, 76),
	PossibleModelColors = table.freeze({
		table.freeze({ Color3.fromRGB(85, 78, 76), 80 }),
		table.freeze({ Color3.fromRGB(104, 87, 75), 19 }),
		table.freeze({ Color3.fromRGB(255, 255, 255), 1 })
	})
})