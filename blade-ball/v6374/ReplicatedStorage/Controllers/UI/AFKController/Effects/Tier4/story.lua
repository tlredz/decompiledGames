local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Shared.FastUtils)
local v3 = require3(script["Starry.story"])

local function createStar(p, _)
	local v3_2 = v3(Vector2.zero, p, 25)
	v3_2.Position = UDim2.fromScale(math.random(), math.random())
end

return function(parent)
	local maid = v.new()
	maid:Add(v2.fastAudio("rbxassetid://16757431297", parent))
	local v4 = maid:Add(Instance.new("Frame"))
	v4.BackgroundColor3 = Color3.new()
	v4.BackgroundTransparency = 0
	v4.Size = UDim2.fromScale(1, 1)
	v4.ZIndex = 0
	v4.Parent = parent
	local v5 = maid:Add(Instance.new("Frame"))
	v5.BackgroundColor3 = Color3.new(1, 1, 1)
	v5.BackgroundTransparency = 0
	v5.Size = UDim2.fromScale(1, 1)
	v5.ZIndex = 10
	v5.Parent = parent
	local v6 = maid:Add(Instance.new("ImageLabel"))
	v6.BackgroundTransparency = 1
	v6.AnchorPoint = Vector2.new(0.5, 0.5)
	v6.Position = UDim2.fromScale(0.5, 0.5)
	v6.Size = UDim2.fromScale(1, 1)
	v6.Image = "rbxassetid://16746234145"
	v6.ScaleType = Enum.ScaleType.Crop
	v6.ZIndex = 2
	v6.ImageTransparency = 0.9
	v6.Parent = parent
	maid:Add(v2.fastTween(v6, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true), {
		ImageTransparency = 0.95
	}))
	local v7 = maid:Add(Instance.new("ImageLabel"))
	v7.BackgroundTransparency = 1
	v7.AnchorPoint = Vector2.new(0.5, 0.5)
	v7.Position = UDim2.fromScale(0.5, 0.5)
	v7.Size = UDim2.fromScale(1, 1)
	v7.Image = "rbxassetid://16661396780"
	v7.ScaleType = Enum.ScaleType.Fit
	v7.ImageTransparency = 1
	v7.ZIndex = 2
	v7.Parent = parent
	maid:Add(v2.fastTween(v7, TweenInfo.new(4), {
		ImageTransparency = 0.975,
		Rotation = 45
	}))
	local v8 = maid:Add(Instance.new("ImageLabel"))
	v8.BackgroundTransparency = 1
	v8.AnchorPoint = Vector2.new(0.5, 0.5)
	v8.Position = UDim2.fromScale(0.5, 0.5)
	v8.Size = UDim2.fromScale(0.75, 0.75)
	v8.Image = "rbxassetid://16745821408"
	v8.ScaleType = Enum.ScaleType.Fit
	v8.ImageTransparency = 1
	v8.ZIndex = 2
	v8.Parent = parent

	for i = 0, 5, 0.5 do
		for _ = 1, 3 do
			task.delay(i + math.random(), createStar, parent, maid)
		end
	end

	maid:Add(v2.fastTween(v5, TweenInfo.new(0.15), {
		BackgroundTransparency = 1
	}))
	task.wait(1)
	maid:Add(v2.fastTween(v8, TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Rotation = 1077
	}))
	maid:Add(v2.fastTween(v8, TweenInfo.new(3), {
		ImageTransparency = 0
	})).Completed:Wait()
	task.wait(2)
	maid:Add(v2.fastTween(v8, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2, true), {
		ImageTransparency = 0.5
	})).Completed:Wait()
	maid:Add(v2.fastTween(v8, TweenInfo.new(0.05), {
		Size = UDim2.fromScale(2, 2),
		ImageTransparency = 1
	}))
	maid:Add(v2.fastTween(v4, TweenInfo.new(0.75), {
		BackgroundColor3 = Color3.fromRGB(26, 4, 22)
	}))
	task.wait(0.5)
	maid:Add(v2.fastTween(v4, TweenInfo.new(0.25), {
		BackgroundTransparency = 1
	}))
	maid:Add(v2.fastTween(v6, TweenInfo.new(0.25), {
		ImageTransparency = 1
	}))
	maid:Add(v2.fastTween(v7, TweenInfo.new(0.25), {
		ImageTransparency = 1
	}))
	task.wait(0.25)
	task.delay(2.75, function()
		maid:Destroy()
	end)
	return function()
		maid:Clean()
	end
end