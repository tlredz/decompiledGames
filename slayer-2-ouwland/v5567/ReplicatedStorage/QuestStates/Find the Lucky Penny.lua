local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickupState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.PickupState)
return PickupState.forTask("Ill look for the penny(Lv 14)", "Lucky Penny found", {
	ObjectText = "Lucky Penny",
	Model = ReplicatedStorage.Assets.Quests.LuckyCoin
})