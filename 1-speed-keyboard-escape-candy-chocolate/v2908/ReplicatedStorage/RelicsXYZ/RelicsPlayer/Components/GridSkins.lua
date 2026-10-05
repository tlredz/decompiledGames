local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local hooks = parent.Hooks
local useUgcSkins = require(hooks.useUgcSkins)
local useGamePasses = require(hooks.useGamePasses)
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
	local v2 = useGamePasses()
	local v3 = usePlayerData("Unlocks/Skins")
	local v4 = React.useMemo(function()
		local result = {}

		for k, v5 in v do
			local limitedInfo = v5.LimitedInfo

			if limitedInfo then
				result[k] = v2[limitedInfo]
			end
		end

		return result
	end, { v2 })
	local v5 = React.useMemo(function()
		return Ownership.BulkGet(v4)
	end, { v4 })
	local v6 = useBulkOwnership(v5, { v })
	local items = React.useMemo(function()
		local result = {}
		local skins

		if v3.Unlocks and v3.Unlocks.Skins then
			skins = v3.Unlocks.Skins
		end

		for k, v8 in pairs(v) do
			if p.RequireOwnership then
				local v9 = k == "Default" or (v6[k] or false)

				if (v9 or not skins or skins[k] ~= true) and not v9 then
					continue
				end
			end

			local limitedInfo = v8.LimitedInfo
			local gamePass = limitedInfo and GamePasses.FindGamePass(limitedInfo)
			result[k] = {
				Target = {
					RenderContext = "ItemTile",
					Type = "SKIN",
					Id = k
				},
				Order = v8.ItemId,
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
		v5,
		v6,
		v3,
		p.RequireOwnership
	})
	return React.createElement(ItemInventory, {
		[React.Tag] = p[React.Tag],
		Items = items,
		RequireOwnership = p.RequireOwnership
	})
end

return GridSkins