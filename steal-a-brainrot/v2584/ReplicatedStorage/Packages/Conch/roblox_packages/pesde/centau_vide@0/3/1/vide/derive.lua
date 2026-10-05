if not game then
	local module = require("test/relative-string")
	script = module
end

local graph = require(script.Parent.graph)
local create_node = graph.create_node
local push_child_to_scope = graph.push_child_to_scope
local assert_stable_scope = graph.assert_stable_scope
local evaluate_node = graph.evaluate_node

local function derive(callback)
	local v = create_node(assert_stable_scope(), callback, false)
	evaluate_node(v)
	return function()
		push_child_to_scope(v)
		return v.cache
	end
end

return derive