local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)

for _, moduleScript in script:QueryDescendants("ModuleScript") do
	local module = require(moduleScript)
	module(localPlayer, data)
end