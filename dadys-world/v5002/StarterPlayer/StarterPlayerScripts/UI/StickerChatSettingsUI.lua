local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local events = ReplicatedStorage:FindFirstChild("Events")
local settingsChangeEvent = events and events:FindFirstChild("SettingsChangeEvent")

-- equivalent calls inferred from this helper; original call sites unknown
local function GetViewportScale()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return 1
	end

	local viewportSize = currentCamera.ViewportSize
	return (math.clamp(math.min(viewportSize.X / 1920, viewportSize.Y / 1080), 0.5, 1.2))
end

local v = {
	background = Color3.fromRGB(35, 35, 42),
	accent = Color3.fromRGB(255, 150, 200),
	text = Color3.fromRGB(230, 230, 240),
	toggleOn = Color3.fromRGB(100, 200, 100),
	toggleOff = Color3.fromRGB(80, 80, 90),
	buttonHover = Color3.fromRGB(50, 50, 60)
}
local screenGui = nil
local frame = nil
local changedConnection = nil
local v2 = true

-- equivalent calls inferred from this helper; original call sites unknown
local function IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local function UpdateButtonAppearance()
	if not frame then
		return
	end

	local toggleBg = frame:FindFirstChild("ToggleBg")
	local knob = toggleBg and toggleBg:FindFirstChild("Knob")
	local statusLabel = frame:FindFirstChild("StatusLabel")

	if toggleBg then
		toggleBg.BackgroundColor3 = v2 and v.toggleOn or v.toggleOff
	end

	if knob then
		knob.Position = v2 and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)
	end

	if statusLabel then
		statusLabel.Text = v2 and "Sticker Chat Window: ON" or "Sticker Chat Window: OFF"
		statusLabel.TextColor3 = v2 and v.toggleOn or v.toggleOff
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SaveSetting(p)
	if settingsChangeEvent then
		settingsChangeEvent:FireServer("StickerChatEnabled", p)
	end
end

local function CreateToggleButton()
	if frame then
		return
	end

	local v3 = IsMobile() and 280 or 260
	local v4 = IsMobile() and 50 or 44
	frame = Instance.new("Frame")
	frame.Name = "StickerChatToggle"
	frame.Size = UDim2.new(0, v3, 0, v4)
	frame.Position = UDim2.new(1, -v3 - 12, 0, 90)
	frame.BackgroundColor3 = v.background
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = screenGui
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 10)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = v.accent
	uIStroke.Thickness = 2
	uIStroke.Transparency = 0.5
	uIStroke.Parent = frame
	local uIScale = Instance.new("UIScale")
	local scale = GetViewportScale() -- equivalent call inferred; original call site unknown
	uIScale.Scale = scale
	uIScale.Parent = frame
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if uIScale and uIScale.Parent then
				local v6 = uIScale
				local scale2 = GetViewportScale() -- equivalent call inferred; original call site unknown
				v6.Scale = scale2
			end
		end)
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Icon"
	imageLabel.Size = UDim2.new(0, 24, 0, 24)
	imageLabel.Position = UDim2.new(0, 10, 0.5, -12)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://3926305904"
	imageLabel.ImageRectOffset = Vector2.new(324, 764)
	imageLabel.ImageRectSize = Vector2.new(36, 36)
	imageLabel.ImageColor3 = v.accent
	imageLabel.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "StatusLabel"
	textLabel.Size = UDim2.new(1, -110, 1, 0)
	textLabel.Position = UDim2.new(0, 38, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = v2 and "Sticker Chat Window: ON" or "Sticker Chat Window: OFF"
	textLabel.TextColor3 = v2 and v.toggleOn or v.toggleOff
	textLabel.TextSize = 14
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "ToggleBg"
	frame2.Size = UDim2.new(0, 46, 0, 24)
	frame2.Position = UDim2.new(1, -56, 0.5, -12)
	frame2.BackgroundColor3 = v2 and v.toggleOn or v.toggleOff
	frame2.BorderSizePixel = 0
	frame2.Parent = frame
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(0, 12)
	uICorner2.Parent = frame2
	local frame3 = Instance.new("Frame")
	frame3.Name = "Knob"
	frame3.Size = UDim2.new(0, 18, 0, 18)
	frame3.Position = v2 and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)
	frame3.BackgroundColor3 = Color3.new(1, 1, 1)
	frame3.BorderSizePixel = 0
	frame3.Parent = frame2
	local uICorner3 = Instance.new("UICorner")
	uICorner3.CornerRadius = UDim.new(0, 9)
	uICorner3.Parent = frame3
	local textButton = Instance.new("TextButton")
	textButton.Name = "ClickButton"
	textButton.Size = UDim2.new(1, 0, 1, 0)
	textButton.BackgroundTransparency = 1
	textButton.Text = ""
	textButton.Parent = frame
	textButton.MouseButton1Click:Connect(function()
		v2 = not v2
		UpdateButtonAppearance()
		SaveSetting(v2) -- equivalent call inferred; original call site unknown
	end)
	textButton.MouseEnter:Connect(function()
		frame.BackgroundColor3 = v.buttonHover
	end)
	textButton.MouseLeave:Connect(function()
		frame.BackgroundColor3 = v.background
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateElevatorVisibility(_)
	if frame then
		frame.Visible = false
	end
end

local function SetupElevatorDetection()
	local function onCharacterAdded(character)
		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		local stats = character:WaitForChild("Stats", 10)

		if not stats then
			return
		end

		local inElevator = stats:WaitForChild("InElevator", 10)

		if not inElevator then
			return
		end

		local _ = inElevator.Value
		UpdateElevatorVisibility() -- equivalent call inferred; original call site unknown
		changedConnection = inElevator.Changed:Connect(function(_)
			UpdateElevatorVisibility() -- equivalent call inferred; original call site unknown
		end)
	end

	if localPlayer.Character then
		task.spawn(function()
			onCharacterAdded(localPlayer.Character)
		end)
	end

	localPlayer.CharacterAdded:Connect(onCharacterAdded)
end

local function Initialize()
	v2 = localPlayer:GetAttribute("StickerChatEnabled") ~= false
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StickerChatSettings"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 60
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui
	CreateToggleButton()
	SetupElevatorDetection()
	localPlayer:GetAttributeChangedSignal("StickerChatEnabled"):Connect(function()
		v2 = localPlayer:GetAttribute("StickerChatEnabled") ~= false
		UpdateButtonAppearance()
	end)
end

Initialize()