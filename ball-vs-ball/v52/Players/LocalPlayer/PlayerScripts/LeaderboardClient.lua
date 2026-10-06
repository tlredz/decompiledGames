local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameFlags = require(ReplicatedStorage.GameFlags)
local v = GameFlags.feature["消费周榜奖励"] == true
local engine = ReplicatedStorage:WaitForChild("Engine")
local PlayerData = require(engine:WaitForChild("Service"):WaitForChild("PlayerData"))
local client = PlayerData.client
local Leaderboard = require(engine:WaitForChild("Service"):WaitForChild("Leaderboard"))
local TimeService = require(engine:WaitForChild("Service"):WaitForChild("TimeService"))
local ServerTypeService = require(engine:WaitForChild("Service"):WaitForChild("ServerTypeService"))
local Config = require(engine:WaitForChild("Service"):WaitForChild("Config"))
local ServerTeleport = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServerTeleport"))
local NumberFormat = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("NumberFormat"))

local function getCurrentWeekKey()
	return (tostring(TimeService.getWeekKey(0, 0, 1)))
end

local function formatRobux(p: number)
	return (`{NumberFormat.commaFormat(p)}`)
end

local function formatDiamonds(value: number)
	return (`💎{NumberFormat.commaFormat(value)}`)
end

local function formatWins(value: number)
	return (`🏆{NumberFormat.commaFormat(value)}`)
end

local function formatWinStreak(value: number)
	return (`🔥{NumberFormat.commaFormat(value)}`)
end

local function formatTradeCount(p: number)
	return NumberFormat.commaFormat(p)
end

local function findText(instance, childName: string)
	local label = instance:FindFirstChild(childName, true)

	if label and label:IsA("TextLabel") then
		return label
	end

	return nil
end

local function renderPlayerRow(callback)
	return function(instance, data)
		local label = instance:FindFirstChild("排名", true)

		if not (label and label:IsA("TextLabel")) then
			label = nil
		end

		local label2 = instance:FindFirstChild("用户名", true)

		if not (label2 and label2:IsA("TextLabel")) then
			label2 = nil
		end

		local label3 = instance:FindFirstChild("数值", true)

		if not (label3 and label3:IsA("TextLabel")) then
			label3 = nil
		end

		if label then
			label.Text = tostring(data.rank)
		end

		if label2 then
			label2.AutoLocalize = false
			label2.Text = (data.emoji or "") .. (data.displayName or "Unknown")
		end

		if label3 then
			label3.Text = callback(data.value)
		end
	end
end

local function applyWeeklyColumns(instance)
	local guiObject = instance:FindFirstChild("排名")
	local guiObject2 = instance:FindFirstChild("数值")

	if guiObject and guiObject:IsA("GuiObject") then
		guiObject.Size = UDim2.fromScale(v and 0.075 or 0.18, 1)
	end

	if guiObject2 and guiObject2:IsA("GuiObject") then
		guiObject2.Size = UDim2.fromScale(v and 0.18 or 0.4, 1)
	end
end

