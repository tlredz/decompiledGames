local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local playerGui = Players.LocalPlayer.PlayerGui
return Observers.observeTagNoAncestry("LiveSaleSurfaceGui", function(p)
	p.Adornee = p.Parent
	p.ResetOnSpawn = false
	p.Parent = playerGui
	return function() end
end)