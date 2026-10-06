local module = require("./graph")
local get_scope = module.get_scope

local function untrack(callback)
	local v = get_scope()

	if not v then
		return callback()
	end

	local effect = v.effect
	v.effect = false
	local v2, v3 = xpcall(callback, debug.traceback)
	v.effect = effect

	if not v2 then
		error(v3, 0)
	end

	return v3
end

return untrack