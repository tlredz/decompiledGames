local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ParentToPlayerGui"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	p.Instance.ResetOnSpawn = false
	p.Instance.Adornee = p.Instance.Parent
	p.Instance.Parent = Players.LocalPlayer.PlayerGui
end

function v:Stop()
	self._Janitor:Destroy()
end

return v