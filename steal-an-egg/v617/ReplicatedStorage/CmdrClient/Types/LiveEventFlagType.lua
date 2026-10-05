local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LiveEventFlags = require(ReplicatedStorage.Shared.Flags.LiveEventFlags)
local v = {
	"set",
	"schedule",
	"reset",
	"status"
}
return function(registry)
	registry:RegisterType(
		"liveEventFlagName",
		registry.Cmdr.Util.MakeEnumType("LiveEventFlagName", table.clone(LiveEventFlags.Names))
	)
	registry:RegisterType("liveEventFlagAction", registry.Cmdr.Util.MakeEnumType("LiveEventFlagAction", v))
end