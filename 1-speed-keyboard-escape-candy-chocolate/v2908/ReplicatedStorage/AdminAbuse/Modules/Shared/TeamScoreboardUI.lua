local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Numbers = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Numbers"))
local uDim = UDim2.fromScale(0.5, 0.1)
local uDim2 = UDim2.fromScale(0.5, -0.12)
local TeamScoreboardUI = {}
TeamScoreboardUI.__index = TeamScoreboardUI

local function formatWins(p: number)
	return Numbers.formatNumber(p)
end

function TeamScoreboardUI.new(options)
	local v = options or {}
	local self = setmetatable({}, TeamScoreboardUI)
	self._title = v.title or "TEAM BATTLE"
	self._displayOrder = v.displayOrder or 10
	self._rows = {}
	self:_build()
	return self
end

function TeamScoreboardUI:_build()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		warn("[TeamScoreboardUI] PlayerGui introuvable")
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeamScoreboardUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = self._displayOrder
	screenGui.Parent = playerGui
	self._screen = screenGui
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = uDim2
	frame.Size = UDim2.fromScale(0.45, 0.2)
	frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	self._container = frame
	self._restPosition = uDim
	self._hiddenPosition = uDim2
	local uISizeConstraint = Instance.new("UISizeConstraint", frame)
	uISizeConstraint.MinSize = Vector2.new(0, 100)
	uISizeConstraint.MaxSize = Vector2.new(9999999, 350)
	local uICorner = Instance.new("UICorner", frame)
	uICorner.CornerRadius = UDim.new(0.03, 0)
	local uIPadding = Instance.new("UIPadding", frame)
	uIPadding.PaddingTop = UDim.new(0.06, 0)
	uIPadding.PaddingBottom = UDim.new(0.06, 0)
	uIPadding.PaddingLeft = UDim.new(0.025, 0)
	uIPadding.PaddingRight = UDim.new(0.025, 0)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Header"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 0.24)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = self._title
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "PhaseText"
	textLabel2.BackgroundTransparency = 1
	textLabel2.Position = UDim2.fromScale(0, 0.24)
	textLabel2.Size = UDim2.fromScale(1, 0.2)
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.Text = ""
	textLabel2.TextColor3 = Color3.fromRGB(210, 210, 225)
	textLabel2.TextScaled = true
	textLabel2.Parent = frame
	self._phaseLabel = textLabel2
	local frame2 = Instance.new("Frame")
	frame2.Name = "Rows"
	frame2.BackgroundTransparency = 1
	frame2.Position = UDim2.fromScale(0, 0.44)
	frame2.Size = UDim2.fromScale(1, 0.56)
	frame2.Parent = frame
	local uIListLayout = Instance.new("UIListLayout", frame2)
	uIListLayout.FillDirection = Enum.FillDirection.Vertical
	uIListLayout.Padding = UDim.new(0.04, 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self._rowsContainer = frame2
end

function TeamScoreboardUI:_ensureRow(data, layoutOrder: number)
	local _row = self._rows[data.id]

	if _row then
		return _row
	end

	local frame = Instance.new("Frame")
	frame.Name = "Team" .. tostring(data.id)
	frame.Size = UDim2.fromScale(1, 0.25)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.LayoutOrder = layoutOrder
	frame.Parent = self._rowsContainer
	local uICorner = Instance.new("UICorner", frame)
	uICorner.CornerRadius = UDim.new(0.25, 0)
	local frame2 = Instance.new("Frame")
	frame2.Name = "Accent"
	frame2.Size = UDim2.fromScale(0.02, 1)
	frame2.BackgroundColor3 = data.color
	frame2.BorderSizePixel = 0
	frame2.Parent = frame
	local uICorner_2 = Instance.new("UICorner", frame2)
	uICorner_2.CornerRadius = UDim.new(0.25, 0)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Name"
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.fromScale(0.05, 0)
	textLabel.Size = UDim2.fromScale(0.58, 1)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = data.displayName
	textLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextScaled = true
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Score"
	textLabel2.AnchorPoint = Vector2.new(1, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Position = UDim2.fromScale(1, 0)
	textLabel2.Size = UDim2.fromScale(0.38, 1)
	textLabel2.Font = Enum.Font.GothamBold
	textLabel2.Text = "0"
	textLabel2.TextColor3 = data.color
	textLabel2.TextXAlignment = Enum.TextXAlignment.Right
	textLabel2.TextScaled = true
	textLabel2.Parent = frame
	local v = {
		row = frame,
		nameLabel = textLabel,
		scoreLabel = textLabel2,
		accent = frame2
	}
	self._rows[data.id] = v
	return v
end

function TeamScoreboardUI:Update(list, p: number?)
	if not self._rowsContainer or type(list) ~= "table" then
		return
	end

	for i, v in ipairs(list) do
		local _ensureRow = self:_ensureRow(v, i)
		_ensureRow.nameLabel.Text = v.displayName
		local scoreLabel = _ensureRow.scoreLabel
		local wins = v.wins or 0
		scoreLabel.Text = Numbers.formatNumber(wins)
		_ensureRow.accent.BackgroundColor3 = v.color
		_ensureRow.scoreLabel.TextColor3 = v.color
		local v2

		if p == nil then
			v2 = false
		else
			v2 = v.id == p
		end

		_ensureRow.row.BackgroundColor3 = v2 and Color3.fromRGB(52, 52, 74) or Color3.fromRGB(30, 30, 42)
		_ensureRow.nameLabel.Text = v2 and "★ " .. v.displayName or v.displayName
	end
end

function TeamScoreboardUI:SetPhaseText(value: string)
	if self._phaseLabel then
		self._phaseLabel.Text = value or ""
	end
end

function TeamScoreboardUI:HideAbove()
	if self._container then
		self._container.Position = self._hiddenPosition or uDim2
	end
end

function TeamScoreboardUI:DropIn(value: number?)
	if not self._container then
		return
	end

	local _restPosition = self._restPosition or uDim
	self._container.Position = self._hiddenPosition or uDim2
	TweenService:Create(
		self._container,
		TweenInfo.new(value or 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Position = _restPosition
		}
	):Play()
end

function TeamScoreboardUI:Destroy()
	if self._screen then
		self._screen:Destroy()
		self._screen = nil
	end

	table.clear(self._rows)
	self._rowsContainer = nil
	self._phaseLabel = nil
	self._container = nil
end

return TeamScoreboardUI