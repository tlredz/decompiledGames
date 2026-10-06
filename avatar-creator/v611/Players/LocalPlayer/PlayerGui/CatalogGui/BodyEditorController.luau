local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local panel = parent.Root.Panel
local CatalogUI = require(game.ReplicatedStorage.CatalogUI)
local MenuFade = require(game.ReplicatedStorage.MenuFade)
local UserInputService = game:GetService("UserInputService")
local bodyEditorRemote = game.ReplicatedStorage:WaitForChild("BodyEditorRemote")

local function make(className, name, parent2, options)
	local instance = Instance.new(className)
	instance.Name = name

	for k, v in pairs(options or {}) do
		instance[k] = v
	end

	instance.Parent = parent2
	return instance
end

local parent3 = make("Frame", "BodyEditorPanel", panel, {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(23, 26, 31),
	Visible = false,
	Active = true,
	ZIndex = 12
})
CatalogUI.round(parent3, 16)
local button = CatalogUI.button("Blocker", parent3, "", UDim2.new(), UDim2.fromScale(1, 1))
button.BackgroundTransparency = 1
button.AutoButtonColor = false
button.ZIndex = 12
local label_2 = CatalogUI.label(
	"Title",
	parent3,
	"Body Editor",
	UDim2.fromOffset(20, 16),
	UDim2.new(1, -240, 0, 38),
	26
)
label_2.ZIndex = 13
local button2 = CatalogUI.button("Back", parent3, "‹  Back", UDim2.new(1, -196, 0, 18), UDim2.fromOffset(94, 36))
button2.ZIndex = 13
local label = CatalogUI.label(
	"Status",
	parent3,
	"Customize your in-game avatar.",
	UDim2.new(0, 20, 1, -44),
	UDim2.new(1, -40, 0, 36),
	13
)
label.ZIndex = 13
local parent4 = make("ScrollingFrame", "Options", parent3, {
	Position = UDim2.fromOffset(20, 66),
	Size = UDim2.new(1, -40, 1, -120),
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 5,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 13
})
make("UIListLayout", "Layout", parent4, {
	Padding = UDim.new(0, 14),
	SortOrder = Enum.SortOrder.LayoutOrder
})

local function section(name, p2, layoutOrder)
	local v3 = make("Frame", name, parent4, {
		Size = UDim2.new(1, -8, 0, p2),
		BackgroundColor3 = Color3.fromRGB(34, 38, 46),
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,
		ZIndex = 14
	})
	CatalogUI.round(v3, 12)
	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function label2(p, p2, p3, p4)
	local label3 = CatalogUI.label(p2, p, p3, UDim2.fromOffset(14, p4), UDim2.new(1, -28, 0, 28), 17)
	label3.ZIndex = 15
	return label3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function btn(p, p2, p3, uDim, uDim2)
	local button3 = CatalogUI.button(p2, p, p3, uDim, uDim2)
	button3.ZIndex = 16
	return button3
end

