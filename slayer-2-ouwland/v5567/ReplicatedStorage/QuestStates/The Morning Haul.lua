local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DepositState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DepositState)
return DepositState.forTasks("Ill fill your crates(Lv 45)", {
	"OuwFish crated",
	"Sea Horse crated",
	"Coral crated",
	"OuwFwesh crated"
}, {
	ObjectText = "Fish Crate",
	ActionText = "Load",
	Title = "The Morning Haul",
	Interval = 0.15,
	VfxScale = 1.5,
	BurstAt = createVector(-574.4017, 799.6649, 684.5108),
	BillboardAt = createVector(-574.1119, 809.04486, 687.1166)
})