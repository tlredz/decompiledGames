local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
require3(ReplicatedStorage2.Shared.Battlepass.BattlepassCurrencyShopData)
require3(ReplicatedStorage2.Controllers.GiftingController)
require3(ReplicatedStorage2.Common.MarketplaceService)
require3(ReplicatedStorage2.Shared.BattlepassUIType)
require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
require3(ReplicatedStorage2.Shared.Policy)
local playerGui = Players.LocalPlayer.PlayerGui
local battlepassCurrencyShop = playerGui:WaitForChild("BattlepassCurrencyShop")
playerGui:WaitForChild("Battlepass")
require3(script.Parent.BattlepassViewController)
return {
	Start = function(_)
		v:OnGuiOpen(battlepassCurrencyShop.Name, function()
			v:Close(battlepassCurrencyShop.Name)
		end)
	end
}