local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.Packages.Net)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local ItemMetadataDisplay = require(ReplicatedStorage.Engine.Gui.Inventory.ItemMetadataDisplay)
local AssetLibrary = require(ReplicatedStorage.Engine.Service.AssetLibrary)
local LazyGrid = require(ReplicatedStorage.Engine.Gui.Inventory.LazyGrid)
local InventoryView = require(script.InventoryView)
local BallCardQuality = require(ReplicatedStorage.Engine.Service.BallCardQuality)
local BallQualityTextStyle = require(ReplicatedStorage.Engine.Service.BallQualityTextStyle)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local PublicInventoryEquipment = require(ReplicatedStorage.Engine.Service.PublicInventoryEquipment)
local ExperienceService = require(ReplicatedStorage.Engine.Service.ExperienceService)
local PlayerThumbnail = require(ReplicatedStorage.Engine.Service.PlayerThumbnail)
local Trade = require(ReplicatedStorage.Engine.Gui.Trade)
local LevelRewards = require(script.LevelRewards)
local TitleBar = require(script.TitleBar)
local GamepadNavigation = require(script.GamepadNavigation)
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local PlayerPanel = {}
local remoteFunction = Net:RemoteFunction("PlayerPanelGetInfo")
Net:RemoteFunction("TradeGetEligibility")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local flag = false
local v = false
local userId = nil
local v2 = nil
local v3 = nil
local panel = nil
local size = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = nil
local parent = nil
local uIGradient = nil
local numberValue = nil
local v19 = nil
local v20 = nil
local layoutTemplate = nil
local v22 = "profile"
local v23 = nil
local canvasPositions = {}
local count = 0
local cnId = nil
local v24 = "All"
local copiesHeader = nil
local position = nil
local size2 = nil
local key = nil
local v26 = {}
local fn
local v27 = {
	"全部筛选",
	"经典筛选",
	"闪光筛选",
	"彩虹筛选"
}
local v28 = {
	"All",
	"Classic",
	"Shiny",
	"Rainbow"
}
local v29 = {
	balls = {
		field = "balls",
		title = "Balls",
		isBall = true
	},
	explosion = {
		field = "explosions",
		title = "Explosions",
		isBall = false
	},
	flyer = {
		field = "flyers",
		title = "Flyers",
		isBall = false
	}
}
local v30 = nil
local backgroundColor3 = nil
local backgroundColor32 = nil
local trade = nil
local v32 = nil
local v33 = nil
local v34 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidImageValue(value)
	return typeof(value) == "string" and string.match(value, "^%a+://") ~= nil
end

local v35 = nil
local v36 = nil
local v37 = {}

local function paintInventoryCard(instance, data)
	local item = data.item
	local config = data.config
	local v38 = {
		isBall = data.isBall
	}
	local firstChild = instance:FindFirstChild("物品图标")
	firstChild.Image = not isValidImageValue(config.image) and "" or config.image
	local firstChild2 = instance:FindFirstChild("底栏"):FindFirstChild("名称")
	local text

	if v38.isBall then
		text = config.displayName
	else
		text = config.name
	end

	firstChild2.Text = text
	local v41 = not v38.isBall and "Classic" or BallCardQuality.kind({
		serial = item.serial,
		metadata = {
			killCount = item.killCount
		}
	}, config)
	BallQualityTextStyle.apply(firstChild2, v41)

	for _, v42 in Config.rating.list do
		if not (v42.lvl == config.rating and typeof(v42.colorHex) == "string") then
			continue
		end

		local findFirstChild = instance:FindFirstChild("品质描边")
		findFirstChild.Color = Color3.fromHex(v42.colorHex)
		break
	end

	local findFirstChild_2 = instance:FindFirstChild("锁")
	findFirstChild_2.Visible = not data.aggregate and item.tradable == false
	ItemMetadataDisplay.apply(instance, item.serial, item.killCount)
	local isBall = v38.isBall

	if isBall then
		if config.isSpecial == true then
			isBall = false
		else
			isBall = typeof(item.killCount) == "number"
		end
	end

	local v42 = typeof(item.serial) == "number"
	local firstChild3 = firstChild:FindFirstChild("击杀统计+唯一编号效果")
	local firstChild4 = firstChild:FindFirstChild("击杀统计效果")
	firstChild3.Visible = isBall and v42
	firstChild4.Visible = isBall and not v42
	local findFirstChild_3 = instance:FindFirstChild("摆摊中遮罩")
	findFirstChild_3.Visible = not data.aggregate and item.listed == true
	local firstChild5 = instance:FindFirstChild("数量")
	firstChild5.Visible = data.aggregate == true
	firstChild5.Text = not data.aggregate and "" or "x" .. tostring(data.count)
