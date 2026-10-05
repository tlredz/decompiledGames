local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local July14thAdminAbuseConfig = require(script.Parent.July14thAdminAbuseConfig)
local localPlayer, playerGui

if RunService:IsClient() then
	localPlayer = Players.LocalPlayer
	playerGui = localPlayer.PlayerGui
else
	localPlayer = nil
	playerGui = nil
end

local color = Color3.fromRGB(24, 24, 26)
local color2 = Color3.fromRGB(38, 38, 42)
local color3 = Color3.fromRGB(48, 48, 54)
local color4 = Color3.fromRGB(210, 255, 80)
local color5 = Color3.fromRGB(235, 235, 238)
local robotoMono = Enum.Font.RobotoMono
local G = Enum.KeyCode.G
local v = nil
local v2 = nil
local v3 = false
local inputBeganConnection = nil
local july14thAdminAbuseReporterTrustedChangedConnection = nil
local inputChangedConnection = nil
local v4 = false

local function isTrusted()
	return localPlayer:GetAttribute("July14thAdminAbuseReporterTrusted") == true
end

local function bindDrag(frame)
	local v5 = false
	local v6 = nil
	local position = nil
	local position2 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update(input)
		local v7 = input.Position - position
		local v8 = position2
		frame.Position = UDim2.new(v8.X.Scale, v8.X.Offset + v7.X, v8.Y.Scale, v8.Y.Offset + v7.Y)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v5 = true
			position = input.Position
			position2 = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					v5 = false
				end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			v6 = input
		end
	end)
	inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if input == v6 and v5 then
			update(input) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function buildPanel()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "July14thAdminAbuseReporterPanel"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 100
	screenGui.Enabled = false
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Name = "Root"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0.15, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.Size = UDim2.new(0, 280, 0, 0)
	frame.BackgroundColor3 = color
	frame.BorderSizePixel = 0
	frame.ZIndex = 2
	frame.Parent = screenGui
	bindDrag(frame)
	local frame2 = Instance.new("Frame")
	frame2.Name = "Stripe"
	frame2.BackgroundColor3 = color4
	frame2.BorderSizePixel = 0
	frame2.Size = UDim2.new(0, 4, 1, 0)
	frame2.ZIndex = 3
	frame2.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.new(0, 12, 0, 10)
	textLabel.Size = UDim2.new(1, -20, 0, 20)
	textLabel.Font = robotoMono
	textLabel.Text = "july14th_reporter_broadcast"
	textLabel.TextColor3 = color4
	textLabel.TextSize = 14
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 3
	textLabel.Parent = frame
	local textBox = Instance.new("TextBox")
	textBox.Name = "Message"
	textBox.BackgroundColor3 = color2
	textBox.BorderSizePixel = 0
	textBox.Position = UDim2.new(0, 10, 0, 36)
	textBox.Size = UDim2.new(1, -20, 0, 60)
	textBox.Font = robotoMono
	textBox.PlaceholderText = "Broadcast to ALL servers..."
	textBox.Text = ""
	textBox.TextColor3 = color5
	textBox.TextSize = 14
	textBox.TextWrapped = true
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.TextYAlignment = Enum.TextYAlignment.Top
	textBox.MultiLine = true
	textBox.ClearTextOnFocus = false
	textBox.ZIndex = 3
	textBox.Parent = frame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingTop = UDim.new(0, 6)
	uIPadding.PaddingLeft = UDim.new(0, 6)
	uIPadding.PaddingRight = UDim.new(0, 6)
	uIPadding.Parent = textBox
	local textButton = Instance.new("TextButton")
	textButton.Name = "Send"
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = color2
	textButton.BorderSizePixel = 0
	textButton.Position = UDim2.new(0, 10, 0, 102)
	textButton.Size = UDim2.new(1, -20, 0, 32)
	textButton.Font = robotoMono
	textButton.Text = "Send to all servers"
	textButton.TextColor3 = color5
	textButton.TextSize = 14
	textButton.ZIndex = 3
	textButton.Parent = frame
	local uIPadding2 = Instance.new("UIPadding")
	uIPadding2.PaddingBottom = UDim.new(0, 10)
	uIPadding2.Parent = frame
	textButton.MouseEnter:Connect(function()
		if not v4 then
			textButton.BackgroundColor3 = color3
		end
	end)
	textButton.MouseLeave:Connect(function()
		if not v4 then
			textButton.BackgroundColor3 = color2
		end
	end)
	textButton.MouseButton1Click:Connect(function()
		if v4 or not v then
			return
		end

		local v5 = textBox.Text:gsub("^%s+", ""):gsub("%s+$", "")

		if v5 == "" then
			return
		end

		v:FireServer(v5)
		textBox.Text = ""
		v4 = true
		textButton.BackgroundColor3 = color2
		textButton.Text = "Send (cooldown)"
		task.delay(July14thAdminAbuseConfig.REPORTER_MESSAGE_COOLDOWN_SEC, function()
			v4 = false
			textButton.Text = "Send to all servers"
		end)
	end)
	return screenGui
end

local function ensurePanel()
	if not v2 then
		v2 = buildPanel()
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPanelVisible(flag: boolean)
	v3 = flag

	if flag then
		if not v2 then
			v2 = buildPanel()
		end

		v2.Enabled = true
	elseif v2 then
		v2.Enabled = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function togglePanel()
	if localPlayer:GetAttribute("July14thAdminAbuseReporterTrusted") ~= true then
		return
	end

	setPanelVisible(not v3) -- equivalent call inferred; original call site unknown
end

local July14thAdminAbuseReporterPanel = {}

function July14thAdminAbuseReporterPanel.init(p)
	v = p
	inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == G then
			togglePanel() -- equivalent call inferred; original call site unknown
		end
	end)
	july14thAdminAbuseReporterTrustedChangedConnection = localPlayer:GetAttributeChangedSignal("July14thAdminAbuseReporterTrusted"):Connect(function()
		if localPlayer:GetAttribute("July14thAdminAbuseReporterTrusted") ~= true then
			setPanelVisible(false) -- equivalent call inferred; original call site unknown
		end
	end)
end

function July14thAdminAbuseReporterPanel.Stop()
	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end

	if july14thAdminAbuseReporterTrustedChangedConnection then
		july14thAdminAbuseReporterTrustedChangedConnection:Disconnect()
		july14thAdminAbuseReporterTrustedChangedConnection = nil
	end

	if inputChangedConnection then
		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
	end

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	v3 = false
	v4 = false
	v = nil
end

return July14thAdminAbuseReporterPanel