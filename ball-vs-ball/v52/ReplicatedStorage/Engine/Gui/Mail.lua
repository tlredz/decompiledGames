local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local DiamondDrawService = require(ReplicatedStorage.Engine.Service.DiamondDrawService)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local RewardBadge = require(ReplicatedStorage.Engine.Gui.RewardsMenu.RewardBadge)
local RewardAutoOpenQueue = require(ReplicatedStorage.Engine.Gui.RewardAutoOpenQueue)
local UnifiedPanel = require(ReplicatedStorage.Engine.Service.GamepadSupport.UnifiedPanel)
local Net = require(ReplicatedStorage.Packages.Net)
local v = nil

local function fn()
	return false
end

local function fn2() end

local v2 = true

local function fn3() end

local remoteEvent = Net:RemoteEvent("MailService/MarkRead")
local remoteFunction = Net:RemoteFunction("MailService/Claim")

local function mailConfig(value: string)
	if DiamondDrawService.parseMailId(value) then
		return Config.mail.byCnId[DiamondDrawService.MAIL_CNID], nil
	end

	local v3 = string.match(value, "^global:(.+)$")

	if v3 then
		return Config.mail.byCnId[v3], nil
	end

	local v4, v5 = string.match(value, "^weeklyTest:(%d+):[%w%-]+:(.+)$")

	if v5 then
		return Config.mail.byCnId[v5], (tonumber(v4))
	end

	local v6, v7 = string.match(value, "^weekly:(%d+):(.+)$")

	if v6 and v7 then
		return Config.mail.byCnId[v7], (tonumber(v6))
	end

	local v8 = string.match(value, "^admin:(.+):[%w%-]+$")

	if v8 then
		return Config.mail.byCnId[v8], nil
	end

	return nil, nil
end

local function formatDescription(row, state)
	local selected = typeof(row.desc) ~= "string" and "" or row.desc

	if typeof(state.prize) == "string" and typeof(state.amount) == "number" then
		local prizeName = DiamondDrawService.prizeName(state.prize)
		local success, result = pcall(string.format, selected, prizeName, state.amount)

		if success then
			return result
		end

		return selected
	else
		local rank = state.rank or 0
		local v4 = string.gsub(selected, "%%d", (tostring(rank)))
		return (string.gsub(v4, "{1:int}", (tostring(rank))))
	end
end

local function mailEntries()
	local mails = client.mailbox.mails()
	local result = {}

	for k, mail in mails do
		local row, week = mailConfig(k)

		if row and typeof(mail) == "table" then
			table.insert(result, {
				id = k,
				state = mail,
				row = row,
				week = week
			})
		end
	end

	table.sort(result, function(a, b)
		if a.state.deliveredAt == b.state.deliveredAt then
			return a.id < b.id
		end

		return a.state.deliveredAt > b.state.deliveredAt
	end)
	return result
end

local function ensureIcon()
	if v then
		return v
	end

	v = TopbarPlus.new()
	v:setImage("rbxassetid://16149098638"):setImageScale(0.8)
	v:setLabel("Mails")
	v:bindEvent("selected", function()
		fn()
	end)
	v:bindEvent("deselected", function()
		fn2()
	end)
	return v
end

local Mail = {}

function Mail.GetIcon()
	return (ensureIcon())
end

function Mail.SetTopbarEnabled(flag: boolean)
	v2 = flag

	if v then
		v:setEnabled(flag)
	end

	if not flag then
		fn2()
	end
end

