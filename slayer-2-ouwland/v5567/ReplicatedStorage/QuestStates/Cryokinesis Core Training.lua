local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EvilArtCores = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.EvilArtCores)
local UnderwaterRocksState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.UnderwaterRocksState)
return UnderwaterRocksState(EvilArtCores.Key("Cryokinesis"))