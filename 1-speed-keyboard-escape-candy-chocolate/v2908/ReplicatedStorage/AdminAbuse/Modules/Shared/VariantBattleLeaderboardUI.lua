local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Numbers = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Numbers"))
local v = { Color3.fromRGB(255, 215, 60), Color3.fromRGB(200, 210, 225), Color3.fromRGB(205, 140, 85) }
local color = Color3.fromRGB(255, 215, 90)
local _ = { 0.34, 0.28, 0.28 }
local v2 = { 2, 1, 3 }
local v3 = {}
local VariantBattleLeaderboardUI = {}
VariantBattleLeaderboardUI.__index = VariantBattleLeaderboardUI

local function formatCoins(p: number)
	return Numbers.formatNumber(p)
end

local function loadHeadshot(p: number, p2)
	if p <= 0 then
		p2.Image = ""
		return
	end

	local image = v3[p]

	if image then
		p2.Image = image
	else
		task.spawn(function()
			local success, result = pcall(function()
				return Players:GetUserThumbnailAsync(p, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			end)

			if success and result and p2.Parent then
				v3[p] = result
				p2.Image = result
			end
		end)
	end
end

local function findLocalEntry(list, p: number?)
	if not p then
		return nil
	end

	for _, v4 in ipairs(list) do
		if v4.userId == p then
			return v4
		end
	end

	return nil
end

function VariantBattleLeaderboardUI.new(options)
	local v4 = options or {}
	local self = setmetatable({}, VariantBattleLeaderboardUI)
	self._title = v4.title or "COIN BATTLE"
	self._displayOrder = v4.displayOrder or 10
	self._accentColor = v4.accentColor or color
	self._secondaryColor = v4.secondaryColor or Color3.fromRGB(255, 145, 55)
	self._scoreLabel = v4.scoreLabel or "COINS"
	self._icon = v4.icon
	self:_build()
	return self
end

function VariantBattleLeaderboardUI:_build()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		warn("[CoinBattleLeaderboardUI] PlayerGui introuvable")
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CoinBattleLeaderboardUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = self._displayOrder
	screenGui.Parent = playerGui
	self._screen = screenGui
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.fromScale(0.5, 0.06)
	frame.Size = UDim2.fromScale(0.56, 0.17)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	local uIPadding = Instance.new("UIPadding", frame)
	uIPadding.PaddingTop = UDim.new(0.03, 0)
	uIPadding.PaddingBottom = UDim.new(0.03, 0)
	uIPadding.PaddingLeft = UDim.new(0.025, 0)
	uIPadding.PaddingRight = UDim.new(0.025, 0)
	local uISizeConstraint = Instance.new("UISizeConstraint", frame)
	uISizeConstraint.MinSize = Vector2.new(360, 90)
	uISizeConstraint.MaxSize = Vector2.new(680, 350)
	local frame2 = Instance.new("Frame")
	frame2.Name = "TitleRow"
	frame2.AnchorPoint = Vector2.new(0.5, 0)
	frame2.Position = UDim2.fromScale(0.5, 0)
	frame2.Size = UDim2.fromScale(0.72, 0.24)
	frame2.BackgroundTransparency = 1
	frame2.Parent = frame
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = 0.7
	uIScale.Parent = frame2
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Header"
	textLabel.BackgroundTransparency = 1
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.Size = UDim2.fromScale(0.62, 1)
	textLabel.FontFace = Font.new(
		"rbxasset://fonts/families/Montserrat.json",
		Enum.FontWeight.Heavy,
		Enum.FontStyle.Normal
	)
	textLabel.Text = self._title
	textLabel.TextColor3 = self._accentColor
	textLabel.TextScaled = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.ZIndex = 2
	textLabel.Parent = frame2
	local uIStroke = Instance.new("UIStroke", textLabel)
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.Thickness = 1.5
	uIStroke.Transparency = 0.35

	if self._icon then
		for i, v4 in ipairs({ 0.16, 0.84 }) do
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = i == 1 and "LeftEventIcon" or "RightEventIcon"
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Position = UDim2.fromScale(v4, 0.5)
			imageLabel.Size = UDim2.fromScale(0.19, 0.96)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = self._icon
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.ZIndex = 2
			imageLabel.Parent = frame2
			local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			uIAspectRatioConstraint.AspectRatio = 1
			uIAspectRatioConstraint.Parent = imageLabel
		end
	end

	TweenService:Create(uIScale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "PhaseText"
	textLabel2.BackgroundTransparency = 1
	textLabel2.Position = UDim2.fromScale(0, 0.24)
	textLabel2.Size = UDim2.fromScale(1, 0.14)
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.Text = ""
	textLabel2.TextColor3 = self._secondaryColor
	textLabel2.TextScaled = true
	textLabel2.ZIndex = 2
	textLabel2.Parent = frame
	local uIStroke2 = Instance.new("UIStroke", textLabel2)
	uIStroke2.Color = Color3.new(0, 0, 0)
	uIStroke2.Thickness = 1.5
	uIStroke2.Transparency = 0.2
	self._phaseLabel = textLabel2
	local frame3 = Instance.new("Frame")
	frame3.Name = "TopSlots"
	frame3.BackgroundTransparency = 1
	frame3.AnchorPoint = Vector2.new(0.5, 1)
	frame3.Position = UDim2.fromScale(0.5, 1.18)
	frame3.Size = UDim2.fromScale(0.78, 0.74)
	frame3.Parent = frame
	local uIListLayout = Instance.new("UIListLayout", frame3)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	uIListLayout.Padding = UDim.new(0.01, 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self._slotsContainer = frame3
	self._topSlots = {}
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "SelfStats"
	textLabel3.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
	textLabel3.BackgroundTransparency = 0.15
	textLabel3.AnchorPoint = Vector2.new(0.5, 0)
	textLabel3.Position = UDim2.fromScale(0.5, 1.28)
	textLabel3.Size = UDim2.fromScale(0.95, 0.16)
	textLabel3.Font = Enum.Font.GothamMedium
	textLabel3.Text = ""
	textLabel3.TextColor3 = Color3.fromRGB(220, 225, 240)
	textLabel3.TextScaled = true
	textLabel3.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel3.Visible = false
	textLabel3.Parent = frame
	local uICorner = Instance.new("UICorner", textLabel3)
	uICorner.CornerRadius = UDim.new(1, 0)
	local uIStroke3 = Instance.new("UIStroke", textLabel3)
	uIStroke3.Color = Color3.new(0, 0, 0)
	uIStroke3.Thickness = 1.5
	uIStroke3.Transparency = 0.2
	self._selfLabel = textLabel3
end

function VariantBattleLeaderboardUI:_ensureTopSlot(rank: number)
	local _topSlot = self._topSlots[rank]

	if _topSlot then
		return _topSlot
	end

	local color2 = v[rank] or Color3.fromRGB(120, 120, 140)
	local v5 = rank == 1 and 1 or 0.85
	local frame = Instance.new("Frame")
	frame.Name = "Top" .. rank
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(v5, v5)
	frame.LayoutOrder = v2[rank] or rank
	frame.Parent = self._slotsContainer
	frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Head"
	imageLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
	imageLabel.BackgroundTransparency = 0.15
	imageLabel.Size = UDim2.fromScale(0.78, 0.78)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0)
	imageLabel.Position = UDim2.fromScale(0.5, 0)
	imageLabel.ScaleType = Enum.ScaleType.Crop
	imageLabel.BorderSizePixel = 0
	imageLabel.Parent = frame
	local uICorner = Instance.new("UICorner", imageLabel)
	uICorner.CornerRadius = UDim.new(1, 0)
	local uIStroke = Instance.new("UIStroke", imageLabel)
	uIStroke.Color = color2
	uIStroke.Thickness = rank == 1 and 2 or 1.5
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Coins"
	textLabel.BackgroundTransparency = 1
	textLabel.AnchorPoint = Vector2.new(0.5, 1)
	textLabel.Position = UDim2.fromScale(0.5, 1)
	textLabel.Size = UDim2.fromScale(1.1, 0.2)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = "0"
	textLabel.TextColor3 = self._accentColor
	textLabel.TextScaled = true
	textLabel.Parent = frame
	local uIStroke2 = Instance.new("UIStroke", textLabel)
	uIStroke2.Color = Color3.new(0, 0, 0)
	uIStroke2.Thickness = 1.5
	uIStroke2.Transparency = 0.2
	local v6 = {
		rank = rank,
		slot = frame,
		head = imageLabel,
		coinsLabel = textLabel,
		stroke = uIStroke,
		userId = 0
	}
	self._topSlots[rank] = v6
	return v6
end

function VariantBattleLeaderboardUI:_applySlot(state, p2, p3: number?)
	local userId = not p2 and 0 or p2.userId or 0

	if state.userId ~= userId then
		state.userId = userId
		local head = state.head

		if userId <= 0 then
			head.Image = ""
		else
			local image = v3[userId]

			if image then
				head.Image = image
			else
				task.spawn(function()
					local success, result = pcall(function()
						return Players:GetUserThumbnailAsync(
							userId,
							Enum.ThumbnailType.HeadShot,
							Enum.ThumbnailSize.Size100x100
						)
					end)

					if success and result and head.Parent then
						v3[userId] = result
						head.Image = result
					end
				end)
			end
		end
	end

	local coinsLabel = state.coinsLabel
	local coins = p2 and p2.coins or 0
	coinsLabel.Text = string.format("%s %s", Numbers.formatNumber(coins), self._scoreLabel)
	state.slot.Visible = true
	local thickness = state.rank == 1 and 3 or 2

	if p3 and userId == p3 and userId > 0 then
		state.stroke.Thickness = thickness + 1
	else
		state.stroke.Thickness = thickness
	end
end

function VariantBattleLeaderboardUI:_updateSelfRow(list, p2: number?)
	local _selfLabel = self._selfLabel

	if not _selfLabel then
		return
	end

	local v4

	if p2 then
		for _, v6 in ipairs(list) do
			if v6.userId ~= p2 then
				continue
			end

			v4 = v6
			break
		end
	end

	if v4 and v4.rank and v4.rank <= 3 then
		_selfLabel.Visible = false
	elseif v4 then
		local rank = v4.rank
		local name = v4.name
		local coins = v4.coins
		_selfLabel.Text = string.format(
			"%d  •  %s  •  %s %s",
			rank,
			name,
			Numbers.formatNumber(coins),
			self._scoreLabel
		)
		_selfLabel.Visible = true
	else
		if not p2 then
			_selfLabel.Visible = false
			return
		end

		local playerByUserId = Players:GetPlayerByUserId(p2)
		_selfLabel.Text = string.format(
			"—  •  %s  •  0 %s",
			playerByUserId and playerByUserId.Name or "You",
			self._scoreLabel
		)
		_selfLabel.Visible = true
	end
end

function VariantBattleLeaderboardUI:Update(list, p: number?)
	if not self._slotsContainer or type(list) ~= "table" then
		return
	end

	local v4 = {}

	for _, v5 in ipairs(list) do
		if not v5.rank or not (v5.rank <= 3) or v4[v5.rank] then
			continue
		end

		v4[v5.rank] = v5
	end

	for i = 1, 3 do
		local _ensureTopSlot = self:_ensureTopSlot(i)
		_ensureTopSlot.stroke.Color = v[i] or Color3.fromRGB(120, 120, 140)
		self:_applySlot(_ensureTopSlot, v4[i], p)
	end

	self:_updateSelfRow(list, p)
end

function VariantBattleLeaderboardUI:SetPhaseText(value: string)
	if self._phaseLabel then
		self._phaseLabel.Text = value or ""
	end
end

function VariantBattleLeaderboardUI:Destroy()
	if self._screen then
		self._screen:Destroy()
		self._screen = nil
	end

	self._slotsContainer = nil
	self._phaseLabel = nil
	self._selfLabel = nil
	self._topSlots = {}
end

return VariantBattleLeaderboardUI