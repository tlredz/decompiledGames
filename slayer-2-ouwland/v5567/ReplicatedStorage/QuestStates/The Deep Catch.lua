local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DepositState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DepositState)
return DepositState.forTasks(
	"Ill haul in the deep catch(Lv 125)",
	{ "Crustadon stocked", "Krathulon stocked", "Clown Fish stocked" },
	{
		ObjectText = "Gate Stores",
		ActionText = "Load",
		Title = "The Deep Catch",
		Interval = 0.15,
		BurstAt = createVector(-111.113, 1354.286, -2524.389),
		BillboardAt = createVector(-111.113, 1363.736, -2524.389),
		VfxScale = 2
	}
)