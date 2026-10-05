local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Data.Rarity)
local configs = script.Parent.Configs

local function makeAnimation(animationId: string)
	local animation = Instance.new("Animation")

	local function setAnimationId()
		animation.AnimationId = animationId
	end

	if not pcall(setAnimationId) then
		warn((`Animation {animationId} is not shared with this experience`))
	end

	return animation
end

local function borrowAnimations(module)
	local animations = module.Animations

	if animations == nil then
		return nil
	end

	local idle

	if animations.Idle then
		idle = makeAnimation(animations.Idle.AnimationId)
	end

	local walk

	if animations.Walk then
		walk = makeAnimation(animations.Walk.AnimationId)
	end

	return table.freeze({
		Idle = idle,
		Walk = walk,
		TransitionFadeDuration = animations.TransitionFadeDuration
	})
end

return table.freeze({
	FromTemplate = function(childName: string, data)
		local child = configs:FindFirstChild(childName)
		assert(child ~= nil, (`No asset config named "{childName}" to borrow placeholder art from`))
		local module = require(child)
		local rarity = Rarity.Rarities[data.Rarity]
		assert(rarity ~= nil, (`Unknown rarity "{data.Rarity}" on {data._id}`))
		return table.freeze({
			_id = data._id,
			DisplayName = data.DisplayName,
			Icon = module.Icon,
			Egg = table.freeze({
				DisplayName = `{data.DisplayName} Egg`,
				Icon = module.Egg.Icon,
				GrowthTime = module.Egg.GrowthTime,
				WeightKg = module.Egg.WeightKg,
				HideRarity = module.Egg.HideRarity,
				IgnoreSizeGrowthMultiplier = module.Egg.IgnoreSizeGrowthMultiplier
			}),
			WhiteImage = nil,
			MutationIcons = nil,
			EarningRate = data.EarningRate,
			IndexSpeedReward = data.IndexSpeedReward,
			DropWeight = 0,
			VisualOdds = data.VisualOdds,
			ModelWeight = module.ModelWeight,
			Animations = borrowAnimations(module),
			WalkAnimationReferenceSpeed = module.WalkAnimationReferenceSpeed,
			Rarity = rarity,
			BaseModelScale = module.BaseModelScale,
			LimitedEggViewportScale = module.LimitedEggViewportScale,
			LimitedEggViewportVerticalOffset = module.LimitedEggViewportVerticalOffset,
			BaseModelColor = module.BaseModelColor,
			PossibleModelColors = module.PossibleModelColors,
			PlaceSound = module.PlaceSound,
			WalkSound = module.WalkSound,
			RandomIdleSound = module.RandomIdleSound,
			LuckyBlockDropTable = nil,
			LuckyBlockDropTableType = nil,
			LuckyBlockLevelRange = nil,
			LuckyBlockOpenDuration = nil,
			DontRoll = nil,
			CannotFuse = nil,
			GenderLocked = nil,
			AlbinosColorFullWhite = nil
		})
	end
})