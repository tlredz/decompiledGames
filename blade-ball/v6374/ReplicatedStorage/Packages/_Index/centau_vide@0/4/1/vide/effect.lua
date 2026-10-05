local module = require("./graph")
local create_node = module.create_node
local assert_stable_scope = module.assert_stable_scope
local evaluate_node = module.evaluate_node

local function effect(callback, p)
	evaluate_node((create_node(assert_stable_scope(), callback, p)))
end

return effect