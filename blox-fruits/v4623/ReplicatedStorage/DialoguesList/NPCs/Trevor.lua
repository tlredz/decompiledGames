require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "Trevor",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TalkTrevor", "1")

						if not v then
							Util.playAction("Negative")
							return {
								Text = { "Get out of here before I kill you." }
							}
						end

						if v == 0 then
							return {
								Text = { "That was a nice fruit." }
							}
						elseif v == 1 then
							Util.playAction("Explain")
							return {
								Text = { "Where is it? Bring me an expensive Blox Fruit!" }
							}
						elseif v == 2 then
							return {
								Text = { "I see. Let me take a closer look." },
								Option1 = {
									Label = "Give",
									Text = { "" },
									JumpTo = function()
										return {
											Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
													"TalkTrevor",
													"3"
												)) }
										}
									end
								}
							}
						end

						return {
							Text = { "You seem strong. Are you here to join our organization?" },
							Option1 = {
								Label = "Sure...",
								Text = { "Bring me an expensive Blox Fruit to prove yourself worthy of speaking to Swan." },
								Option1 = {
									Label = "Alright",
									Text = { "" },
									JumpTo = function()
										game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TalkTrevor", "2")
										return {
											Text = { "Don't disappoint me." }
										}
									end
								}
							}
						}
					end)())
				end
			}
		}
	end
}