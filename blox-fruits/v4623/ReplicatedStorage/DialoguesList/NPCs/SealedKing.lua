require(game.ReplicatedStorage.DialoguesList.Types)
return {
	Title = "Sealed King",
	Get = function(_)
		local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4Progress", "Check")

		if v == 0 then
			return {
				Text = { "Here lies King Red Head... Perhaps one day, he'll be released from his mental prison." }
			}
		elseif v == 1 then
			return {
				Text = {
					"Ah... So you found some of my memory fragments from defeating that monster...",
					"It also appears that you tapped into a small fraction of his ability to travel through spacetime... A powerful, yet annoying technique from ancient times...",
					"A long time ago, the Rip Family and the Red Legion clashed many times. In order to fight against their teleportation ability, we had to come up with our very own technique...",
					"This technique allowed us to forget our limits, however, it wasn't easy to learn.",
					"-his memories start fading away- Please head to the Great Tree, I'm sure he's hiding something within that island..."
				},
				Option1 = {
					Label = "Yes, admin",
					Text = {},
					JumpTo = function()
						return {
							Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4Progress", "Begin")) }
						}
					end
				}
			}
		elseif v == 2 then
			return {
				Text = { "Please head to the Great Tree, I'm sure he's hiding something within that island..." }
			}
		elseif v == 3 then
			return {
				Text = {
					"So it was the <Color=Blue>Temple of Time<Color=/> that I felt.",
					"That place may hold the key to a greater power, but you must undergo a trial to grab hold of it.",
					"Powers involving time always work best under the light of a <Color=Blue>full moon<Color=/>."
				},
				Option1 = {
					Label = "Thank you, admin",
					Text = {},
					JumpTo = function()
						return {
							Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
									"RaceV4Progress",
									"Continue"
								)) }
						}
					end
				}
			}
		elseif v == 4 then
			return {
				Text = {
					"That place may hold the key to a greater power, but you must undergo a trial to grab hold of it.",
					"Powers involving time always work best under the light of a <Color=Blue>full moon<Color=/>."
				}
			}
		elseif v == 5 then
			return {
				Text = { "Good morning bro, I'm at Temple of Time right now, WSG?" }
			}
		end

		error((`unexpected r value: {v}`))
	end
}