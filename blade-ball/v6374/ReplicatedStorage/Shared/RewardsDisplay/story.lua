local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = {
	Blue = {
		Banner = {
			HoverImage = "rbxassetid://15997756526",
			Image = "rbxassetid://15994058890"
		},
		Flame = "rbxassetid://15994058406"
	},
	Orange = {
		Banner = {
			HoverImage = "rbxassetid://15997757551",
			Image = "rbxassetid://15994059410"
		},
		Flame = "rbxassetid://15994057974"
	},
	Rainbow = {
		Banner = {
			HoverImage = "rbxassetid://15997757055",
			Image = "rbxassetid://15994059209"
		},
		Flame = "rbxassetid://15994058213"
	}
}
local v2 = {
	IsNew = false,
	Stars = 1,
	Rarity = "Blue",
	RewardType = "Explosion",
	RewardIcon = "rbxassetid://15640244880"
}
local v3 = {
	IsNew = true,
	Stars = 3,
	Rarity = "Orange",
	RewardType = "Explosion",
	RewardIcon = "rbxassetid://15640244880"
}
local v4 = {
	{
		IsNew = true,
		Stars = 4,
		Rarity = "Rainbow",
		RewardType = "Explosion",
		RewardIcon = "rbxassetid://15640244880"
	},
	v3,
	v3,
	v2,
	v2,
	v2,
	v2,
	v2,
	v2,
	v2
}
local TweenService = game:GetService("TweenService")
local clone = script.Reward:Clone()
local star = clone.Banner.Frame.Stars.Star
star.Parent = nil

local function fastTween(...)
	local tween = TweenService:Create(...)
	tween:Play()
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	return tween
end

local function animate(p, maid)
	p.Banner.Position = UDim2.fromScale(5.5, 0.5)
	p.Banner.GroupTransparency = 5
	maid:Add(fastTween(p.Banner, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		Position = UDim2.fromScale(0.5, 0.5),
		GroupTransparency = 0
	})).Completed:Wait()
	maid:Add(fastTween(p.Flames, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		ImageTransparency = 0
	})).Completed:Wait()
	maid:Add(fastTween(p.Flames, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		ImageTransparency = 0.5
	}))
end

local function createFrame(p)
	local clone2 = clone:Clone()
	clone2.Flames.ImageTransparency = 1
	clone2.Banner.GroupTransparency = 1
	local v5 = v[p.Rarity or "Blue"] or v.Blue
	clone2.Flames.Image = v5.Flame
	clone2.Banner.Frame.HoverImage = v5.Banner.HoverImage
	clone2.Banner.Frame.Image = v5.Banner.Image

	for _ = 1, p.Stars do
		local clone_2 = star:Clone()
		clone_2.Parent = clone2.Banner.Frame.Stars
	end

	return clone2
end

return function(parent)
	parent:ClearAllChildren()
	local maid = require3(ReplicatedStorage2.Packages.Trove).new()
	maid:Add(clone)
	local uIListLayout = Instance.new("UIListLayout", parent)
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal

	for k, v5 in v4 do
		local frame = createFrame(v5)
		frame.LayoutOrder = k
		frame.Parent = parent
		maid:Add(task.delay(k * 0.15, animate, frame, maid))
	end

	return function()
		maid:Destroy()
	end
end