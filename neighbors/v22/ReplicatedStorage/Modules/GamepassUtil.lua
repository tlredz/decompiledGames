local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local prompts = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Prompts")
local GamepassUtil = {}

function GamepassUtil.PromptGamepass(_, p: string)
	local Gamepasses = require(ReplicatedStorage.Assets.Data.Store.Gamepasses)

	if Gamepasses[p] then
		MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, Gamepasses[p].Id)
	end
end

function GamepassUtil.DisplayGamepassInfo(_, itemName: string)
	prompts.ShopPrompt:SetAttribute("ItemName", itemName)
	prompts.ShopPrompt.Visible = true
end

return GamepassUtil