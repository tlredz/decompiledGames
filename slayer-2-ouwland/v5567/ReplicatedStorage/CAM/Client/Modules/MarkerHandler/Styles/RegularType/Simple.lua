local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local StyleShared = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler.StyleShared)
local Simple = {}

function Simple.createInterface(data)
	if data == nil then
		return
	end

	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.AnchorPoint = Vector2.new(0.5, 0.5)
	canvasGroup.Size = UDim2.new(0, 0, 0, 0)
	canvasGroup.BorderSizePixel = 0
	canvasGroup.BackgroundTransparency = 1
	TweenService:Create(canvasGroup, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Size = UDim2.new(0, gameSettings.MarkerSize, 0, gameSettings.MarkerSize)
	}):Play()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Parent = canvasGroup
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Image = "rbxassetid://77304560969574"
	imageLabel.ImageColor3 = Color3.new(0.4, 0.4, 0.4)
	local color = data.color or Color3.new(1, 1, 1)
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Size = UDim2.fromScale(1.2, 1.2)
	imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel2.ImageColor3 = color
	imageLabel2.Image = "rbxassetid://79597720768538"
	imageLabel2.ZIndex = 2
	imageLabel2.Name = "Pointer"
	imageLabel2.Parent = canvasGroup
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "Enabled"
	boolValue.Parent = imageLabel2

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updEnabled()
		if imageLabel2 and imageLabel2.Parent == canvasGroup then
			imageLabel2.Visible = boolValue.Value
		end
	end

	updEnabled() -- equivalent call inferred; original call site unknown
	boolValue.Changed:Connect(updEnabled)
	local img = data.img

	if img then
		local imageLabel3 = Instance.new("ImageLabel")
		imageLabel3.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel3.Position = UDim2.fromScale(0.5, 0.5)
		imageLabel3.Size = UDim2.new(0.71, 0, 0.71, 0)
		imageLabel3.Parent = canvasGroup
		imageLabel3.Name = "Content"
		imageLabel3.BackgroundTransparency = 1
		imageLabel3.Image = img
		imageLabel3.ScaleType = Enum.ScaleType.Crop
		local uICorner = Instance.new("UICorner", imageLabel3)
		uICorner.CornerRadius = UDim.new(1, 0)
	end

	if not data.displayDistance then
		return canvasGroup
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "dist"
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.75)
	textLabel.Font = Enum.Font.SourceSansSemibold
	textLabel.Size = gameSettings.MarkerDistanceTextScale
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.ZIndex = 99
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.Parent = canvasGroup
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Thickness = 1.5
	uIStroke.Name = "stroke"
	return canvasGroup
end

function Simple.setPointer(p, p2, rotation)
	p.Pointer.Enabled.Value = p2

	if p2 then
		p.Pointer.Rotation = rotation
	end
end

Simple.replaySpawn = StyleShared.replaySpawn
Simple.applyOpacity = StyleShared.applyOpacity
return Simple