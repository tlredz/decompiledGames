local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserService = game:GetService("UserService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaceConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("RaceConfig"))
local RaceFormat = require(ReplicatedStorage.Services.RaceFormat)
local RaceRemotes = require(ReplicatedStorage.Services.RaceRemotes)
local TAG_LEADERBOARD = RaceConfig.TAG_LEADERBOARD
local MODES = RaceConfig.MODES
local RACE_WORLDS = RaceConfig.RACE_WORLDS
local DEFAULT_THUMB = RaceConfig.DEFAULT_THUMB
local SCOPE_GLOBAL = RaceConfig.SCOPE_GLOBAL
local SCOPE_LOCAL = RaceConfig.SCOPE_LOCAL
local LB_USE_ODS = RaceConfig.LB_USE_ODS
local LB_USE_LOCAL = RaceConfig.LB_USE_LOCAL
local RANK_COLORS = RaceConfig.RANK_COLORS
local RANK_STROKE_DEFAULT = RaceConfig.RANK_STROKE_DEFAULT
local formatTime = RaceFormat.FormatTime
local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local displayNames = {}
local v = {}
local v2 = {}
local flag = false

local function loadUser(userId: number)
	if not displayNames[userId] then
		local success, result = pcall(function()
			return UserService:GetUserInfosByUserIdsAsync({ userId })
		end)
		displayNames[userId] = success and result and result[1] and result[1].DisplayName or "???"
	end

	if not v[userId] then
		local success, result = pcall(function()
			return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)
		v[userId] = success and result or DEFAULT_THUMB
	end

	return displayNames[userId], v[userId]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pumpQueue()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		while #v2 > 0 do
			local v3 = table.remove(v2, 1)
			local v4, v5 = loadUser(v3.userId)
			v3.apply(v4, v5)
		end

		flag = false
	end)
end

local function enqueueHydrate(userId: number, apply)
	table.insert(v2, {
		userId = userId,
		apply = apply
	})
	pumpQueue() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatValue(p: string, value: number)
	if p == RaceConfig.MODE_FASTEST then
		return formatTime(value)
	end

	return (tostring(value))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function modeLabel(p: string)
	if p == RaceConfig.MODE_FASTEST then
		return "Fastest"
	end

	return "Most Time"
end

local v3 = {}

if LB_USE_LOCAL then
	table.insert(v3, {
		scope = SCOPE_LOCAL
	})
end

