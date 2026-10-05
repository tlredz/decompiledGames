local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickupState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.PickupState)
return PickupState.forTask("Ill find the coins(Lv 21)", "Coins collected", {
	ObjectText = "Coin",
	Model = ReplicatedStorage.Assets.Quests.LuckyCoin
})