local function renderWeeklySpendRow(instance, p)
	local v2 = formatRobux;
	(function(instance2, data)
		local label = instance2:FindFirstChild("排名", true)

		if not (label and label:IsA("TextLabel")) then
			label = nil
		end

		local label2 = instance2:FindFirstChild("用户名", true)

		if not (label2 and label2:IsA("TextLabel")) then
			label2 = nil
		end

		local label3 = instance2:FindFirstChild("数值", true)

		if not (label3 and label3:IsA("TextLabel")) then
			label3 = nil
		end

		if label then
			label.Text = tostring(data.rank)
		end

		if label2 then
			label2.AutoLocalize = false
			label2.Text = (data.emoji or "") .. (data.displayName or "Unknown")
		end

		if label3 then
			label3.Text = v2(data.value)
		end
	end)(instance, p)
	applyWeeklyColumns(instance)
	local frame = instance:FindFirstChild("奖励列表")

	if not (frame and frame:IsA("Frame")) then
		return
	end

	frame.Visible = v

	if not v then
		return
	end

	for _, button in frame:GetChildren() do
		if button:IsA("GuiButton") and button.Name ~= "奖励框模板" then
			button:Destroy()
		end
	end

	local button = frame:FindFirstChild("奖励框模板")

	if not (button and button:IsA("TextButton")) then
		return
	end

	local cnId = nil
	local v3 = nil

	for _, v4 in Config.reward.list do
		local v5

		if typeof(v4.cnId) == "string" then
			v5 = string.match(v4.cnId, "^每周消费榜前(%d+)奖励$")
		else
			v5 = false
		end

		if not v5 then
			continue
		end

		if cnId and cnId ~= v4.cnId then
			return
		end

		cnId = v4.cnId
		v3 = tonumber(v5)
	end

	if not cnId or not v3 or v3 < p.rank then
		return
	end

	for k, v4 in Config.reward.byCnId[cnId] or {} do
		local clone = button:Clone()
		clone.Name = "运行时奖励" .. tostring(k)
		clone.LayoutOrder = k
		local v5 = Config.asset.byCnId[v4.assetCnId]
		local image = clone:FindFirstChild("物品图标", true)

		if image and image:IsA("ImageLabel") then
			image.Image = (not v5 or typeof(v5.image) ~= "string" or not string.match(v5.image, "^%a+://")) and "" or v5.image
		end

		local color = Color3.new(1, 1, 1)

		for _, v7 in Config.rating.list do
			if v7.lvl ~= v4.rating then
				continue
			end

			local success, result = pcall(Color3.fromHex, v7.colorHex)

			if success then
				color = result
			end

			break
		end

		local uIStroke = clone:FindFirstChild("品质描边")

		if uIStroke and uIStroke:IsA("UIStroke") then
			uIStroke.Color = color
		end

		local uIGradient = clone:FindFirstChildOfClass("UIGradient")

		if uIGradient then
			uIGradient.Color = ColorSequence.new(
				color:Lerp(Color3.new(0, 0, 0), 0.7),
				color:Lerp(Color3.new(0, 0, 0), 0.35)
			)
		end

		clone.Visible = true
		clone.Parent = frame
	end
end

