local LightDarkPlaceholder = require(script.Parent.Parent.LightDarkPlaceholder)
local clone = table.clone(LightDarkPlaceholder.FromTemplate("Stag", {
	_id = "Centaur",
	DisplayName = "Centaur",
	Rarity = "Secret",
	EarningRate = 350000000,
	IndexSpeedReward = 90000000,
	VisualOdds = 135.13513513513513
}))
clone.ModelWeight = 12000

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

local animation = Instance.new("Animation")
local animationId2 = "rbxassetid://103579027390419"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://103579027390419 is not shared with this experience")
end

local v = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://87256504987743"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://87256504987743 is not shared with this experience")
end

v.Walk = animation2
clone.Animations = table.freeze(v)
local clone2 = table.clone(clone.Egg)
clone2.Icon = "rbxassetid://94996357404675"
clone2.GrowthTime = 12600
clone.Egg = table.freeze(clone2)
clone.Icon = "rbxassetid://136114731886336"
clone.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 90865226033557
})
clone.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 138591041806731
})
return table.freeze(clone)