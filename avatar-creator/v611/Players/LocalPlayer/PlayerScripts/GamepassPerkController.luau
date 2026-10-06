local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gamepassAction = ReplicatedStorage:WaitForChild("GamepassAction")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GamepassPerkControls"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 210
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(360, 240)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(28, 33, 40)
frame.Visible = false
frame.Parent = screenGui
local uICorner = Instance.new("UICorner", frame)
uICorner.CornerRadius = UDim.new(0, 16)
local uIScale = Instance.new("UIScale", frame)

-- equivalent calls inferred from this helper; original call sites unknown
local function layout()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	uIScale.Scale = math.min(1, (viewportSize.X - 32) / 360, (viewportSize.Y - 32) / 240)
end

layout() -- equivalent call inferred; original call site unknown
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)

local function text(className, text2, position, size)
	local instance = Instance.new(className)
	instance.BackgroundTransparency = className == "TextLabel" and 1 or 0
	instance.BackgroundColor3 = Color3.fromRGB(62, 76, 96)
	instance.TextColor3 = Color3.fromRGB(240, 242, 247)
	instance.Font = Enum.Font.GothamMedium
	instance.TextSize = 16
	instance.Text = text2
	instance.Position = position
	instance.Size = size
	instance.Parent = frame

	if className ~= "TextLabel" then
		local uICorner = Instance.new("UICorner", instance)
		uICorner.CornerRadius = UDim.new(0, 8)
	end

	return instance
end

local uDim = UDim2.fromOffset(18, 14)
local uDim2 = UDim2.fromOffset(274, 32)
local textLabel = Instance.new("TextLabel")
textLabel.BackgroundTransparency = 1
textLabel.BackgroundColor3 = Color3.fromRGB(62, 76, 96)
textLabel.TextColor3 = Color3.fromRGB(240, 242, 247)
textLabel.Font = Enum.Font.GothamMedium
textLabel.TextSize = 16
textLabel.Text = ""
textLabel.Position = uDim
textLabel.Size = uDim2
textLabel.Parent = frame
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextSize = 20
local v = text("TextButton", "×", UDim2.fromOffset(308, 14), UDim2.fromOffset(34, 32))
v.BackgroundColor3 = Color3.fromRGB(186, 44, 61)
v.Activated:Connect(function()
	frame.Visible = false
end)
local uDim3 = UDim2.fromOffset(18, 163)
local uDim4 = UDim2.fromOffset(324, 60)
local textLabel2 = Instance.new("TextLabel")
textLabel2.BackgroundTransparency = 1
textLabel2.BackgroundColor3 = Color3.fromRGB(62, 76, 96)
textLabel2.TextColor3 = Color3.fromRGB(240, 242, 247)
textLabel2.Font = Enum.Font.GothamMedium
textLabel2.TextSize = 16
textLabel2.Text = ""
textLabel2.Position = uDim3
textLabel2.Size = uDim4
textLabel2.Parent = frame
textLabel2.TextSize = 13
textLabel2.TextWrapped = true
local v2 = text("TextBox", "", UDim2.fromOffset(18, 62), UDim2.fromOffset(324, 38))
v2.PlaceholderText = "Audio asset ID"
v2.ClearTextOnFocus = false

-- equivalent calls inferred from this helper; original call sites unknown
local function invoke(p, p2)
	local success, result = pcall(gamepassAction.InvokeServer, gamepassAction, p, p2)
	textLabel2.Text = not success and "Could not apply this perk. Try again." or result.error or result.message or "Could not apply this perk. Try again."
end

local v3 = {}

for i, v4 in ipairs({
	0.1,
	0.5,
	1,
	2,
	3
}) do
	local v5 = text("TextButton", v4 .. "×", UDim2.fromOffset(18 + (i - 1) * 66, 108), UDim2.fromOffset(60, 40))
	local v6 = v4
	v5.Activated:Connect(function()
		invoke("Scale", v6) -- equivalent call inferred; original call site unknown
	end)
	table.insert(v3, v5)
