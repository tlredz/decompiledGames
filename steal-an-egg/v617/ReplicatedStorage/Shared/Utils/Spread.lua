return table.freeze({
	Sample = function(list, p: number, object)
		if type(list) == "table" then
			assert(#list == 2, "a random range needs exactly two bounds")
			return object:NextNumber(list[1], list[2])
		end

		if list == nil then
			return p
		end

		return list
	end,
	Scale = function(value, p: number)
		if type(value) == "number" then
			return value * p
		end

		if type(value) == "table" then
			return { value[1] * p, value[2] * p }
		end

		return nil
	end,
	FromRange = function(range: NumberRange, p: number)
		return { range.Min * p, range.Max * p }
	end
})