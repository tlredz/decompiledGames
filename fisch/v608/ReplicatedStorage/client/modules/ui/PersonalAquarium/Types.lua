local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
require(packages.Signal)
require(packages.State)
local legacyControllers = ReplicatedStorage.client.legacyControllers
require(legacyControllers.PersonalAquariumController)
return nil