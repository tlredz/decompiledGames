local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local childAreas = {
	["Iceveil Settlement"] = {
		Village = true,
		Grid = {
			{
				Center = Vector2.new(-320.215, -2903.84),
				Radius = Vector2.new(245.825, 727.88),
				Type = Menum.AreaType.Rectangle
			},
			{
				Center = Vector2.new(68.28, -2699.06),
				Radius = Vector2.new(393.28, 247.4),
				Type = Menum.AreaType.Rectangle
			}
		},
		CrystalAt = CFrame.new(-208.841, 1352.665, -2596.467, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		Spawns = {
			createVector(-192.6, 1348.982, -2598.405),
			createVector(-192.486, 1348.996, -2592.366),
			createVector(-203.824, 1348.805, -2580.919)
		},
		IndependentMarkers = true
	}
}
local IceveilValley = {
	Area = {
		Grid = {
			{
				Center = Vector2.new(683.81, -2443.45),
				Radius = Vector2.new(604.61, 1024),
				Type = Menum.AreaType.Rectangle,
				IsParent = true,
				ChildAreas = childAreas
			},
			{
				Center = Vector2.new(-695.535, -2811.93),
				Radius = Vector2.new(813.035, 661.04),
				Type = Menum.AreaType.Rectangle,
				IsParent = true,
				ChildAreas = childAreas
			},
			{
				Center = Vector2.new(267.8, -3722.355),
				Radius = Vector2.new(1024, 255.405),
				Type = Menum.AreaType.Rectangle,
				IsParent = true,
				ChildAreas = childAreas
			},
			{
				Center = Vector2.new(-1420.525, -4161.9),
				Radius = Vector2.new(670.385, 703.67),
				Type = Menum.AreaType.Rectangle,
				IsParent = true,
				ChildAreas = childAreas
			}
		}
	},
	Shrines = {
		{
			Name = "Frost Veil Shrine",
			Price = {
				Wen = 45000
			},
			At = CFrame.new(
				142.125137,
				1385.08752,
				-2783.1521,
				-0.331576884,
				-0.0178111345,
				0.943260193,
				-0.0249441415,
				0.999637902,
				0.0101072602,
				-0.943098426,
				-0.0201774891,
				-0.331900656
			)
		}
	},
	Npcs = {}
}
local AreaContentLoader = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaContentLoader"))
IceveilValley.Npcs = AreaContentLoader.loadNpcs(script, IceveilValley.Area)
local npcContents = script:FindFirstChild("NpcContents")
local dialogues = npcContents and npcContents:FindFirstChild("Dialogues")

if dialogues then
	IceveilValley.Dialogues = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Yap"))
	IceveilValley.DialogueFunctions = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Functions"))
	IceveilValley.Quests = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Quests"))
end

return IceveilValley