game:GetService("ServerStorage")
local NPCCallbacks = {}
local v = nil
require(game.ReplicatedStorage.Util.Realm)
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteFunction = Net:RemoteFunction("DungeonNPCNetworkFunction")

local function getBaseSimulationNPCDialogue()
	if workspace:GetAttribute("MAP") == "Dungeons" then
		return {
			Title = "Lucien",
			Get = function()
				return {
					Text = { "What can I do for you?" },
					Option1 = {
						Label = "Return",
						JumpTo = function()
							return {
								Text = { "Would you like to return to your previous Sea?" },
								Option1 = {
									Label = "Yes",
									JumpTo = function()
										return remoteFunction:InvokeServer("TeleportBack")
									end
								}
							}
						end
					},
					Option2 = {
						Label = "Energy",
						JumpTo = function()
							return remoteFunction:InvokeServer("GetDungeonEnergy")
						end
					}
				}
			end
		}
	end

	return {
		Title = "Lucien",
		Get = function()
			return {
				Text = { "What can I do for you?" },
				Option1 = {
					Label = "Hub",
					JumpTo = function()
						return {
							Text = { "Would you like to teleport to the <Color=Blue>Dungeon Hub<Color=/>? You can return to this location from there." },
							Option1 = {
								Label = "Yes",
								JumpTo = function()
									return remoteFunction:InvokeServer("TeleportToDungeonHub", false)
								end
							}
						}
					end
				},
				Option2 = {
					Label = "Energy",
					JumpTo = function()
						return remoteFunction:InvokeServer("GetDungeonEnergy")
					end
				}
			}
		end
	}
end

function NPCCallbacks.InitializeNPC(p)
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v = DialogueController
	task.spawn(function()
		task.spawn(p.new, "Lucien", function(_)
			return (getBaseSimulationNPCDialogue())
		end, 4)
	end)
end

task.spawn(function()
	local NPCTable = require(game.ReplicatedStorage.NPCTable)
	NPCTable.onLoaded(NPCCallbacks.InitializeNPC)
end)
return NPCCallbacks