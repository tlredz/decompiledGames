local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Shared.FastUtils)
return function(parent)
	local maid = v.new()
	local v3 = maid:Add(Instance.new("Frame"))
	v3.BackgroundColor3 = Color3.new()
	v3.BackgroundTransparency = 0
	v3.Size = UDim2.fromScale(1, 1)
	v3.ZIndex = 0
	v3.Parent = parent
	local v4 = maid:Add(Instance.new("Frame"))
	v4.BackgroundColor3 = Color3.new(1, 1, 1)
	v4.BackgroundTransparency = 0
	v4.Size = UDim2.fromScale(1, 1)
	v4.ZIndex = 2
	v4.Parent = parent
	local v5 = maid:Add(Instance.new("ImageLabel"))
	v5.BackgroundTransparency = 1
	v5.AnchorPoint = Vector2.new(0.5, 0.5)
	v5.Position = UDim2.fromScale(0.5, 0.5)
	v5.Size = UDim2.fromScale(0.75, 0.75)
	v5.Image = "rbxassetid://16745733577"
	v5.ScaleType = Enum.ScaleType.Fit
	v5.ImageTransparency = 1
	v5.ZIndex = 1
	v5.Parent = parent
	maid:Add(v2.fastAudio("rbxassetid://16757431504", parent))
	maid:Add(v2.fastTween(v4, TweenInfo.new(0.15), {
		BackgroundTransparency = 1
	}))
	task.wait(1)
	maid:Add(v2.fastTween(v5, TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Rotation = 1077
	}))
	maid:Add(v2.fastTween(v5, TweenInfo.new(3), {
		ImageTransparency = 0
	})).Completed:Wait()
	task.wait(2)
	maid:Add(v2.fastTween(v5, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2, true), {
		ImageTransparency = 0.5
	})).Completed:Wait()
	maid:Add(v2.fastTween(v5, TweenInfo.new(0.05), {
		Size = UDim2.fromScale(2, 2),
		ImageTransparency = 1
	}))
	maid:Add(v2.fastTween(v3, TweenInfo.new(0.75), {
		BackgroundColor3 = Color3.fromRGB(26, 4, 22)
	}))
	task.wait(0.5)
	maid:Add(v2.fastTween(v3, TweenInfo.new(0.25), {
		BackgroundTransparency = 1
	}))
	task.wait(0.25)
	task.delay(2.75, function()
		maid:Clean()
	end)
	return function()
		maid:Clean()
	end
end