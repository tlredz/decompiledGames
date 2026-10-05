local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(script.Parent.Parent.Parent.Parent.Types)
local FactChip = require(script.FactChip)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local selectionAlpha = props.SelectionAlpha
	local facts = props.Facts
	local chipTransparency = props.ChipTransparency
	local chipBackgroundColor3 = props.ChipBackgroundColor3
	local v = React.useMemo(function()
		local result = {}

		for _, fact in pairs(facts) do
			if fact.Text then
				result[fact] = fact.Text:len() * selectionAlpha + 4 + (fact.Icon and 5 or 0)
			end
		end

		return result
	end, { facts, selectionAlpha })
	local v2 = React.useMemo(function()
		local total = 0

		for _, v3 in pairs(v) do
			total += v3
		end

		return total
	end, { v })
	local v3 = React.useMemo(function()
		local clone = table.clone(facts)
		table.sort(clone, function(a, b)
			return v[a] > v[b]
		end)
		return clone
	end, { v })
	local v4 = React.useMemo(function()
		local total = 0
		local result = {}

		for _, v5 in ipairs(v3) do
			if total >= 27 then
				return result
			end

			total += v[v5]
			table.insert(result, v5)
		end

		return result
	end, { v3, v, v2 })
	local v5 = React.useMemo(function()
		local result = {}

		for i = #v4 + 1, #v3 do
			table.insert(result, v3[i])
		end

		return result
	end, { v3, v4 })
	local v6 = useSpring(#v5 / math.max(#facts, 1), #v5 > 0 and 1 or 0, 2, 10)
	local children = {}

	for i, fact in ipairs(v4) do
		children[`Fact{i}`] = createElement(FactChip, {
			LayoutOrder = i,
			BackgroundColor3 = chipBackgroundColor3,
			BackgroundTransparency = chipTransparency,
			SelectionAlpha = selectionAlpha,
			Fact = fact
		})
	end

	local children2 = {}

	for i, fact in ipairs(v5) do
		children2[`Fact{i}`] = createElement(FactChip, {
			LayoutOrder = i,
			BackgroundColor3 = chipBackgroundColor3,
			BackgroundTransparency = chipTransparency,
			SelectionAlpha = selectionAlpha,
			Fact = fact
		})
	end

	local mergeGuiObject = RobloxTypes.mergeGuiObject({}, props)
	local uIListLayout

	if #facts ~= 0 then
		uIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = CONSTANTS.SPACING.PADDING.NONE,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Wraps = false
		})
	end

	local topFacts

	if #facts ~= 0 then
		topFacts = createElement("Frame", {
			LayoutOrder = 1,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 1 - 0.5 * selectionAlpha)
		}, {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Wraps = false
			}),
			Facts = createElement(React.Fragment, {}, children)
		})
	end

	local bottomFacts

	if v6 > 0 or #facts == 0 then
		bottomFacts = createElement("Frame", {
			LayoutOrder = 2,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(1, 0.5 * selectionAlpha * v6)
		}, {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Wraps = false
			}),
			Facts = createElement(React.Fragment, {}, children2)
		})
	end

	return createElement("Frame", mergeGuiObject, {
		UIListLayout = uIListLayout,
		TopFacts = topFacts,
		BottomFacts = bottomFacts
	})
end