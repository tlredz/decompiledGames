local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local ChanceWeightUtil = require(ReplicatedStorage.Util.ChanceWeightUtil)
local BuffCardConfigs = require(game.ReplicatedStorage.DungeonShared.BuffCardConfigs)
local rarities = {
	Uncommon = {
		Color = Color3.fromRGB(56, 194, 37),
		Weight = 5,
		Name = "Uncommon"
	},
	Rare = {
		Color = Color3.fromRGB(21, 117, 212),
		Weight = 4,
		Name = "Rare"
	},
	Epic = {
		Color = Color3.fromRGB(139, 46, 201),
		Weight = 2,
		Name = "Epic"
	},
	Legendary = {
		Color = Color3.fromRGB(255, 164, 28),
		Weight = 1,
		Name = "Legendary"
	},
	Mythic = {
		Color = Color3.fromRGB(255, 0, 0),
		Weight = 0,
		Name = "Challenge"
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function tryHighQualitySprite(p: string)
	return Spritesheets.MAP["HighQuality " .. p] or Spritesheets.MAP[p]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fmt(p: number, p2)
	if p2 and p2.NoColor then
		return string.format("%.0f%%", p * 100)
	end

	return (`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`)
end

local function yellow(p: number, value)
	return (`<font color="rgb(255, 215, 38)">{string.format("%.0f", p)}{value or ""}</font>`)
end

local function applyDiminishingReturns(p: number, p2: number)
	return p - (p * 0.5) ^ p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function colorText(p: number, main: Color3)
	return (`<font color="rgb({math.clamp(math.floor(main.R * 255), 0, 255)}, {math.clamp(math.floor(main.G * 255), 0, 255)}, {math.clamp(math.floor(main.B * 255), 0, 255)})">{p}</font>`)
end

local function fn(p: number)
	return string.format("%.0f%%", p * 100)
end

local function getEquippedTool(p: string, p2)
	local v2 = p2 or game.Players.LocalPlayer

	if not v2 then
		return nil
	end

	local character = v2.Character

	if character then
		local tool = character:FindFirstChildOfClass("Tool")

		if tool and tool.ToolTip == p then
			return tool
		end
	end

	for _, tool in v2.Backpack:GetChildren() do
		if tool:IsA("Tool") and tool.ToolTip == p then
			return tool
		end
	end

	return nil
end

local function toolHasSkill(equippedTool, p: string)
	local data = equippedTool:FindFirstChild("Data")
	local module

	if data and data:IsA("ModuleScript") then
		module = require(data)
	elseif RunService:IsServer() then
		local Movesets = require(game.ServerScriptService.Movesets)
		module = Movesets.getLegacyData(equippedTool.Name)
	end

	return module ~= nil and module.Lvl ~= nil and module.Lvl[p] ~= nil
end

local function getToolColor(equippedTool)
	if equippedTool.Name == "Gravity-Gravity" then
		return Color3.fromRGB(214, 184, 255)
	end

	if equippedTool.Name == "Dragon-Dragon" then
		return Color3.fromRGB(255, 183, 128)
	end

	if equippedTool.Name == "Gas-Gas" then
		return Color3.fromRGB(255, 150, 255)
	end

	if equippedTool.Name == "Kitsune-Kitsune" then
		return Color3.fromRGB(169, 189, 255)
	end

	return Color3.new(1, 1, 1)
end

local function getToolSpriteInfo(p: string)
	local v2 = p == "Fruit" and "Blox Fruit" or p
	local equippedTool = getEquippedTool(v2)

	if equippedTool then
		local v4 = tryHighQualitySprite(equippedTool.Name .. "1") -- equivalent call inferred; original call site unknown

		if v4 then
			local v5 = {
				Image = v4.Image,
				ImageRectOffset = v4.ImageRectOffset,
				ImageRectSize = v4.ImageRectSize,
				Color = getToolColor(equippedTool)
			}
			local v7 = tryHighQualitySprite(equippedTool.Name .. "2") -- equivalent call inferred; original call site unknown

			if v7 then
				v5.Outline = {
					Image = v7.Image,
					ImageRectOffset = v7.ImageRectOffset,
					ImageRectSize = v7.ImageRectSize
				}
			end

			return v5
		end
	end

	local v3 = tryHighQualitySprite(v2) -- equivalent call inferred; original call site unknown

	if v3 then
		return {
			Image = v3.Image,
			ImageRectOffset = v3.ImageRectOffset,
			ImageRectSize = v3.ImageRectSize
		}
	end

	return {
		Image = "rbxassetid://0",
		ImageRectOffset = Vector2.new(0, 0),
		ImageRectSize = Vector2.new(0, 0)
	}
end

local explorerBuffs = {
	Lifesteal = {
		DisplayName = "Lifesteal",
		Chance = 1,
		Step = 0.1,
		Cap = 1,
		RelevantCharacterStat = "PveLeech",
		Rarity = rarities.Epic,
		Colors = {
			Main = Color3.fromRGB(255, 50, 50)
		},
		GetLevelUpText = function(p: number, p2: number)
			return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}\n\n`)
		end,
		GetDescription = function(_: number?, p: number)
			return (`Heal for {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} of damage dealt to enemies.`)
		end,
		GetCardImage = function()
			return Spritesheets.MAP["HighQuality Lifesteal"] or Spritesheets.MAP.Lifesteal
		end,
		GetValue = fn
	}
}
local constructHealth = {
	DisplayName = "Healing Constructs",
	Chance = 0,
	Step = 0.04,
	Cap = 0.24,
	Colors = {
		Main = Color3.fromRGB(22, 245, 29),
		IconGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 211, 0))
		})
	},
	Rarity = rarities.Rare,
	GetLevelUpText = function(p: number, p2: number)
		local v5 = fmt(p - (p * 0.5) ^ 2, false) -- equivalent call inferred; original call site unknown
		local v6 = p2 - (p2 * 0.5) ^ 2
		return (`{v5} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", v6 * 100)}</font>`}\n\n`)
	end,
	GetDescription = function(_: number?, p: number)
		local v4 = p - (p * 0.5) ^ 2
		return (`Your physical constructs heal nearby allies for {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", v4 * 100)}</font>`} max health, per second.`)
	end,
	GetCardImage = function()
		return
			Spritesheets.MAP["HighQuality Creation-Creation1"] or Spritesheets.MAP["Creation-Creation1"],
			Spritesheets.MAP["HighQuality Health"] or Spritesheets.MAP.Health
	end,
	GetValue = function(p: number)
		local v4 = p - (p * 0.5) ^ 2
		return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", v4 * 100)}</font>`}`)
	end,
	GetRawValue = 0
}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function GetRawValue(p: number)
	return p - (p * 0.5) ^ 2
end

constructHealth.GetRawValue = GetRawValue
explorerBuffs.ConstructHealth = constructHealth
explorerBuffs.Size = {
	DisplayName = "Size",
	Chance = 1,
	Step = 0.2,
	Cap = 1,
	Colors = {
		Main = Color3.fromRGB(255, 221, 52)
	},
	Rarity = rarities.Rare,
	RelevantCharacterStat = "CharacterSize",
	GetLevelUpText = function(p: number, p2: number)
		return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}\n\n`)
	end,
	GetDescription = function(_: number?, p: number)
		return (`Increases size by {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`}.\n\n This also applies to humanoid transformations.`)
	end,
	GetCardImage = function()
		return Spritesheets.MAP["HighQuality Buffcard Size"] or Spritesheets.MAP["Buffcard Size"]
	end,
	GetValue = fn
}
explorerBuffs.Skyjumps = {
	DisplayName = "Skyjumps",
	Chance = 1,
	Step = 2,
	Cap = 6,
	RelevantCharacterStat = "SkyJumps",
	Colors = {
		Main = Color3.fromRGB(202, 241, 255)
	},
	Rarity = rarities.Uncommon,
	GetLevelUpText = function(_: number, p: number)
		return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f", p)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f", p)}</font>`}\n\n`)
	end,
	GetDescription = function(_: number?, p: number)
		return (`Gain {`<font color="rgb(255, 215, 38)">{string.format("%.0f", p)}</font>`} EXTRA skyjumps.`)
	end,
	GetCardImage = function()
		return Spritesheets.MAP["HighQuality AirJump Small"] or Spritesheets.MAP["AirJump Small"]
	end,
	GetValue = function(p: number)
		return (`+{p}`)
	end
}
explorerBuffs.RageGain = {
	DisplayName = "Fruit Meter",
	Chance = function(player)
		local character = player.Character

		if character and character:FindFirstChild("Rage") then
			return 1
		end

		return 0
	end,
	Step = 0.35,
	Cap = 5,
	Colors = {
		Main = Color3.fromRGB(255, 107, 57)
	},
	Rarity = rarities.Epic,
	GetLevelUpText = function(p: number, p2: number)
		return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}\n\n`)
	end,
	GetDescription = function(_: number?, p: number)
		return (`Gain {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} additional fruit meter from all sources.`)
	end,
	GetCardImage = function()
		return getToolSpriteInfo("Fruit"), Spritesheets.MAP["HighQuality RageGain"] or Spritesheets.MAP.RageGain
	end,
	GetValue = fn
}
explorerBuffs.RaceEnergy = {
	DisplayName = "Race Meter",
	Chance = function(player)
		local character = player.Character

		if character and character:FindFirstChild("RaceEnergy") then
			return 1
		end

		return 0
	end,
	Step = 0.2,
	Cap = 1,
	Colors = {
		Main = Color3.fromRGB(184, 84, 84)
	},
	Rarity = rarities.Epic,
	GetLevelUpText = function(p: number, p2: number)
		return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}\n\n`)
	end,
	GetDescription = function(_: number?, p: number)
		return (`Gain {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} additional race meter from all sources.`)
	end,
	GetCardImage = function()
		return
			Spritesheets.MAP["HighQuality Instinct Small"] or Spritesheets.MAP["Instinct Small"],
			Spritesheets.MAP["HighQuality Energy"] or Spritesheets.MAP.Energy
	end,
	GetValue = fn
}
explorerBuffs.AllCooldown = {
	DisplayName = "All Cooldowns",
	Chance = 1,
	Step = 0.1,
	Cap = 0.2,
	RelevantCharacterStat = "AllCooldown",
	Colors = {
		Main = Color3.fromRGB(91, 173, 255)
	},
	Rarity = rarities.Legendary,
	GetLevelUpText = function(p: number, p2: number)
		return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}\n\n`)
	end,
	GetDescription = function(_: number?, p: number)
		return (`All cooldowns reduced by {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`}.`)
	end,
	GetCardImage = function()
		return Spritesheets.MAP["HighQuality Cooldown"] or Spritesheets.MAP.Cooldown
	end,
	GetValue = fn
}
explorerBuffs.AttackSpeedMultiplier = {
	DisplayName = "HYPER!",
	Chance = 1,
	Step = 0.35,
	Cap = 5,
	RelevantCharacterStat = "AttackSpeedMultiplier",
	Colors = {
		Main = Color3.fromRGB(11, 190, 255)
	},
	Rarity = rarities.Legendary,
	GetLevelUpText = function(p: number, p2: number)
		return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}\n\n`)
	end,
	GetDescription = function(_: number?, p: number)
		return (`Your M1 attacks with Sword, Gun, and Melee become {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} faster.`)
	end,
	GetCardImage = function()
		return
			Spritesheets.MAP["HighQuality Sword"] or Spritesheets.MAP.Sword,
			Spritesheets.MAP["HighQuality Energy"] or Spritesheets.MAP.Energy
	end,
	GetValue = fn
}
explorerBuffs.Unbreakable = {
	DisplayName = "Unbreakable",
	Chance = 1,
	Step = 1,
	Cap = 1,
	RelevantCharacterStat = "Unbreakable",
	Colors = {
		Main = Color3.fromRGB(255, 251, 145)
	},
	Rarity = rarities.Epic,
	GetDescription = function(_: number?, _: number)
		return "Your skill charges can no longer be interrupted."
	end,
	GetCardImage = function()
		return
			Spritesheets.MAP["HighQuality FlashStep Small"] or Spritesheets.MAP["FlashStep Small"],
			Spritesheets.MAP["HighQuality Sword"] or Spritesheets.MAP.Sword
	end,
	GetValue = function()
		return ""
	end
}
explorerBuffs.Overflow = {
	DisplayName = "<font color=\"rgb(11, 190, 255)\">Overflow</font>",
	Chance = 1,
	Step = 3000,
	Cap = 30000,
	Colors = {
		Main = Color3.fromRGB(151, 227, 255)
	},
	Rarity = rarities.Legendary,
	GetLevelUpText = function(p: number, p2: number)
		local v4 = colorText(p, explorerBuffs.Overflow.Colors.Main) -- equivalent call inferred; original call site unknown
		local main2 = explorerBuffs.Overflow.Colors.Main
		return (`{v4} > {`<font color="rgb({math.clamp(math.floor(main2.R * 255), 0, 255)}, {math.clamp(math.floor(main2.G * 255), 0, 255)}, {math.clamp(math.floor(main2.B * 255), 0, 255)})">{p2}</font>`}\n\n`)
	end,
	GetDescription = function(_: number?, p: number)
		local main = explorerBuffs.Overflow.Colors.Main
		return (`Every 15 seconds, gain {`<font color="rgb({math.clamp(math.floor(main.R * 255), 0, 255)}, {math.clamp(math.floor(main.G * 255), 0, 255)}, {math.clamp(math.floor(main.B * 255), 0, 255)})">{p}</font>`} <font color="rgb(11, 190, 255)">Overflow</font> health.`)
	end,
	GetCardImage = function()
		return Spritesheets.MAP["HighQuality Defense"] or Spritesheets.MAP.Defense
	end,
	GetValue = function(p: number)
		return (`{p}`)
	end
}
explorerBuffs.Shadow = {
	DisplayName = "<font color=\"rgb(115, 22, 245)\">Shadow</font>",
	Chance = 0.5,
	Step = 1,
	Cap = 2,
	Colors = {
		Main = Color3.fromRGB(115, 22, 245)
	},
	Rarity = rarities.Legendary,
	GetLevelUpText = function(p: number, p2: number)
		return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f", p)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f", p2)}</font>`}\n\n`)
	end,
	GetDescription = function(_: number?, p: number)
		local v4 = 60 / p
		local formatted = `<font color="rgb(255, 215, 38)">{string.format("%.0f", v4)}</font>`
		local formatted2 = `<font color="rgb(255, 215, 38)">{string.format("%.0f", p)}</font>`
		local v5 = p > 1 and "s" or ""
		local v6 = 60 / p
		return (`Every {formatted} seconds, {formatted2} <font color="rgb(115, 22, 245)">Shadow{v5}</font> will spawn and fight on your behalf.\n\n<i><font color="rgb(115, 22, 245)">Shadows</font> have a shared respawn timer and only one will respawn every {`<font color="rgb(255, 215, 38)">{string.format("%.0f", v6)}</font>`} seconds.</i>`)
	end,
	GetCardImage = function()
		return Spritesheets.MAP["HighQuality Buffcard Shadow"] or Spritesheets.MAP["Buffcard Shadow"]
	end,
	GetValue = function(p: number)
		return (`{p}`)
	end
}
explorerBuffs.Armor = {
	DisplayName = "Armor",
	Chance = 1,
	Step = 0.1,
	Cap = 0.5,
	Colors = {
		Main = Color3.fromRGB(115, 22, 245),
		IconGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 85, 85)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		})
	},
	Rarity = rarities.Rare,
	GetLevelUpText = function(p: number, p2: number)
		local rawValue = GetRawValue(p)
		local v6 = fmt(rawValue, false) -- equivalent call inferred; original call site unknown
		local rawValue2 = GetRawValue(p2)
		return (`{v6} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", rawValue2 * 100)}</font>`}\n\n`)
	end,
	GetDescription = function(_: number?, p: number)
		local rawValue = GetRawValue(p)
		return (`Gain {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", rawValue * 100)}</font>`} damage reduction from all sources.`)
	end,
	GetCardImage = function()
		return Spritesheets.MAP["HighQuality Defense"] or Spritesheets.MAP.Defense
	end,
	GetValue = function(p: number)
		local rawValue = GetRawValue(p)
		return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", rawValue * 100)}</font>`}`)
	end,
	GetRawValue = function(p: number)
		return GetRawValue(p)
	end
}
explorerBuffs.Sniper = {
	DisplayName = "Sniper",
	Chance = 1,
	Step = 0.3,
	Cap = 0.9,
	RelevantCharacterStat = "SniperBuff",
	Colors = {
		Main = Color3.fromRGB(91, 173, 255)
	},
	Rarity = rarities.Epic,
	GetLevelUpText = function(p: number, p2: number)
		return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}\n\n`)
	end,
	GetDescription = function(_: number?, p: number)
		return (`Your Gun deals up to {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} more damage, increasing with range.`)
	end,
	GetCardImage = function()
		return Spritesheets.MAP["HighQuality Gun"] or Spritesheets.MAP.Gun
	end,
	GetValue = fn
}
explorerBuffs.Fortress = {
	DisplayName = "Fortress",
	Chance = 1,
	Step = 1,
	Cap = 1,
	Colors = {
		Main = Color3.fromRGB(255, 251, 145)
	},
	Rarity = rarities.Legendary,
	GetDescription = function(_: number?, _: number)
		return (`Stuns no longer apply to you. When hit, you have a {`<font color="rgb(255, 215, 38)">{string.format("%.0f", 20)}%</font>`} chance to nullify the attack. If successful, reflects {`<font color="rgb(255, 215, 38)">{string.format("%.0f", 100)}%</font>`} of that damage to the dealer and stuns them for 1 second.`)
	end,
	GetCardImage = function()
		return
			Spritesheets.MAP["HighQuality Buffcard Fortress"] or Spritesheets.MAP["Buffcard Fortress"],
			Spritesheets.MAP["HighQuality Defense"] or Spritesheets.MAP.Defense
	end,
	GetValue = function()
		return ""
	end
}

local function fn2(p: string, p2: string)
	local v5 = p == "Fruit" and "Blox Fruit" or p
	local FruitSkills = require(game.ReplicatedStorage.FruitSkills)

	if not game.Players.LocalPlayer then
		return "???"
	end

	local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")

	if tool and tool.ToolTip == v5 then
		local v6 = tool:FindFirstChild("AwakenedMoves") ~= nil
		local v7 = FruitSkills[tool.Name][v6 and 2 or 1]

		for _, v8 in pairs(v7) do
			if v8[1] == p2 then
				return v8[3]
			end
		end
	end

	for _, tool2 in game.Players.LocalPlayer.Backpack:GetChildren() do
		if not (tool2:IsA("Tool") and tool2.ToolTip == v5) then
			continue
		end

		local v6 = tool2:FindFirstChild("AwakenedMoves") ~= nil
		local v7 = FruitSkills[tool2.Name][v6 and 2 or 1]

		for _, v8 in pairs(v7) do
			if v8[1] == p2 then
				return v8[3]
			end
		end
	end

	return "???"
end

for _, v5 in {
	"Gun",
	"Sword",
	"Melee",
	"Fruit",
	"Defense"
} do
	local v6 = v5 .. ""
	local v7 = v5
	local v8 = v5
	explorerBuffs[v6] = {
		DisplayName = `{v5}`,
		Chance = 1,
		Step = 500,
		Cap = 10000,
		RelevantCharacterStat = v6 == "Fruit" and "Demon Fruit" or v6,
		Colors = {
			Main = Color3.fromRGB(11, 190, 255)
		},
		Rarity = rarities.Uncommon,
		GetLevelUpText = function(p: number, p2: number)
			return (`{p} > {p2}\n\n`)
		end,
		GetDescription = function(p: number?, p2: number)
			return (`{v7} stat increased by {p2}.`)
		end,
		GetCardImage = function()
			local v9 = v8 == "Defense" and "Health" or v8
			return
				getToolSpriteInfo(v9) or tryHighQualitySprite(v9),
				Spritesheets.MAP["HighQuality Misc"] or Spritesheets.MAP.Misc
		end,
		GetValue = function(p: number)
			return (`+{p}`)
		end
	}
end

for _, v5 in {
	"Gun",
	"Sword",
	"Melee",
	"Fruit"
} do
	local v6 = v5
	local v7 = v5
	explorerBuffs[v5 .. "Cooldown"] = {
		DisplayName = v5 .. " Cooldowns",
		Chance = 1,
		Step = 0.1,
		Cap = 0.3,
		RelevantCharacterStat = v5 .. "Cooldown",
		Colors = {
			Main = Color3.fromRGB(11, 190, 255)
		},
		Rarity = rarities.Rare,
		GetLevelUpText = function(p: number, p2: number)
			return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}\n\n`)
		end,
		GetDescription = function(p: number?, p2: number)
			return (`All {v6} skill cooldowns reduced by {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}.`)
		end,
		GetCardImage = function()
			local toolSpriteInfo = getToolSpriteInfo(v7)

			if not toolSpriteInfo then
				toolSpriteInfo = tryHighQualitySprite(v7)
			end

			return toolSpriteInfo, Spritesheets.MAP["HighQuality Cooldown"] or Spritesheets.MAP.Cooldown
		end,
		GetValue = fn
	}

	for _, letterDescriptor in {
		"Z",
		"X",
		"C",
		"V"
	} do
		if not ((v5 ~= "Gun" and v5 ~= "Sword" or letterDescriptor ~= "V" and letterDescriptor ~= "C") and (v5 ~= "Melee" or letterDescriptor ~= "V")) then
			continue
		end

		local relevantCharacterStat = v5 .. letterDescriptor .. "Cooldown"
		local v10 = v5
		local v11 = letterDescriptor
		local v12 = v5
		local v13 = letterDescriptor
		local v14 = v5
		explorerBuffs[relevantCharacterStat] = {
			LetterDescriptor = letterDescriptor,
			DisplayName = `{v5} Cooldown ({letterDescriptor} Skill)`,
			Chance = function(p)
				local equippedTool = getEquippedTool(v10 == "Fruit" and "Blox Fruit" or v10, p)

				if equippedTool and toolHasSkill(equippedTool, v11) then
					return 1
				end

				return 0
			end,
			Step = 0.15,
			Cap = 0.45,
			RelevantCharacterStat = relevantCharacterStat,
			Colors = {
				Main = Color3.fromRGB(11, 190, 255)
			},
			Rarity = rarities.Rare,
			GetLevelUpText = function(p: number, p2: number)
				return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}\n\n`)
			end,
			GetDescription = function(p: number?, p2: number)
				return (`{fn2(v12, v13)} cooldown reduced by {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}.`)
			end,
			GetCardImage = function()
				return getToolSpriteInfo(v14), Spritesheets.MAP["HighQuality Cooldown"] or Spritesheets.MAP.Cooldown
			end,
			GetValue = fn
		}
	end

	if v5 ~= "Fruit" then
		continue
	end

	local relevantCharacterStat2 = "Fruit" .. "TAPCooldown"
	local v10 = {
		"Kitsune-Kitsune",
		"Blade-Blade",
		"Werewolf (Tiger)-Werewolf (Tiger)",
		"Pain-Pain",
		"Empyrean (Kitsune)-Empyrean (Kitsune)",
		"Fiend (Yeti)-Fiend (Yeti)",
		"Mammoth-Mammoth",
		"Magnet-Magnet",
		"Tiger-Tiger",
		"Yeti-Yeti",
		"Light-Light",
		"Ice-Ice"
	}
	local v11 = "Fruit"
	explorerBuffs[relevantCharacterStat2] = {
		LetterDescriptor = "M1",
		DisplayName = `{"Fruit"} M1 Speed`,
		Chance = function(p)
			local equippedTool = getEquippedTool("Blox Fruit", p)

			if not equippedTool then
				return 0
			end

			if table.find(v10, equippedTool.Name) or toolHasSkill(equippedTool, "TAP") then
				return 1
			end

			return 0
		end,
		Step = 0.15,
		Cap = 0.6,
		RelevantCharacterStat = relevantCharacterStat2,
		Colors = {
			Main = Color3.fromRGB(11, 190, 255)
		},
		Rarity = rarities.Epic,
		GetLevelUpText = function(p: number, p2: number)
			return (`{`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`} > {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p2 * 100)}</font>`}\n\n`)
		end,
		GetDescription = function(_: number?, p: number)
			return (`Fruit M1 speed increased by {`<font color="rgb(255, 215, 38)">{string.format("%.0f%%", p * 100)}</font>`}.`)
		end,
		GetCardImage = function()
			return getToolSpriteInfo(v11), Spritesheets.MAP["HighQuality Energy"] or Spritesheets.MAP.Energy
		end,
		GetValue = fn
	}
end

local new = ChanceWeightUtil.new
local weights = {}

for _, v5 in pairs(rarities) do
	weights[v5] = v5.Weight
end

local v5 = new(weights)

local function handleNewConfigs(currentBuffCardConfigs)
	for k, v6 in pairs(explorerBuffs) do
		local v7 = currentBuffCardConfigs[k]

		if not v7 then
			continue
		end

		if v7.Chance then
			v6.Chance = v7.Chance
		end

		if v7.Step then
			v6.Step = v7.Step
		end

		if v7.Cap then
			v6.Cap = v7.Cap
		end
	end
end

handleNewConfigs(BuffCardConfigs.CurrentBuffCardConfigs or {})
BuffCardConfigs.OnUpdate.Event:Connect(handleNewConfigs)

for _, _ in explorerBuffs do

end

return {
	ExplorerBuffs = explorerBuffs,
	Rarities = rarities,
	RollRarity = function()
		return v5:Roll()
	end
}