end

local function ensureInventoryGrid()
	if v35 then
		return v35
	end

	v35 = LazyGrid.new(v19, v19, {
		slotAttribute = "PlayerPanelGeneratedSlot",
		layoutTemplate = layoutTemplate,
		active = function()
			return v and v2.Enabled and v3.Visible and v6.Visible
		end,
		assign = function(instance, p)
			v26[instance] = p
			local v39

			if p then
				v39 = p.key or nil
			end

			instance:SetAttribute("ItemInstanceId", v39)
			instance.Active = p ~= nil and p.aggregate == true
		end,
		equal = function(data, data2)
			if data then
				if data.key == data2.key and data.config == data2.config and data.isBall == data2.isBall and data.count == data2.count and data.aggregate == data2.aggregate and data.item.serial == data2.item.serial and data.item.killCount == data2.item.killCount and data.item.tradable == data2.item.tradable and data.item.listed == data2.item.listed then
					data = data.item.equipped == data2.item.equipped
				else
					data = false
				end
			end

			return data
		end,
		paint = paintInventoryCard,
		bindCell = function(p)
			ButtonActions.Bind(p, function()
				local v38 = v26[p]

				if v38 and v38.aggregate and GamepadSupport.CanActivate(p) then
					fn(v38)
				end
			end)
		end,
		bindVisual = function(button)
			button.SizeConstraint = Enum.SizeConstraint.RelativeXY
			button.AutomaticSize = Enum.AutomaticSize.None

			if button:IsA("GuiButton") then
				button.Active = true
				button.Interactable = true
				button.AutoButtonColor = true
				button.Selectable = false
				ButtonActions.Bind(button, function()
					local v38 = v26[button.Parent]

					if v38 and v38.aggregate and GamepadSupport.CanActivate(button) then
						fn(v38)
					end
				end)
			end

			for _, guiObject in button:GetDescendants() do
				if guiObject:IsA("GuiObject") then
					guiObject.Selectable = false
				end

				if not guiObject:IsA("GuiButton") then
					continue
				end

				guiObject.Active = false
				guiObject.Interactable = false
				guiObject.AutoButtonColor = false
			end
		end,
		changed = function()
			if v34 then
				v34:Refresh()
			end
		end
	})
	return v35
end

local function fn2()
	count += 1
	local v38 = v29[v22]
	local v39 = v23
	local inventoryGrid = ensureInventoryGrid()
	local v40 = AssetLibrary.Get("小球卡片", "已拥有小球卡片")

	if v38 and v39 then
		local canvasPosition = v19.CanvasPosition
		v20.Text = v39.displayName .. "'s " .. v38.title

		if v36 ~= v39 then
			v36 = v39
			v37 = {}
		end

		local v41 = v37[v22]

		if not v41 then
			local build = InventoryView.build
			local v42 = v39[v38.field]
			local v43

			if v38.isBall then
				v43 = Config.ball
			else
				v43 = Config.skin
			end

			v41 = build(v42, v43, v38.isBall)
			v37[v22] = v41
		end

		local aggregates = v41.aggregates

		if cnId and not v41.groups[cnId] then
			cnId = nil
			v24 = "All"
			canvasPosition = canvasPositions[v22] or Vector2.zero
		end

		copiesHeader.Visible = cnId ~= nil

		if cnId then
			local group = v41.groups[cnId]
			local v42
			aggregates, v42 = InventoryView.filter(group, v24, v38.isBall)
			local v43 = copiesHeader["标题"]
			local text

			if v38.isBall then
				text = group[1].config.displayName
			else
				text = group[1].config.name
			end

			v43.Text = text
			copiesHeader["总数量"].Text = "Owned: " .. #group

			for k, v45 in v27 do
				local v46 = copiesHeader[v45]
				v46.Visible = v38.isBall or k == 1
				v46["文字组"]["文字"].Text = v28[k]
				v46["文字组"]["数量"].Text = tostring(v42[v28[k]])
				v46.BackgroundColor3 = v46:GetAttribute(v24 == v28[k] and "SelectedColor" or "DefaultColor")
			end

			local v45 = v6["二级列表布局"]
			v19.Position = v45.Position
			v19.Size = v45.Size
		else
			v19.Position = position
			v19.Size = size2
		end

		inventoryGrid:Set(v40, aggregates)
		inventoryGrid:Update()
		v19.CanvasPosition = canvasPosition
		inventoryGrid:Invalidate()
		inventoryGrid:Update()

		if v34 then
			v34:Refresh()
		end
	else
		copiesHeader.Visible = false
		inventoryGrid:Set(v40, {})
		inventoryGrid:Update()
	end
