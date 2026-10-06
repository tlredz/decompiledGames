local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages:WaitForChild("Net"))
local Observers = require(packages:WaitForChild("Observers"))
local ServerTeleport = require(packages:WaitForChild("ServerTeleport"))
local ServerTypeService = require(ReplicatedStorage.Engine.Service.ServerTypeService)
local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
local PlayerThumbnail = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("PlayerThumbnail"))
local UIManager = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Gui"):WaitForChild("UIManager"))
local RewardConfirmQueue = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Gui"):WaitForChild("RewardConfirmQueue"))
local BoostDisplay = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Gui"):WaitForChild("Currency"):WaitForChild("BoostDisplay"))
local GameModeRegistry = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("GameModeRegistry"))

local function getAssetTemplate(p: string, p2: string)
	local byCnId = Config.asset.byCnId

	if byCnId then
		local v = byCnId[p]

		if v and typeof(v.txt) == "string" then
			return v.txt
		end
	end

	if Config.asset and Config.asset.list then
		for _, v in ipairs(Config.asset.list) do
			if v.cnId == p and typeof(v.txt) == "string" then
				return v.txt
			end
		end
	end

	return p2
end

local v = ReplicatedStorage:WaitForChild("音效素材"):WaitForChild("开战倒计时")
local assetTemplate = getAssetTemplate("等待玩家加入", "%d / %d PLAYERS")
local assetTemplate2 = getAssetTemplate("对战奖励", "Win %d")
local assetTemplate3 = getAssetTemplate("加入座位", "加入")

-- equivalent calls inferred from this helper; original call sites unknown
local function getDuelRewardCoins(gameMode: string?)
	local raceCnId = GameModeRegistry.get(gameMode).raceCnId
	local v2 = Config.race.byCnId[raceCnId]
	local rewardCoins = v2 and v2.rewardCoins

	if typeof(rewardCoins) == "number" and rewardCoins >= 0 then
		return (math.floor(rewardCoins))
	end

	return 0
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function easeOutQuad(p: number)
	return 1 - (1 - p) * (1 - p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findPreBattlePanel(instance)
	return instance:FindFirstChild("MainFrame", true) or instance:FindFirstChild("准备面板", true)
end

local function moveModelTo(screenModel, screenBindBox, cframe: CFrame, p: number)
	local cframe2 = screenModel:GetPivot():ToObjectSpace(screenBindBox.CFrame)
	local cFrame = screenBindBox.CFrame
	local lastTime = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v2 = math.clamp((os.clock() - lastTime) / p, 0, 1)
		local v3 = easeOutQuad(v2)
		screenModel:PivotTo(cFrame:Lerp(cframe, v3) * cframe2:Inverse())

		if v2 >= 1 then
			heartbeatConnection:Disconnect()
		end
	end)
	return heartbeatConnection
end

local DuelTableClient = {}
DuelTableClient.__index = DuelTableClient

function DuelTableClient.new()
	local object = setmetatable({}, DuelTableClient)
	object.localPlayer = Players.LocalPlayer
	object.bindings = {}
	object.states = {}
	object.lastCountdownSecondByTable = {}
	object.observerCleanup = nil
	object.destroyed = false
	object.stateConnection = nil
	object.coinLimitConnection = nil
	object.lastHideBackgroundUi = nil
	object:_connectNetwork()
	object.coinLimitConnection = Net:RemoteEvent("DuelCoinLimitReached").OnClientEvent:Connect(function()
		RewardConfirmQueue.enqueueCoinLimitReached()
	end)
	task.spawn(function()
		local serverType = ServerTeleport.getServerType()

		if serverType == ServerTypeService.TRADE_POOL_NAME then
			return
		end

		local v2 = Workspace:WaitForChild("大厅"):WaitForChild("双人对战")

		if serverType == ServerTypeService.TWO_V_TWO_POOL_NAME then
			while v2:GetAttribute("ready") ~= true do
				v2:GetAttributeChangedSignal("ready"):Wait()
			end
		end

		if object.destroyed then
			return
		end

		object.observerCleanup = Observers.observeTag("双人对战桌子", function(model)
			if model:IsA("Model") and model:IsDescendantOf(v2) then
				return object:_bindTable(model)
			end
		end)
	end)
	return object
