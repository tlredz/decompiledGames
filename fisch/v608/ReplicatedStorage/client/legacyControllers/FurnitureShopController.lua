local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PolicyService = game:GetService("PolicyService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local packages = ReplicatedStorage.packages
local Monetization = require(ReplicatedStorage.shared.Monetization)
local personalAquariumFurniture = require(ReplicatedStorage.shared.modules.library.personalAquariumFurniture)
local ViewOddsController = require(legacyControllers.ViewOddsController)
local HudController = require(legacyControllers.HudController)
local Net = require(packages.Net)
local localPlayer = game.Players.LocalPlayer
local furnitureShop = HudController:GetSafeZone().FurnitureShop
local remoteEvent = Net:RemoteEvent("FurnitureShop/Open")
local remoteEvent2 = Net:RemoteEvent("FurnitureShop/ReplicateItems")
local remoteEvent3 = Net:RemoteEvent("FurnitureShop/Purchase")
local remoteEvent4 = Net:RemoteEvent("FurnitureShop/Refresh")

local function comma_value(price)
	local v = math.ceil(price)

	repeat
		local v2
		v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

local function formatTime(p)
	local v = math.floor(p / 3600)
	local v2 = math.floor(p % 3600 / 60)
	local v3 = p % 60
	local v4 = ""

	if v > 0 then
		v4 ..= v .. "h "
	end

	if v2 > 0 then
		v4 ..= v2 .. "m "
	end

	if v3 > 0 or v4 == "" then
		return v4 .. v3 .. "s"
	end

	return v4
end

local FurnitureShopController = {}
local v = {}
local nextRefresh = nil

function FurnitureShopController:Toggle(visible: boolean?)
	if visible == nil then
		visible = not furnitureShop.Visible
	end

	if visible == furnitureShop.Visible then
		return
	end

	furnitureShop.Visible = visible
end

function FurnitureShopController.Start(_)
	remoteEvent.OnClientEvent:Connect(function(...)
		FurnitureShopController:Toggle(...)
	end)
	furnitureShop.Close.Activated:Connect(function()
		FurnitureShopController:Toggle(false)
	end)
	furnitureShop["RefreshC$"].MouseButton1Click:Connect(function()
		if PolicyService:GetPolicyInfoForPlayerAsync(localPlayer).ArePaidRandomItemsRestricted then
			local promptConfirmOdds = ViewOddsController.PromptConfirmOdds("furnitureShop")
			furnitureShop.Visible = true

			if not promptConfirmOdds then
				return
			end
		end

		remoteEvent4:FireServer()
	end)
	furnitureShop.RefreshPaid.Label.Text = `{Monetization:GetRobuxPrice(Monetization.products.Others.RefreshFurnitureShop.ProductId, false)}`
	furnitureShop.RefreshPaid.MouseButton1Click:Connect(function()
		if ViewOddsController.IsLoading then
			return
		end

		if ViewOddsController.PromptConfirmOdds("furnitureShop") then
			remoteEvent4:FireServer("Paid")
		end

		furnitureShop.Visible = true
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateRefreshPaidVisibility()
		furnitureShop.RefreshPaid.Visible = localPlayer:GetAttribute("PolicyPaidRandomItemsRestricted") ~= true
	end

	updateRefreshPaidVisibility() -- equivalent call inferred; original call site unknown
	localPlayer:GetAttributeChangedSignal("PolicyPaidRandomItemsRestricted"):Connect(updateRefreshPaidVisibility)
	furnitureShop.viewChances.Activated:Connect(function()
		ViewOddsController.ShowOdds("furnitureShop")
	end)

	local function updateRefreshLabel()
		if not nextRefresh or nextRefresh - DateTime.now().UnixTimestamp < 0 then
			return
		end

		local label = furnitureShop.Header.Refresh.Label
		local v3 = nextRefresh - DateTime.now().UnixTimestamp
		local v4 = math.floor(v3 / 3600)
		local v5 = math.floor(v3 % 3600 / 60)
		local v6 = v3 % 60
		local v7 = ""

		if v4 > 0 then
			v7 ..= v4 .. "h "
		end

		if v5 > 0 then
			v7 ..= v5 .. "m "
		end

		if v6 > 0 or v7 == "" then
			v7 ..= v6 .. "s"
		end

		label.Text = `Refreshing in {v7}`
	end

	task.spawn(function()
		while true do
			if nextRefresh then
				updateRefreshLabel()
			end

			task.wait(1)
		end
	end)
	local list = furnitureShop.List
	local sample = list:WaitForChild("Sample")
	remoteEvent2.OnClientEvent:Connect(function(p, p2)
		local v2 = v
		v = p2
		furnitureShop["RefreshC$"].Rerolls.Text = p.Rerolls["C$"]
		furnitureShop.RefreshPaid.Rerolls.Text = p.Rerolls.Paid
		nextRefresh = p.NextRefresh
		updateRefreshLabel()
		local v3 = {}

		for k in v2 do
			if not v[k] then
				v3[k] = true
			end
		end

		for _, child in list:GetChildren() do
			if v3[child.Name] then
				child:Destroy()
			end
		end

		for childName, v4 in v do
			for displayName, v5 in v4 do
				local clone

				if v2[childName] then
					clone = list:FindFirstChild(childName)
				else
					clone = sample:Clone()
					clone.Name = childName
					clone.Parent = list
					local v6 = childName
					clone.BuyButton.MouseButton1Click:Connect(function()
						remoteEvent3:FireServer(v6)
					end)
				end

				if not clone then
					continue
				end

				local v6 = personalAquariumFurniture[displayName]

				if v6 then
					displayName = v6.DisplayName or displayName
				end

				local icon = v6 and v6.Icon or ""
				clone.Label.Text = displayName
				clone.Amount.Text = not (v5.amount > 1) and "" or `x{v5.amount}`
				clone.BuyButton.Label.Text = `C${comma_value(v5.price)}`
				clone.ImageLabel.Image = icon
				clone.ImageLabel.Visible = icon ~= ""
				clone.NoImage.Visible = icon == ""
				clone.SoldOut.Visible = v5.amount <= 0
				clone.Visible = true
			end
		end
	end)
end

return FurnitureShopController