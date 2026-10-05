local shared = script.Parent.Parent.Parent.Shared
local React = require(shared.React)
local useStyleSheet = require(script.Parent.useStyleSheet)

local function useLayout(p: string, p2)
	local v = useStyleSheet("Layout", "string")
	return (React.useMemo(function()
		local v2 = v(p, {})
		local result = {}

		for k, v3 in v2 do
			local v4 = tonumber(k:split("-")[2])
			local layoutOrder = tonumber(k:split("-")[3])

			if not (v4 and layoutOrder) then
				continue
			end

			local v6 = v3:sub(2)

			if not result[v4] then
				result[v4] = {}
			end

			if not (v6 and p2[v6]) then
				continue
			end

			local v7 = p2[v6]
			v7.LayoutOrder = layoutOrder
			v7.props.LayoutOrder = layoutOrder
			result[v4][v6] = v7
		end

		return result
	end, { p, p2 }))
end

return useLayout