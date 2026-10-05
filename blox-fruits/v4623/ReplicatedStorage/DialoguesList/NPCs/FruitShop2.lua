local Net = require(game.ReplicatedStorage.Modules.Net)
require(game.ReplicatedStorage.DialoguesList.Types)
local Library = require(game.ReplicatedStorage.DialoguesList.Library)
return {
	Title = "Advanced Fruit Dealer",
	Get = function(_)
		Net:RemoteEvent("RobloxAnalytics"):FireServer({
			Context = "SpokeToNPC",
			InternalName = "FruitShop2"
		})
		local IsTransformed = require(game.ReplicatedStorage.Util.IsTransformed)

		if IsTransformed(game.Players.LocalPlayer.Character, true, true) then
			return {
				Text = { "If you want to buy something, you'll have to disable your transformation first." }
			}
		end

		return {
			Text = {
				"I search the world for Blox Fruits. When I find one, I will put it in stock here at my shop for you to buy. Otherwise, you can take your chances at finding one across the oceans.",
				"Buying here will grant you the powers a fruit beholds, not a physical fruit. Buying a new fruit will directly replace your existing one. Purchasing a fruit with <Color=Green>Robux<Color=/> will allow you to swap for it here at any time."
			},
			Option1 = {
				Label = "Continue",
				JumpTo = function()
					return Library.openFruitShop("AdvancedFruitDealer")
				end
			}
		}
	end
}