local random = Random.new()
local Table = {}

for k, v in pairs(table) do
	Table[k] = v
end

function Table.contains(p, p2)
	return Table.indexOf(p, p2) ~= nil
end

function Table.indexOf(list, p)
	local index = table.find(list, p)

	if index then
		return index
	end

	return Table.keyOf(list, p)
end

function Table.keyOf(items, p)
	for k, item in pairs(items) do
		if item == p then
			return k
		end
	end

	return nil
end

function Table.skip(list, p)
	return table.move(list, p + 1, #list, 1, table.create(#list - p))
end

function Table.take(p, p2)
	return table.move(p, 1, p2, 1, table.create(p2))
end

function Table.range(p, p2, p3)
	return table.move(p, p2, p3, 1, table.create(p3 - p2 + 1))
end

function Table.skipAndTake(p, p2, p3)
	return table.move(p, p2 + 1, p2 + p3, 1, table.create(p3))
end

function Table.random(list)
	return list[random:NextInteger(1, #list)]
end

function Table.join(list, list2)
	local v = table.create(#list + #list2)
	return table.move(list2, 1, #list2, #list + 1, v)
end

function Table.removeObject(list, p)
	local index = Table.indexOf(list, p)

	if index then
		table.remove(list, index)
	end
end

function Table.expand(list, p)
	if p < 0 then
		error("Cannot expand a table by a negative amount of objects.")
	end

	local result = table.create(#list + p)

	for i = 1, #list do
		result[i] = list[i]
	end

	return result
end

return Table