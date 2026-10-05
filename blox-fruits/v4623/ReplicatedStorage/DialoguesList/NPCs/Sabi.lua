require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "Sabi",
	Get = function(_)
		return {
			Text = { "Hello." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
							"BlackbeardReward",
							"DragonClaw",
							"1"
						)

						if not v then
							Util.playAction("Negative")
							return {
								Text = { "Go away." }
							}
						end

						if v == 1 then
							return {
								Text = { "It seems you already know this style. Would you like to start using it again?" },
								Option1 = {
									Label = "Learn",
									Text = { "" },
									JumpTo = function()
										local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"BlackbeardReward",
											"DragonClaw",
											"2"
										)

										if v2 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Dragon Breath learned.]" }
											}
										elseif v2 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough fragments.]" }
											}
										end

										if v2 ~= 2 then
											return {
												Text = { "..." }
											}
										end

										Util.playAction("Explain")
										return {
											Text = { "[You already know this fighting style.]" }
										}
									end
								}
							}
						end

						return {
							Text = { "I'd be willing to teach you the Dragon Breath fighting style for <Color=Purple>ƒ1,500<Color=/>, interested?" },
							Option1 = {
								Label = "Trade",
								Text = { "" },
								JumpTo = function()
									local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
										"BlackbeardReward",
										"DragonClaw",
										"2"
									)

									if v2 == 1 then
										Util.playAction("Positive")
										return {
											Text = { "[Trade completed.]" }
										}
									elseif v2 == 0 then
										Util.playAction("Negative")
										return {
											Text = { "[Not enough fragments.]" }
										}
									end

									if v2 ~= 2 then
										return {
											Text = { "..." }
										}
									end

									Util.playAction("Explain")
									return {
										Text = { "[You already own this item.]" }
									}
								end
							}
						}
					end)())
				end
			}
		}
	end
}