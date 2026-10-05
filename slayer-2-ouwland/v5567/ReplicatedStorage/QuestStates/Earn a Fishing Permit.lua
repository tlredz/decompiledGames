local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickupState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.PickupState)
return PickupState.forTask("Ill find the permit stamp(Lv 45)", "Permit Stamp found", {
	ObjectText = "Permit Stamp",
	Model = ReplicatedStorage.Assets.Quests["Permit Stamp"]
})