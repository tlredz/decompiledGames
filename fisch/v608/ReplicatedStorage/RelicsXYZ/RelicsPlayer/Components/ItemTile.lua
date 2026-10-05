local parent = script.Parent.Parent
local shared = parent.Parent.Shared
require(shared.GamePasses)
local components = parent.Components
local Button = require(components.Button)
local ItemPage = require(components.ItemPage)
local EmotePreview = require(components.EmotePreview)
local BoomboxPreview = require(components.BoomboxPreview)
local Util = require(parent.Util)
local State = require(parent.State)
local React = require(shared.React)
local hooks = parent.Hooks
local useSpring = require(hooks.useSpring)
local useRelicsAssetInfo = require(hooks.useRelicsAssetInfo)

local function ItemTile(data)
	local target = data.Target
	local target2 = type(target) == "table" and {
		RenderContext = "ItemPage",
		Type = target.Type,
		Id = target.Id
	} or target
	local v2 = useRelicsAssetInfo(target2)
	local v3 = useRelicsAssetInfo(target)
	local v4 = React.useContext(State.Context)
	local state, setState = React.useState(false)
	local v5, v6 = React.useBinding(1)
	local v7 = useSpring(v5, {
		tension = 200,
		friction = 20
	})
	local owned = v3.Owned
	local locked = v3.Locked

	if owned then
		locked = false
	end

	local image = v3.Image or ""
	local overrideBackgroundImage = data.OverrideBackgroundImage or v3.BackgroundImage
	local overrideStrokeColor = data.OverrideStrokeColor or v3.StrokeColor
	local overrideGlowImage = data.OverrideGlowImage

	if overrideGlowImage then
		overrideBackgroundImage = nil
		overrideStrokeColor = nil
	end

	local coerceImage = Util.CoerceImage(overrideBackgroundImage)
	v6(state and 0 or 1)
	local v8 = React.useCallback(function(p)
		if not p then
			return nil
		end

		local props = p.Props or {
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = 0
		}

		if coerceImage and (p.Widget == BoomboxPreview or p.Widget == EmotePreview) then
			props = table.clone(props)
			props.SkyboxImg = coerceImage
		end

		return React.createElement(p.Widget, props)
	end, { coerceImage })
	local onActivated = React.useCallback(function()
		local widget = v4.Widget
		v4.SetWidget({
			HideBackground = v2.HideBackground,
			ReturnText = v3.Title,
			ReturnFunc = function()
				v4.SetWidget(widget)
			end,
			Widget = function(props)
				return React.createElement(ItemPage, {
					Size = props.Size,
					Position = props.Position,
					AnchorPoint = props.AnchorPoint,
					ZIndex = props.ZIndex,
					Locked = v2.Locked,
					Target = target2
				})
			end
		})
	end, { v3, v2, target2 })
	local createElement = React.createElement
	local v11 = {
		[React.Tag] = Util.ClassNames("PurchaseableItem", data[React.Tag]),
		LayoutOrder = data.LayoutOrder,
		OnActivated = onActivated,
		HoverScale = 1.05,
		PressScale = 0.95,
		OnHoverStart = function()
			setState(true)
		end,
		OnHoverEnd = function()
			setState(false)
		end
	}

	if overrideGlowImage then
		overrideGlowImage = React.createElement("ImageLabel", {
			[React.Tag] = "GlowImage",
			Image = overrideGlowImage
		})
	end

	if overrideBackgroundImage then
		overrideBackgroundImage = React.createElement("ImageLabel", {
			[React.Tag] = "BackgroundImage",
			Image = overrideBackgroundImage
		})
	end

	local children = {
		GlowImage = overrideGlowImage,
		BackgroundImage = overrideBackgroundImage,
		Title = React.createElement("TextLabel", {
			[React.Tag] = "ItemTitleHeading",
			TextStrokeTransparency = v7,
			TextTransparency = v7,
			Size = v7:map(function(p: number)
				local v13 = (1 - p) / 2
				return UDim2.fromScale(v13, v13)
			end),
			Visible = v7:map(function(p: number)
				return p < 1
			end),
			Text = v3.Title,
			TextScaled = true,
			ZIndex = 100
		}),
		Image = 0,
		ButtonLabel = 0
	}
	local createElement3 = React.createElement
	local v14 = {
		[React.Tag] = "ItemImage",
		LayoutOrder = data.LayoutOrder,
		BackgroundColor3 = overrideStrokeColor,
		Image = image
	}

	if overrideStrokeColor then
		overrideStrokeColor = React.createElement("UIStroke", {
			[React.Tag] = "UIStroke",
			Color = overrideStrokeColor
		})
	end

	if owned then
		owned = React.createElement("Frame", {
			[React.Tag] = "Unlocked"
		}, {
			Checkmark = React.createElement("TextLabel", {})
		})
	end

	local createElement4 = React.createElement
	local fragment = React.Fragment
	local v17 = {
		OverrideRender = v8(data.OverrideRender),
		DefaultRender = 0
	}
	local defaultRender

	if not data.OverrideRender then
		defaultRender = v8(v3.Render)
	end

	v17.DefaultRender = defaultRender
	children.Image = createElement3("ImageLabel", v14, {
		Stroke = overrideStrokeColor,
		Unlocked = owned,
		Render = createElement4(fragment, nil, v17)
	})
	children.ButtonLabel = React.createElement("Frame", {
		[React.Tag] = "ButtonLabel"
	}, {
		Text = React.createElement("TextLabel", {
			Text = locked and "[LOCKED]" or v3.Product and not v3.Owned and "BUY" or "VIEW"
		})
	})
	return createElement(Button, v11, children)
end

return ItemTile