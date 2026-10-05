local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
return {
	Inherits = { MenuItem },
	Cast = function(p)
		return p
	end
}