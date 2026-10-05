local ReplicatedStorage = game:GetService("ReplicatedStorage")
local state = require(ReplicatedStorage.client.ui.state)
local Cinematic = {
	enabled = false,
	init = function() end
}

function Cinematic.set(enabled: boolean)
	state.cinematic(enabled)
	Cinematic.enabled = enabled
end

return Cinematic