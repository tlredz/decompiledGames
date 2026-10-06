local parent = script.Parent
local localPlayer = game.Players.LocalPlayer
local MenuFade = require(game.ReplicatedStorage.MenuFade)

local function make(className, name, parent2, items)
	local instance = Instance.new(className)
	instance.Name = name

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent2
	return instance
end

local v = {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 50
}
local frame = Instance.new("Frame")
frame.Name = "ResetConfirmation"

for k, v2 in pairs(v) do
	frame[k] = v2
end

frame.Parent = parent
local v2 = {
	Size = UDim2.fromScale(1, 1),
	Text = "",
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1,
	AutoButtonColor = false,
	ZIndex = 50
}
local textButton = Instance.new("TextButton")
textButton.Name = "Blocker"

for k, v3 in pairs(v2) do
	textButton[k] = v3
end

textButton.Parent = frame
local v3 = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(420, 230),
	BackgroundColor3 = Color3.fromRGB(25, 30, 40),
	BorderSizePixel = 0,
	ZIndex = 51
}
local frame2 = Instance.new("Frame")
frame2.Name = "Dialog"

for k, v4 in pairs(v3) do
	frame2[k] = v4
end

frame2.Parent = frame
local v4 = {
	CornerRadius = UDim.new(0, 18)
}
local uICorner = Instance.new("UICorner")
uICorner.Name = "Corner"

for k, v5 in pairs(v4) do
	uICorner[k] = v5
end

uICorner.Parent = frame2
local v5 = {
	Color = Color3.fromRGB(119, 140, 170),
	Transparency = 0.3,
	Thickness = 1.5
}
local uIStroke = Instance.new("UIStroke")
uIStroke.Name = "Border"

for k, v6 in pairs(v5) do
	uIStroke[k] = v6
end

uIStroke.Parent = frame2
local v6 = {
	Position = UDim2.fromOffset(24, 22),
	Size = UDim2.new(1, -48, 0, 36),
	Text = "Are you sure?",
	Font = Enum.Font.GothamBold,
	TextSize = 25,
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 1,
	ZIndex = 52
}
local textLabel = Instance.new("TextLabel")
textLabel.Name = "Title"

for k, v7 in pairs(v6) do
	textLabel[k] = v7
end

textLabel.Parent = frame2
local v7 = {
	Position = UDim2.fromOffset(24, 67),
	Size = UDim2.new(1, -48, 0, 62),
	Text = "Restore your normal Roblox avatar outfit?",
	Font = Enum.Font.Gotham,
	TextSize = 16,
	TextWrapped = true,
	TextColor3 = Color3.fromRGB(206, 214, 227),
	BackgroundTransparency = 1,
	ZIndex = 52
}
local textLabel2 = Instance.new("TextLabel")
textLabel2.Name = "Message"

for k, v8 in pairs(v7) do
	textLabel2[k] = v8
end

textLabel2.Parent = frame2

local function button(name, p, color)
	local v9 = {
		Position = UDim2.new(p, 24, 1, -72),
		Size = UDim2.new(0.5, -36, 0, 48),
		Text = name,
		Font = Enum.Font.GothamBold,
		TextSize = 19,
		TextColor3 = Color3.new(1, 1, 1),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = 52
	}
	local textButton2 = Instance.new("TextButton")
	textButton2.Name = name

	for k, v10 in pairs(v9) do
		textButton2[k] = v10
	end

	textButton2.Parent = frame2
	local v10 = {
		CornerRadius = UDim.new(0, 10)
	}
	local uICorner2 = Instance.new("UICorner")
	uICorner2.Name = "Corner"

	for k, v11 in pairs(v10) do
		uICorner2[k] = v11
	end

	uICorner2.Parent = textButton2
	return textButton2
end

local v8 = button("Yes", 0, Color3.fromRGB(38, 151, 85))
local v9 = button("No", 0.5, Color3.fromRGB(188, 49, 62))
local flag = false
localPlayer:WaitForChild("PlayerGui"):WaitForChild("WearingGui").Root.Panel.Current:WaitForChild("ResetAvatar").Activated:Connect(function()
	if flag then
		return
	end

	textLabel2.Text = "Restore your normal Roblox avatar outfit?"
	MenuFade.Set(frame, "Visible", true)
end)
v9.Activated:Connect(function()
	if not flag then
		MenuFade.Set(frame, "Visible", false)
	end
end)
v8.Activated:Connect(function()
	if flag then
		return
	end

	flag = true
	v8.Text = "Restoring…"
	v8.Interactable = false
	v9.Interactable = false
	local success, result = pcall(function()
		return game.ReplicatedStorage.EditorToolsRemote:InvokeServer("ResetAvatar", {})
	end)
	flag = false
	v8.Text = "Yes"
	v8.Interactable = true
	v9.Interactable = true

	if success and result and not result.error then
		MenuFade.Set(frame, "Visible", false)
	else
		textLabel2.Text = success and result and result.error or "Could not restore your outfit. Please try again."
	end
end)
local uIScale = Instance.new("UIScale", frame2)

-- equivalent calls inferred from this helper; original call sites unknown
local function fit()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	uIScale.Scale = math.min(1, (viewportSize.X - 32) / 420, (viewportSize.Y - 32) / 230)
end

local ViewportLayoutWatch = require(game.ReplicatedStorage:WaitForChild("ViewportLayoutWatch"))
ViewportLayoutWatch.Bind(fit)
fit() -- equivalent call inferred; original call site unknown