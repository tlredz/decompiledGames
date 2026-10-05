local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickupState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.PickupState)
local scroll = ReplicatedStorage.Assets.Quests:FindFirstChild("Scroll")
return PickupState.forTask("Ill learn the Tai Chi Style(Lv 65)", "Tai Chi Scroll", {
	ObjectText = "Tai Chi Scroll",
	Model = scroll
})