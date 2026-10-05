local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local interface = t.interface({
	EggUid = t.string,
	Message = t.string,
	RarityId = t.string,
	SoundId = t.optional(t.number)
})
local array = t.array(interface)
return {
	SchemaValidation = {
		RareSpawnPresentation = interface,
		RareSpawnPresentations = array,
		SequencePayload = t.strictInterface({
			DayStartsAt = t.number
		}),
		RevealPayload = t.strictInterface({
			PeriodIndex = t.number,
			DayStartsAt = t.number,
			RareSpawns = array
		})
	}
}