require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Packages.Option)
require(game.ReplicatedStorage.Packages.Future)
local Type = require(game.ReplicatedStorage.Packages.Type)
local Display = require(game.ReplicatedStorage.Packages.Display)
local TypeUtil = require(game.ReplicatedStorage.Economy.TypeUtil)
require(game.ReplicatedStorage.Types.JuiceTypes)
local redeemDataStrategy = TypeUtil.BetterLiteral.Type.check(
	"PermanentFruit",
	"PhysicalMoveset",
	"Sword",
	"SwordSkin",
	"EtcItems",
	"Items",
	"FruitSkin",
	"SkinnedFruit",
	"MutatedFruit",
	"FruitMutation",
	"ChangeDevilFruit",
	"AuraSkin",
	"ProfileFullArt"
)
local class = {}
class.__index = class

function class.__tostring(p)
	local clone = table.clone(p)
	setmetatable(clone, nil)
	return (`{script.Name}<{Display.JSON.new():display(clone)}>`)
end

return {
	Type = {
		check = Type.intersection(Type.strictInterface({
			Config = TypeUtil.BetterUnion.Type.check({
				Box = Type.strictInterface({
					Type = Type.literal("Box"),
					ItemId = Type.integer
				}),
				SpecialProduct = Type.strictInterface({
					Type = Type.literal("SpecialProduct"),
					ItemId = Type.integer
				}),
				Currency = Type.strictInterface({
					Type = Type.literal("Currency"),
					FragmentAmount = Type.integer,
					BeliAmount = Type.integer,
					ItemId = TypeUtil.Option.Type.check(Type.integer)
				}),
				ExpBoost = Type.strictInterface({
					Type = Type.literal("ExpBoost"),
					Duration = Type.integer
				}),
				Item = Type.strictInterface({
					Type = Type.literal("Item"),
					RedeemDataStrategy = redeemDataStrategy,
					ItemId = Type.integer,
					Amount = TypeUtil.Option.Type.check(Type.integer)
				}),
				EconomyItem = Type.strictInterface({
					Type = Type.literal("EconomyItem"),
					ItemId = Type.integer,
					StoreOnRedeem = Type.boolean
				}),
				MasteryBoost = Type.strictInterface({
					Type = Type.literal("MasteryBoost"),
					Moveset = Type.union(
						Type.literal("FightingStyle"),
						Type.literal("Sword"),
						Type.literal("Gun"),
						Type.literal("Fruit")
					),
					Amount = Type.number
				})
			})
		}), TypeUtil.Metatable.Type.check(class))
	},
	Class = class,
	Templates = {
		Box = {
			new = function(itemId: number)
				local self = setmetatable({
					Config = table.freeze({
						Type = "Box",
						ItemId = itemId
					})
				}, class)
				table.freeze(self)
				return self
			end
		},
		SpecialProduct = {
			new = function(itemId: number)
				local self = setmetatable({
					Config = table.freeze({
						Type = "SpecialProduct",
						ItemId = itemId
					})
				}, class)
				table.freeze(self)
				return self
			end
		},
		Currency = {
			new = function(beliAmount: number, fragmentAmount: number, itemId)
				local self = setmetatable({
					Config = table.freeze({
						Type = "Currency",
						BeliAmount = beliAmount,
						FragmentAmount = fragmentAmount,
						ItemId = itemId
					})
				}, class)
				table.freeze(self)
				return self
			end
		},
		Item = {
			new = function(itemId: number, redeemDataStrategy2: string, amount)
				local self = setmetatable({
					Config = table.freeze({
						Type = "Item",
						RedeemDataStrategy = redeemDataStrategy2,
						ItemId = itemId,
						Amount = amount
					})
				}, class)
				table.freeze(self)
				return self
			end
		},
		ExpBoost = {
			new = function(duration: number)
				local self = setmetatable({
					Config = table.freeze({
						Type = "ExpBoost",
						Duration = duration
					})
				}, class)
				table.freeze(self)
				return self
			end
		},
		EconomyItem = {
			new = function(itemId: number, storeOnRedeem: boolean)
				local self = setmetatable({
					Config = table.freeze({
						Type = "EconomyItem",
						ItemId = itemId,
						StoreOnRedeem = storeOnRedeem
					})
				}, class)
				table.freeze(self)
				return self
			end
		},
		MasteryBoost = {
			new = function(moveset: string, amount: number)
				local self = setmetatable({
					Config = table.freeze({
						Type = "MasteryBoost",
						Moveset = moveset,
						Amount = amount
					})
				}, class)
				table.freeze(self)
				return self
			end
		}
	}
}