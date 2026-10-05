local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "AnimatedDials"
})
require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local ClientZoneEmitter = require(ReplicatedStorage.Modules.Client.Components.World.ClientZoneEmitter)

function v:Construct()
	self._Janitor = Janitor.new()
	self.forcedOpen = false
	self.SetForcedOpen = Signal.new()
	self._Janitor:Add(self.SetForcedOpen)
	self._Janitor:Add(self.SetForcedOpen:Connect(function(forcedOpen)
		self.forcedOpen = forcedOpen
	end))
end

function v.Start(p)
	local value = p.Instance:FindFirstChild("LinkedZone") and p.Instance.LinkedZone.Value or p.Instance:FindFirstChild("AnimateZone")
	ClientZoneEmitter:WaitForInstance(value):expect()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v