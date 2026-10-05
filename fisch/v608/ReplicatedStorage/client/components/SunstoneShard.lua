local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
require(packages.Trove)
local v = Component.new({
	Tag = "SunstoneShard",
	Ancestors = { Workspace }
})

function v:Construct()
	local item = self.Instance:GetAttribute("Item")
	local child = script:FindFirstChild(item)
	self.Instance.Transparency = 1

	if not child then
		return
	end

	local clone = child:Clone()
	clone:PivotTo(CFrame.new(self.Instance.Position))
	clone:ScaleTo(2)
	self.Render = clone
	self.Thread = task.defer(function()
		local position2 = self.Instance.Position
		local total = 0

		while true do
			local v2 = task.wait()

			if not (self.Instance and clone) then
				break
			end

			total += v2
			local v3 = position2 + Vector3.new(0, math.sin(total * 1.5) * 0.25 + 2.5, 0)
			clone:PivotTo(CFrame.new(v3) * CFrame.Angles(0, total * 1, 0))
		end
	end)
	clone.Parent = self.Instance
end

function v.Stop(p)
	if p.Thread then
		task.cancel(p.Thread)
	end

	if p.Render then
		p.Render:Destroy()
	end
end

return v