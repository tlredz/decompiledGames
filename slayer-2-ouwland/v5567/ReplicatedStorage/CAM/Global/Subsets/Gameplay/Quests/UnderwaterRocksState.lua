local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local PickupState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.PickupState)
local seaCrystal = ReplicatedStorage.Assets.Quests:FindFirstChild("Sea Crystal")
return function(p: string)
	return PickupState.forTask(p, "Underwater Rocks", {
		ObjectText = "Sea Crystal",
		Model = seaCrystal
	})
end