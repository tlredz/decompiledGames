local function createSignal()
	local v = {}
	local v2 = {}
	local v3 = false

	local function subscribe(callback)
		assert(typeof(callback) == "function", "Can only subscribe to signals with a function.")
		local v4 = {
			callback = callback,
			disconnected = false
		}

		if v3 and not v[callback] then
			v2[callback] = v4
		end

		v[callback] = v4

		local function disconnect()
			assert(not v4.disconnected, "Listeners can only be disconnected once.")
			v4.disconnected = true
			v[callback] = nil
			v2[callback] = nil
		end

		return disconnect
	end

	local function fire(...)
		v3 = true

		for k, v4 in v do
			if not (v4.disconnected or v2[k]) then
				k(...)
			end
		end

		v3 = false
		table.clear(v2)
	end

	return subscribe, fire
end

return createSignal