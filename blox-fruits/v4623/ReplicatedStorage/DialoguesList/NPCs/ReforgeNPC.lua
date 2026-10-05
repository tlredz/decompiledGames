local Players = game:GetService("Players")
local DialogueController = require(game.ReplicatedStorage.DialogueController)
require(game.ReplicatedStorage.DialoguesList.Types)
return {
	Title = "Trinket Refiner",
	Get = function(_)
		return {
			Text = { "That merging guy thinks he's so cool... Not only can I REFORGE your trinkets, but I can SCRAP them for Simulation Data too! Interested?" },
			Option1 = {
				Label = "Reforge",
				JumpTo = function()
					DialogueController.hideFrame()
					pcall(function()
						local accessoryMerge = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("AccessoryMerge")
						local open = accessoryMerge:WaitForChild("Open")
						local ROOT = accessoryMerge:WaitForChild("ROOT")
						open:Fire(true)
						task.wait(0.5)

						repeat
							task.wait(0.1)
						until #ROOT:GetChildren() == 0
					end)
					return {
						Text = { "..." }
					}
				end
			},
			Option2 = {
				Label = "Scrap",
				JumpTo = function()
					DialogueController.hideFrame()
					pcall(function()
						local accessoryTrasher = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("AccessoryTrasher")
						local open = accessoryTrasher:WaitForChild("Open")
						local ROOT = accessoryTrasher:WaitForChild("ROOT")
						open:Fire()
						task.wait(0.5)

						repeat
							task.wait(0.1)
						until #ROOT:GetChildren() == 0
					end)
					return {
						Text = { "..." }
					}
				end
			}
		}
	end
}