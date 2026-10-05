local React = require(game.ReplicatedStorage.Packages.React)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local MenuButton = require(script.MenuButton)
local useStatPoints = require(game.ReplicatedStorage.React.Hooks.Player.useStatPoints)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useGiftCount = require(game.ReplicatedStorage.React.Hooks.Player.useGiftCount)
local useCumulativeNewCount = require(game.ReplicatedStorage.React.Hooks.Item.useCumulativeNewCount)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Components.HUD.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

function toBadgeText(p: number?)
	if p and p > 0 then
		if p > 99 then
			return "99+"
		end

		return (`{p}`)
	else
		return nil
	end
end

return function(p)
	local v = useStatPoints() or 0
	local v2 = useCumulativeNewCount({
		Inventory = {
			Tags = {
				Operation = "NEQ",
				Value = PseudoEnum.InventoryItemTag.HasInvisibleTile
			}
		}
	})
	local v3 = useMockState("TotalNewItems", 0)

	if v3 then
		v2 = v3:get() or 0
	end

	local v4 = useGiftCount() or 0
	local state, setState = React.useState(false)
	local v5 = v4 + v2 > 0
	local v6 = v > 0
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p)
	local v9 = {
		UIGridLayout = createElement("UIGridLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			FillDirectionMaxCells = 2,
			CellPadding = UDim2.fromScale(0.025, 0.05),
			CellSize = UDim2.fromScale(0.4875, 0.475)
		}),
		Menu = 0,
		Stats = 0,
		Items = 0,
		Shop = 0
	}
	local v12 = {
		Text = state and "Close" or "Menu",
		LayoutOrder = 3
	}
	local badgeText

	if not state then
		badgeText = math.sign(v4) + math.sign(v) + math.sign(v2) > 1 and "!!" or toBadgeText(v + v2 + v4)
	end

	v12.BadgeText = badgeText
	v12.BadgeVariant = v5 and v6 and "Split" or v5 and "Blue" or "Red"

	v12[React.Event.Activated] = function()
		setState(not state)
	end

	v9.Menu = createElement(MenuButton, v12)
	local stats

	if state then
		stats = createElement(MenuButton, {
			Text = "Stats",
			LayoutOrder = 1,
			BadgeText = toBadgeText(v),
			BadgeVariant = "Red",
			[React.Event.Activated] = function()
				p.OnMenuAction({
					Type = "Navigate",
					Key = "Stats"
				})
			end
		})
	else
		stats = state
	end

	v9.Stats = stats
	local items

	if state then
		items = createElement(MenuButton, {
			Text = "Items",
			LayoutOrder = 2,
			BadgeText = toBadgeText(v2),
			BadgeVariant = "Blue",
			[React.Event.Activated] = function()
				p.OnMenuAction({
					Type = "Navigate",
					Key = "Inventory"
				})
			end
		})
	else
		items = state
	end

	v9.Items = items

	if state then
		state = createElement(MenuButton, {
			Theme = p.ShopTheme,
			Text = "Shop",
			LayoutOrder = 4,
			BadgeText = toBadgeText(v4),
			BadgeVariant = "Blue",
			BadgeAnchorPoint = Vector2.new(0.7, 0),
			BadgePosition = UDim2.fromScale(1, 0.5),
			[React.Event.Activated] = function()
				p.OnMenuAction({
					Type = "Navigate",
					Key = "Shop"
				})
			end
		})
	end

	v9.Shop = state
	return createElement("Frame", mergeFrame, v9)
end