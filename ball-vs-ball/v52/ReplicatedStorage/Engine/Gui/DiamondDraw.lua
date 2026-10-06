local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)
local PlayerThumbnail = require(ReplicatedStorage.Engine.Service.PlayerThumbnail)
local DiamondDrawService = require(ReplicatedStorage.Engine.Service.DiamondDrawService)
local v = true

local function fn(_: string?) end

local function fn2() end

local function formatNumber(p: number)
	return (tostring((math.floor(p))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function formatShort(totalTickets: number)
	if totalTickets >= 1000000 then
		return (string.gsub(string.format("%.1fM", totalTickets / 1000000), "%.0M", "M"))
	end

	if totalTickets >= 1000 then
		return (string.gsub(string.format("%.1fK", totalTickets / 1000), "%.0K", "K"))
	end

	return (tostring((math.floor(totalTickets))))
end

local function formatAgo(p: number)
	local v2 = math.max(0, p)

	if v2 < 3600 then
		local v3 = math.max(1, (math.floor(v2 / 60)))
		return (`{v3} minute{v3 == 1 and "" or "s"} ago`)
	end

	if v2 < 86400 then
		local v3 = math.floor(v2 / 3600)
		return (`{v3} hour{v3 == 1 and "" or "s"} ago`)
	end

	local v3 = math.floor(v2 / 86400)
	return (`{v3} day{v3 == 1 and "" or "s"} ago`)
end

local DiamondDraw = {}

function DiamondDraw.Open(p: string?)
	fn(p)
end

function DiamondDraw.Close()
	fn2()
end

function DiamondDraw.SetTopbarEnabled(flag: boolean)
	v = flag

	if not flag then
		fn2()
	end
end

function DiamondDraw.Init()
	if not DiamondDrawService.isEnabled() then
		return
	end

	local v2 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("全服抽奖活动")
	local v3 = v2:WaitForChild("背景")
	local v4 = v3:WaitForChild("面板")
	local PrizeDrawTabs = require(script.PrizeDrawTabs)
	local v5 = PrizeDrawTabs.Init(v4)
	local v6 = v4:WaitForChild("钻石奖池")
	local v7 = v6:WaitForChild("当前奖池页面")
	local v8 = v6:WaitForChild("历史开奖页面")
	local v9 = v7:WaitForChild("奖池展示"):WaitForChild("奖池数值组"):WaitForChild("奖池数量")
	local v10 = v7:WaitForChild("开奖倒计时")
	local v11 = v7:WaitForChild("参与统计")
	local v12 = v11:WaitForChild("中奖概率"):WaitForChild("数值")
	local v13 = v11:WaitForChild("个人奖券"):WaitForChild("数值")
	local v14 = v11:WaitForChild("全服奖券"):WaitForChild("数值")
	local v15 = v7:WaitForChild("奖券获取进度")
	local v16 = v15:WaitForChild("规则说明")
	local v17 = v15:WaitForChild("进度条"):WaitForChild("填充")
	local v18 = v15:WaitForChild("进度条"):WaitForChild("进度数值")
	local parent = v8:WaitForChild("开奖记录列表")
	local v20 = parent:WaitForChild("开奖记录模板")
	local text = v16.Text
	v2.Enabled = true
	v3.Visible = false
	v20.Visible = false

	for _, frame in parent:GetChildren() do
		if frame:IsA("Frame") and frame ~= v20 then
			frame:Destroy()
		end
	end

	local ConfirmDialogController = require(script.Parent.ConfirmDialogController)
	local flag = false

	local function openRules()
		if flag then
			return
		end

		flag = true
		local connection = nil
		local absoluteSizeChangedConnection = nil
		ConfirmDialogController.Enqueue("钻石奖池规则面板", {
			category = "DiamondDrawRules",
			onShown = function(instance, callback)
				local v21 = instance:WaitForChild("文本框")

				local function resizeText()
					local v22 = math.clamp(v21.AbsoluteSize.Y * 0.06, 14, 24)

					for _, label in v21:GetChildren() do
						if not label:IsA("TextLabel") then
							continue
						end

						local textSize

						if label:GetAttribute("RulesHeading") then
							textSize = v22 * 1.15
						else
							textSize = v22
						end

						label.TextSize = textSize
					end
				end

				absoluteSizeChangedConnection = v21:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeText)
				resizeText()
				v21.CanvasPosition = Vector2.zero
				connection = ConfirmDialogController.BindButton(instance:WaitForChild("关闭按钮"), "B", callback)
			end,
			onHidden = function()
				flag = false

				if connection then
					connection:Disconnect()
				end

				if absoluteSizeChangedConnection then
					absoluteSizeChangedConnection:Disconnect()
				end
			end
		})
	end

	for _, v21 in { v7, v8 } do
		local button = v21:FindFirstChild("帮助按钮")

		if not (button and button:IsA("GuiButton")) then
			continue
		end

		button.Visible = true
		button.Active = true
		ButtonActions.Bind(button, openRules)
	end

	v16.Text = string.gsub(text, "%d+ diamonds", (`{DiamondDrawService.ticketCost()} diamonds`))
	v9.Text = "0"
	v12.Text = "0%"
	v13.Text = "0"
	v14.Text = "0"
	v10.Text = ""
	v18.Text = `0 / {DiamondDrawService.ticketCost()}`
	v17.Size = UDim2.new(0, 0, v17.Size.Y.Scale, v17.Size.Y.Offset)
	local flag2 = false
	local v21 = nil
	local v22 = 0
	local v23 = ""

	-- equivalent calls inferred from this helper; original call sites unknown
	local function myState()
		return (client.diamondDraw())
	end

	local function renderCurrent()
		local ticketCost = DiamondDrawService.ticketCost()
		local v24 = myState() -- equivalent call inferred; original call site unknown
		local v25 = math.clamp((v24.spendProgress or 0) / ticketCost, 0, 1)
		v17.Size = UDim2.new(v25 * 0.986, 0, v17.Size.Y.Scale, v17.Size.Y.Offset)
		v18.Text = `{math.floor(v24.spendProgress or 0)} / {ticketCost}`

		if not v21 then
			return
		end

		local v26 = v24.period ~= v21.period and 0 or v24.tickets
		local v27 = math.max(v21.summary.tickets, v26)
		v9.Text = tostring((math.floor(v21.summary.pool))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
		v13.Text = tostring((math.floor(v26))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
		v14.Text = tostring((math.floor(v27))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
		v12.Text = not (v26 > 0 and v27 > 0) and "0%" or string.format("%.4f%%", v26 / v27 * 100)
	end

	local function renderCountdown()
		if not v21 then
			v10.Text = ""
			return
		end

		local now = TimeService.now()

		if now < v21.lockAt then
			v10.Text = "Next draw in: " .. TimeService.formatClock(v21.drawAt - now)
		else
			v10.Text = "Entries closed. Drawing in: " .. TimeService.formatClock((math.max(0, v21.drawAt - now)))
		end
	end

	local function setWinner(instance, data)
		local image = instance:FindFirstChild("玩家头像")
		local label = instance:FindFirstChild("玩家名称")
		local label2 = instance:FindFirstChild("用户名")
		local label3 = instance:FindFirstChild("奖励数量")
		local label4 = instance:FindFirstChild("奖券数量")

		if image and image:IsA("ImageLabel") then
			if data then
				PlayerThumbnail.applyAsync(image, data.u)
			else
				image.Image = ""
			end
		end

		if label and label:IsA("TextLabel") then
			label.Text = not data and "-" or data.d or data.n or tostring(data.u)
		end

		if label2 and label2:IsA("TextLabel") then
			label2.Text = not (data and data.n) and "" or "@" .. data.n
		end

		if label3 and label3:IsA("TextLabel") then
			label3.Text = not data and "0" or tostring((math.floor(data.a))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
				"^,",
				""
			)
		end

		if label4 and label4:IsA("TextLabel") then
			local v24 = not data and 0 or data.t
			local text2

			if instance.Name == "一等奖" then
				text2 = `{tostring((math.floor(v24))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")} tickets`
			else
				text2 = tostring((math.floor(v24))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
			end

			label4.Text = text2
		end
	end

	local function renderRecord(clone, data)
		local prizes = data.prizes or {}
		local v24 = clone:WaitForChild("开奖信息栏")
		local waitForChild = v24:WaitForChild("开奖时间")
		waitForChild.Text = formatAgo(TimeService.now() - (data.drawnAt or 0))
		local waitForChild_2 = v24:WaitForChild("全服奖券")
		waitForChild_2.Text = "Total Tickets: " .. formatShort(data.totalTickets or 0)

		for _, v25 in Config.diamondDrawPrize.list do
			local child = clone:FindFirstChild(v25.cnId)
			local v26 = prizes[v25.cnId] or {
				count = 0,
				total = 0,
				winners = {}
			}

			if not child then
				continue
			end

			local label = child:FindFirstChild("奖项标题")

			if label and label:IsA("TextLabel") then
				label.Text = DiamondDrawService.prizeName(v25.cnId)
			end

			local firstChild = child:FindFirstChild("获奖玩家列表")
			local firstChild2 = child:FindFirstChild("获奖名单按钮")
			local label2 = child:FindFirstChild("中奖人数")

			if firstChild then
				for _, guiObject in firstChild:GetChildren() do
					local v27 = tonumber(string.match(guiObject.Name, "^获奖玩家示例(%d+)$"))

					if not (v27 and guiObject:IsA("GuiObject")) then
						continue
					end

					local winner = v26.winners[v27]
					guiObject.Visible = winner ~= nil

					if winner then
						setWinner(guiObject, winner)
					end
				end
			elseif firstChild2 then
				local label3 = firstChild2:FindFirstChild("文字")

				if label3 and label3:IsA("TextLabel") then
					label3.Text = `{tostring((math.floor(v26.count))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")} Winners`
				end

				for i = 1, 3 do
					local image = child:FindFirstChild("玩家头像示例" .. i)

					if not (image and image:IsA("ImageLabel")) then
						continue
					end

					local winner = v26.winners[i]
					image.Visible = winner ~= nil

					if winner then
						PlayerThumbnail.applyAsync(image, winner.u)
					end
				end

				local guiObject = child:FindFirstChild("更多标记")

				if guiObject and guiObject:IsA("GuiObject") then
					guiObject.Visible = v26.count > 3
				end

				local label4 = child:FindFirstChild("奖励总额")

				if label4 and label4:IsA("TextLabel") then
					label4.Text = tostring((math.floor(v26.total))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
						"^,",
						""
					)
				end
			elseif label2 then
				if label2:IsA("TextLabel") then
					label2.Text = `Awarded to {tostring((math.floor(v26.count))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")} players`
				end

				local label3 = child:FindFirstChild("奖励总额")

				if label3 and label3:IsA("TextLabel") then
					label3.Text = tostring((math.floor(v26.total))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
						"^,",
						""
					)
				end
			else
				setWinner(child, v26.winners[1])
			end
		end
	end

	local function renderHistory()
		if not v21 then
			return
		end

		local history = v21.history or {}
		local v24 = tostring(#history) .. ":" .. tostring(not history[1] and 0 or history[1].period or 0)

		if v24 == v23 then
			for k, v25 in history do
				local child = parent:FindFirstChild("开奖记录" .. k)

				if child then
					child["开奖信息栏"]["开奖时间"].Text = formatAgo(TimeService.now() - (v25.drawnAt or 0))
				end
			end
		else
			v23 = v24

			for _, frame in parent:GetChildren() do
				if frame:IsA("Frame") and frame ~= v20 then
					frame:Destroy()
				end
			end

			local v25 = math.max(1, #history * 0.8280000000000001)
			parent.CanvasSize = UDim2.fromScale(0, v25)

			for k, v26 in history do
				local clone = v20:Clone()
				clone.Name = "开奖记录" .. k
				clone.Position = UDim2.fromScale(v20.Position.X.Scale, (k - 1) * 0.8280000000000001 / v25)
				clone.Size = UDim2.fromScale(v20.Size.X.Scale, 0.792 / v25)
				clone.Visible = true
				renderRecord(clone, v26)
				clone.Parent = parent
			end
		end
	end

	local function refreshState()
		local state = DiamondDrawService.getState()

		if typeof(state) == "table" then
			v21 = state
			v22 = TimeService.now()
		end

		renderCurrent()
		renderCountdown()

		if v8.Visible then
			renderHistory()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function showPage(p)
		v7.Visible = p == v7
		v8.Visible = p == v8

		if p == v8 then
			renderHistory()
		end
	end

	for _, v24 in { v7, v8 } do
		local v25 = v24:WaitForChild("页签栏")
		ButtonActions.Bind(v25:WaitForChild("当前页签"), function()
			showPage(v7) -- equivalent call inferred; original call site unknown
		end)
		ButtonActions.Bind(v25:WaitForChild("历史页签"), function()
			showPage(v8) -- equivalent call inferred; original call site unknown
		end)
	end

	ButtonActions.Bind(v4:WaitForChild("关闭按钮"), function()
		fn2()
	end)
	ButtonActions.Bind(v7:WaitForChild("前往商店按钮"), function()
		fn2()
		local Store = require(ReplicatedStorage.Engine.Gui.Store)
		Store.OpenHome()
	end)

	fn = function(p: string?)
		if not v then
			return
		end

		v5.SetActivity((p == "history" or p == "current") and "diamond" or "raffle")
		local v24

		if p == "history" then
			v24 = v8
		else
			v24 = v7
		end

		showPage(v24) -- equivalent call inferred; original call site unknown

		if flag2 then
			return
		end

		flag2 = true
		v3.Visible = true
		task.spawn(refreshState)
		task.spawn(function()
			while flag2 do
				renderCountdown()

				if TimeService.now() - v22 >= 60 or v21 and TimeService.now() >= v21.drawAt then
					v22 = TimeService.now()
					task.spawn(refreshState)
				end

				task.wait(1)
			end
		end)
	end

	fn2 = function()
		if not flag2 then
			return
		end

		flag2 = false
		v3.Visible = false
	end

	client.diamondDraw.Changed(function()
		if flag2 then
			renderCurrent()
		end
	end)
end

return DiamondDraw