local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.Components.StatsMenu.Types)
local StatRow = require(script.StatRow)
local useLevels = require(game.ReplicatedStorage.React.Hooks.Player.Stats.useLevels)
local useMasteryBoosts = require(game.ReplicatedStorage.React.Hooks.Player.Stats.useMasteryBoosts)
local useLocks = require(game.ReplicatedStorage.React.Hooks.Player.Stats.useLocks)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = require(game.ReplicatedStorage.React.Components.StatsMenu.CONSTANTS)
local STATS = CONSTANTS2.STATS
local createElement = React.createElement
return function(props)
	local v = useLevels()
	local v2 = useMasteryBoosts()
	local v3 = useLocks()
	local children = {}

	for k, v4 in STATS do
		local clone

		if v4.LayoutOrder == nil then
			clone = table.clone(v4)
			clone.LayoutOrder = k
		else
			clone = v4
		end

		children[v4.Key] = createElement(StatRow, {
			Stat = clone,
			Level = v[v4.Key],
			Size = UDim2.fromScale(1, 0.17434),
			MasteryBoost = v2[v4.Key],
			IsLocked = v3[v4.Key],
			InvestAmount = props.InvestAmount,
			AreHintsVisible = props.AreHintsVisible,
			AreQuickButtonsVisible = props.AreQuickButtonsVisible,
			OnAction = props.OnAction
		})
	end

	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		SelectionGroup = true
	}, props), {
		UIPadding = createElement("UIPadding", {
			PaddingLeft = CONSTANTS.SPACING.PADDING.SCALE.XXS,
			PaddingTop = CONSTANTS.SPACING.PADDING.SCALE.XXS
		}),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Wraps = true
		}),
		Rows = createElement(React.Fragment, {}, children)
	})
end