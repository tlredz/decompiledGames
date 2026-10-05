local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
require(packages.Trove)
local v = Component.new({
	Tag = "FloatingCandle"
})

function v.SteppedUpdate(data, _: number)
	data.Instance:PivotTo(data.BaseCF * CFrame.new(0, data.RandomAltitudeSeed * math.sin((tick())), 0))
end

function v:Start()
	self.BaseCF = self.Instance:GetPivot()
	self.RandomAltitudeSeed = Random.new():NextNumber(0.3, 0.8)
end

function v.Stop(_) end

return v