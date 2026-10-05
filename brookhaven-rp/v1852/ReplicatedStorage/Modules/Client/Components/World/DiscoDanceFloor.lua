local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "DiscoDanceFloor"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v