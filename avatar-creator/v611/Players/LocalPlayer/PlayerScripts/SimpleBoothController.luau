local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleBoothGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 500
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local function make(className, items, parent)
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local v = {
	Name = "Editor",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(420, 340),
	BackgroundColor3 = Color3.fromRGB(55, 55, 55),
	Visible = false
}
local frame = Instance.new("Frame")

for k, v2 in v do
	frame[k] = v2
end

frame.Parent = screenGui
local v2 = {
	CornerRadius = UDim.new(0, 12)
}
local uICorner = Instance.new("UICorner")

for k, v3 in v2 do
	uICorner[k] = v3
end

uICorner.Parent = frame
local uIScale = Instance.new("UIScale")

for k, v3 in {} do
	uIScale[k] = v3
end

uIScale.Parent = frame

local function label(text, p2, p3)
	local v3 = {
		Position = UDim2.fromOffset(20, p2),
		Size = UDim2.new(1, -40, 0, p3),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 17,
		TextWrapped = true,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}
	local textLabel = Instance.new("TextLabel")

	for k, v5 in v3 do
		textLabel[k] = v5
	end

	textLabel.Parent = frame
	return textLabel
end

local label_2 = label("Edit your booth", 16, 30)
label_2.TextSize = 25
label("Title · up to 60 characters", 58, 24)

local function input(name, p2)
	local v3 = {
		Name = name,
		Position = UDim2.fromOffset(20, p2),
		Size = UDim2.new(1, -40, 0, 42),
		BackgroundColor3 = Color3.fromRGB(90, 90, 90),
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.Gotham,
		TextSize = 18,
		ClearTextOnFocus = false,
		Text = ""
	}
	local textBox = Instance.new("TextBox")

	for k, v5 in v3 do
		textBox[k] = v5
	end

	textBox.Parent = frame
	return textBox
end

local v3 = input("Title", 86)
label("Logo decal / image ID · blank uses default", 140, 24)
local v4 = input("DecalId", 168)
v4.PlaceholderText = "Paste a decal or image ID"
local v5 = label("", 218, 55)
v5.TextSize = 15

local function button(name, text, p3, p4)
	local v6 = {
		Name = name,
		Text = text,
		Position = UDim2.fromOffset(p3, 286),
		Size = UDim2.fromOffset(p4, 36),
		BackgroundColor3 = Color3.fromRGB(185, 185, 185),
		TextColor3 = Color3.fromRGB(30, 30, 30),
		Font = Enum.Font.GothamBold,
		TextSize = 16
	}
	local textButton = Instance.new("TextButton")

	for k, v8 in v6 do
		textButton[k] = v8
	end

	textButton.Parent = frame
	return textButton
end

local v6 = button("Save", "Save", 20, 116)
local v7 = button("Release", "Release", 152, 116)
local v8 = button("Close", "Close", 284, 116)
local flag = false
replicatedStorage:WaitForChild("SimpleBoothOpen").OnClientEvent:Connect(function(p)
	v3.Text = p.title or ""
	v4.Text = p.decalId or ""
	v5.Text = "Change your title and the logo beside it."
	frame.Visible = true
end)

local function send(p)
	if flag then
		return
	end

	flag = true
	v6.Text = "Saving..."
	local success, result = pcall(function()
		return replicatedStorage.SimpleBoothRemote:InvokeServer(p, {
			title = v3.Text,
			decalId = v4.Text
		})
	end)
	flag = false
	v6.Text = "Save"

	if not success then
		v5.Text = "Could not connect. Try again."
		return
	end

	v5.Text = result.error or "Saved!"

	if result.title then
		v3.Text = result.title
	end

	if result.released then
		frame.Visible = false
	end
end

v6.Activated:Connect(function()
	send("Save")
end)
v7.Activated:Connect(function()
	send("Release")
end)
v8.Activated:Connect(function()
	frame.Visible = false
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function fit()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local viewportSize = currentCamera.ViewportSize
		uIScale.Scale = math.min(1, (viewportSize.X - 24) / 420, (viewportSize.Y - 24) / 340)
	end
end

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
end

fit() -- equivalent call inferred; original call site unknown