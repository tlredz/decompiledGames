local module = require("./graph")
local create_node = module.create_node
local push_scope = module.push_scope
local pop_scope = module.pop_scope
local destroy = module.destroy
local v = {}

local function root(callback)
	local v2 = create_node(false, false, false)
	v[v2] = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn()
		if not v[v2] then
			error("root already destroyed")
		end

		v[v2] = nil
		destroy(v2)
	end

	push_scope(v2)
	local v3 = { xpcall(callback, debug.traceback, fn) }
	pop_scope()

	if not v3[1] then
		fn() -- equivalent call inferred; original call site unknown
		error(`error while running root():\n\n{v3[2]}`, 0)
	end

	return fn, unpack(v3, 2)
end

return root