local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "RepairReceiver"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnRepairEvent = Signal.new()
	self._Janitor:Add(self.OnRepairEvent)
end

function v.Start(_) end

function v.Repair(p, p2, p3)
	p.OnRepairEvent:Fire(p2, p3)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v