local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Shared.t.t)

local function inputMap(p, p2)
	return p.Name, p2
end

local function literalMap(p, p2)
	return v2.literal(p), p2
end

local mapped = v.List.map(Enum.KeyCode:GetEnumItems(), inputMap)
local mapped2 = v.List.map(Enum.UserInputType:GetEnumItems(), inputMap)
local joined = v.List.concat(
	v.List.map(Enum.KeyCode:GetEnumItems(), inputMap),
	v.List.map(Enum.UserInputType:GetEnumItems(), inputMap)
)
v2.union(table.unpack(v.List.map(mapped, literalMap)))
v2.union(table.unpack(v.List.map(mapped2, literalMap)))
local union = v2.union(table.unpack(v.List.map(joined, literalMap)))
local strictInterface = v2.strictInterface({
	X = v2.number,
	Y = v2.number
})
local SettingsInfo = {
	Volume = {
		LayoutOrder = 0,
		Music = {
			Validate = v2.numberConstrained(0, 100),
			Current = 50,
			Default = 50,
			Max = 100,
			LayoutOrder = 1
		},
		SFX = {
			Validate = v2.numberConstrained(0, 100),
			Current = 50,
			Default = 50,
			Max = 100,
			LayoutOrder = 2
		}
	},
	Keybinds = {
		LayoutOrder = 100,
		Block = {
			Validate = union,
			Default = {
				PC = "F",
				Console = "ButtonR1"
			},
			PC = {
				Bind1 = "F",
				Bind2 = "MouseButton1",
				Bind3 = ""
			},
			Console = {
				Bind1 = "ButtonR1",
				Bind2 = "",
				Bind3 = ""
			},
			LayoutOrder = 101
		},
		Ability = {
			Validate = union,
			Default = {
				PC = "Q",
				Console = "ButtonX"
			},
			PC = {
				Bind1 = "",
				Bind2 = ""
			},
			Console = {
				Bind1 = "",
				Bind2 = ""
			},
			Elemental = false,
			LayoutOrder = 102
		},
		Emote = {
			Validate = union,
			Default = {
				PC = "R",
				Console = "ButtonL1"
			},
			PC = {
				Bind1 = "R",
				Bind2 = ""
			},
			Console = {
				Bind1 = "ButtonL1",
				Bind2 = ""
			},
			LayoutOrder = 106
		}
	},
	Accessibility = {
		LayoutOrder = 200,
		["Highlight Color"] = {
			Validate = v2.optional(v2.Color3),
			Type = "Color",
			Default = 16711680,
			LayoutOrder = 201
		}
	},
	Misc = {
		LayoutOrder = 300,
		["Weapon VFX"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = true,
			BlockedBy = "Low Graphics",
			LayoutOrder = 301
		},
		["Explosion VFX"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = true,
			BlockedBy = "Low Graphics",
			LayoutOrder = 302
		},
		["Highlight Players"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 303
		},
		["Remove Swords SFX"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 304
		},
		["Hide Serial Label"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 304
		},
		["Hide Exist Count Label"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 304
		},
		["Remove Emotes SFX"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 305
		},
		["Remove Explosions SFX"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 305
		},
		["Low Graphics"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 306
		},
		["Duel Requests"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = true,
			LayoutOrder = 307
		},
		["Shift Lock on Match"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = true,
			LayoutOrder = 308
		},
		["Hide UI During Match"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 308
		},
		["Cinematic Emote Camera"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = true,
			LayoutOrder = 309
		},
		["Max Zoom"] = {
			Validate = v2.numberConstrained(0, 5),
			Current = 2,
			Default = 2,
			Max = 5,
			LayoutOrder = 310
		},
		["Country Flag"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = true,
			LayoutOrder = 311,
			DoNotDisplay = false
		},
		["Tap Screen To Block"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = true,
			LayoutOrder = 312
		},
		["VR Parry Sensitivity"] = {
			Validate = v2.numberConstrained(0, 100),
			Current = 50,
			Default = 50,
			Max = 100,
			LayoutOrder = 313
		},
		["VR Hand Switch Sensitivity"] = {
			Validate = v2.numberConstrained(0, 100),
			Current = 50,
			Default = 50,
			Max = 100,
			LayoutOrder = 314
		},
		["Clan Joins"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = true,
			LayoutOrder = 315
		},
		["Hide Clan Tag in Chat"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 316
		},
		["Lag-Ball"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 317,
			Tooltip = "Higher values lower visual update frequency for clearer trajectory changes."
		},
		["Gray Sky"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 318,
			Tooltip = "Remove the default sky."
		},
		["Time Of Day"] = {
			TemplateType = "TimeOfDay",
			Validate = v2.optional(v2.boolean),
			Current = 66,
			Default = 66,
			Enabled = false,
			BlockedBy = "Gray Sky",
			LayoutOrder = 319
		},
		FOV = {
			TemplateType = "Slider",
			Validate = v2.numberConstrained(0, 100),
			Current = 50,
			Default = 50,
			Max = 100,
			LayoutOrder = 321
		},
		["Show Ping"] = {
			Validate = v2.optional(v2.boolean),
			Enabled = false,
			LayoutOrder = 322,
			Tooltip = "Display ping on your HUD."
		},
		["Server Region"] = {
			LayoutOrder = 331
		},
		["Server Version"] = {
			LayoutOrder = 332
		},
		Ability1MobileButtonPosition = {
			Validate = strictInterface,
			Current = {
				X = 0.778,
				Y = 0.879
			},
			Default = {
				X = 0.778,
				Y = 0.879
			},
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability2MobileButtonPosition = {
			Validate = strictInterface,
			Current = {
				X = 0.778,
				Y = 0.72
			},
			Default = {
				X = 0.778,
				Y = 0.72
			},
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability3MobileButtonPosition = {
			Validate = strictInterface,
			Current = {
				X = 0.859,
				Y = 0.651
			},
			Default = {
				X = 0.859,
				Y = 0.651
			},
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability4MobileButtonPosition = {
			Validate = strictInterface,
			Current = {
				X = 0.935,
				Y = 0.651
			},
			Default = {
				X = 0.935,
				Y = 0.651
			},
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability1TabletButtonPosition = {
			Validate = strictInterface,
			Current = {
				X = 0.718,
				Y = 0.87
			},
			Default = {
				X = 0.718,
				Y = 0.87
			},
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability2TabletButtonPosition = {
			Validate = strictInterface,
			Current = {
				X = 0.718,
				Y = 0.739
			},
			Default = {
				X = 0.718,
				Y = 0.739
			},
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability3TabletButtonPosition = {
			Validate = strictInterface,
			Current = {
				X = 0.815,
				Y = 0.641
			},
			Default = {
				X = 0.815,
				Y = 0.641
			},
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability4TabletButtonPosition = {
			Validate = strictInterface,
			Current = {
				X = 0.903,
				Y = 0.641
			},
			Default = {
				X = 0.903,
				Y = 0.641
			},
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		BlockButtonPosition = {
			Validate = strictInterface,
			Current = {
				X = 0.9,
				Y = 0.3
			},
			Default = {
				X = 0.9,
				Y = 0.3
			},
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		BlockButtonScale = {
			Validate = v2.number,
			Current = 1,
			Default = 1,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		AbilityButtonPosition = {
			Validate = strictInterface,
			Current = {
				X = 0.9,
				Y = 0.51
			},
			Default = {
				X = 0.9,
				Y = 0.51
			},
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability1MobileButtonScale = {
			Validate = v2.number,
			Current = 1,
			Default = 1,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability2MobileButtonScale = {
			Validate = v2.number,
			Current = 1,
			Default = 1,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability3MobileButtonScale = {
			Validate = v2.number,
			Current = 1,
			Default = 1,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability4MobileButtonScale = {
			Validate = v2.number,
			Current = 1,
			Default = 1,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability1TabletButtonScale = {
			Validate = v2.number,
			Current = 1,
			Default = 1,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability2TabletButtonScale = {
			Validate = v2.number,
			Current = 1,
			Default = 1,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability3TabletButtonScale = {
			Validate = v2.number,
			Current = 1,
			Default = 1,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		Ability4TabletButtonScale = {
			Validate = v2.number,
			Current = 1,
			Default = 1,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		AbilityButtonScale = {
			Validate = v2.number,
			Current = 1,
			Default = 1,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		SwordSkinsRandomizer = {
			ResetIgnore = true,
			Validate = v2.optional(v2.boolean),
			Current = false,
			Default = false,
			UseFavorites = false,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		ExplosionSkinsRandomizer = {
			ResetIgnore = true,
			Validate = v2.optional(v2.boolean),
			Current = false,
			Default = false,
			UseFavorites = false,
			LayoutOrder = 0,
			DoNotDisplay = true
		},
		AbilitiesRandomizer = {
			ResetIgnore = true,
			Validate = v2.optional(v2.boolean),
			Current = false,
			Default = false,
			UseFavorites = false,
			LayoutOrder = 0,
			DoNotDisplay = true
		}
	}
}
local v3 = {
	Volume = {
		Order = 0,
		List = { "Music", "SFX" }
	},
	Keybinds = {
		Order = 1,
		List = { "Block", "Ability", "Emote" }
	},
	Accessibility = {
		Order = 2,
		List = { "Highlight Color" }
	},
	Misc = {
		Order = 3,
		List = {
			"Weapon VFX",
			"Explosion VFX",
			"Night Mode",
			"Highlight Players",
			"Remove Swords SFX",
			"Remove Emotes SFX",
			"Remove Explosions SFX",
			"Hide Serial Label",
			"Hide Exist Count Label",
			"Low Graphics",
			"Duel Requests",
			"Shift Lock on Match",
			"Hide UI During Match",
			"Cinematic Emote Camera",
			"Max Zoom",
			"Country Flag",
			"Tap Screen To Block",
			"VR Parry Sensitivity",
			"VR Hand Switch Sensitivity",
			"Clan Joins",
			"Hide Clan Tag in Chat",
			"Lag-Ball",
			"Gray Sky",
			"FOV",
			"Server Region",
			"Server Version"
		}
	}
}

for k, v4 in SettingsInfo do
	local v5 = v3[k]

	if not v5 then
		continue
	end

	local list = v5.List
	local v6 = v5.Order * 100

	for k2, v7 in v4 do
		local index = table.find(list, k2)

		if index then
			v7.LayoutOrder = v6 + index
		end
	end
end

return SettingsInfo