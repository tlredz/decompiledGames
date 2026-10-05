game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local _ = {
	Finn = {
		character = "Finn",
		dialogue = "…I really do miss when these tanks were filled with critters."
	},
	Shrimpo = {
		character = "Shrimpo",
		dialogue = "I HATE THIS PLACE!! NOT ENOUGH PICTURES OF ME!!!"
	}
}
local AquariumMapEvent = {}
AquariumMapEvent.properties = {
	HasDialogueTriggers = true,
	UsesStoryKey = true,
	DefaultTriggerDuration = 3
}

function AquariumMapEvent.onRoomLoad(_, _) end

function AquariumMapEvent.setupBehaviors(_, _) end

return AquariumMapEvent