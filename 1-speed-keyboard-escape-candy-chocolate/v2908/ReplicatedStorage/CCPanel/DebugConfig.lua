local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaceRegistry = require(ReplicatedStorage.Config.PlaceRegistry)
local v = {
	Test = false,
	Sano = true
}
return {
	isEnabled = function()
		local groupName = PlaceRegistry.getGroupName()
		return groupName ~= nil and v[groupName] == true
	end
}