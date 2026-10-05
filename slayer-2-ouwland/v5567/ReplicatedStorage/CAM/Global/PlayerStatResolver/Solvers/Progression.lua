local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerProgression = require(ReplicatedStorage.CAM.Global.PlayerProgression)
return function(p, p2: string)
	return PlayerProgression.GetStatTotal(p, p2)
end