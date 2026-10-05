local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local hooks = parent.Hooks
local useUgcSkins = require(hooks.useUgcSkins)
local usePlayerData = require(hooks.usePlayerData)
local useBulkOwnership = require(hooks.useBulkOwnership)
require(parent.State)
local React = require(shared.React)
local Ownership = require(shared.Ownership)
local GamePasses = require(shared.GamePasses)
local components = parent.Components
local ItemInventory = require(components.ItemInventory)
local BoomboxPreview = require(components.BoomboxPreview)

local function GridSkins(p)
	local v = useUgcSkins()
	local v2 = usePlayerData("Unlocks/Skins")
	local v3 = React.useMemo(function()
		return Ownership.BulkGet(v)
	end, { v })
	local v4 = useBulkOwnership(v3, { v })
	local items = React.useMemo(function()
		local result = {}
		local skins

		if v2.Unlocks and v2.Unlocks.Skins then
			skins = v2.Unlocks.Skins
		end

		for k, v6 in pairs(v) do
			if p.RequireOwnership then
				local v7 = k == "Default" or (v4[k] or false)

				if (v7 or not skins or skins[k] ~= true) and not v7 then
					continue
				end
			end

			local limitedInfo = v6.LimitedInfo
			local gamePass = limitedInfo and GamePasses.FindGamePass(limitedInfo)
			result[k] = {
				Target = {
					RenderContext = "ItemTile",
					Type = "SKIN",
					Id = k
				},
				Order = v6.ItemId,
				GamePass = gamePass,
				OverrideRender = {
					Widget = BoomboxPreview,
					Props = {
						Skin = k,
						ViewportScale = 0.75
					}
				},
				OverrideGlowImage = p.RequireOwnership and "rbxassetid://91766934143856" or nil
			}
		end

		return result
	end, {
		v,
		v3,
		v4,
		v2,
		p.RequireOwnership
	})
	return React.createElement(ItemInventory, {
		[React.Tag] = p[React.Tag],
		Items = items,
		RequireOwnership = p.RequireOwnership
	})
end

return GridSkins