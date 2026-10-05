local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
local FightingStyles, v, v2 = require(game.ReplicatedStorage.CAM.Global.Powers.FightingStyles)
local powersFightingStyle = {}

for k in FightingStyles, v, v2 do
	table.insert(powersFightingStyle, k)
end

return {
	Icon = "rbxassetid://17802518394",
	Description = "A persistent fist form that carries any learned fighting style, keeping its place as teachers and forms change.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Toolbar,
	HasCombat = true,
	CombatPreset = "Combat",
	DemonArt = "Shockwave",
	Mastery = "Fist",
	ActiveToolStats = {
		["Additional Damage"] = 3,
		["Additional Damage Factor"] = 0.05,
		["Block Points"] = 3
	},
	Unique = true,
	NoDelete = true,
	Requirements = {
		["Powers.FightingStyle"] = powersFightingStyle
	},
	AutoGrant = true,
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		}
	}
}