local function robuxSpentClientConfig(model)
	local v2 = {
		kind = "player",
		model = model,
		getValue = function()
			return client.robuxSpent()
		end,
		formatRecord = formatRobux,
		renderRow = 0
	}
	local v3 = formatRobux

	function v2.renderRow(instance, data)
		local label = instance:FindFirstChild("排名", true)

		if not (label and label:IsA("TextLabel")) then
			label = nil
		end

		local label2 = instance:FindFirstChild("用户名", true)

		if not (label2 and label2:IsA("TextLabel")) then
			label2 = nil
		end

		local label3 = instance:FindFirstChild("数值", true)

		if not (label3 and label3:IsA("TextLabel")) then
			label3 = nil
		end

		if label then
			label.Text = tostring(data.rank)
		end

		if label2 then
			label2.AutoLocalize = false
			label2.Text = (data.emoji or "") .. (data.displayName or "Unknown")
		end

		if label3 then
			label3.Text = v3(data.value)
		end
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindRobuxSpent(client2)
	client.robuxSpent.Changed(function(p: number)
		client2.setClientValue("RobuxSpent", p)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getItemDefinition(key: string)
	return Config.ball.byCnId[key] or Config.skin.byCnId[key]
end

local function getItemName(p: string, p2)
	if not p2 then
		return p
	end

	if p2.displayName then
		return p2.displayName
	end

	return p2.name
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRating(rating: number)
	for _, v2 in Config.rating.list do
		if v2.lvl == rating then
			return v2
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isImage(value)
	return typeof(value) == "string" and string.match(value, "^%a+://") ~= nil
end

local function renderItemRow(instance, data)
	local label = instance:FindFirstChild("排名", true)

	if not (label and label:IsA("TextLabel")) then
		label = nil
	end

	local label2 = instance:FindFirstChild("用户名", true)

	if not (label2 and label2:IsA("TextLabel")) then
		label2 = nil
	end

	local label3 = instance:FindFirstChild("数值", true)

	if not (label3 and label3:IsA("TextLabel")) then
		label3 = nil
	end

	local firstChild = instance:FindFirstChild("物品框")
	local image = firstChild and firstChild:FindFirstChild("物品图片")
	local uIStroke = firstChild and firstChild:FindFirstChild("品质描边")
	local uIGradient = firstChild and firstChild:FindFirstChildOfClass("UIGradient")
	local itemDefinition = getItemDefinition(data.key) -- equivalent call inferred; original call site unknown

	if label then
		label.Text = tostring(data.rank)
	end

	if label2 then
		local key2 = data.key

		if itemDefinition then
			if itemDefinition.displayName then
				key2 = itemDefinition.displayName
			else
				key2 = itemDefinition.name
			end
		end

		label2.Text = key2
	end

	if label3 then
		local value = data.value
		label3.Text = NumberFormat.commaFormat(value)
	end

	if image and image:IsA("ImageLabel") then
		local image2

		if itemDefinition then
			image2 = not isImage(itemDefinition.image) and "" or itemDefinition.image
		else
			image2 = ""
		end

		image.Image = image2
	end

	if itemDefinition then
		local rating2 = getRating(itemDefinition.rating) -- equivalent call inferred; original call site unknown

		if rating2 then
			local color = Color3.fromHex(rating2.colorHex)

			if uIStroke and uIStroke:IsA("UIStroke") then
				uIStroke.Color = color
			end

			if uIGradient and uIGradient:IsA("UIGradient") then
				uIGradient.Color = ColorSequence.new(color)
			end
		end
	end
end

local v2 = ServerTeleport.getServerType() == ServerTypeService.TRADE_POOL_NAME
local v3 = workspace:WaitForChild(v2 and "交易大厅" or "大厅"):WaitForChild("排行榜")

if v2 then
	local model = v3:WaitForChild("消费排行榜")
	local model2 = v3:WaitForChild("钻石排行榜")
	local model3 = v3:WaitForChild("交易量排行榜")
	local client2 = Leaderboard.RegisterClient({
		RobuxSpent = robuxSpentClientConfig(model),
		DiamondBalance = {
			kind = "player",
			model = model2,
			getValue = function()
				return client.diamonds()
			end,
			formatRecord = formatDiamonds,
			renderRow = function(instance, data)
				local label = instance:FindFirstChild("排名", true)

				if not (label and label:IsA("TextLabel")) then
					label = nil
				end

				local label2 = instance:FindFirstChild("用户名", true)

				if not (label2 and label2:IsA("TextLabel")) then
					label2 = nil
				end

				local label3 = instance:FindFirstChild("数值", true)

				if not (label3 and label3:IsA("TextLabel")) then
					label3 = nil
				end

				if label then
					label.Text = tostring(data.rank)
				end

				if label2 then
					label2.AutoLocalize = false
					label2.Text = (data.emoji or "") .. (data.displayName or "Unknown")
				end

				if label3 then
					label3.Text = formatDiamonds(data.value)
				end
			end
		},
		ItemTradeVolume = {
			kind = "item",
			model = model3,
			formatRecord = formatTradeCount,
			renderRow = renderItemRow
		}
	})
	bindRobuxSpent(client2) -- equivalent call inferred; original call site unknown
	client.diamonds.Changed(function(p: number)
		client2.setClientValue("DiamondBalance", p)
	end)
else
	local folder = v3:WaitForChild("周消费排行榜")

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Frame") and descendant:FindFirstChild("排名") and descendant:FindFirstChild("数值") then
			applyWeeklyColumns(descendant)
		end

		if descendant.Name == "奖励列表" and descendant:IsA("Frame") or descendant.Name == "奖励表头" and descendant:IsA("TextLabel") then
			descendant.Visible = v
		elseif descendant:IsA("ProximityPrompt") then
			descendant.Enabled = v
		end
	end

	local model = v3:WaitForChild("消费排行榜")
	local client2 = Leaderboard.RegisterClient({
		RobuxSpent = robuxSpentClientConfig(model),
		WeeklyRobuxSpent = {
			kind = "player",
			model = folder,
			getValue = function()
				return client.weeklyRobuxSpent[tostring(TimeService.getWeekKey(0, 0, 1))]() or 0
			end,
			formatRecord = formatRobux,
			renderRow = renderWeeklySpendRow
		},
		Wins = {
			kind = "player",
			getValue = function()
				return client.weeklyWins[tostring(TimeService.getWeekKey(0, 0, 1))]() or 0
			end,
			formatRecord = formatWins,
			renderRow = function(instance, data)
				local label = instance:FindFirstChild("排名", true)

				if not (label and label:IsA("TextLabel")) then
					label = nil
				end

				local label2 = instance:FindFirstChild("用户名", true)

				if not (label2 and label2:IsA("TextLabel")) then
					label2 = nil
				end

				local label3 = instance:FindFirstChild("数值", true)

				if not (label3 and label3:IsA("TextLabel")) then
					label3 = nil
				end

				if label then
					label.Text = tostring(data.rank)
				end

				if label2 then
					label2.AutoLocalize = false
					label2.Text = (data.emoji or "") .. (data.displayName or "Unknown")
				end

				if label3 then
					label3.Text = formatWins(data.value)
				end
			end
		},
		MaxWinStreak = {
			kind = "player",
			getValue = function()
				return client.maxWinStreak()
			end,
			formatRecord = formatWinStreak,
			renderRow = function(instance, data)
				local label = instance:FindFirstChild("排名", true)

				if not (label and label:IsA("TextLabel")) then
					label = nil
				end

				local label2 = instance:FindFirstChild("用户名", true)

				if not (label2 and label2:IsA("TextLabel")) then
					label2 = nil
				end

				local label3 = instance:FindFirstChild("数值", true)

				if not (label3 and label3:IsA("TextLabel")) then
					label3 = nil
				end

				if label then
					label.Text = tostring(data.rank)
				end

				if label2 then
					label2.AutoLocalize = false
					label2.Text = (data.emoji or "") .. (data.displayName or "Unknown")
				end

				if label3 then
					label3.Text = formatWinStreak(data.value)
				end
			end
		}
	})
	client.weeklyRobuxSpent.OnKeyAdded(function(p: string, p2: number)
		if p == tostring(TimeService.getWeekKey(0, 0, 1)) then
			client2.setClientValue("WeeklyRobuxSpent", p2)
		end
	end)
	client.weeklyRobuxSpent.Changed(function(p, _: number, p2: string)
		if p2 == tostring(TimeService.getWeekKey(0, 0, 1)) then
			client2.setClientValue("WeeklyRobuxSpent", p[p2] or 0)
		end
	end)
	client.weeklyWins.OnKeyAdded(function(p: string, p2: number)
		if p == tostring(TimeService.getWeekKey(0, 0, 1)) then
			client2.setClientValue("Wins", p2)
		end
	end)
	client.weeklyWins.Changed(function(p, _: number, p2: string)
		if p2 == tostring(TimeService.getWeekKey(0, 0, 1)) then
			client2.setClientValue("Wins", p[p2] or 0)
		end
	end)
	client.maxWinStreak.Changed(function(p: number)
		client2.setClientValue("MaxWinStreak", p)
	end)
	bindRobuxSpent(client2) -- equivalent call inferred; original call site unknown
end