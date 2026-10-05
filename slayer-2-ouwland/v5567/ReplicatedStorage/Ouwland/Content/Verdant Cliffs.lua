local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local VerdantCliffs = {
	Area = {
		Grid = {
			{
				Center = Vector2.new(1774.963, -425.009),
				Radius = Vector2.new(363.305, 656),
				Type = Menum.AreaType.Rectangle,
				YLimits = Vector2.new(1095, 1733)
			}
		}
	},
	Npcs = {}
}
local AreaContentLoader = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaContentLoader"))
VerdantCliffs.Npcs = AreaContentLoader.loadNpcs(script, VerdantCliffs.Area)
local npcContents = script:FindFirstChild("NpcContents")
local dialogues = npcContents and npcContents:FindFirstChild("Dialogues")

if dialogues then
	VerdantCliffs.Dialogues = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Yap"))
	VerdantCliffs.DialogueFunctions = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Functions"))
	VerdantCliffs.Quests = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Quests"))
end

return VerdantCliffs