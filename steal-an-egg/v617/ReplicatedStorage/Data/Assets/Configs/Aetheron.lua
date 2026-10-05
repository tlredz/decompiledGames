local clone = table.clone(require(script.Parent.ArchAngel))
clone._id = "Aetheron"
clone.DisplayName = "Aetheron"
clone.Icon = "rbxassetid://116718586319869"
clone.EarningRate = 6900000000
clone.ModelWeight = 120000

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
local animationId2 = "rbxassetid://97205108103704"

local function setAnimationId()
	animation.AnimationId = animationId2
end

if not pcall(setAnimationId) then
	warn("Animation rbxassetid://97205108103704 is not shared with this experience")
end

local v = {
	Idle = animation,
	Walk = 0,
	TransitionFadeDuration = nil
}
local animation2 = Instance.new("Animation")
local animationId3 = "rbxassetid://81153625252167"

local function setAnimationId2()
	animation2.AnimationId = animationId3
end

if not pcall(setAnimationId2) then
	warn("Animation rbxassetid://81153625252167 is not shared with this experience")
end

v.Walk = animation2
clone.Animations = table.freeze(v)
clone.BaseModelColor = Color3.fromRGB(255, 48, 12)
clone.PossibleModelColors = table.freeze({
	table.freeze({ Color3.fromRGB(255, 48, 12), 850 }),
	table.freeze({ Color3.fromRGB(255, 120, 30), 90 }),
	table.freeze({ Color3.fromRGB(158, 28, 28), 48 }),
	table.freeze({ Color3.fromRGB(255, 255, 255), 12 })
})
local clone2 = table.clone(clone.Egg)
clone2.DisplayName = "Aetheron Egg"
clone2.ModelName = "Aetheron"
clone2.Icon = "rbxassetid://98329267204643"
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
	SoundId = 89464015548692
})
clone.RandomIdleSound = table.freeze({
	Data = table.freeze({
		MaxDistance = 20,
		Volume = 1.5
	}),
	SoundId = 120804583549199
})
return table.freeze(clone)