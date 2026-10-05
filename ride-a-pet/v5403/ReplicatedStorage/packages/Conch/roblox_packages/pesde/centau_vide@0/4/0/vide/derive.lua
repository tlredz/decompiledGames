local module = require("./graph")
local create_node = module.create_node
local push_scope_as_child_of = module.push_scope_as_child_of
local assert_stable_scope = module.assert_stable_scope
local evaluate_node = module.evaluate_node

local function derive(callback)
	local v = create_node(assert_stable_scope(), callback, false)
	evaluate_node(v)
	return function()
		push_scope_as_child_of(v)
		return v.cache
	end
end

return derive