if LB_USE_ODS then
	for _, world in RACE_WORLDS do
		table.insert(v3, {
			scope = SCOPE_GLOBAL,
			world = world
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function viewLabel(p)
	if p.scope == SCOPE_LOCAL then
		return "This Server"
	end

	return "World " .. p.world
end

local function viewBoardName(p, p2: string)
	if p.scope == SCOPE_LOCAL then
		return string.format("LB_local_%s", p2)
	end

	return string.format("LB_global_W%d_%s", p.world, p2)
end

local v4 = nil
local v5 = nil
local v6 = nil
local v7 = {}

local function entriesFor(p, p2: string)
	if p.scope == SCOPE_LOCAL then
		return v5 and v5[p2] or {}
	end

	local v8 = v4 and v4[p.world]
	return v8 and v8[p2] or {}
end

local function formatSelf(p, MODE_FASTEST: string)
	local value = nil

	if p.scope == SCOPE_LOCAL then
		for _, v9 in entriesFor(p, MODE_FASTEST) do
			if v9.userId ~= Players.LocalPlayer.UserId then
				continue
			end

			value = v9.value
			break
		end
	else
		local v8 = v6 and v6[p.world]
		value = v8 and v8[MODE_FASTEST]
	end

	if MODE_FASTEST ~= RaceConfig.MODE_FASTEST then
		return (tostring(value or 0))
	end

	if value and value > 0 then
		return formatTime(value)
	end

	return RaceConfig.TIME_PLACEHOLDER
end

local function registerGui(instance)
	if #v3 == 0 or instance:GetAttribute("ChronoLBRegistered") then
		return
	end

	instance:SetAttribute("ChronoLBRegistered", true)
	local container = instance:WaitForChild("Container")
	local worldContainer = container:WaitForChild("WorldContainer")
	local modeContainer = container:WaitForChild("ModeContainer")
	local scrollingFrame = container:WaitForChild("ScrollingFrame")
	scrollingFrame:WaitForChild("Template")

	for _, scrollingFrame2 in container:GetChildren() do
		if not (scrollingFrame2:IsA("ScrollingFrame") and string.sub(scrollingFrame2.Name, 1, 3) == "LB_") then
			continue
		end

		scrollingFrame2:Destroy()
	end

	local MODE_FASTEST = RaceConfig.MODE_FASTEST

	local function makeScroller(name: string)
		local clone = scrollingFrame:Clone()
		clone.Name = name
		clone.Visible = false
		local uIListLayout = clone:FindFirstChildOfClass("UIListLayout")

		if uIListLayout then
			uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				clone.CanvasSize = UDim2.new(0, 0, 0, uIListLayout.AbsoluteContentSize.Y)
			end)
		end

		local template = clone:FindFirstChild("Template")

		if template then
			template.Visible = false
		end

		clone.Parent = container
		return clone
	end

	local v8 = {}
	local v9 = 1

	for k, v10 in v3 do
		v8[k] = {}

		for _, v11 in MODES do
			v8[k][v11] = makeScroller(viewBoardName(v10, v11))
		end
	end

	scrollingFrame.Visible = false

	local function forEachBoard(fn)
		for k, v10 in v3 do
			for _, v11 in MODES do
				fn(v8[k][v11], k, v10, v11)
			end
		end
	end

	local function clearRows(parent)
		for _, child in parent:GetChildren() do
			if child.Name == "Template" or (child:IsA("UIListLayout") or child:IsA("UIPadding")) then
				continue
			end

			child:Destroy()
		end
	end

	local function populate(parent, list, p)
		clearRows(parent)
		local template = parent:FindFirstChild("Template")

		if not template then
			return
		end

		for i, v10 in ipairs(list) do
			local clone = template:Clone()
			clone.Name = "Row_" .. i
			clone.LayoutOrder = i
			clone.Visible = true
			local rankTextLabel = clone:FindFirstChild("RankTextLabel")

			if rankTextLabel then
				rankTextLabel.Visible = false
			end

			local valueTextLabel = clone:FindFirstChild("ValueTextLabel")

			if valueTextLabel then
				local text = formatValue(p, v10.value) -- equivalent call inferred; original call site unknown
				valueTextLabel.Text = text
				valueTextLabel.TextColor3 = RANK_COLORS[i] or RANK_STROKE_DEFAULT
			end

			local displayNameTextLabel = clone:FindFirstChild("DisplayNameTextLabel")

			if displayNameTextLabel then
				displayNameTextLabel.Text = "..."
				displayNameTextLabel.TextColor3 = RANK_COLORS[i] or RANK_STROKE_DEFAULT
			end

			local playerIcon = clone:FindFirstChild("PlayerIcon")
			local thumbnailImage = playerIcon and playerIcon:FindFirstChild("ThumbnailImage")

			if thumbnailImage then
				thumbnailImage.Image = DEFAULT_THUMB
			end

			local uIStroke = thumbnailImage and thumbnailImage:FindFirstChild("UIStroke")

			if uIStroke then
				uIStroke.Color = RANK_COLORS[i] or RANK_STROKE_DEFAULT
			end

			clone.Parent = parent
			local userId = v10.userId

			if not userId then
				continue
			end

			local v11 = displayNameTextLabel
			local v12 = thumbnailImage
			table.insert(v2, {
				userId = userId,
				apply = function(text, image)
					if v11 and v11.Parent then
						v11.Text = text
					end

					if v12 and v12.Parent then
						v12.Image = image
					end
				end
			})
			pumpQueue() -- equivalent call inferred; original call site unknown
		end
	end

	local function populateAll()
		forEachBoard(function(parent, _, p2, p3)
			populate(parent, entriesFor(p2, p3), p3)
		end)
	end

	local function showActive()
		forEachBoard(function(p, p2, _, p3)
			p.Visible = p2 == v9 and p3 == MODE_FASTEST
		end)
		local v10 = v3[v9]
		local textLabel = worldContainer:FindFirstChild("TextLabel")

		if textLabel then
			textLabel.Text = viewLabel(v10)
		end

		local textLabel2 = modeContainer:FindFirstChild("TextLabel")

		if textLabel2 then
			textLabel2.Text = modeLabel(MODE_FASTEST)
		end

		local youTextLabel = container:FindFirstChild("YouTextLabel")

		if youTextLabel then
			youTextLabel.Text = "You: " .. formatSelf(v10, MODE_FASTEST)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cycleView(p)
		v9 = (v9 - 1 + p) % #v3 + 1
		showActive()
	end

	local function toggleMode()
		MODE_FASTEST = MODE_FASTEST == RaceConfig.MODE_FASTEST and RaceConfig.MODE_MOST_TIME or RaceConfig.MODE_FASTEST
		showActive()
	end

	local function wireButton(instance2, childName, callback)
		local button = instance2:FindFirstChild(childName)

		if not (button and button:IsA("TextButton")) then
			return
		end

		local backgroundTransparency = button.BackgroundTransparency
		local backgroundColor3 = button.BackgroundColor3
		local lerped = backgroundColor3:Lerp(Color3.new(1, 1, 1), 0.2)
		local v10 = math.max(backgroundTransparency - 0.15, 0)
		local flag2 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function tweenTo(tweenInfo3, color: Color3, backgroundTransparency2: number)
			TweenService:Create(button, tweenInfo3, {
				BackgroundColor3 = color,
				BackgroundTransparency = backgroundTransparency2
			}):Play()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function settle()
			if flag2 then
				tweenTo(tweenInfo, lerped, v10) -- equivalent call inferred; original call site unknown
			else
				tweenTo(tweenInfo, backgroundColor3, backgroundTransparency) -- equivalent call inferred; original call site unknown
			end
		end

		button.Activated:Connect(function()
			callback()
			tweenTo(tweenInfo2, lerped, v10) -- equivalent call inferred; original call site unknown
			task.delay(tweenInfo2.Time, function()
				if button.Parent then
					settle() -- equivalent call inferred; original call site unknown
				end
			end)
		end)
		button.MouseEnter:Connect(function()
			flag2 = true
			tweenTo(tweenInfo, lerped, v10) -- equivalent call inferred; original call site unknown
		end)
		button.MouseLeave:Connect(function()
			flag2 = false
			tweenTo(tweenInfo, backgroundColor3, backgroundTransparency) -- equivalent call inferred; original call site unknown
		end)
	end

	wireButton(worldContainer, "LeftButton", function()
		cycleView(-1) -- equivalent call inferred; original call site unknown
	end)
	wireButton(worldContainer, "RightButton", function()
		cycleView(1) -- equivalent call inferred; original call site unknown
	end)
	wireButton(modeContainer, "LeftButton", toggleMode)
	wireButton(modeContainer, "RightButton", toggleMode)
	forEachBoard(function(parent, _, p2, p3)
		populate(parent, entriesFor(p2, p3), p3)
	end)
	showActive()
	table.insert(v7, {
		refresh = populateAll,
		showActive = showActive
	})
end

RaceRemotes.ChronoLeaderboardSync:connect(function(p)
	if type(p) ~= "table" then
		return
	end

	v4 = p

	for _, v8 in v7 do
		v8.refresh()
	end
end)
RaceRemotes.RaceLocalLeaderboardSync:connect(function(p)
	if type(p) ~= "table" then
		return
	end

	v5 = p

	for _, v8 in v7 do
		v8.refresh()
		v8.showActive()
	end
end)
RaceRemotes.RaceSelfStats:connect(function(p)
	if type(p) ~= "table" then
		return
	end

	v6 = p

	for _, v8 in v7 do
		v8.showActive()
	end
end)

for _, v8 in CollectionService:GetTagged(TAG_LEADERBOARD) do
	task.spawn(registerGui, v8)
end

CollectionService:GetInstanceAddedSignal(TAG_LEADERBOARD):Connect(function(p)
	task.spawn(registerGui, p)
end)
return {}