end

local v4 = text("TextBox", "1", UDim2.fromOffset(18, 62), UDim2.fromOffset(232, 38))
v4.PlaceholderText = "Size: 0.1–3"
v4.ClearTextOnFocus = false
local v5 = text("TextButton", "Apply", UDim2.fromOffset(258, 62), UDim2.fromOffset(84, 38))

-- equivalent calls inferred from this helper; original call sites unknown
local function applyScale()
	local text2 = tonumber(v4.Text)

	if not text2 or text2 ~= text2 or text2 < 0.1 or text2 > 3 then
		textLabel2.Text = "Enter a number from 0.1 to 3."
		return
	end

	invoke("Scale", text2) -- equivalent call inferred; original call site unknown
end

v5.Activated:Connect(applyScale)
v4.FocusLost:Connect(function(p)
	if p then
		applyScale() -- equivalent call inferred; original call site unknown
	end
end)
local v6 = text("TextButton", "Play", UDim2.fromOffset(18, 108), UDim2.fromOffset(156, 40))
local v7 = text("TextButton", "Stop", UDim2.fromOffset(186, 108), UDim2.fromOffset(156, 40))
v7.BackgroundColor3 = Color3.fromRGB(166, 48, 62)
v6.Activated:Connect(function()
	invoke("Play", v2.Text:match("%d+")) -- equivalent call inferred; original call site unknown
end)
v7.Activated:Connect(function()
	invoke("Stop", nil) -- equivalent call inferred; original call site unknown
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function open(gamepassTool)
	local visible = gamepassTool == "Boombox"
	textLabel.Text = visible and "Boombox" or "Avatar Scaler"
	v2.Visible = visible
	v6.Visible = visible
	v7.Visible = visible
	v4.Visible = not visible
	v5.Visible = not visible

	for _, v9 in v3 do
		v9.Visible = not visible
	end

	textLabel2.Text = visible and "Use audio IDs that this experience has permission to play." or "Range: 0.1×–3×. Type a size and press Apply. 1× restores normal size."
	frame.Visible = true
end

local object = setmetatable({}, {
	__mode = "k"
})

local function bind(tool)
	if not tool:IsA("Tool") or object[tool] then
		return
	end

	local gamepassTool = tool:GetAttribute("GamepassTool")

	if gamepassTool ~= "Scaler" and gamepassTool ~= "Boombox" then
		return
	end

	object[tool] = true
	tool.Equipped:Connect(function()
		open(gamepassTool) -- equivalent call inferred; original call site unknown
	end)
	tool.Activated:Connect(function()
		open(gamepassTool) -- equivalent call inferred; original call site unknown
	end)
	tool.Unequipped:Connect(function()
		frame.Visible = false
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watch(instance)
	for _, child in instance:GetChildren() do
		bind(child)
	end

	instance.ChildAdded:Connect(bind)
end

watch(localPlayer:WaitForChild("Backpack")) -- equivalent call inferred; original call site unknown
localPlayer.CharacterAdded:Connect(function(character)
	frame.Visible = false
	watch(character) -- equivalent call inferred; original call site unknown
	watch(localPlayer:WaitForChild("Backpack")) -- equivalent call inferred; original call site unknown
end)

if localPlayer.Character then
	watch(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

local TextChatService = game:GetService("TextChatService")

TextChatService.OnIncomingMessage = function(p)
	if p.TextSource then
		local playerByUserId = Players:GetPlayerByUserId(p.TextSource.UserId)

		if playerByUserId and playerByUserId:GetAttribute("Pass_VIP") then
			local textChatMessageProperties = Instance.new("TextChatMessageProperties")
			textChatMessageProperties.PrefixText = "<font color=\"#FFD35C\">[VIP]</font> " .. p.PrefixText
			return textChatMessageProperties
		end
	end
end