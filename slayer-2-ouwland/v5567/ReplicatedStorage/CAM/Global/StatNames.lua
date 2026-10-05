local StatNames = {
	Transcribe = {
		BiteSpeedMultiplier = "Bite Speed Multiplier",
		CastRadius = "Cast Radius",
		CatchChance = "Catch Chance",
		CatchTier = "Catch Tier",
		FishLuck = "Fish Luck"
	}
}

function StatNames.Get(p: string)
	return StatNames.Transcribe[p] or p
end

return StatNames