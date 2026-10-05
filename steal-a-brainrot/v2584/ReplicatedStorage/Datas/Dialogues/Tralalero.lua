game:GetService("ReplicatedStorage")
return {
	Dialogs = {
		{
			Text = "TRA-LA-LA! You smell that? That’s the smell of gold melting into chaos!",
			Sound = "Sounds.Others.Tralala",
			Duration = 3,
			Answers = {
				{
					Text = "What are you doing here?",
					Next = 2
				},
				{
					Text = "How does this machine work?",
					Next = 4
				},
				{
					Text = "Nevermind",
					Next = 5
				}
			}
		},
		{
			Text = "I found this magical hunk of junk while chilling at the bottom of the ocean.",
			Duration = 3,
			Next = 3,
			Wait = 3
		},
		{
			Text = "No idea how it works and i don’t care all i know you feed it stolen <font color=\"#FFDE59\">golden</font> brainrots and it shoots a rainbow in the sky.",
			Duration = 4,
			Wait = 5
		},
		{
			Text = "Steal golden brainrots from random players and bring them back to me so we can power this thing up!",
			Duration = 4,
			Wait = 3
		},
		{
			Text = "Fine.",
			Duration = 0.2,
			Wait = 2
		}
	}
}