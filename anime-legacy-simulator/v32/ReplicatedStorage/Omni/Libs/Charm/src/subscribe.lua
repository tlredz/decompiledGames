local store = require(script.Parent.store)
require(script.Parent.types)

local function subscribe(p, callback)
	local capture, v = store.capture(p)
	local v2 = false
	local handler

	handler = function()
		local v3 = v
		store.disconnect(capture, handler)
		capture, v = store.capture(p)

		if not v2 then
			store.connect(capture, handler)
		end

		if v ~= v3 then
			callback(v, v3)
		end
	end

	store.connect(capture, handler)
	return function()
		if not v2 then
			v2 = true
			store.disconnect(capture, handler)
		end
	end
end

return subscribe