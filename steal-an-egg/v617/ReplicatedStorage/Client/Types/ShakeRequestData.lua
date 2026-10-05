local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
return {
	SchemaValidation = t.interface({
		FadeInTime = t.optional(t.number),
		FadeOutTime = t.optional(t.number),
		Magnitude = t.number,
		PosInfluence = t.optional(t.Vector3),
		RotInfluence = t.optional(t.Vector3),
		Roughness = t.number
	})
}