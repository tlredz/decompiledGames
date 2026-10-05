local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.Spritesheets)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

function renderIcon(props, layoutOrder: number, imageColor: Color3)
	local v3 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Image = 0,
		ImageContent = 0,
		ImageColor3 = 0,
		ImageRectOffset = 0,
		ImageRectSize = 0,
		LayoutOrder = 0,
		ScaleType = 0,
		Size = 0
	}
	local image

	if typeof(props.Image) == "string" then
		image = props.Image
	end

	v3.Image = image
	local imageContent

	if typeof(props.Image) ~= "string" then
		imageContent = props.Image
	end

	v3.ImageContent = imageContent
	v3.ImageColor3 = imageColor
	v3.ImageRectOffset = props.ImageRectOffset
	v3.ImageRectSize = props.ImageRectSize
	v3.LayoutOrder = layoutOrder
	v3.ScaleType = Enum.ScaleType.Fit
	v3.Size = UDim2.fromOffset(23, 23)
	return createElement("ImageLabel", v3, {
		FlexItem = createElement("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Shrink
		})
	})
end

return function(props)
	local GREY_500

	if props.Text == nil or props.Text:len() == 0 then
		GREY_500 = CONSTANTS.COLOR.PALETTE.GREY_500
	else
		GREY_500 = CONSTANTS.COLOR.PALETTE.WHITE
	end

	local ref = React.useRef(nil)

	local function onFocusChanged(object)
		if props.OnFocusChanged then
			props.OnFocusChanged(object:IsFocused())
		end
	end

	local v = {
		AutoButtonColor = false,
		AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.XY,
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		ClipsDescendants = true,
		ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = props.Size or UDim2.fromScale(0, 0),
		[React.Event.Activated] = function()
			local current = ref.current

			if current and not current:IsFocused() then
				current:CaptureFocus()
			end
		end
	}
	local mergeImageButton = RobloxTypes.mergeImageButton(v, props)
	local v4 = {
		Outline = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = CONSTANTS.COLOR.PALETTE.BLACK,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			Transparency = CONSTANTS.ALPHA.OPAQUE
		}),
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(0, 2)
		}),
		SizeConstraint = createElement("UISizeConstraint", {
			MinSize = Vector2.new(0, 36)
		}),
		Padding = createElement("UIPadding", {
			PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.SM
		}),
		Layout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = CONSTANTS.SPACING.PADDING.OFFSET.SM,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		BeforeIcon = 0,
		TextBox = 0,
		AfterIcon = 0
	}
	local beforeIcon

	if props.BeforeIcon then
		beforeIcon = renderIcon(props.BeforeIcon, 1, GREY_500)
	end

	v4.BeforeIcon = beforeIcon
	v4.TextBox = createElement("TextBox", {
		ref = ref,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.BODY_LIGHT,
		LayoutOrder = 2,
		LineHeight = 0,
		PlaceholderColor3 = CONSTANTS.COLOR.PALETTE.GREY_500,
		PlaceholderText = props.PlaceholderText or "",
		Selectable = false,
		Text = props.Text or "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextStrokeTransparency = CONSTANTS.ALPHA.INVISIBLE,
		TextXAlignment = Enum.TextXAlignment.Left,
		[React.Change.Text] = function(p)
			p.Text = props.OnTextChanged(p.Text)
		end,
		[React.Event.Focused] = onFocusChanged,
		[React.Event.FocusLost] = onFocusChanged
	}, {
		UIPadding = createElement("UIPadding", {
			PaddingTop = CONSTANTS.SPACING.PADDING.SCALE.LG,
			PaddingBottom = CONSTANTS.SPACING.PADDING.SCALE.LG
		}),
		FlexItem = createElement("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Fill,
			ItemLineAlignment = Enum.ItemLineAlignment.Stretch
		})
	})
	local afterIcon

	if props.AfterIcon then
		afterIcon = renderIcon(props.AfterIcon, 3, GREY_500)
	end

	v4.AfterIcon = afterIcon
	return createElement("ImageButton", mergeImageButton, v4)
end