local parent = script.Parent.Parent
local lobby = script.Parent.Parent.Lobby
local _ = lobby.Screens
local _ = parent.Game
local tradeRequest = lobby.Leaderboard.Container.OverlayMenu.TradeRequest
local leaderBar = lobby.LeaderBar
local gameBar = lobby.GameBar
local tradeGUI_Phone = game.Players.LocalPlayer.PlayerGui.TradeGUI_Phone
local tradeModule = game.ReplicatedStorage.Modules.TradeModule
local module = require(tradeModule)
module.GUI.RequestFrame = tradeRequest
module.GUI.TradeGUI = tradeGUI_Phone
module.GUI.Actions = tradeGUI_Phone.Container.Trade.Actions
module.GUI.YourOffer = tradeGUI_Phone.Container.Trade.YourOffer
module.GUI.TheirOffer = tradeGUI_Phone.Container.Trade.TheirOffer
module.GUI.ItemLayout = tradeModule.TradeGridLayout

function _G.NewTradeRequest(visible)
	leaderBar.Main.Plus.TradeRequest.Visible = visible
	gameBar.Main.Plus.TradeRequest.Visible = visible
end

local v, v2 = game.ReplicatedStorage.Trade.GetTradeStatus:InvokeServer()
module.UpdateTradeRequestWindow(v, v2)
module.ConnectRequestWindow()
module.ConnectActions()
module.ConnectTabButtons()
tradeGUI_Phone.Changed:connect(function()
	tradeGUI_Phone.ClickBlocker.Visible = tradeGUI_Phone.Enabled
end)
local localPlayer = game.Players.LocalPlayer
localPlayer.Changed:connect(function()
	tradeGUI_Phone.Container.Processing.Visible = localPlayer:GetAttribute("PerformingTrade") == true
end)