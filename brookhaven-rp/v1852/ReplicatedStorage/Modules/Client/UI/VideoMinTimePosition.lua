local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VideoMinTimePosition"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._minTime = self.Instance:GetAttribute("MinTime") or 0
end

function v:Start()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("TimePosition"):Connect(function()
		if self.Instance.TimePosition < self._minTime then
			self.Instance.TimePosition = self._minTime
		end
	end))

	if self.Instance.TimePosition < self._minTime then
		self.Instance.TimePosition = self._minTime
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v