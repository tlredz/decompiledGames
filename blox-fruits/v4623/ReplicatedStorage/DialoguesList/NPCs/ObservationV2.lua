require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "Hungry Man",
	Get = function(_)
		return {
			Text = { "Hey." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk2", "Start")
						local v2 = {
							Text = { "Would you like to purchase Instinct V2 for <Color=Green>$5,000,000<Color=/>? This upgrade allows you to see the level and hotbar of your opponents, upgrades your dodges cooldown, lessens the blur on your screen, predicts attacks and enables faster dashing towards players in combat." },
							Option1 = {
								Label = "Learn",
								JumpTo = function()
									if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk2", "Buy") == 0 then
										Util.playAction("Positive")
										return {
											Text = { "[Instinct upgraded.]" }
										}
									end

									Util.playAction("Negative")
									return {
										Text = { "[Not enough money.]" }
									}
								end
							}
						}

						if v == 0 then
							Util.playAction("Positive")
							return {
								Text = { "Congratulations, you already know Instinct V2." }
							}
						elseif v == 2 then
							Util.playAction("Explain")
							return {
								Text = { "Hey, if you bring me a decent meal I can teach you something." }
							}
						elseif v == 4 then
							return {
								Text = { "Delicious!" },
								Option1 = {
									Label = "No problem",
									Text = {
										"Thank you so much, young one. I'd like to reward you, by teaching you something I learned a few decades ago, when I was still a pirate.",
										"Would you like to learn more about it?"
									},
									Option1 = {
										Label = "Yeah",
										JumpTo = function()
											return v2
										end
									}
								}
							}
						elseif v == 5 then
							Util.playAction("Negative")
							return {
								Text = { "Not enough, I need more food!" },
								Option1 = {
									Label = "Sorry",
									Text = { "Bring me more food!" }
								}
							}
						elseif v == 6 then
							Util.playAction("Explain")
							return {
								Text = { "Nice, you found 3 fruits, but I'm a picky person. I want to eat this in a bowl, can you do that for me?" }
							}
						elseif v == 1 then
							return v2
						end

						Util.playAction("Negative")
						return {
							Text = { "Go away, weakling." }
						}
					end)())
				end
			}
		}
	end
}