local atom = require(script.Parent.atom)
local store = require(script.Parent.store)
local subscribe = require(script.Parent.subscribe)
require(script.Parent.types)

local function mapped(callback, callback2)
	local current2 = atom({})
	local object = setmetatable({
		current = current2
	}, {
		__mode = "v"
	})
	local v2 = {}
	local v3 = nil

	local function listener(items)
		local current = object.current

		if not current then
			return v3()
		end

		local clone = table.clone(current())
		local v4 = {}

		for k, item in next, items, nil do
			local v5, v6 = callback2(item, k)

			if v6 == nil then
				v6 = k
			end

			if clone[v6] == v5 then
				v4[v6] = k
			else
				clone[v6] = v5
			end
		end

		for k in next, v2, nil do
			if v4[k] == nil and clone[k] == v2[k] then
				clone[k] = nil
			end
		end

		v2 = clone
		current(clone)
	end

	v3 = subscribe(callback, listener)
	store.peek(function()
		listener(callback())
	end)
	return current2
end

return mapped