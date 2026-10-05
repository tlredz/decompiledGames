if not game then
	local module = require("test/relative-string")
	script = module
end

local graph = require(script.Parent.graph)
local create_node = graph.create_node
local assert_stable_scope = graph.assert_stable_scope
local evaluate_node = graph.evaluate_node

local function effect(callback, p)
	evaluate_node((create_node(assert_stable_scope(), callback, p)))
end

return effect