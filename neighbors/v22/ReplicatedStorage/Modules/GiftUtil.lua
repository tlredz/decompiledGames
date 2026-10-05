local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local localPlayer = Players.LocalPlayer
local prompts = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Prompts")
MarketplaceService.PromptProductPurchaseFinished:Connect(function(_: number, _: number, flag: boolean)
	if not flag and localPlayer:GetAttribute("SelectedRecipient") then
		Network:fire("CancelDeveloperProductGift")
		print("Gifting prompt closed -- removing gift recipient.")
	end
end)
return {
	PromptGift = function(_, productId: number)
		prompts.Gift:SetAttribute("ProductId", productId)
		prompts.Gift.Visible = true
	end
}