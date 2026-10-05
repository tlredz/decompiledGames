local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local dataViewerAction = ReplicatedStorage:WaitForChild("DataViewerAction")
local v = {
	{
		Name = "Stats",
		Color = Color3.fromRGB(80, 180, 255),
		Keys = {
			"Level",
			"XP",
			"TotalXP",
			"Wins",
			"Rebirths",
			"Multiplier",
			"StepBonus",
			"SpeedBoostTier",
			"ExtraSpeedBoostTier",
			"CustomWalkSpeed",
			"Checkpoint"
		}
	},
	{
		Name = "Time",
		Color = Color3.fromRGB(100, 255, 150),
		Keys = {
			"firstJoin",
			"timePlayed",
			"SocialCodeClaimed",
			"SocialResetAppliedAt",
			"MedalRewardClaimed",
			"CheckInfinityTrailGlitch",
			"CheckInfinityTrailGlitch2"
		}
	},
	{
		Name = "Access",
		Color = Color3.fromRGB(255, 200, 80),
		Keys = {
			"ManualGoldAccess",
			"ManualDiamondAccess",
			"ManualCandyAccess",
			"ManualAdminAccess",
			"ManualInfinityTrailAccess",
			"VIP_ID",
			"X2Boost",
			"GiftClaimed"
		}
	},
	{
		Name = "Trails",
		Color = Color3.fromRGB(200, 130, 255),
		Keys = {
			"EquippedTrail",
			"OwnedTrails",
			"EquippedAura",
			"OwnedAuras"
		}
	},
	{
		Name = "Items",
		Color = Color3.fromRGB(255, 150, 100),
		Keys = { "Items", "EquippedItems" }
	},
	{
		Name = "Gifts",
		Color = Color3.fromRGB(255, 130, 180),
		Keys = {
			"GiftSent",
			"GiftReceived",
			"GamepassReceived",
			"GiftedCosmetics"
		}
	},
	{
		Name = "History",
		Color = Color3.fromRGB(255, 80, 80),
		Keys = { "CheatHistory", "CheatHistory2", "PurchaseHistory" }
	},
	{
		Name = "Other",
		Color = Color3.fromRGB(180, 180, 180),
		Keys = {
			"TikfinityBinds",
			"RSVPBoost",
			"CCPermissions",
			"RefundedItems",
			"AfkPosition"
		}
	}
}
local v2 = {
	{ 1e18, "Qi" },
	{ 1000000000000000, "Qa" },
	{ 1000000000000, "T" },
	{ 1000000000, "B" },
	{ 1000000, "M" },
	{ 1000, "K" }
}

local function formatNum(value)
	if type(value) ~= "number" then
		return (tostring(value))
	end

	for _, v3 in ipairs(v2) do
		if math.abs(value) >= v3[1] then
			return string.format("%.2f", value / v3[1]):gsub("%.?0+$", "") .. v3[2]
		end
	end

	return (tostring(math.floor(value * 100) / 100))
end

local function formatTime(value)
	if type(value) ~= "number" or value <= 0 then
		return "0s"
	end

	local v3 = math.floor(value / 86400)
	local v4 = math.floor(value % 86400 / 3600)
	local v5 = math.floor(value % 3600 / 60)
	local v6 = math.floor(value % 60)

	if v3 > 0 then
		return string.format("%dj %dh %02dm", v3, v4, v5)
	end

	return string.format("%dh %02dm %02ds", v4, v5, v6)
end

local function formatDate(value)
	if type(value) == "number" and not (value <= 0) then
		return os.date("%d/%m/%Y %H:%M", value)
	end

	return "N/A"
end

local function formatValue(p, items)
	if p == "timePlayed" then
		return formatTime(items)
	end

	if p == "firstJoin" and type(items) == "number" and items > 0 or p == "SocialResetAppliedAt" and type(items) == "number" and items > 0 then
		return formatDate(items)
	end

	if (p == "TotalXP" or p == "Wins") and type(items) == "number" then
		return formatNum(items) .. "  (" .. tostring(items) .. ")"
	end

	if not (type(items) ~= "boolean" and type(items) ~= "number") then
		return (tostring(items))
	end

	if type(items) == "string" then
		return items
	end

	return (tostring(items))
