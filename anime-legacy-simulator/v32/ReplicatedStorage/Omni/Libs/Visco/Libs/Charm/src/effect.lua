local store = require(script.Parent.store)

local function effect(callback)
	local v = {}
	local v2 = nil
	local flag = false
	local disconnect
	local listener

	listener = function()
		if v2 then
			v2()
		end

		store.disconnect(v, listener)
		v, v2 = store.capture(callback, disconnect)

		if not flag then
			store.connect(v, listener)
		end
	end

	disconnect = function()
		if flag then
			return
		end

		flag = true
		store.disconnect(v, listener)

		if v2 then
			v2()
		end
	end

	v, v2 = store.capture(callback, disconnect)

	if not flag then
		store.connect(v, listener)
	end

	return disconnect
end

return effect