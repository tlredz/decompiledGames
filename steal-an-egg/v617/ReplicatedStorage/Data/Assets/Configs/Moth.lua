local LightDarkPlaceholder = require(script.Parent.Parent.LightDarkPlaceholder)
local clone = table.clone(LightDarkPlaceholder.FromTemplate("Snowy Owl", {
	_id = "Moth",
	DisplayName = "Sacred Moth",
	Rarity = "Cosmic",
	EarningRate = 16000000,
	IndexSpeedReward = 8000000,
	VisualOdds = 5.9417706476530014
}))
clone.ModelWeight = 9000

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
local animationId2 = "rbxassetid://113695479057312"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://113695479057312 is not shared with this experience")
end

local v = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://95246247805951"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://95246247805951 is not shared with this experience")
end

v.Walk = animation2
clone.Animations = table.freeze(v)
local clone2 = table.clone(clone.Egg)
clone2.GrowthTime = 900
clone2.Icon = "rbxassetid://104832997526909"
clone.Egg = table.freeze(clone2)
clone.Icon = "rbxassetid://114029210145538"
clone.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 88538312814962
})
clone.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 113504042242020
})
return table.freeze(clone)