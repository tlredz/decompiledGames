local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local hooks = parent.Hooks
local useEmotes = require(hooks.useEmotes)
local useBulkOwnership = require(hooks.useBulkOwnership)
require(parent.State)
local React = require(shared.React)
local Ownership = require(shared.Ownership)
local GamePasses = require(shared.GamePasses)
local components = parent.Components
local ItemInventory = require(components.ItemInventory)

local function GridEmotes(p)
	local v = useEmotes()
	local v3 = useBulkOwnership((React.useMemo(function()
		return Ownership.BulkGet(v)
	end, { v })))
	local items = React.useMemo(function()
		local v5 = {}
		local v6 = {}
		local configsById = {}

		for k, v7 in pairs(v) do
			if not (not p.RequireOwnership or v3[k]) then
				continue
			end

			local gamePass = GamePasses.FindGamePassFromContent(v7.Animation)
			local config = {
				Target = {
					RenderContext = "ItemTile",
					Type = "EMOTE",
					Id = k
				}
			}

			if gamePass and gamePass.IsActive and gamePass.IsFeatured and gamePass.RelicsAssetType == "EMOTE" then
				config.Order = v7.Order or 0
				config.OverrideBackgroundImage = "rbxassetid://135018381174183"
				table.insert(v5, {
					id = k,
					config = config
				})
			else
				config.Order = (v7.Order or 0) + 10000
				config.OverrideBackgroundImage = "rbxassetid://132855273143799"
				config.OverrideStrokeColor = Color3.fromRGB(80, 80, 80)
				table.insert(v6, {
					id = k,
					config = config
				})
			end
		end

		for _, v7 in pairs(v5) do
			configsById[v7.id] = v7.config
		end

		for _, v7 in pairs(v6) do
			configsById[v7.id] = v7.config
		end

		return configsById
	end, { v, v3 })
	return React.createElement(ItemInventory, {
		[React.Tag] = p[React.Tag],
		Items = items,
		RequireOwnership = p.RequireOwnership
	})
end

return GridEmotes