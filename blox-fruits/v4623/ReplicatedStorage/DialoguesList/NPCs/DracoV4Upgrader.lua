require(game.ReplicatedStorage.DialoguesList.Types)
return {
	Title = "Red Essence",
	Get = function(_)
		if not game.Players.LocalPlayer.Character:FindFirstChild("RaceTransformed") then
			return {
				Text = { "You have yet to achieve greatness." }
			}
		end

		local v, v2, v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Check", 2)

		if v == 1 then
			return {
				Text = {
					"So you've awakened.",
					"Like the other races, it's possible to gather energy quicker, but you'll need to train first."
				},
				Option1 = {
					Label = "Okay.",
					JumpTo = function()
						return {
							Text = { "Come back when you've trained more." }
						}
					end
				}
			}
		elseif v == 2 then
			return {
				Text = {
					"You've been working hard, I can tell.",
					"I have something you could use to improve your limits.",
					"I have no need for it, I'll sell it to you for <Color=Purple>ƒ" .. v3 .. "<Color=/>."
				},
				Option1 = {
					Label = "Buy",
					JumpTo = function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Buy", 2) then
							return {
								Text = { "Here you go. This should improve your energy." }
							}
						end

						return {
							Text = { "You don't have enough." }
						}
					end
				}
			}
		elseif v == 3 then
			return {
				Text = { "You can still improve. I can help you increase your potential further." },
				Option1 = {
					Label = "Teach me.",
					JumpTo = function()
						return {
							Text = { "Come back when you've trained more." }
						}
					end
				}
			}
		elseif v == 4 then
			return {
				Text = {
					"You've come a long way.",
					"As promised, I'll upgrade your transformation limit for <Color=Purple>ƒ" .. v3 .. "<Color=/>."
				},
				Option1 = {
					Label = "Buy",
					JumpTo = function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Buy", 2) then
							return {
								Text = { "Excellent." }
							}
						end

						return {
							Text = { "You don't have enough." }
						}
					end
				}
			}
		elseif v == 5 then
			return {
				Text = { "It seems you've made this power your own. I've done all I can for you." }
			}
		elseif v == 6 then
			return {
				Text = { [[
In order to participate in the next trial, we'll have to go through 3 additional training sessions. This will help you last longer transformed.
<Color=Yellow>Upgrades completed: ]] .. v2 - 2 .. "/3<Color=/>" },
				Option1 = {
					Label = "Teach me.",
					JumpTo = function()
						return {
							Text = { "Come back when you've trained more." }
						}
					end
				}
			}
		elseif v == 7 then
			return {
				Text = { "You're ready for the next upgrade. This will cost you <Color=Purple>ƒ" .. v3 .. "<Color=/>." },
				Option1 = {
					Label = "Buy",
					JumpTo = function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Buy", 2) then
							return {
								Text = { "Perfect." }
							}
						end

						return {
							Text = { "You don't have enough." }
						}
					end
				}
			}
		elseif v == 8 then
			return {
				Text = { "It seems that you've mastered the trials. If you're interested, I can help you further with <Color=Yellow>" .. 10 - v2 .. "<Color=/> more training sessions." },
				Option1 = {
					Label = "Teach me.",
					JumpTo = function()
						return {
							Text = { "Come back when you've trained more." }
						}
					end
				}
			}
		elseif v == 9 then
			return {
				Text = { "Your race treads a different path to power. I'm unable to help with this." }
			}
		elseif v == 0 then
			return {
				Text = { "You're ready for the next trial." }
			}
		end

		return {
			Text = { "You have yet to achieve greatness." }
		}
	end
}