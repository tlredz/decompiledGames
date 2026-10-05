local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local childAreas = {
	["Seasons Crossing"] = {
		Grid = {
			{
				Center = Vector2.new(-636.764, -25.16),
				Radius = Vector2.new(301.992, 259.716),
				Type = Menum.AreaType.Rectangle
			}
		},
		IndependentMarkers = true
	},
	["Dreamfall Hollow"] = {
		Cave = true,
		Grid = {
			{
				Center = Vector2.new(715.702, 787.728),
				Radius = Vector2.new(237.307, 337.597),
				Type = Menum.AreaType.Rectangle,
				YLimits = Vector2.new(788, 923)
			}
		},
		IndependentMarkers = true
	}
}
local MistfallHarbor = {
	Area = {
		Grid = {
			{
				Center = Vector2.new(-624, -37.697),
				Radius = Vector2.new(400, 285.607),
				Type = Menum.AreaType.Rectangle,
				IsParent = true,
				ChildAreas = childAreas
			},
			{
				Center = Vector2.new(126.655, 624.708),
				Radius = Vector2.new(353.345, 559.268),
				Type = Menum.AreaType.Rectangle,
				IsParent = true,
				ChildAreas = childAreas
			},
			{
				Center = Vector2.new(715.702, 787.728),
				Radius = Vector2.new(237.307, 337.597),
				Type = Menum.AreaType.Rectangle,
				YLimits = Vector2.new(788, 923),
				IsParent = true,
				ChildAreas = childAreas
			},
			{
				Center = Vector2.new(-497.081, 502.155),
				Radius = Vector2.new(280.325, 259.385),
				Type = Menum.AreaType.Rectangle,
				IsParent = true,
				ChildAreas = childAreas
			}
		}
	},
	CrystalAt = CFrame.new(136.539932, 873.900024, 733.369995, 0, 0, 1, 0, 1, 0, -1, 0, 0),
	Spawns = { createVector(140.73, 873.5, 728.215), createVector(144.165, 873.5, 735.097) },
	Shrines = {
		{
			Name = "Mistfall Harbor Shrine",
			Price = {
				Wen = 25000
			},
			At = CFrame.new(
				16.9635143,
				967.723755,
				372.266876,
				0.609892726,
				0.00074212387,
				-0.792484641,
				-0.00121682766,
				0.999999702,
				-4.74233142e-9,
				0.792484403,
				0.000964284874,
				0.609889209
			)
		}
	},
	Npcs = {}
}
local AreaContentLoader = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaContentLoader"))
MistfallHarbor.Npcs = AreaContentLoader.loadNpcs(script, MistfallHarbor.Area)
local npcContents = script:FindFirstChild("NpcContents")
local dialogues = npcContents and npcContents:FindFirstChild("Dialogues")

if dialogues then
	MistfallHarbor.Dialogues = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Yap"))
	MistfallHarbor.DialogueFunctions = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Functions"))
	MistfallHarbor.Quests = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Quests"))
end

return MistfallHarbor