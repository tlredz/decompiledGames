local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Numbers = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Numbers"))
local v = { Color3.fromRGB(255, 215, 60), Color3.fromRGB(200, 210, 225), Color3.fromRGB(205, 140, 85) }
local color = Color3.fromRGB(255, 215, 90)
local _ = { 0.34, 0.28, 0.28 }
local v2 = { 2, 1, 3 }
local v3 = {}
local CoinBattleLeaderboardUI = {}
CoinBattleLeaderboardUI.__index = CoinBattleLeaderboardUI

local function formatCoins(coins: number)
	return Numbers.formatNumber(coins)
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

function CoinBattleLeaderboardUI.new(options)
	local v4 = options or {}
	local self = setmetatable({}, CoinBattleLeaderboardUI)
	self._title = v4.title or "COIN BATTLE"
	self._displayOrder = v4.displayOrder or 10
	self:_build()
	return self
end

function CoinBattleLeaderboardUI:_build()
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
	frame.Position = UDim2.fromScale(0.5, 0.08)
	frame.Size = UDim2.fromScale(0.88, 0.15)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	local uIPadding = Instance.new("UIPadding", frame)
	uIPadding.PaddingTop = UDim.new(0.03, 0)
	uIPadding.PaddingBottom = UDim.new(0.03, 0)
	uIPadding.PaddingLeft = UDim.new(0.025, 0)
	uIPadding.PaddingRight = UDim.new(0.025, 0)
	local uISizeConstraint = Instance.new("UISizeConstraint", frame)
	uISizeConstraint.MinSize = Vector2.new(0, 80)
	uISizeConstraint.MaxSize = Vector2.new(9999999, 350)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Header"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 0.18)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = self._title
	textLabel.TextColor3 = color
	textLabel.TextScaled = true
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "PhaseText"
	textLabel2.BackgroundTransparency = 1
	textLabel2.Position = UDim2.fromScale(0, 0.18)
	textLabel2.Size = UDim2.fromScale(1, 0.14)
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.Text = ""
	textLabel2.TextColor3 = color
	textLabel2.TextScaled = true
	textLabel2.Parent = frame
	self._phaseLabel = textLabel2
	local frame2 = Instance.new("Frame")
	frame2.Name = "TopSlots"
	frame2.BackgroundTransparency = 1
	frame2.AnchorPoint = Vector2.new(0.5, 1)
	frame2.Position = UDim2.fromScale(0.5, 1.35)
	frame2.Size = UDim2.fromScale(0.8, 0.8)
	frame2.Parent = frame
	local uIListLayout = Instance.new("UIListLayout", frame2)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	uIListLayout.Padding = UDim.new(0.01, 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self._slotsContainer = frame2
	self._topSlots = {}
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "SelfStats"
	textLabel3.BackgroundTransparency = 1
	textLabel3.AnchorPoint = Vector2.new(0.5, 0)
	textLabel3.Position = UDim2.fromScale(0.5, 1.42)
	textLabel3.Size = UDim2.fromScale(0.95, 0.16)
	textLabel3.Font = Enum.Font.GothamMedium
	textLabel3.Text = ""
	textLabel3.TextColor3 = Color3.fromRGB(220, 225, 240)
	textLabel3.TextScaled = true
	textLabel3.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel3.Visible = false
	textLabel3.Parent = frame
	self._selfLabel = textLabel3
end

function CoinBattleLeaderboardUI:_ensureTopSlot(rank: number)
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
	textLabel.TextColor3 = Color3.fromRGB(255, 220, 90)
	textLabel.TextScaled = true
	textLabel.Parent = frame
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

function CoinBattleLeaderboardUI:_applySlot(state, p, p2: number?)
	local userId = not p and 0 or p.userId or 0

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
	local coins = p and p.coins or 0
	coinsLabel.Text = Numbers.formatNumber(coins)
	state.slot.Visible = true
	local thickness = state.rank == 1 and 3 or 2

	if p2 and userId == p2 and userId > 0 then
		state.stroke.Thickness = thickness + 1
	else
		state.stroke.Thickness = thickness
	end
end

function CoinBattleLeaderboardUI:_updateSelfRow(list, p2: number?)
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
		_selfLabel.Text = string.format("%d - %s - %s", v4.rank, v4.name, formatCoins(v4.coins))
		_selfLabel.Visible = true
	else
		if not p2 then
			_selfLabel.Visible = false
			return
		end

		local playerByUserId = Players:GetPlayerByUserId(p2)
		_selfLabel.Text = string.format("- - %s - 0", playerByUserId and playerByUserId.Name or "You")
		_selfLabel.Visible = true
	end
end

function CoinBattleLeaderboardUI:Update(list, p: number?)
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

function CoinBattleLeaderboardUI:SetPhaseText(value: string)
	if self._phaseLabel then
		self._phaseLabel.Text = value or ""
	end
end

function CoinBattleLeaderboardUI:Destroy()
	if self._screen then
		self._screen:Destroy()
		self._screen = nil
	end

	self._slotsContainer = nil
	self._phaseLabel = nil
	self._selfLabel = nil
	self._topSlots = {}
end

return CoinBattleLeaderboardUI