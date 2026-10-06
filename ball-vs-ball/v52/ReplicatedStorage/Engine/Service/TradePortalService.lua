local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerTeleport = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServerTeleport"))
local ServerTypeService = require(script.Parent:WaitForChild("ServerTypeService"))
local GameFlags = require(ReplicatedStorage:WaitForChild("GameFlags"))
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("TradePortalFeedback")
local TradePortalService = {
	server = {},
	client = {}
}
local flag = false
local flag2 = false

local function findPromptUnder(childName: string, childName2: string, childName3: string)
	local child = Workspace:FindFirstChild(childName)

	if not child then
		return nil
	end

	local child2 = child:FindFirstChild(childName2)
	local child3 = child2 and child2:FindFirstChild(childName3)
	local proximityPrompt = child3 and child3:FindFirstChild("ProximityPrompt")

	if proximityPrompt and proximityPrompt:IsA("ProximityPrompt") then
		return proximityPrompt
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findTradePrompt()
	return (findPromptUnder("大厅", "交易服传送门", "传送至交易服交互点"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findGamePrompt()
	return (findPromptUnder("交易大厅", "游戏服务器传送门", "传送交互点"))
end

local function pickReservedServerAccessCode()
	local activeReservedServers = ServerTeleport.server.getActiveReservedServers(ServerTypeService.TRADE_POOL_NAME)
	local activeReservedServers2 = {}

	for _, activeReservedServer in activeReservedServers do
		if not (activeReservedServer.playerCount < Players.PreferredPlayers) then
			continue
		end

		table.insert(activeReservedServers2, activeReservedServer)

		if #activeReservedServers2 >= 3 then
			break
		end
	end

	if #activeReservedServers2 == 0 then
		return nil
	end

	return activeReservedServers2[math.random(1, #activeReservedServers2)].accessCode
end

local function onTradePortalTriggered(player)
	if GameFlags.feature["交易服"] ~= true then
		return
	end

	local PlayerData = require(script.Parent.PlayerData)
	local TradeQualificationService = require(script.Parent.TradeQualificationService)
	PlayerData.server.Service:waitForData(player)

	if player.Parent ~= Players then
		return
	end

	local eligibility = TradeQualificationService.getEligibility(player)
	remoteEvent:FireClient(player, eligibility.ok)

	if not eligibility.ok then
		return
	end

	ServerTeleport.server.teleport(ServerTypeService.TRADE_POOL_NAME, {
		plrList = { player },
		reservedServerAccessCode = pickReservedServerAccessCode()
	})
end

local function onGamePortalTriggered(p)
	ServerTeleport.server.teleport("standard", {
		plrList = { p },
		targetServer = "standard"
	})
end

local function init()
	if flag then
		error("[TradePortalService] init() called more than once")
	end

	flag = true
	local tradePrompt = findTradePrompt() -- equivalent call inferred; original call site unknown

	if tradePrompt then
		tradePrompt.Triggered:Connect(onTradePortalTriggered)
	elseif Workspace:FindFirstChild("大厅") then
		warn("[TradePortalService] 未找到交易服传送门交互点，暂不接线")
	end

	local gamePrompt = findGamePrompt() -- equivalent call inferred; original call site unknown

	if gamePrompt then
		gamePrompt.Triggered:Connect(onGamePortalTriggered)
	elseif Workspace:FindFirstChild("交易大厅") then
		warn("[TradePortalService] 未找到游戏服务器传送门交互点，暂不接线")
	end
end

TradePortalService.server.init = init

local function showPortalFeedback(p: string)
	local connection = nil
	local ConfirmDialogController = require(ReplicatedStorage.Engine.Gui.ConfirmDialogController)
	ConfirmDialogController.Show(p, {
		category = "Teleport",
		onShown = function(instance, callback)
			local button = instance:FindFirstChild("确定按钮", true)

			if button and button:IsA("GuiButton") then
				local ConfirmDialogController2 = require(ReplicatedStorage.Engine.Gui.ConfirmDialogController)
				connection = ConfirmDialogController2.BindButton(button, "A", callback)
			end
		end,
		onHidden = function()
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindLocalTeleportFeedback(gamePrompt)
	gamePrompt.Triggered:Connect(function(player)
		if player == Players.LocalPlayer then
			showPortalFeedback("传送中面板")
		end
	end)
end

local function init2()
	if flag2 then
		return
	end

	flag2 = true
	remoteEvent.OnClientEvent:Connect(function(flag3: boolean)
		showPortalFeedback(flag3 and "传送中面板" or "交易解锁条件面板")
	end)
	local gamePrompt = findGamePrompt() -- equivalent call inferred; original call site unknown

	if gamePrompt then
		bindLocalTeleportFeedback(gamePrompt) -- equivalent call inferred; original call site unknown
	end
end

TradePortalService.client.init = init2
return TradePortalService