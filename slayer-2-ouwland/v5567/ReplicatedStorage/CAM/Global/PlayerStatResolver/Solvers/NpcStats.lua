local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
return function(instance, p: string)
	local attribute = instance:GetAttribute(StatTypes.StatToAttribute(p))

	if typeof(attribute) == "number" then
		return attribute
	end

	return attribute == true or 0
end