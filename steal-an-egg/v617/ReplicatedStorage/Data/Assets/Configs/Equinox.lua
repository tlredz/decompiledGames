local clone = table.clone(require(script.Parent.Pegasus))
clone._id = "Equinox"
clone.DisplayName = "Equinox"
clone.Icon = "rbxassetid://92079543818607"
clone.EarningRate = 1800000000
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
local animationId2 = "rbxassetid://84399470387824"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://84399470387824 is not shared with this experience")
end

local v = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://102707946124614"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://102707946124614 is not shared with this experience")
end

v.Walk = animation2
clone.Animations = table.freeze(v)
clone.BaseModelColor = Color3.fromRGB(240, 194, 77)
clone.PossibleModelColors = table.freeze({
	table.freeze({ Color3.fromRGB(240, 194, 77), 850 }),
	table.freeze({ Color3.fromRGB(255, 223, 142), 90 }),
	table.freeze({ Color3.fromRGB(196, 140, 56), 48 }),
	table.freeze({ Color3.fromRGB(255, 255, 255), 12 })
})
local clone2 = table.clone(clone.Egg)
clone2.DisplayName = "Equinox Egg"
clone2.ModelName = "Equinox"
clone2.Icon = "rbxassetid://73572093043918"
clone.Egg = table.freeze(clone2)
clone.DropWeight = 0
clone.DontRoll = true
clone.WalkSound = table.freeze({
	Data = table.freeze({
		Looped = true,
		MaxDistance = 20,
		Speed = 1,
		Volume = 1.5
	}),
	SoundId = 127024805236306
})
clone.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 105229098897232
})
return table.freeze(clone)