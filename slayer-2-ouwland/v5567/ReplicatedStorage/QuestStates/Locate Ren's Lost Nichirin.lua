local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickupState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.PickupState)
return PickupState.forTask("Ill look for your blade(Lv 75)", "Nichirin Blade found", {
	ObjectText = "Nichirin Blade",
	Model = ReplicatedStorage.Assets.Quests["Nichirin Blade"]
})