end

fn = function(data)
	if not data.aggregate then
		return
	end

	canvasPositions[v22] = v19.CanvasPosition
	key = data.key
	cnId = data.cnId
	v24 = "All"
	v19.CanvasPosition = Vector2.zero
	fn2()

	if v34 then
		v34:FocusCopies()
	end
end

local function onBack()
	if not cnId then
		return false
	end

	cnId = nil
	v24 = "All"
	fn2()
	v19.CanvasPosition = canvasPositions[v22] or Vector2.zero

	if v35 then
		v35:Invalidate()
		v35:Update()
	end

	if v34 then
		v34:FocusItem(key)
	end

	return true
end

local function setPage(p: string)
	if v33 then
		v33.collapse()
	end

	if v22 ~= "profile" and not cnId then
		canvasPositions[v22] = v19.CanvasPosition
	end

	cnId = nil
	v24 = "All"
	key = nil
	v22 = p
	v5.Visible = p == "profile"
	v6.Visible = p ~= "profile"
	local v38 = v7
	local backgroundColor

	if p == "profile" then
		backgroundColor = backgroundColor3
	else
		backgroundColor = backgroundColor32
	end

	v38.BackgroundColor3 = backgroundColor
	local v40 = v8
	local backgroundColor2

	if p == "balls" then
		backgroundColor2 = backgroundColor3
	else
		backgroundColor2 = backgroundColor32
	end

	v40.BackgroundColor3 = backgroundColor2
	local v42 = v9
	local backgroundColor4

	if p == "explosion" then
		backgroundColor4 = backgroundColor3
	else
		backgroundColor4 = backgroundColor32
	end

	v42.BackgroundColor3 = backgroundColor4
	local v44 = v10
	local backgroundColor5

	if p == "flyer" then
		backgroundColor5 = backgroundColor3
	else
		backgroundColor5 = backgroundColor32
	end

	v44.BackgroundColor3 = backgroundColor5
	v19.CanvasPosition = canvasPositions[p] or Vector2.zero
	fn2()

	if v34 then
		v34:SetPage(p)
	end
end

local color = Color3.new(1, 1, 1)
local color2 = Color3.fromRGB(20, 23, 34)

local function applyExperienceGradient(value: number)
	local v38 = math.clamp(value, 0, 1)

	if v38 <= 0 then
		uIGradient.Color = ColorSequence.new(color2)
		return
	end

	if v38 >= 1 then
		uIGradient.Color = ColorSequence.new(color)
		return
	end

	local v39 = math.max(0, v38 - 0.001)
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(v39, color),
		ColorSequenceKeypoint.new(v38, color2),
		ColorSequenceKeypoint.new(1, color2)
	})
end

local function renderExperience(p: number)
	local levelInfo = ExperienceService.getLevelInfo(p)
	v17.Text = "Lv." .. tostring(levelInfo.level)
	TweenService:Create(numberValue, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Value = levelInfo.progress
	}):Play()
end

local function render(data)
	userId = data.userId
	v23 = data
	v22 = "profile"
	canvasPositions = {}
	cnId = nil
	v24 = "All"
	key = nil
	v32.setViewedPlayer(data.userId)
	PlayerThumbnail.applyAsync(v13, data.userId)
	v11.Text = data.displayName
	v33.setViewed(data.userId, data.equippedTitle)
	v14.Text = tostring(data.wins)
	v15.Text = tostring((math.round(data.wins / math.max(data.totalMatches, 1) * 100))) .. "%"
	v16.Text = "🔥" .. tostring(data.maxWinStreak)
	renderExperience(data.totalExp)
	PlayerThumbnail.applyAsync(v12, data.userId)
	setPage("profile")
	trade.Visible = data.userId ~= Players.LocalPlayer.UserId
end

