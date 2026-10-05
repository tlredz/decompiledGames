local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.ChromaticTile)
local Window = require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.Window)
local Tiles = require(script.Tiles)
local usePityTrack = require(game.ReplicatedStorage.React.Hooks.Gacha.usePityTrack)
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
					ShowName = true,
					Hovering = state
				})
			end

			return result
		end, { v, state })
	})
	return createElement(Window, {
		TimeEnds = props.TimeEnds
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XS
		}),
		Content = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 4
		}, createElement(React.Fragment, {}, element)),
		Sink = createElement("TextButton", {
			Text = "",
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = 999,
			Size = UDim2.fromScale(1, 1),
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