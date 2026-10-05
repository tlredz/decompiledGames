local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickupState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.PickupState)
return PickupState.forTask("Ill look for it(Lv 10)", "Gemstone found", {
	ObjectText = "Gemstone",
	Model = ReplicatedStorage.Assets.GemStone
})