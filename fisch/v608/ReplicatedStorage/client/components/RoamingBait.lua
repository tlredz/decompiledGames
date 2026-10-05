local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local v = Component.new({
	Tag = "RoamingBait",
	Ancestors = { Workspace }
})

function v:Construct()
	local pivot = self.Instance:GetPivot()
	local lastTime = os.clock()
	local v2 = math.floor((math.random(10, 100))) / 100
	local core = self.Instance:WaitForChild("core")
	self.RoamingThread = task.spawn(function()
		while true do
			local v3 = math.sin((os.clock() - lastTime) * v2) * 0.5
			core.CFrame = pivot + Vector3.new(0, v3, 0)
			task.wait(0.1)
		end
	end)
end

function v.Stop(p)
	if p.RoamingThread then
		task.cancel(p.RoamingThread)
	end
end

return v