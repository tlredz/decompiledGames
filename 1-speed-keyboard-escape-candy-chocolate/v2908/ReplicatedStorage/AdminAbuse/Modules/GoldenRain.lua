local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartyEvent = require(script.Parent.Parent.PartyEvent)
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local goldenRain = EventsConfig.GoldenRain
return PartyEvent.new({
	DisplayName = goldenRain.DisplayName,
	MaxDurationSeconds = goldenRain.MaxDurationSeconds,
	DefaultDurationSeconds = goldenRain.DefaultDurationSeconds,
	NeedsDuration = goldenRain.NeedsDuration,
	RequiresRespawnRefire = true,
	SkipDoorTransition = goldenRain.SkipDoorTransition,
	IsAdminAbuse = goldenRain.IsAdminAbuse,
	Sounds = goldenRain.Sounds
})