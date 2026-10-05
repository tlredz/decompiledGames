local Net = require(game.ReplicatedStorage.Modules.Net)
local Main = require(game.ReplicatedStorage.Util.CameraShaker.Main)
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
local remoteFunction = Net:RemoteFunction("InteractDragonQuest")
local DragonWizard = {
	Title = "Dragon Wizard",
	Get = function(_)
		local v = remoteFunction:InvokeServer({
			NPC = "Dragon Wizard",
			Command = "Speak"
		})

		if not v then
			return {
				Text = { "..." }
			}
		end

		if not (v.CanTransform or v.CanLearnTether or v.TetherLearned or v.AvailableVQuest) then
			Util.playAction("Negative")
			return {
				Text = { "Young dragon, I only teach students who have finished learning everything which this dojo has to offer." }
			}
		end

		local v2 = nil
		local v3 = {}

		if v.CanTransform then
			if v.CanTransformFree then
				table.insert(v3, {
					Label = "Draco",
					Text = { "Would you like to change your race to <Color=Red>Draco<Color=/>?" },
					Option1 = {
						Label = "Yes",
						JumpTo = function()
							if not remoteFunction:InvokeServer({
								NPC = "Dragon Wizard",
								Command = "DragonRace"
							}) then
								return {
									Text = { "..." }
								}
							end

							Util.playAction("Positive")
							return {
								Text = { "Race changed to <Color=Yellow>Draco<Color=/>." }
							}
						end
					}
				})
			else
				table.insert(v3, {
					Label = "Draco",
					Text = { "Would you like to change your race to <Color=Red>Draco<Color=/>? All I need is that egg you're holding, do you want to trade me for it?" },
					Option1 = {
						Label = "Trade",
						JumpTo = function()
							if not remoteFunction:InvokeServer({
								NPC = "Dragon Wizard",
								Command = "DragonRace"
							}) then
								return {
									Text = { "..." }
								}
							end

							Util.playAction("Positive")
							return {
								Text = { "Race changed to <Color=Yellow>Draco<Color=/>." }
							}
						end
					}
				})
			end
		elseif v.Special then
			if v.Special == 2 then
				table.insert(v3, {
					Label = "Next",
					Text = { "During times of such chilling weather, the most loyal Draco soldiers are to be tested." }
				})
				v2 = "Freezing the island was a great idea! We have protection from the cold in our dojo, but those venom invaders are vulnerable. We will soon take back our lands thanks to you!"
			else
				v2 = "It's freezing outside. You may take shelter inside the dojo until the storm passes."
			end
		elseif v.AvailableVQuest == "V2" then
			table.insert(v3, {
				Label = "Ascension",
				Text = { "Very well. You'll need to acquire five <Color=Yellow>Fire Flowers<Color=/> to start your ascension." },
				Option1 = {
					Label = "Begin",
					JumpTo = function()
						if not remoteFunction:InvokeServer({
							NPC = "Dragon Wizard",
							Command = "Ascension",
							Action = "Begin"
						}) then
							return {
								Text = { "..." }
							}
						end

						Util.playAction("Positive")
						return {
							Text = { "Good luck." }
						}
					end
				}
			})
			v2 = "Welcome back, young dragon."
		elseif v.AvailableVQuest == "V2TurnInReady" then
			table.insert(v3, {
				Label = "Ascension",
				Text = { "I see you've gathered the <Color=Yellow>Fire Flowers<Color=/>. I'll also need <Color=Green>$1,000,000<Color=/> from you." },
				Option1 = {
					Label = "Complete",
					JumpTo = function()
						if not remoteFunction:InvokeServer({
							NPC = "Dragon Wizard",
							Command = "Ascension",
							Action = "Complete"
						}) then
							return {
								Text = { "You don't have enough money." }
							}
						end

						CameraShaker:ShakeSustain(Main.Presets.Vibration)
						task.delay(2, function()
							CameraShaker:StopSustained(0.25)
						end)
						Util.playAction("Positive")
						return {
							Text = {
								"<AnimateYield=0.5>.<AnimateYield=0.5>.<AnimateYield=0.5>.",
								"<Color=Red>Draconic<Color=/> power is coursing through you."
							}
						}
					end
				}
			})
			v2 = "Welcome back, young dragon."
		elseif v.AvailableVQuest == "V2InProgress" then
			Util.playAction("Negative")
			table.insert(v3, {
				Label = "Ascension",
				Text = { "Head back to me when you've got the <Color=Yellow>Fire Flowers<Color=/>." }
			})
			v2 = "Welcome back, young dragon."
		elseif v.AvailableVQuest == "V3CantStart" then
			Util.playAction("Negative")
			table.insert(v3, {
				Label = "Ascension",
				Text = { "You're not ready yet." }
			})
			v2 = "I don't have anything to teach you right now. Come back when you're a little stronger."
		elseif v.AvailableVQuest == "V3" then
			table.insert(v3, {
				Label = "Ascension",
				Text = { "This time, you'll be defeating a Terrorshark." },
				Option1 = {
					Label = "Begin",
					JumpTo = function()
						if not remoteFunction:InvokeServer({
							NPC = "Dragon Wizard",
							Command = "Ascension",
							Action = "Begin"
						}) then
							return {
								Text = { "..." }
							}
						end

						Util.playAction("Positive")
						return {
							Text = { "Good luck." }
						}
					end
				}
			})
			v2 = "I've been waiting for you."
		elseif v.AvailableVQuest == "V3InProgress" then
			Util.playAction("Negative")
			table.insert(v3, {
				Label = "Ascension",
				Text = { "Still haven't defeated a Terrorshark? I'll be waiting here." }
			})
			v2 = "Welcome back, young dragon."
		elseif v.AvailableVQuest == "V3TurnInReady" then
			table.insert(v3, {
				Label = "Ascension",
				Text = { "You've finally defeated the Terrorshark? This will cost you <Color=Green>$3,000,000<Color=/>." },
				Option1 = {
					Label = "Complete",
					JumpTo = function()
						if not remoteFunction:InvokeServer({
							NPC = "Dragon Wizard",
							Command = "Ascension",
							Action = "Complete"
						}) then
							return {
								Text = { "You don't have enough money." }
							}
						end

						CameraShaker:ShakeSustain(Main.Presets.Vibration)
						task.delay(2, function()
							CameraShaker:StopSustained(0.25)
						end)
						Util.playAction("Positive")
						return {
							Text = {
								"<AnimateYield=0.5>.<AnimateYield=0.5>.<AnimateYield=0.5>.",
								"<Color=Red>Draconic<Color=/> power is coursing through you."
							}
						}
					end
				}
			})
			v2 = "Welcome back, young dragon."
		elseif v.TetherLearned and v.Race ~= "Draco" then
			Util.playAction("Negative")
			table.insert(v3, {
				Label = "Draco",
				Text = { "Come back when you have a <Color=Yellow>Dragon Egg<Color=/> for me." }
			})
		elseif v.CanLearnTether then
			table.insert(v3, {
				Label = "Dragon Tether",
				Text = { "Would you like to learn <Color=Red>Dragon Tether<Color=/>?" },
				Option1 = {
					Label = "Yes",
					JumpTo = function()
						if not remoteFunction:InvokeServer({
							NPC = "Dragon Wizard",
							Command = "LearnTether"
						}) then
							return {
								{
									Text = "..."
								}
							}
						end

						CameraShaker:ShakeSustain(Main.Presets.Vibration)
						task.delay(2, function()
							CameraShaker:StopSustained(0.25)
						end)
						Util.playAction("Positive")
						return {
							Text = {
								"<AnimateYield=0.5>.<AnimateYield=0.5>.<AnimateYield=0.5>.",
								"You've learned <Color=Red>Dragon Tether<Color=/>.",
								"Now you will be able to collect <Color=Yellow>Dragon Eggs<Color=/> from the Prehistoric Island."
							}
						}
					end
				}
			})
		end

		local v4 = not v2 and v.FoundPrehistoric and not (v.WantsBlizz or v.V4) and "The Draco temple has much knowledge to share with you. A visit to the Prehistoric Island volcano should be very productive for you." or v2
		local v5

		if not (v4 or not v.WantsBlizz) then
			v4 = "The wind is chilly.."
			v5 = "I wonder if there's a storm approaching."
		end

		if table.maxn(v3) > 0 then
			local result = {
				Text = { v4 or "What do you seek?" }
			}

			for k, v6 in v3 do
				result["Option" .. tostring(k)] = v6
			end

			return result
		elseif v4 or not v.V4 then
			local v6 = v4 or "I don't have anything to teach you right now. Come back when you're a little stronger."

			if v5 then
				return {
					Text = { v6, v5 }
				}
			end

			return {
				Text = { v6 }
			}
		else
			local _, _, v6 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Check", 2)

			if v6 then
				return {
					Text = {
						"You have learned everything I know.  However...",
						"I feel checking the hologram room would prove beneficial."
					}
				}
			end

			return {
				Text = { "You have learned everything I know." }
			}
		end
	end,
	FishTournamentNpc = 0
}
local FishingTournamentClient = require(game.ReplicatedStorage.Controllers.FishingTournamentClient)
DragonWizard.FishTournamentNpc = FishingTournamentClient.FishTournamentNPC()
return DragonWizard