return {
	Btn = 3,
	SortOrder = 2,
	Val = "VolMS",
	Desc = "Change the volume for music",
	Max = 2,
	Callback = function(volume)
		game.SoundService.Music.Volume = volume
	end
}