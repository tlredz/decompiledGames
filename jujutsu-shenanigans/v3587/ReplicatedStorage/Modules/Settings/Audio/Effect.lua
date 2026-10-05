return {
	Btn = 3,
	SortOrder = 1,
	Val = "VolFX",
	Desc = "Change the volume for sound effects",
	Max = 2,
	Callback = function(volume)
		game.SoundService.Effect.Volume = volume
	end
}