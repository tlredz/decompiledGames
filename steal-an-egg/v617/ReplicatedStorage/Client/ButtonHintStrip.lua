local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUI = require(ReplicatedStorage.Client.GUI)
local InputIconsConfig = require(ReplicatedStorage.Client.InputIconsConfig)
local Log = require(ReplicatedStorage.Packages.Log)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local t = require(ReplicatedStorage.Packages.t)
local vector = Vector2.new(0, 1)
local vector2 = Vector2.new(1, 1)
local uDim = UDim2.fromScale(0.335, 0.965)
local uDim2 = UDim2.fromScale(0.085, 0.15)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(15, 15, 20)
local strict = t.strict(t.string)
local v = Log.new()
local playerGui = GUI.PlayerGui()

local function build(className: string, parent, items)
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local v2 = {
	DisplayOrder = 5,
	Name = "ActionPrompts",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}
local screenGui = Instance.new("ScreenGui")
local v3 = {}
local v4 = nil
local v5 = nil
local count = 0
local ButtonHintStrip = {}

for k, v6 in v2 do
	screenGui[k] = v6
end

screenGui.Parent = nil
local v6 = {
	AnchorPoint = vector,
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	Name = "Holder",
	Position = uDim,
	Size = UDim2.new(0, 0, uDim2.Y.Scale, 0),
	Visible = false
}
local frame = Instance.new("Frame")

for k, v7 in v6 do
	frame[k] = v7
end

frame.Parent = screenGui
local v7 = {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	Padding = UDim.new(0.06, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	VerticalAlignment = Enum.VerticalAlignment.Bottom
}
local uIListLayout = Instance.new("UIListLayout")

for k, v8 in v7 do
	uIListLayout[k] = v8
end

uIListLayout.Parent = frame
screenGui.Parent = playerGui

local function paint(data)
	local v8

	if data.key then
		v8 = InputIconsConfig.Image(data.key)
	end

	data.glyph.Image = v8 or ""
	data.glyph.Visible = v8 ~= nil
	local text = data.text
	local text2

	if data.key and not v8 then
		text2 = `{data.key == Enum.KeyCode.ButtonR3 and "Press right stick" or data.key.Name}: {data.caption}`
	else
		text2 = data.caption
	end

	text.Text = text2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function republish()
	frame.Visible = PlatformController.IsConsole() and next(v3) ~= nil

	for _, v8 in v3 do
		paint(v8)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reposition()
	local anchorPoint = vector
	local uDim3 = uDim

	if v4 == nil then
		if v5 ~= nil then
			anchorPoint = vector2
			uDim3 = UDim2.fromScale(v5, uDim.Y.Scale)
		end
	else
		uDim3 = UDim2.fromScale(v4, uDim.Y.Scale)
	end

	frame.AnchorPoint = anchorPoint
	frame.Position = uDim3
end

local function mint(p, caption: string)
	count += 1
	local v8 = {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = count,
		Name = "Prompt",
		Size = UDim2.new(0, 0, 0.26, 0)
	}
	local frame2 = Instance.new("Frame")

	for k, v9 in v8 do
		frame2[k] = v9
	end

	frame2.Parent = nil
	local v9 = {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center
	}
	local uIListLayout2 = Instance.new("UIListLayout")

	for k, v10 in v9 do
		uIListLayout2[k] = v10
	end

	uIListLayout2.Parent = frame2
	local v10 = {
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Name = "Icon",
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}
	local imageLabel = Instance.new("ImageLabel")

	for k, v11 in v10 do
		imageLabel[k] = v11
	end

	imageLabel.Parent = frame2
	local v11 = {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		LayoutOrder = 2,
		Name = "Label",
		Size = UDim2.new(0, 0, 0.58, 0),
		TextColor3 = color,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left
	}
	local textLabel = Instance.new("TextLabel")

	for k, v12 in v11 do
		textLabel[k] = v12
	end

	textLabel.Parent = frame2
	local v12 = {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
		Color = color2,
		Thickness = 2.5
	}
	local uIStroke = Instance.new("UIStroke")

	for k, v13 in v12 do
		uIStroke[k] = v13
	end

	uIStroke.Parent = textLabel
	frame2.Parent = frame
	return {
		key = p,
		caption = caption,
		row = frame2,
		glyph = imageLabel,
		text = textLabel
	}
end

function ButtonHintStrip.Present(p: string, p2, caption: string)
	strict(p)
	strict(caption)
	assert(typeof(p2) == "EnumItem", (`hint {p} was handed a {typeof(p2)} where a KeyCode belongs`))
	local v8 = v3[p]

	if v8 ~= nil and v8.key == p2 and v8.caption == caption then
		return
	end

	if v8 == nil then
		v8 = mint(p2, caption)
		v3[p] = v8
	else
		v8.key = p2
		v8.caption = caption
	end

	paint(v8)
	republish() -- equivalent call inferred; original call site unknown
	v:AtDebug():Log((`hint {p} now reads {caption} off {p2.Name}; gamepad {PlatformController.IsConsole()}, glyph {v8.glyph.Image}`))
end

function ButtonHintStrip.PresentStatus(p: string, caption: string)
	local v8 = v3[p]

	if v8 and v8.caption == caption then
		return
	end

	if v8 then
		v8.caption = caption
	else
		v8 = mint(nil, caption)
		v3[p] = v8
	end

	paint(v8)
	republish() -- equivalent call inferred; original call site unknown
end

function ButtonHintStrip.SetNavigationLayer(p: number?)
	screenGui.DisplayOrder = not p and 5 or math.max(5, p + 1)
end

function ButtonHintStrip.Retract(p: string)
	strict(p)
	local v8 = v3[p]

	if v8 == nil then
		return
	end

	v3[p] = nil
	v8.row:Destroy()
	republish() -- equivalent call inferred; original call site unknown
end

function ButtonHintStrip.IsPresent(p: string)
	strict(p)
	return v3[p] ~= nil
end

function ButtonHintStrip.PinLeft(p: number?)
	v4 = p
	reposition() -- equivalent call inferred; original call site unknown
end

function ButtonHintStrip.PinRight(p: number?)
	v5 = p
	reposition() -- equivalent call inferred; original call site unknown
end

PlatformController.Changed:Connect(republish)
InputIconsConfig.Changed:Connect(republish)
republish() -- equivalent call inferred; original call site unknown
return ButtonHintStrip