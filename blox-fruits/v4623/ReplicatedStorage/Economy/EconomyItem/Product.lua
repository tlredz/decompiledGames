local Result = require(game.ReplicatedStorage.Packages.Result)
local Option = require(game.ReplicatedStorage.Packages.Option)
require(game.ReplicatedStorage.Packages.Future)
local Type = require(game.ReplicatedStorage.Packages.Type)
local Display = require(game.ReplicatedStorage.Packages.Display)
local SimpleError = require(game.ReplicatedStorage.Packages.SimpleError)
local TierInfo = require(game.ReplicatedStorage.Economy.EconomyItem.Product.TierInfo)
local Settlement = require(game.ReplicatedStorage.Economy.EconomyItem.Product.Settlement)
require(game.ReplicatedStorage.Economy.EconomyItem.LegacyInfo)
require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
local TypeUtil = require(game.ReplicatedStorage.Economy.TypeUtil)
local class = {}
class.__index = class

function class.__tostring(p)
	local clone = table.clone(p)
	setmetatable(clone, nil)
	return (`{script.Name}<{Display.JSON.new():display(clone)}>`)
end

function class.GetMatchingTier(p, p2: number)
	local none = Option.none()

	for _, tier in pairs(p.Tiers) do
		if not tier.Tier:Check(p2) then
			continue
		end

		if none:isSome() then
			return Result.err(SimpleError.new("Overqualified", (`Multiple tiers found matching level {p2}`)))
		else
			none = Option.some(tier.Settlement)
		end
	end

	return Option.map(none, function(p3)
		return Result.ok(p3)
	end):unwrapOrElse(function()
		return Result.err(SimpleError.new("Underqualified", (`No tier found matching level {p2}`)))
	end)
end

function class.new(items)
	local values = {}

	for k, item in items do
		table.insert(values, table.freeze({
			Tier = k,
			Settlement = item
		}))
	end

	local self = setmetatable({
		Tiers = values
	}, class)
	table.freeze(self)
	return self
end

return {
	Type = {
		check = Type.intersection(Type.strictInterface({
			Tiers = Type.array(Type.strictInterface({
				Tier = TierInfo.Type.check,
				Settlement = Settlement.Type.check
			}))
		}), TypeUtil.Metatable.Type.check(class))
	},
	Class = class
}