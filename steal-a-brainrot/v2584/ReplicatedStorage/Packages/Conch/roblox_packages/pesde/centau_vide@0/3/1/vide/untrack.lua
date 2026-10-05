if not game then
	local module = require("test/relative-string")
	script = module
end

local graph = require(script.Parent.graph)
local get_scope = graph.get_scope

local function untrack(callback)
	local v = get_scope()

	if not v then
		return callback()
	end

	local effect = v.effect
	v.effect = false
	local success, result = pcall(callback)
	v.effect = effect

	if not success then
		error(result, 0)
	end

	return result
end

return untrack