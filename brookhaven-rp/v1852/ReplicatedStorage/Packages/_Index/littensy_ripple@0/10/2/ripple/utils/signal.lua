local module = require("./spawn")

local function signal()
	local v = {}
	local v2 = 0

	local function subscribe(callback)
		table.insert(v, callback)
		v2 += 1
		return function()
			local index = table.find(v, callback)

			if index then
				v[index] = v[v2]
				v[v2] = nil
				v2 -= 1
			end
		end
	end

	local function fire(...)
		for i = v2, 1, -1 do
			module(v[i], ...)
		end
	end

	return subscribe, fire
end

return signal