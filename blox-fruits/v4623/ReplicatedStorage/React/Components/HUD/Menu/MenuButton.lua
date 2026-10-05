local React = require(game.ReplicatedStorage.Packages.React)
local Badge = require(game.ReplicatedStorage.React.Components.Badge)
local NotifyMark = require(game.ReplicatedStorage.React.Components.HUD.NotifyMark)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Components.HUD.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local vector = Vector2.new(0.7, 0.4)
local uDim = UDim2.fromScale(1, 0)
local uDim2 = UDim2.fromScale(0.75, 0.75)
local createElement = React.createElement
local require2 = require
return function(props)
	local v = React.useMemo(function()
		if not props.Theme then
			return
		end

		local child = script.Themes:FindFirstChild(props.Theme)

		if child then
			return require2(child)
		end

		warn((`unknown theme "{props.Theme}"`))
	end, { props.Theme })
	local mergeTextButton = RobloxTypes.mergeTextButton({
		BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	}, props)
	local v4 = {
		Trans = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.new(1, -4, 0.4, 0)
		}),
		TextLabel = createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
			Size = UDim2.fromScale(1, 1),
			Text = props.Text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		Theme = v and createElement(v, {
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}) or nil,
		Notify = 0,
		Badge = 0,
		UIStroke = 0
	}
	local notify

	if props.NotifyText then
		notify = createElement(NotifyMark, {
			Position = UDim2.fromScale(0.8, -0.5),
			Size = UDim2.fromScale(0.3, 1.1),
			Text = props.NotifyText
		}) or nil
	end

	v4.Notify = notify
	local badge

	if props.BadgeText then
		badge = createElement(Badge, {
			AnchorPoint = props.BadgeAnchorPoint or vector,
			Position = props.BadgePosition or uDim,
			Size = uDim2,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Text = props.BadgeText,
			Variant = props.BadgeVariant or "Red",
			ZIndex = 4
		})
	end

	v4.Badge = badge
	v4.UIStroke = createElement("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color3.fromRGB(156, 96, 0),
		LineJoinMode = Enum.LineJoinMode.Miter,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		Thickness = 0.04
	})
	return createElement("TextButton", mergeTextButton, v4)
end