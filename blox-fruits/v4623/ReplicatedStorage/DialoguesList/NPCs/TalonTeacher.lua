local Net = require(game.ReplicatedStorage.Modules.Net)
require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
local remoteFunction = Net:RemoteFunction("InteractDragonQuest")
return {
	Title = "Uzoth",
	Get = function(_)
		local v = remoteFunction:InvokeServer({
			NPC = "Uzoth",
			Command = "Speak"
		})
		local v2 = {
			Text = { "It is I, the legendary Uzoth! What's up?" },
			Option1 = {
				Label = "Style",
				JumpTo = function()
					return ((function()
						local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDragonTalon", true)

						if typeof(v3) == "string" then
							return {
								Text = { v3 }
							}
						end

						if v3 ~= 3 then
							return {
								Text = { v3 == 1 and "It seems you already know this style. Would you like to start using it again?" or "Would you like to learn the Dragon Talon fighting style for <Color=Green>$3,000,000<Color=/> and <Color=Purple>ƒ5,000<Color=/>? This style allows the manipulation of fire to attack your opponents with it. It also has 3 special skills." },
								Option1 = {
									Label = "Learn",
									JumpTo = function()
										local v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDragonTalon")

										if v4 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Dragon Talon learned.]" }
											}
										elseif v4 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough money or fragments.]" }
											}
										elseif v4 == 2 then
											Util.playAction("Negative")
											return {
												Text = { "[You already know this fighting style.]" }
											}
										end

										if v4 ~= 3 then
											return {
												Text = { v4 }
											}
										end

										Util.playAction("Negative")
										return {
											Text = { "[You're not strong enough yet.]" }
										}
									end
								}
							}
						end

						Util.playAction("Explain")
						return {
							Text = { "Thanks for providing me with a Fire Essence, but I can't teach you anything yet! Come back when you're prepared enough." }
						}
					end)())
				end
			}
		}

		if v then
			local function finalDialogue()
				if v == "Completed" then
					return {
						Text = { "I have nothing left to teach you. Your Dragon Talon style is fully upgraded." }
					}
				end

				local v3 = v.Hotkey == "X" and "Ember Annihilation [X]" or v.Hotkey == "C" and "Infernal Vortex [C]" or "Talon Lighter [Z]"
				return {
					Text = { string.format(({
							Z = "The first skill I can upgrade is <Color=Yellow><%s><Color=/>. When an enemy is low enough, using this ability will result in a special execution. Just give me <Color=Yellow>%ss<Color=/> for my services.",
							X = "The next skill I can upgrade is <Color=Yellow><%s><Color=/>. Holding this ability will allow you to ride the projectile. Just give me <Color=Yellow>%ss<Color=/> for my services.",
							C = "The last skill I can upgrade is <Color=Yellow><%s><Color=/>. At the start of the ability, nearby enemies will be stunned briefly. Just give me <Color=Yellow>%ss<Color=/> for my services."
						})[v.Hotkey], v3, v.Cost[1].Amount .. " " .. v.Cost[1].Name) },
					Option1 = {
						Label = "Upgrade",
						JumpTo = function()
							if remoteFunction:InvokeServer({
								NPC = "Uzoth",
								Command = "Upgrade"
							}) then
								Util.playAction("Positive")
								return {
									Text = { "Excellent training." }
								}
							end

							Util.playAction("Negative")
							return {
								Text = { "Come back once you've gathered the materials." }
							}
						end
					}
				}
			end

			v2.Option2 = {
				Label = "Upgrade",
				JumpTo = function()
					if v == "Completed" or v.Cost[1].Name ~= "Z" then
						return (finalDialogue())
					end

					return {
						Text = { "You've done well training your Dragon Talon, but you aren't using it to its fullest potential. Want me to show you?" },
						Option1 = {
							Label = "For sure",
							JumpTo = finalDialogue
						}
					}
				end
			}
		end

		return v2
	end
}