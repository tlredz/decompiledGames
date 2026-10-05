local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local PurchaseButtons = require(game.ReplicatedStorage.React.Components.Gacha.PurchaseButtons)
require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.ChromaticTile)
local Window = require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.Window)
local Tiles = require(script.Tiles)
local usePityTrack = require(game.ReplicatedStorage.React.Hooks.Gacha.usePityTrack)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local state, setState = React.useState(nil)
	local v = usePityTrack(props.BoxName)
	local element = createElement(Tiles, {
		Hover = state,
		Items = React.useMemo(function()
			local result = {}

			for k, item in pairs(v.Items) do
				local isNextItem = v.NextItem == item.ItemId
				local isPastItem = table.find(v.PastItems, item.ItemId) ~= nil
				table.insert(result, {
					Data = {
						Index = k,
						ItemId = item.ItemId,
						Pity = item.Pity,
						Chance = item.Chance,
						RollGuarantee = item.RollGuarantee,
						IsNextItem = isNextItem,
						IsPastItem = isPastItem
					},
					ShowPity = true,
					ShowOdds = true,
					Hovering = state
				})
			end

			return result
		end, { v, state })
	})
	local clone = table.clone(props)
	local mergeFrame = RobloxTypes.mergeFrame({}, clone)
	mergeFrame.TimeEnds = props.TimeEnds
	return createElement(Window, mergeFrame, {
		Aspect = createElement("UIAspectRatioConstraint", {
			AspectRatio = 2.5
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, 8)
		}),
		Content = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0.55),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 4
		}, {
			Tiles = createElement(React.Fragment, {}, element)
		}),
		PurchaseButtons = createElement("Frame", {
			Position = UDim2.new(0.5, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 1),
			Size = UDim2.new(1, 0, 0.12, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UIListLayout = createElement("UIListLayout", {
				Padding = CONSTANTS.SPACING.PADDING.SCALE.XXS,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Bottom
			}),
			Buttons = createElement(PurchaseButtons, {
				OnPurchase = props.OnPurchase,
				ClipCorners = true,
				DiscountBanner = {
					AnchorPoint = Vector2.new(0.3, 0.6),
					Size = UDim2.fromScale(0.371456, 0.549358)
				}
			})
		}),
		Sink = createElement("TextButton", {
			Text = "",
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = 999,
			Size = UDim2.fromScale(1, 0.83),
			[React.Event.Activated] = props.OnItemSelected,
			[React.Event.MouseEnter] = function()
				setState(true)
			end,
			[React.Event.MouseLeave] = function()
				setState(false)
			end
		})
	})
end