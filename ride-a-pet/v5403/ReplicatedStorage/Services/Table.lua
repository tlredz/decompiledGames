local Table = {}

function Table:Visualize(items, count)
	local v = count or 0
	print(string.rep("\t", v) .. "{")

	for k, item in pairs(items) do
		if typeof(item) == "table" then
			print(string.rep("\t", v + 1) .. "[" .. tostring(k) .. "]:")
			Table:Visualize(item, v + 1)
		else
			print(string.rep("\t", v + 1) .. "[" .. tostring(k) .. "]: " .. tostring(item))
		end
	end

	print(string.rep("\t", v) .. "}")
end

function Table.Jumble(_, p)
	local clone = table.clone(p)

	for i = #clone, 2, -1 do
		local v = math.random(i)
		local v2 = clone[v]
		local v3 = clone[i]
		clone[i] = v2
		clone[v] = v3
	end

	return clone
end

return Table