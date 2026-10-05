local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local hooks = parent.Hooks
local useEmotes = require(hooks.useEmotes)
local useGamePasses = require(hooks.useGamePasses)
local useBulkOwnership = require(hooks.useBulkOwnership)
require(parent.State)
local React = require(shared.React)
local Ownership = require(shared.Ownership)
local GamePasses = require(shared.GamePasses)
local components = parent.Components
local ItemInventory = require(components.ItemInventory)

local function GridEmotes(p)
	local v = useEmotes()
	local v2 = useGamePasses()
	local v3 = React.useMemo(function()
		local result = {}

		for k, v4 in v do
			local limitedInfo = v4.LimitedInfo

			if limitedInfo then
				result[k] = v2[limitedInfo]
			end
		end

		return result
	end, { v2 })
	local v5 = useBulkOwnership((React.useMemo(function()
		return Ownership.BulkGet(v3)
	end, { v3 })))
	local items = React.useMemo(function()
		local v7 = {}
		local v8 = {}
		local configsById = {}

		for k, v9 in pairs(v) do
			if not (not p.RequireOwnership or v5[k]) then
				continue
			end

			local gamePass = GamePasses.FindGamePassFromContent(v9.Animation)
			local config = {
				Target = {
					RenderContext = "ItemTile",
					Type = "EMOTE",
					Id = k
				}
			}

			if gamePass and gamePass.IsActive and gamePass.IsFeatured and gamePass.RelicsAssetType == "EMOTE" then
				config.Order = v9.Order or 0
				config.OverrideBackgroundImage = "rbxassetid://135018381174183"
				table.insert(v7, {
					id = k,
					config = config
				})
			else
				config.Order = (v9.Order or 0) + 10000
				config.OverrideBackgroundImage = "rbxassetid://132855273143799"
				config.OverrideStrokeColor = Color3.fromRGB(80, 80, 80)
				table.insert(v8, {
					id = k,
					config = config
				})
			end
		end

		for _, v9 in pairs(v7) do
			configsById[v9.id] = v9.config
		end

		for _, v9 in pairs(v8) do
			configsById[v9.id] = v9.config
		end

		return configsById
	end, { v, v5 })
	return React.createElement(ItemInventory, {
		[React.Tag] = p[React.Tag],
		Items = items,
		RequireOwnership = p.RequireOwnership
	})
end

return GridEmotes