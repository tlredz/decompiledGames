local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local GamepadPages = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
local ButtonHints = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonHints)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
local BattleAnalysisTypes = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("BattleAnalysis"):WaitForChild("BattleAnalysisTypes"))
local BattleAnalysisPanelService = {}
local color = Color3.fromRGB(244, 246, 250)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(226, 230, 238)
local color4 = Color3.fromRGB(28, 32, 44)
local color5 = Color3.fromRGB(124, 132, 152)
local color6 = Color3.fromRGB(58, 110, 230)
local color7 = Color3.fromRGB(46, 168, 110)
local color8 = Color3.fromRGB(224, 178, 45)
local color9 = Color3.fromRGB(226, 86, 86)
local color10 = Color3.fromRGB(150, 158, 176)
local v = { "winRate", "avgDuration", "spread" }
local v2 = {
	winRate = "胜率",
	avgDuration = "平均时长",
	spread = "时长分布"
}
local v3 = {
	pair = "组合",
	ball = "单球",
	global = "全部"
}
local v4 = {
	"default",
	"winRate",
	"avgDuration",
	"matches",
	"draws"
}
local v5 = {
	default = "默认",
	winRate = "胜率",
	avgDuration = "平均时长",
	matches = "样本数",
	draws = "平局"
}
local v6 = {
	default = 58,
	winRate = 58,
	avgDuration = 92,
	matches = 76,
	draws = 58
}
local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function make(className: string, items, parent)
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

-- equivalent calls inferred from this helper; original call sites unknown
local function corner(parent, p: number)
	local v7 = {
		CornerRadius = UDim.new(0, p)
	}
	local uICorner = Instance.new("UICorner")

	for k, v8 in v7 do
		uICorner[k] = v8
	end

	uICorner.Parent = parent
end

local function stroke(parent, color11: Color3?, value: number?)
	local uIStroke = Instance.new("UIStroke")

	for k, v8 in {
		Color = color11 or color3,
		Thickness = value or 1
	} do
		uIStroke[k] = v8
	end

	uIStroke.Parent = parent
	return uIStroke
end

local function padding(parent, p: number, p2: number, p3: number, p4: number)
	local v7 = {
		PaddingLeft = UDim.new(0, p),
		PaddingRight = UDim.new(0, p2),
		PaddingTop = UDim.new(0, p3),
		PaddingBottom = UDim.new(0, p4)
	}
	local uIPadding = Instance.new("UIPadding")

	for k, v8 in v7 do
		uIPadding[k] = v8
	end

	uIPadding.Parent = parent
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidImageValue(image)
	return typeof(image) == "string" and image ~= "" and string.match(image, "^%a+://") ~= nil
end

local function ballImage(p: string)
	local byCnId = Config.ball.byCnId
	local v7 = byCnId and byCnId[p]
	local image = v7 and v7.image

	-- equivalent call inferred; original call site unknown
	if isValidImageValue(image) then
		return image
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatCount(matches: number)
	if matches >= 10000 then
		return string.format("%.1fk", matches / 1000)
	end

	return (tostring(matches))
end

local function formatTime(archivedAt: number)
	if archivedAt <= 0 then
		return "-"
	end

	return os.date("%m-%d %H:%M", archivedAt)
end

local function winRateColor(p: number)
	local v7 = math.clamp(math.abs(p - 0.5) * 2, 0, 1)

	if v7 <= 0.2 then
		return color7:Lerp(color8, v7 / 0.2)
	end

	return color8:Lerp(color9, (v7 - 0.2) / 0.8)
end

local function trimBuckets(list)
	local v7 = 0

	for i = #list, 1, -1 do
		if not ((list[i] or 0) > 0) then
			continue
		end

		v7 = i
		break
	end

	return (math.clamp(v7, 10, BattleAnalysisTypes.BUCKET_COUNT))
end

