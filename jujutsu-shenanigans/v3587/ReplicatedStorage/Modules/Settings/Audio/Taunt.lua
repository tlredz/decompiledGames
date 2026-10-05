return {
	Btn = 3,
	SortOrder = 5,
	Val = "VolTA",
	Desc = "Change the volume for taunts",
	Max = 2,
	Callback = function(volume)
		game.SoundService.Taunt.Volume = volume
	end
}