function Mail.Init()
	local v3 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("邮件")
	local v4 = v3:WaitForChild("背景")
	local v5 = v4:WaitForChild("面板")
	local v6 = v5:WaitForChild("邮件列表")
	local v7 = v5:WaitForChild("邮件详情")
	local v8 = v6:WaitForChild("邮件条目模板")
	local parent = v7:WaitForChild("奖励列表")
	local v10 = parent:WaitForChild("奖励条目模板")
	local closeButton = v5:WaitForChild("关闭按钮")
	local v12 = v7:WaitForChild("领取按钮")
	local v13 = v5:WaitForChild("全部领取按钮")
	local id = nil
	local flag = false
	local v14 = UnifiedPanel.new(v4, {
		closeButton = closeButton,
		scroll = v6,
		isOpen = function()
			return flag
		end
	})
	local v15 = {}
	local v16 = {}
	local v17 = {}
	local flag2 = false
	local flag3 = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hasClaimable()
		for _, v18 in mailEntries() do
			if (v18.state.claimedAt or 0) == 0 then
				return true
			end
		end

		return false
	end

	local function autoOpen()
		-- equivalent call inferred; original call site unknown
		if hasClaimable() then
			return fn()
		end

		return false
	end

	local function tryAutoOpen(items)
		local v18 = false

		for _, item in items do
			if (item.state.claimedAt or 0) ~= 0 or v17[item.id] then
				continue
			end

			v17[item.id] = true
			v18 = true
		end

		if flag2 then
			if v18 and not (flag or flag3) then
				RewardAutoOpenQueue.Enqueue("Mail", autoOpen)
			end
		else
			flag2 = true
			local resolveInitial = RewardAutoOpenQueue.ResolveInitial
			local v20

			if not flag3 then
				v20 = autoOpen
			end

			resolveInitial("Mail", v20)
		end
	end

	v3.Enabled = true
	v4.Visible = false

	for _, button in v6:GetChildren() do
		if button:IsA("GuiButton") then
			button.Visible = false
		end
	end

	for _, frame in parent:GetChildren() do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end

	v8.Visible = false
	v10.Visible = false

	local function claim(p: string)
		local success, result = pcall(function()
			return remoteFunction:InvokeServer(p)
		end)

		if not success or typeof(result) ~= "table" or result.ok ~= true then
			if success and typeof(result) == "table" then
				result = result.reason
			end

			warn("[Mail] 领取失败: " .. tostring(result))
		end
	end

	local function renderRewards(row, state)
		for _, frame in parent:GetChildren() do
			if frame:IsA("Frame") and frame ~= v10 then
				frame:Destroy()
			end
		end

		for k, v18 in Config.reward.byCnId[row.rewardId] or {} do
			local clone = v10:Clone()
			clone.Name = "奖励" .. tostring(k)
			clone.LayoutOrder = k
			clone.Visible = true
			local v19 = Config.asset.byCnId[v18.assetCnId]
			local image = clone:FindFirstChild("奖励图标")
			local label = clone:FindFirstChild("奖励名称")

			if image and image:IsA("ImageLabel") then
				image.Image = (not v19 or typeof(v19.image) ~= "string" or not string.match(v19.image, "^%a+://")) and "" or v19.image
			end

			if label and label:IsA("TextLabel") then
				local amount

				if typeof(state.amount) == "number" then
					amount = state.amount
				else
					amount = v18.count
				end

				local v20 = (not v19 or typeof(v19.txt) ~= "string") and "" or v19.txt

				if v20 == "" and v18.itemType == "货币" then
					v20 = "%d " .. (v18.itemId == "钻石" and "Diamonds" or "Coins")
				end

				if v18.itemType == "头衔" then
					local v21 = Config.playerTitle.byCnId[v18.itemId]
					local v22

					if v21 and typeof(v21.displayName) == "string" then
						v22 = v21.displayName
					else
						v22 = tostring(v18.itemId)
					end

					v20 = string.gsub(v20, "%%s", (string.gsub(v22, "%%", "%%%%")))
				end

				label.Text = string.gsub(v20, "%%d", (tostring(amount)))
			end

			clone.Parent = parent
		end
	end

	local function showDetail(p)
		if not p then
			v7.Visible = false
			return
		end

		v7.Visible = true
		local row = p.row
		local state = p.state
		local waitForChild = v7:WaitForChild("邮件标题")
		waitForChild.Text = row.title
		local waitForChild_2 = v7:WaitForChild("邮件正文")
		waitForChild_2.Text = formatDescription(row, state)
		renderRewards(row, state)
		local visible = (state.claimedAt or 0) > 0
		local waitForChild_3 = v7:WaitForChild("领取按钮")
		waitForChild_3.Visible = not visible
		local waitForChild_4 = v7:WaitForChild("已领取状态")
		waitForChild_4.Visible = visible
	end

	fn3 = function()
		local v18 = mailEntries()
		local v19 = {}
		local count = 0
		local count2 = 0
		local v20 = nil

		for k, v21 in v18 do
			local state = v21.state
			local id2 = v21.id
			v19[id2] = true

			if (state.readAt or 0) == 0 then
				count2 += 1
			end

			if (state.claimedAt or 0) == 0 then
				count += 1
			end

			local clone = v15[id2]

			if not clone then
				clone = v8:Clone()
				clone.Visible = true
				clone.Parent = v6
				v15[id2] = clone
			end

			if v16[id2] ~= k then
				v14:Unbind(clone)
				local id3 = id2
				v14:Bind(clone, function()
					id = id3
					remoteEvent:FireServer(id3)
					fn3()
				end, k)
				v16[id2] = k
			end

			clone.Name = "邮件" .. tostring(k)
			clone.LayoutOrder = k
			local waitForChild = clone:WaitForChild("邮件标题")
			waitForChild.Text = v21.row.title
			local waitForChild_2 = clone:WaitForChild("状态文本")
			waitForChild_2.Text = (state.claimedAt or 0) > 0 and "Claimed" or os.date(
				"!%Y-%m-%d",
				state.deliveredAt or 0
			)
			local waitForChild_3 = clone:WaitForChild("未读标记")
			waitForChild_3.Visible = (state.readAt or 0) == 0
			local waitForChild_4 = clone:WaitForChild("已领取标记")
			waitForChild_4.Visible = (state.claimedAt or 0) > 0

			if id2 == id then
				v20 = v21
			end
		end

		for k, v21 in v15 do
			if v19[k] then
				continue
			end

			v14:Unbind(v21)
			v21:Destroy()
			v15[k] = nil
			v16[k] = nil
		end

		if not v20 and #v18 > 0 then
			v20 = v18[1]
			id = v20.id
		end

		showDetail(v20)
		local v21 = v5:WaitForChild("未读数量容器")
		v21.Visible = count2 > 0
		local waitForChild_5 = v21:WaitForChild("数量文本")
		waitForChild_5.Text = tostring(count2)
		v13.Visible = count > 0
		RewardBadge.Set("mail", ensureIcon(), count)
		v14:Refresh()
		tryAutoOpen(v18)
	end

	v14:Bind(v12, function()
		if id then
			claim(id)
		end
	end, 1000)
	v14:Bind(v13, function()
		claim("ALL")
	end, 1001)
	v14:Bind(closeButton, function()
		fn2()
	end, 1002)

	fn = function()
		if not v2 then
			return false
		end

		if flag then
			return true
		end

		flag = true
		v4.Visible = true
		fn3()

		if id then
			remoteEvent:FireServer(id)
		end

		if v and not v.isSelected then
			v:select()
		end

		v14:Refresh()
		return true
	end

	fn2 = function()
		if not flag then
			return
		end

		flag = false
		v4.Visible = false

		if v and v.isSelected then
			v:deselect()
		end

		v14:Refresh()
		RewardAutoOpenQueue.Finish("Mail")
	end

	local localPlayer = Players.LocalPlayer
	local updateLogSkipAutoOpen = localPlayer:GetAttribute("UpdateLogSkipAutoOpen")

	if updateLogSkipAutoOpen == nil then
		localPlayer:GetAttributeChangedSignal("UpdateLogSkipAutoOpen"):Wait()
		updateLogSkipAutoOpen = localPlayer:GetAttribute("UpdateLogSkipAutoOpen")
	end

	if updateLogSkipAutoOpen == true then
		flag3 = true
	else
		flag3 = false
	end

	client.mailbox.mails.Changed(function()
		fn3()
	end)
	client.mailbox.mails.OnKeyAdded(function()
		fn3()
	end)
	fn3()
end

return Mail