local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local OuwigaharaToken = require(ReplicatedStorage.Items.Materials["Ouwigahara Token"])
local icon = OuwigaharaToken.Icon
local v = tonumber(string.match(icon, "%d+"))
local OuwigaharaToken2 = {
	AccountBalance = true,
	FormulateTextPlusText = function(p: number)
		return (`{Utility.addCommasToNumber(p)} [#]<img={v}>`)
	end,
	FormulateRichText = function(p: number)
		return (`<font color="rgb(255,217,77)">{Utility.addCommasToNumber(p)} Ouwigahara Tokens</font>`)
	end,
	GetContent = function(price: number)
		return {
			Icon = icon,
			Price = price
		}
	end,
	CanBuy = function(p, p2: number)
		local heldItem = Utility.HeldItem(p, "Ouwigahara Token")

		if heldItem == nil then
			return false
		end

		local amount = heldItem:FindFirstChild("Amount")
		return p2 <= (amount == nil and 1 or amount.Value or 1)
	end
}
local v2 = nil

function OuwigaharaToken2.Buy(_, p: number, p2, _: string?)
	if p2 == nil then
		return
	end

	local Item = v2

	if not Item then
		local ServerStorage = game:GetService("ServerStorage")
		Item = require(ServerStorage.SAM.Services.Removers.Item)
	end

	v2 = Item
	v2(p2, "Ouwigahara Token", p, nil, "ShopPurchase")
end

return OuwigaharaToken2