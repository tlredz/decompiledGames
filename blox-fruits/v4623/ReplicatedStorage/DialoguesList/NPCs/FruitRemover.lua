require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteFunction = Net:RemoteFunction("RequestSecretStories")

local function canRemoveStyle()
	if game.Players.LocalPlayer:WaitForChild("Data"):WaitForChild("DevilFruit").Value ~= "" then
		return false
	end

	local success, result = pcall(function()
		return remoteFunction:InvokeServer({
			Type = "GetPhase"
		})
	end)

	if not success or typeof(result) ~= "table" then
		return false
	end

	local phase = result.Phase
	return phase == "Repair" or phase == "Complete"
end

return {
	Title = "Blox Fruit Remover",
	Get = function(_)
		return {
			Text = { "Hey kid, want to have your Blox Fruit powers removed for only <Color=Green>$50,000<Color=/>? No scam, I promise..." },
			Option1 = {
				Label = "Sure",
				JumpTo = function()
					local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RemoveFruit", "Beli")

					if v == 1 then
						Util.playAction("Positive")
						return {
							Text = { "[Blox Fruit removed.]" }
						}
					elseif v == 0 then
						Util.playAction("Negative")
						return {
							Text = { "[Not enough Money.]" }
						}
					elseif v == 2 then
						Util.playAction("Negative")
						return {
							Text = { "[You don't have a Blox Fruit.]" }
						}
					elseif v == 3 then
						Util.playAction("Negative")
						return {
							Text = { "[Stop using your ability first.]" }
						}
					end

					if v ~= 4 then
						return {
							Text = { "..." }
						}
					end

					Util.playAction("Negative")
					return {
						Text = { "[Disable your transformation first.]" }
					}
				end
			},
			Option2 = {
				Label = "Shut up",
				Text = { "<Color=Red>Heh. Watch your back from now on.<Color=/>" }
			},
			Option3 = canRemoveStyle() and {
				Label = "Remove my fighting style",
				JumpTo = function()
					local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RemoveFightingStyle")

					if v == 1 then
						Util.playAction("Positive")
						return {
							Text = { "[Fighting style removed.]" }
						}
					elseif v == 2 then
						Util.playAction("Negative")
						return {
							Text = { "[You're already using Combat.]" }
						}
					elseif v == 3 then
						Util.playAction("Negative")
						return {
							Text = { "[Stop using your ability first.]" }
						}
					elseif v == 4 then
						Util.playAction("Negative")
						return {
							Text = { "[Disable your transformation first.]" }
						}
					elseif v == 5 then
						Util.playAction("Negative")
						return {
							Text = { "[Have your Blox Fruit removed first.]" }
						}
					end

					Util.playAction("Negative")
					return {
						Text = { "[Not here, not now.]" }
					}
				end
			} or nil
		}
	end
}