end

function DuelTableClient:_getSeatModel(instance, childName: string)
	local model = instance:FindFirstChild(childName)

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

function DuelTableClient:_isLocalPlayerAtAnyTable()
	for _, state in self.states do
		for _, v2 in state.seats or {} do
			if v2 and v2.userId == self.localPlayer.UserId then
				return true
			end
		end
	end

	return false
end

function DuelTableClient:_isLocalPlayerAtFinishedTable()
	for _, state in self.states do
		if state.state ~= "Finished" then
			continue
		end

		for _, v2 in state.seats or {} do
			if v2 and v2.userId == self.localPlayer.UserId then
				return true
			end
		end
	end

	return false
end

function DuelTableClient:_isLocalPlayerInActiveMatch()
	local v2 = {
		Picking = true,
		Aiming = true,
		RoundStarting = true,
		Playing = true
	}

	for _, state in self.states do
		if not v2[state.state or ""] then
			continue
		end

		for _, v3 in state.seats or {} do
			if v3 and v3.userId == self.localPlayer.UserId then
				return true
			end
		end
	end

	return false
end

function DuelTableClient:_isSeatAvailable(p2, p3: string)
	local state = self.states[p2]

	if not state then
		return true
	end

	local v2 = state.seats and state.seats[p3]
	return state.state == "Waiting" and (not v2 or v2.userId == nil)
end

function DuelTableClient:_getCurrencyBackground()
	local playerGui = self.localPlayer:FindFirstChildOfClass("PlayerGui")
	local v2 = playerGui and playerGui:FindFirstChild("货币")
	local guiObject = v2 and v2:FindFirstChild("货币栏")

	if guiObject and guiObject:IsA("GuiObject") then
		return guiObject
	end

	return nil
end

function DuelTableClient:_refreshPrompts()
	local _isLocalPlayerAtAnyTable = self:_isLocalPlayerAtAnyTable()

	for k, binding in self.bindings do
		for k2 in binding.prompts do
			local parent = k2.Parent and k2.Parent.Parent
			local name = parent and parent.Name
			local enabled = not _isLocalPlayerAtAnyTable

			if enabled then
				if name == nil then
					enabled = false
				else
					enabled = self:_isSeatAvailable(k, name)
				end
			end

			k2.Enabled = enabled
		end
	end

	if _isLocalPlayerAtAnyTable ~= self.lastHideBackgroundUi then
		self.lastHideBackgroundUi = _isLocalPlayerAtAnyTable
		UIManager.SetScreenGuiEnabled("界面图标", not _isLocalPlayerAtAnyTable)
		UIManager.SetScreenGuiEnabled("右侧菜单", not _isLocalPlayerAtAnyTable)
		local rewardsMenu = UIManager.Get("RewardsMenu")

		if rewardsMenu then
			rewardsMenu.SetTopbarEnabled(not _isLocalPlayerAtAnyTable)
		end

		local playerPanel = UIManager.Get("PlayerPanel")

		if playerPanel then
			playerPanel.SetTopbarEnabled(not _isLocalPlayerAtAnyTable)
		end

		local emoteWheel = UIManager.Get("EmoteWheel")

		if emoteWheel then
			emoteWheel.SetTopbarEnabled(not _isLocalPlayerAtAnyTable)
		end

		local settings = UIManager.Get("Settings")

		if settings then
			settings.SetTopbarEnabled(not _isLocalPlayerAtAnyTable)
		end
	end

	local stickerPanel = UIManager.Get("StickerPanel")

	if stickerPanel then
		stickerPanel.SetTopbarEnabled(_isLocalPlayerAtAnyTable)
	end

	RewardConfirmQueue.SetSuppressed(self:_isLocalPlayerInActiveMatch())
	BoostDisplay.SetSuppressed(self:_isLocalPlayerInActiveMatch())
	local _getCurrencyBackground = self:_getCurrencyBackground()

	if _getCurrencyBackground then
		_getCurrencyBackground.Visible = not _isLocalPlayerAtAnyTable or self:_isLocalPlayerAtFinishedTable() or _getCurrencyBackground:GetAttribute("ForceVisible") == true
	end
