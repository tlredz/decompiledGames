require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "Alchemist",
	Get = function(_)
		return {
			Text = { "Hello." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "1")

						if v == -2 then
							return {
								Text = { "Thanks for the money." }
							}
						elseif v == -1 then
							Util.playAction("Negative")
							return {
								Text = { "You're still lacking <Color=Green>$500,000<Color=/> money." }
							}
						elseif v == 0 then
							Util.playAction("Explain")
							return {
								Text = {
									"It appears you haven't unlocked your maximum potential yet.",
									"If you're seeking more power, I need you to bring me 3 different flowers spread across the entire map."
								},
								Option1 = {
									Label = "I'll do it.",
									Text = { "" },
									JumpTo = function()
										return {
											Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
													"Alchemist",
													"2"
												)) }
										}
									end
								}
							}
						elseif v == 1 then
							return {
								Text = { "Have you found them yet? Come back when you have the 3 flowers." }
							}
						elseif v == 2 then
							Util.playAction("Explain")
							return {
								Text = { "Good job. Now I can make the potion, but it's not going to be free! Pay me <Color=Green>$500,000<Color=/> to proceed." },
								Option1 = {
									Label = "Pay",
									Text = { "" },
									JumpTo = function()
										return {
											Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
													"Alchemist",
													"3"
												)) }
										}
									end
								}
							}
						elseif v == 5 then
							Util.playAction("Negative")
							return {
								Text = { "What are you?" }
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "I don't think you're ready yet." }
						}
					end)())
				end
			}
		}
	end
}