local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HousePropManagerButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v