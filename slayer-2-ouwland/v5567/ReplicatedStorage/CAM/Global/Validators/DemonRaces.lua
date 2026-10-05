local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(character)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if playerFromCharacter == nil then
		return false
	end

	local data = Utility.GetData(playerFromCharacter)
	local race = data ~= nil and data:FindFirstChild("Race") or nil
	return race ~= nil and (race.Value == "Demon" or race.Value == "Hybrid")
end