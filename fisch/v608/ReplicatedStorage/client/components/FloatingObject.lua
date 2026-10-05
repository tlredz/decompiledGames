local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local v = Component.new({
	Tag = "FloatingObject",
	Ancestors = { Workspace }
})

function v:Construct()
	local position = self.Instance:GetPivot().Position
	self.Thread = task.defer(function()
		local total = 0

		while true do
			local v2 = task.wait()

			if not self.Instance then
				break
			end

			total += v2
			local v3 = math.sin(total * 1.5) * 0.25
			local v4 = position + Vector3.new(0, v3, 0)
			self.Instance:PivotTo(CFrame.new(v4) * CFrame.Angles(0, total * 1, 0))
		end
	end)
end

function v.Stop(p)
	if p.Thread then
		task.cancel(p.Thread)
	end
end

return v