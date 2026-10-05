local module = require("./graph")
local create_node = module.create_node
local push_scope = module.push_scope
local pop_scope = module.pop_scope
local destroy = module.destroy
local get_scope = module.get_scope

local function branch(callback)
	local v = get_scope()

	if not v then
		error("cannot use branch() outside a stable or reactive scope", 0)
	end

	local owner = v.owner

	if not owner or owner.effect then
		error("current scope is not owned by a stable scope", 0)
	end

	local v2 = create_node(owner, false, false)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn()
		destroy(v2)
	end

	push_scope(v2)
	local v3, v4 = xpcall(callback, debug.traceback)
	pop_scope()

	if not v3 then
		fn() -- equivalent call inferred; original call site unknown
		error(`error while running branch():\n\n{v4}`, 0)
	end

	return fn, v4
end

return branch