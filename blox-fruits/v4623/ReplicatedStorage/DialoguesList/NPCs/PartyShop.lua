local EventShop = require(game.ReplicatedStorage.Controllers.UI.EventShop)
local Net = require(game.ReplicatedStorage.Modules.Net)
require(game.ReplicatedStorage.DialoguesList.Types)
return {
	Title = "Easter Shop",
	Get = function(_)
		Net:RemoteFunction("EasterServiceRF"):InvokeServer("EasterBunny.Request")
		return {
			Text = { "Shop resets every hour!" },
			Option1 = {
				Label = "Continue",
				JumpTo = function()
					EventShop:Open("Easter2026")
					return {
						Text = { "..." }
					}
				end
			},
			Option2 = {
				Label = "Secret",
				JumpTo = function()
					local v = Net:RemoteFunction("EasterServiceRF"):InvokeServer("EasterBunny.Request")

					if not v.CanCollectChalice then
						local v2 = math.max(v.NumTotal - 1 - v.NumOwned, 0)
						return {
							Text = { (`Come back when you have collected {v2} other Egg{v2 > 1 and "s" or ""}!`) }
						}
					end

					if v.NextCost == 0 then
						local v2 = Net:RemoteFunction("EasterServiceRF"):InvokeServer("EasterBunny.Chalice")

						if v2 and v2.Success then
							return {
								Text = { "You received a free Easter Chalice!" }
							}
						end
					end

					if not v.CanAffordNext then
						return {
							Text = { (`You need {v.NextCost} Candy Eggs to buy another Easter Chalice.`) }
						}
					end

					local v2 = Net:RemoteFunction("EasterServiceRF"):InvokeServer("EasterBunny.Chalice")

					if v2 and v2.Success then
						if v2.NextCost == 0 then
							return {
								Text = { "You received a free Easter Chalice!" }
							}
						end

						return {
							Text = { (`You traded {v2.NextCost} Candy Eggs for an Easter Chalice.`) }
						}
					else
						if v2 and v2.Reason == "NotEnoughEggs" then
							return {
								Text = { (`You need {v2.NextCost} Candy Eggs to buy another Easter Chalice.`) }
							}
						end

						if not v2 or v2.Reason ~= "MissingEggs" then
							return {
								Text = { "Something went wrong." }
							}
						end

						local v3 = math.max(v2.NumTotal - 1 - v2.NumOwned, 0)
						return {
							Text = { (`Come back when you have collected {v3} other Egg{v3 > 1 and "s" or ""}!`) }
						}
					end
				end
			}
		}
	end
}