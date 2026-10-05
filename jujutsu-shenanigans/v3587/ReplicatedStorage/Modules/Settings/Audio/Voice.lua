return {
	Btn = 3,
	SortOrder = 4,
	Val = "VolVA",
	Desc = "Change the volume for sound effects",
	Max = 2,
	Callback = function(volume)
		game.SoundService.Voice.Volume = volume
	end
}