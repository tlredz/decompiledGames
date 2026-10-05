local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContextActionService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Observers = require(ReplicatedStorage.packages.Observers)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local library = require(ReplicatedStorage.shared.modules.library)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
return {
	init = function()
		local v = nil

		local function updateTradeOfferPrompts()
			local fetched = legacyLocalPlayerData.fetch()
			local tool = v and v:FindFirstChildOfClass("Tool")
			local itemFromLink = DataController.getItemFromLink(tool)
			local enabled = itemFromLink and (library.fish[itemFromLink.name] or tool and tool:GetAttribute("ShowTradeOffer")) and true or false

			if fetched.Stats.level.Value < 15 then
				enabled = false
			end

			for _, v3 in Players:GetPlayers() do
				if v3 == localPlayer then
					continue
				end

				local character = v3.Character

				if not character then
					continue
				end

				local torso = character:FindFirstChild("Torso")

				if not torso then
					continue
				end

				local tradeOffer = torso:FindFirstChild("TradeOffer")

				if not tradeOffer then
					continue
				end

				tradeOffer.Enabled = enabled
				tradeOffer.ActionText = not tool and "Request Trade" or tool:GetAttribute("OfferDisplay") or "Request Trade"
			end
		end

		Observers.observeCharacter(localPlayer, function(_, p)
			v = p
			v.ChildAdded:Connect(updateTradeOfferPrompts)
			v.ChildRemoved:Connect(updateTradeOfferPrompts)
			updateTradeOfferPrompts()
		end)
		task.spawn(function()
			while true do
				updateTradeOfferPrompts()
				task.wait(0.5)
			end
		end)
	end
}