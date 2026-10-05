local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local HudNavigation = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("HudNavigation"))
local ProximityPromptService = game:GetService("ProximityPromptService")
ProximityPromptService.PromptTriggered:Connect(function(player, p)
	local shopModel = workspace:FindFirstChild("ShopModel")

	if p == localPlayer and shopModel and player:IsDescendantOf(shopModel) then
		HudNavigation.activate("Shop")
		local valleyArmory = localPlayer.PlayerGui:FindFirstChild("ValleyArmory")

		if valleyArmory and valleyArmory.Overlay.Visible then
			valleyArmory.Overlay.Canvas.Storefront.CanvasPosition = Vector2.zero
		end
	end
end)