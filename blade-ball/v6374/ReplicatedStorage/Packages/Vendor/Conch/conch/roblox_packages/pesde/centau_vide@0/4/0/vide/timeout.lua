local v = {}

local function timeout(p: number, fn)
	local v2 = {
		t = p,
		fn = fn,
		cancel = false
	}
	table.insert(v, v2)
	return v2
end

local function update_timeouts(p: number)
	for i = #v, 1, -1 do
		local v2 = v[i]
		v2.t -= p

		if not (v2.cancel or v2.t <= 0) then
			continue
		end

		v[i] = v[#v]
		v[#v] = nil

		if not v2.cancel then
			v2.fn()
		end
	end
end

return function()
	return timeout, update_timeouts
end