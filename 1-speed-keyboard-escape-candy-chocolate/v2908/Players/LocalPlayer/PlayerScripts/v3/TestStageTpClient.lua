local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("GeneralConfig"))

if not GeneralConfig:IsTestPlace() then
	return
end

local Icon = require(ReplicatedStorage:WaitForChild("TopbarPlus"):WaitForChild("Icon"))
local TestStageTpRemotes = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("TestStageTpRemotes"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TestStageTpGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Enabled = false
screenGui.DisplayOrder = 50
screenGui.Parent = playerGui
local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Active = true
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromOffset(260, 360)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui
local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(0, 10)
uICorner.Parent = frame
local uIDragDetector = Instance.new("UIDragDetector")
uIDragDetector.Parent = frame
local textLabel = Instance.new("TextLabel")
textLabel.Name = "Title"
textLabel.Size = UDim2.new(1, 0, 0, 40)
textLabel.BackgroundTransparency = 1
textLabel.Text = "Stage TP (TestPlace)"
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 18
textLabel.Parent = frame
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "List"
scrollingFrame.Position = UDim2.fromOffset(10, 48)
scrollingFrame.Size = UDim2.new(1, -20, 1, -58)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.CanvasSize = UDim2.new()
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.Parent = frame
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Padding = UDim.new(0, 6)
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uIListLayout.Parent = scrollingFrame

local function makeButton(layoutOrder)
	local textButton = Instance.new("TextButton")
	textButton.Name = "Stage" .. layoutOrder
	textButton.Size = UDim2.new(1, -6, 0, 36)
	textButton.BackgroundColor3 = Color3.fromRGB(45, 120, 220)
	textButton.AutoButtonColor = true
	textButton.Text = "Stage " .. layoutOrder
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.Font = Enum.Font.GothamSemibold
	textButton.TextSize = 16
	textButton.LayoutOrder = layoutOrder
	textButton.Parent = scrollingFrame
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(0, 6)
	uICorner2.Parent = textButton
	textButton.MouseButton1Click:Connect(function()
		TestStageTpRemotes.TeleportToStage:fire(layoutOrder)
	end)
end

local function rebuild()
	local success, result = pcall(function()
		return TestStageTpRemotes.GetStages:request():expect()
	end)

	if not success or type(result) ~= "table" then
		return
	end

	for _, button in ipairs(scrollingFrame:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end

	for _, v in ipairs(result) do
		makeButton(v)
	end
end

local v = Icon.new():setName("StageTP"):setLabel("Stage TP"):setImage("rbxassetid://6034509993")
v.selected:Connect(function()
	rebuild()
	screenGui.Enabled = true
end)
v.deselected:Connect(function()
	screenGui.Enabled = false
end)