local parent5 = section("SkinTone", 470, 1)
local label_3 = CatalogUI.label("Heading", parent5, "Skin tone", UDim2.fromOffset(14, 12), UDim2.new(1, -28, 0, 28), 17)
label_3.ZIndex = 15
local button32 = btn(parent5, "Presets", "Presets", UDim2.fromOffset(14, 50), UDim2.fromOffset(110, 34)) -- equivalent call inferred; original call site unknown
local button33 = btn(parent5, "Custom", "Custom color", UDim2.fromOffset(132, 50), UDim2.fromOffset(130, 34)) -- equivalent call inferred; original call site unknown
local parent6 = make("Frame", "PresetColors", parent5, {
	Position = UDim2.fromOffset(14, 98),
	Size = UDim2.new(1, -28, 0, 260),
	BackgroundTransparency = 1,
	ZIndex = 15
})
make("UIGridLayout", "Grid", parent6, {
	CellSize = UDim2.new(0.1667, -8, 0, 50),
	CellPadding = UDim2.fromOffset(8, 8),
	SortOrder = Enum.SortOrder.LayoutOrder
})
local v7 = make("Frame", "CustomPicker", parent5, {
	Position = parent6.Position,
	Size = UDim2.new(1, -28, 0, 278),
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 15
})
local parent7 = btn(v7, "SaturationValue", "", UDim2.new(), UDim2.new(1, -44, 0, 160)) -- equivalent call inferred; original call site unknown
parent7.AutoButtonColor = false
make("UIGradient", "Fade", make("Frame", "White", parent7, {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
	ZIndex = 17
}), {
	Transparency = NumberSequence.new(0, 1)
})
make("UIGradient", "Fade", make("Frame", "Black", parent7, {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BorderSizePixel = 0,
	ZIndex = 18
}), {
	Rotation = 90,
	Transparency = NumberSequence.new(1, 0)
})
local parent8 = make("Frame", "Marker", parent7, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(10, 10),
	BackgroundTransparency = 1,
	ZIndex = 19
})
CatalogUI.round(parent8, 10)
make("UIStroke", "Ring", parent8, {
	Color = Color3.new(1, 1, 1),
	Thickness = 2
})
local parent9 = btn(v7, "Hue", "", UDim2.new(1, -30, 0, 0), UDim2.fromOffset(30, 160)) -- equivalent call inferred; original call site unknown
parent9.AutoButtonColor = false
parent9.BackgroundColor3 = Color3.new(1, 1, 1)
local colorSequenceKeypoints = {}

for i = 0, 6 do
	table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
end

make("UIGradient", "Spectrum", parent9, {
	Rotation = 90,
	Color = ColorSequence.new(colorSequenceKeypoints)
})
local input = CatalogUI.input("Hex", v7, "#RRGGBB", UDim2.fromOffset(0, 178), UDim2.new(0.45, -5, 0, 36))
input.ZIndex = 16
local v11 = {}

for i, v12 in ipairs({ "R", "G", "B" }) do
	v11[i] = CatalogUI.input(
		v12,
		v7,
		v12 .. " 0–255",
		UDim2.new(0.45 + (i - 1) * 0.1833, 4, 0, 178),
		UDim2.new(0.1833, -6, 0, 36)
	)
	v11[i].ZIndex = 16
end

local label32 = label2(v7, "Hint", "Drag to pick a color, or enter hex / RGB values.", 228) -- equivalent call inferred; original call site unknown
label32.TextSize = 13
local v13 = make("Frame", "Swatch", parent5, {
	Position = UDim2.fromOffset(14, 380),
	Size = UDim2.fromOffset(48, 38),
	BorderSizePixel = 0,
	ZIndex = 15
})
CatalogUI.round(v13, 8)
local label3 = CatalogUI.label(
	"SelectedColor",
	parent5,
	"#FFFFFF",
	UDim2.fromOffset(74, 380),
	UDim2.new(1, -90, 0, 38),
	18
)
label3.ZIndex = 15
local uDim9 = UDim2.fromOffset(14, 428)
local uDim10 = UDim2.new(1, -28, 0, 32)
local button3 = CatalogUI.button("ApplyColor", parent5, "Apply skin tone", uDim9, uDim10)
button3.ZIndex = 16
local fn
local v14 = 0
local v15 = 0
local v16 = 1
local color = Color3.new(1, 1, 1)

local function setColor(backgroundColor)
	color = backgroundColor
	v14, v15, v16 = backgroundColor:ToHSV()
	local text = "#" .. backgroundColor:ToHex():upper()
	input.Text = text
	label3.Text = text
	v13.BackgroundColor3 = backgroundColor
	parent7.BackgroundColor3 = Color3.fromHSV(v14, 1, 1)
	parent8.Position = UDim2.fromScale(v15, 1 - v16)

	for i, v18 in ipairs({ backgroundColor.R, backgroundColor.G, backgroundColor.B }) do
		v11[i].Text = tostring((math.floor(v18 * 255 + 0.5)))
	end
end

