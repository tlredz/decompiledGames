local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = {
	Red = {
		Banner = {
			Image = "rbxassetid://16020983254"
		},
		Flame = "rbxassetid://16189217919",
		FlameColor = Color3.fromRGB(255, 65, 65)
	},
	Purple = {
		Banner = {
			Image = "rbxassetid://16019120071"
		},
		Flame = "rbxassetid://16189183935",
		FlameColor = Color3.fromRGB(147, 70, 255)
	}
}
local v2 = {
	Stars = 3,
	Rarity = "Purple",
	RewardName = "Reward 1",
	RewardIcon = "rbxassetid://15640244880"
}
local _ = {
	{
		IsNew = true,
		Stars = 5,
		Rarity = "Red",
		RewardName = "Reward 2",
		RewardIcon = "rbxassetid://15640244880"
	},
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

local function createFrame(item, maid)
	local clone2 = clone:Clone()
	clone2.Flames.ImageTransparency = 1
	clone2.Banner.GroupTransparency = 1
	local v3 = v[item.Rarity or "Purple"] or v.Purple
	clone2.Flames.Image = v3.Flame
	clone2.Flames.ImageColor3 = v3.FlameColor
	clone2.Banner.Frame.Image = v3.Banner.Image
	clone2.Banner.Frame.ItemName.Text = item.RewardName
	clone2.Banner.Frame.Icon.Image = item.RewardIcon or ""
	clone2.Banner.Frame.New.Visible = item.IsNew

	for _ = 1, item.Stars do
		local clone_2 = star:Clone()
		clone_2.Parent = clone2.Banner.Frame.Stars
	end

	local uIScale = clone2.UIScale
	maid:Add(clone2.Hitbox.MouseEnter:Connect(function()
		fastTween(uIScale, TweenInfo.new(0.1), {
			Scale = 1.1
		})
	end))
	maid:Add(clone2.Hitbox.MouseLeave:Connect(function()
		fastTween(uIScale, TweenInfo.new(0.1), {
			Scale = 1
		})
	end))
	return clone2
end

return function(parent, items)
	parent:ClearAllChildren()
	local maid = require3(ReplicatedStorage2.Packages.Trove).new()
	maid:Add(clone)

	if not parent:FindFirstChild("UIListLayout") then
		local uIListLayout = Instance.new("UIListLayout", parent)
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	end

	for k, item in items do
		local v3 = maid:Add((createFrame(item, maid)))
		v3.LayoutOrder = item.LayoutOrder or k
		v3.Parent = parent
		maid:Add(task.delay(k * 0.15, animate, v3, maid))
	end

	return function()
		maid:Destroy()
	end
end