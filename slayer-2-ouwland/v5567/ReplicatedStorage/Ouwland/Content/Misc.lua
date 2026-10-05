local MuzanSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("MuzanSettings"))
local Misc = {
	Situations = { MuzanSettings.LairSituation },
	Npcs = {}
}
local AreaContentLoader = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaContentLoader"))
Misc.Npcs = AreaContentLoader.loadNpcs(script)
local npcContents = script:FindFirstChild("NpcContents")
local dialogues = npcContents and npcContents:FindFirstChild("Dialogues")

if dialogues then
	Misc.Dialogues = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Yap"))
	Misc.DialogueFunctions = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Functions"))
	Misc.Quests = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Quests"))
end

return Misc