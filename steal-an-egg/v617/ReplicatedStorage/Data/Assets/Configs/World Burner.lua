local LightDarkPlaceholder = require(script.Parent.Parent.LightDarkPlaceholder)
local clone = table.clone(LightDarkPlaceholder.FromTemplate("Archdemon Dragon", {
	_id = "World Burner",
	DisplayName = "World Burner",
	Rarity = "Divine",
	EarningRate = 5000000000,
	IndexSpeedReward = 600000000,
	VisualOdds = 5000
}))

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
local animationId2 = "rbxassetid://105908120568207"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://105908120568207 is not shared with this experience")
end

local v = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://134098549938118"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://134098549938118 is not shared with this experience")
end

v.Walk = animation2
clone.Animations = table.freeze(v)
clone.Icon = "rbxassetid://74345431327000"
local clone2 = table.clone(clone.Egg)
clone2.Icon = "rbxassetid://117970605290776"
clone2.GrowthTime = 64800
clone.Egg = table.freeze(clone2)
clone.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 107316499206585
})
clone.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 112126857388298
})
return table.freeze(clone)