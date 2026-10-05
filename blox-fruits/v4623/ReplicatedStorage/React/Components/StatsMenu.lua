local React = require(game.ReplicatedStorage.Packages.React)
local Spring = require(game.ReplicatedStorage.Packages.Spring)
local Footer = require(script.Footer)
local RaceBar = require(script.RaceBar)
local StatList = require(script.StatList)
local ItemInspect = require(script.ItemInspect)
local CustomAmountField = require(script.CustomAmountField)
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local Header = require(game.ReplicatedStorage.React.Components.Header)
local useIsDungeon = require(game.ReplicatedStorage.React.Hooks.useIsDungeon)
local useSpringEffect = require(game.ReplicatedStorage.React.Hooks.Animation.useSpringEffect)
require(script.Types)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState(false)
	local v = useIsDungeon()

	local function handleAction(p)
		if p.Type == "Close" then
			props.OnExit()
		end

		if props.OnAction then
			props.OnAction(p)
		end
	end

	React.useEffect(function()
		if props.IsOpen == true then
			return function() end
		end

		local v2 = true
		task.spawn(function()
			if not v2 then
				return
			end

			setState2(false)
			setState(nil)
			setState3(false)
		end)
		return function()
			v2 = false
		end
	end, { props.IsOpen ~= true })
	local ref = React.useRef(nil)
	local state4, setState4 = React.useState(props.IsOpen and "Default" or "Offscreen")
	local isOpen = props.IsOpen
	local ref2 = React.useRef(isOpen)
	ref2.current = isOpen
	useSpringEffect(isOpen and 1 or 0, Spring.new(0.85, 2, isOpen and 1 or 0), true, function(p: number, _: number)
		local current = ref.current

		if current then
			current.Visible = p > 0
			current.Position = UDim2.fromScale(0.5, 1):Lerp(UDim2.fromScale(0.5, 0.5), p)
			current.AnchorPoint = Vector2.new(0.5, p * 0.5)
		end
	end, function()
		setState4("Moving")
	end, function()
		if ref2.current then
			setState4("Default")
		else
			setState4("Offscreen")
		end
	end)
	local createElement2 = React.createElement
	local mergeFrame = RobloxTypes.mergeFrame({
		ref = ref,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Visible = false
	}, props)
	local v7 = {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.PADDING.SCALE.XS
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.NONE
		}),
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.3
		}),
		UISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(600, 600)
		}),
		Title = createElement(Header, {
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.128583),
			Text = "Stats",
			OnExit = props.OnAction and function()
				props.OnAction({
					Type = "Close"
				})
			end,
			OnHelp = function()
				setState3(not state3)
			end
		}),
		Content = 0,
		ItemInspect = 0
	}
	local v10 = {
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0, 0.128583),
		Size = UDim2.fromScale(1, 0.872533)
	}
	local customAmount

	if not v then
		customAmount = createElement(CustomAmountField, {
			Amount = state,
			OnChange = setState
		})
	end

	v7.Content = createElement("Frame", v10, {
		CustomAmount = customAmount,
		Race = createElement(RaceBar, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.0175928, 0.0534727),
			Size = UDim2.fromOffset(271, 24),
			OnClick = function()
				setState2(not state2)
			end
		}),
		Stats = createElement(StatList, {
			InvestAmount = state or 1,
			OnAction = handleAction,
			AreHintsVisible = state3,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.102605),
			Size = UDim2.fromScale(0.97456, 0.758778)
		}),
		Footer = createElement(Footer, {
			LayoutOrder = 2,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 0.122229),
			OnAction = handleAction
		})
	})
	local itemInspect

	if state2 then
		itemInspect = createElement(ItemInspect, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(1.02686, 0.511275),
			Size = UDim2.fromScale(0.39104, 0.766386),
			OnAction = handleAction
		})
	end

	v7.ItemInspect = itemInspect
	return createElement2(DrawContextProvider, {
		Context = state4
	}, {
		Menu = createElement("Frame", mergeFrame, v7)
	})
end