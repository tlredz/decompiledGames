local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DepositState = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DepositState)
return DepositState.forTasks(
	"Ill stock the reserves(Lv 75)",
	{ "Golden Fish crated", "Clown Fish crated", "Zebra Fish crated" },
	{
		ObjectText = "Infirmary Crates",
		ActionText = "Stock",
		Title = "The Full Pantry",
		Interval = 0.15,
		BurstAt = createVector(-1848.23, 315.086, -125.179),
		BillboardAt = createVector(-1848.23, 319.886, -119.539),
		VfxScale = 1.5
	}
)