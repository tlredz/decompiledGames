local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local hooks = parent.Hooks
local usePlaylists = require(hooks.usePlaylists)
require(parent.State)
local React = require(shared.React)
local GamePasses = require(shared.GamePasses)
local components = parent.Components
local ItemInventory = require(components.ItemInventory)

local function GridPlaylists(p)
	local v = usePlaylists()
	local items = React.useMemo(function()
		local v3 = {}
		local v4 = {}
		local configsById = {}

		for _, v5 in pairs(v) do
			local name = v5.Name
			local productId = v5.ProductId
			local v6 = productId and GamePasses.FindGamePassFromProductId(productId)
			local config = {
				Target = {
					RenderContext = "ItemTile",
					Type = "PLAYLIST",
					Id = name
				}
			}

			if v6 and v6.IsActive and v6.IsFeatured and v6.RelicsAssetType == "PLAYLIST" then
				config.Order = v5.SortPriority or 0
				table.insert(v3, {
					id = name,
					config = config
				})
			else
				config.Order = (v5.SortPriority or 0) + 10000
				config.OverrideStrokeColor = Color3.fromRGB(80, 80, 80)
				table.insert(v4, {
					id = name,
					config = config
				})
			end
		end

		for _, v5 in pairs(v3) do
			configsById[v5.id] = v5.config
		end

		for _, v5 in pairs(v4) do
			configsById[v5.id] = v5.config
		end

		return configsById
	end, { v })
	return React.createElement(ItemInventory, {
		[React.Tag] = p[React.Tag],
		Items = items,
		RequireOwnership = p.RequireOwnership
	})
end

return GridPlaylists