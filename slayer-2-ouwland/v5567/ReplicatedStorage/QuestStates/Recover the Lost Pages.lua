local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickupState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.PickupState)
return PickupState.forTask("Ill find the pages", "Lost Pages", {
	ObjectText = "Lost Page",
	Model = game.ReplicatedStorage.Assets.Pages
})