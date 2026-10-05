local import = _G.import("event")
local import2 = _G.import("global")
local import3 = _G.import("gamePassData")
local import4 = _G.import("subscriptionCollection")
local import5 = _G.import("developerProductCollection")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = game.Players.LocalPlayer

local function developerProductPurchased(p)
	local v = import5:get("p" .. p.ProductId)

	if not v.Client then
		return
	end

	local playerSave = import2.get("playerSave", localPlayer)
	local playerSession = import2.get("playerSession", localPlayer)
	v.Client(localPlayer, p, playerSave, playerSession, v)
end

local function gamePassPurchased(p, p2, p3)
	if not (p3 and p) then
		return
	end

	local v = import3["p" .. p2]
	local playerSave = import2.get("playerSave", p)
	local playerSession = import2.get("playerSession", p)
	playerSave:addPass(p2)

	if v and v.Client then
		v.Client(p, playerSave, playerSession, v)
	end
end

local function subscriptionStatusChanged(p, remoteFire)
	local v = import4:get("s" .. p)

	if not (v and v.Client) then
		return
	end

	local playerSave = import2.get("playerSave", localPlayer)
	local playerSession = import2.get("playerSession", localPlayer)
	v.Client(localPlayer, p, remoteFire, playerSave, playerSession, v)
end

local function subscriptionPromptFinished(p, p2, p3)
	if p ~= localPlayer then
		return
	end

	local v = import4:get("s" .. p2)

	if v and v.PromptFinished then
		v.PromptFinished(localPlayer, p2, p3, v)
	end

	if not p3 then
		return
	end

	local remoteFire = import.remoteFire("GetSubscriptionStatus", p2)

	if remoteFire then
		subscriptionStatusChanged(p2, remoteFire)
	end
end

local function promptSubscription(p)
	MarketplaceService:PromptSubscriptionPurchase(localPlayer, p)
end

return {
	Priority = 1,
	Run = function()
		import.remoteConnect("ProcessReceipt", developerProductPurchased)
		import.remoteConnect("SubscriptionStatusChanged", subscriptionStatusChanged)
		import.connect("PromptSubscription", promptSubscription)
		MarketplaceService.PromptGamePassPurchaseFinished:connect(gamePassPurchased)
		MarketplaceService.PromptSubscriptionPurchaseFinished:Connect(subscriptionPromptFinished)
	end
}