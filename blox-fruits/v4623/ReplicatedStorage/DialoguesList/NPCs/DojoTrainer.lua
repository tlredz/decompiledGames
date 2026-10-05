local Net = require(game.ReplicatedStorage.Modules.Net)
require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
local remoteFunction = Net:RemoteFunction("InteractDragonQuest")
return {
	Title = "Dojo Trainer",
	Get = function(_)
		local v = remoteFunction:InvokeServer({
			NPC = "Dojo Trainer",
			Command = "RequestQuest"
		})

		if v then
			local quest = v.Quest

			if quest then
				local questName = quest.QuestName
				return {
					Text = { "Welcome, young dragon. We have a lot we can teach you here." },
					Option1 = {
						Label = quest.BeltName .. " Belt",
						JumpTo = function()
							local v2 = quest.Progress >= quest.Goal
							local v3

							if quest.Description:lower():match("minute") then
								local floor = math.floor
								local _ = string.format
								local v4 = floor(quest.Goal % 3600 / 60)
								local v5 = floor(quest.Goal % 60)
								local v6 = floor(quest.Progress % 3600 / 60)
								local v7 = floor(quest.Progress % 60)
								local v8 = math.floor((v6 * 60 + v7) / (v4 * 60 + v5) * 100)
								v3 = string.format("%.f", v8)
							else
								v3 = string.format("%.f", quest.Progress / quest.Goal * 100)
							end

							local v4 = {
								Text = { (`Today's teaching focuses on <Color=Yellow>{questName}<Color=/>. Ponder its meaning and seek clarity. Return when you have unraveled its mystery.\nProgress: {v3}%`) }
							}

							if v2 then
								v4.Option1 = {
									Label = "Claim",
									JumpTo = function()
										if remoteFunction:InvokeServer({
											NPC = "Dojo Trainer",
											Command = "ClaimQuest"
										}) then
											return {
												Text = { "Excellent work." }
											}
										end

										return {
											Text = { "..." }
										}
									end
								}
							end

							return v4
						end
					}
				}
			end

			if v.Timeout then
				Util.playAction("Negative")
				return {
					Text = { "That's enough training for today... Come back tomorrow and we can continue." }
				}
			elseif v.Completed then
				return {
					Text = { "Your training is complete. You've earned your place as a respected member of the dojo." }
				}
			end
		end

		return {
			Text = { "Make sure you behave yourself. You are not yet one of us, come back once you become proficient with the arts of the Dragon Talon style." }
		}
	end
}