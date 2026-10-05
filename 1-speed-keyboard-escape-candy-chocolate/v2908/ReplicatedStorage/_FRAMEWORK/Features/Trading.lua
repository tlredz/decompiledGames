local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local AsyncUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.AsyncUtils)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local Config = require(script.Config)
local PlayerReady = require(ReplicatedStorage._FRAMEWORK.Features.PlayerReady)
local isServer = RunService:IsServer()
local TradingManager

if isServer then
	TradingManager = require(script.TradingManager)
else
	TradingManager = nil
end

local Trading = {
	config = Config,
	remotes = remo.createRemotes({
		trading = remo.namespace({
			requestTrade = remo.remote(t.number).middleware(remo.throttleMiddleware(0.35)),
			respondRequest = remo.remote(t.number, t.string).middleware(remo.throttleMiddleware(0.35)),
			addOfferItem = remo.remote(t.string, t.number, t.optional(t.number), t.optional(t.integer)).middleware(remo.throttleMiddleware(0.35)),
			removeOfferItem = remo.remote(t.string, t.number, t.optional(t.number), t.optional(t.integer)).middleware(remo.throttleMiddleware(0.35)),
			setReady = remo.remote(t.boolean).middleware(remo.throttleMiddleware(0.35)),
			cancelContract = remo.remote().middleware(remo.throttleMiddleware(0.35)),
			queryTarget = remo.remote(t.number).returns(t.table).middleware(remo.throttleMiddleware(0.35)),
			openTargetModal = remo.remote(),
			tradeRequest = remo.remote(t.table),
			contractOpened = remo.remote(t.table),
			contractUpdated = remo.remote(t.table),
			contractClosed = remo.remote(t.number),
			showInfo = remo.remote(t.table)
		})
	}).trading,
	openTargetModalFor = function(p)
		assert(isServer, "openTargetModalFor is server-only")
		TradingManager.openTargetModalFor(p)
	end,
	playerCanTrade = function(p)
		assert(isServer, "playerCanTrade is server-only")
		return TradingManager.playerCanTrade(p)
	end,
	isTradeBanned = function(p)
		assert(isServer, "isTradeBanned is server-only")
		return TradingManager.isTradeBanned(p)
	end,
	setTradeBanned = function(p, flag: boolean)
		assert(isServer, "setTradeBanned is server-only")
		return TradingManager.setTradeBanned(p, flag)
	end,
	tradeBan = function(p)
		assert(isServer, "tradeBan is server-only")
		return TradingManager.setTradeBanned(p, true)
	end,
	tradeUnban = function(p)
		assert(isServer, "tradeUnban is server-only")
		return TradingManager.setTradeBanned(p, false)
	end,
	isInContract = function(p)
		assert(isServer, "isInContract is server-only")
		return TradingManager.isInContract(p)
	end,
	requestTrade = function(p, p2: number)
		assert(isServer, "requestTrade is server-only")
		TradingManager.requestTrade(p, p2)
	end
}

if isServer then
	Trading.contractChanged = TradingManager.contractChanged
else
	local UiHelpers = require(script.Client.UiHelpers)
	Trading.fillItemButton = UiHelpers.fillItemButton
	Trading.clearItemButtons = UiHelpers.clearItemButtons
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if isServer then
			local remotes = Trading.remotes
			TradingManager.bindRemotes({
				tradeRequest = remotes.tradeRequest,
				contractOpened = remotes.contractOpened,
				contractUpdated = remotes.contractUpdated,
				contractClosed = remotes.contractClosed,
				showInfo = remotes.showInfo,
				openTargetModal = remotes.openTargetModal
			})
			remotes.requestTrade:connect(function(p, p2)
				TradingManager.requestTrade(p, p2)
			end)
			remotes.respondRequest:connect(function(p, p2, p3)
				TradingManager.respondRequest(p, p2, p3)
			end)
			remotes.addOfferItem:connect(function(p, p2, p3, p4, p5)
				TradingManager.addOfferItem(p, p2, p3, p4, p5)
			end)
			remotes.removeOfferItem:connect(function(p, p2, p3, p4, p5)
				TradingManager.removeOfferItem(p, p2, p3, p4, p5)
			end)
			remotes.setReady:connect(function(p, p2)
				TradingManager.setReady(p, p2)
			end)
			remotes.cancelContract:connect(function(p)
				TradingManager.cancelContract(p)
			end)
			remotes.queryTarget:onRequest(function(p, p2)
				return TradingManager.queryTarget(p, p2)
			end)
			PlayerReady.onPlayerReady:Connect(function(p)
				TradingManager.onPlayerReady(p)
			end)

			for _, v in ipairs(Players:GetPlayers()) do
				TradingManager.onPlayerReady(v)
			end

			Players.PlayerRemoving:Connect(function(player)
				TradingManager.onPlayerRemoving(player)
			end)
		end
	end,
	OnUIInit = not isServer and function()
		local InfoModal = require(script.Client.InfoModal)
		local TargetModal = require(script.Client.TargetModal)
		local RequestModal = require(script.Client.RequestModal)
		local ContractModal = require(script.Client.ContractModal)
		InfoModal.bind(Trading.remotes)
		TargetModal.bind(Trading.remotes)
		RequestModal.bind(Trading.remotes)
		ContractModal.bind(Trading.remotes)
		AsyncUtils.fetchPaidItemTradingAllowed(Players.LocalPlayer)
	end or nil,
	OnUpdate = isServer and function()
		TradingManager.update()
	end or nil
})
return Trading