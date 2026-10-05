local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local childAreas = {
	["Final Selection"] = {
		Village = true,
		Grid = {
			{
				Center = Vector2.new(-2618.765, 3.21),
				Radius = Vector2.new(271.405, 371.94),
				Type = Menum.AreaType.Rectangle
			},
			{
				Center = Vector2.new(-1994, 1050),
				Radius = Vector2.new(103, 103),
				Type = Menum.AreaType.Rectangle
			}
		},
		CrystalAt = CFrame.new(-2547.569, 278, 31.729, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		Spawns = {
			createVector(-2555.054, 275, 16.436),
			createVector(-2558.883, 275, 28.715),
			createVector(-2544.462, 275, 21.486)
		}
	},
	["The White Terror Lair"] = {
		Cave = true,
		Grid = {
			{
				Center = Vector2.new(-1615.071, 505.244),
				Radius = Vector2.new(364.128, 215.824),
				Type = Menum.AreaType.Rectangle,
				YLimits = Vector2.new(-40, 160)
			}
		},
		IndependentMarkers = true
	}
}
local FinalSelectionPlains = {
	Area = {
		Grid = {
			{
				Center = Vector2.new(-1994.12, 1050.13),
				Radius = Vector2.new(820.79, 307.87),
				Type = Menum.AreaType.Rectangle,
				YLimits = Vector2.new(12, 592),
				IsParent = true,
				ChildAreas = childAreas
			},
			{
				Center = Vector2.new(-2618.945, 190.89),
				Radius = Vector2.new(277.035, 561.08),
				Type = Menum.AreaType.Rectangle,
				IsParent = true,
				ChildAreas = childAreas
			},
			{
				Center = Vector2.new(-2903, 384),
				Radius = Vector2.new(50, 50),
				Type = Menum.AreaType.Rectangle,
				IsParent = true,
				ChildAreas = childAreas
			},
			{
				Center = Vector2.new(-1834.05, 480),
				Radius = Vector2.new(240, 175),
				Type = Menum.AreaType.Rectangle,
				YLimits = Vector2.new(-40, 160),
				IsParent = true,
				ChildAreas = childAreas
			}
		}
	},
	Situations = {
		{
			Name = "Safezone",
			SecondaryName = "Final Selection",
			Center = Vector2.new(-2625.25, -78),
			Size = Vector2.new(184, 299)
		}
	},
	Npcs = {}
}
local AreaContentLoader = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaContentLoader"))
FinalSelectionPlains.Npcs = AreaContentLoader.loadNpcs(script, FinalSelectionPlains.Area)
local npcContents = script:FindFirstChild("NpcContents")
local dialogues = npcContents and npcContents:FindFirstChild("Dialogues")

if dialogues then
	FinalSelectionPlains.Dialogues = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Yap"))
	FinalSelectionPlains.DialogueFunctions = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Functions"))
	FinalSelectionPlains.Quests = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Quests"))
end

return FinalSelectionPlains