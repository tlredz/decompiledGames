local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
require(packages.Signal)
require(packages.State)
local sharedPersonalAquarium = ReplicatedStorage.shared.modules.SharedPersonalAquarium
require(sharedPersonalAquarium.SharedTypes)
return nil