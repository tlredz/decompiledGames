local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local BallBattleStatsService = require(ReplicatedStorage.Engine.Service.BallBattleStatsService)
local BallIndex = {}
local color = Color3.fromRGB(57, 235, 93)
local color2 = Color3.fromRGB(255, 204, 30)
local color3 = Color3.fromRGB(165, 180, 205)
local color4 = Color3.fromRGB(234, 62, 80)
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = {
	{
		text = "Win Rate ↓",
		key = "winRate",
		desc = true
	},
	{
		text = "Win Rate ↑",
		key = "winRate",
		desc = false
	},
	{
		text = "Matches ↓",
		key = "games",
		desc = true
	},
	{
		text = "Matches ↑",
		key = "games",
		desc = false
	}
}
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local parent = nil
local clone = nil
local parent2 = nil
local clone2 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = nil
local v18 = nil
local v19 = nil
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = nil
local clonesByCnId = {}
local v24 = {}
local flag = false
local v25 = 1
local text = ""
local v26 = nil
local v27 = nil
local count = 0
local tweens = {}
local v28 = {}
local v29 = {}

local function formatCount(p: number)
	return (tostring((math.floor(p))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function percentText(p: number)
	return ("%d%%"):format((math.floor(p * 100 + 0.5)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rateColor(p: number?)
	if p == nil then
		return color3
	end

	if p >= 0.5 then
		return color
	end

	return color2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function drawRateColor(value: number)
	local v30 = math.clamp(value, 0, 1)

	if v30 <= 0.5 then
		return color:Lerp(color2, v30 / 0.5)
	end

	return color2:Lerp(color4, (v30 - 0.5) / 0.5)
end

local function statsOf(p: string)
	local v30 = v24[p]

	if v30 then
		return v30
	end

	return {
		games = 0,
		wins = 0,
		losses = 0,
		draws = 0,
		winRate = nil,
		opponents = {},
		mirror = {
			games = 0,
			draws = 0,
			drawRate = nil
		}
	}
end

local function cancelTweens()
	for _, v30 in tweens do
		v30:Cancel()
	end

	table.clear(tweens)

	for k, connection in v29 do
		connection:Disconnect()
		v29[k] = nil
	end
end

local function growDriven(p: string, onChanged)
	local v30 = v28[p]

	if not v30 then
		v30 = Instance.new("NumberValue")
		v28[p] = v30
	end

	local connection = v29[p]

	if connection then
		connection:Disconnect()
	end

	v30.Value = 0
	onChanged(0)
	v29[p] = v30.Changed:Connect(onChanged)
	local tween = TweenService:Create(v30, tweenInfo, {
		Value = 1
	})
	table.insert(tweens, tween)
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function growTo(p, p2: string, uDim, uDim2)
	p[p2] = uDim
	local tween = TweenService:Create(p, tweenInfo, {
		[p2] = uDim2
	})
	table.insert(tweens, tween)
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function growWidth(firstChild, rate: number)
	local Y = firstChild.Size.Y
	growTo(firstChild, "Size", UDim2.new(0, 0, Y.Scale, Y.Offset), UDim2.new(rate, 0, Y.Scale, Y.Offset)) -- equivalent call inferred; original call site unknown
end

local function ringRotations(value: number)
	local v30 = math.clamp(value, 0, 1)
	return math.min(v30, 0.5) * 360, math.clamp(v30 - 0.5, 0, 0.5) * 360 + 180
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRingProgress(value: number)
	local v30 = math.clamp(value, 0, 1)
	local rotation = math.min(v30, 0.5) * 360
	local rotation2 = math.clamp(v30 - 0.5, 0, 0.5) * 360 + 180
	v15.Rotation = rotation
	v16.Rotation = rotation2
	v13.Visible = value > 0
	v14.Visible = value > 0.5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function growRing(winRate: number)
	local v30 = math.clamp(winRate, 0, 1)
	growDriven("ring", function(p)
		applyRingProgress(v30 * p) -- equivalent call inferred; original call site unknown
	end)
end

local function renderCardStats(p: string)
	local v30 = clonesByCnId[p]

	if not v30 then
		return
	end

	local firstChild = v30:FindFirstChild("统计区")
	local firstChild2 = firstChild:FindFirstChild("胜率")
	local firstChild3 = firstChild:FindFirstChild("场次")
	local firstChild4 = firstChild:FindFirstChild("胜率底条"):FindFirstChild("胜率填充")
	local v31 = statsOf(p)
	local uDim = UDim2.new(0, 0, firstChild4.Size.Y.Scale, firstChild4.Size.Y.Offset)

	if flag then
		firstChild3.Text = tostring((math.floor(v31.games))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. " Matches"

		if v31.winRate == nil then
			firstChild2.Text = "—"
			firstChild2.TextColor3 = color3
			firstChild4.Size = uDim
		else
			local v32 = rateColor(v31.winRate) -- equivalent call inferred; original call site unknown
			firstChild2.Text = ("%.1f%%"):format(v31.winRate * 100)
			firstChild2.TextColor3 = v32
			firstChild4.BackgroundColor3 = v32
			firstChild4.Size = UDim2.new(v31.winRate, 0, firstChild4.Size.Y.Scale, firstChild4.Size.Y.Offset)
		end
	else
		firstChild2.Text = "—"
		firstChild2.TextColor3 = color3
		firstChild3.Text = "—"
		firstChild4.Size = uDim
	end
end

local function applySortAndFilter()
	local v30 = v[v25]
	v9.Text = v30.text
	local lower = text:lower()
	local v31 = {}

	for _, v32 in Config.ball.list do
		if clonesByCnId[v32.cnId] then
			table.insert(v31, v32)
		end
	end

	table.sort(v31, function(a, b)
		local v32 = statsOf(a.cnId)
		local v33 = statsOf(b.cnId)
		local v34 = v32.games == 0
		local selected = v33.games == 0

		if v34 ~= selected then
			return selected
		end

		if v34 then
			return a.cnId < b.cnId
		end

		local winRate

		if v30.key == "winRate" then
			winRate = v32.winRate or 0
		else
			winRate = v32.games
		end

		local winRate2

		if v30.key == "winRate" then
			winRate2 = v33.winRate or 0
		else
			winRate2 = v33.games
		end

		if winRate == winRate2 then
			return a.cnId < b.cnId
		end

		if v30.desc then
			return winRate2 < winRate
		end

		return winRate < winRate2
	end)

	for k, v32 in v31 do
		local v33 = clonesByCnId[v32.cnId]
		v33.LayoutOrder = k
		v33.Visible = lower == "" or v32.displayName:lower():find(lower, 1, true) ~= nil or v32.displayNameCN:find(
			text,
			1,
			true
		) ~= nil
	end
end

local function clearOpponentRows()
	count += 1

	for _, child in parent2:GetChildren() do
		if child:GetAttribute("BallIndexGenerated") then
			child:Destroy()
		end
	end

	v27 = nil
	v12.Visible = false
end

local function renderExpandPanel(data)
	local v30 = data.wins + data.losses + data.draws
	local firstChild = v12:FindFirstChild("总场次")
	local firstChild2 = v12:FindFirstChild("胜场数")
	local firstChild3 = v12:FindFirstChild("负场数")
	local firstChild4 = v12:FindFirstChild("平场数")
	firstChild.Text = tostring((math.floor(v30))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. " Matches Total"
	firstChild2.Text = "Wins " .. tostring((math.floor(data.wins))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
		"^,",
		""
	)
	firstChild3.Text = "Losses " .. tostring((math.floor(data.losses))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
		"^,",
		""
	)
	firstChild4.Text = "Draws " .. tostring((math.floor(data.draws))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
		"^,",
		""
	)
	local firstChild5 = v12:FindFirstChild("胜负平比例条")
	local v31 = {
		{
			name = "胜",
			label = "胜百分比",
			value = not (v30 > 0) and 0 or data.wins / v30
		},
		{
			name = "负",
			label = "负百分比",
			value = not (v30 > 0) and 0 or data.losses / v30
		},
		{
			name = "平",
			label = "平百分比",
			value = not (v30 > 0) and 0 or data.draws / v30
		}
	}
	local total = 0

	for _, v32 in v31 do
		v32.segment = firstChild5:FindFirstChild(v32.name)
		v32.labelObj = firstChild5:FindFirstChild(v32.label)
		v32.labelObj.Text = ("%d%%"):format((math.floor(v32.value * 100 + 0.5)))
		v32.start = total
		total += v32.value
	end

	growDriven("expand", function(p)
		for _, v32 in v31 do
			local v33 = math.clamp(p - v32.start, 0, v32.value)
			local segment = v32.segment
			local labelObj = v32.labelObj
			local uDim = UDim2.new(v32.start, 0, segment.Position.Y.Scale, segment.Position.Y.Offset)
			segment.Position = uDim
			segment.Size = UDim2.new(v33, 0, segment.Size.Y.Scale, segment.Size.Y.Offset)
			labelObj.Position = uDim
			labelObj.Size = UDim2.new(v33, 0, labelObj.Size.Y.Scale, labelObj.Size.Y.Offset)
		end
	end)
end

local function toggleExpand(instance, p)
	count += 1
	local v30 = count
	local Y = instance.AbsolutePosition.Y
	local canvasPosition = parent2.CanvasPosition
	task.spawn(function()
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()

		if v30 ~= count or instance.Parent ~= parent2 or (parent2.CanvasPosition - canvasPosition).Magnitude > 1 then
			return
		end

		local v31 = instance.AbsolutePosition.Y - Y
		local v32 = math.max(0, parent2.AbsoluteCanvasSize.Y - parent2.AbsoluteWindowSize.Y)
		parent2.CanvasPosition = Vector2.new(canvasPosition.X, (math.clamp(canvasPosition.Y + v31, 0, v32)))
	end)
	local firstChild = instance:FindFirstChild("展开箭头")

	if v27 == instance then
		v12.Visible = false
		firstChild.Text = "▼"
		v27 = nil
	else
		local v31 = v27 and v27:FindFirstChild("展开箭头")

		if v31 then
			v31.Text = "▼"
		end

		v27 = instance
		firstChild.Text = "▲"
		v12.LayoutOrder = instance.LayoutOrder + 1
		renderExpandPanel(p)
		v12.Visible = true
	end
end

local function renderOpponents(p: string)
	clearOpponentRows()
	local v30 = {}

	for k, opponent in statsOf(p).opponents do
		local ball = Config.ball.byCnId[k]

		if not (ball and ball.canAnalyze) then
			continue
		end

		local v32 = opponent.wins + opponent.losses + opponent.draws

		if v32 > 0 then
			table.insert(v30, {
				ball = ball,
				counts = opponent,
				rate = opponent.wins / v32
			})
		end
	end

	table.sort(v30, function(a, b)
		if a.rate == b.rate then
			return a.ball.cnId < b.ball.cnId
		end

		return a.rate > b.rate
	end)

	for k, v31 in v30 do
		local clone3 = clone2:Clone()
		clone3.Name = "对手行_" .. v31.ball.cnId
		clone3:SetAttribute("BallIndexGenerated", true)
		clone3.LayoutOrder = k * 2
		clone3.Visible = true
		local firstChild = clone3:FindFirstChild("对手名称")
		local firstChild2 = clone3:FindFirstChild("小球图片")
		local firstChild3 = clone3:FindFirstChild("胜率")
		local firstChild4 = clone3:FindFirstChild("展开箭头")
		local firstChild5 = clone3:FindFirstChild("胜率底条"):FindFirstChild("胜率填充")
		firstChild.Text = v31.ball.displayName
		firstChild2.Image = v31.ball.image
		firstChild3.Text = ("%d%%"):format((math.floor(v31.rate * 100 + 0.5)))
		firstChild4.Text = "▼"
		local backgroundColor = rateColor(v31.rate) -- equivalent call inferred; original call site unknown
		firstChild5.BackgroundColor3 = backgroundColor
		clone3.Parent = parent2
		growWidth(firstChild5, v31.rate) -- equivalent call inferred; original call site unknown
		local counts = v31.counts
		ButtonActions.Bind(clone3, function()
			toggleExpand(clone3, counts)
		end)
	end
end

local function openDetail(p: string)
	local v30 = Config.ball.byCnId[p]

	if not (v30 and v30.canAnalyze) then
		return
	end

	cancelTweens()
	v26 = p
	local v31 = statsOf(p)
	v17.Text = v30.displayName
	v18.Image = v30.image
	v19.Text = tostring((math.floor(v31.games))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. " Matches"
	local v32 = v31.winRate ~= nil
	v20.Text = not v32 and "—" or ("%.1f%%"):format(v31.winRate * 100)

	if v32 then
		local imageColor = rateColor(v31.winRate) -- equivalent call inferred; original call site unknown
		v13.ImageColor3 = imageColor
		v14.ImageColor3 = imageColor
		growRing(v31.winRate) -- equivalent call inferred; original call site unknown
	else
		v13.Visible = false
		v14.Visible = false
	end

	local drawRate = v31.mirror.drawRate
	v22.Text = not drawRate and "—" or ("%.1f%%"):format(drawRate * 100)
	v23.Text = tostring((math.floor(v31.mirror.games))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. " Matches"
	local v33 = v21
	local backgroundColor = drawRateColor(drawRate or 0) -- equivalent call inferred; original call site unknown
	v33.BackgroundColor3 = backgroundColor
	local v35 = v21
	local Y = v35.Size.Y
	growTo(v35, "Size", UDim2.new(0, 0, Y.Scale, Y.Offset), UDim2.new(drawRate or 0, 0, Y.Scale, Y.Offset)) -- equivalent call inferred; original call site unknown
	renderOpponents(p)
	parent2.CanvasPosition = Vector2.zero
	v3.Visible = false
	v4.Visible = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showList()
	cancelTweens()
	v26 = nil
	clearOpponentRows()
	v4.Visible = false
	v3.Visible = true
	parent.CanvasPosition = Vector2.zero
end

local function buildCards()
	for _, v30 in Config.ball.list do
		if v30.canAnalyze and not clonesByCnId[v30.cnId] then
			local clone3 = clone:Clone()
			clone3.Name = "卡片_" .. v30.cnId
			clone3:SetAttribute("BallIndexGenerated", true)
			clone3.Visible = true
			local firstChild = clone3:FindFirstChild("小球名称")
			local firstChild2 = clone3:FindFirstChild("小球图片")
			firstChild.Text = v30.displayName
			firstChild2.Image = v30.image
			clone3.Parent = parent
			clonesByCnId[v30.cnId] = clone3
			local cnId = v30.cnId
			ButtonActions.Bind(clone3, function()
				openDetail(cnId)
			end)
		end

		renderCardStats(v30.cnId)
	end
end

local function loadStats()
	local success, result = pcall(BallBattleStatsService.getAll)

	if not success then
		warn("[BallIndex] 拉取全服战绩失败: " .. tostring(result))
		return
	end

	v24 = result
	flag = true

	for k in clonesByCnId do
		renderCardStats(k)
	end

	applySortAndFilter()

	if v26 then
		openDetail(v26)
	end
end

function BallIndex.Open()
	if not v2 then
		return
	end

	local firstChild = v2:FindFirstChild("背景")
	local firstChild2 = firstChild:FindFirstChild("面板")
	firstChild.Visible = true
	firstChild2.Visible = true
	showList() -- equivalent call inferred; original call site unknown
	buildCards()
	applySortAndFilter()
	task.spawn(loadStats)
end

function BallIndex.Close()
	if not v2 then
		return
	end

	cancelTweens()
	local findFirstChild = v2:FindFirstChild("背景")
	findFirstChild.Visible = false
end

function BallIndex.Init()
	v2 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("图鉴")
	local v30 = v2:WaitForChild("背景"):WaitForChild("面板")
	v3 = v30:WaitForChild("图鉴列表页")
	v4 = v30:WaitForChild("小球数据详细页")
	v5 = v30:WaitForChild("关闭按钮")
	v7 = v3:WaitForChild("搜索框")
	v8 = v3:WaitForChild("排序按钮")
	v9 = v8:WaitForChild("文字")
	parent = v3:WaitForChild("小球列表")
	v6 = v4:WaitForChild("返回按钮")
	parent2 = v4:WaitForChild("对手列表")
	local uIListLayout = parent2:FindFirstChildOfClass("UIListLayout")
	local padding = uIListLayout.Padding

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateOpponentPadding()
		uIListLayout.Padding = UDim.new(0, padding.Scale * parent2.AbsoluteSize.Y + padding.Offset)
	end

	parent2:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateOpponentPadding)
	updateOpponentPadding() -- equivalent call inferred; original call site unknown
	parent2.AutomaticCanvasSize = Enum.AutomaticSize.None

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateOpponentCanvas()
		parent2.CanvasSize = UDim2.fromOffset(0, uIListLayout.AbsoluteContentSize.Y)
	end

	uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateOpponentCanvas)
	updateOpponentCanvas() -- equivalent call inferred; original call site unknown
	v12 = parent2:WaitForChild("场次明细")
	v17 = v4:WaitForChild("小球名称")
	v18 = v4:WaitForChild("小球图片")
	v19 = v4:WaitForChild("总场次")
	v21 = v4:WaitForChild("同球平局底条"):WaitForChild("平局填充")
	v22 = v4:WaitForChild("平局比例")
	v23 = v4:WaitForChild("平局场次")
	local v31 = v4:WaitForChild("总胜率圆环")
	v20 = v31:WaitForChild("总胜率")
	v13 = v31:WaitForChild("右半环裁剪"):WaitForChild("进度圆环")
	v14 = v31:WaitForChild("左半环裁剪"):WaitForChild("进度圆环")
	v15 = v13:WaitForChild("进度遮罩")
	v16 = v14:WaitForChild("进度遮罩")
	clone = parent:WaitForChild("卡片1"):Clone()
	clone.AutoButtonColor = false
	clone.Visible = false
	clone2 = parent2:WaitForChild("对手行1"):Clone()
	clone2.AutoButtonColor = false
	clone2.Visible = false

	for _, guiObject in parent:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _, guiObject in parent2:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject ~= v12 then
			guiObject:Destroy()
		end
	end

	v12.Visible = false
	ButtonActions.Bind(v5, function()
		BallIndex.Close()
	end)
	ButtonActions.Bind(v6, showList)
	ButtonActions.Bind(v8, function()
		v25 = v25 % #v + 1
		applySortAndFilter()
	end)
	v7:GetPropertyChangedSignal("Text"):Connect(function()
		text = v7.Text
		applySortAndFilter()
	end)
	v3.Visible = true
	v4.Visible = false
	local findFirstChild = v2:FindFirstChild("背景")
	findFirstChild.Visible = false
end

return BallIndex