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
	maid:Add(v2.fastAudio("rbxassetid://16757430922", parent, nil, nil))
	local v3 = maid:Add(Instance.new("Frame"))
	v3.BackgroundColor3 = Color3.new(1, 1, 1)
	v3.BackgroundTransparency = 0
	v3.Size = UDim2.fromScale(1, 1)
	v3.Parent = parent
	maid:Add(v2.fastTween(v3, TweenInfo.new(0.5), {
		BackgroundTransparency = 1
	}))
	return function()
		maid:Clean()
	end
end