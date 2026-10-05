local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "TruncatedTextSize"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self:UpdateSize()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:UpdateSize()
	end))
end

function v:UpdateSize()
	self.Instance.TextSize = self.Instance.AbsoluteSize.Y
end

function v:Stop()
	self._Janitor:Destroy()
end

return v