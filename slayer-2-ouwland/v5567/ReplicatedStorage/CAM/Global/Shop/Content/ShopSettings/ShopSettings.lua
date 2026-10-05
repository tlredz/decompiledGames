local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local shopSettings = require(ReplicatedStorage.CAM.Global.shopSettings)
local ShopSettings = {}

for _, shopSetting in shopSettings do
	if typeof(shopSetting) ~= "table" then
		continue
	end

	for _, v in shopSetting do
		if typeof(v) == "table" and v.Name ~= nil and v.ProductId ~= nil then
			ShopSettings[v.Name] = {
				Type = Menum.ShopItemType.Product,
				Price = {
					Product = v.ProductId
				},
				AllowOre = v.RobuxOnly ~= true,
				Reward = v.Reward,
				RewardAmount = v.RewardAmount,
				ListedPrice = v.ListedPrice,
				RequiresVIP = v.RequiresVIP,
				RequiresGamepass = v.RequiresGamepass,
				AskFirst = v.AskFirst
			}
		end
	end
end

return ShopSettings