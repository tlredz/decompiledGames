local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SequenceTeleport = require(ReplicatedStorage.CAM.Client.Modules.SequenceTeleport)
return function(p)
	if p == nil or typeof(p.Destination) ~= "CFrame" then
		return
	end

	SequenceTeleport.Start({
		FallLength = 1,
		TeleportAtFall = 0.5,
		RiseLength = 1,
		Destination = p.Destination
	})
end