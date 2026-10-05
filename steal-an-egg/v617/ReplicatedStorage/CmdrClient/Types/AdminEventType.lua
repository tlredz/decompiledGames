game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local v = {
	"RecoveryEvent",
	"DemonicEvent",
	"Countdown",
	"DragonEggEvent",
	"CaptureTheEgg",
	"GreatBloom",
	"AdminAbuse",
	"MonsterEvent",
	"RiftEvent",
	"RiftOpen",
	"LightVsDarkness",
	"SammyEvent",
	"ScrambleBoss",
	"BeanstalkEvent"
}
local v2 = {}

for _, v3 in v do
	if v3 ~= "CaptureTheEgg" then
		table.insert(v2, v3)
	end
end

return function(registry)
	registry:RegisterType("adminEventType", registry.Cmdr.Util.MakeEnumType("AdminEventType", v))
	registry:RegisterType("adminStartEventType", registry.Cmdr.Util.MakeEnumType("AdminStartEventType", v2))
end