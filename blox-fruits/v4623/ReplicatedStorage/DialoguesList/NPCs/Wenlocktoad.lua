require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "arowe",
	Get = function(_)
		return {
			Text = { "Greetings." },
			Option1 = {
				Label = "Sir?",
				JumpTo = function()
					return ((function()
						local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1")

						if v == -2 then
							return {
								Text = { "Friend." }
							}
						elseif v == -1 then
							Util.playAction("Negative")
							return {
								Text = { "You're still lacking <Color=Green>$2,000,000<Color=/> money." }
							}
						elseif v == 0 then
							return {
								Text = { "Let's begin." },
								Option1 = {
									Label = "What?",
									Text = { "I am arowe, a son of rip_indra. I train those less fortunate than I to channel their hidden strengths." },
									Option1 = {
										Label = "Hidden strengths?",
										Text = { "Yes, child. I know this must be confusing for you, but I have been sent here by the God's to teach those who seek my wisdom in order to make their race abilities stronger." },
										Option1 = {
											Label = "I'm interested",
											Text = { "" },
											JumpTo = function()
												return {
													Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
															"Wenlocktoad",
															"2"
														)) }
												}
											end
										}
									}
								}
							}
						elseif v == 1 then
							return {
								Text = { game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "info") }
							}
						elseif v == 2 then
							Util.playAction("Explain")
							return {
								Text = { "Well done. I, like many gods before me, have used this gift of mine to teach others. Of course though... I charge a cheap price for my craft. <Color=Green>$2,000,000<Color=/> should do it." },
								Option1 = {
									Label = "Pay",
									Text = { "" },
									JumpTo = function()
										return {
											Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
													"Wenlocktoad",
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
							Text = { "Come back when you're prepared enough." }
						}
					end)())
				end
			}
		}
	end
}