local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InteractableItem = require(ReplicatedStorage.Modules.Shared.Item.InteractableItem)
return {
	Inherits = { InteractableItem },
	Cast = function(p)
		return p
	end
}