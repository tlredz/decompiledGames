local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = Players.LocalPlayer
local Gamepasses = require(game.ReplicatedStorage.Gamepasses)
local panel = script.Parent.Root.Panel
local priceInRobuxes = {}

local function update(p)
	local pack = panel.Packs[p]

	if p == "VIP" and localPlayer:GetAttribute("VIPGiftsReady") ~= true and not localPlayer:GetAttribute("Pass_VIP") then
		pack.Buy.Text = "Loading…"
		pack.Buy.Interactable = false
		pack.Availability.Text = ""
	elseif localPlayer:GetAttribute("Pass_" .. p) then
		pack.Buy.Text = "Owned"
		pack.Buy.Interactable = false
		pack.Availability.Text = "Unlocked"
	elseif priceInRobuxes[p] then
		pack.Buy.Text = "R$ " .. priceInRobuxes[p]
		pack.Buy.Interactable = true
		pack.Availability.Text = "One-time purchase"
	else
		pack.Buy.Text = "Loading…"
		pack.Buy.Interactable = false
		pack.Availability.Text = ""
	end
end

localPlayer:GetAttributeChangedSignal("VIPGiftsReady"):Connect(function()
	update("VIP")
end)
panel.Status.Text = "Permanent perks. Roblox confirms your final price."
local id = nil

for k, gamepass in pairs(Gamepasses) do
	local pack = panel.Packs[k]
	pack:SetAttribute("PassId", gamepass.id)
	pack.Description.Text = k == "Coils" and "Includes both Speed Coil and Jump Coil." or pack.Description.Text
	update(k)
	local v = k
	localPlayer:GetAttributeChangedSignal("Pass_" .. k):Connect(function()
		update(v)
	end)
	local v2 = gamepass
	local v3 = k
	task.spawn(function()
		for i = 1, 3 do
			local success, productInfoAsync = pcall(
				MarketplaceService.GetProductInfoAsync,
				MarketplaceService,
				v2.id,
				Enum.InfoType.GamePass
			)

			if success and productInfoAsync.IsForSale and type(productInfoAsync.PriceInRobux) == "number" then
				priceInRobuxes[v3] = productInfoAsync.PriceInRobux
				update(v3)
				return
			elseif success and not productInfoAsync.IsForSale then
				pack.Buy.Text = "Not for sale"
				pack.Availability.Text = ""
				return
			else
				task.wait(i)
			end
		end

		pack.Buy.Text = "Unavailable"
	end)
	local v5 = k
	local v6 = gamepass
	pack.Buy.Activated:Connect(function()
		if id or localPlayer:GetAttribute("Pass_" .. v5) or v5 == "VIP" and localPlayer:GetAttribute("VIPGiftsReady") ~= true then
			return
		end

		id = v6.id

		if not pcall(MarketplaceService.PromptGamePassPurchase, MarketplaceService, localPlayer, v6.id) then
			id = nil
			panel.Status.Text = "Could not open the purchase prompt. Try again."
		end
	end)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if p ~= localPlayer or p2 ~= id then
		return
	end

	id = nil
	panel.Status.Text = p3 and "Purchase complete. Your perks are unlocking." or "Purchase cancelled. You can try again."
end)