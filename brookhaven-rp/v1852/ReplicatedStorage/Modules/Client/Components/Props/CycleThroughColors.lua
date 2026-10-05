local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "CycleThroughColors"
})

function v:CycleColorLoop()
	local thread = coroutine.create(function()
		while true do
			for _, color in self.colorCycle do
				self.Instance.Color = color
				task.wait(self.Instance:GetAttribute("ColorChangeInterval") or 1)
			end

			task.wait()
		end
	end)
	coroutine.resume(thread)
	return thread
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.colorCycle = {}
	local parts = (self.Instance:GetAttribute("ColorCycle") or "Really red, Really blue"):split(",")

	for _, part in ipairs(parts) do
		local match = part:match("^%s*(.-)%s*$")
		table.insert(self.colorCycle, BrickColor.new(match).Color)
	end
end

function v:Start()
	self.colorCycleThread = self:CycleColorLoop()
	self._Janitor:Add(self.colorCycleThread)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v