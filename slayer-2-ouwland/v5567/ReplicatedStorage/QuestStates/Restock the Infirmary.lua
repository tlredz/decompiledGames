local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DepositState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DepositState)
return DepositState.forTasks(
	"Ill restock the infirmary(Lv 70)",
	{ "Health Elixirs stocked", "Health Regen Elixirs stocked", "Stamina Regen Elixirs stocked" },
	{
		ObjectText = "Infirmary Crates",
		ActionText = "Stock",
		Title = "Infirmary Restock",
		Interval = 0.15,
		BurstAt = createVector(-1848.23, 315.086, -125.179),
		BillboardAt = createVector(-1848.23, 319.886, -119.539),
		VfxScale = 1.5
	}
)