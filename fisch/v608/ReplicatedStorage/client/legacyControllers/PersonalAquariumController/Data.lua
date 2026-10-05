local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sharedPersonalAquarium = ReplicatedStorage.shared.modules.SharedPersonalAquarium
require(sharedPersonalAquarium.SharedTypes)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
return {
	Hitch = function(callback)
		return DataController.PlayerDataReplicator:Observe({ "PersonalAquarium" }, callback)
	end
}