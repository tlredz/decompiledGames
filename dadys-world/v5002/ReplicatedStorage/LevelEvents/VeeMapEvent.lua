game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("CollectionService")
local VeeMapEvent = {}
VeeMapEvent.properties = {
	HasDialogueTriggers = true,
	RequiresVeeCharacter = true,
	TriggerDuration = 45
}

function VeeMapEvent.onRoomLoad(_, _) end

function VeeMapEvent.setupBehaviors(_, _) end

return VeeMapEvent