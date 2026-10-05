local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeamBattleCountdownUI = {}
TeamBattleCountdownUI.__index = TeamBattleCountdownUI

function TeamBattleCountdownUI.new(options)
	local self = setmetatable({}, TeamBattleCountdownUI)
	self._displayOrder = (options or {}).displayOrder or 11
	self:_build()
	return self
end

function TeamBattleCountdownUI:_build()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		warn("[TeamBattleCountdownUI] PlayerGui introuvable")
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeamBattleCountdownUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = self._displayOrder
	screenGui.Parent = playerGui
	self._screen = screenGui
	local frame = Instance.new("Frame")
	frame.Name = "Container"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.38)
	frame.Size = UDim2.fromScale(0.9, 0.18)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui
	self._container = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Number"
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.42)
	textLabel.Size = UDim2.fromScale(1, 0.6)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.Text = ""
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Parent = frame
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Thickness = 4
	uIStroke.Color = Color3.fromRGB(80, 160, 255)
	uIStroke.Transparency = 0.1
	self._numberLabel = textLabel
	self._numberStroke = uIStroke
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Go"
	textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel2.Position = UDim2.fromScale(0.5, 0.5)
	textLabel2.Size = UDim2.fromScale(0.95, 0.55)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Font = Enum.Font.GothamBlack
	textLabel2.Text = ""
	textLabel2.TextColor3 = Color3.fromRGB(255, 230, 80)
	textLabel2.TextScaled = true
	textLabel2.Visible = false
	textLabel2.Parent = frame
	local uIStroke2 = Instance.new("UIStroke", textLabel2)
	uIStroke2.Thickness = 3.5
	uIStroke2.Color = Color3.fromRGB(255, 255, 255)
	uIStroke2.Transparency = 0.15
	self._goLabel = textLabel2
	self._goStroke = uIStroke2
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "Subtitle"
	textLabel3.AnchorPoint = Vector2.new(0.5, 0)
	textLabel3.Position = UDim2.fromScale(0.5, 0)
	textLabel3.Size = UDim2.fromScale(1, 0.14)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Font = Enum.Font.GothamBold
	textLabel3.Text = "TEAM BATTLE"
	textLabel3.TextColor3 = Color3.fromRGB(170, 200, 255)
	textLabel3.TextScaled = true
	textLabel3.Parent = frame
	self._subtitle = textLabel3
end

function TeamBattleCountdownUI:SetSeconds(p2: number)
	if not self._numberLabel then
		return
	end

	self._goLabel.Visible = false
	self._numberLabel.Visible = true
	self._numberLabel.Text = tostring(p2)
	local v = p2 % 2 * 0.08 + 1
	self._numberLabel.Size = UDim2.fromScale(1, v * 0.6)
	TweenService:Create(self._numberLabel, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1, 0.6)
	}):Play()
end

function TeamBattleCountdownUI:ShowGo(text: string)
	if not (self._goLabel and self._numberLabel) then
		return
	end

	self._numberLabel.Visible = false
	self._goLabel.Visible = true
	self._goLabel.Text = text
	self._goLabel.TextTransparency = 1
	self._goStroke.Transparency = 1
	self._goLabel.Size = UDim2.fromScale(0.85, 0.45)
	TweenService:Create(self._goLabel, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		Size = UDim2.fromScale(0.95, 0.55)
	}):Play()
	TweenService:Create(self._goStroke, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0.15
	}):Play()
end

function TeamBattleCountdownUI:Hide()
	if self._screen then
		self._screen.Enabled = false
	end
end

function TeamBattleCountdownUI:Show()
	if self._screen then
		self._screen.Enabled = true
	end
end

function TeamBattleCountdownUI:Destroy()
	if self._screen then
		self._screen:Destroy()
		self._screen = nil
	end

	self._container = nil
	self._numberLabel = nil
	self._numberStroke = nil
	self._goLabel = nil
	self._goStroke = nil
	self._subtitle = nil
end

return TeamBattleCountdownUI