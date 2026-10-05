local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local StoneSanctuary = {
	Area = {
		Grid = {
			{
				Center = Vector2.new(2564.096, -590.007),
				Radius = Vector2.new(348.101, 455.86),
				Type = Menum.AreaType.Rectangle
			}
		}
	},
	Npcs = {}
}
local AreaContentLoader = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaContentLoader"))
StoneSanctuary.Npcs = AreaContentLoader.loadNpcs(script, StoneSanctuary.Area)
local npcContents = script:FindFirstChild("NpcContents")
local dialogues = npcContents and npcContents:FindFirstChild("Dialogues")

if dialogues then
	StoneSanctuary.Dialogues = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Yap"))
	StoneSanctuary.DialogueFunctions = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Functions"))
	StoneSanctuary.Quests = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Quests"))
end

return StoneSanctuary