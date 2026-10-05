local parent = script.Parent.Parent
local External = require(parent.External)

local function merge(flag: boolean, p, ...)
	local v = { ... }

	if #v < 1 then
		return p
	end

	for _, v2 in v do
		for k, v3 in v2 do
			if p[k] == nil then
				p[k] = v3
			elseif not flag then
				External.logError("mergeConflict", nil, (tostring(k)))
			end
		end
	end

	return p
end

return merge