local Realm = require(game.ReplicatedStorage.Util.Realm)
local Net = require(game.ReplicatedStorage.Modules.Net)
require(game.ReplicatedStorage.DialoguesList.Types)
return {
	Title = "Secret Santa",
	Get = function(_)
		local v = {
			"Great! Go defeat 5 elf enemies near your player level.",
			"Great! Go destroy 5 magic <Color=Red>red<Color=/> trees.",
			"Great! Go collect 3 holiday chests."
		}
		local option = {
			Label = "Meters?",
			JumpTo = function()
				return {
					Text = { "Yes! If you fill up your Holiday Magic Meter, you will receive a Lucky Gift from the countdown event. If everyone fills up the Golden Magic Meter, everyone can participate in a bonus event to earn a bonus Gift." }
				}
			end
		}
		local v4 = Net:RemoteFunction("GetQuestsCompleted"):InvokeServer()
		local v5 = {
			Text = { (v4 == 1 or v4 == 2) and "Thank you for your help, I've added one light to your holiday magic meter. Would you like to complete another quest?" or "Welcome to The North Pole. If you help me with my quests, I will fill your Holiday Magic Meter. If you complete all 3, you will be helping to fill up the Golden Magic Meter." },
			Option1 = {
				Label = "Quest",
				JumpTo = function()
					local v4, v5, v6 = Net:RemoteFunction("InteractChristmasNPC"):InvokeServer()

					if v5 then
						return {
							Text = { v4 },
							Option1 = {
								Label = "Yes",
								JumpTo = function()
									return {
										Text = { v[v6] }
									}
								end
							}
						}
					end

					if v4 == "CompletedAll" then
						return {
							Text = {
								"Thank you for your help! You can now expect to find a Lucky Gift at the end of the countdown.",
								"This will also help the server to possibly start the bonus gift raid."
							}
						}
					end

					return {
						Text = { v4 }
					}
				end
			}
		}

		if Realm.getCurrentRealmDifficultyAsync() > 1 then
			v5.Option2 = option
		end

		return v5
	end
}