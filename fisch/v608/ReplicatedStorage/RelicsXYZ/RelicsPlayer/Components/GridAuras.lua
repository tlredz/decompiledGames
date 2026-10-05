local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local Ownership = require(shared.Ownership)
local GamePasses = require(shared.GamePasses)
require(parent.State)
local React = require(shared.React)
local components = parent.Components
local ItemInventory = require(components.ItemInventory)
local hooks = parent.Hooks
local useAuras = require(hooks.useAuras)
local useAuraData = require(hooks.useAuraData)
local useBulkOwnership = require(hooks.useBulkOwnership)

local function GridAuras(p)
	local v = useAuras()
	local v2 = useAuraData()
	local v4 = useBulkOwnership(React.useMemo(function()
		return Ownership.BulkGet(v)
	end, { v }), { v })
	local items = React.useMemo(function()
		local result = {}

		for k, v6 in pairs(v) do
			if not (v4[k] or not p.RequireOwnership) then
				continue
			end

			local limitedInfo = v6.LimitedInfo
			local gamePass = limitedInfo and GamePasses.FindGamePass(limitedInfo)
			local v8 = {
				Target = {
					RenderContext = "ItemTile",
					Type = "AURA",
					Id = k
				},
				Order = (1 - v6.Chance) * 1000000,
				GamePass = gamePass,
				OverrideGlowImage = p.RequireOwnership and "rbxassetid://110514908008860" or nil,
				OverrideBackgroundImage = not p.RequireOwnership and "rbxassetid://127812013490839" or nil,
				OverrideStrokeColor = 0
			}
			local overrideStrokeColor

			if not p.RequireOwnership then
				overrideStrokeColor = Color3.fromHex("#68C2B3")
			end

			v8.OverrideStrokeColor = overrideStrokeColor
			result[k] = v8
		end

		return result
	end, { v, v2, v4 })
	return React.createElement(ItemInventory, {
		[React.Tag] = p[React.Tag],
		Items = items,
		RequireOwnership = p.RequireOwnership
	})
end

return GridAuras