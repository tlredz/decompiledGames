local Constructors = require(script.Parent.Constructors)
local none = Constructors.Option.none()
local some = Constructors.Option.some
local Option = {
	some = Constructors.Option.some,
	none = Constructors.Option.none,
	transpose = Constructors.Option.transpose,
	flatten = Constructors.Option.flatten,
	map = function(p, callback)
		if p.IsSome then
			return some(callback(p.Value))
		end

		return p
	end,
	mapNone = function(p, callback)
		if p.IsNone then
			return some(callback())
		end

		return p
	end,
	match = function(p, callback, callback2)
		if p.IsSome then
			return callback(p.Value)
		end

		return callback2()
	end,
	from = function(p)
		if p == nil then
			return some(nil)
		end

		return none
	end
}

function Option.try(callback)
	return Option.from(callback())
end

function Option.asNullable(p)
	if p.IsSome then
		return p.Value
	end

	return nil
end

return Option