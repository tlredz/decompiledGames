local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SilkThread = {
	FormulateTextPlusText = function(p: number)
		return (`{Utility.addCommasToNumber(p)} [#]<img={86755077727133}>`)
	end,
	FormulateRichText = function(p: number)
		return (`<font color="rgb(223,230,204)">{Utility.addCommasToNumber(p)} Silk Thread</font>`)
	end,
	GetContent = function(price: number)
		return {
			Icon = "rbxassetid://86755077727133",
			Price = price
		}
	end,
	CanBuy = function(p, p2: number)
		local heldItem = Utility.HeldItem(p, "Silk Thread")

		if heldItem == nil then
			return false
		end

		local amount = heldItem:FindFirstChild("Amount")
		return p2 <= (amount == nil and 1 or amount.Value or 1)
	end
}
local v = nil

function SilkThread.Buy(_, p: number, p2, _: string?)
	if p2 == nil then
		return
	end

	local Item = v

	if not Item then
		local ServerStorage = game:GetService("ServerStorage")
		Item = require(ServerStorage.SAM.Services.Removers.Item)
	end

	v = Item
	v(p2, "Silk Thread", p, nil, "ShopPurchase")
end

return SilkThread