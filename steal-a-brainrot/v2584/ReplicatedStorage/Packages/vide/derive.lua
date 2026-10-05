local graph = require(script.Parent.graph)
local create_node = graph.create_node
local push_scope_as_child_of = graph.push_scope_as_child_of
local assert_stable_scope = graph.assert_stable_scope
local evaluate_node = graph.evaluate_node

local function derive(callback)
	local v = create_node(assert_stable_scope(), callback, false)
	evaluate_node(v)
	return function()
		push_scope_as_child_of(v)
		return v.cache
	end
end

return derive