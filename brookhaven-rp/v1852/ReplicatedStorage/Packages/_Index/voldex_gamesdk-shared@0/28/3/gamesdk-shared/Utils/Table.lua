local Table = {}
local iterateNestedTables

iterateNestedTables = function(items, p: string, callback)
	for k, item in pairs(items) do
		if type(item) == "table" then
			iterateNestedTables(item, p .. "/" .. tostring(k), callback)
		end
	end

	callback(items, p)
end

function Table.iterateNestedTables(p, callback)
	iterateNestedTables(p, "root", callback)
end

return Table