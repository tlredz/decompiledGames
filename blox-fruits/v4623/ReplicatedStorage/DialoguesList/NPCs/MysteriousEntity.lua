require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "Mysterious Entity",
	Get = function(_)
		return {
			Text = { "<Color=Yellow>Greetings, mortal. What do you seek?<Color=/>" },
			Option1 = {
				Label = "ASCENSION",
				JumpTo = function()
					return ((function()
						local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Awakener", "Check")

						if v == 0 then
							return {
								Text = { "[You cannot talk to this NPC.]" }
							}
						elseif v == 1 then
							Util.playAction("Negative")
							return {
								Text = { "<AnimateStyle=Wiggle><Color=Yellow>Ah. Your current fruit cannot awaken its true potential yet, sorry.<Color=/><AnimateStyle=/>" }
							}
						end

						if v then
							return {
								Text = { "<AnimateStyle=Wiggle><Color=Yellow>Do you wish to awaken your [" .. v.Key .. "] ability for <Color=/><AnimateStyle=/><Color=Purple>ƒ" .. v.Cost .. "<Color=/><AnimateStyle=Wiggle><Color=Yellow>?<Color=/><AnimateStyle=/>" },
								Option1 = {
									Label = "Of course",
									Text = { "" },
									JumpTo = function()
										local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"Awakener",
											"Awaken"
										)

										if v2 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Ability awakened.]" }
											}
										end

										if v2 ~= 0 then
											return {
												Text = { "..." }
											}
										end

										Util.playAction("Negative")
										return {
											Text = { "[Not enough fragments.]" }
										}
									end
								}
							}
						end

						return {
							Text = { "<AnimateStyle=Wiggle><Color=Yellow>I've already taught you everything I know.<Color=/><AnimateStyle=/>" }
						}
					end)())
				end
			},
			Option2 = {
				Label = "Take me back",
				JumpTo = function()
					if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Awakener", "Teleport") == 1 then
						Util.playAction("Positive")
						return {
							Text = { "<AnimateStyle=Wiggle><Color=Yellow>As you wish.<Color=/><AnimateStyle=/>" }
						}
					end

					Util.playAction("Negative")
					return {
						Text = { "[You cannot talk to this NPC.]" }
					}
				end
			}
		}
	end
}