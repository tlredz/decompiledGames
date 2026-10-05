local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DialogueController = require(game.ReplicatedStorage.DialogueController)
require(game.ReplicatedStorage.DialoguesList.Types)
return {
	Title = "Trinket Expert",
	Get = function(self)
		local accessoryMerge = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("AccessoryMerge")
		local open = accessoryMerge:WaitForChild("Open")
		local ROOT = accessoryMerge:WaitForChild("ROOT")
		return {
			Text = { "I can fuse your Trinkets together to make them more powerful! I've also got some spare Trinkets you can buy." },
			Option1 = {
				Label = "Fuse",
				JumpTo = function()
					DialogueController.hideFrame()
					pcall(function()
						open:Fire(false)
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
				Label = "Buy",
				JumpTo = function()
					return {
						Text = { "Here's the deal... 400 Simulation Data for a random Trinket. Sound good?" },
						Option1 = {
							Label = "Buy",
							JumpTo = function()
								local v, v2 = ReplicatedStorage.Remotes.AccessoryInteract:InvokeServer("d")

								if v then
									return nil
								end

								return {
									Text = { v2 == "CantAfford" and "Sorry, you don't have enough Simulation Data. No freebies!" or v2 == "MaxTrinkets" and "You've already got the maximum amount of Trinkets. Scrap some and try again!" or "Sorry, I ran out of boxes. Try again later!" },
									Option1 = {
										Label = "Return",
										JumpTo = function()
											return self:Get()
										end
									}
								}
							end
						}
					}
				end
			}
		}
	end
}