local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local FakePurchasePromptView = {}
FakePurchasePromptView.__index = FakePurchasePromptView
local color = Color3.fromRGB(35, 36, 41)
local color2 = Color3.fromRGB(51, 95, 255)
local color3 = Color3.fromRGB(247, 247, 248)
local color4 = Color3.fromRGB(174, 178, 183)
local color5 = Color3.fromRGB(60, 62, 68)
local color6 = Color3.fromRGB(10, 10, 14)
local rbxassetfontsfamiliesBuilderSansjson = Font.new(
	"rbxasset://fonts/families/BuilderSans.json",
	Enum.FontWeight.Regular
)
local rbxassetfontsfamiliesBuilderSansjson2 = Font.new(
	"rbxasset://fonts/families/BuilderSans.json",
	Enum.FontWeight.Medium
)
local rbxassetfontsfamiliesBuilderSansjson3 = Font.new(
	"rbxasset://fonts/families/BuilderSans.json",
	Enum.FontWeight.Bold
)

-- equivalent calls inferred from this helper; original call sites unknown
local function formatPrice(p: number?)
	if p == nil then
		return "?"
	end

	return (tostring(p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function createPriceRow(name: string, p: number, textSize: number, color7: Color3, rbxassetfontsfamiliesBuilderSansjson4, priceInRobux: number?)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.AutomaticSize = Enum.AutomaticSize.XY
	frame.Size = UDim2.fromOffset(0, 0)
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Padding = UDim.new(0, 4)
	uIListLayout.Parent = frame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "RobuxIcon"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxasset://textures/ui/common/robux.png"
	imageLabel.ImageColor3 = color7
	imageLabel.Size = UDim2.fromOffset(p, p)
	imageLabel.LayoutOrder = 1
	imageLabel.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Amount"
	textLabel.BackgroundTransparency = 1
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.Size = UDim2.fromOffset(0, 0)
	textLabel.Text = formatPrice(priceInRobux)
	textLabel.TextColor3 = color7
	textLabel.TextSize = textSize
	textLabel.FontFace = rbxassetfontsfamiliesBuilderSansjson4
	textLabel.LayoutOrder = 2
	textLabel.Parent = frame
	return frame
end

function FakePurchasePromptView.new(promptData)
	return (setmetatable({
		_promptData = promptData,
		_janitor = Janitor.new(),
		_hasResolved = false
	}, FakePurchasePromptView))
end

function FakePurchasePromptView:Show(callback)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local function resolve(flag: boolean)
		if self._hasResolved then
			return
		end

		self._hasResolved = true
		callback(flag)
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FakePurchasePrompt"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1000
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self._janitor:Add(screenGui)
	local textButton = Instance.new("TextButton")
	textButton.Name = "Scrim"
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = color6
	textButton.BackgroundTransparency = 0.25
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.ZIndex = 1
	textButton.Parent = screenGui
	local imageButton = Instance.new("ImageButton")
	imageButton.Name = "Sheet"
	imageButton.Image = ""
	imageButton.AutoButtonColor = false
	imageButton.Selectable = false
	imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
	imageButton.Position = UDim2.fromScale(0.5, 0.5)
	imageButton.Size = UDim2.new(1, -40, 0, 0)
	imageButton.AutomaticSize = Enum.AutomaticSize.Y
	imageButton.BackgroundColor3 = color
	imageButton.ZIndex = 2
	imageButton.Parent = screenGui
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 16)
	uICorner.Parent = imageButton
	local uISizeConstraint = Instance.new("UISizeConstraint")
	uISizeConstraint.MaxSize = Vector2.new(480, 1e999)
	uISizeConstraint.Parent = imageButton
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Vertical
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = imageButton
	local frame = Instance.new("Frame")
	frame.Name = "Header"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 56)
	frame.LayoutOrder = 1
	frame.Parent = imageButton
	local frame2 = Instance.new("Frame")
	frame2.Name = "BottomBorder"
	frame2.BackgroundColor3 = color5
	frame2.BorderSizePixel = 0
	frame2.AnchorPoint = Vector2.new(0, 1)
	frame2.Position = UDim2.fromScale(0, 1)
	frame2.Size = UDim2.new(1, 0, 0, 1)
	frame2.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.fromOffset(20, 0)
	textLabel.Size = UDim2.new(1, -80, 1, 0)
	textLabel.Text = "Buy item"
	textLabel.TextColor3 = color3
	textLabel.TextSize = 20
	textLabel.FontFace = rbxassetfontsfamiliesBuilderSansjson3
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = frame
	local imageButton2 = Instance.new("ImageButton")
	imageButton2.Name = "CloseButton"
	imageButton2.BackgroundTransparency = 1
	imageButton2.Image = ""
	imageButton2.AnchorPoint = Vector2.new(1, 0.5)
	imageButton2.Position = UDim2.new(1, -12, 0.5, 0)
	imageButton2.Size = UDim2.fromOffset(40, 40)
	imageButton2.Parent = frame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Icon"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxasset://textures/ui/InspectMenu/x.png"
	imageLabel.ImageColor3 = color3
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromOffset(16, 16)
	imageLabel.Parent = imageButton2
	local frame3 = Instance.new("Frame")
	frame3.Name = "Details"
	frame3.BackgroundTransparency = 1
	frame3.Size = UDim2.new(1, 0, 0, 112)
	frame3.LayoutOrder = 2
	frame3.Parent = imageButton
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "ItemIcon"
	imageLabel2.BackgroundColor3 = color5
	imageLabel2.Position = UDim2.fromOffset(20, 20)
	imageLabel2.Size = UDim2.fromOffset(72, 72)

	if self._promptData.iconAssetId ~= nil and self._promptData.iconAssetId > 0 then
		imageLabel2.Image = string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", self._promptData.iconAssetId)
	end

	imageLabel2.Parent = frame3
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(0, 8)
	uICorner2.Parent = imageLabel2
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "ItemName"
	textLabel2.BackgroundTransparency = 1
	textLabel2.Position = UDim2.fromOffset(108, 24)
	textLabel2.Size = UDim2.new(1, -128, 0, 40)
	textLabel2.Text = self._promptData.name
	textLabel2.TextColor3 = color3
	textLabel2.TextSize = 18
	textLabel2.FontFace = rbxassetfontsfamiliesBuilderSansjson2
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.TextYAlignment = Enum.TextYAlignment.Top
	textLabel2.TextWrapped = true
	textLabel2.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel2.Parent = frame3
	local priceRow = createPriceRow(
		"ItemPrice",
		16,
		16,
		color4,
		rbxassetfontsfamiliesBuilderSansjson,
		self._promptData.priceInRobux
	)
	priceRow.Position = UDim2.fromOffset(108, 66)
	priceRow.Parent = frame3
	local frame4 = Instance.new("Frame")
	frame4.Name = "Actions"
	frame4.BackgroundTransparency = 1
	frame4.Size = UDim2.new(1, 0, 0, 0)
	frame4.AutomaticSize = Enum.AutomaticSize.Y
	frame4.LayoutOrder = 3
	frame4.Parent = imageButton
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingTop = UDim.new(0, 4)
	uIPadding.PaddingBottom = UDim.new(0, 20)
	uIPadding.PaddingLeft = UDim.new(0, 20)
	uIPadding.PaddingRight = UDim.new(0, 20)
	uIPadding.Parent = frame4
	local uIListLayout2 = Instance.new("UIListLayout")
	uIListLayout2.FillDirection = Enum.FillDirection.Vertical
	uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout2.Padding = UDim.new(0, 12)
	uIListLayout2.Parent = frame4
	local textButton2 = Instance.new("TextButton")
	textButton2.Name = "BuyButton"
	textButton2.AutoButtonColor = true
	textButton2.BackgroundColor3 = color2
	textButton2.Size = UDim2.new(1, 0, 0, 40)
	textButton2.Text = "Buy"
	textButton2.TextColor3 = color3
	textButton2.TextSize = 16
	textButton2.FontFace = rbxassetfontsfamiliesBuilderSansjson2
	textButton2.LayoutOrder = 1
	textButton2.Parent = frame4
	local uICorner3 = Instance.new("UICorner")
	uICorner3.CornerRadius = UDim.new(0, 8)
	uICorner3.Parent = textButton2
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "Disclaimer"
	textLabel3.BackgroundTransparency = 1
	textLabel3.AutomaticSize = Enum.AutomaticSize.Y
	textLabel3.Size = UDim2.new(1, 0, 0, 0)
	textLabel3.Text = "This is a FAKE test purchase. No Robux will be charged."
	textLabel3.TextColor3 = color4
	textLabel3.TextSize = 12
	textLabel3.FontFace = rbxassetfontsfamiliesBuilderSansjson
	textLabel3.TextWrapped = true
	textLabel3.LayoutOrder = 2
	textLabel3.Parent = frame4
	self._janitor:Add(textButton2.Activated:Connect(function()
		if self._hasResolved then
			return
		end

		self._hasResolved = true
		callback(true)
	end))
	self._janitor:Add(imageButton2.Activated:Connect(function()
		if self._hasResolved then
			return
		end

		self._hasResolved = true
		callback(false)
	end))
	self._janitor:Add(textButton.Activated:Connect(function()
		if self._hasResolved then
			return
		end

		self._hasResolved = true
		callback(false)
	end))
	screenGui.Parent = playerGui
end

function FakePurchasePromptView:Destroy()
	self._janitor:Destroy()
end

return FakePurchasePromptView