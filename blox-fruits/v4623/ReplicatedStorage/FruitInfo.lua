local Result = require(game.ReplicatedStorage.Packages.Result)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(game.ReplicatedStorage.BuildUtil)
require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local v = {
	Premium = {
		Value = 5,
		Name = "Premium"
	},
	Mythical = {
		Value = 4,
		Name = "Mythical"
	},
	Legendary = {
		Value = 3,
		Name = "Legendary"
	},
	Rare = {
		Value = 2,
		Name = "Rare"
	},
	Uncommon = {
		Value = 1,
		Name = "Uncommon"
	},
	Common = {
		Value = 0,
		Name = "Common"
	}
}
local DragonNames = require(game.ReplicatedStorage.Modules.Asset.DragonNames)
local v2 = {
	["Rocket-Rocket"] = {
		Rarity = v.Common,
		Description = "Grants explosive movement abilities, allowing quick travel and attacks."
	},
	["Spin-Spin"] = {
		Rarity = v.Common,
		Description = "Provides spinning attacks which will injure enemies with razor sharp wind slashes."
	},
	["Blade-Blade"] = {
		Rarity = v.Common,
		Description = "Grants the user a body of blades, offering immunity to sword attacks and sharp striking abilities.",
		Elements = {
			Elemental = {
				Text = "Immune to sword attacks"
			},
			M1 = {}
		}
	},
	["Spring-Spring"] = {
		Rarity = v.Common,
		Description = "Offers spring-like movement and bouncing attacks."
	},
	["Bomb-Bomb"] = {
		Rarity = v.Common,
		Description = "Provides the user with a wide range of explosive attacks.",
		Elements = {
			M1 = {}
		}
	},
	["Smoke-Smoke"] = {
		Rarity = v.Common,
		Description = "Offers the user an arsenal of smoke attacks, and is useful for grinding as a new player.",
		Elements = {
			Elemental = {}
		}
	},
	["Spike-Spike"] = {
		Rarity = v.Common,
		Description = "Grants the user sharp spikes on their body, full of offensive attacks skills."
	},
	["Flame-Flame"] = {
		Rarity = v.Uncommon,
		Description = "Enables the user to control and create fire, forcing enemies to steer clear if you don't want to burn.",
		Elements = {
			Elemental = {},
			Awakening = {}
		}
	},
	["Eagle-Eagle"] = {
		Rarity = v.Uncommon,
		Description = "Gives the user wings, and bird-like attacks."
	},
	["Ice-Ice"] = {
		Rarity = v.Uncommon,
		Description = "Allows the user to manipulate ice, freezing their foes in place.",
		Elements = {
			M1 = {},
			Elemental = {},
			Awakening = {}
		}
	},
	["Sand-Sand"] = {
		Rarity = v.Uncommon,
		Description = "Grants control over sand, with abilities to trap and attack.",
		Elements = {
			Elemental = {},
			Awakening = {}
		}
	},
	["Dark-Dark"] = {
		Rarity = v.Uncommon,
		Description = "Provides darkness-based abilities which pull enemies in closer to you.",
		Elements = {
			Elemental = {},
			Awakening = {}
		}
	},
	["Diamond-Diamond"] = {
		Rarity = v.Uncommon,
		Description = "Turns the user into diamond, enhancing defense and providing sharp attacks.",
		Elements = {
			M1 = {}
		}
	},
	["Light-Light"] = {
		Rarity = v.Rare,
		Description = "Grants light-speed movement and powerful light-based attacks.",
		Elements = {
			Elemental = {},
			M1 = {},
			Awakening = {}
		}
	},
	["Rubber-Rubber"] = {
		Rarity = v.Rare,
		Description = "Grants the user a rubber body, immune to electric attacks and stretchy enough to deal a barrage of offensive attacks.",
		Elements = {
			M1 = {}
		}
	},
	["Creation-Creation"] = {
		Rarity = v.Legendary,
		Description = " Creates barriers for defense and can trap enemies."
	},
	["Ghost-Ghost"] = {
		Rarity = v.Rare,
		Description = "Allows the user to transcend the barrier between life and death, granting an extra life and paranormal abilities."
	},
	["Magma-Magma"] = {
		Rarity = v.Rare,
		Description = "Grants magma-based attacks that deal high damage and burn enemies.",
		Elements = {
			Elemental = {},
			Awakening = {}
		}
	},
	["Quake-Quake"] = {
		Rarity = v.Legendary,
		Description = "Provides the ability to create shockwaves, dealing massive area damage.",
		Elements = {
			Awakening = {}
		}
	},
	["Buddha-Buddha"] = {
		Rarity = v.Legendary,
		Description = "Transforms the user into a giant Buddha, increasing the users size, power, and defense, making it perfect for farming.",
		Elements = {
			Transformation = {},
			Awakening = {},
			M1 = {}
		}
	},
	["Love-Love"] = {
		Rarity = v.Legendary,
		Description = "Use charming abilities to debuff enemies, and to summon your Besto Friendo."
	},
	["Spider-Spider"] = {
		Rarity = v.Legendary,
		Description = "Grants spider-like abilities, including web attacks and agility.",
		Elements = {
			Awakening = {}
		}
	},
	["Sound-Sound"] = {
		Rarity = v.Legendary,
		Description = "Use instrument based attacks, or ride along sheets of music to power-up this Fruit. "
	},
	["Phoenix-Phoenix"] = {
		Rarity = v.Legendary,
		Description = "Grants regenerative abilities, powerful fire-based attacks, and the ability to transform into full body Phoenix.",
		Elements = {
			Transformation = {},
			Awakening = {},
			M1 = {
				Text = "Can M1 awakened"
			}
		}
	},
	["Portal-Portal"] = {
		Rarity = v.Legendary,
		Description = "Allows the user to instantly travel to any location, or create a portal to a dimension of their own.",
		Elements = {
			M1 = {}
		}
	},
	["Pain-Pain"] = {
		Rarity = v.Legendary,
		Description = "Inflicts pain-based attacks, causing damage over time.",
		Elements = {
			M1 = {}
		}
	},
	["Blizzard-Blizzard"] = {
		Rarity = v.Legendary,
		Description = "Grants control over powerful ice storms, which can be used to blind your enemies. ",
		Elements = {
			Elemental = {}
		}
	},
	["Gravity-Gravity"] = {
		Rarity = v.Mythical,
		Description = "Allows the user to manipulate gravity, controlling the battlefield.",
		Elements = {
			M1 = {}
		}
	},
	["Mammoth-Mammoth"] = {
		Rarity = v.Mythical,
		Description = "Transforms the user into a mammoth, providing strength and size.",
		Elements = {
			Transformation = {},
			M1 = {
				Text = "Can M1 transformed"
			}
		}
	},
	["T-Rex-T-Rex"] = {
		Rarity = v.Mythical,
		Description = "Transforms the user into a T-Rex, granting powerful close-range attacks.",
		Elements = {
			Transformation = {},
			M1 = {}
		}
	},
	["Dough-Dough"] = {
		Rarity = v.Mythical,
		Description = "Provides sticky and flexible dough-based attacks.",
		Elements = {
			Awakening = {},
			Elemental = {},
			M1 = {
				Text = "Can M1 awakened"
			}
		}
	},
	["Lightning-Lightning"] = {
		Rarity = v.Legendary,
		Description = "Provides electric-based attacks, which have stun based effects.",
		Elements = {
			Elemental = {},
			M1 = {}
		}
	},
	["Shadow-Shadow"] = {
		Rarity = v.Mythical,
		Description = "Grants life-leeching abilities, useful for tactical takedowns of your enemies."
	},
	["Venom-Venom"] = {
		Rarity = v.Mythical,
		Description = "Transforms the user into a venomous hydra, granting the user poison-based attacks that damage over time.",
		Elements = {
			Transformation = {}
		}
	},
	["Control-Control"] = {
		Rarity = v.Mythical,
		Description = "Allows the user to control objects and enemies within a specified area."
	},
	["Gas-Gas"] = {
		Rarity = v.Mythical,
		Description = "Allows the user to exhale clouds of explosive gas and transform into a powerful gaseous knight.",
		Elements = {
			Transformation = {},
			M1 = {},
			Elemental = {}
		}
	},
	["Spirit-Spirit"] = {
		Rarity = v.Mythical,
		Description = "Grants the user the ability to manipulate spirits, which can offer the user heavenly buffs to themselves or disastrous traps to their enemies.",
		Elements = {
			M1 = {}
		}
	},
	["Yeti-Yeti"] = {
		Rarity = v.Mythical,
		Description = "Allows the user to turn into a hulking snow beast with cold attacks and ground-shaking strength.",
		Elements = {
			Transformation = {},
			M1 = {
				Text = "Can M1 transformed"
			}
		}
	},
	["Fiend (Yeti)-Fiend (Yeti)"] = {
		Rarity = v.Mythical,
		Description = "Allows the user to turn into a hulking snow beast with cold attacks and ground-shaking strength.",
		Elements = {
			Transformation = {},
			M1 = {
				Text = "Can M1 transformed"
			}
		}
	},
	["Tiger-Tiger"] = {
		Rarity = v.Mythical,
		Description = "Allows the user to turn into a tiger, granting enhanced agility and powerful melee attacks.",
		Elements = {
			Transformation = {},
			M1 = {
				Text = "Can M1 transformed"
			}
		}
	},
	["Werewolf (Tiger)-Werewolf (Tiger)"] = {
		Rarity = v.Mythical,
		Description = "Allows the user to turn into a werewolf, granting enhanced agility and powerful melee attacks.",
		Elements = {
			Transformation = {},
			M1 = {
				Text = "Can M1 transformed"
			}
		}
	},
	["Kitsune-Kitsune"] = {
		Rarity = v.Mythical,
		Description = "Grants fox-like abilities, with amazing agility and blue fire-based attacks. Damage enemies to fully transform into the mythical Kitsune.",
		Elements = {
			Transformation = {},
			M1 = {}
		}
	},
	["Empyrean (Kitsune)-Empyrean (Kitsune)"] = {
		Rarity = v.Mythical,
		Description = "Grants fox-like abilities, with amazing agility and blue fire-based attacks. Damage enemies to fully transform into the mythical Kitsune.",
		Elements = {
			Transformation = {},
			M1 = {}
		}
	},
	["Magnet-Magnet"] = {
		Rarity = v.Mythical,
		Description = "It's magnetic!",
		Elements = {
			Transformation = {},
			M1 = {}
		}
	},
	[DragonNames.Permanent] = {
		Rarity = v.Mythical,
		Description = "Transforms the user into a mighty dragon, allowing them to rule over the skies with scorching flames.",
		Elements = {
			Transformation = {},
			M1 = {}
		}
	}
}
local ELEMENTS = {
	M1 = {
		Images = {
			["845x845"] = "rbxassetid://18522363952",
			["34x34"] = "rbxassetid://110722339497487",
			["100x100"] = "rbxassetid://124422403020828"
		},
		Text = "Can M1"
	},
	Elemental = {
		Images = {
			["845x845"] = "rbxassetid://18522364171",
			["34x34"] = "rbxassetid://99096073700387",
			["100x100"] = "rbxassetid://116857012834974"
		},
		Text = "Immune to weak attacks"
	},
	Transformation = {
		Images = {
			["845x845"] = "rbxassetid://18522364352",
			["34x34"] = "rbxassetid://116255990226292",
			["100x100"] = "rbxassetid://85635919480021"
		},
		Text = "Can transform"
	},
	Awakening = {
		Images = {
			["845x845"] = "rbxassetid://18556567876",
			["34x34"] = "rbxassetid://138098911321101",
			["100x100"] = "rbxassetid://93842515161395"
		},
		Text = "Unlockable awakening"
	}
}
local DATA = {}