end

local buildLines

buildLines = function(p, items, count, options)
	local depth = count or 0
	local result = options or {}
	local v4 = string.rep("    ", depth)

	if type(items) ~= "table" then
		table.insert(result, {
			Text = v4 .. tostring(p) .. " : " .. formatValue(p, items),
			Depth = depth
		})
		return result
	end

	if next(items) == nil then
		table.insert(result, {
			Text = v4 .. tostring(p) .. " : (vide)",
			Depth = depth
		})
		return result
	end

	table.insert(result, {
		Text = v4 .. tostring(p) .. " :",
		Depth = depth,
		IsHeader = true
	})
	local v5 = {}

	for k in pairs(items) do
		table.insert(v5, k)
	end

	table.sort(v5, function(a, b)
		return tostring(a) < tostring(b)
	end)

	for _, v6 in ipairs(v5) do
		if depth < 3 then
			buildLines(v6, items[v6], depth + 1, result)
		else
			table.insert(result, {
				Text = v4 .. "    " .. tostring(v6) .. " : " .. tostring(items[v6]),
				Depth = depth + 1
			})
		end
	end

	return result
end

local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyExisting()
	local dataViewerPanel = playerGui:FindFirstChild("DataViewerPanel")

	if dataViewerPanel then
		dataViewerPanel:Destroy()
	end
end

local function createEntry(parent, text, depth, isHeader, color)
	local textLabel = Instance.new("TextLabel", parent)
	textLabel.Size = UDim2.new(1, -10, 0, 22)
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.Font = isHeader and Enum.Font.GothamBold or Enum.Font.Gotham
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextScaled = true
	textLabel.RichText = true
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint", textLabel)
	uITextSizeConstraint.MaxTextSize = 12

	if isHeader and depth == 0 then
		textLabel.TextColor3 = color or Color3.fromRGB(255, 215, 0)
		textLabel.Text = text
		textLabel.Size = UDim2.new(1, -10, 0, 26)
	else
		if isHeader then
			textLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
		else
			textLabel.TextColor3 = Color3.fromRGB(170, 170, 185)
		end

		textLabel.Text = text
	end

	return textLabel
end

local function populateCategory(scrollingFrame, data, p)
	for _, guiObject in ipairs(scrollingFrame:GetChildren()) do
		if guiObject:IsA("TextLabel") or guiObject:IsA("Frame") then
			guiObject:Destroy()
		end
	end

	local v4 = v[p]

	if not v4 then
		return
	end

	local count = 0

	for _, key in ipairs(v4.Keys) do
		local v5 = data[key]
		local lines = buildLines(key, v5 == nil and "nil" or v5, 0)

		for _, line in ipairs(lines) do
			local entry = createEntry(scrollingFrame, line.Text, line.Depth, line.IsHeader, v4.Color)
			count += 1
			entry.LayoutOrder = count
		end

		local frame = Instance.new("Frame", scrollingFrame)
		frame.Name = "Sep"
		frame.Size = UDim2.new(1, -20, 0, 1)
		frame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		frame.BorderSizePixel = 0
		count += 1
		frame.LayoutOrder = count
	end
end

