return {
	["Sea 1"] = {
		FishName = "Mosslurker",
		StockFFlag = "MosslurkerStock",
		DefaultStock = game.GameId == 6756890519 and 50 or 300,
		GlobalMetterIndex = "MosslurkerCautch",
		ZoneName = "Mosslurker",
		DisplayPoolText = "Mosslurker Pool",
		IdleAnimation = 109671254205033,
		Messages = {
			StartChat = {
				MessageWithIsland = "A <font color=\"#FF0000\"><b>Mosslurker</b></font> has been spotted near <font color=\"#FF0000\"><b>%targetIsland</b></font>!",
				MessageWithoutIsland = "A <font color=\"#FF0000\"><b>Mosslurker</b></font> has appeared somewhere in the <font color=\"#FF0000\"><b>ocean</b></font>!"
			},
			Start = {
				TitleWithIsland = "A <font color=\"#FF0000\">Mosslurker</font> has been spotted near <font color=\"#FF0000\">%targetIsland</font>!",
				TitleWithoutIsland = "A <font color=\"#FF0000\">Mosslurker</font> has appeared somewhere in the <font color=\"#FF0000\">ocean</font>!",
				Description = "[Catch rare fish while they're still around!]"
			},
			StopChat = "The <font color=\"#FF0000\"><b>Mosslurker</b></font> got away..."
		}
	},
	["Sea 2"] = {
		FishName = "Apex Leviathan",
		StockFFlag = "ApexLeviathanStock",
		DefaultStock = game.GameId == 6756890519 and 50 or 300,
		GlobalMetterIndex = "ApexLeaviathanCautch",
		ZoneName = "Apex Leviathan",
		DisplayPoolText = "Apex Leviathan Pool",
		IdleAnimation = 126643295509145,
		Messages = {
			StartChat = {
				MessageWithIsland = "An <font color=\"#FF0000\"><b>Apex Leviathan</b></font> has been spotted near <font color=\"#FF0000\"><b>%targetIsland</b></font>!",
				MessageWithoutIsland = "An <font color=\"#FF0000\"><b>Apex Leviathan</b></font> has appeared somewhere in the <font color=\"#FF0000\"><b>ocean</b></font>!"
			},
			Start = {
				TitleWithIsland = "An <font color=\"#FF0000\">Apex Leviathan</font> has been spotted near <font color=\"#FF0000\">%targetIsland</font>!",
				TitleWithoutIsland = "An <font color=\"#FF0000\">Apex Leviathan</font> has appeared somewhere in the <font color=\"#FF0000\">ocean</font>!",
				Description = "[Catch rare fish while they're still around!]"
			},
			StopChat = "The <font color=\"#FF0000\"><b>Apex Leviathan</b></font> got away..."
		}
	}
}