local v = {
	Gems = {
		Icon = "rbxassetid://131917706859525"
	},
	["Free Gems"] = {
		Icon = "rbxassetid://120456880139890"
	},
	["Paid Gems"] = {
		Icon = "rbxassetid://115808411787220"
	},
	Yen = {
		Icon = "rbxassetid://119876388556611"
	},
	Damage = {
		Icon = "rbxassetid://81941152561733"
	},
	["Player Damage"] = {
		Icon = "rbxassetid://81941152561733"
	},
	["Fighter Damage"] = {
		Icon = "rbxassetid://81941152561733"
	},
	Drops = {
		Icon = "rbxassetid://116055951228504"
	},
	["Player Exp"] = {
		Icon = "rbxassetid://71668811657109"
	},
	["Shiny Chance"] = {
		Icon = "rbxassetid://132919946904449"
	},
	Luck = {
		Icon = "rbxassetid://140709709110944"
	},
	["Gacha Luck"] = {
		Icon = "rbxassetid://84015917005972"
	},
	["Star Open"] = {
		NumericOnly = true,
		Icon = "rbxassetid://95235816548276"
	},
	["Gacha Roll"] = {
		NumericOnly = true,
		Icon = "rbxassetid://137122232830385"
	},
	["Fighter Equip"] = {
		NumericOnly = true,
		Icon = "rbxassetid://105113845366371"
	},
	["Attack Range"] = {
		NumericOnly = true,
		Icon = "rbxassetid://126282893757100"
	}
}

for k, v2 in v do
	v2.Name = k
	v2.Rarity = "Perk"
end

return table.freeze(v)