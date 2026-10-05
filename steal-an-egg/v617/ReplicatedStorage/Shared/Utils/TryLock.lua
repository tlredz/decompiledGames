local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function isEngaged(p, p2: number?)
	local v = object[p]
	return v ~= nil and (p2 == nil or os.clock() - v.Since < p2)
end

local function conclude(p, p2, flag: boolean, ...)
	if object[p] == p2 then
		object[p] = nil
	end

	if flag then
		return true, ...
	end

	error(..., 0)
end

return function(p: number?)
	local v = {}
	return function(callback, ...)
		-- equivalent call inferred; original call site unknown
		if isEngaged(v, p) then
			return false
		end

		local v3 = {
			Since = os.clock()
		}
		object[v] = v3
		return conclude(v, v3, pcall(callback, ...))
	end
end