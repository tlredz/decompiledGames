return {
	Btn = 3,
	SortOrder = 3,
	Val = "VolMS2",
	Desc = "Change the volume for background music",
	Max = 2,
	Callback = function(volume)
		game.SoundService.Music2.Volume = volume
	end
}