end

function DuelTableClient:_updateStatusUi(instance, data)
	local UI = instance:FindFirstChild("状态UI", true)

	if not (UI and UI:IsA("BillboardGui")) then
		return
	end

	local enabled = (data.state or "Waiting") == "Waiting"
	UI.Enabled = enabled

	if not enabled then
		return
	end

	local label = UI:FindFirstChild("游戏状态", true)

	if not (label and label:IsA("TextLabel")) then
		return
	end

	if data.statusText and data.statusText ~= "" then
		label.Text = data.statusText
		return
	end

	local count = 0

	for _ in data.seats or {} do
		count += 1
	end

	label.Text = string.format(assetTemplate, count, #GameModeRegistry.getForTable(instance).seats)
end

function DuelTableClient:_updateRewardUi(instance)
	local label = instance:FindFirstChild("奖金", true)

	if not (label and label:IsA("TextLabel")) then
		return
	end

	local gameMode = instance:GetAttribute("GameMode")

	if typeof(gameMode) ~= "string" then
		gameMode = nil
	end

	label.Text = string.format(assetTemplate2, getDuelRewardCoins(gameMode))
end

function DuelTableClient:_updateNameUi(instance)
	local label = instance:FindFirstChild("名称", true)

	if not (label and label:IsA("TextLabel")) then
		return
	end

	local raceCnId = GameModeRegistry.getForTable(instance).raceCnId
	local v2 = Config.race.byCnId[raceCnId]

	if v2 and typeof(v2.name) == "string" then
		label.Text = v2.name
	end
end

function DuelTableClient:_updateBattlePreStatus(instance, data)
	local label = instance:FindFirstChild("战前状态", true)

	if not (label and label:IsA("TextLabel")) then
		return
	end

	local count = 0

	for _, v2 in data.seats or {} do
		if v2 and v2.userId ~= nil then
			count += 1
		end
	end

	if #GameModeRegistry.getForTable(instance).seats <= count then
		if (data.state or "Waiting") == "Countdown" and data.countdownEndsAt then
			local v2 = math.max(0, (math.ceil(data.countdownEndsAt - Workspace:GetServerTimeNow())))
			label.Text = tostring(v2)

			if v2 > 0 and self.lastCountdownSecondByTable[instance] ~= v2 then
				self.lastCountdownSecondByTable[instance] = v2
				local flag = false

				for _, v4 in data.seats or {} do
					if not (v4 and v4.userId == self.localPlayer.UserId) then
						continue
					end

					flag = true
					break
				end

				if flag then
					v:Play()
				end
			end
		end
	elseif count >= 1 then
		label.Text = "VS"
	end
end

function DuelTableClient:_updateSeatVisuals(instance, p)
	local binding = self.bindings[instance]
	local preBattlePanel = findPreBattlePanel(instance) -- equivalent call inferred; original call site unknown
	local firstChild = instance:FindFirstChild("装饰")
	local state = p.state or "Waiting"
	local v2 = state == "Waiting" or state == "Countdown"
	local v3 = not v2

	if binding and binding.settlementActive and state == "Waiting" then
		binding.settlementActive = false
		local guiObject = instance:FindFirstChild("结算面板", true)

		if guiObject and guiObject:IsA("GuiObject") then
			guiObject.Visible = false
		end
	end

	local v4 = false

	for _, v6 in p.seats or {} do
		if not (v6 and v6.userId ~= nil) then
			continue
		end

		v4 = true
		break
	end

	if preBattlePanel and preBattlePanel:IsA("GuiObject") and not (binding and binding.settlementActive) then
		preBattlePanel.Visible = v4 and not v3
	end

	for _, seat in GameModeRegistry.getForTable(instance).seats do
		local seatName = seat.seatName
		local _getSeatModel = self:_getSeatModel(instance, seatName)
		local v6 = p.seats and p.seats[seatName]
		local v7

		if v6 == nil then
			v7 = false
		else
			v7 = v6.userId ~= nil
		end

		local part = _getSeatModel and _getSeatModel:FindFirstChild("视觉效果")

		if part and part:IsA("BasePart") then
			local material

			if v7 and not v3 then
				material = Enum.Material.Neon
			else
				material = Enum.Material.SmoothPlastic
			end

			part.Material = material
			part.Transparency = v3 and 1 or 0
		end

		local image = preBattlePanel and seat.panelName and preBattlePanel:FindFirstChild(seat.panelName)

		if image and image:IsA("ImageLabel") then
			if v7 then
				local userId = v6.userId
				image.Visible = true

				if binding and binding.avatarUserIdBySeat[seatName] ~= userId then
					binding.avatarUserIdBySeat[seatName] = userId
					PlayerThumbnail.applyAsync(image, userId)
				end
			else
				image.Visible = false

				if binding then
					binding.avatarUserIdBySeat[seatName] = nil
				end
			end
		end

		local folder = firstChild and seat.lightName and firstChild:FindFirstChild(seat.lightName)
		local beamBase = folder and folder:FindFirstChild("BeamBase")
		local beam = beamBase and beamBase:FindFirstChild("Beam")

		if beam and beam:IsA("Beam") then
			beam.Enabled = v7 and v2
		end

		local v8 = folder and folder:FindFirstChild("材质切换")

		if v8 then
			for _, part2 in v8:GetChildren() do
				if not part2:IsA("BasePart") then
					continue
				end

				local material

				if v7 then
					material = Enum.Material.Neon
				else
					material = Enum.Material.SmoothPlastic
				end

				part2.Material = material
			end
		end

		if not folder then
			continue
		end

		for _, part2 in folder:GetDescendants() do
			if not part2:IsA("BasePart") then
				continue
			end

			if v3 then
				part2.Transparency = 1
			else
				local transparency = binding and binding.lightOriginalTransparency[part2]

				if transparency ~= nil then
					part2.Transparency = transparency
				end
			end
		end
	end

	self:_updateScreenVisibility(instance, p)
end

function DuelTableClient:_updateScreenVisibility(p2, p3)
	local binding = self.bindings[p2]

	if not (binding and binding.screenModel and binding.screenBindBox and binding.screenDefaultCFrame and binding.screenHiddenCFrame) then
		return
	end

	if binding.settlementActive then
		return
	end

	local v2 = false

	for _, v4 in p3.seats or {} do
		if not (v4 and v4.userId ~= nil) then
			continue
		end

		v2 = true
		break
	end

	local state = p3.state or "Waiting"
	local screenHidden = not v2 or state ~= "Waiting" and state ~= "Countdown"

	if binding.screenHidden == screenHidden then
		return
	end

	binding.screenHidden = screenHidden

	if binding.screenMoveConnection then
		binding.screenMoveConnection:Disconnect()
	end

	local v5

	if screenHidden then
		v5 = binding.screenHiddenCFrame
	else
		v5 = binding.screenDefaultCFrame
	end

	binding.screenMoveConnection = moveModelTo(binding.screenModel, binding.screenBindBox, v5, 0.5)
end

function DuelTableClient.showSettlement(p, instance, list, flag: boolean?)
	local binding = p.bindings[instance]

	if not binding then
		return
	end

	local state = p.states[instance]

	if state and state.state == "Waiting" then
		binding.settlementActive = false
		return
	end

	binding.settlementActive = true

	if binding.screenModel and binding.screenBindBox and binding.screenDefaultCFrame and binding.screenHiddenCFrame and binding.screenHidden ~= false then
		binding.screenHidden = false

		if binding.screenMoveConnection then
			binding.screenMoveConnection:Disconnect()
		end

		binding.screenMoveConnection = moveModelTo(
			binding.screenModel,
			binding.screenBindBox,
			binding.screenDefaultCFrame,
			0.5
		)
	end

	local preBattlePanel = findPreBattlePanel(instance) -- equivalent call inferred; original call site unknown

	if preBattlePanel and preBattlePanel:IsA("GuiObject") then
		preBattlePanel.Visible = false
	end

	local guiObject = instance:FindFirstChild("结算面板", true)

	if guiObject and guiObject:IsA("GuiObject") then
		guiObject.Visible = true
		local guiObject2 = guiObject:FindFirstChild("赢")
		local guiObject3 = guiObject:FindFirstChild("平局")

		if guiObject2 and guiObject2:IsA("GuiObject") then
			guiObject2.Visible = not flag
		end

		if guiObject3 and guiObject3:IsA("GuiObject") then
			guiObject3.Visible = flag == true
		end

		if not flag and list and guiObject2 then
			local image = guiObject2:FindFirstChild("赢家头像")

			if image and image:IsA("ImageLabel") and list[1] then
				PlayerThumbnail.applyAsync(image, list[1])
				return
			end

			local v2 = 1

			while true do
				local image2 = guiObject2:FindFirstChild("赢家头像" .. tostring(v2))

				if not image2 then
					break
				end

				local v3 = list[v2]

				if image2:IsA("ImageLabel") and v3 then
					PlayerThumbnail.applyAsync(image2, v3)
				end

				v2 += 1
			end
		end
	end
end

function DuelTableClient:_applyState(data)
	local table2 = data.table

	if not (table2 and table2:IsA("Model")) then
		return
	end

	self.states[table2] = data
	self:_updateStatusUi(table2, data)
	self:_updateBattlePreStatus(table2, data)

	if data.state == "Countdown" and data.countdownEndsAt then
		task.spawn(function()
			while self.states[table2] == data and data.state == "Countdown" do
				self:_updateStatusUi(table2, data)
				self:_updateBattlePreStatus(table2, data)

				if Workspace:GetServerTimeNow() >= data.countdownEndsAt then
					break
				else
					task.wait(0.25)
				end
			end
		end)
	end

	self:_updateSeatVisuals(table2, data)
	self:_refreshPrompts()
end

function DuelTableClient:_connectNetwork()
	self.stateConnection = Net:RemoteEvent("DuelTableState").OnClientEvent:Connect(function(p)
		if type(p) ~= "table" then
			return
		end

		if p.table then
			self:_applyState(p)
			return
		end

		local tables = p.tables

		if type(tables) == "table" then
			for _, table2 in tables do
				if type(table2) == "table" then
					self:_applyState(table2)
				end
			end
		end
	end)
	Net:RemoteEvent("DuelTableStateRequest"):FireServer()
end

function DuelTableClient:_bindTable(instance)
	if self.bindings[instance] then
		return
	end

	local v2 = {
		table = instance,
		prompts = {},
		avatarUserIdBySeat = {},
		lightOriginalTransparency = {}
	}
	self.bindings[instance] = v2
	local v3 = GameModeRegistry.getForTable(instance)
	local firstChild = instance:FindFirstChild("装饰")

	if firstChild then
		for _, seat in v3.seats do
			local folder = seat.lightName and firstChild:FindFirstChild(seat.lightName)

			if not folder then
				continue
			end

			for _, part in folder:GetDescendants() do
				if part:IsA("BasePart") then
					v2.lightOriginalTransparency[part] = part.Transparency
				end
			end
		end
	end

	local model = instance:WaitForChild("屏幕", 5)
	local part = instance:WaitForChild("显示面板隐藏位置", 5)

	if model and model:IsA("Model") and part and part:IsA("BasePart") then
		local part2 = model:WaitForChild("绑定箱", 5)

		if part2 and part2:IsA("BasePart") then
			v2.screenModel = model
			v2.screenBindBox = part2
			v2.screenDefaultCFrame = model:GetPivot()
			v2.screenHiddenCFrame = part.CFrame
		else
			warn((`[DuelTableClient] 屏幕缺少绑定箱: {instance:GetFullName()}`))
		end
	else
		warn((`[DuelTableClient] 桌子缺少屏幕或显示面板隐藏位置: {instance:GetFullName()}`))
	end

	local guiObject = instance:FindFirstChild("结算面板", true)

	if guiObject and guiObject:IsA("GuiObject") then
		guiObject.Visible = false
	end

	for _, childName in { "UI方块", "棋盘锚点", "对战视角" } do
		local part2 = instance:FindFirstChild(childName, true)

		if not (part2 and part2:IsA("BasePart")) then
			continue
		end

		part2.Transparency = 1
		part2.Anchored = true
		part2.CanCollide = false
	end

	for _, seat in v3.seats do
		local seatName = seat.seatName
		local _getSeatModel = self:_getSeatModel(instance, seatName)

		if _getSeatModel then
			local part2 = _getSeatModel:WaitForChild("交互点", 5)

			if part2 and part2:IsA("BasePart") then
				local v4 = part2:FindFirstChild("DuelTableJoinPrompt")

				if not v4 then
					v4 = Instance.new("ProximityPrompt")
					v4.Name = "DuelTableJoinPrompt"
					v4.Parent = part2
				end

				v4.ActionText = assetTemplate3
				v4.ObjectText = ""
				v4.HoldDuration = 0
				v4.RequiresLineOfSight = false
				v4.MaxActivationDistance = 10
				local seatName2 = seatName
				v2.prompts[v4] = v4.Triggered:Connect(function()
					if self:_isLocalPlayerAtAnyTable() or not self:_isSeatAvailable(instance, seatName2) then
						return
					end

					Net:RemoteEvent("DuelTableJoinRequest"):FireServer(instance, seatName2)
				end)
			else
				warn((`[DuelTableClient] 座位缺少交互点 {seatName}: {instance:GetFullName()}`))
			end
		else
			warn((`[DuelTableClient] 桌子缺少座位 {seatName}: {instance:GetFullName()}`))
		end
	end

	local state = self.states[instance]
	self:_updateStatusUi(instance, state or {
		table = instance,
		state = "Waiting"
	})
	self:_updateRewardUi(instance)
	self:_updateNameUi(instance)

	if v2.screenModel and v2.screenDefaultCFrame and v2.screenHiddenCFrame then
		local v4 = false

		if state and state.seats then
			for _, seat in state.seats do
				if not (seat and seat.userId ~= nil) then
					continue
				end

				v4 = true
				break
			end
		end

		local state2 = state and state.state or "Waiting"
		v2.screenHidden = not v4 or state2 ~= "Waiting" and state2 ~= "Countdown"
		local screenModel = v2.screenModel
		local v5

		if v2.screenHidden then
			v5 = v2.screenHiddenCFrame
		else
			v5 = v2.screenDefaultCFrame
		end

		screenModel:PivotTo(v5)
	end

	self:_refreshPrompts()
	return function()
		if self.bindings[instance] ~= v2 then
			return
		end

		for _, prompt in v2.prompts do
			prompt:Disconnect()
		end

		if v2.screenMoveConnection then
			v2.screenMoveConnection:Disconnect()
		end

		self.bindings[instance] = nil
		self.states[instance] = nil
	end
end

function DuelTableClient:destroy()
	self.destroyed = true

	if self.observerCleanup then
		self.observerCleanup()
		self.observerCleanup = nil
	end

	if self.stateConnection then
		self.stateConnection:Disconnect()
		self.stateConnection = nil
	end

	if self.coinLimitConnection then
		self.coinLimitConnection:Disconnect()
		self.coinLimitConnection = nil
	end

	for k, binding in self.bindings do
		for _, prompt in binding.prompts do
			prompt:Disconnect()
		end

		if binding.screenMoveConnection then
			binding.screenMoveConnection:Disconnect()
		end

		self.bindings[k] = nil
	end

	table.clear(self.states)
end

return DuelTableClient