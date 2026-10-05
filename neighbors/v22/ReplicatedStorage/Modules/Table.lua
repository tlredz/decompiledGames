local random = Random.new()
local Table = {}

function Table:shuffle()
	for i = #self, 1, -1 do
		local v = math.random(i)
		local v2 = self[i]
		self[i] = self[v]
		self[v] = v2
	end

	return self
end

function Table.iter_backwards(list, _: number?)
	local v = #list + 1
	return function()
		v -= 1

		if v > 0 then
			return v, list[v]
		end

		return nil
	end
end

function Table.pick_random(list)
	return list[random:NextInteger(1, #list)]
end

function Table.remove_value(list, p)
	local index = table.find(list, p)

	if index then
		table.remove(list, index)
	end
end

function Table.count(items)
	local count = 0

	for _, _ in next, items, nil do
		count += 1
	end

	return count
end

return Table