local parent = script.Parent
local useBundles = require(parent.useBundles)
local shared = parent.Parent.Parent.Shared
local React = require(shared.React)
require(shared.Bundles)

local function useActiveBundle()
	local v = useBundles()
	return (React.useMemo(function()
		local v2 = nil

		for _, v3 in v do
			if not v3.IsActive then
				continue
			end

			if v2 then
				if v3.IsFeatured == v2.IsFeatured then
					local sort = v2.Sort or 1e999
					local sort2 = v3.Sort or 1e999

					if sort2 == sort then
						if (v2.Name or "") > (v3.Name or "") then
							v2 = v3
						end
					elseif sort2 < sort then
						v2 = v3
					end
				elseif v3.IsFeatured then
					v2 = v3
				end
			else
				v2 = v3
			end
		end

		return v2
	end, { v }))
end

return useActiveBundle