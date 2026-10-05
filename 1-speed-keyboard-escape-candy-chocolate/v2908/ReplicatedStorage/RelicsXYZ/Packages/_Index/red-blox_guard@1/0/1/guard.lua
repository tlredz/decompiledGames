local Guard = {}

function Guard.Any(p)
	return p
end

function Guard.Boolean(p)
	assert(type(p) == "boolean")
	return p
end

function Guard.Thread(p)
	assert(type(p) == "thread")
	return p
end

function Guard.Nil(p)
	assert(p == nil)
	return p
end

function Guard.Number(value)
	assert(type(value) == "number")
	assert(value == value)
	return value
end

function Guard.String(value)
	assert(type(value) == "string")
	return value
end

function Guard.Optional(callback)
	return function(p)
		if p == nil then
			return nil
		end

		return callback(p)
	end
end

function Guard.Literal(p)
	return function(p2)
		assert(p2 == p)
		return p2
	end
end

function Guard.Or(callback, callback2)
	return function(p)
		if pcall(callback, p) or pcall(callback2, p) then
			return p
		end

		error("Union check failed")
	end
end

function Guard.And(callback, callback2)
	return function(p)
		if not pcall(callback, p) then
			error("Intersection check failed")
		end

		if not pcall(callback2, p) then
			error("Intersection check failed")
		end

		return p
	end
end

function Guard.Map(callback, callback2)
	return function(items)
		assert(type(items) == "table")

		for k, item in items do
			callback(k)
			callback2(item)
		end

		return items
	end
end

function Guard.Set(callback)
	local v = true

	local function fn(item)
		assert(item == v)
		return item
	end

	return function(items)
		assert(type(items) == "table")

		for k, item in items do
			callback(k)
			fn(item)
		end

		return items
	end
end

function Guard.List(callback)
	return function(list)
		assert(type(list) == "table")

		for i = 1, table.maxn(list) do
			callback(list[i])
		end

		return list
	end
end

function Guard.Integer(value)
	assert(type(value) == "number")
	assert(value % 1 == 0)
	return value
end

function Guard.NumberMin(p: number)
	return function(value)
		assert(type(value) == "number")
		assert(p <= value)
		return value
	end
end

function Guard.NumberMax(p: number)
	return function(value)
		assert(type(value) == "number")
		assert(value <= p)
		return value
	end
end

function Guard.NumberMinMax(p: number, p2: number)
	return function(value)
		assert(type(value) == "number")
		assert(p < value)
		assert(value < p2)
		return value
	end
end

function Guard.CFrame(p)
	assert(typeof(p) == "CFrame")
	assert(p == p)
	return p
end

function Guard.Color3(p)
	assert(typeof(p) == "Color3")
	assert(p == p)
	return p
end

function Guard.DateTime(p)
	assert(typeof(p) == "DateTime")
	return p
end

function Guard.Instance(instance)
	assert(typeof(instance) == "Instance")
	return instance
end

function Guard.Vector2(p)
	assert(typeof(p) == "Vector2")
	assert(p == p)
	return p
end

function Guard.Vector2int16(p)
	assert(typeof(p) == "Vector2int16")
	return p
end

function Guard.Vector3(p)
	assert(typeof(p) == "Vector3")
	assert(p == p)
	return p
end

function Guard.Vector3int16(p)
	assert(typeof(p) == "Vector3int16")
	return p
end

function Guard.Check(callback)
	return function(p)
		return pcall(callback, p)
	end
end

return Guard