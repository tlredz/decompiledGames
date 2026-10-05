local LightDarkPlaceholder = require(script.Parent.Parent.LightDarkPlaceholder)
local clone = table.clone(LightDarkPlaceholder.FromTemplate("Alabaster Whale", {
	_id = "Pegasus",
	DisplayName = "Pegasus",
	Rarity = "Eternal",
	EarningRate = 1300000000,
	IndexSpeedReward = 200000000,
	VisualOdds = 322.5806451612903
}))
clone.ModelWeight = 65000

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
local animationId2 = "rbxassetid://115495639401411"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://115495639401411 is not shared with this experience")
end

local v = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://71740487568684"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://71740487568684 is not shared with this experience")
end

v.Walk = animation2
clone.Animations = table.freeze(v)
local clone2 = table.clone(clone.Egg)
clone2.Icon = "rbxassetid://79544542526316"
clone2.GrowthTime = 36000
clone.Egg = table.freeze(clone2)
clone.Icon = "rbxassetid://112830316982322"
clone.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 100255579453255
})
clone.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 109471556133110
})
return table.freeze(clone)