require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Packages.Option)
require(game.ReplicatedStorage.Packages.Future)
local Type = require(game.ReplicatedStorage.Packages.Type)
local Display = require(game.ReplicatedStorage.Packages.Display)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local TypeUtil = require(game.ReplicatedStorage.Economy.TypeUtil)
local v = TypeUtil.BetterLiteral.Type.check(
	"HasNoActiveBeliBoost",
	"HasNoActiveMasteryBoost",
	"HasNoActiveBoatSpeedBoost",
	"HasNoActiveFruitNotifier",
	"HasNoActiveBossDropsBoost",
	"HasNoTradeableDragonToken",
	"HasNoPermanentDragonDiscount",
	"HasNotLearnedAuraSkill"
)
local literal = Type.literal("Purchaser", "Recipient", "Both")
local check = nil
local strictInterface = Type.strictInterface({
	Type = TypeUtil.BetterLiteral.Type.check(
		"StorageLimit",
		"PurchaseLimit",
		"RedeemLimit",
		"GiftLimit",
		"AvailableFruitStorage"
	),
	ItemId = Type.integer,
	Scope = literal,
	Minimum = TypeUtil.Option.Type.check(Type.integer),
	Maximum = TypeUtil.Option.Type.check(Type.integer)
})
local strictInterface2 = Type.strictInterface({
	Type = TypeUtil.BetterLiteral.Type.check(
		"SeaLevelLimit",
		"RobuxSpentLimit",
		"LevelLimit",
		"BeliLimit",
		"FragmentsLimit"
	),
	Scope = literal,
	Minimum = TypeUtil.Option.Type.check(Type.integer),
	Maximum = TypeUtil.Option.Type.check(Type.integer)
})
local strictInterface3 = Type.strictInterface({
	Type = Type.literal("Special"),
	Scope = literal,
	Key = v
})
local strictInterface4 = Type.strictInterface({
	Type = TypeUtil.BetterLiteral.Type.check("DoesNotHaveItemEquipped", "HasItemEquipped"),
	ItemId = Type.integer,
	Scope = literal
})
local strictInterface5 = Type.strictInterface({
	Type = Type.literal("SaleIsActive"),
	Key = Type.string
})
local strictInterface6 = Type.strictInterface({
	Type = Type.literal("MasteryBoostable"),
	Moveset = TypeUtil.BetterLiteral.Type.check("FightingStyle", "Sword", "Gun", "Fruit"),
	Scope = literal
})
local config = TypeUtil.BetterUnion.Type.check({
	ItemLimit = strictInterface,
	ValueLimit = strictInterface2,
	Special = strictInterface3,
	Equipped = strictInterface4,
	SaleIsActive = strictInterface5,
	MasteryBoostable = strictInterface6
})
local class = {}
class.__index = class

function class.__tostring(p)
	local clone = table.clone(p)
	setmetatable(clone, nil)
	return (`{script.Name}<{Display.JSON.new():display(clone)}>`)
end

check = Type.intersection(Type.strictInterface({
	Config = config,
	Filters = TypeUtil.Option.Type.check(Type.array(TypeUtil.BetterLiteral.Type.check(
		"Gift",
		"Redeem",
		"Purchase",
		"Trade",
		"Store"
	))),
	Alternative = TypeUtil.Option.Type.check(function(p)
		return check(p)
	end)
}), TypeUtil.Metatable.Type.check(class))
return {
	Type = {
		check = check
	},
	Class = class,
	Templates = {
		ItemRange = {
			new = function(p: string, p2: string, p3, scope: string, minimum, maximum, filters, alternative)
				local unwrapped = ItemId.getId(p2, p3):unwrap()
				local self = setmetatable({
					Config = table.freeze({
						Type = p,
						ItemId = unwrapped,
						Scope = scope,
						Minimum = minimum,
						Maximum = maximum
					}),
					Filters = filters,
					Alternative = alternative
				}, class)
				table.freeze(self)
				return self
			end
		},
		EquipState = {
			new = function(p: string, p2: string, p3, scope: string, filters, alternative)
				local unwrapped = ItemId.getId(p2, p3):unwrap()
				local self = setmetatable({
					Config = table.freeze({
						Type = p,
						ItemId = unwrapped,
						Scope = scope
					}),
					Alternative = alternative,
					Filters = filters
				}, class)
				table.freeze(self)
				return self
			end
		},
		ValueRange = {
			new = function(p: string, scope: string, minimum, maximum, filters, alternative)
				local self = setmetatable({
					Config = table.freeze({
						Type = p,
						Minimum = minimum,
						Maximum = maximum,
						Scope = scope
					}),
					Filters = filters,
					Alternative = alternative
				}, class)
				table.freeze(self)
				return self
			end
		},
		Special = {
			new = function(p: string, scope: string, filters, alternative)
				local self = setmetatable({
					Config = table.freeze({
						Type = "Special",
						Key = p,
						Scope = scope
					}),
					Filters = filters,
					Alternative = alternative
				}, class)
				table.freeze(self)
				return self
			end
		},
		MasteryBoostable = {
			new = function(moveset: string, scope: string, filters, alternative)
				local self = setmetatable({
					Config = table.freeze({
						Type = "MasteryBoostable",
						Moveset = moveset,
						Scope = scope
					}),
					Filters = filters,
					Alternative = alternative
				}, class)
				table.freeze(self)
				return self
			end
		},
		SaleIsActive = {
			new = function(p: string, filters, alternative)
				local self = setmetatable({
					Config = table.freeze({
						Type = "SaleIsActive",
						Key = p
					}),
					Filters = filters,
					Alternative = alternative
				}, class)
				table.freeze(self)
				return self
			end
		}
	}
}