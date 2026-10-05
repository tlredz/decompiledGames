local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local StyleShared = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler.StyleShared)
local Load_Custom = require(ReplicatedStorage.CAM.Global.Load_Custom)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local PartyMember = {
	PLATE_IMAGE = "rbxassetid://77304560969574",
	PLATE_COLOR = Color3.new(0.258824, 0.333333, 0.466667)
}

local function buildViewport(parent, p)
	local data = Utility.GetData(p, true)
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "Content"
	viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	viewportFrame.Position = UDim2.fromScale(0.5, 0.5)
	viewportFrame.Size = UDim2.fromScale(0.71, 0.71)
	viewportFrame.BackgroundTransparency = 1
	local uICorner = Instance.new("UICorner", viewportFrame)
	uICorner.CornerRadius = UDim.new(1, 0)
	viewportFrame.Parent = parent
	local worldModel = Instance.new("WorldModel", viewportFrame)
	local clone = ReplicatedStorage.Assets.StarterCharacterCloneable:Clone()
	clone.Parent = worldModel
	local humanoid = clone:FindFirstChild("Humanoid")

	if humanoid then
		humanoid:Destroy()
	end

	local humanoid2 = Instance.new("Humanoid")
	humanoid2.Name = "Humanoid"
	humanoid2.RigType = Enum.HumanoidRigType.R15
	humanoid2.Parent = clone
	clone.HumanoidRootPart.Anchored = true
	local camera = Instance.new("Camera")
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	local v = clone.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2).Position
	local position = clone.HumanoidRootPart.Position

	if data.Race.Value == "Demon" then
		camera.CFrame = CFrame.new(v, position) + createVector(0, 1.5, 0)
	else
		camera.CFrame = CFrame.new(v, position) + createVector(0, 1.25, 0)
	end

	Load_Custom(p, clone, data, true)
end

PartyMember.buildViewport = buildViewport

function PartyMember.createInterface(data)
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
	imageLabel.Image = PartyMember.PLATE_IMAGE
	imageLabel.ImageColor3 = PartyMember.PLATE_COLOR
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
	task.spawn(buildViewport, canvasGroup, data.player)

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

function PartyMember.setPointer(p, p2, rotation)
	p.Pointer.Enabled.Value = p2

	if p2 then
		p.Pointer.Rotation = rotation
	end
end

PartyMember.replaySpawn = StyleShared.replaySpawn
PartyMember.applyOpacity = StyleShared.applyOpacity
return PartyMember