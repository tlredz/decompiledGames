local Floor0Shop = {
	ShopItems = {
		Bandage = {
			name = "Bandage",
			description = "Heals 1 Heart",
			icon = "rbxassetid://129516341286149",
			ichorCost = 50,
			tokenCost = 1,
			itemName = "Bandage"
		},
		HealthKit = {
			name = "Health Kit",
			description = "Heals Full Hearts",
			icon = "rbxassetid://106564675500154",
			ichorCost = 100,
			tokenCost = 2,
			itemName = "HealthKit"
		},
		Valve = {
			name = "Valve",
			description = "Instantly Completes a Machine",
			icon = "rbxassetid://104533444523870",
			ichorCost = 200,
			tokenCost = 4,
			itemName = "Valve"
		},
		Band = {
			name = "Bandage",
			description = "Heals 1 Heart",
			icon = "rbxassetid://129516341286149",
			ichorCost = 50,
			tokenCost = 1,
			itemName = "Bandage"
		},
		Medkit = {
			name = "Health Kit",
			description = "Heals Full Hearts",
			icon = "rbxassetid://106564675500154",
			ichorCost = 100,
			tokenCost = 2,
			itemName = "HealthKit"
		}
	}
}

function Floor0Shop.GetShopData()
	return Floor0Shop.ShopItems
end

function Floor0Shop.CanPlayerAfford(p, p2, p3)
	local child = game.ReplicatedStorage.PlayerData:FindFirstChild((tostring(p.UserId)))

	if not child then
		return false
	end

	local shopItem = Floor0Shop.ShopItems[p2]

	if not shopItem then
		return false
	end

	if p3 == "Ichor" then
		local coin = child:FindFirstChild("Coin")
		return coin and coin.Value >= shopItem.ichorCost
	end

	return p3 == "Tokens" and (child:GetAttribute("Tokens") or 0) >= shopItem.tokenCost
end

function Floor0Shop:UpdateTeamFrameReady(p2)
	if not self then
		return
	end

	if p2 then
		self.BackgroundColor3 = Color3.fromRGB(0, 255, 60)
	else
		self.BackgroundColor3 = Color3.fromRGB(121, 121, 121)
	end
end

function Floor0Shop.SetupToggleButtons(p)
	local margin = p.Parent:FindFirstChild("Margin")

	if not margin then
		warn("[Floor0Shop] Margin frame not found for toggle buttons")
		return
	end

	local catalogFrame = margin:FindFirstChild("CatalogFrame")

	if not catalogFrame then
		warn("[Floor0Shop] CatalogFrame not found for toggle buttons")
		return
	end

	local toons = catalogFrame:FindFirstChild("Toons")
	local trinkets = catalogFrame:FindFirstChild("Trinkets")

	if not (toons and trinkets) then
		warn("[Floor0Shop] Toons or Trinkets frame not found")
		return
	end

	local toTrinkets = toons:FindFirstChild("ToTrinkets")
	local toToons = trinkets:FindFirstChild("ToToons")
	toons.Visible = true
	trinkets.Visible = false

	if toTrinkets then
		toTrinkets.Activated:Connect(function()
			toons.Visible = false
			trinkets.Visible = true
		end)
	else
		warn("[Floor0Shop] ToTrinkets button not found")
	end

	if toToons then
		toToons.Activated:Connect(function()
			trinkets.Visible = false
			toons.Visible = true
		end)
	else
		warn("[Floor0Shop] ToToons button not found")
	end
end

return Floor0Shop