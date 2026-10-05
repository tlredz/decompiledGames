local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Item = require(ReplicatedStorage.Modules.Shared.Item.Item)
return {
	Inherits = { Item },
	Cast = function(p)
		return p
	end
}