local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local Tools = {
	SlapControllerProfile = t.interface({
		Duration = t.number,
		Force = t.number,
		BrainrotDamage = t.number,
		MaxBrainrotTargets = t.optional(t.number)
	})
}
Tools.SlapControllerData = t.interface({
	Player = Tools.SlapControllerProfile,
	Brainrot = Tools.SlapControllerProfile,
	PlayerCooldown = t.optional(t.number),
	MobCooldown = t.optional(t.number)
})
return Tools