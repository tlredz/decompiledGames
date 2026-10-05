local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local GoldenFish = {
	FormulateTextPlusText = function(p: number)
		return (`{Utility.addCommasToNumber(p)} [Golden Fish]<Color=(0.309804, 0.72549, 1)>`)
	end,
	FormulateRichText = function(p: number)
		return (`<font color="rgb(79,185,255)">{Utility.addCommasToNumber(p)} Golden Fish</font>`)
	end,
	GetContent = function(price: number)
		return {
			Icon = "rbxassetid://74401178915187",
			Price = price
		}
	end,
	CanBuy = function(p, p2: number)
		local heldItem = Utility.HeldItem(p, "Golden Fish")

		if heldItem == nil then
			return false
		end

		local amount = heldItem:FindFirstChild("Amount")
		return p2 <= (amount == nil and 1 or amount.Value or 1)
	end
}
local v = nil

function GoldenFish.Buy(_, p: number, p2, _: string?)
	if p2 == nil then
		return
	end

	local Item = v

	if not Item then
		local ServerStorage = game:GetService("ServerStorage")
		Item = require(ServerStorage.SAM.Services.Removers.Item)
	end

	v = Item
	v(p2, "Golden Fish", p, nil, "ShopPurchase")
end

return GoldenFish