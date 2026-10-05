local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local TacoMerchantData = require(ReplicatedStorage.Datas.TacoMerchantData)
local brainrots = table.create(#TacoMerchantData.Brainrots)

for _, brainrot in TacoMerchantData.Brainrots do
	table.insert(brainrots, brainrot.Brainrot)
end

return Conch.register_type("Taco Merchant Brainrot", Conch.args.enum_new(brainrots))