local function closePanel()
	if not v then
		return
	end

	v = false

	if v34 then
		v34:Close()
	end

	userId = nil
	v23 = nil
	v36 = nil
	v37 = {}
	cnId = nil
	v24 = "All"
	v26 = {}
	copiesHeader.Visible = false

	if v35 then
		v35:Set(AssetLibrary.Get("小球卡片", "已拥有小球卡片"), {})
		v35:Update()
	end

	count += 1
	v32.setViewedPlayer(nil)
	v33.setViewed(nil)
	TweenService:Create(v3, TweenInfo.new(0.2), {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(panel, tweenInfo2, {
		Size = UDim2.fromOffset(0, 0)
	}):Play()
	task.delay(tweenInfo2.Time, function()
		if not v then
			v3.Visible = false
		end
	end)

	if v30 then
		v30:deselect()
	end
end

local function openPanel(p, flag2: boolean)
	render(p)

	if not v then
		v = true
		v3.Visible = true
		v3.BackgroundTransparency = 1
		panel.Size = UDim2.fromOffset(0, 0)
		TweenService:Create(v3, TweenInfo.new(0.2), {
			BackgroundTransparency = 0.5
		}):Play()
		TweenService:Create(panel, tweenInfo, {
			Size = size
		}):Play()
	end

	if v34 then
		v34:Open()
	end

	if p.userId == Players.LocalPlayer.UserId then
		v32.scrollToNextReward()
	end

	if flag2 and v30 then
		v30:select()
	elseif v30 then
		v30:deselect()
	end
end

local function localProfile()
	local v38 = {}
	local flyers = {}
	local explosions = {}
	local balls = {}

	for _, v42 in client.boothListings() do
		if not (typeof(v42) == "table" and typeof(v42.itemInstanceId) == "string") then
			continue
		end

		v38[v42.itemInstanceId] = true
	end

	local items = client.items()
	local resolved = PublicInventoryEquipment.resolve(items, client.equipment(), v38)

	for k, item in items do
		if not (typeof(item) == "table" and typeof(item.itemId) == "string") then
			continue
		end

		if item.itemType == "Ball" then
			local v42 = {
				cnId = item.itemId,
				tradable = item.tradable,
				instanceId = item.instanceId or k,
				serial = item.serial,
				killCount = 0,
				listed = 0,
				equipped = 0
			}
			local killCount

			if typeof(item.metadata) == "table" and typeof(item.metadata.killCount) == "number" then
				killCount = item.metadata.killCount
			end

			v42.killCount = killCount
			v42.listed = v38[item.instanceId or k] == true
			v42.equipped = resolved[item.instanceId or k] == true
			table.insert(balls, v42)
		elseif item.itemType == "爆炸特效" then
			local v42 = {
				cnId = item.itemId,
				tradable = item.tradable,
				instanceId = item.instanceId or k,
				serial = item.serial,
				killCount = 0,
				listed = 0,
				equipped = 0
			}
			local killCount

			if typeof(item.metadata) == "table" and typeof(item.metadata.killCount) == "number" then
				killCount = item.metadata.killCount
			end

			v42.killCount = killCount
			v42.listed = v38[item.instanceId or k] == true
			v42.equipped = resolved[item.instanceId or k] == true
			table.insert(explosions, v42)
		elseif item.itemType == "飞行器" then
			local v42 = {
				cnId = item.itemId,
				tradable = item.tradable,
				instanceId = item.instanceId or k,
				serial = item.serial,
				killCount = 0,
				listed = 0,
				equipped = 0
			}
			local killCount

			if typeof(item.metadata) == "table" and typeof(item.metadata.killCount) == "number" then
				killCount = item.metadata.killCount
			end

			v42.killCount = killCount
			v42.listed = v38[item.instanceId or k] == true
			v42.equipped = resolved[item.instanceId or k] == true
			table.insert(flyers, v42)
		end
	end

	local localPlayer = Players.LocalPlayer
	return {
		userId = localPlayer.UserId,
		displayName = localPlayer.DisplayName,
		wins = client.matchStats.Duel.wins() + client.matchStats.RPS.wins() + client.matchStats.TwoVTwo.wins(),
		totalMatches = client.matchStats.Duel.matches() + client.matchStats.RPS.matches() + client.matchStats.TwoVTwo.matches(),
		totalExp = client.exp.total(),
		maxWinStreak = client.maxWinStreak(),
		balls = balls,
		explosions = explosions,
		flyers = flyers,
		equippedTitle = client.equippedTitle()
	}
end

function PlayerPanel.OpenSelf()
	openPanel(localProfile(), true)
end

function PlayerPanel.OpenPlayer(p: number)
	local success, result = pcall(function()
		return remoteFunction:InvokeServer(p)
	end)

	if not success or typeof(result) ~= "table" or result.ok ~= true or typeof(result.profile) ~= "table" then
		return
	end

	openPanel(result.profile, false)
end

function PlayerPanel.Close()
	closePanel()
end

function PlayerPanel.SetTopbarEnabled(flag2: boolean)
	if not flag2 then
		closePanel()
	end

	if v30 then
		v30:setEnabled(flag2)
	end
end

local function makePlayerPrompt(p, instance)
	if p == Players.LocalPlayer then
		return function() end
	end

	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 5)

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return function() end
	end

	local checkPeopleInfoPrompt = Config.misc.checkPeopleInfoPrompt or {}
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Name = "查看玩家信息"
	proximityPrompt.ActionText = ""
	proximityPrompt.ObjectText = ""
	proximityPrompt.MaxActivationDistance = tonumber(checkPeopleInfoPrompt["交互距离"]) or 5
	proximityPrompt.HoldDuration = tonumber(checkPeopleInfoPrompt["按压时间"]) or 0.5
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = humanoidRootPart
	local triggeredConnection = proximityPrompt.Triggered:Connect(function()
		PlayerPanel.OpenPlayer(p.UserId)
	end)
	return function()
		triggeredConnection:Disconnect()
		proximityPrompt:Destroy()
	end
end

function PlayerPanel.Init()
	if flag then
		return
	end

	flag = true
	v2 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("玩家面板")
	v3 = v2:WaitForChild("背景")
	panel = v3:WaitForChild("面板")
	v5 = panel:WaitForChild("玩家信息")
	v32 = LevelRewards.new(v5:WaitForChild("等级奖励区域"))
	v6 = panel:WaitForChild("通用库存")
	local tabList = panel:WaitForChild("左侧选择栏"):WaitForChild("左侧选择栏")
	v7 = tabList:WaitForChild("玩家信息按钮")
	v8 = tabList:WaitForChild("小球库存按钮")
	v9 = tabList:WaitForChild("爆炸特效库存按钮")
	v10 = tabList:WaitForChild("飞行器库存按钮")
	v13 = v7:WaitForChild("玩家头像")
	PlayerThumbnail.applyAsync(v13, Players.LocalPlayer.UserId)
	v11 = v5:WaitForChild("姓名头衔栏"):WaitForChild("姓名")
	local v39 = v5:WaitForChild("姓名头衔栏"):WaitForChild("头衔栏")
	v33 = TitleBar.new(v39)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function syncNameAlignment()
		local v40 = v11
		local textXAlignment

		if v39.Visible then
			textXAlignment = Enum.TextXAlignment.Left
		else
			textXAlignment = Enum.TextXAlignment.Center
		end

		v40.TextXAlignment = textXAlignment
	end

	v39:GetPropertyChangedSignal("Visible"):Connect(syncNameAlignment)
	syncNameAlignment() -- equivalent call inferred; original call site unknown
	v12 = v5:WaitForChild("玩家头像")
	v14 = v5:WaitForChild("模式列表"):WaitForChild("总胜场"):WaitForChild("数量")
	v15 = v5:WaitForChild("模式列表"):WaitForChild("胜率"):WaitForChild("数值")
	v16 = v5:WaitForChild("模式列表"):WaitForChild("最高连胜"):WaitForChild("数值")
	v19 = v6:WaitForChild("列表")
	v20 = v6:WaitForChild("库存名称")
	layoutTemplate = v19:WaitForChild("占位格子")
	copiesHeader = v6:WaitForChild("副本标题栏")

	for k, v40 in {
		Classic = "经典筛选",
		Shiny = "闪光筛选",
		Rainbow = "彩虹筛选"
	} do
		BallQualityTextStyle.apply(copiesHeader[v40]["文字组"]["文字"], k)
	end

	position = v19.Position
	size2 = v19.Size
	copiesHeader.Visible = false
	ButtonActions.Bind(copiesHeader["返回按钮"], function()
		if GamepadSupport.CanActivate(copiesHeader["返回按钮"]) then
			onBack()
		end
	end)

	for k, v40 in v27 do
		local v41 = copiesHeader[v40]
		local v43 = k
		ButtonActions.Bind(v41, function()
			if not GamepadSupport.CanActivate(v41) then
				return
			end

			v24 = v28[v43]
			v19.CanvasPosition = Vector2.zero
			fn2()
		end)
	end

	size = panel.Size
	backgroundColor3 = v7.BackgroundColor3
	backgroundColor32 = v8.BackgroundColor3
	v17 = v5:WaitForChild("等级")
	parent = v5:WaitForChild("等级条")
	uIGradient = parent:WaitForChild("UIGradient")
	v17.Visible = true
	parent.Visible = true
	numberValue = Instance.new("NumberValue")
	numberValue.Name = "等级进度值"
	numberValue.Value = 0
	numberValue.Parent = parent
	numberValue.Changed:Connect(function(p)
		applyExperienceGradient(p)
	end)
	applyExperienceGradient(numberValue.Value)
	local waitForChild = panel:WaitForChild("交易按钮")
	waitForChild.Visible = false
	trade = panel:WaitForChild("交易按钮")
	trade.Visible = false

	for _, frame in v19:GetChildren() do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end

	layoutTemplate.Visible = false
	v3.Visible = false
	setPage("profile")
	ButtonActions.Bind(v7, function()
		if not GamepadSupport.CanActivate(v7) then
			return
		end

		setPage("profile")
	end)
	ButtonActions.Bind(v8, function()
		if not GamepadSupport.CanActivate(v8) then
			return
		end

		setPage("balls")
	end)
	ButtonActions.Bind(v9, function()
		if not GamepadSupport.CanActivate(v9) then
			return
		end

		setPage("explosion")
	end)
	ButtonActions.Bind(v10, function()
		if not GamepadSupport.CanActivate(v10) then
			return
		end

		setPage("flyer")
	end)
	local close = panel:WaitForChild("关闭按钮")
	ButtonActions.Bind(close, function()
		if GamepadSupport.CanActivate(close) then
			closePanel()
		end
	end)

	local function activateTrade()
		if not GamepadSupport.CanActivate(trade) then
			return
		end

		if userId and userId ~= Players.LocalPlayer.UserId then
			Trade.Request(userId)
		end
	end

	ButtonActions.Bind(trade, activateTrade)
	v34 = GamepadNavigation.new({
		panel = panel,
		tabList = tabList,
		tabs = {
			v7,
			v8,
			v9,
			v10
		},
		lists = {
			v5["等级奖励区域"]["等级奖励"],
			v19,
			v19,
			v19
		},
		close = close,
		trade = trade,
		onPage = setPage,
		onClose = closePanel,
		onTrade = activateTrade,
		copiesHeader = copiesHeader,
		isCopies = function()
			return cnId ~= nil
		end,
		onBack = onBack
	})
	v30 = TopbarPlus.new()
	local _, v41 = PlayerThumbnail.fetchLocalPlayerAsync()
	v30:setImage(v41)
	v30:setImageScale(1)
	v30:modifyTheme({ "IconImageCorner", "CornerRadius", UDim.new(1, 0) })
	v30:setLeft()
	v30:setOrder(2)
	v30:bindEvent("selected", function()
		PlayerPanel.OpenSelf()
	end)
	v30:bindEvent("deselected", closePanel)
	Observers.observeCharacter(makePlayerPrompt)
	Players.PlayerRemoving:Connect(function(player)
		if userId == player.UserId then
			closePanel()
		end
	end)

	local function refreshLocalInventory()
		if v and userId == Players.LocalPlayer.UserId then
			if v22 ~= "profile" and not cnId then
				canvasPositions[v22] = v19.CanvasPosition
			end

			v23 = localProfile()
			fn2()
		end
	end

	client.items.Changed(refreshLocalInventory)
	client.boothListings.Changed(refreshLocalInventory)
	client.equipment.Changed(refreshLocalInventory)

	local function refreshLocalWinRate()
		if v and userId == Players.LocalPlayer.UserId then
			local v42 = localProfile()
			v14.Text = tostring(v42.wins)
			v15.Text = tostring((math.round(v42.wins / math.max(v42.totalMatches, 1) * 100))) .. "%"
			v16.Text = "🔥" .. tostring(v42.maxWinStreak)
		end
	end

	client.matchStats.Duel.wins.Changed(refreshLocalWinRate)
	client.matchStats.RPS.wins.Changed(refreshLocalWinRate)
	client.matchStats.Duel.matches.Changed(refreshLocalWinRate)
	client.matchStats.RPS.matches.Changed(refreshLocalWinRate)
	client.matchStats.TwoVTwo.wins.Changed(refreshLocalWinRate)
	client.matchStats.TwoVTwo.matches.Changed(refreshLocalWinRate)
	client.maxWinStreak.Changed(refreshLocalWinRate)
	client.exp.total.Changed(function(p)
		if v and userId == Players.LocalPlayer.UserId then
			renderExperience(p)
		end
	end)
end

return PlayerPanel