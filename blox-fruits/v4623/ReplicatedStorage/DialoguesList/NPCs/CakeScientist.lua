require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "Cake Scientist",
	Get = function(_)
		return ((function()
			local function call(p)
				return {
					Text = { "Would you like to purchase a <" .. p .. "> Special Microchip for <Color=Purple>ƒ1,000<Color=/>? You can only do this every 2 hours." },
					Option1 = {
						Label = "Buy",
						JumpTo = function()
							local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Select", p)

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

			if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CakeScientist", "Check") then
				local redKey = game.Players.LocalPlayer.Backpack:FindFirstChild("Red Key") or game.Players.LocalPlayer.Character:FindFirstChild("Red Key")

				if redKey then
					return {
						Text = { "You've freed me from the Dough King's tyranny. Did you know I'm a good scientist? Perhaps I can help you further evolve your abilities with that power." },
						Option1 = {
							Label = "Sure",
							Text = { "" },
							JumpTo = function()
								redKey:Destroy()
								return (call("Dough"))
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
				elseif v2.Dough then
					return {
						Text = { "Thanks for your help. Do you need help with anything?" },
						Option1 = {
							Label = "Yes",
							Text = { "" },
							JumpTo = function()
								return (call("Dough"))
							end
						}
					}
				end
			end

			return {
				Text = { "..." }
			}
		end)())
	end
}