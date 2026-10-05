local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local random = Random.new()
return function(parent)
	local maid = require3(ReplicatedStorage2.Packages.Trove).new()
	local v = maid:Add(script.Triangle:Clone())
	v.Parent = nil

	for _ = 1, 15 do
		local v2 = maid:Add(v:Clone())
		v2.Size = UDim2.fromScale(random:NextNumber(0.1, 2) * 1, random:NextNumber(0.1, 2) * 1)
		v2.Rotation = random:NextNumber(0, 360)
		v2.Position = UDim2.fromScale(random:NextNumber(-0.2, 1.2), random:NextNumber(-0.2, 1.2))
		v2.Parent = parent
		maid:Add(task.spawn(function()
			while true do
				local v4 = maid:Add(TweenService:Create(v2, TweenInfo.new(60, Enum.EasingStyle.Linear), {
					Size = UDim2.fromScale(random:NextNumber(0.1, 2) * 1, random:NextNumber(0.1, 2) * 1),
					Rotation = random:NextNumber(0, 360),
					Position = UDim2.fromScale(random:NextNumber(-0.2, 1.2), random:NextNumber(-0.2, 1.2))
				}))
				v4:Play()
				v4.Completed:Wait()
				v4:Destroy()
			end
		end))
	end

	return function()
		maid:Destroy()
	end
end