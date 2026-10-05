local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.MarketplaceService)
local v2 = require3(ReplicatedStorage2.Shared.CNYEvent.CNYEventItemData)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local singlePass = Players.LocalPlayer.PlayerGui:WaitForChild("SinglePass")
local turkeyCoins = singlePass.MainFrame.Main.Pages.TurkeyCoins
return {
	Start = function(_)
		singlePass.MainFrame.Main.SideBtns.Currency.Add.Activated:Connect(function()
			turkeyCoins.Visible = true
		end)
		turkeyCoins.Close.Activated:Connect(function()
			turkeyCoins.Visible = false
		end)
		local v5 = {}

		for k, lanternProduct in v2.LanternProducts do
			table.insert(v5, {
				ProductId = k,
				Value = lanternProduct.Value
			})
		end

		table.sort(v5, function(a, b)
			return a.Value < b.Value
		end)
		local count = 0

		for _, v6 in v5 do
			count += 1
			local turkeyCoin = turkeyCoins[tostring(count)]
			turkeyCoin.Amount.Text = v3.ValueConvertor:AddCommas(v6.Value)
			local v8 = turkeyCoin
			v:GetProductInfoAsync(v6.ProductId, Enum.InfoType.Product):andThen(function(p)
				turkeyCoin.Buy.Cost.Text = ` {v3.ValueConvertor:AddCommas(p.PriceInRobux)}`
			end):catch(function()
				v8.Buy.Cost.Text = "???"
			end)
			local v9 = v6
			turkeyCoin.Buy.Activated:Connect(function()
				v4:PromptPurchase(v9.ProductId, Enum.InfoType.Product)
			end)
		end
	end
}