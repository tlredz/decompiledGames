local LightDarkPlaceholder = require(script.Parent.Parent.LightDarkPlaceholder)
local clone = table.clone(LightDarkPlaceholder.FromTemplate("Crane", {
	_id = "Lamb",
	DisplayName = "Winged Lamb",
	Rarity = "Mythic",
	EarningRate = 1250000,
	IndexSpeedReward = 4000000,
	VisualOdds = 3.806623524933384
}))
clone.ModelWeight = 72000

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
local animationId2 = "rbxassetid://111816188642783"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://111816188642783 is not shared with this experience")
end

local v = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://79560565269439"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://79560565269439 is not shared with this experience")
end

v.Walk = animation2
clone.Animations = table.freeze(v)
clone.Icon = "rbxassetid://75083238388813"
local clone2 = table.clone(clone.Egg)
clone2.Icon = "rbxassetid://135085221683245"
clone2.GrowthTime = 480
clone.Egg = table.freeze(clone2)
clone.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 122963672192307
})
clone.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 83228840270934
})
return table.freeze(clone)