local function build(screenGui)
	local v7 = nil
	local flag = false

	local function getRemote()
		if flag then
			return v7
		end

		flag = true
		local success, result = pcall(function()
			return Net:RemoteFunction("BattleAnalysisRequest")
		end)

		if success then
			v7 = result
		else
			warn("[对局分析] 找不到分析服务通道，面板将保持空白：", result)
		end

		return v7
	end

	local function request(p: string, p2)
		if not flag then
			flag = true
			local success, result = pcall(function()
				return Net:RemoteFunction("BattleAnalysisRequest")
			end)

			if success then
				v7 = result
			else
				warn("[对局分析] 找不到分析服务通道，面板将保持空白：", result)
			end
		end

		local v8 = v7

		if not v8 then
			return nil
		end

		local success, result = pcall(function()
			return v8:InvokeServer(p, p2)
		end)

		if success then
			return result
		end

		warn("[对局分析] 请求失败：", p, result)
		return nil
	end

	local v8 = {
		Name = "AnalysisRoot",
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.8, 0.8),
		Visible = false,
		ZIndex = 2
	}
	local frame = Instance.new("Frame")
	local v9 = {
		page = "overview",
		ballRoleId = nil,
		chartType = "winRate",
		sortMode = "winRate",
		sortDesc = true,
		pairKey = nil,
		archiveKey = nil,
		archiveLabel = nil,
		drawerOpen = false,
		visible = false
	}
	local refresh
	local refreshPair

	for k, v10 in v8 do
		frame[k] = v10
	end

	frame.Parent = screenGui
	corner(frame, 16) -- equivalent call inferred; original call site unknown
	local uIStroke = Instance.new("UIStroke")

	for k, v11 in {
		Color = color3 or color3,
		Thickness = 1
	} do
		uIStroke[k] = v11
	end

	uIStroke.Parent = frame
	local v11 = {
		Name = "Header",
		BackgroundColor3 = color2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 60),
		ZIndex = 3
	}
	local frame2 = Instance.new("Frame")

	for k, v12 in v11 do
		frame2[k] = v12
	end

	frame2.Parent = frame
	padding(frame2, 20, 20, 0, 0)
	local v12 = {
		Name = "HeaderBorder",
		BackgroundColor3 = color3,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 59),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 4
	}
	local frame3 = Instance.new("Frame")

	for k, v13 in v12 do
		frame3[k] = v13
	end

	frame3.Parent = frame
	local v13 = {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 220, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "对局分析",
		TextColor3 = color4,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4
	}
	local textLabel = Instance.new("TextLabel")

	for k, v14 in v13 do
		textLabel[k] = v14
	end

	textLabel.Parent = frame2
	local v14 = {
		Name = "Summary",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 226, 0, 0),
		Size = UDim2.new(1, -640, 1, 0),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = color5,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 4
	}
	local textLabel2 = Instance.new("TextLabel")

	for k, v15 in v14 do
		textLabel2[k] = v15
	end

	textLabel2.Parent = frame2

	local function headerButton(name: string, text: string, p3: number, p4: number)
		local v15 = {
			Name = name,
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(240, 243, 249),
			AutoButtonColor = false,
			Position = UDim2.new(1, -p3, 0.5, 0),
			Size = UDim2.fromOffset(p4, 32),
			Font = Enum.Font.GothamMedium,
			Text = text,
			TextColor3 = color4,
			TextSize = 13,
			ZIndex = 4
		}
		local textButton = Instance.new("TextButton")

		for k, v17 in v15 do
			textButton[k] = v17
		end

		textButton.Parent = frame2
		corner(textButton, 8) -- equivalent call inferred; original call site unknown
		local uIStroke2 = Instance.new("UIStroke")

		for k, v18 in {
			Color = color3,
			Thickness = 1
		} do
			uIStroke2[k] = v18
		end

		uIStroke2.Parent = textButton
		textButton.MouseEnter:Connect(function()
			TweenService:Create(textButton, tweenInfo, {
				BackgroundColor3 = Color3.fromRGB(228, 234, 246)
			}):Play()
		end)
		textButton.MouseLeave:Connect(function()
			TweenService:Create(textButton, tweenInfo, {
				BackgroundColor3 = Color3.fromRGB(240, 243, 249)
			}):Play()
		end)
		return textButton
	end

	local v15 = headerButton("CloseButton", "关闭", 8, 64)
	local v16 = headerButton("RunningButton", "全部暂停", 330, 96)
	local v17 = headerButton("JobsButton", "任务 (0)", 226, 96)
	local v18 = headerButton("ArchivesButton", "历史存档", 122, 96)
	ButtonActions.Bind(v15, function()
		BattleAnalysisPanelService.close()
	end)
	local v19 = {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 60),
		Size = UDim2.new(1, 0, 1, -60),
		ZIndex = 2
	}
	local frame4 = Instance.new("Frame")

	for k, v20 in v19 do
		frame4[k] = v20
	end

	frame4.Parent = frame

	local function newPage(name: string)
		local v20 = {
			Name = name,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			ZIndex = 2
		}
		local frame5 = Instance.new("Frame")

		for k, v22 in v20 do
			frame5[k] = v22
		end

		frame5.Parent = frame4
		return frame5
	end

	local v20 = {
		Name = "OverviewPage",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 2
	}
	local frame5 = Instance.new("Frame")

	for k, v21 in v20 do
		frame5[k] = v21
	end

	frame5.Parent = frame4
	local v21 = {
		Name = "BallPage",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 2
	}
	local frame6 = Instance.new("Frame")

	for k, v22 in v21 do
		frame6[k] = v22
	end

	frame6.Parent = frame4
	local v22 = {
		Name = "ArchivePage",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 2
	}
	local frame7 = Instance.new("Frame")

	for k, v23 in v22 do
		frame7[k] = v23
	end

	frame7.Parent = frame4
	frame5.Visible = true
	local v23 = {
		Name = "ToolBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 56),
		ZIndex = 3
	}
	local frame8 = Instance.new("Frame")

	for k, v24 in v23 do
		frame8[k] = v24
	end

	frame8.Parent = frame5
	padding(frame8, 20, 20, 12, 0)
	local v24 = {
		Name = "AnalyzeAll",
		BackgroundColor3 = color6,
		AutoButtonColor = false,
		Size = UDim2.fromOffset(180, 34),
		Font = Enum.Font.GothamBold,
		Text = "分析全部对局",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 13,
		ZIndex = 4
	}
	local textButton = Instance.new("TextButton")

	for k, v25 in v24 do
		textButton[k] = v25
	end

	textButton.Parent = frame8
	corner(textButton, 8) -- equivalent call inferred; original call site unknown
	local v25 = {
		Name = "Hint",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 192, 0, 0),
		Size = UDim2.new(1, -592, 0, 34),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = color5,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 4
	}
	local textLabel3 = Instance.new("TextLabel")

	for k, v26 in v25 do
		textLabel3[k] = v26
	end

	textLabel3.Parent = frame8
	local v26 = {
		Name = "SortGroup",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(400, 34),
		ZIndex = 4
	}
	local frame9 = Instance.new("Frame")

	for k, v27 in v26 do
		frame9[k] = v27
	end

	frame9.Parent = frame8
	local v27 = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder
	}
	local uIListLayout = Instance.new("UIListLayout")

	for k, v28 in v27 do
		uIListLayout[k] = v28
	end

	uIListLayout.Parent = frame9
	local v28 = {
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Size = UDim2.fromOffset(40, 28),
		Font = Enum.Font.Gotham,
		Text = "排序",
		TextColor3 = color5,
		TextSize = 12,
		ZIndex = 5
	}
	local textLabel4 = Instance.new("TextLabel")

	for k, v29 in v28 do
		textLabel4[k] = v29
	end

	textLabel4.Parent = frame9
	local v29 = {}

	for i, v30 in ipairs(v4) do
		local v31 = {
			Name = "SortBtn_" .. v30,
			BackgroundColor3 = color2,
			AutoButtonColor = false,
			LayoutOrder = i,
			Size = UDim2.fromOffset(v6[v30], 28),
			Font = Enum.Font.GothamMedium,
			Text = v5[v30],
			TextColor3 = color5,
			TextSize = 12,
			ZIndex = 5
		}
		local textButton2 = Instance.new("TextButton")

		for k, v32 in v31 do
			textButton2[k] = v32
		end

		textButton2.Parent = frame9
		corner(textButton2, 6) -- equivalent call inferred; original call site unknown
		local uIStroke2 = Instance.new("UIStroke")

		for k, v33 in {
			Color = color3,
			Thickness = 1
		} do
			uIStroke2[k] = v33
		end

		uIStroke2.Parent = textButton2
		v29[v30] = textButton2
	end

	local v30 = {
		Name = "Grid",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 56),
		Size = UDim2.new(1, 0, 1, -56),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = color3,
		ZIndex = 3
	}
	local scrollingFrame = Instance.new("ScrollingFrame")

	for k, v31 in v30 do
		scrollingFrame[k] = v31
	end

	scrollingFrame.Parent = frame5
	padding(scrollingFrame, 20, 20, 4, 20)
	local v31 = {
		CellSize = UDim2.fromOffset(168, 118),
		CellPadding = UDim2.fromOffset(12, 12),
		SortOrder = Enum.SortOrder.LayoutOrder
	}
	local uIGridLayout = Instance.new("UIGridLayout")

	for k, v32 in v31 do
		uIGridLayout[k] = v32
	end

	uIGridLayout.Parent = scrollingFrame
	local v32 = {
		Name = "BallBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 56),
		ZIndex = 3
	}
	local frame10 = Instance.new("Frame")

	for k, v33 in v32 do
		frame10[k] = v33
	end

	frame10.Parent = frame6
	padding(frame10, 20, 20, 12, 0)
	local v33 = {
		Name = "Back",
		BackgroundColor3 = Color3.fromRGB(240, 243, 249),
		AutoButtonColor = false,
		Size = UDim2.fromOffset(72, 34),
		Font = Enum.Font.GothamMedium,
		Text = "< 返回",
		TextColor3 = color4,
		TextSize = 13,
		ZIndex = 4
	}
	local textButton2 = Instance.new("TextButton")

	for k, v34 in v33 do
		textButton2[k] = v34
	end

	textButton2.Parent = frame10
	corner(textButton2, 8) -- equivalent call inferred; original call site unknown
	local uIStroke2 = Instance.new("UIStroke")

	for k, v35 in {
		Color = color3,
		Thickness = 1
	} do
		uIStroke2[k] = v35
	end

	uIStroke2.Parent = textButton2
	local v35 = {
		Name = "BallTitle",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 84, 0, 0),
		Size = UDim2.new(1, -300, 0, 34),
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = color4,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4
	}
	local textLabel5 = Instance.new("TextLabel")

	for k, v36 in v35 do
		textLabel5[k] = v36
	end

	textLabel5.Parent = frame10
	local v36 = {
		Name = "AnalyzeBall",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = color6,
		AutoButtonColor = false,
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(158, 34),
		Font = Enum.Font.GothamBold,
		Text = "分析这个球",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 13,
		ZIndex = 4
	}
	local textButton3 = Instance.new("TextButton")

	for k, v37 in v36 do
		textButton3[k] = v37
	end

	textButton3.Parent = frame10
	corner(textButton3, 8) -- equivalent call inferred; original call site unknown
	local v37 = {
		Name = "ChartTabs",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 56),
		Size = UDim2.new(1, 0, 0, 40),
		ZIndex = 3
	}
	local frame11 = Instance.new("Frame")

	for k, v38 in v37 do
		frame11[k] = v38
	end

	frame11.Parent = frame6
	padding(frame11, 20, 20, 0, 0)
	local v38 = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder
	}
	local uIListLayout2 = Instance.new("UIListLayout")

	for k, v39 in v38 do
		uIListLayout2[k] = v39
	end

	uIListLayout2.Parent = frame11
	local v39 = {}

	for i, v40 in ipairs(v) do
		local v41 = {
			Name = "ChartTab_" .. v40,
			BackgroundColor3 = color2,
			AutoButtonColor = false,
			LayoutOrder = i,
			Size = UDim2.fromOffset(132, 28),
			Font = Enum.Font.GothamMedium,
			Text = v2[v40],
			TextColor3 = color5,
			TextSize = 12,
			ZIndex = 4
		}
		local textButton4 = Instance.new("TextButton")

		for k, v42 in v41 do
			textButton4[k] = v42
		end

		textButton4.Parent = frame11
		corner(textButton4, 6) -- equivalent call inferred; original call site unknown
		local uIStroke3 = Instance.new("UIStroke")

		for k, v43 in {
			Color = color3,
			Thickness = 1
		} do
			uIStroke3[k] = v43
		end

		uIStroke3.Parent = textButton4
		v39[v40] = textButton4
	end

	local v40 = {
		Name = "ChartCard",
		BackgroundColor3 = color2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 20, 0, 104),
		Size = UDim2.new(1, -40, 1, -128),
		ZIndex = 3
	}
	local frame12 = Instance.new("Frame")

	for k, v41 in v40 do
		frame12[k] = v41
	end

	frame12.Parent = frame6
	corner(frame12, 10) -- equivalent call inferred; original call site unknown
	local uIStroke3 = Instance.new("UIStroke")

	for k, v42 in {
		Color = color3,
		Thickness = 1
	} do
		uIStroke3[k] = v42
	end

	uIStroke3.Parent = frame12
	local v42 = {
		Name = "ChartScroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, -34),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = color3,
		ZIndex = 4
	}
	local scrollingFrame2 = Instance.new("ScrollingFrame")

	for k, v43 in v42 do
		scrollingFrame2[k] = v43
	end

	scrollingFrame2.Parent = frame12
	padding(scrollingFrame2, 16, 16, 16, 8)
	local v43 = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder
	}
	local uIListLayout3 = Instance.new("UIListLayout")

	for k, v44 in v43 do
		uIListLayout3[k] = v44
	end

	uIListLayout3.Parent = scrollingFrame2
	local v44 = {
		Name = "MirrorLabel",
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 1, -8),
		Size = UDim2.new(1, -32, 0, 20),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = color5,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4
	}
	local textLabel6 = Instance.new("TextLabel")

	for k, v45 in v44 do
		textLabel6[k] = v45
	end

	textLabel6.Parent = frame12
	local v45 = {
		Name = "ArchiveBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 56),
		ZIndex = 3
	}
	local frame13 = Instance.new("Frame")

	for k, v46 in v45 do
		frame13[k] = v46
	end

	frame13.Parent = frame7
	padding(frame13, 20, 20, 12, 0)
	local v46 = {
		Name = "Back",
		BackgroundColor3 = Color3.fromRGB(240, 243, 249),
		AutoButtonColor = false,
		Size = UDim2.fromOffset(72, 34),
		Font = Enum.Font.GothamMedium,
		Text = "< 返回",
		TextColor3 = color4,
		TextSize = 13,
		ZIndex = 4
	}
	local textButton4 = Instance.new("TextButton")

	for k, v47 in v46 do
		textButton4[k] = v47
	end

	textButton4.Parent = frame13
	corner(textButton4, 8) -- equivalent call inferred; original call site unknown
	local uIStroke4 = Instance.new("UIStroke")

	for k, v48 in {
		Color = color3,
		Thickness = 1
	} do
		uIStroke4[k] = v48
	end

	uIStroke4.Parent = textButton4
	local v48 = {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 84, 0, 0),
		Size = UDim2.new(1, -280, 0, 34),
		Font = Enum.Font.GothamBold,
		Text = "历史存档",
		TextColor3 = color4,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4
	}
	local textLabel7 = Instance.new("TextLabel")

	for k, v49 in v48 do
		textLabel7[k] = v49
	end

	textLabel7.Parent = frame13
	local v49 = {
		Name = "ArchiveNow",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(240, 243, 249),
		AutoButtonColor = false,
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(168, 34),
		Font = Enum.Font.GothamMedium,
		Text = "归档当前数据",
		TextColor3 = color4,
		TextSize = 12,
		ZIndex = 4
	}
	local textButton5 = Instance.new("TextButton")

	for k, v50 in v49 do
		textButton5[k] = v50
	end

	textButton5.Parent = frame13
	corner(textButton5, 8) -- equivalent call inferred; original call site unknown
	local uIStroke5 = Instance.new("UIStroke")

	for k, v51 in {
		Color = color3,
		Thickness = 1
	} do
		uIStroke5[k] = v51
	end

	uIStroke5.Parent = textButton5
	local v51 = {
		Name = "ArchiveList",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 56),
		Size = UDim2.new(1, 0, 1, -56),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = color3,
		ZIndex = 3
	}
	local scrollingFrame3 = Instance.new("ScrollingFrame")

	for k, v52 in v51 do
		scrollingFrame3[k] = v52
	end

	scrollingFrame3.Parent = frame7
	padding(scrollingFrame3, 20, 20, 0, 20)
	local v52 = {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	}
	local uIListLayout4 = Instance.new("UIListLayout")

	for k, v53 in v52 do
		uIListLayout4[k] = v53
	end

	uIListLayout4.Parent = scrollingFrame3
	local v53 = {
		Name = "JobDrawer",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = color2,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 330, 0, 0),
		Size = UDim2.new(0, 330, 1, 0),
		ZIndex = 20
	}
	local frame14 = Instance.new("Frame")

	for k, v54 in v53 do
		frame14[k] = v54
	end

	frame14.Parent = frame
	local uIStroke6 = Instance.new("UIStroke")

	for k, v55 in {
		Color = color3,
		Thickness = 1
	} do
		uIStroke6[k] = v55
	end

	uIStroke6.Parent = frame14
	local v55 = {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 14),
		Size = UDim2.new(1, -32, 0, 24),
		Font = Enum.Font.GothamBold,
		Text = "任务队列",
		TextColor3 = color4,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 21
	}
	local textLabel8 = Instance.new("TextLabel")

	for k, v56 in v55 do
		textLabel8[k] = v56
	end

	textLabel8.Parent = frame14
	local v56 = {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 38),
		Size = UDim2.new(1, -32, 0, 16),
		Font = Enum.Font.Gotham,
		Text = "优先级：组合 > 单球 > 全部",
		TextColor3 = color5,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 21
	}
	local textLabel9 = Instance.new("TextLabel")

	for k, v57 in v56 do
		textLabel9[k] = v57
	end

	textLabel9.Parent = frame14
	local v57 = {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.fromOffset(28, 28),
		Font = Enum.Font.GothamBold,
		Text = "X",
		TextColor3 = color5,
		TextSize = 14,
		ZIndex = 21
	}
	local textButton6 = Instance.new("TextButton")

	for k, v58 in v57 do
		textButton6[k] = v58
	end

	textButton6.Parent = frame14
	local v58 = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 64),
		Size = UDim2.new(1, 0, 1, -64),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = color3,
		ZIndex = 21
	}
	local scrollingFrame4 = Instance.new("ScrollingFrame")

	for k, v59 in v58 do
		scrollingFrame4[k] = v59
	end

	scrollingFrame4.Parent = frame14
	padding(scrollingFrame4, 12, 12, 4, 16)
	local v59 = {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	}
	local uIListLayout5 = Instance.new("UIListLayout")

	for k, v60 in v59 do
		uIListLayout5[k] = v60
	end

	uIListLayout5.Parent = scrollingFrame4
	local v60 = {
		Name = "ModalDimmer",
		BackgroundColor3 = Color3.fromRGB(20, 24, 34),
		BackgroundTransparency = 0.55,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Visible = false,
		ZIndex = 30
	}
	local textButton7 = Instance.new("TextButton")

	for k, v61 in v60 do
		textButton7[k] = v61
	end

	textButton7.Parent = frame
	local v61 = {
		Name = "PairModal",
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = color2,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(520, 400),
		Text = "",
		ZIndex = 31
	}
	local textButton8 = Instance.new("TextButton")

	for k, v62 in v61 do
		textButton8[k] = v62
	end

	textButton8.Parent = textButton7
	corner(textButton8, 12) -- equivalent call inferred; original call site unknown
	padding(textButton8, 20, 20, 18, 18)
	local v62 = {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 0, 24),
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = color4,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 32
	}
	local textLabel10 = Instance.new("TextLabel")

	for k, v63 in v62 do
		textLabel10[k] = v63
	end

	textLabel10.Parent = textButton8
	local v63 = {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 26),
		Size = UDim2.new(1, -40, 0, 18),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = color5,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 32
	}
	local textLabel11 = Instance.new("TextLabel")

	for k, v64 in v63 do
		textLabel11[k] = v64
	end

	textLabel11.Parent = textButton8
	local v64 = {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(26, 26),
		Font = Enum.Font.GothamBold,
		Text = "X",
		TextColor3 = color5,
		TextSize = 14,
		ZIndex = 32
	}
	local textButton9 = Instance.new("TextButton")

	for k, v65 in v64 do
		textButton9[k] = v65
	end

	textButton9.Parent = textButton8
	local v65 = {
		BackgroundColor3 = Color3.fromRGB(238, 241, 247),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 56),
		Size = UDim2.new(1, 0, 0, 26),
		ZIndex = 32
	}
	local frame15 = Instance.new("Frame")

	for k, v66 in v65 do
		frame15[k] = v66
	end

	frame15.Parent = textButton8
	corner(frame15, 6) -- equivalent call inferred; original call site unknown
	local v66 = {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder
	}
	local uIListLayout6 = Instance.new("UIListLayout")

	for k, v67 in v66 do
		uIListLayout6[k] = v67
	end

	uIListLayout6.Parent = frame15

	local function ratioSegment(layoutOrder: number, color11: Color3)
		local v67 = {
			BackgroundColor3 = color11,
			BorderSizePixel = 0,
			LayoutOrder = layoutOrder,
			Size = UDim2.fromScale(0, 1),
			Font = Enum.Font.GothamMedium,
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 12,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 33
		}
		local textLabel12 = Instance.new("TextLabel")

		for k, v69 in v67 do
			textLabel12[k] = v69
		end

		textLabel12.Parent = frame15
		return textLabel12
	end

	local v67 = ratioSegment(1, color6)
	local v68 = ratioSegment(2, color10)
	local v69 = ratioSegment(3, Color3.fromRGB(240, 170, 60))
	local v70 = {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 90),
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = color5,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 32
	}
	local textLabel12 = Instance.new("TextLabel")

	for k, v71 in v70 do
		textLabel12[k] = v71
	end

	textLabel12.Parent = textButton8
	local v71 = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 116),
		Size = UDim2.new(1, 0, 1, -164),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = color3,
		ZIndex = 32
	}
	local scrollingFrame5 = Instance.new("ScrollingFrame")

	for k, v72 in v71 do
		scrollingFrame5[k] = v72
	end

	scrollingFrame5.Parent = textButton8
	local v72 = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder
	}
	local uIListLayout7 = Instance.new("UIListLayout")

	for k, v73 in v72 do
		uIListLayout7[k] = v73
	end

	uIListLayout7.Parent = scrollingFrame5
	local v73 = {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = color6,
		AutoButtonColor = false,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.fromOffset(184, 34),
		Font = Enum.Font.GothamBold,
		Text = "只分析这一对",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 13,
		ZIndex = 32
	}
	local textButton10 = Instance.new("TextButton")

	for k, v74 in v73 do
		textButton10[k] = v74
	end

	textButton10.Parent = textButton8
	corner(textButton10, 8) -- equivalent call inferred; original call site unknown

	local function clearChildren(instance)
		for _, uIComponent in ipairs(instance:GetChildren()) do
			if not uIComponent:IsA("UIComponent") then
				uIComponent:Destroy()
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setButtonEnabled(p, active: boolean)
		p.Active = active
		p.AutoButtonColor = false
		local backgroundColor

		if active then
			backgroundColor = color6
		else
			backgroundColor = Color3.fromRGB(198, 206, 220)
		end

		p.BackgroundColor3 = backgroundColor
	end

	local v74 = {}
	local v75 = nil

	local function createBallCard(p)
		local v76 = {
			Name = "BallCard_" .. p.roleId,
			BackgroundColor3 = color2,
			AutoButtonColor = false,
			Text = "",
			ZIndex = 4
		}
		local textButton11 = Instance.new("TextButton")

		for k, v78 in v76 do
			textButton11[k] = v78
		end

		textButton11.Parent = scrollingFrame
		corner(textButton11, 10) -- equivalent call inferred; original call site unknown
		local uIStroke7 = Instance.new("UIStroke")

		for k, v79 in {
			Color = color3,
			Thickness = 1
		} do
			uIStroke7[k] = v79
		end

		uIStroke7.Parent = textButton11
		local roleId = p.roleId
		local byCnId = Config.ball.byCnId
		local v79 = byCnId and byCnId[roleId]
		local image = v79 and v79.image

		-- equivalent call inferred; original call site unknown
		if not isValidImageValue(image) then
			image = nil
		end

		if image then
			local v80 = {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 12),
				Size = UDim2.fromOffset(38, 38),
				Image = image,
				ZIndex = 5
			}
			local imageLabel = Instance.new("ImageLabel")

			for k, v81 in v80 do
				imageLabel[k] = v81
			end

			imageLabel.Parent = textButton11
		end

		local v80 = {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, image and 58 or 12, 0, 12),
			Size = UDim2.new(1, image and -70 or -24, 0, 20),
			Font = Enum.Font.GothamBold,
			Text = p.displayNameCN,
			TextColor3 = color4,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 5
		}
		local textLabel13 = Instance.new("TextLabel")

		for k, v81 in v80 do
			textLabel13[k] = v81
		end

		textLabel13.Parent = textButton11
		local v81 = {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, image and 58 or 12, 0, 32),
			Size = UDim2.new(1, image and -70 or -24, 0, 16),
			Font = Enum.Font.Gotham,
			Text = "",
			TextColor3 = color5,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5
		}
		local textLabel14 = Instance.new("TextLabel")

		for k, v82 in v81 do
			textLabel14[k] = v82
		end

		textLabel14.Parent = textButton11
		local v82 = {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 58),
			Size = UDim2.new(1, -24, 0, 24),
			Font = Enum.Font.GothamBold,
			Text = "--",
			TextColor3 = color5,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5
		}
		local textLabel15 = Instance.new("TextLabel")

		for k, v83 in v82 do
			textLabel15[k] = v83
		end

		textLabel15.Parent = textButton11
		local v83 = {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 84),
			Size = UDim2.new(1, -24, 0, 16),
			Font = Enum.Font.Gotham,
			Text = "",
			TextColor3 = color5,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5
		}
		local textLabel16 = Instance.new("TextLabel")

		for k, v84 in v83 do
			textLabel16[k] = v84
		end

		textLabel16.Parent = textButton11
		local v84 = {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(238, 241, 247),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 12, 1, -10),
			Size = UDim2.new(1, -24, 0, 4),
			ZIndex = 5
		}
		local frame16 = Instance.new("Frame")

		for k, v85 in v84 do
			frame16[k] = v85
		end

		frame16.Parent = textButton11
		corner(frame16, 2) -- equivalent call inferred; original call site unknown
		local v85 = {
			BackgroundColor3 = color10,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0, 1),
			ZIndex = 6
		}
		local frame17 = Instance.new("Frame")

		for k, v86 in v85 do
			frame17[k] = v86
		end

		frame17.Parent = frame16
		corner(frame17, 2) -- equivalent call inferred; original call site unknown
		textButton11.MouseEnter:Connect(function()
			uIStroke7.Color = color6
		end)
		textButton11.MouseLeave:Connect(function()
			uIStroke7.Color = color3
		end)
		ButtonActions.Bind(textButton11, function()
			v9.page = "ball"
			v9.ballRoleId = p.roleId
			refresh()
		end)
		return {
			card = textButton11,
			matchesLabel = textLabel14,
			rateLabel = textLabel15,
			subLabel = textLabel16,
			fill = frame17
		}
	end

	local function compareBalls(data, data2)
		local sortMode = v9.sortMode

		if sortMode == "default" then
			return data.roleId < data2.roleId
		end

		local v76 = data.matches > 0

		if v76 ~= (data2.matches > 0) then
			return v76
		end

		local winRate, winRate2

		if sortMode == "winRate" then
			winRate = data.winRate
			winRate2 = data2.winRate
		elseif sortMode == "avgDuration" then
			winRate = data.avgDuration
			winRate2 = data2.avgDuration
		elseif sortMode == "draws" then
			winRate = data.draws
			winRate2 = data2.draws
		else
			winRate = data.matches
			winRate2 = data2.matches
		end

		if winRate == winRate2 then
			return data.roleId < data2.roleId
		end

		if v9.sortDesc then
			return winRate2 < winRate
		end

		return winRate < winRate2
	end

	local function updateSortButtons()
		for k, v76 in v29 do
			local v77 = k == v9.sortMode
			local backgroundColor

			if v77 then
				backgroundColor = color6
			else
				backgroundColor = color2
			end

			v76.BackgroundColor3 = backgroundColor
			local textColor

			if v77 then
				textColor = Color3.fromRGB(255, 255, 255)
			else
				textColor = color5
			end

			v76.TextColor3 = textColor

			if v77 and k ~= "default" then
				v76.Text = v5[k] .. (v9.sortDesc and " ↓" or " ↑")
			else
				v76.Text = v5[k]
			end
		end
	end

	local function renderOverview(p)
		if not p then
			return
		end

		local archiveKey = v9.archiveKey or "live"

		if v75 ~= archiveKey then
			v75 = archiveKey
			clearChildren(scrollingFrame)
			v74 = {}
		end

		local clone = table.clone(p.balls)
		table.sort(clone, compareBalls)
		local v76 = {}

		for i, v77 in ipairs(clone) do
			v76[v77.roleId] = true
			local v78 = v74[v77.roleId]

			if not v78 then
				v78 = createBallCard(v77)
				v74[v77.roleId] = v78
			end

			local v79 = v77.matches > 0
			v78.card.LayoutOrder = i
			v78.matchesLabel.Text = string.format("%s 场", formatCount(v77.matches))
			v78.rateLabel.Text = not v79 and "--" or string.format("%.1f%%", v77.winRate * 100)
			local rateLabel = v78.rateLabel
			local textColor

			if v79 then
				local v81 = math.clamp(math.abs(v77.winRate - 0.5) * 2, 0, 1)

				if v81 <= 0.2 then
					textColor = color7:Lerp(color8, v81 / 0.2)
				else
					textColor = color8:Lerp(color9, (v81 - 0.2) / 0.8)
				end
			else
				textColor = color5
			end

			rateLabel.TextColor3 = textColor
			v78.subLabel.Text = not v79 and "暂无样本" or string.format("胜率  ·  平均 %.1f 秒", v77.avgDuration)
			local fill = v78.fill
			local backgroundColor

			if v79 then
				local v82 = math.clamp(math.abs(v77.winRate - 0.5) * 2, 0, 1)

				if v82 <= 0.2 then
					backgroundColor = color7:Lerp(color8, v82 / 0.2)
				else
					backgroundColor = color8:Lerp(color9, (v82 - 0.2) / 0.8)
				end
			else
				backgroundColor = color10
			end

			fill.BackgroundColor3 = backgroundColor
			v78.fill.Size = UDim2.fromScale(not v79 and 0 or math.clamp(v77.winRate, 0, 1), 1)
		end

		for k, v77 in v74 do
			if v76[k] then
				continue
			end

			v77.card:Destroy()
			v74[k] = nil
		end
	end

	local function makeBar(parent, data)
		local v76 = {
			Name = "Bar_" .. tostring(data.key),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Size = UDim2.new(0, data.width or 58, 1, 0),
			Text = "",
			ZIndex = 5
		}
		local textButton11 = Instance.new("TextButton")

		for k, v77 in v76 do
			textButton11[k] = v77
		end

		textButton11.Parent = parent
		local bottomHeight = data.bottomHeight or 46
		local v77 = {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Font = Enum.Font.GothamMedium,
			Text = "",
			TextColor3 = color4,
			TextSize = 11,
			ZIndex = 6
		}
		local textLabel13 = Instance.new("TextLabel")

		for k, v78 in v77 do
			textLabel13[k] = v78
		end

		textLabel13.Parent = textButton11
		local v78 = {
			BackgroundColor3 = Color3.fromRGB(243, 245, 250),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 8, 0, 18),
			Size = UDim2.new(1, -16, 1, -(18 + bottomHeight)),
			ZIndex = 5
		}
		local frame16 = Instance.new("Frame")

		for k, v79 in v78 do
			frame16[k] = v79
		end

		frame16.Parent = textButton11
		corner(frame16, 4) -- equivalent call inferred; original call site unknown
		local v79 = {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = color6,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.fromScale(1, 0),
			ZIndex = 6
		}
		local frame17 = Instance.new("Frame")

		for k, v80 in v79 do
			frame17[k] = v80
		end

		frame17.Parent = frame16
		corner(frame17, 4) -- equivalent call inferred; original call site unknown
		local uIGradient = Instance.new("UIGradient")

		for k, v80 in {
			Rotation = 90
		} do
			uIGradient[k] = v80
		end

		uIGradient.Parent = frame17

		if data.image then
			local v80 = {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 1, -18),
				Size = UDim2.fromOffset(26, 26),
				Image = data.image,
				ZIndex = 6
			}
			local imageLabel = Instance.new("ImageLabel")

			for k, v81 in v80 do
				imageLabel[k] = v81
			end

			imageLabel.Parent = textButton11
		end

		local v80 = {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, data.axisTwoLine and 26 or 16),
			Font = Enum.Font.Gotham,
			Text = "",
			TextColor3 = color5,
			TextSize = 10,
			TextWrapped = data.axisTwoLine == true,
			TextTruncate = 0,
			ZIndex = 6
		}
		local textTruncate

		if data.axisTwoLine then
			textTruncate = Enum.TextTruncate.None
		else
			textTruncate = Enum.TextTruncate.AtEnd
		end

		v80.TextTruncate = textTruncate
		local textLabel14 = Instance.new("TextLabel")

		for k, v82 in v80 do
			textLabel14[k] = v82
		end

		textLabel14.Parent = textButton11
		return {
			column = textButton11,
			valueLabel = textLabel13,
			fill = frame17,
			gradient = uIGradient,
			axisLabel = textLabel14
		}
	end

	local function updateBar(data, layoutOrder: number, data2)
		data.column.LayoutOrder = layoutOrder
		data.valueLabel.Text = data2.valueText
		data.valueLabel.TextColor3 = data2.valueColor or color4
		data.fill.Size = UDim2.fromScale(1, (math.clamp(data2.ratio, 0, 1)))
		data.fill.BackgroundColor3 = data2.barColor
		data.gradient.Color = ColorSequence.new(
			data2.barColor,
			data2.barColor:Lerp(Color3.fromRGB(255, 255, 255), 0.28)
		)
		data.axisLabel.Text = data2.axisText
	end

	local function newChartDrawer(parent)
		local v76 = {}
		local v77 = nil
		return function(list, p2: string)
			if v77 ~= p2 then
				v77 = p2
				clearChildren(parent)
				v76 = {}
			end

			local v78 = {}

			for i, v79 in ipairs(list) do
				v78[v79.key] = true
				local v80 = v76[v79.key]

				if not v80 then
					v80 = makeBar(parent, v79)
					v76[v79.key] = v80

					if v79.onClick then
						ButtonActions.Bind(v80.column, v79.onClick)
					end
				end

				updateBar(v80, i, v79)
			end

			for k, v79 in v76 do
				if v78[k] then
					continue
				end

				v79.column:Destroy()
				v76[k] = nil
			end
		end
	end

	local v76 = {}
	local v77 = nil

	local function fn(list, p: string)
		if v77 ~= p then
			v77 = p
			clearChildren(scrollingFrame2)
			v76 = {}
		end

		local v78 = {}

		for i, v79 in ipairs(list) do
			v78[v79.key] = true
			local v80 = v76[v79.key]

			if not v80 then
				v80 = makeBar(scrollingFrame2, v79)
				v76[v79.key] = v80

				if v79.onClick then
					ButtonActions.Bind(v80.column, v79.onClick)
				end
			end

			updateBar(v80, i, v79)
		end

		for k, v79 in v76 do
			if v78[k] then
				continue
			end

			v79.column:Destroy()
			v76[k] = nil
		end
	end

	local v78 = {}
	local v79 = nil

	local function fn2(list, pairKey: string)
		if v79 ~= pairKey then
			v79 = pairKey
			clearChildren(scrollingFrame5)
			v78 = {}
		end

		local v80 = {}

		for i, v81 in ipairs(list) do
			v80[v81.key] = true
			local v82 = v78[v81.key]

			if not v82 then
				v82 = makeBar(scrollingFrame5, v81)
				v78[v81.key] = v82

				if v81.onClick then
					ButtonActions.Bind(v82.column, v81.onClick)
				end
			end

			updateBar(v82, i, v81)
		end

		for k, v81 in v78 do
			if v80[k] then
				continue
			end

			v81.column:Destroy()
			v78[k] = nil
		end
	end

	local function histogramEntries(list, width: number)
		local v80 = 0

		for i = #list, 1, -1 do
			if not ((list[i] or 0) > 0) then
				continue
			end

			v80 = i
			break
		end

		local v81 = math.clamp(v80, 10, BattleAnalysisTypes.BUCKET_COUNT)
		local v82 = 0

		for i = 1, v81 do
			v82 = math.max(v82, list[i] or 0)
		end

		local result = {}

		for i = 1, v81 do
			local v83 = list[i] or 0
			local v84 = {
				key = "bucket_" .. i,
				width = width,
				bottomHeight = 18,
				valueText = 0,
				valueColor = 0,
				ratio = 0,
				barColor = 0,
				axisText = 0
			}
			local valueText

			if v83 > 0 then
				if v83 >= 10000 then
					valueText = string.format("%.1fk", v83 / 1000)
				else
					valueText = tostring(v83)
				end
			else
				valueText = ""
			end

			v84.valueText = valueText
			v84.valueColor = color5
			v84.ratio = not (v82 > 0) and 0 or v83 / v82
			v84.barColor = color6
			v84.axisText = BattleAnalysisTypes.bucketLabel(i)
			table.insert(result, v84)
		end

		return result
	end

	local function renderBallPage(data)
		if data then
			local v80 = string.format("%s|%s|%s", data.roleId, v9.chartType, v9.archiveKey or "live")
			local config = data.config

			if config then
				textLabel5.Text = string.format(
					"%s    生命 %s · 攻击 %s · 速度 %s",
					data.displayNameCN,
					tostring(config.maxHp),
					tostring(config.attack),
					(tostring(config.speed))
				)
			else
				textLabel5.Text = data.displayNameCN
			end

			local v81 = textLabel6
			local displayNameCN = data.displayNameCN
			local displayNameCN2 = data.displayNameCN
			local v83 = formatCount(data.mirror.matches) -- equivalent call inferred; original call site unknown
			v81.Text = string.format(
				"镜像局（%s vs %s）：%s 场 · 平均 %.1f 秒   —   镜像局两边是同一个球，胜率没有意义，所以不进柱状图。",
				displayNameCN,
				displayNameCN2,
				v83,
				data.mirror.avgDuration
			)

			if v9.chartType == "spread" then
				local emptyBuckets = BattleAnalysisTypes.emptyBuckets()

				for _, opponent in ipairs(data.opponents) do
					for i = 1, BattleAnalysisTypes.BUCKET_COUNT do
						emptyBuckets[i] += opponent.durationBuckets[i] or 0
					end
				end

				fn(histogramEntries(emptyBuckets, 46), v80)
			else
				local clone = table.clone(data.opponents)
				table.sort(clone, function(a, b)
					if v9.chartType == "winRate" then
						if a.matches == 0 and b.matches == 0 or a.winRate == b.winRate then
							return a.roleId < b.roleId
						end

						return a.winRate > b.winRate
					elseif a.avgDuration == b.avgDuration then
						return a.roleId < b.roleId
					else
						return a.avgDuration > b.avgDuration
					end
				end)
				local v84 = 0

				for _, v85 in ipairs(clone) do
					v84 = math.max(v84, v85.avgDuration)
				end

				local v85 = {}

				for _, v86 in ipairs(clone) do
					local v87 = v86.matches > 0
					local ratio, valueText, barColor

					if v9.chartType == "winRate" then
						ratio = not v87 and 0 or v86.winRate
						valueText = not v87 and "--" or string.format("%.0f%%", v86.winRate * 100)

						if v87 then
							local v91 = math.clamp(math.abs(v86.winRate - 0.5) * 2, 0, 1)

							if v91 <= 0.2 then
								barColor = color7:Lerp(color8, v91 / 0.2)
							else
								barColor = color8:Lerp(color9, (v91 - 0.2) / 0.8)
							end
						else
							barColor = color10
						end
					else
						ratio = not (v84 > 0) and 0 or v86.avgDuration / v84
						valueText = not v87 and "--" or string.format("%.1f秒", v86.avgDuration)

						if v87 then
							barColor = color6
						else
							barColor = color10
						end
					end

					local pairKey = v86.pairKey
					local v91 = {
						key = v86.roleId,
						valueText = valueText,
						ratio = ratio,
						barColor = barColor,
						image = 0,
						axisText = 0,
						axisTwoLine = true,
						onClick = 0
					}
					local roleId = v86.roleId
					local byCnId = Config.ball.byCnId
					local v92 = byCnId and byCnId[roleId]
					local image = v92 and v92.image

					-- equivalent call inferred; original call site unknown
					if not isValidImageValue(image) then
						image = nil
					end

					v91.image = image
					v91.axisText = string.format("%s\n%s", v86.displayNameCN, formatCount(v86.matches))

					function v91.onClick()
						v9.pairKey = pairKey
						refreshPair()
					end

					table.insert(v85, v91)
				end

				fn(v85, v80)
			end
		else
			textLabel5.Text = ""
			textLabel6.Text = ""
			fn({}, "empty")
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function renderPairModal(data)
		if not data then
			textButton7.Visible = false
			return
		end

		textButton7.Visible = true
		textLabel10.Text = string.format("%s  vs  %s", data.displayA, data.displayB)
		local v80 = textLabel11
		local v82 = formatCount(data.matches) -- equivalent call inferred; original call site unknown
		v80.Text = string.format("%s 场 · 平均 %.2f 秒%s", v82, data.avgDuration, data.isMirror and " · 镜像局" or "")
		local v83 = math.max(1, data.matches)
		v67.Size = UDim2.fromScale(data.winsA / v83, 1)
		v68.Size = UDim2.fromScale(data.draws / v83, 1)
		v69.Size = UDim2.fromScale(data.winsB / v83, 1)
		v67.Text = not (data.winsA > 0) and "" or tostring(data.winsA)
		v68.Text = not (data.draws > 0) and "" or tostring(data.draws)
		v69.Text = not (data.winsB > 0) and "" or tostring(data.winsB)
		local v84 = data.winsA + data.winsB
		textLabel12.Text = string.format(
			"%s 胜 %d 场（%.1f%%）   ·   平局 %d 场   ·   %s 胜 %d 场（%.1f%%）",
			data.displayA,
			data.winsA,
			not (v84 > 0) and 0 or data.winsA / v84 * 100,
			data.draws,
			data.displayB,
			data.winsB,
			not (v84 > 0) and 0 or data.winsB / v84 * 100
		)
		fn2(histogramEntries(data.durationBuckets, 42), data.pairKey)
		setButtonEnabled(textButton10, v9.archiveKey == nil) -- equivalent call inferred; original call site unknown
	end

	local v80 = {}
	local v81 = nil

	local function createJobRow(data)
		local v82 = {
			Name = "JobRow_" .. data.id,
			BackgroundColor3 = Color3.fromRGB(248, 250, 253),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 84),
			ZIndex = 22
		}
		local frame16 = Instance.new("Frame")

		for k, v84 in v82 do
			frame16[k] = v84
		end

		frame16.Parent = scrollingFrame4
		corner(frame16, 8) -- equivalent call inferred; original call site unknown
		local uIStroke7 = Instance.new("UIStroke")

		for k, v85 in {
			Color = color3,
			Thickness = 1
		} do
			uIStroke7[k] = v85
		end

		uIStroke7.Parent = frame16
		padding(frame16, 10, 10, 8, 8)
		local v85 = {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Font = Enum.Font.GothamBold,
			Text = string.format("[%s] %s", v3[data.kind] or data.kind, data.targetLabel),
			TextColor3 = color4,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 23
		}
		local textLabel13 = Instance.new("TextLabel")

		for k, v86 in v85 do
			textLabel13[k] = v86
		end

		textLabel13.Parent = frame16
		local v86 = {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 18),
			Size = UDim2.new(1, 0, 0, 14),
			Font = Enum.Font.Gotham,
			Text = "",
			TextColor3 = color5,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 23
		}
		local textLabel14 = Instance.new("TextLabel")

		for k, v87 in v86 do
			textLabel14[k] = v87
		end

		textLabel14.Parent = frame16
		local v87 = {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 32),
			Size = UDim2.new(1, 0, 0, 14),
			Font = Enum.Font.Gotham,
			Text = "",
			TextColor3 = color5,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 23
		}
		local textLabel15 = Instance.new("TextLabel")

		for k, v88 in v87 do
			textLabel15[k] = v88
		end

		textLabel15.Parent = frame16

		local function smallButton(p: number, color11: Color3)
			local v88 = {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = color11,
				AutoButtonColor = false,
				Position = UDim2.new(p, 0, 1, 0),
				Size = UDim2.new(0.48, 0, 0, 24),
				Font = Enum.Font.GothamMedium,
				Text = "",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 11,
				ZIndex = 23
			}
			local textButton11 = Instance.new("TextButton")

			for k, v90 in v88 do
				textButton11[k] = v90
			end

			textButton11.Parent = frame16
			corner(textButton11, 6) -- equivalent call inferred; original call site unknown
			return textButton11
		end

		local v88 = {
			row = frame16,
			statsLabel = textLabel14,
			stateLabel = textLabel15,
			pauseButton = smallButton(0, color6),
			stopButton = smallButton(0.52, color9),
			paused = false
		}
		ButtonActions.Bind(v88.pauseButton, function()
			request(v88.paused and "jobResume" or "jobPause", data.id)
			refresh()
		end)
		ButtonActions.Bind(v88.stopButton, function()
			request("jobRemove", data.id)
			refresh()
		end)
		v88.stopButton.Text = "停止"
		return v88
	end

	local function renderJobs(jobs)
		if #jobs == 0 and not v81 then
			local v82 = {
				BackgroundTransparency = 1,
				LayoutOrder = 999,
				Size = UDim2.new(1, 0, 0, 40),
				Font = Enum.Font.Gotham,
				Text = "当前没有运行中的任务。",
				TextColor3 = color5,
				TextSize = 12,
				ZIndex = 22
			}
			local textLabel13 = Instance.new("TextLabel")

			for k, v84 in v82 do
				textLabel13[k] = v84
			end

			textLabel13.Parent = scrollingFrame4
			v81 = textLabel13
		elseif #jobs > 0 and v81 then
			v81:Destroy()
			v81 = nil
		end

		local v82 = {}

		for i, v83 in ipairs(jobs) do
			v82[v83.id] = true
			local v84 = v80[v83.id]

			if not v84 then
				v84 = createJobRow(v83)
				v80[v83.id] = v84
			end

			v84.paused = v83.paused
			v84.row.LayoutOrder = i
			local statsLabel = v84.statsLabel
			local pairCount = v83.pairCount
			local v86 = formatCount(v83.completedCount) -- equivalent call inferred; original call site unknown
			statsLabel.Text = string.format("%d 个组合 · 已跑 %s 场 · %.1f 场/秒", pairCount, v86, v83.ratePerSecond)
			local stateLabel = v84.stateLabel
			local startedAt = v83.startedAt
			stateLabel.Text = string.format(
				"启动于 %s%s",
				startedAt <= 0 and "-" or os.date("%m-%d %H:%M", startedAt),
				v83.paused and "  ·  已暂停" or ""
			)
			local stateLabel2 = v84.stateLabel
			local textColor

			if v83.paused then
				textColor = color9
			else
				textColor = color5
			end

			stateLabel2.TextColor3 = textColor
			v84.pauseButton.Text = v83.paused and "继续" or "暂停"
		end

		for k, v83 in v80 do
			if v82[k] then
				continue
			end

			v83.row:Destroy()
			v80[k] = nil
		end
	end

	local v82 = nil

	local function renderArchives(p)
		if not p then
			return
		end

		textLabel7.Text = string.format("历史存档（%d / %d）", #p.archives, p.maxArchives)
		local dataKeys = {}

		for _, archive in ipairs(p.archives) do
			table.insert(dataKeys, archive.dataKey)
		end

		local joined = table.concat(dataKeys, ",")

		if v82 == joined then
			return
		end

		v82 = joined
		clearChildren(scrollingFrame3)

		if #p.archives == 0 then
			local v83 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 48),
				Font = Enum.Font.Gotham,
				Text = "还没有存档。战斗配置哈希变化时会自动归档一份。",
				TextColor3 = color5,
				TextSize = 12,
				ZIndex = 4
			}
			local textLabel13 = Instance.new("TextLabel")

			for k, v85 in v83 do
				textLabel13[k] = v85
			end

			textLabel13.Parent = scrollingFrame3
		else
			for i = #p.archives, 1, -1 do
				local archive = p.archives[i]
				local v83 = {
					BackgroundColor3 = color2,
					BorderSizePixel = 0,
					LayoutOrder = #p.archives - i,
					Size = UDim2.new(1, 0, 0, 58),
					ZIndex = 4
				}
				local frame16 = Instance.new("Frame")

				for k, v85 in v83 do
					frame16[k] = v85
				end

				frame16.Parent = scrollingFrame3
				corner(frame16, 8) -- equivalent call inferred; original call site unknown
				local uIStroke7 = Instance.new("UIStroke")

				for k, v86 in {
					Color = color3,
					Thickness = 1
				} do
					uIStroke7[k] = v86
				end

				uIStroke7.Parent = frame16
				padding(frame16, 14, 14, 0, 0)
				local v86 = {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 10),
					Size = UDim2.new(1, -220, 0, 18),
					Font = Enum.Font.GothamBold,
					Text = string.format("版本 %s", (string.sub(archive.versionKey, 1, 8))),
					TextColor3 = color4,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 5
				}
				local textLabel13 = Instance.new("TextLabel")

				for k, v87 in v86 do
					textLabel13[k] = v87
				end

				textLabel13.Parent = frame16
				local v87 = {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 30),
					Size = UDim2.new(1, -220, 0, 16),
					Font = Enum.Font.Gotham,
					Text = 0,
					TextColor3 = 0,
					TextSize = 11,
					TextXAlignment = 0,
					ZIndex = 5
				}
				local archivedAt = archive.archivedAt
				v87.Text = string.format(
					"归档于 %s · %s 场",
					archivedAt <= 0 and "-" or os.date("%m-%d %H:%M", archivedAt),
					formatCount(archive.matches)
				)
				v87.TextColor3 = color5
				v87.TextXAlignment = Enum.TextXAlignment.Left
				local textLabel14 = Instance.new("TextLabel")

				for k, v88 in v87 do
					textLabel14[k] = v88
				end

				textLabel14.Parent = frame16
				local v88 = {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = color6,
					AutoButtonColor = false,
					Position = UDim2.new(1, -96, 0.5, 0),
					Size = UDim2.fromOffset(84, 28),
					Font = Enum.Font.GothamMedium,
					Text = "查看",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					ZIndex = 5
				}
				local textButton11 = Instance.new("TextButton")

				for k, v89 in v88 do
					textButton11[k] = v89
				end

				textButton11.Parent = frame16
				corner(textButton11, 6) -- equivalent call inferred; original call site unknown
				ButtonActions.Bind(textButton11, function()
					v9.archiveKey = archive.dataKey
					v9.archiveLabel = string.format(
						"版本 %s（归档于 %s）",
						string.sub(archive.versionKey, 1, 8),
						formatTime(archive.archivedAt)
					)
					v9.page = "overview"
					refresh()
				end)
				local v90 = {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = color9,
					AutoButtonColor = false,
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(84, 28),
					Font = Enum.Font.GothamMedium,
					Text = "删除",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 12,
					ZIndex = 5
				}
				local textButton12 = Instance.new("TextButton")

				for k, v91 in v90 do
					textButton12[k] = v91
				end

				textButton12.Parent = frame16
				corner(textButton12, 6) -- equivalent call inferred; original call site unknown
				local v92 = archive
				ButtonActions.Bind(textButton12, function()
					textButton12.Text = "..."
					request("archiveDelete", v92.dataKey)

					if v9.archiveKey == v92.dataKey then
						v9.archiveKey = nil
						v9.archiveLabel = nil
					end

					refresh()
				end)
			end
		end
	end

	local flag2 = false

	refreshPair = function()
		if not v9.pairKey then
			renderPairModal() -- equivalent call inferred; original call site unknown
			return
		end

		if not v9.archiveKey then
			renderPairModal(request("pair", v9.pairKey))
			return
		end

		v9.pairKey = nil
		renderPairModal() -- equivalent call inferred; original call site unknown
	end

	refresh = function()
		if flag2 then
			return
		end

		flag2 = true
		local success, result = pcall(function()
			local v83 = request("status")

			if v83 then
				local v84 = textLabel2
				local v86 = string.sub(v83.versionKey, 1, 8)
				local v87 = formatCount(v83.totalMatches) -- equivalent call inferred; original call site unknown
				v84.Text = string.format(
					"配置版本 %s   ·   已存 %s 场样本   ·   %d 种球 / %d 种组合   ·   %s",
					v86,
					v87,
					#v83.roleIds,
					v83.pairCount,
					v83.persistent and "已落盘到 DataStore" or "仅内存（DataStore 不可用）"
				)
				v17.Text = string.format("任务 (%d)", #v83.jobs)
				v16.Text = v83.running and "全部暂停" or "全部继续"

				if v9.drawerOpen then
					renderJobs(v83.jobs)
				end
			end

			frame5.Visible = v9.page == "overview"
			frame6.Visible = v9.page == "ball"
			frame7.Visible = v9.page == "archives"
			local v84 = v9.archiveKey ~= nil
			setButtonEnabled(textButton, not v84) -- equivalent call inferred; original call site unknown
			setButtonEnabled(textButton3, not v84) -- equivalent call inferred; original call site unknown

			if v9.page == "overview" then
				if v84 then
					textLabel3.Text = string.format("只读存档：%s   —   点右上角「历史存档」回到实时数据。", v9.archiveLabel or "")
					renderOverview(request("archiveView", v9.archiveKey))
				else
					textLabel3.Text = "每个样本一次确定性模拟 · 无序组合 · 不停止就一直累积样本。"
					renderOverview(request("overview"))
				end
			elseif v9.page == "ball" and v9.ballRoleId then
				renderBallPage(request("ball", v9.ballRoleId))
			elseif v9.page == "archives" then
				renderArchives(request("archives"))
			end

			for k, v89 in v39 do
				local v90 = k == v9.chartType
				local backgroundColor

				if v90 then
					backgroundColor = color6
				else
					backgroundColor = color2
				end

				v89.BackgroundColor3 = backgroundColor
				local textColor

				if v90 then
					textColor = Color3.fromRGB(255, 255, 255)
				else
					textColor = color5
				end

				v89.TextColor3 = textColor
			end

			updateSortButtons()

			if v9.pairKey and textButton7.Visible then
				renderPairModal(request("pair", v9.pairKey))
			end
		end)
		flag2 = false

		if not success then
			warn("[对局分析] 面板刷新失败：", result)
		end
	end

	ButtonActions.Bind(textButton, function()
		if v9.archiveKey then
			return
		end

		request("jobGlobal")
		v9.drawerOpen = true
		frame14:TweenPosition(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.18, true)
		refresh()
	end)
	ButtonActions.Bind(textButton3, function()
		if v9.archiveKey or not v9.ballRoleId then
			return
		end

		request("jobBall", v9.ballRoleId)
		refresh()
	end)
	ButtonActions.Bind(textButton10, function()
		if v9.archiveKey or not v9.pairKey then
			return
		end

		request("jobPair", v9.pairKey)
		refresh()
	end)
	ButtonActions.Bind(textButton2, function()
		v9.page = "overview"
		v9.ballRoleId = nil
		refresh()
	end)
	ButtonActions.Bind(textButton4, function()
		v9.page = "overview"
		refresh()
	end)
	ButtonActions.Bind(v18, function()
		if v9.page == "archives" then
			v9.archiveKey = nil
			v9.archiveLabel = nil
			v9.page = "overview"
		else
			v9.archiveKey = nil
			v9.archiveLabel = nil
			v9.page = "archives"
		end

		refresh()
	end)
	ButtonActions.Bind(textButton5, function()
		textButton5.Text = "归档中..."
		request("archiveNow")
		textButton5.Text = "归档当前数据"
		refresh()
	end)
	ButtonActions.Bind(v17, function()
		v9.drawerOpen = not v9.drawerOpen
		local v83

		if v9.drawerOpen then
			v83 = UDim2.new(1, 0, 0, 0)
		else
			v83 = UDim2.new(1, 330, 0, 0)
		end

		frame14:TweenPosition(v83, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.18, true)
		refresh()
	end)
	ButtonActions.Bind(textButton6, function()
		v9.drawerOpen = false
		frame14:TweenPosition(UDim2.new(1, 330, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.18, true)
	end)
	ButtonActions.Bind(v16, function()
		local v83 = request("status")

		if v83 then
			request("setRunning", not v83.running)
		end

		refresh()
	end)

	for k, v83 in v39 do
		local chartType = k
		ButtonActions.Bind(v83, function()
			v9.chartType = chartType
			refresh()
		end)
	end

	for k, v83 in v29 do
		local sortMode = k
		ButtonActions.Bind(v83, function()
			if v9.sortMode == sortMode then
				if sortMode ~= "default" then
					v9.sortDesc = not v9.sortDesc
				end
			else
				v9.sortMode = sortMode
				v9.sortDesc = true
			end

			refresh()
		end)
	end

	local function closeModal()
		v9.pairKey = nil
		renderPairModal() -- equivalent call inferred; original call site unknown
	end

	ButtonActions.Bind(textButton9, closeModal)
	ButtonActions.Bind(textButton7, closeModal)
	GamepadPages.Observe(frame14, {
		available = function()
			return drawerOpen
		end,
		defaultButton = textButton6
	})
	GamepadPages.Observe(textButton8, {
		defaultButton = textButton10
	})
	ButtonHints.Shortcut(textButton6, "B")
	ButtonHints.Shortcut(textButton9, "B")
	local RunService = game:GetService("RunService")
	RunService.Heartbeat:Connect(function()
		ButtonHints.Shortcut(v15, (frame6.Visible or frame7.Visible) and "A" or "B")
	end)
	task.spawn(function()
		while true do
			if v9.visible then
				refresh()
			end

			task.wait(1.5)
		end
	end)
	return {
		root = frame,
		setVisible = function(flag3: boolean)
			v9.visible = flag3
			frame.Visible = flag3

			if flag3 then
				task.spawn(refresh)
			end
		end
	}
end

local v7 = false
local v8 = nil

function BattleAnalysisPanelService.open()
	if not v7 then
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "BattleAnalysisPanel"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = false
		screenGui.DisplayOrder = 50
		screenGui.Parent = playerGui
		v8 = build(screenGui)
		v7 = true
	end

	if v8 then
		v8.setVisible(true)
	end
end

function BattleAnalysisPanelService.close()
	if v7 and v8 then
		v8.setVisible(false)
	end
end

return BattleAnalysisPanelService