local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "ExplosionReceiver"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnExploded = Signal.new()
	self._Janitor:Add(self.OnExploded)
end

function v.Start(_) end

function v.Exploded(p, p2, vector: Vector3)
	p.OnExploded:Fire(p2, vector)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v