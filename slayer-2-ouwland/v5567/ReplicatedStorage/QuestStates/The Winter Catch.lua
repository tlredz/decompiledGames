local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DepositState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DepositState)
return DepositState.forTasks("Ill fill the winter stores(Lv 105)", {
	"Golden Fish stocked",
	"Clown Fish stocked",
	"Zebra Fish stocked",
	"Crustadon stocked",
	"Krathulon stocked"
}, {
	ObjectText = "Gate Stores",
	ActionText = "Load",
	Title = "The Winter Catch",
	Interval = 0.15,
	BurstAt = createVector(-111.113, 1354.286, -2524.389),
	BillboardAt = createVector(-111.113, 1364.686, -2524.389),
	VfxScale = 2
})