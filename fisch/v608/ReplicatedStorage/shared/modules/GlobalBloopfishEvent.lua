return {
	["Sea 1"] = {
		FishName = "Bloop Fish",
		StockFFlag = "BloopFishStock",
		DefaultStock = game.GameId == 6756890519 and 50 or 1000,
		GlobalMetterIndex = "BloopfishCaught",
		ZoneName = "Bloop Fish",
		DisplayPoolText = "The Bloopfish Pool",
		IdleAnimation = 110153743236118,
		ExitAnimation = 113084860143691,
		EnterAnimation = 84986185075863,
		Messages = {
			StartChat = "A <font color=\"#FF0000\"><b>Bloop Fish</b></font> has been spotted near <font color=\"#FF0000\"><b>Moosewood</b></font>!",
			Start = {
				TitleWithIsland = "A <font color=\"#FF0000\">Bloop Fish</font> has been spotted near <font color=\"#FF0000\">Moosewood</font>!",
				Description = "[Catch rare fish while they're still around!]"
			},
			StopChat = "The <font color=\"#FF0000\"><b>Bloop Fish</b></font> got away..."
		}
	}
}