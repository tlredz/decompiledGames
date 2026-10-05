local React = require(game.ReplicatedStorage.Packages.React)
local Button = require(script.Parent.Parent.Button)
local useLevelCap = require(game.ReplicatedStorage.React.Hooks.Player.useLevelCap)
local useStrictLerp = require(game.ReplicatedStorage.React.Hooks.Animation.useStrictLerp)
local useIsDungeon = require(game.ReplicatedStorage.React.Hooks.useIsDungeon)
require(game.ReplicatedStorage.React.Components.StatsMenu.Types)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local uDim = UDim.new(0.07, 0)
local createElement = React.createElement
return function(props)
	local stat = props.Stat
	local isLocked = props.IsLocked == true
	local v = useLevelCap()
	local v2 = useIsDungeon()
	local v3 = not isLocked and props.Level and props.Level < v
	local text

	if props.MasteryBoost and props.MasteryBoost > 0 then
		text = `Lv. <b>{props.Level}</b> (+{props.MasteryBoost} Mas.)`
	else
		text = `Lv. <b>{props.Level}</b>`
	end

	if props.Level and v <= props.Level then
		text ..= " (MAX)"
	end

	local state, setState = React.useState(Enum.GuiState.Idle)
	local v5 = useStrictLerp(
		state == Enum.GuiState.Idle and 0 or 1,
		state == Enum.GuiState.Idle and 0 or 1,
		0.1,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	)
	local v6 = v5 * 0.025
	local v10 = RobloxTypes.mergeFrame({
		Active = true,
		Selectable = true,
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		LayoutOrder = stat.LayoutOrder,
		[React.Change.GuiState] = function(p)
			setState(p.GuiState)
		end
	}, props)
	local v11 = {
		UICorner = createElement("UICorner", {
			CornerRadius = uDim
		}),
		UIStroke = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
		}),
		ColorFade = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = stat.FadeColor,
			BackgroundTransparency = CONSTANTS.ALPHA.FAINT,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.BASE
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = uDim
			}),
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.25 * (1 - v5)),
					NumberSequenceKeypoint.new(0.466999, 1 - 0.1 * v5),
					NumberSequenceKeypoint.new(0.843088, 1 - 0.1 * v5),
					NumberSequenceKeypoint.new(1, 0.25 * (1 - v5))
				})
			})
		}),
		Left = 0,
		Right = 0
	}
	local fragment = React.Fragment
	local v14 = {
		Icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = stat.Icon.Image,
			ImageRectOffset = stat.Icon.ImageRectOffset,
			ImageRectSize = stat.Icon.ImageRectSize,
			Position = UDim2.fromScale(0.01, 0.5 - v6),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.0732121, 0.872913),
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		Info = 0
	}
	local v17 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.09, 0 - v6),
		Size = UDim2.fromScale(0.432294, 0.993869)
	}
	local v18 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = CONSTANTS.SPACING.PADDING.NONE
		}),
		UIPadding = createElement("UIPadding", {
			PaddingLeft = UDim.new(0.007, 0),
			PaddingBottom = CONSTANTS.SPACING.PADDING.SCALE.LG
		}),
		Name = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			Position = UDim2.fromScale(0.007, 0.32),
			Size = UDim2.fromScale(0.864, 0.66),
			Text = stat.Name,
			TextColor3 = stat.NameColor,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1
		}, {
			UIStroke = createElement("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.04
			})
		}),
		Description = 0
	}
	local description

	if props.AreHintsVisible then
		description = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC),
			Position = UDim2.fromScale(0.00664452, 0.741379),
			Size = UDim2.fromScale(1.1116, 0.310345),
			Text = stat.Description,
			TextColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 2
		}) or nil
	end

	v18.Description = description
	v14.Info = createElement("Frame", v17, v18)
	v11.Left = createElement(fragment, {}, v14)
	local v22 = {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(1, 0.5 - v6),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false
	}
	local v23 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0.025, 0)
		}),
		UIPadding = createElement("UIPadding", {
			PaddingRight = UDim.new(0.015, 0)
		}),
		Level = 0,
		LockedIcon = 0,
		InvestmentButton = 0
	}
	local v26 = {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC),
		Position = UDim2.fromScale(0.812275, 0.5),
		RichText = true,
		Size = 0,
		Text = 0,
		TextColor3 = 0,
		TextScaled = true,
		TextXAlignment = 0,
		Visible = 0,
		LayoutOrder = 1
	}
	local size

	if props.MasteryBoost then
		size = UDim2.fromScale(0.489811, 0.6)
	else
		size = UDim2.fromScale(0.372232, 0.6)
	end

	v26.Size = size
	v26.Text = text
	v26.TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	v26.TextXAlignment = Enum.TextXAlignment.Right
	v26.Visible = not isLocked
	v23.Level = createElement("TextLabel", v26, {
		UIStroke = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.04
		})
	})
	local lockedIcon

	if isLocked then
		lockedIcon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://99266539906486",
			ImageColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
			Position = UDim2.fromScale(0.98, 0.4675),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.0529098, 0.682708)
		})
	end

	v23.LockedIcon = lockedIcon
	local investmentButton

	if not (isLocked or v2) then
		investmentButton = createElement(Button, {
			AnchorPoint = Vector2.new(1, 0.5),
			Label = `+{props.InvestAmount}`,
			LabelSize = UDim2.fromScale(0.95, 0.85),
			LayoutOrder = 999,
			Position = UDim2.fromScale(0.985, 0.500001),
			Size = UDim2.fromScale(0.151991, 0.672056),
			Variant = v3 and "Yellow" or "Grey",
			Interactable = v3,
			AutoButtonColor = v3,
			Active = v3,
			IsSelectable = v3,
			[React.Event.Activated] = v3 and function()
				props.OnAction({
					Type = "Invest",
					StatKey = stat.Key,
					Amount = props.InvestAmount
				})
			end or nil
		}) or nil
	end

	v23.InvestmentButton = investmentButton
	v11.Right = createElement("Frame", v22, v23)
	return createElement("Frame", v10, v11)
end