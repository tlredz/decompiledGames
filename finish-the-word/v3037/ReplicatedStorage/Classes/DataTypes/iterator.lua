local replicatedStorage = game.ReplicatedStorage
local machine = require(replicatedStorage:WaitForChild("Services"):WaitForChild("Core"):WaitForChild("machine"))
local req = machine.req(replicatedStorage, "Classes", "DataTypes", "class")
local req2 = machine.req(replicatedStorage, "Services", "Utility", "dictUtil")
local v = req.new()

function v:new(iterator, p2, var)
	self.iterator = iterator
	self._s = p2
	self._var = var
end

function v.fromArray(p)
	return v(pairs(p))
end

function v.range(p, p2, value)
	local v2 = value or 1
	local v3 = p
	return v(function()
		local v4 = v3
		v3 += v2
		return v4 <= p2 and v4 or nil
	end)
end

function v.count(p)
	return v.range(1, p)
end

function v.values(p)
	return v.fromArray(p):map(function(_, p2)
		return p2
	end)
end

function v.keys(p)
	return v.fromArray(p):map(function(p2, _)
		return p2
	end)
end

function v:map(callback)
	return v(function(p)
		local v2 = { self.iterator(p, self._var) }

		if v2[1] == nil then
			return
		end

		self._var = v2[1]
		return callback(unpack(v2))
	end, self._s, self._var)
end

function v:filter(callback)
	local iter

	iter = function(p)
		local v2 = { self.iterator(p, self._var) }

		if v2[1] == nil then
			return
		end

		self._var = v2[1]

		if callback(unpack(v2)) == true then
			return unpack(v2)
		end

		return iter(p)
	end

	return v(iter, self._s, self._var)
end

function v:flatMap(p)
	local mapped = self:map(p)
	local v2 = nil
	local iter

	iter = function(p2)
		if not v2 then
			local v3 = { mapped.iterator(p2, mapped._var) }

			if not v3[1] then
				return
			end

			mapped._var = v3[1]
			v2 = v.fromArray(v3[1])
		end

		local v3 = { v2.iterator(v2._s, v2._var) }

		if v3[1] == nil then
			v2 = nil
			return iter(p2)
		end

		v2._var = v3[1]
		return unpack(v3)
	end

	return v(iter, self._s, self._var)
end

function v:ord()
	local count = 0
	return self:map(function()
		count += 1
		return count
	end)
end

function v:build()
	return self.iterator, self._s, self._var
end

function v:dict()
	local result = {}

	for k, v2 in self:build() do
		result[k] = v2
	end

	return result
end

function v:array()
	local result = {}
	local v2 = 1

	for k in self:build() do
		result[v2] = k
		v2 += 1
	end

	return result
end

function v:find(callback)
	local v2, v3, v4 = self:build()

	while true do
		local v5 = { v2(v3, v4) }

		if v5[1] == nil then
			break
		end

		if callback(unpack(v5)) then
			return unpack(v5)
		else
			v4 = v5[1]
		end
	end
end

function v:has(p)
	if self:find(p) then
		return true
	end

	return false
end

function v:forEach(callback)
	local v2, v3, v4 = self:build()

	while true do
		local v5 = { v2(v3, v4) }

		if v5[1] == nil then
			break
		end

		v4 = v5[1]
		callback(unpack(v5))
	end
end

function v:random()
	local array = self:array()

	if #array == 0 then
		return
	else
		return array[math.random(1, #array)]
	end
end

function v:sum()
	return req2.sum(self:array())
end

function v:first(p, callback)
	for k in self:build() do
		if callback(k, p) then
			p = k or p
		end
	end

	return p
end

function v:len()
	local count = 0

	for _ in self:build() do
		count += 1
	end

	return count
end

function v:max()
	return self:first(-1e999, function(p, p2)
		return p2 < p
	end)
end

function v:min()
	return self:first(1e999, function(p, p2)
		return p < p2
	end)
end

function v:sort(callback)
	local v2, v3, v4 = self:build()
	local v5 = {}

	while true do
		local v6 = { v2(v3, v4) }

		if v6[1] == nil then
			break
		end

		v4 = v6[1]
		table.insert(v5, v6)
	end

	table.sort(v5, function(a, b)
		return callback(unpack(req2.arrayMerge(a, b)))
	end)
	return v.values(v5):map(function(list)
		return unpack(list)
	end)
end

function v:next()
	local v2, v3, _ = self:build()
	local v4 = { v2(v3, self._var) }

	if v4[1] == nil then
		return
	end

	self._var = v4[1]
	return unpack(v4)
end

function v.gen(p, p2)
	return v.count(p):map(p2):dict()
end

function v.mapArr(p, p2)
	return v.fromArray(p):map(p2):dict()
end

return v