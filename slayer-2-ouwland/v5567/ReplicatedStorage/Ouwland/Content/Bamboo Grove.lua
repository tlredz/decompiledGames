local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local childAreas = {
	["Bamboo Grove Sanctuary"] = {
		Grid = {
			{
				Center = Vector2.new(635.273, -388.303),
				Radius = Vector2.new(417.878, 452.769),
				Type = Menum.AreaType.Rectangle
			},
			{
				Center = Vector2.new(767.618, 151.514),
				Radius = Vector2.new(285.179, 103.514),
				Type = Menum.AreaType.Rectangle
			}
		},
		CrystalAt = CFrame.new(627.065, 1020, -194.484, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		Spawns = { createVector(620.506, 1017, -199.069), createVector(621.174, 1017, -190.334) }
	}
}
local BambooGrove = {
	Area = {
		Grid = {
			{
				Center = Vector2.new(442.676, -677.636),
				Radius = Vector2.new(613.176, 743.015),
				Type = Menum.AreaType.Rectangle,
				IsParent = true,
				ChildAreas = childAreas
			},
			{
				Center = Vector2.new(768.071, 141.377),
				Radius = Vector2.new(287.929, 114.623),
				Type = Menum.AreaType.Rectangle,
				IsParent = true,
				ChildAreas = childAreas
			}
		}
	},
	CrystalAt = CFrame.new(
		367.688965,
		1129.47925,
		-941.085938,
		1.22464698e-16,
		7.54979013e-8,
		-1,
		1.22464672e-16,
		1,
		7.54979013e-8,
		1,
		-1.22464685e-16,
		1.22464685e-16
	),
	Spawns = { createVector(422, 1128, -915), createVector(423, 1128, -892) },
	Npcs = {}
}
local AreaContentLoader = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaContentLoader"))
BambooGrove.Npcs = AreaContentLoader.loadNpcs(script, BambooGrove.Area)
local npcContents = script:FindFirstChild("NpcContents")
local dialogues = npcContents and npcContents:FindFirstChild("Dialogues")

if dialogues then
	BambooGrove.Dialogues = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Yap"))
	BambooGrove.DialogueFunctions = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Functions"))
	BambooGrove.Quests = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Quests"))
end

return BambooGrove