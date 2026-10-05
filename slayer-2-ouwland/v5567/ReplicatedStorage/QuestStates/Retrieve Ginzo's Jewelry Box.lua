local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickupState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.PickupState)
return PickupState.forTask("Ill find the jewelry box(Lv 45)", "Jewelry Box found", {
	ObjectText = "Jewelry Box",
	Model = ReplicatedStorage.Assets.Quests.JewelryBox
})