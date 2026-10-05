local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local data = Utility.GetData(localPlayer, true)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
return {
	timeforquest = function()
		local quests = data.Quests
		return Quests.QuestCD - math.floor(Utility.Tick() - quests.LastTime.Value)
	end
}