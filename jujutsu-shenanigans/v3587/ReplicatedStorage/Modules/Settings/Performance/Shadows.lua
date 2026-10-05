return {
	Btn = 1,
	SortOrder = 2,
	Val = "Shadows",
	Desc = "Render shadows globally",
	Callback = function(globalShadows)
		game.Lighting.GlobalShadows = globalShadows
	end
}