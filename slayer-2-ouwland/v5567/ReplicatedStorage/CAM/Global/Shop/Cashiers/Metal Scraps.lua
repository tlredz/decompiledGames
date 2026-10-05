local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MetalScraps = {
	FormulateTextPlusText = function(p: number)
		return (`{Utility.addCommasToNumber(p)} [#]<img={129731726532959}>`)
	end,
	FormulateRichText = function(p: number)
		return (`<font color="rgb(223,230,204)">{Utility.addCommasToNumber(p)} Metal Scraps</font>`)
	end,
	GetContent = function(price: number)
		return {
			Icon = "rbxassetid://129731726532959",
			Price = price
		}
	end,
	CanBuy = function(p, p2: number)
		local heldItem = Utility.HeldItem(p, "Metal Scraps")

		if heldItem == nil then
			return false
		end

		local amount = heldItem:FindFirstChild("Amount")
		return p2 <= (amount == nil and 1 or amount.Value or 1)
	end
}
local v = nil

function MetalScraps.Buy(_, p: number, p2, _: string?)
	if p2 == nil then
		return
	end

	local Item = v

	if not Item then
		local ServerStorage = game:GetService("ServerStorage")
		Item = require(ServerStorage.SAM.Services.Removers.Item)
	end

	v = Item
	v(p2, "Metal Scraps", p, nil, "ShopPurchase")
end

return MetalScraps