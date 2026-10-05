local random = Random.new()
local table2 = table
local v = {}

function v.contains(p, p2)
	return v.indexOf(p, p2) ~= nil
end

function v.indexOf(list, p)
	local index = table.find(list, p)

	if index then
		return index
	end

	return v.keyOf(list, p)
end

function v.keyOf(items, p)
	for k, item in pairs(items) do
		if item == p then
			return k
		end
	end

	return nil
end

function v:insertAndGetIndexOf(p)
	self[#self + 1] = p
	return #self
end

function v.skip(list, p)
	return table.move(list, p + 1, #list, 1, table.create(#list - p))
end

function v.take(p, p2)
	return table.move(p, 1, p2, 1, table.create(p2))
end

function v.range(p, p2, p3)
	return table.move(p, p2, p3, 1, table.create(p3 - p2 + 1))
end

function v.skipAndTake(p, p2, p3)
	return table.move(p, p2 + 1, p2 + p3, 1, table.create(p3))
end

function v.random(list)
	return list[random:NextInteger(1, #list)]
end

function v.join(list, list2)
	local v2 = table.create(#list + #list2)
	table.move(list, 1, #list, 1, v2)
	return table.move(list2, 1, #list2, #list + 1, v2)
end

function v.removeObject(list, p)
	local index = v.indexOf(list, p)

	if index then
		table.remove(list, index)
	end
end

return (setmetatable({}, {
	__index = function(_, p)
		if v[p] == nil then
			return table2[p]
		end

		return v[p]
	end,
	__newindex = function(_, _, _)
		error("Add new table entries by editing the Module itself.")
	end
}))