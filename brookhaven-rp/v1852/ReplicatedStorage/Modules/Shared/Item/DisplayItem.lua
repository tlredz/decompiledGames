local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local Item = require(ReplicatedStorage.Modules.Shared.Item.Item)
return {
	Inherits = { Item },
	Cast = function(p)
		return p
	end
}