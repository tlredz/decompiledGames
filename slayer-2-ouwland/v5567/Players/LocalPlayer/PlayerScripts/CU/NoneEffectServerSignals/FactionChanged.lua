local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FactionState = require(ReplicatedStorage.CAM.Client.Modules.FactionState)
return function(p)
	local apply = FactionState.Apply

	if type(p) ~= "table" then
		p = nil
	end

	apply(p)
end