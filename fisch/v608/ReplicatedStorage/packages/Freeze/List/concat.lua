local None = require(script.Parent.Parent.None)
local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function concat(...)
	local v = {}
	local v2 = 1

	for i = 1, select("#", ...) do
		local v3 = select(i, ...)

		if not (v3 ~= nil and type(v3) == "table" and #v3 > 0) then
			continue
		end

		for _, v4 in ipairs(v3) do
			if v4 == None then
				continue
			end

			v[v2] = v4
			v2 += 1
		end
	end

	return maybeFreeze(v)
end

return concat