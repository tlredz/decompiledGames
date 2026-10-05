local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickupState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.PickupState)
local scroll = ReplicatedStorage.Assets.Quests:FindFirstChild("Scroll")
return PickupState.forTask("Ill learn the Reaping Blades Style(Lv 100)", "Reaper Scroll", {
	ObjectText = "Reaper Scroll",
	Model = scroll
})