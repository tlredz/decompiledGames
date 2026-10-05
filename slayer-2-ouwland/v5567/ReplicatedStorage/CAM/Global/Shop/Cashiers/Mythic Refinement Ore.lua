local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MythicRefinementOre = {
	FormulateTextPlusText = function(p: number)
		return (`{Utility.addCommasToNumber(p)} [#]<img={133978680725240}>`)
	end,
	FormulateRichText = function(p: number)
		return (`<font color="rgb(161,0,0)">{Utility.addCommasToNumber(p)} Mythic Refinement Ore</font>`)
	end,
	GetContent = function(price: number)
		return {
			Icon = "rbxassetid://133978680725240",
			Price = price
		}
	end,
	CanBuy = function(p, p2: number)
		local heldItem = Utility.HeldItem(p, "Mythic Refinement Ore")

		if heldItem == nil then
			return false
		end

		local amount = heldItem:FindFirstChild("Amount")
		return p2 <= (amount == nil and 1 or amount.Value or 1)
	end
}
local v = nil

function MythicRefinementOre.Buy(_, p: number, p2, _: string?)
	if p2 == nil then
		return
	end

	local Item = v

	if not Item then
		local ServerStorage = game:GetService("ServerStorage")
		Item = require(ServerStorage.SAM.Services.Removers.Item)
	end

	v = Item
	v(p2, "Mythic Refinement Ore", p, nil, "ShopPurchase")
end

return MythicRefinementOre