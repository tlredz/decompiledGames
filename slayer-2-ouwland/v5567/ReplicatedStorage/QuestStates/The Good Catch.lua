local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DepositState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DepositState)
return DepositState.forTasks("Ill land the good catch(Lv 60)", {
	"OuwFish crated",
	"Sea Horse crated",
	"Coral crated",
	"OuwFwesh crated",
	"Clown Fish crated",
	"Zebra Fish crated"
}, {
	ObjectText = "Fish Crate",
	ActionText = "Load",
	Title = "The Good Catch",
	Interval = 0.15,
	VfxScale = 1.5,
	BurstAt = createVector(-574.4017, 799.6649, 684.5108),
	BillboardAt = createVector(-574.1119, 810.34485, 687.1166)
})