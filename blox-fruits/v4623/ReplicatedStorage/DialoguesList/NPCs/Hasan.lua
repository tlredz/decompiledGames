local BonusMomentsController = require(game.ReplicatedStorage.Controllers.BonusMomentsController)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
local v = DialogueController.new()
v:setTitle("Hasan")
v:addPage("Main", function(object)
	local rescueHasan = BonusMomentsController:GetLoadedMoments()["Rescue Hasan"]
	local progress = rescueHasan and rescueHasan.Progress
	local completed

	if rescueHasan == nil then
		completed = false
	else
		completed = rescueHasan.Completed
	end

	if progress == 0 then
		object:addText("YO!!! What are you doin' bro? Take care of those skeletons!")
	elseif progress == 1 then
		object:addText("Phew... thanks for saving me back there, homie! As a small token of my appreciation, I'll give you a bargain for this cape I'm selling!")
		object:addText("Go let the Desert Merchant know I'm alright. My homie is probably worried sick about me.")
		object:noCancel()
		object:addOptionType("Accept", function(object2)
			object2:setText("OK!")
			object2:jumpToPage(function(_)
				rescueHasan:FireServer("Interact")
			end)
		end)
	else
		if not completed and progress ~= 2 then
			object:addText("...")
			return
		end

		object:addText("Thanks for rescuing me back there bro! What can I do for you?")
		object:advanceAfterDelay(1)
		object:addOptionType("Purchase", function(object2)
			object2:setText("Purchase")
			object2:jumpToPage(function(object3)
				if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("AccessoryTalk", "Hasan") == 0 then
					object3:addText("Just finessed this Swordsman Hat 😂😂😂 Y'all finna buy some of this merch for <Color=Green>$150,000<Color=/>?")
					object3:addOptionType("Purchase", function(object4)
						object4:setText("Sure homie.")
						object4:jumpToPage(function(object5)
							local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Swordsman Hat")

							if v2 == 1 then
								Util.playAction("Positive")
								object5:addText("[Item purchased.]")
							elseif v2 == 0 then
								Util.playAction("Negative")
								object5:addText("[Not enough Money.]")
							elseif v2 == 2 then
								Util.playAction("Negative")
								object5:addText("[You already own this item.]")
							else
								object5:addText("...")
							end

							object5:advanceAfterDelay(2)
						end)
					end)
				else
					Util.playAction("Negative")
					object3:addText("You're not ready yet, homie.]")
					object3:advanceAfterDelay(2)
				end
			end)
		end)
	end
end)
return v:build()