local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "Valentine Daily Quests",
	Get = function(_)
		local v, _ = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ValentineCurrentQuest")

		if v == "BringValentineFruit" then
			return {
				Text = { "Would you like to hand in a fruit? [Hold out the fruit you wish to hand in.]" },
				Option1 = {
					Label = "Give Fruit",
					JumpTo = function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ValentinesBringFruitQuest")

						if v2 == 0 then
							Util.playAction("Explain")
							return {
								Text = { "Thank you!" }
							}
						elseif v2 == 1 then
							Util.playAction("Negative")
							return {
								Text = { "An error has occured." }
							}
						elseif v2 == 2 then
							Util.playAction("Negative")
							return {
								Text = { "[You already completed this quest. Come back tomorrow!]" }
							}
						end

						if typeof(v2) == "string" then
							return {
								Text = { v2 }
							}
						end

						return {
							Text = { "..." }
						}
					end
				}
			}
		elseif v == "BringValentineFish" then
			return {
				Text = { "Would you like to hand in a fish?" },
				Option1 = {
					Label = "Give Fish",
					JumpTo = function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ValentinesBringFishQuest")

						if v2 == 0 then
							Util.playAction("Explain")
							return {
								Text = { "Thank you!" }
							}
						elseif v2 == 1 then
							Util.playAction("Negative")
							return {
								Text = { "An error has occured." }
							}
						elseif v2 == 2 then
							Util.playAction("Negative")
							return {
								Text = { "[You already completed this quest. Come back tomorrow!]" }
							}
						end

						if typeof(v2) == "string" then
							return {
								Text = { v2 }
							}
						end

						return {
							Text = { "..." }
						}
					end
				}
			}
		end

		return {
			Text = { (`Hey! Wanna complete a few quests for Valentine's and earn Hearts? I will reset my quest offerings in [{game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ValentineQuestGetRefreshTime")}].`) },
			Option1 = {
				Label = "Yes!",
				JumpTo = function()
					local function talkWithCupid(MAP: string)
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("GetValentineDailyQuest", MAP)

						if typeof(v2) == "string" then
							return {
								Text = { v2 }
							}
						end

						local v3 = "Level Required: " .. 1 .. "\nDescription: "

						if v2[1] ~= "ValentineBeatBandits" and v2[1] == "ValentineDefeatBoss" then
						end

						return {
							Label = "Quest",
							Text = { (v3 .. `{v2[4]}`) .. [[


Reward:
]] .. "<Color=Red>" .. TextUtil.commaValue(v2[2]) .. " Hearts.<Color=/>\n" },
							Option1 = {
								Label = "Accept",
								Text = { "" },
								JumpTo = function()
									local v5 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
										"StartNextValentineQuest",
										MAP
									)

									if v5 == 0 then
										Util.playAction("Explain")
										return {
											Text = { "Thank you!" }
										}
									elseif v5 == 1 then
										Util.playAction("Negative")
										return {
											Text = { "An error has occured." }
										}
									elseif v5 == 2 then
										Util.playAction("Negative")
										return {
											Text = { "[You already completed this quest. Come back tomorrow!]" }
										}
									end

									if typeof(v5) == "string" then
										return {
											Text = { v5 }
										}
									end

									return {
										Text = { "..." }
									}
								end
							}
						}
					end

					return (talkWithCupid(workspace:GetAttribute("MAP")))
				end
			}
		}
	end
}