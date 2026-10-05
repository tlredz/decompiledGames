local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local Types = require(game.ReplicatedStorage.React.Components.PlayerProfile.Types)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local itemIdsByDebugLabel = {}

for _, v in ItemConfig.Query.select({}) do
	itemIdsByDebugLabel[v.Index.DebugLabel] = v.Index.ItemId
end

local keys = TableUtil.keys(itemIdsByDebugLabel)
table.insert(keys, 1, "NULL")
local random = Types.LoadedPlayer.random(tick() % 100000)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		quantity = UILabs.Number(1, 1, 99, 1),
		item1 = UILabs.Choose(keys, 1),
		item2 = UILabs.Choose(keys, 1),
		item3 = UILabs.Choose(keys, 1),
		item4 = UILabs.Choose(keys, 1),
		item5 = UILabs.Choose(keys, 1),
		item6 = UILabs.Choose(keys, 1)
	}
}, function(p)
	local v = {
		p.controls.item1,
		p.controls.item2,
		p.controls.item3,
		p.controls.item4,
		p.controls.item5,
		p.controls.item6,
		p.controls.quantity
	}
	local inventoryItems = React.useMemo(function()
		local result = {}

		for _, v3 in v do
			if itemIdsByDebugLabel[v3] then
				table.insert(result, {
					ItemId = itemIdsByDebugLabel[v3]
				})
			end
		end

		return result
	end, v)
	local loadedPlayer = React.useMemo(function()
		local clone = table.clone(random)
		clone.ProfileData = table.clone(clone.ProfileData)
		clone.ProfileData.ShowcaseSlot1Id = itemIdsByDebugLabel[p.controls.item1]
		clone.ProfileData.ShowcaseSlot1Quantity = p.controls.quantity
		clone.ProfileData.ShowcaseSlot2Id = itemIdsByDebugLabel[p.controls.item2]
		clone.ProfileData.ShowcaseSlot3Id = itemIdsByDebugLabel[p.controls.item3]
		clone.ProfileData.ShowcaseSlot4Id = itemIdsByDebugLabel[p.controls.item4]
		clone.ProfileData.ShowcaseSlot5Id = itemIdsByDebugLabel[p.controls.item5]
		clone.ProfileData.ShowcaseSlot6Id = itemIdsByDebugLabel[p.controls.item6]
		return clone
	end, v)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(74, 74, 74),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 0.7),
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, {
		UIPadding = createElement("UIPadding", {
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XL,
			PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.XL,
			PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.MD,
			PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.MD
		}),
		Showcase = createElement(parentModule, {
			LoadedPlayer = loadedPlayer,
			StatSelectionVisible = true,
			SetStatSelectionVisible = function(_: boolean) end,
			InventoryItems = inventoryItems,
			SetLoadedPlayer = function(...) end,
			SetSelectedStatSlotId = function(_: number) end
		})
	})
end)