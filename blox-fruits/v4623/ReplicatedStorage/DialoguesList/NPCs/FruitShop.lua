local Net = require(game.ReplicatedStorage.Modules.Net)
require(game.ReplicatedStorage.DialoguesList.Types)
local Library = require(game.ReplicatedStorage.DialoguesList.Library)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local v = DialogueController.new()
v:setTitle("Blox Fruit Dealer")
v:setTitleSprite("Fruit", {
	wiggle = true
})
return v:addPage("Main", function(object)
	Net:RemoteEvent("RobloxAnalytics"):FireServer({
		Context = "SpokeToNPC",
		InternalName = "FruitShop"
	})
	local IsTransformed = require(game.ReplicatedStorage.Util.IsTransformed)

	if IsTransformed(game.Players.LocalPlayer.Character, true, true) then
		object:addText("If you want to buy something, you'll have to disable your transformation first.")
		return
	end

	object:addText("I search the world for Blox Fruits. When I find one, I will put it in stock here at my shop for you to buy. Otherwise, you can take your chances at finding one across the oceans.")
	object:addText("Buying here will grant you the powers a fruit beholds, not a physical fruit. Buying a new fruit will directly replace your existing one. Purchasing a fruit with <Color=Green>Robux<Color=/> will allow you to swap for it here at any time.")
	object:addOptionType("Purchase", function(object2)
		object2:setText("Purchase")
		object2:onSelected(function(_)
			return Library.openFruitShop("FruitDealer")
		end)
	end)
end):build()