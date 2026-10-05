local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3("@self/Items")
local v2 = require3("@self/Gifts")
local v3 = require3(ReplicatedStorage2.Shared.SpinTypes)
local v4 = require3(ReplicatedStorage2.Shared.ResourceTypes)
local v5 = require3(ReplicatedStorage2.Shared.MapData)
local v6 = require3(ReplicatedStorage2.Packages.Conch)
local v7 = require3(ReplicatedStorage2.Packages.Freeze)

local function register_type(p, p2: string?, p3: string?)
	return v6.wrap_type(v6.register_strange_type(p), p2, p3)
end

local function register_enum(p: string, list, p2: string?, p3: string?)
	if #list > 0 then
		return v6.args.enum_from_array(p, list, p2 or p, p3)
	end

	if next(list) then
		return v6.args.enum_from_map(p, list, p2 or p, p3)
	end

	error("Enum must have at least one value")
end

return {
	BanScope = register_enum("ban_scope", { "Game", "Ranked" }, "BanScope"),
	SpinType = register_enum("spin_type", v3.Names, "SpinType"),
	Resource = register_enum("resource", v4.Names, "Resource"),
	SettableResource = register_enum("settable_resource", v4.SettableNames, "Resource"),
	Toggle = register_enum("toggle", {
		On = true,
		Off = false
	}, "Toggle"),
	ReplionOp = register_enum("replion_op", { "Set", "Increase", "Decrease" }, "Operation"),
	RankedType = register_enum("ranked_type", { "Normal", "NoAbility" }, "RankedType"),
	MapName = register_enum("map_name", v7.Dictionary.keys(v5), "Map"),
	Gravities = register_enum("gravity", {
		"Mid",
		"High",
		"Low",
		"ExtraLow"
	}, "Gravity"),
	LuckArea = register_enum("luck_area", {
		"Battlepass",
		"DefaultWheel",
		"UpdateCrate",
		"GenericGacha"
	}, "LuckArea"),
	Multiplier = register_enum("multiplier", {
		["2x"] = 2,
		["3x"] = 3,
		["4x"] = 4,
		["6x"] = 6,
		["8x"] = 8
	}, "Multiplier"),
	Ability = register_enum("ability", v7.List.map(ReplicatedStorage2.Misc.DataAbilities:GetChildren(), function(p)
		return p.Name
	end), "Ability"),
	Caipirinha = register_enum("country", {
		"GLOBAL",
		"NA",
		"EU",
		"LATAM",
		"MENA",
		"OCE",
		"ASEAN",
		"ASIA",
		"AF"
	}),
	Event = register_enum("game_event", {
		"ActivateLuck",
		"BattlepassLuck",
		"DefaultWheelLuck",
		"UpdateCrateLuck",
		"BrazilEvent",
		"GlobalBallManipulation",
		"2Ball",
		"CurveBall",
		"FastBall",
		"PlayerManipulation",
		"ChangeGravity",
		"ForceAbility",
		"WalkSpeed",
		"ParryStrength",
		"ReduceAbilityCooldown",
		"Pulsed",
		"GoldenAbilities",
		"GoldenSkies"
	}, "Event"),
	GiveItemType = register_enum("item_type", {
		["Battlepass Spins"] = "createGachaSpinsReward",
		["Default Lobby Wheel Spins"] = "createWheelSpinReward",
		["Update Crate"] = "UpdateCrate",
		Sword = "Sword",
		Emote = "Emote",
		Explosion = "Explosion"
	}, "ItemType"),
	Conch = register_enum("conch_type", { "viewroles", "viewpermissions" }),
	InventoryType = register_enum("inventory_type", { "Sword", "Emote", "Explosion" }, "InventoryType"),
	InventoryKind = register_enum("inventory_kind", {
		"Sword",
		"Emote",
		"Explosion",
		"Ability"
	}, "InventoryKind"),
	InventoryType2 = register_enum("inventory_type_2", {
		"Sword",
		"Emote",
		"Explosion",
		"UpdateCrate"
	}, "InventoryType"),
	InventoryItem = register_enum("inventory_item", v.Names, "Item"),
	GiftProduct = register_enum("gift_product", v2.Names, "Product")
}