require(script.Parent.Types)
local Config = require(script.Parent.Config)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local AlertBubble = require(script.Parent.Parent.ReactComponents.AlertBubble)
local BASE_TRACKER_SIZE = Config.BASE_TRACKER_SIZE
local EDGE_INDICATOR_SIZE = Config.EDGE_INDICATOR_SIZE
local DEFAULT_ALERT_ICON_SETTINGS = Config.DEFAULT_ALERT_ICON_SETTINGS
local VIEWPORT_FRAME_SIZE = Config.VIEWPORT_FRAME_SIZE
local ICON_BACKGROUND_IMAGE_OFFSET = Config.ICON_BACKGROUND_IMAGE_OFFSET
local ICON_BACKGROUND_VIEWPORT_SIZE = Config.ICON_BACKGROUND_VIEWPORT_SIZE

-- equivalent calls inferred from this helper; original call sites unknown
local function setGuiPassive(p)
	p.Active = false
	p.Interactable = false
end

local function createAlertBubble(parent, name: string, udim: UDim2, udim2: UDim2, flag: boolean, zIndex: number)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	setGuiPassive(frame) -- equivalent call inferred; original call site unknown
	frame.Parent = parent
	local binding, setVisible = React.createBinding(false)
	local binding2, setPosition = React.createBinding(udim)
	local binding3, setArrowPosition = React.createBinding(UDim2.fromScale(0.0100003, 0.5))
	local binding4, setArrowAngle = React.createBinding(0)
	local binding5, setArrowVisible = React.createBinding(flag)
	local root = ReactRoblox.createRoot(frame)

	local function render(props)
		local v6

		if props.Sprite then
			v6 = Spritesheets.MAP[props.Sprite]
		end

		local createElement = React.createElement
		local v9 = {
			Position = binding2,
			Size = udim2,
			ZIndex = zIndex,
			Visible = binding,
			ShowArrow = binding5,
			ArrowPosition = binding3,
			ArrowAngle = binding4,
			Icon = 0,
			IconRectOffset = 0,
			IconRectSize = 0,
			IconColor = 0,
			BackgroundColor = 0,
			BorderColor = 0,
			TextFrontColor = 0
		}
		local icon

		if v6 then
			icon = v6.Image
		else
			icon = props.Icon
		end

		v9.Icon = icon
		local iconRectOffset

		if v6 then
			iconRectOffset = v6.ImageRectOffset
		end

		v9.IconRectOffset = iconRectOffset
		local iconRectSize

		if v6 then
			iconRectSize = v6.ImageRectSize
		end

		v9.IconRectSize = iconRectSize
		v9.IconColor = props.ImageColor
		v9.BackgroundColor = props.BackgroundColor
		v9.BorderColor = props.BorderColor
		v9.TextFrontColor = props.Color
		root:render(createElement(AlertBubble, v9))
	end

	render(DEFAULT_ALERT_ICON_SETTINGS)
	return {
		Host = frame,
		Root = root,
		Render = render,
		SetVisible = setVisible,
		SetPosition = setPosition,
		SetArrowPosition = setArrowPosition,
		SetArrowAngle = setArrowAngle,
		SetArrowVisible = setArrowVisible
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createEdgeIndicator(parent, p)
	return (createAlertBubble(
		parent,
		`EdgeIndicatorHost_{p}`,
		UDim2.fromOffset(0, 0),
		UDim2.fromOffset(EDGE_INDICATOR_SIZE, EDGE_INDICATOR_SIZE),
		true,
		20
	))
end

local TrackerUi = {}

function TrackerUi.create(parent, p)
	local frame = Instance.new("Frame")
	frame.Name = `TrackerFrame_{p}`
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromOffset(BASE_TRACKER_SIZE.X, BASE_TRACKER_SIZE.Y)
	frame.Visible = false
	setGuiPassive(frame) -- equivalent call inferred; original call site unknown
	frame.Parent = parent
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "DistanceLabel"
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = Font.new(
		"rbxasset://fonts/families/SourceSansPro.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	)
	textLabel.Position = UDim2.fromScale(0, 0.3)
	textLabel.Size = UDim2.fromScale(1, 0.2)
	textLabel.Text = ""
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.TextStrokeTransparency = 0.8
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.ZIndex = 2
	setGuiPassive(textLabel) -- equivalent call inferred; original call site unknown
	textLabel.Parent = frame
	local alertBubble = createAlertBubble(
		frame,
		`AlertBubbleHost_{p}`,
		UDim2.fromScale(0.5, 0),
		UDim2.fromScale(0.5, 0.375),
		false,
		2
	)
	local frame2 = Instance.new("Frame")
	frame2.Name = "ImageDetails"
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = Color3.new(1, 1, 1)
	frame2.BackgroundTransparency = 1
	frame2.BorderColor3 = Color3.new()
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromScale(0.5, 0)
	frame2.Size = UDim2.fromScale(1, 0.8)
	setGuiPassive(frame2) -- equivalent call inferred; original call site unknown
	frame2.Parent = frame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ImageLabel"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = ""
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Visible = false
	setGuiPassive(imageLabel) -- equivalent call inferred; original call site unknown
	imageLabel.Parent = frame2
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "ViewportFrame"
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.Size = VIEWPORT_FRAME_SIZE
	viewportFrame.Visible = false
	setGuiPassive(viewportFrame) -- equivalent call inferred; original call site unknown
	viewportFrame.Parent = frame2
	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.CornerRadius = UDim.new(0.2, 0)
	uICorner.Parent = viewportFrame
	local worldModel = Instance.new("WorldModel")
	worldModel.Name = "WorldModel"
	worldModel.Parent = viewportFrame
	local edgeIndicator = createEdgeIndicator(parent, p) -- equivalent call inferred; original call site unknown
	return {
		TrackerFrame = frame,
		DistanceLabel = textLabel,
		AlertBubbleHost = alertBubble.Host,
		AlertBubbleRoot = alertBubble.Root,
		RenderAlertBubble = alertBubble.Render,
		SetAlertBubbleVisible = alertBubble.SetVisible,
		ImageLabel = imageLabel,
		ViewportFrame = viewportFrame,
		WorldModel = worldModel,
		EdgeIndicatorHost = edgeIndicator.Host,
		EdgeIndicatorRoot = edgeIndicator.Root,
		RenderEdgeIndicator = edgeIndicator.Render,
		SetEdgeIndicatorVisible = edgeIndicator.SetVisible,
		SetEdgeIndicatorPosition = edgeIndicator.SetPosition,
		SetEdgeIndicatorArrowPosition = edgeIndicator.SetArrowPosition,
		SetEdgeIndicatorArrowAngle = edgeIndicator.SetArrowAngle,
		SetEdgeIndicatorArrowVisible = edgeIndicator.SetArrowVisible
	}
end

function TrackerUi.destroy(data)
	data.AlertBubbleRoot:unmount()
	data.EdgeIndicatorRoot:unmount()
	data.TrackerFrame:Destroy()
	data.EdgeIndicatorHost:Destroy()
end

function TrackerUi.setIconBackgroundLayout(p, flag: boolean)
	if flag then
		p.ImageLabel.Position = ICON_BACKGROUND_IMAGE_OFFSET
		p.ViewportFrame.Size = ICON_BACKGROUND_VIEWPORT_SIZE
	else
		p.ImageLabel.Position = UDim2.fromScale(0, 0)
		p.ViewportFrame.Size = VIEWPORT_FRAME_SIZE
	end
end

function TrackerUi.applyOptions(data, p)
	data.RenderAlertBubble(p.AlertIconSettings)
	data.RenderEdgeIndicator(p.AlertIconSettings)
	data.SetEdgeIndicatorArrowVisible(true)
	local sprite = p.IconSettings.Sprite
	local v

	if sprite then
		v = Spritesheets.MAP[sprite]
	end

	if v then
		data.ImageLabel.Image = v.Image
		data.ImageLabel.ImageRectOffset = v.ImageRectOffset or Vector2.zero
		data.ImageLabel.ImageRectSize = v.ImageRectSize or Vector2.zero
	elseif p.IconSettings.CustomIcon then
		data.ImageLabel.Image = p.IconSettings.CustomIcon or ""
	end
end

return TrackerUi