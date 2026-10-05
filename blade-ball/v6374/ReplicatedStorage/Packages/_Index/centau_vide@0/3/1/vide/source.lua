if not game then
	local module = require("test/relative-string")
	script = module
end

local graph = require(script.Parent.graph)
local create_source_node = graph.create_source_node
local push_child_to_scope = graph.push_child_to_scope
local update_descendants = graph.update_descendants

local function source(p)
	local v = create_source_node(p)
	return function(...)
		if select("#", ...) == 0 then
			push_child_to_scope(v)
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
end

return source