local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local HiddenMistVillage = {
	Area = {
		Village = true,
		Grid = {
			{
				Center = Vector2.new(1801.21, -354.98),
				Radius = Vector2.new(302.88, 690.67),
				Type = Menum.AreaType.Rectangle,
				YLimits = Vector2.new(550, 845)
			}
		}
	},
	CrystalAt = CFrame.new(1640, 606.3, -125, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Spawns = { createVector(1651.024, 607.3, -124), createVector(1644, 605.796, -112) },
	Shrines = {
		{
			Name = "Hidden Mist Village Shrine",
			Price = {
				Wen = 35000
			},
			At = CFrame.new(
				1266.15491,
				980.876465,
				-482.316437,
				-0.536102057,
				-0.00247755041,
				-0.844153821,
				-0.019812597,
				0.999755621,
				0.0096482886,
				0.843923807,
				0.0218971502,
				-0.536020577
			)
		}
	},
	Npcs = {}
}
local AreaContentLoader = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaContentLoader"))

if script:FindFirstChild("Npcs") ~= nil then
	HiddenMistVillage.Npcs = AreaContentLoader.loadNpcs(script, HiddenMistVillage.Area)
end

local npcContents = script:FindFirstChild("NpcContents")
local dialogues = npcContents and npcContents:FindFirstChild("Dialogues")

if dialogues then
	HiddenMistVillage.Dialogues = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Yap"))
	HiddenMistVillage.DialogueFunctions = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Functions"))
	HiddenMistVillage.Quests = AreaContentLoader.mergeModules(dialogues:FindFirstChild("Quests"))
end

return HiddenMistVillage