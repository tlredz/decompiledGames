local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
require(script.Parent.Parent.BaitData)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishingGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
local UI = {}

function UI.create(_, data)
	local frame = Instance.new("Frame")
	frame.Name = "MinigameFrame"
	frame.Size = UDim2.new(0, 100, 0, 400)
	frame.Position = UDim2.new(0.5, -50, 0.5, -200)
	frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	frame.BorderSizePixel = 2
	frame.Visible = false
	frame.Parent = screenGui
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "FishBar"
	imageLabel.Size = UDim2.new(1, 0, data.FishBarHeight, 0)
	imageLabel.Position = UDim2.new(0, 0, 0.425, 0)
	imageLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	imageLabel.BackgroundTransparency = 0.8
	imageLabel.Image = "rbxassetid://15922811031"
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "PlayerBar"
	frame2.Size = UDim2.new(1, 0, data.PlayerBarHeight, 0)
	frame2.Position = UDim2.new(0, 0, 0.45, 0)
	frame2.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	frame2.BackgroundTransparency = 0.5
	frame2.Parent = frame
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "TreasureIcon"
	imageLabel2.Size = UDim2.new(1, 0, data.ChestBarHeight, 0)
	imageLabel2.Position = UDim2.new(0, 0, 0, 0)
	imageLabel2.BackgroundTransparency = 0.8
	imageLabel2.Image = "rbxassetid://5828514453"
	imageLabel2.ScaleType = Enum.ScaleType.Fit
	imageLabel2.Visible = false
	imageLabel2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "ChestLoadBG"
	frame3.Size = UDim2.new(0.5, 0, 0, 6)
	frame3.Position = UDim2.new(0.25, 0, 0, -6)
	frame3.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame3.Visible = false
	frame3.Parent = imageLabel2
	local frame4 = Instance.new("Frame")
	frame4.Name = "ChestLoadFill"
	frame4.Size = UDim2.new(0, 0, 0, 6)
	frame4.Position = UDim2.new(0.25, 0, 0, -6)
	frame4.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	frame4.Parent = imageLabel2
	local frame5 = Instance.new("Frame")
	frame5.Name = "ProgressBar"
	frame5.Size = UDim2.new(0, 10, 0, 0)
	frame5.Position = UDim2.new(1, -10, 1, 0)
	frame5.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
	frame5.Parent = frame
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "BaitSelection"
	scrollingFrame.Position = UDim2.new(0.7, 0, 0.6, 0)
	scrollingFrame.Size = UDim2.new(0.1, 0, 0.2, 0)
	scrollingFrame.Visible = false
	Instance.new("UIListLayout", scrollingFrame)
	return frame, imageLabel, frame2, imageLabel2, frame3, frame4, frame5
end

function UI.UpdateBait(_, parent, items)
	for _, uIListLayout in parent:GetChildren() do
		if not uIListLayout:IsA("UIListLayout") then
			uIListLayout:Destroy()
		end
	end

	for k, item in items do
		local textButton = Instance.new("TextButton")
		textButton.Name = k
		textButton.Text = k
		textButton.Size = UDim2.new(1, 0, 0.02, 0)
		local textLabel = Instance.new("TextLabel", textButton)
		textLabel.Name = "amount"
		textLabel.Text = item
		textLabel.Enabled = false
		textLabel.Size = UDim2.new(0.1, 0, 1, 0)
		textLabel.Position = UDim2.new(0.9, 0, 0, 0)
		textButton.Parent = parent
	end
end

function UI.UpdateIcons(_, p, p2, p3)
	local treasure = p3.Treasure

	if treasure and treasure.Icon then
		p2.Image = treasure.Icon
	else
		p2.Image = "rbxassetid://5828514453"
	end

	if p3.Icon then
		p.Image = p3.Icon
	else
		p.Image = "rbxassetid://15922811031"
	end
end

return UI