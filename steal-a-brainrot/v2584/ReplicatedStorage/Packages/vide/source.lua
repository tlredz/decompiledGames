local graph = require(script.Parent.graph)
local create_source_node = graph.create_source_node
local push_scope_as_child_of = graph.push_scope_as_child_of
local update_descendants = graph.update_descendants

local function source(p)
	local v = create_source_node(p)

	local function update_source(...)
		if select("#", ...) == 0 then
			push_scope_as_child_of(v)
			return v.cache
		end

		local cache = ...

		if v.cache == cache and (type(cache) ~= "table" or table.isfrozen(cache)) then
			return cache
		end

		v.cache = cache
		update_descendants(v)
		return cache
	end

	return update_source
end

return source