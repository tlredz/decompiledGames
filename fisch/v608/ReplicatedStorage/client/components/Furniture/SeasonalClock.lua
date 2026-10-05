local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local v = Component.new({
	Tag = "SeasonalClock",
	Ancestors = { workspace }
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	p.trove:Add(task.spawn(function()
		local back = p.Instance:WaitForChild("Back")
		local hand = p.Instance:WaitForChild("Hand")
		local handAttach = back:WaitForChild("HandAttach")
		hand.Anchored = false

		while p.Instance.Parent do
			local v2 = math.fmod(workspace:GetServerTimeNow(), 138240) / 34560
			handAttach.CFrame = CFrame.fromOrientation(0, 0, v2 * 1.5707963267948966 + -1.5707963267948966)
			task.wait(1)
		end
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v