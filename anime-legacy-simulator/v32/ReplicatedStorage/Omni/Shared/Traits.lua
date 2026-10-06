local Gacha = require(script.Parent.Gacha)
require(script.Parent.SoftPity)
local v = {
	Name = "Traits",
	MapName = "Lobby",
	Icon = "rbxassetid://91892931737865",
	Cooldown = 2,
	HistoryLimit = 50,
	Price = {
		Type = "Item",
		Name = "Trait Shard",
		Amount = 10
	},
	Products = {
		{
			Type = "Item",
			Name = "Trait Shard",
			Amount = 10,
			Price = 200,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Trait Shard",
			Amount = 35,
			Price = 500,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Trait Shard",
			Amount = 125,
			Price = 1250,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Trait Shard",
			Amount = 400,
			Price = 2500,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Trait Shard",
			Amount = 1250,
			Price = 6000,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Trait Shard",
			Amount = 3500,
			Price = 12500,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Trait Shard",
			Amount = 9000,
			Price = 25000,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Trait Shard",
			Amount = 25000,
			Price = 50000,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Trait Shard",
			Amount = 65000,
			Price = 100000,
			Enabled = true
		}
	},
	SoftPity = {},
	List = {
		["Genius I"] = {
			Rarity = "Common",
			Chance = 8.875,
			Icon = "rbxassetid://123903597451023",
			Attributes = {
				["Exp Gain"] = {
					Type = "Multi",
					Amount = 1.1
				}
			},
			Perks = {}
		},
		["Rich I"] = {
			Rarity = "Common",
			Chance = 8.6,
			Icon = "rbxassetid://87366667507647",
			Attributes = {},
			Perks = {
				Yen = {
					Type = "Multi",
					Amount = 1.1
				}
			}
		},
		["Strong I"] = {
			Rarity = "Common",
			Chance = 8.35,
			Icon = "rbxassetid://78643710107948",
			Attributes = {
				Damage = {
					Type = "Multi",
					Amount = 1.1
				}
			},
			Perks = {}
		},
		["Lucky I"] = {
			Rarity = "Common",
			Chance = 8.15,
			Icon = "rbxassetid://119073171529061",
			Attributes = {},
			Perks = {
				Luck = {
					Type = "Add",
					Amount = 0.05
				}
			}
		},
		["Genius II"] = {
			Rarity = "Uncommon",
			Chance = 7.225,
			Icon = "rbxassetid://123903597451023",
			Attributes = {
				["Exp Gain"] = {
					Type = "Multi",
					Amount = 1.175
				}
			},
			Perks = {}
		},
		["Rich II"] = {
			Rarity = "Uncommon",
			Chance = 7.025,
			Icon = "rbxassetid://87366667507647",
			Attributes = {},
			Perks = {
				Yen = {
					Type = "Multi",
					Amount = 1.175
				}
			}
		},
		["Strong II"] = {
			Rarity = "Uncommon",
			Chance = 6.775,
			Icon = "rbxassetid://78643710107948",
			Attributes = {
				Damage = {
					Type = "Multi",
					Amount = 1.175
				}
			},
			Perks = {}
		},
		["Sorcerer I"] = {
			Rarity = "Uncommon",
			Chance = 6.575,
			Icon = "rbxassetid://113810570558401",
			Attributes = {
				["Ultimate Damage"] = {
					Type = "Multi",
					Amount = 1.15
				}
			},
			Perks = {}
		},
		["Genius III"] = {
			Rarity = "Rare",
			Chance = 5.75,
			Icon = "rbxassetid://123903597451023",
			Attributes = {
				["Exp Gain"] = {
					Type = "Multi",
					Amount = 1.25
				}
			},
			Perks = {}
		},
		["Rich III"] = {
			Rarity = "Rare",
			Chance = 5.6,
			Icon = "rbxassetid://87366667507647",
			Attributes = {},
			Perks = {
				Yen = {
					Type = "Multi",
					Amount = 1.25
				}
			}
		},
		["Strong III"] = {
			Rarity = "Rare",
			Chance = 5.4,
			Icon = "rbxassetid://78643710107948",
			Attributes = {
				Damage = {
					Type = "Multi",
					Amount = 1.25
				}
			},
			Perks = {}
		},
		["Sorcerer II"] = {
			Rarity = "Rare",
			Chance = 5.25,
			Icon = "rbxassetid://113810570558401",
			Attributes = {
				["Ultimate Damage"] = {
					Type = "Multi",
					Amount = 1.25
				}
			},
			Perks = {}
		},
		["Lucky II"] = {
			Rarity = "Epic",
			Chance = 3.2,
			Icon = "rbxassetid://119073171529061",
			Attributes = {},
			Perks = {
				Luck = {
					Type = "Add",
					Amount = 0.125
				}
			}
		},
		["Sorcerer III"] = {
			Rarity = "Epic",
			Chance = 3.05,
			Icon = "rbxassetid://113810570558401",
			Attributes = {
				["Ultimate Damage"] = {
					Type = "Multi",
					Amount = 1.35
				}
			},
			Perks = {}
		},
		Tank = {
			Rarity = "Epic",
			Chance = 2.9,
			Icon = "rbxassetid://123750597424780",
			Attributes = {
				Damage = {
					Type = "Multi",
					Amount = 1.5
				},
				["Movement Speed"] = {
					Type = "Multi",
					Amount = 0.7
				}
			},
			Perks = {}
		},
		Speedy = {
			Rarity = "Epic",
			Chance = 2.75,
			Icon = "rbxassetid://87368942294224",
			Attributes = {
				["Movement Speed"] = {
					Type = "Multi",
					Amount = 1.25
				}
			},
			Perks = {}
		},
		Giant = {
			Rarity = "Legendary",
			Chance = 1.25,
			Icon = "rbxassetid://119921789146572",
			Attributes = {
				["Fighter Size"] = {
					Type = "Multi",
					Amount = 1.5
				},
				Damage = {
					Type = "Multi",
					Amount = 2
				},
				["Movement Speed"] = {
					Type = "Multi",
					Amount = 0.6
				},
				["Attack Speed"] = {
					Type = "Multi",
					Amount = 0.8
				}
			},
			Perks = {}
		},
		Tiny = {
			Rarity = "Legendary",
			Chance = 1.1,
			Icon = "rbxassetid://79060387820238",
			Attributes = {
				["Fighter Size"] = {
					Type = "Multi",
					Amount = 0.5
				},
				Damage = {
					Type = "Multi",
					Amount = 1.6
				},
				["Movement Speed"] = {
					Type = "Multi",
					Amount = 1.4
				},
				["Attack Speed"] = {
					Type = "Multi",
					Amount = 1.3
				}
			},
			Perks = {}
		},
		Collector = {
			Rarity = "Legendary",
			Chance = 0.95,
			Icon = "rbxassetid://94976845477100",
			Attributes = {},
			Perks = {
				Drops = {
					Type = "Add",
					Amount = 0.05
				}
			}
		},
		["Lucky III"] = {
			Rarity = "Legendary",
			Chance = 0.8,
			Icon = "rbxassetid://119073171529061",
			Attributes = {},
			Perks = {
				Luck = {
					Type = "Add",
					Amount = 0.2
				}
			}
		},
		Prodigy = {
			Rarity = "Mythical",
			Chance = 0.2,
			Pity = 750,
			Icon = "rbxassetid://128800840211163",
			Attributes = {
				["Exp Gain"] = {
					Type = "Multi",
					Amount = 2
				}
			},
			Perks = {}
		},
		Leprechaun = {
			Rarity = "Mythical",
			Chance = 0.1,
			Pity = 1500,
			Icon = "rbxassetid://136562813553180",
			Attributes = {},
			Perks = {
				Luck = {
					Type = "Add",
					Amount = 0.4
				},
				Yen = {
					Type = "Multi",
					Amount = 2
				}
			}
		},
		Mercenary = {
			Rarity = "Mythical",
			Chance = 0.075,
			Pity = 2000,
			Icon = "rbxassetid://140528689398028",
			Attributes = {
				Damage = {
					Type = "Multi",
					Amount = 2
				},
				["Ultimate Damage"] = {
					Type = "Multi",
					Amount = 1.5
				},
				["Boss Damage"] = {
					Type = "Multi",
					Amount = 1.25
				}
			},
			Perks = {
				Drops = {
					Type = "Add",
					Amount = 0.04
				}
			}
		},
		Blessing = {
			Rarity = "Mythical",
			Chance = 0.05,
			Pity = 3000,
			Icon = "rbxassetid://85317882953126",
			Attributes = {
				Damage = {
					Type = "Multi",
					Amount = 3.5
				},
				["Movement Speed"] = {
					Type = "Multi",
					Amount = 1.3
				},
				["Attack Speed"] = {
					Type = "Multi",
					Amount = 1.2
				}
			},
			Perks = {
				Luck = {
					Type = "Add",
					Amount = 0.25
				}
			}
		}
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsCounter(value)
	return typeof(value) == "number" and value >= 0 and value <= 9007199254740991 and value % 1 == 0
end

for k, v2 in v.List do
	v2.Name = k
	v2.Icon = v2.Icon or "rbxassetid://81941152561733"
end

function v.GetPityPreview(p)
	if p ~= nil and (typeof(p) ~= "table" or getmetatable(p) ~= nil) then
		return nil, "Trait pity requires a table of counters."
	end

	local currentState = {}
	local nextState = {}
	local v4 = -1
	local v5 = nil

	for k, v6 in v.List do
		local pity = v6.Pity

		if pity == nil then
			continue
		end

		if v6.Rarity ~= "Mythical" then
			return nil, "Trait pity requires an available Mythical Trait and a positive integer limit."
		end

		local v7

		if typeof(pity) == "number" and pity >= 0 and pity <= 9007199254740991 then
			v7 = pity % 1 == 0
		else
			v7 = false
		end

		if not (v7 and pity ~= 0 and not (v6.Chance <= 0)) then
			return nil, "Trait pity requires an available Mythical Trait and a positive integer limit."
		end

		local v8 = (not p or p[k] == nil) and 0 or p[k]
		local v9

		if typeof(v8) == "number" and v8 >= 0 and v8 <= 9007199254740991 then
			v9 = v8 % 1 == 0
		else
			v9 = false
		end

		if not v9 then
			return nil, "Trait pity counts must be nonnegative integers."
		end

		currentState[k] = v8
		nextState[k] = math.min(v8 + 1, 9007199254740991)
		local v10 = nextState[k] - pity

		if v10 >= 0 and (v4 < v10 or v10 == v4 and (not v5 or k < v5)) then
			v5 = k
			v4 = v10
		end

		continue
	end

	return {
		Enabled = next(nextState) ~= nil,
		Result = v5,
		CurrentState = currentState,
		NextState = nextState
	}
end

function v.GetNextPityState(p, p2: string)
	local clone = table.clone(p.NextState)

	if clone[p2] ~= nil then
		clone[p2] = 0
	end

	return clone
end

function v.GetPreview(p: number, p2, p3)
	local v2 = {
		Source = {
			Type = "Normal",
			Normal = v.List
		},
		Pity = {},
		SoftPity = v.SoftPity
	}
	local normalPreview, v3 = Gacha.GetNormalPreview(v2, p, nil, p3)

	if not normalPreview then
		return nil, v3
	end

	local pityPreview, v4 = v.GetPityPreview(p2)

	if not pityPreview then
		return nil, v4
	end

	if pityPreview.Result then
		for k, chance in normalPreview.Chances do
			chance.Chance = k == pityPreview.Result and 100 or 0
		end
	end

	return {
		GachaLuck = normalPreview.GachaLuck,
		Chances = normalPreview.Chances,
		SoftPity = normalPreview.SoftPity,
		Pity = pityPreview
	}
end

function v.Get(p)
	local trait = p and p.Trait

	if typeof(trait) == "table" then
		trait = trait.Current or trait
	end

	return typeof(trait) == "string" and v.List[trait] or nil
end

function v:NormalizeData()
	if typeof(self.Traits) ~= "table" then
		self.Traits = {}
	end

	local pity = self.Traits.Pity
	local pity3 = {}

	for k, v3 in v.List do
		if v3.Rarity ~= "Mythical" then
			continue
		end

		local pity2 = v3.Pity
		local v4

		if typeof(pity2) == "number" and pity2 >= 0 and pity2 <= 9007199254740991 then
			v4 = pity2 % 1 == 0
		else
			v4 = false
		end

		if not (v4 and v3.Pity ~= 0) then
			continue
		end

		local v5

		if typeof(pity) == "table" then
			v5 = pity[k]
		else
			v5 = false
		end

		pity3[k] = not IsCounter(v5) and 0 or v5
	end

	self.Traits.Pity = pity3
	local list = self.Fighters and self.Fighters.List

	if typeof(list) == "table" then
		for _, v3 in list do
			if typeof(v3) ~= "table" then
				continue
			end

			local trait = v3.Trait
			local current

			if typeof(trait) == "table" then
				current = trait.Current or trait
			else
				current = trait
			end

			if typeof(current) ~= "string" or v.List[current] then
				continue
			end

			if typeof(trait) == "table" then
				trait.Current = nil
			else
				v3.Trait = {
					History = {}
				}
			end
		end
	end

	local autoStop = self.Traits and self.Traits.AutoStop

	if typeof(autoStop) ~= "table" then
		return
	end

	for k in autoStop do
		if not v.List[k] then
			autoStop[k] = nil
		end
	end
end

function v.ApplyAttribute(p, p2: string, p3: number)
	local v2 = v.Get(p)
	local v3 = v2 and v2.Attributes[p2]

	if not v3 then
		return p3
	end

	if v3.Type == "Add" then
		return p3 + v3.Amount
	end

	return p3 * v3.Amount
end

function v.WithTrait(p, p2: string?, p3: number?)
	local history = {}
	local trait = p.Trait

	if typeof(trait) == "table" and typeof(trait.History) == "table" then
		for _, v3 in trait.History do
			if not (typeof(v3) == "table" and typeof(v3.Name) == "string" and typeof(v3.ObtainedAt) == "number") then
				continue
			end

			table.insert(history, {
				Name = v3.Name,
				ObtainedAt = v3.ObtainedAt
			})
		end
	end

	if p2 then
		assert(v.List[p2], "Unknown Trait")
		table.insert(history, {
			Name = p2,
			ObtainedAt = p3 or os.time()
		})
	end

	while #history > v.HistoryLimit do
		table.remove(history, 1)
	end

	return {
		Current = p2,
		History = history
	}
end

return table.freeze(v)