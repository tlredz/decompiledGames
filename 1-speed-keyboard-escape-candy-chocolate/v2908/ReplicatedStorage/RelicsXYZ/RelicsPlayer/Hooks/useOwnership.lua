local parent = script.Parent
local useBulkOwnership = require(parent.useBulkOwnership)

local function useOwnership(p, p2)
	local v = useBulkOwnership(p, p2)
	local count = 0

	for _, v2 in pairs(v) do
		if v2 then
			count += 1
		end
	end

	return count > 0, count
end

return useOwnership