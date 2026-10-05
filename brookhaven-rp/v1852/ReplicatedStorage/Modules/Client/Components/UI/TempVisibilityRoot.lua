local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "TempVisibilityRoot"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnVisibleChanged = Signal.new()
end

function v:Start()
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		self.OnVisibleChanged:Fire(self.Instance.Visible)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v