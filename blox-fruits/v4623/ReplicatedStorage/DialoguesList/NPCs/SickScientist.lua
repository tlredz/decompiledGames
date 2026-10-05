require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "Sick Scientist",
	Get = function(_)
		return {
			Text = { "Hey..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local function call(p: string)
							return {
								Text = { "Would you like to purchase a <Phoenix> Special Microchip for <Color=Purple>ƒ1,000<Color=/>? You can only do this every 2 hours." },
								Option1 = {
									Label = "Buy",
									JumpTo = function()
										local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"RaidsNpc",
											"Select",
											p
										)

										if v == 1 then
											Util.playAction("Positive")
											return {
												Text = { "Thank you. You also purchase these microchips from the head scientist." }
											}
										elseif v == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[You must be Level 1100 to do this.]" }
											}
										end

										if typeof(v) == "string" then
											return {
												Text = { v }
											}
										end

										return {
											Text = { "..." }
										}
									end
								}
							}
						end

						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SickScientist", "Check") then
							return {
								Text = { "I was wounded badly fighting off pirates on this island... please help me." },
								Option1 = {
									Label = "Attempt to heal",
									JumpTo = function()
										local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"SickScientist",
											"Heal"
										)

										if v == 1 then
											return {
												Text = { "<Color=Green>Thank you, I'm healed!<Color=/> Did you know I'm a good scientist? Perhaps I can help you further evolve your abilities with that power." },
												Option1 = {
													Label = "Sure",
													Text = { "" },
													JumpTo = function()
														return (call("Phoenix"))
													end
												}
											}
										end

										if typeof(v) == "string" then
											return {
												Text = { v }
											}
										end

										return {
											Text = { "..." }
										}
									end
								}
							}
						end

						local v, v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Check")

						if v == 0 then
							Util.playAction("Negative")
							return {
								Text = { "[You must be at least Level 1100 to do this.]" }
							}
						end

						if v2.Phoenix then
							return {
								Text = { "Thanks for your help. Do you need help with anything?" },
								Option1 = {
									Label = "Yes",
									Text = { "" },
									JumpTo = function()
										return (call("Phoenix"))
									end
								}
							}
						end

						return {
							Text = { "..." }
						}
					end)())
				end
			}
		}
	end
}