local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local ForgottenRuins = {
	Area = {
		Grid = {
			{
				Center = Vector2.new(-953.97, 945.479),
				Radius = Vector2.new(168.03, 357.479),
				Type = Menum.AreaType.Rectangle
			},
			{
				Center = Vector2.new(-589.847, 1026),
				Radius = Vector2.new(221.153, 254),
				Type = Menum.AreaType.Rectangle
			}
		}
	},
	Npcs = {}
}
local AreaContentLoader = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaContentLoader"))
ForgottenRuins.Npcs = AreaContentLoader.loadNpcs(script, ForgottenRuins.Area)
local npcContents = script:FindFirstChild("NpcContents")
local dialogues = npcContents and npcContents:FindFirstChild("Dialogues")

if dialogues then
	ForgottenRuins.Dialogues = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Yap"))
	ForgottenRuins.DialogueFunctions = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Functions"))
	ForgottenRuins.Quests = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Quests"))
end

return ForgottenRuins