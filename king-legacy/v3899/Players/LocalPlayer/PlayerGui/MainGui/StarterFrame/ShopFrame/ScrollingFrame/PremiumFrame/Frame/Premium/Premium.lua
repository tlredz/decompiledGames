local localPlayer = game.Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
game:GetService("ReplicatedStorage")
localPlayer:GetMouse()
local v = true
script.Parent.MouseButton1Click:Connect(function()
	if not v then
		return
	end

	v = false
	task.spawn(function()
		wait(0.1)
		v = true
	end)
	task.spawn(function()
		_G.ClickFrameEffect({
			Sound = true
		})
	end)

	if localPlayer.MembershipType == Enum.MembershipType.Premium then
		return
	end

	MarketplaceService:PromptPremiumPurchase(localPlayer)
end)