for k, v5 in pairs(v2) do
	local rarity = assert(v5.Rarity, "bad fruitInfo.Rarity")
	local v7 = v5
	local v8 = {
		Elements = {},
		Description = Result.map(ItemId.getId(k, "Moveset"), function(p: number)
			return Result.map(ItemConfig.match(p), function(p2)
				return p2.Display.Description or v7.Description
			end):unwrapOr(v7.Description)
		end):unwrapOr(v5.Description),
		Rarity = rarity
	}

	if v5.Elements then
		for k2, element in pairs(v5.Elements) do
			local v9 = assert(ELEMENTS[k2], (`Element has no ElementInfo {k2}`))
			local v10 = {
				Images = element.Images or v9.Images,
				Text = element.Text or v9.Text
			}
			v8.Elements[k2] = v10
		end
	end

	DATA[k] = v8
end

TableUtil.deepFreeze(DATA)
TableUtil.deepFreeze(ELEMENTS)

function get(permanent: string)
	if not DATA[permanent] and (permanent == DragonNames.West or permanent == DragonNames.East) then
		permanent = DragonNames.Permanent
	end

	assert(DATA[permanent], (`couldn't find fruitInfo at key "{permanent}"`))
	return DATA[permanent]
end

local FruitInfo = {
	DATA = DATA,
	ELEMENTS = ELEMENTS,
	getNames = function()
		local result = {}

		for k, _ in pairs(DATA) do
			table.insert(result, k)
		end

		return result
	end,
	get = function(p: string)
		return get(p)
	end,
	tryGet = function(p: string)
		local v5 = nil
		local _, _ = pcall(function()
			v5 = get(p)
		end)
		return v5
	end,
	match = function(p: string)
		return Result.try(function()
			return get(p)
		end)
	end
}
FruitInfo.List = FruitInfo.DATA
FruitInfo.Elements = FruitInfo.ELEMENTS

function FruitInfo.Get(_, p: string)
	return get(p)
end

function FruitInfo.TryGet(_, p: string)
	local v5 = nil
	local _, _ = pcall(function()
		v5 = get(p)
	end)
	return v5
end

return FruitInfo