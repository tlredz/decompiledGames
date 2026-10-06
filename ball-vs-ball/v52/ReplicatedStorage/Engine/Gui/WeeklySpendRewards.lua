local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local Leaderboard = require(ReplicatedStorage.Engine.Service.Leaderboard)
local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)
local RunService = game:GetService("RunService")
local ConfirmDialogController = require(script.Parent.ConfirmDialogController)
local GameFlags = require(ReplicatedStorage.GameFlags)
local v = GameFlags.feature["消费周榜奖励"] == true
local WeeklySpendRewards = {}
local flag = false
local flag2 = false

local function renderRewards(instance)
	local parent = instance:WaitForChild("奖励列表")
	local v3 = parent:WaitForChild("奖励卡片模板")

	for _, guiObject in parent:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject ~= v3 then
			guiObject:Destroy()
		end
	end

	for k, v4 in Config.reward.byCnId["每周消费榜前50奖励"] or {} do
		local clone = v3:Clone()
		clone.Name = "奖励" .. tostring(k)
		clone.LayoutOrder = k
		local v5 = Config.asset.byCnId[v4.assetCnId]
		local txt

		if v5 and typeof(v5.txt) == "string" then
			txt = v5.txt
		else
			txt = v4.itemId
		end

		if string.find(txt, "%d", 1, true) then
			txt = string.gsub(txt, "%%d", (tostring(v4.count)))
		end

		local v6 = clone["名称"]["文字"]
		local v7 = clone["物品图标"]
		v6.Text = txt
		v7.Image = (not v5 or typeof(v5.image) ~= "string" or not string.match(v5.image, "^%a+://")) and "" or v5.image
		local color = Color3.new(1, 1, 1)

		for _, v9 in Config.rating.list do
			if v9.lvl ~= v4.rating then
				continue
			end

			local success, result = pcall(Color3.fromHex, v9.colorHex)

			if success then
				color = result
			end

			break
		end

		for _, v9 in { clone, clone["名称"] } do
			local uIStroke = v9:FindFirstChildOfClass("UIStroke")

			if uIStroke then
				uIStroke.Color = color
			end
		end

		local uIGradient = clone:FindFirstChildOfClass("UIGradient")

		if uIGradient then
			uIGradient.Color = ColorSequence.new(
				color:Lerp(Color3.new(0, 0, 0), 0.7),
				color:Lerp(Color3.new(0, 0, 0), 0.35)
			)
		end

		clone.Visible = true
		clone.Parent = parent
	end

	parent.CanvasPosition = Vector2.zero
end

local function renderInformation(p)
	local now = TimeService.now()
	local v2 = (TimeService.getWeekBoundaryDayKeyAt(now, 0, 0, 1) + 7) * 86400
	p["发放时间说明"].Text = "Rewards in " .. TimeService.formatCountdown(v2 - now)
	local myStanding = Leaderboard.GetMyStanding("WeeklyRobuxSpent")
	local v3

	if myStanding then
		local rank = tonumber(myStanding.rank)
		v3 = not (rank and rank <= 50) and "#50+" or "#" .. tostring(rank)
	else
		v3 = "Loading..."
	end

	p["排名规则说明"].Text = "Your rank: " .. v3
end

function WeeklySpendRewards.Open()
	if not v or flag2 then
		return
	end

	flag2 = true
	local v2 = {}
	local v3 = nil
	ConfirmDialogController.Enqueue("每周最高消费榜奖励面板", {
		category = "WeeklySpendRewards",
		onShown = function(p, callback)
			renderRewards(p)
			renderInformation(p)
			v3 = Leaderboard.OnChanged("WeeklyRobuxSpent", function()
				renderInformation(p)
			end)
			local total = 0
			table.insert(v2, RunService.Heartbeat:Connect(function(dt: number)
				total += dt

				if total >= 1 then
					total = 0
					renderInformation(p)
				end
			end))
			table.insert(v2, ConfirmDialogController.BindButton(p["确定按钮"], "A", callback))
		end,
		onHidden = function()
			if v3 then
				v3()
				v3 = nil
			end

			for _, connection in v2 do
				connection:Disconnect()
			end

			table.clear(v2)
			flag2 = false
		end
	})
end

function WeeklySpendRewards.Init()
	if not v or flag then
		return
	end

	flag = true
	local waitForChild = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("通用确认框"):WaitForChild("背景"):WaitForChild("每周最高消费榜奖励面板"):WaitForChild("奖励列表"):WaitForChild("奖励卡片模板")
	waitForChild.Visible = false
	ConfirmDialogController.Init()
	ProximityPromptService.PromptTriggered:Connect(function(player, p)
		if p ~= Players.LocalPlayer then
			return
		end

		local firstChild = workspace:FindFirstChild("大厅")
		local v2 = firstChild and firstChild:FindFirstChild("排行榜")
		local v3 = v2 and v2:FindFirstChild("周消费排行榜")
		local v4 = v3 and v3:FindFirstChild("交互点")

		if v4 and player == v4:FindFirstChild("ProximityPrompt") then
			WeeklySpendRewards.Open()
		end
	end)
end

return WeeklySpendRewards