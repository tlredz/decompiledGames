local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Synchronizer = require(packages.Synchronizer)
local localPlayer = Players.LocalPlayer
local v = nil
return {
	Load = function(_)
		Synchronizer:WaitAndCall(localPlayer, function(p)
			v = p
			ReplicatedFirst:SetAttribute("DataLoaded", true)
		end)
	end
}