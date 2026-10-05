local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "Lego_FireBoat"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(_) end

function v.ToggleWaterSprayer(p)
	Remotes.fireServerComponent(p.Instance, "ToggleWaterSprayer")
end

function v:Stop()
	self._Janitor:Destroy()
end

return v