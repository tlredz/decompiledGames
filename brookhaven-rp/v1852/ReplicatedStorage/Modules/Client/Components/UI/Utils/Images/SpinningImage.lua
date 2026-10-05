local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "SpinningImage"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local thread = task.spawn(function()
		while true do
			self.Instance.Rotation = self.Instance.Rotation + 5
			task.wait(0.01)
		end
	end)
	self._Janitor:Add(thread)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v