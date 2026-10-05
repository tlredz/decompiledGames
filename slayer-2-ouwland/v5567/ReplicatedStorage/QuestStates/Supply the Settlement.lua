local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DepositState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DepositState)
return DepositState.forTasks(
	"Ill help you survive the winter(Lv 100)",
	{ "Cooked Bear Meat stocked", "Health Elixirs stocked" },
	{
		ObjectText = "Gate Stores",
		ActionText = "Load",
		Title = "Supply the Settlement",
		Interval = 0.15,
		BurstAt = createVector(-111.113, 1354.286, -2524.389),
		BillboardAt = createVector(-111.113, 1363.086, -2524.389),
		VfxScale = 2
	}
)