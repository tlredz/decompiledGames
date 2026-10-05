local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local MerchantData = require(ReplicatedStorage.Datas.MerchantData)
local stockKeys = {}

for _, brainrot in MerchantData.Brainrots do
	table.insert(stockKeys, brainrot.StockKey)
end

return Conch.register_type("Stock Key", Conch.args.enum_new(stockKeys))