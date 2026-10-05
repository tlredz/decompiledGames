local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local WindyPeak = {
	Area = {
		Village = true,
		Grid = {
			{
				IsParent = true,
				Center = Vector2.new(-670, -1138.5),
				Radius = Vector2.new(294, 284.5),
				Type = Menum.AreaType.Rectangle,
				ChildAreas = {
					["Raze's Sword Shop"] = {
						Grid = {
							{
								Center = Vector2.new(-564.403, -1085.535),
								Radius = Vector2.new(34.5, 45),
								Type = Menum.AreaType.Rectangle
							}
						}
					}
				}
			}
		}
	},
	CrystalAt = CFrame.new(
		-447.908508,
		1241.40466,
		-919.120117,
		1,
		-1.22464685e-16,
		1.22464685e-16,
		1.22464672e-16,
		1,
		7.54979013e-8,
		-1.22464698e-16,
		-7.54979013e-8,
		1
	),
	Spawns = { createVector(-456, 1241, -932), createVector(-452.532, 1240.993, -961.222) },
	Situations = {
		{
			Name = "Safezone",
			Center = Vector2.new(-515.5, -1146),
			Size = Vector2.new(931, 662)
		}
	},
	Shrines = {
		{
			Name = "Windy Peak Shrine",
			At = CFrame.new(
				-409.410339,
				1250.2373,
				-1311.96143,
				2.09681943e-8,
				0,
				-1,
				5.68881097e-13,
				1,
				0,
				1,
				5.68881097e-13,
				-2.09681943e-8
			)
		}
	},
	Npcs = {}
}
local AreaContentLoader = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaContentLoader"))
WindyPeak.Npcs = AreaContentLoader.loadNpcs(script, WindyPeak.Area)
local npcContents = script:FindFirstChild("NpcContents")
local dialogues = npcContents and npcContents:FindFirstChild("Dialogues")

if dialogues then
	WindyPeak.Dialogues = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Yap"))
	WindyPeak.DialogueFunctions = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Functions"))
	WindyPeak.Quests = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Quests"))
end

return WindyPeak