for i, v17 in ipairs({
	"FBE5D0",
	"F1C9A5",
	"DDAA80",
	"C68C60",
	"A96E47",
	"865334",
	"68402B",
	"4A2D20",
	"FFCC99",
	"F8D96B",
	"F5F5F5",
	"B9BDC6",
	"8D919B",
	"373C46",
	"F3B8D0",
	"B9A1E8",
	"8EBDF0",
	"8DD8BB"
}) do
	local button34 = btn(parent6, "Tone" .. i, "", UDim2.new(), UDim2.fromOffset(50, 50)) -- equivalent call inferred; original call site unknown
	button34.BackgroundColor3 = Color3.fromHex(v17)
	button34.LayoutOrder = i
	local v20 = v17
	button34.Activated:Connect(function()
		setColor(Color3.fromHex(v20))
		fn(v20)
	end)
end

button32.Activated:Connect(function()
	parent6.Visible = true
	v7.Visible = false
end)
button33.Activated:Connect(function()
	parent6.Visible = false
	v7.Visible = true
end)
input.FocusLost:Connect(function()
	local v17 = input.Text:gsub("#", ""):gsub("%s", "")

	if v17:match("^%x%x%x%x%x%x$") then
		setColor(Color3.fromHex(v17))
	else
		label.Text = "Enter a six-digit hex code, such as #DDAA80."
	end
end)

for _, v17 in v11 do
	v17.FocusLost:Connect(function()
		local text = tonumber(v11[1].Text)
		local text2 = tonumber(v11[2].Text)
		local text3 = tonumber(v11[3].Text)

		if text and text2 and text3 then
			setColor(Color3.fromRGB(math.clamp(text, 0, 255), math.clamp(text2, 0, 255), (math.clamp(text3, 0, 255))))
		else
			label.Text = "RGB values must be between 0 and 255."
		end
	end)
end

local v17 = nil

local function pick(position)
	if v17 == "square" then
		setColor(Color3.fromHSV(
			v14,
			math.clamp((position.X - parent7.AbsolutePosition.X) / parent7.AbsoluteSize.X, 0, 1),
			1 - math.clamp((position.Y - parent7.AbsolutePosition.Y) / parent7.AbsoluteSize.Y, 0, 1)
		))
	elseif v17 == "hue" then
		local v18 = math.clamp((position.Y - parent9.AbsolutePosition.Y) / parent9.AbsoluteSize.Y, 0, 0.9999)
		setColor(Color3.fromHSV(v18, math.max(v15, 0.01), v16))
	end
end

for k, v18 in pairs({
	[parent7] = "square",
	[parent9] = "hue"
}) do
	local v19 = v18
	k.InputBegan:Connect(function(input2)
		if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
			v17 = v19
			pick(input2.Position)
		end
	end)
end

UserInputService.InputChanged:Connect(function(input2)
	if v17 and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) then
		pick(input2.Position)
	end
end)
UserInputService.InputEnded:Connect(function(input2)
	if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
		v17 = nil
	end
end)
local v18 = section("Rig", 134, 2)
local label33 = label2(v18, "Heading", "Avatar rig", 12) -- equivalent call inferred; original call site unknown
local button35 = btn(v18, "R6", "R6", UDim2.fromOffset(14, 48), UDim2.new(0.5, -21, 0, 36)) -- equivalent call inferred; original call site unknown
local button36 = btn(v18, "R15", "R15", UDim2.new(0.5, 7, 0, 48), UDim2.new(0.5, -21, 0, 36)) -- equivalent call inferred; original call site unknown
local label34 = label2(v18, "Note", "R6 has classic proportions. Some items and animations need R15.", 92) -- equivalent call inferred; original call site unknown
label34.TextSize = 13
local v23 = section("Scales", 386, 3)
local label_4 = CatalogUI.label(
	"Heading",
	v23,
	"Body proportions · R15",
	UDim2.fromOffset(14, 12),
	UDim2.new(1, -28, 0, 28),
	17
)
label_4.ZIndex = 15
local v24 = {
	{
		"HeightScale",
		"Height",
		0.9,
		1.05
	},
	{
		"WidthScale",
		"Width",
		0.7,
		1
	},
	{
		"DepthScale",
		"Depth",
		0.7,
		1
	},
	{
		"HeadScale",
		"Head",
		0.95,
		1
	},
	{
		"BodyTypeScale",
		"Body type",
		0,
		1
	},
	{
		"ProportionScale",
		"Proportions",
		0,
		1
	}
}
local inputs = {}

