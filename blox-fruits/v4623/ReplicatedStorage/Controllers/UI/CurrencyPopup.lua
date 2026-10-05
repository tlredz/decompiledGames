local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local color = Color3.fromRGB(112, 255, 60)

local function findCurrencyAnchor(playerGui)
	local currencyContainer = playerGui:FindFirstChild("CurrencyContainer", true)

	if currencyContainer and currencyContainer:IsA("GuiObject") then
		return currencyContainer
	end

	local beli = playerGui:FindFirstChild("Beli", true)
	local parent

	if beli and beli:IsA("TextLabel") then
		parent = beli.Parent
	end

	if parent and parent:IsA("GuiObject") then
		return parent
	end

	return nil
end

local function getScreen(playerGui)
	local currencyPopups = playerGui:FindFirstChild("CurrencyPopups")

	if currencyPopups and currencyPopups:IsA("ScreenGui") then
		return currencyPopups
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CurrencyPopups"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 1
	screenGui.Parent = playerGui
	return screenGui
end

return {
	show = function(text: string, color2: Color3?)
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

		if not playerGui then
			return
		end

		local currencyAnchor = findCurrencyAnchor(playerGui)

		if not currencyAnchor then
			return
		end

		local absoluteSize = currencyAnchor.AbsoluteSize
		local v = absoluteSize * 2.1
		local v2 = currencyAnchor.AbsolutePosition.Y + absoluteSize.Y / 2 - absoluteSize.Y * 0.85
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Popup"
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.AutoLocalize = false
		textLabel.BackgroundTransparency = 1
		textLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
		textLabel.Position = UDim2.new(0.2, 0, 0, v2)
		textLabel.Size = UDim2.fromOffset(v.X, v.Y)
		textLabel.Text = text
		textLabel.TextColor3 = color2 or color
		textLabel.TextScaled = true
		textLabel.TextStrokeTransparency = 1
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = Color3.new(0, 0, 0)
		uIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
		uIStroke.Thickness = 0.025
		uIStroke.Parent = textLabel
		textLabel.Parent = getScreen(playerGui)
		local tweenInfo = TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(textLabel, tweenInfo, {
			Position = UDim2.new(0.2, 0, 0, v2 - absoluteSize.Y * 1.4),
			TextTransparency = 1
		}):Play()
		TweenService:Create(uIStroke, tweenInfo, {
			Transparency = 1
		}):Play()
		Debris:AddItem(textLabel, 1.1)
	end
}