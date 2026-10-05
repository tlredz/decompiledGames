local frozen = table.freeze({})

local function is_action(p)
	return getmetatable(p) == frozen
end

local function action(callback, value: number?)
	local v = {
		priority = value or 1,
		callback = callback
	}
	setmetatable(v, frozen)
	return table.freeze(v)
end

return function()
	return action, is_action
end