local function buildGUI(player)
	destroyExisting() -- equivalent call inferred; original call site unknown
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DataViewerPanel"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 125
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame", screenGui)
	frame.Name = "Background"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.4
	frame.BorderSizePixel = 0
	local frame2 = Instance.new("Frame", frame)
	frame2.Name = "Panel"
	frame2.Size = UDim2.new(0, 520, 0, 620)
	frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
	frame2.BorderSizePixel = 0
	local uICorner = Instance.new("UICorner", frame2)
	uICorner.CornerRadius = UDim.new(0, 14)
	local v4 = player.IsOnline and "  [EN LIGNE]" or "  [HORS LIGNE]"
	local v5 = player.IsOnline and "#44FF44" or "#FF6666"
	local textLabel = Instance.new("TextLabel", frame2)
	textLabel.Name = "Title"
	textLabel.Size = UDim2.new(1, -50, 0, 22)
	textLabel.Position = UDim2.new(0, 15, 0, 10)
	textLabel.BackgroundTransparency = 1
	textLabel.RichText = true
	textLabel.Text = string.format(
		"<font color=\"#FFD700\"><b>DATA:</b></font> %s <font color=\"#AAAAAA\">(%d)</font><font color=\"%s\">%s</font>",
		player.DisplayName,
		player.UserId,
		v5,
		v4
	)
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint", textLabel)
	uITextSizeConstraint.MaxTextSize = 16
	local textButton = Instance.new("TextButton", frame2)
	textButton.Name = "CloseBtn"
	textButton.Size = UDim2.new(0, 32, 0, 32)
	textButton.Position = UDim2.new(1, -40, 0, 6)
	textButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	textButton.Text = "X"
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.TextScaled = true
	textButton.Font = Enum.Font.GothamBold
	local uICorner_2 = Instance.new("UICorner", textButton)
	uICorner_2.CornerRadius = UDim.new(0, 6)
	textButton.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local absolutePosition = frame2.AbsolutePosition
			local absoluteSize = frame2.AbsoluteSize
			local position = input.Position

			if position.X < absolutePosition.X or position.X > absolutePosition.X + absoluteSize.X or position.Y < absolutePosition.Y or position.Y > absolutePosition.Y + absoluteSize.Y then
				screenGui:Destroy()
			end
		end
	end)
	local frame3 = Instance.new("Frame", frame2)
	frame3.Name = "TabFrame"
	frame3.Size = UDim2.new(1, -20, 0, 32)
	frame3.Position = UDim2.new(0, 10, 0, 38)
	frame3.BackgroundTransparency = 1
	local uIListLayout = Instance.new("UIListLayout", frame3)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.Padding = UDim.new(0, 4)
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	local scrollingFrame = Instance.new("ScrollingFrame", frame2)
	scrollingFrame.Name = "DataScroll"
	scrollingFrame.Size = UDim2.new(1, -20, 1, -82)
	scrollingFrame.Position = UDim2.new(0, 10, 0, 76)
	scrollingFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
	scrollingFrame.BackgroundTransparency = 0.3
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 4
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local uICorner_3 = Instance.new("UICorner", scrollingFrame)
	uICorner_3.CornerRadius = UDim.new(0, 8)
	local uIListLayout2 = Instance.new("UIListLayout", scrollingFrame)
	uIListLayout2.Padding = UDim.new(0, 2)
	uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local uIPadding = Instance.new("UIPadding", scrollingFrame)
	uIPadding.PaddingTop = UDim.new(0, 6)
	uIPadding.PaddingBottom = UDim.new(0, 6)
	uIPadding.PaddingLeft = UDim.new(0, 8)
	local v6 = {}

	local function selectTab(p)
		v3 = p

		for i, v7 in ipairs(v6) do
			if i == p then
				v7.BackgroundColor3 = v[i].Color
				v7.TextColor3 = Color3.fromRGB(0, 0, 0)
			else
				v7.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
				v7.TextColor3 = Color3.fromRGB(180, 180, 180)
			end
		end

		populateCategory(scrollingFrame, player.Data, p)
	end

	for i, v7 in ipairs(v) do
		local textButton2 = Instance.new("TextButton", frame3)
		textButton2.Name = "Tab_" .. i
		textButton2.Size = UDim2.new(0, 56, 0, 28)
		textButton2.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		textButton2.Text = v7.Name
		textButton2.TextColor3 = Color3.fromRGB(180, 180, 180)
		textButton2.TextScaled = true
		textButton2.Font = Enum.Font.GothamBold
		textButton2.AutoButtonColor = true
		local uICorner_4 = Instance.new("UICorner", textButton2)
		uICorner_4.CornerRadius = UDim.new(0, 6)
		local uITextSizeConstraint_2 = Instance.new("UITextSizeConstraint", textButton2)
		uITextSizeConstraint_2.MaxTextSize = 11
		local v8 = i
		textButton2.MouseButton1Click:Connect(function()
			selectTab(v8)
		end)
		table.insert(v6, textButton2)
	end

	selectTab(1)
end

dataViewerAction.OnClientEvent:Connect(function(p)
	if type(p) ~= "table" then
		return
	end

	if p.Action == "showData" then
		buildGUI(p)
	end
end)