local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
local ClanSkills = require(game.ReplicatedStorage.CAM:WaitForChild("Clans"):WaitForChild("ClanSkills"))
local clan = {}

for k in ClanSkills.SkillSets do
	table.insert(clan, k)
end

return {
	Icon = "rbxassetid://81394943526226",
	Description = "A bloodline tool that appears only for clans with techniques, drawing the right clan skills without needing a separate weapon.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Toolbar,
	HasCombat = true,
	CombatPreset = "Combat",
	Mastery = "Fist",
	Unique = true,
	NoDelete = true,
	Requirements = {
		Clan = clan
	},
	AutoGrant = true
}