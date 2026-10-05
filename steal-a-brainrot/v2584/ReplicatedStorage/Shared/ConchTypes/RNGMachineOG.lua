local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local RNGMachineLimitedStockData = require(ReplicatedStorage.Datas.RNGMachineLimitedStockData)
return Conch.register_type("RNG Machine OG", Conch.args.enum_new(RNGMachineLimitedStockData.Brainrots))