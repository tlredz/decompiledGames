require(game.ReplicatedStorage.Packages.Result)
local Option = require(game.ReplicatedStorage.Packages.Option)
local Type = require(game.ReplicatedStorage.Packages.Type)
local Display = require(game.ReplicatedStorage.Packages.Display)
local TypeUtil = require(game.ReplicatedStorage.Economy.TypeUtil)
local class = {}
class.__index = class

function class.__tostring(p)
	local clone = table.clone(p)
	setmetatable(clone, nil)
	return (`{script.Name}<{Display.JSON.new():display(clone)}>`)
end

function class.Check(p, p2: number)
	local unwrapOr = p.Min:unwrapOr(0)
	local unwrapOr2 = p.Max:unwrapOr(1e999)
	return unwrapOr <= p2 and p2 <= unwrapOr2
end

function class.new(min, max)
	local self = setmetatable({
		Min = min,
		Max = max
	}, class)
	table.freeze(self)
	return self
end

return {
	Templates = {
		all = function()
			return class.new(Option.none(), Option.none())
		end,
		min = function(p: number)
			return class.new(Option.some(p), Option.none())
		end,
		max = function(p: number)
			return class.new(Option.none(), Option.some(p))
		end,
		range = function(p: number, p2: number)
			return class.new(Option.some(p), Option.some(p2))
		end
	},
	Type = {
		check = Type.intersection(Type.strictInterface({
			Min = TypeUtil.Option.Type.check(Type.integer),
			Max = TypeUtil.Option.Type.check(Type.integer)
		}), TypeUtil.Metatable.Type.check(class))
	},
	Class = class
}