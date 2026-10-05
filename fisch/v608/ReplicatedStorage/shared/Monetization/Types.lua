local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local _ = shared.modules
require(shared.RewardInfo)
require(packages.Signal)
require(packages.PromiseTypes)
require(ReplicatedStorage.shared.modules.OfficialCommerceProducts)
return nil