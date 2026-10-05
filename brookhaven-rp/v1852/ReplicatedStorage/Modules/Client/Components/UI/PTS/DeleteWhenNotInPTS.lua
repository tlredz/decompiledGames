local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "DeleteWhenNotInPTS"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	if game.GameId ~= 7732870260 and not RunService:IsStudio() then
		p.Instance:Destroy()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v