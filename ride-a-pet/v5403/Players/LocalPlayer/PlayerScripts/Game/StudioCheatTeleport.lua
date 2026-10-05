local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GameSettings = require(ReplicatedStorage:WaitForChild("GameSettings"))

if not GameSettings.Enabled("SHOWCHEATTELEPORTBUTTONONSTUDIO") then
	return
end

local General = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("General"))
local localPlayer = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StudioCheatTeleport"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 1000
local textButton = Instance.new("TextButton")
textButton.Name = "TeleportToPlot"
textButton.AnchorPoint = Vector2.new(1, 0.5)
textButton.Position = UDim2.new(1, -12, 0.5, 0)
textButton.Size = UDim2.fromOffset(180, 44)
textButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
textButton.TextColor3 = Color3.new(1, 1, 1)
textButton.TextScaled = true
textButton.Font = Enum.Font.GothamBold
textButton.Text = "CHEAT TP: Plot"
textButton.Parent = screenGui
local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(0, 8)
uICorner.Parent = textButton
local uIPadding = Instance.new("UIPadding")
uIPadding.PaddingLeft = UDim.new(0, 8)
uIPadding.PaddingRight = UDim.new(0, 8)
uIPadding.PaddingTop = UDim.new(0, 6)
uIPadding.PaddingBottom = UDim.new(0, 6)
uIPadding.Parent = textButton
local textLabel = Instance.new("TextLabel")
textLabel.Name = "Flags"
textLabel.AnchorPoint = Vector2.new(1, 0)
textLabel.Position = UDim2.new(1, -12, 0.5, 26)
textLabel.Size = UDim2.fromOffset(180, 20)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextStrokeTransparency = 0.5
textLabel.TextScaled = true
textLabel.Font = Enum.Font.Gotham
textLabel.Text = "flags: 0"
textLabel.Parent = screenGui
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshReadout()
	textLabel.Text = string.format("flags: %d", localPlayer:GetAttribute("TeleportFlags") or 0)
end

localPlayer:GetAttributeChangedSignal("TeleportFlags"):Connect(RefreshReadout)
RefreshReadout() -- equivalent call inferred; original call site unknown
textButton.Activated:Connect(function()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local plot = General:GetPlot(localPlayer)
	local baseplate = plot and plot:FindFirstChild("Baseplate")

	if humanoidRootPart and baseplate then
		character:PivotTo(baseplate.CFrame * CFrame.new(0, 6, 0))
	end
end)