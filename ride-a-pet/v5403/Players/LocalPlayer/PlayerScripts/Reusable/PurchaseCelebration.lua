local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local Confetti = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("Confetti"))
local v = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function Celebrate()
	local now = os.clock()

	if now - v < 1.5 then
		return
	end

	v = now
	pcall(Confetti.Burst)
end

MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, _, p2)
	if p2 and p == localPlayer.UserId then
		Celebrate() -- equivalent call inferred; original call site unknown
	end
end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, _, p2)
	if p2 and p == localPlayer then
		Celebrate() -- equivalent call inferred; original call site unknown
	end
end)