for i, v25 in ipairs(v24) do
	local v26 = 46 + (i - 1) * 40
	local label35 = label2(v23, v25[1] .. "Label", v25[2] .. "  (" .. v25[3] .. "–" .. v25[4] .. ")", v26) -- equivalent call inferred; original call site unknown
	label35.Size = UDim2.new(0.65, -20, 0, 32)
	local input2 = CatalogUI.input(v25[1], v23, "Value", UDim2.new(0.65, 0, 0, v26), UDim2.new(0.35, -14, 0, 32))
	input2.ZIndex = 16
	inputs[v25[1]] = input2
end

local button37 = btn(v23, "ApplyScale", "Apply proportions", UDim2.fromOffset(14, 294), UDim2.new(1, -28, 0, 36)) -- equivalent call inferred; original call site unknown
local label36 = label2(v23, "Note", "The Avatar Scaler gamepass controls overall size (0.1×–3×).", 342) -- equivalent call inferred; original call site unknown
label36.TextSize = 13
local flag = false
local now = -1e999
local v27 = nil
local flag2 = false

local function render(result)
	if result.hex and not v27 then
		setColor(Color3.fromHex(result.hex))
	end

	if result.rig then
		label33.Text = "Avatar rig · " .. result.rig
		button37.Interactable = result.rig == "R15"
	end

	for k, v28 in pairs(result.scales or {}) do
		if inputs[k] then
			inputs[k].Text = string.format("%.2f", v28)
		end
	end
end

local function request(p, options)
	if flag then
		return
	end

	flag = true
	label.Text = "Applying..."
	local v28 = 0.55 - (os.clock() - now)

	if v28 > 0 then
		task.wait(v28)
	end

	now = os.clock()
	local success, result = pcall(function()
		return bodyEditorRemote:InvokeServer(p, options or {})
	end)
	flag = false

	if not success then
		label.Text = "Could not connect. Please try again."
		return
	end

	if result.error then
		label.Text = result.error
		return
	end

	render(result)
	label.Text = result.message or "Customize your in-game avatar."
end

fn = function(p)
	v27 = p

	if flag2 then
		return
	end

	flag2 = true
	task.spawn(function()
		while v27 do
			while flag do
				task.wait()
			end

			local v28 = 0.55 - (os.clock() - now)

			if v28 > 0 then
				task.wait(v28)
			end

			if flag then
				continue
			end

			local hex = v27
			v27 = nil
			request("Color", {
				hex = hex
			})
		end

		flag2 = false
	end)
end

button3.Visible = false
button32.Activated:Connect(function()
	button3.Visible = false
end)
button33.Activated:Connect(function()
	button3.Visible = true
end)
button3.Activated:Connect(function()
	request("Color", {
		hex = color:ToHex()
	})
end)
button37.Activated:Connect(function()
	local texts = {}

	for _, v28 in ipairs(v24) do
		local text = tonumber(inputs[v28[1]].Text)

		if text and text == text and not (text < v28[3] or v28[4] < text) then
			texts[v28[1]] = text
		else
			label.Text = v28[2] .. " must be between " .. v28[3] .. " and " .. v28[4] .. "."
			return
		end
	end

	request("Scale", {
		scales = texts
	})
end)
button35.Activated:Connect(function()
	request("Rig", {
		rig = "R6"
	})
end)
button36.Activated:Connect(function()
	request("Rig", {
		rig = "R15"
	})
end)
button2.Activated:Connect(function()
	MenuFade.Set(parent3, "Visible", false)
end)
panel.Tabs.BodyEditor.Activated:Connect(function()
	MenuFade.Set(parent3, "Visible", true)
	task.spawn(request, "State")
end)
parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not parent.Enabled then
		if not parent:GetAttribute("PreserveCatalogPage") then
			parent3.Visible = false
		end

		v17 = nil
	end
end)
localPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	workspace.CurrentCamera.CameraSubject = humanoid
end)
setColor(color)