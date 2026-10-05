local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
game:GetService("Debris")
local adminMessageToAll = ReplicatedStorage:WaitForChild("AdminMessageToAll")
local parent = script.Parent
local announcementSound = SoundService:WaitForChild("AnnouncementSound")

-- equivalent calls inferred from this helper; original call sites unknown
local function getHeadshot(userId)
	local userThumbnailAsync, _ = Players:GetUserThumbnailAsync(
		userId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size48x48
	)
	return userThumbnailAsync
end

adminMessageToAll.OnClientEvent:Connect(function(p, text)
	local frame = Instance.new("Frame")
	frame.Name = "AdminMsgFrame"
	frame.Parent = parent
	frame.Size = UDim2.new(0.6, 0, 0.06, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, -0.1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel = 0
	frame.ZIndex = 10
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Parent = frame
	uIStroke.Thickness = 2
	uIStroke.Transparency = 0.8
	uIStroke.Color = Color3.fromRGB(255, 255, 255)
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Parent = frame
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Padding = UDim.new(0, 12)
	local uIPadding = Instance.new("UIPadding")
	uIPadding.Parent = frame
	uIPadding.PaddingLeft = UDim.new(0, 8)
	uIPadding.PaddingRight = UDim.new(0, 8)
	uIPadding.PaddingTop = UDim.new(0, 4)
	uIPadding.PaddingBottom = UDim.new(0, 4)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Parent = frame
	imageLabel.Size = UDim2.new(0.8, 0, 0.8, 0)
	imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
	imageLabel.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	imageLabel.BackgroundTransparency = 0
	imageLabel.Image = getHeadshot(p.UserId)
	imageLabel.ZIndex = 11
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(1, 0)
	uICorner2.Parent = imageLabel
	local uIStroke2 = Instance.new("UIStroke")
	uIStroke2.Parent = imageLabel
	uIStroke2.Thickness = 1
	uIStroke2.Color = Color3.fromRGB(150, 150, 150)
	uIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local textLabel = Instance.new("TextLabel")
	textLabel.Parent = frame
	textLabel.Text = p.Name .. " :"
	textLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MaxTextSize = 24
	uITextSizeConstraint.MinTextSize = 12
	uITextSizeConstraint.Parent = textLabel
	textLabel.AutomaticSize = Enum.AutomaticSize.X
	textLabel.Size = UDim2.new(0, 0, 1, 0)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 11
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextStrokeTransparency = 0
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Parent = frame
	textLabel2.Text = text
	textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel2.Font = Enum.Font.GothamSemibold
	textLabel2.BackgroundTransparency = 1
	textLabel2.TextScaled = true
	local uITextSizeConstraint2 = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint2.MaxTextSize = 24
	uITextSizeConstraint2.MinTextSize = 12
	uITextSizeConstraint2.Parent = textLabel2
	textLabel2.Size = UDim2.new(1, 0, 1, 0)
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel2.ZIndex = 11
	textLabel2.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel2.TextStrokeTransparency = 0
	local uDim = UDim2.new(0.5, 0, 0.08, 0)
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(frame, tweenInfo, {
		Position = uDim
	}):Play()
	local clone = announcementSound:Clone()
	clone.Parent = parent
	clone:Play()
	task.wait(8)
	local tween = TweenService:Create(frame, tweenInfo, {
		Position = UDim2.new(0.5, 0, -0.15, 0)
	})
	tween:Play()
	tween.Completed:Connect(function()
		frame:Destroy()
		clone:Destroy()
	end)
end)