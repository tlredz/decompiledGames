local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local RefinementOre = {
	FormulateTextPlusText = function(p: number)
		return (`{Utility.addCommasToNumber(p)} [#]<img={138070983705140}>`)
	end,
	FormulateRichText = function(p: number)
		return (`<font color="rgb(79,185,255)">{Utility.addCommasToNumber(p)} Refinement Ore</font>`)
	end,
	GetContent = function(price: number)
		return {
			Icon = "rbxassetid://138070983705140",
			Price = price
		}
	end,
	CanBuy = function(p, p2: number)
		local heldItem = Utility.HeldItem(p, "Refinement Ore")

		if heldItem == nil then
			return false
		end

		local amount = heldItem:FindFirstChild("Amount")
		return p2 <= (amount == nil and 1 or amount.Value or 1)
	end
}
local v = nil

function RefinementOre.Buy(_, p: number, p2, _: string?)
	if p2 == nil then
		return
	end

	local Item = v

	if not Item then
		local ServerStorage = game:GetService("ServerStorage")
		Item = require(ServerStorage.SAM.Services.Removers.Item)
	end

	v = Item
	v(p2, "Refinement Ore", p, nil, "ShopPurchase")
end

return RefinementOre