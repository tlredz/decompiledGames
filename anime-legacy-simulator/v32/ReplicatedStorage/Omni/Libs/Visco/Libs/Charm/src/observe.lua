local store = require(script.Parent.store)
local subscribe = require(script.Parent.subscribe)
require(script.Parent.types)

local function noop() end

local function observe(callback, callback2)
	local v = {}

	local function listener(items)
		for k, v2 in next, v, nil do
			if items[k] ~= nil then
				continue
			end

			v[k] = nil
			v2()
		end

		for k, item in next, items, nil do
			if not v[k] then
				v[k] = callback2(item, k) or noop
			end
		end
	end

	local v2 = subscribe(callback, listener)
	store.peek(function()
		listener(callback())
	end)
	return function()
		v2()

		for _, v3 in next, v, nil do
			v3()
		end

		table.clear(v)
	end
end

return observe