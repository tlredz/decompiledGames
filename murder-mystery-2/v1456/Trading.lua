local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
local PolicyService = game:GetService("PolicyService")
local localPlayer = game.Players.LocalPlayer
local game2 = script.Parent.Parent.Game
local TradeModule = require(game.ReplicatedStorage.Modules.TradeModule)
local LevelModule = require(game.ReplicatedStorage.Modules.LevelModule)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local trade = ReplicatedStorage2:WaitForChild("Trade")
local success, result = pcall(function()
	return PolicyService:GetPolicyInfoForPlayerAsync(localPlayer)
end)
local v = LevelModule.GetLevel(ProfileData.NewXP) >= 10 or ProfileData.Prestige > 0

if success then
	if not result.IsPaidItemTradingAllowed then
		game2.Leaderboard.Inspect.Trade.Visible = false
		TradeModule.RequestsEnabled = false
		return "Trading Not Allowed"
	end
else
	warn("PolicyService error: " .. result)
end

if not v then
	game2.Leaderboard.Inspect.Trade.Visible = false
	TradeModule.RequestsEnabled = false
end

local leaderboard = game2.Leaderboard
local _ = leaderboard.Inspect
local tradeRequest = leaderboard.Container.TradeRequest
local tradeGUI = game.Players.LocalPlayer.PlayerGui.TradeGUI
TradeModule.GUI.RequestFrame = tradeRequest
TradeModule.GUI.TradeGUI = game.Players.LocalPlayer.PlayerGui.TradeGUI
TradeModule.GUI.Actions = tradeGUI.Container.Trade.Actions
TradeModule.GUI.YourOffer = tradeGUI.Container.Trade.YourOffer
TradeModule.GUI.TheirOffer = tradeGUI.Container.Trade.TheirOffer
local v2, v3 = game.ReplicatedStorage.Trade.GetTradeStatus:InvokeServer()
TradeModule.UpdateTradeRequestWindow(v2, v3)
TradeModule.ConnectRequestWindow()
TradeModule.ConnectActions()
TradeModule.ConnectTabButtons()
local toggleRequests = game2.Leaderboard.Container.ToggleRequests
toggleRequests.On.Visible = TradeModule.RequestsEnabled
toggleRequests.Off.Visible = not TradeModule.RequestsEnabled
toggleRequests.On.Activated:Connect(function()
	toggleRequests.On.Visible = false
	toggleRequests.Off.Visible = true
	TradeModule.RequestsEnabled = false
	game.ReplicatedStorage.Trade.DeclineRequest:FireServer()
	trade.SetRequestsEnabled:FireServer(false)
	tradeRequest.Visible = false
end)
toggleRequests.Off.Activated:Connect(function()
	toggleRequests.On.Visible = true
	toggleRequests.Off.Visible = false
	trade.SetRequestsEnabled:FireServer(true)
	TradeModule.RequestsEnabled = true
end)
tradeGUI.Changed:Connect(function()
	tradeGUI.ClickBlocker.Visible = tradeGUI.Enabled
end)
local localPlayer2 = game.Players.LocalPlayer
localPlayer2.Changed:connect(function()
	tradeGUI.Container.Visible = localPlayer2:GetAttribute("PerformingTrade") ~= true
	tradeGUI.Processing.Visible = localPlayer2:GetAttribute("PerformingTrade") == true
end)