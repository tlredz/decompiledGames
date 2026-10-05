local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local hooks = parent.Hooks
local useStyleSheet = require(hooks.useStyleSheet)

local function useTabOrder()
	local v, v2 = useStyleSheet("Tweaks")
	return (React.useMemo(function()
		local v4 = v("Tweak-TabOrder-Favorites", 1)
		local v5 = v("Tweak-TabOrder-Equip", 2)
		local v6 = v("Tweak-TabOrder-Settings", 3)
		local v3 = {
			[v4] = "Favorites",
			[v5] = "Equip",
			[v6] = "Settings"
		}
		local v7 = {}
		local names = {}

		for k, name in pairs(v3) do
			table.insert(v7, {
				order = k,
				name = name
			})
		end

		table.sort(v7, function(a, b)
			return a.order < b.order
		end)

		for _, v8 in ipairs(v7) do
			table.insert(names, v8.name)
		end

		return names
	end, { v2 }))
end

return useTabOrder