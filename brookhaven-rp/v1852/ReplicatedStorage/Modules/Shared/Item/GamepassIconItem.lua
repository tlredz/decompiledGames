local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
require(ReplicatedStorage.Modules.Shared.PlayerData.Purchasable)
return {
	Inherits = { MenuItem },
	Cast = function(p)
		return p
	end
}