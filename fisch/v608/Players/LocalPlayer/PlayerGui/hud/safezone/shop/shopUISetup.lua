local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local events = ReplicatedStorage.events
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local resources = ReplicatedStorage.resources
local shared = ReplicatedStorage.shared
local modules = shared.modules
local Monetization = require(shared.Monetization)
local Net = require(packages.Net)
local Replion = require(packages.Replion)
local Timer = require(packages.Timer)
require(packages.ViewportModel)
local BundleController = require(legacyControllers.Shop.BundleController)
local CurrencyController = require(legacyControllers.CurrencyController)
local GiftController = require(legacyControllers.Shop.GiftController)
local VisualizerController = require(legacyControllers.Shop.VisualizerController)
local HudController = require(legacyControllers.HudController)
local ShowroomController = require(legacyControllers.Shop.ShowroomController)
local GeneralUtils = require(shared.utils.GeneralUtils)
local assets = require(shared.utils.assets)
local library = modules.library
local RodSkins = require(modules.RodSkins)
local vessels = require(modules.vessels)
local lanterns = require(library.lanterns)
local halos = require(library.halos)
local items = require(ReplicatedStorage.shared.modules.library.items)
local randomPaidItems = require(library.randomPaidItems)
local Bundles = require(modules.Bundles)
local debris = require(modules.fx.debris)
local fx = require(modules.fx)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local vessels2 = require(modules.vessels)
local v = Timer.new(1)
local client = Replion.Client
local fetched = legacyLocalPlayerData.fetch()
local parent = script.Parent
local shopNEW = parent.Parent.shopNEW
local main = parent.Products.Views.Main

local function addCommas(p: number)
	local v2 = p >= 0
	local v3 = tostring((math.abs(p)))
	local v4 = v3:find("(%.%d+)$")
	local v5 = not v4 and "" or v3:sub(v4) or ""

	if v4 then
		v3 = v3:sub(1, v4 - 1)
	end

	return (v2 and "" or "-") .. v3:reverse():gsub("(%d%d%d)", "%1,"):gsub(",$", ""):reverse() .. v5
end

local v2 = ""

-- equivalent calls inferred from this helper; original call sites unknown
local function OpenPage(name: string)
	v2 = name
	main.CanvasPosition = Vector2.new(0, main[name].AbsolutePosition.Y - main.Featured.AbsolutePosition.Y)
end

for _, button in parent.Categories:GetChildren() do
	if not button:IsA("GuiButton") then
		continue
	end

	local v3 = button
	button.Activated:Connect(function()
		OpenPage(v3.Name) -- equivalent call inferred; original call site unknown
	end)
end

OpenPage("Limiteds") -- equivalent call inferred; original call site unknown
ReplicatedStorage:WaitForChild("events"):WaitForChild("thelimited_salesperson").OnClientEvent:Connect(function()
	script.Parent.Parent.SkinsPopup.Visible = true
end)
script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	script.Parent.Products.Views.Main.CanvasPosition = Vector2.new(0, 0)
end)
local gamepasses = fetched:WaitForChild("Gamepasses")

local function BuyVFX()
	fx:PlaySound(resources.sounds.sfx.ui.purchase, parent, true)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "PurchasedCC"
	colorCorrectionEffect.Parent = Lighting
	colorCorrectionEffect.TintColor = Color3.fromRGB(202, 255, 183)
	GeneralUtils.fastTween(
		colorCorrectionEffect,
		TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			TintColor = Color3.fromRGB(255, 255, 255)
		}
	)
	debris:AddItem(colorCorrectionEffect, 2)
end

local v3 = {}

local function ConstructGamepass(gamepassId: number, priority: number)
	local _, v4 = Monetization:GetProductDataById(gamepassId, true)

	if not v4 then
		return
	end

	local v5 = v4.AssetId ~= nil
	local v6 = false

	if v5 then
		pcall(function()
			v6 = MarketplaceService:PlayerOwnsAsset(localPlayer, v4.AssetId)
		end)
	else
		pcall(function()
			v6 = MarketplaceService:UserOwnsGamePassAsync(localPlayer.UserId, gamepassId)
		end)
	end

	local productInfo = Monetization:GetProductInfo(gamepassId, true)

	if not productInfo then
		return
	end

	local function createTemplate(parent2)
		local clone = script:WaitForChild("GamepassTemplate"):Clone()
		clone.Name = productInfo.Name

		if v4.Description then
		end

		clone.Description.Text = v4.Description

		if not v3[gamepassId] then
			v3[gamepassId] = {}
		end

		table.insert(v3[gamepassId], clone)
		clone.LayoutOrder = priority
		clone.Title.Text = productInfo.Name

		if v5 and v4.DisplayName then
			clone.Title.Text = v4.DisplayName
		end

		local robuxPrice = Monetization:GetRobuxPrice(gamepassId, true)

		if robuxPrice then
			clone.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
		else
			clone.BuyButton.Text = "Not On Sale"
		end

		clone.Icon.Image = "rbxassetid://" .. productInfo.IconImageAssetId

		if v5 and v4.Icon then
			clone.Icon.Image = v4.Icon
		end

		clone.Parent = parent2

		if v4.Color then
			clone.stroke.Color = v4.Color
			clone.corner.ImageColor3 = v4.Color
			local HSV, v7, v8 = v4.Color:ToHSV()
			clone.BackgroundColor3 = Color3.fromHSV(HSV, v7, v8 / 8)
		end

		if not v5 and gamepasses:FindFirstChild((tostring(gamepassId))) then
			v6 = true
		end

		if v6 then
			clone.BuyButton.Text = "Owned"
			return
		end

		clone.BuyButton.Activated:Connect(function()
			if v5 then
				MarketplaceService:PromptPurchase(localPlayer, v4.AssetId)
			elseif not gamepasses:FindFirstChild((tostring(gamepassId))) then
				Monetization.BuyProduct:FireServer(gamepassId, true)
			end
		end)

		if v5 then
			MarketplaceService.PromptPurchaseFinished:Connect(function(_, p, p2)
				if p ~= v4.AssetId or not p2 then
					return
				end

				v6 = true
				clone.BuyButton.Text = "Owned"
				BuyVFX()
			end)
		else
			MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2: number, flag: boolean)
				if not p or p2 ~= gamepassId or not flag then
					return
				end

				v6 = true
				clone.BuyButton.Text = "Owned"
				BuyVFX()
				events:WaitForChild("gamepasspurchased"):FireServer(productInfo)
			end)
		end
	end

	createTemplate(main.Gamepasses)
	createTemplate(shopNEW.Container.List.Gamepasses.Container)
end

function ConstructGamepassGifting()
	for k, v4 in pairs(v3) do
		for _, v5 in v4 do
			local v6 = k
			local v7 = v5
			task.spawn(function()
				for k2, gamepassesGift in Monetization.products.GamepassesGifts do
					if gamepassesGift.Gamepass ~= v6 then
						continue
					end

					v7.Gift.Visible = true
					local productDataById, v8 = Monetization:GetProductDataById(v6, true)

					if not (v8 and v8.AssetId) and gamepasses:FindFirstChild((tostring(v6))) then
						v7.BuyButton.Text = "Owned"
					end

					local v9 = gamepassesGift
					v7.Gift.MouseButton1Click:Connect(function()
						if not GiftController.isGifting then
							GiftController:PromptGift(v9.ProductId, nil, nil, nil, (tonumber(v6)))
						end
					end)
				end
			end)
		end
	end

	gamepasses.ChildAdded:Connect(function(child)
		local name = tonumber(child.Name)

		if not Monetization:GetProductGiftFromGamepass(name) then
			return
		end

		local _, v4 = Monetization:GetProductDataById(name, true)

		if v4 and v4.AssetId then
			return
		end

		local v5 = v3[name]

		if not v5 then
			return
		end

		for _, v6 in v5 do
			if not Monetization:GetProductInfo(name, true) then
				continue
			end

			v6.BuyButton.Text = "Owned"
			BuyVFX()
		end
	end)
	gamepasses.ChildRemoved:Connect(function(child)
		local name = tonumber(child.Name)

		if not Monetization:GetProductGiftFromGamepass(name) then
			return
		end

		local _, v4 = Monetization:GetProductDataById(name, true)

		if v4 and v4.AssetId then
			return
		end

		local v5 = v3[name]

		if not v5 then
			return
		end

		local v6 = false
		local _, _ = pcall(function()
			v6 = MarketplaceService:UserOwnsGamePassAsync(localPlayer.UserId, name)
		end)
		local robuxPrice = Monetization:GetRobuxPrice(name, true)

		if robuxPrice and not v6 then
			for _, v7 in v5 do
				v7.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
			end
		end
	end)
end

local v4 = {
	[1] = "2xLuck",
	[2] = "4xLuck",
	[4] = "8xLuck"
}
local _ = {
	[2] = "2xLuck",
	[4] = "4xLuck",
	[8] = "8xLuck"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isPaidRandomItemsRestricted()
	return localPlayer:GetAttribute("PolicyPaidRandomItemsRestricted") == true
end

local function reconnectLuckTimerAndProduct()
	local template = main.Featured.Template
	local luckMultiplier = shopNEW.Container.List.LuckMultiplier
	local activatedConnection = nil
	local connection = nil
	local activatedConnection2 = nil
	local connection2 = nil
	local v5 = {}
	local v6 = {}
	local world = ReplicatedStorage:WaitForChild("world")
	local luck_Server = world:WaitForChild("luck_Server")
	local luck_ServerCountdown = world:WaitForChild("luck_ServerCountdown")

	local function redoLuckBoost()
		local paidRandomItemsRestricted = isPaidRandomItemsRestricted() -- equivalent call inferred; original call site unknown

		for _, guiObject in template:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Name ~= "VideoAd" then
				guiObject.Visible = not paidRandomItemsRestricted
			end
		end

		template.BackgroundTransparency = paidRandomItemsRestricted and 1 or 0.2
		local stroke = template:FindFirstChild("stroke")

		if stroke then
			stroke.Enabled = not paidRandomItemsRestricted
		end

		luckMultiplier.Visible = not paidRandomItemsRestricted
		local value = luck_Server.Value
		local v7 = Monetization.products.Luck[v4[value]]
		local robuxPrice = Monetization:GetRobuxPrice(v7.ProductId)

		if activatedConnection then
			activatedConnection:Disconnect()
			activatedConnection = nil
		end

		if activatedConnection2 then
			activatedConnection2:Disconnect()
			activatedConnection2 = nil
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end

		if connection2 then
			connection2:Disconnect()
			connection2 = nil
		end

		if v5 then
			for _, connection3 in pairs(v5) do
				connection3:Disconnect()
			end
		end

		if v6 then
			for _, connection3 in pairs(v6) do
				connection3:Disconnect()
			end
		end

		local function applyToFrame(data)
			data.Available.Visible = not paidRandomItemsRestricted and value ~= 8
			data.MaxedOut.Visible = not paidRandomItemsRestricted and value == 8
			data.BuyButton.Text = value == 8 and "Maxed" or data.BuyButton.Text
			data.ButtonsWithExtension.Visible = not paidRandomItemsRestricted and v7 and v7.Extensions

			if v7 and v7.Extensions then
				for k, extension in pairs(v7.Extensions) do
					local robuxPrice2 = Monetization:GetRobuxPrice(extension)

					if robuxPrice2 then
						data.ButtonsWithExtension.List[k].Text = utf8.char(57346) .. tostring(robuxPrice2)
					end

					if data.ButtonsWithExtension.List[k]:FindFirstChild("Discount") then
						data.ButtonsWithExtension.List[k].Discount.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2"><font color="rgb(255, 0, 0)"><s>{v7.Discount}</s></font></stroke>`
					end

					local v8 = extension
					table.insert(
						data == template and v5 or v6,
						data.ButtonsWithExtension.List[k].Activated:Connect(function()
							Monetization.BuyProduct:FireServer(v8)
						end)
					)
				end
			end

			if value == 8 then
				return
			end

			if robuxPrice then
				data.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
			end

			data.Available["1"].Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2">{value}<font color="rgb(56, 232, 57)"></font></stroke>` .. "x"
			data.Available["2"].Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2"><font color="rgb(56, 232, 57)">{v7.SetLuckAt}</font></stroke>` .. "x"
		end

		applyToFrame(template)
		applyToFrame(luckMultiplier)
		activatedConnection = template.BuyButton.Activated:Connect(function()
			Monetization.BuyProduct:FireServer(v7.ProductId)
		end)
		activatedConnection2 = luckMultiplier.BuyButton.Activated:Connect(function()
			Monetization.BuyProduct:FireServer(v7.ProductId)
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function formatTime(value: number)
		local v7 = math.floor(value / 60)
		local v8 = value % 60
		return string.format("%i:%02i", v7, v8)
	end

	local function redoLuckTimer()
		local value = luck_ServerCountdown.Value
		local v7 = formatTime(value) -- equivalent call inferred; original call site unknown
		template.ExpiresIn.Text = not (value > 0) and "<font color=\"rgb(255, 0, 0)\">15 mins</font>" or `<stroke color="rgb(0,0,0)" joins="round" thickness="2"><font color="rgb(255, 0, 0)">{v7}</font></stroke>` or "<font color=\"rgb(255, 0, 0)\">15 mins</font>"
		luckMultiplier.ExpiresIn.Text = value > 0 and `<stroke color="rgb(0,0,0)" joins="round" thickness="2"><font color="rgb(255, 0, 0)">{v7}</font></stroke>` or "<font color=\"rgb(255, 0, 0)\">15 mins</font>"
	end

	MarketplaceService.PromptProductPurchaseFinished:Connect(function(p: number, p2: number, flag: boolean)
		if localPlayer.UserId ~= p or not flag then
			return
		end

		for _, v7 in pairs(Monetization.products.Luck) do
			if p2 == v7.ProductId then
				BuyVFX()
			end
		end
	end)
	pcall(redoLuckBoost)
	luck_Server.Changed:Connect(redoLuckBoost)
	pcall(redoLuckTimer)
	luck_ServerCountdown.Changed:Connect(redoLuckTimer)
	localPlayer:GetAttributeChangedSignal("PolicyPaidRandomItemsRestricted"):Connect(function()
		pcall(redoLuckBoost)
	end)
end

reconnectLuckTimerAndProduct()
local bobbers = require(ReplicatedStorage.shared.modules.fishing.bobbers)
local limitedBobbers = Monetization.products.LimitedBobbers

-- equivalent calls inferred from this helper; original call sites unknown
local function IsLimitedBobbersEnabled()
	local serverTimeNow = workspace:GetServerTimeNow()
	local enabled = limitedBobbers.Enabled

	if enabled then
		if limitedBobbers.TimeRange.Min < serverTimeNow then
			enabled = serverTimeNow < limitedBobbers.TimeRange.Max
		else
			enabled = false
		end
	end

	return enabled, serverTimeNow
end

v.Tick:Connect(function()
	local visible, _ = IsLimitedBobbersEnabled() -- equivalent call inferred; original call site unknown
	local v6 = limitedBobbers.TimeRange.Max - workspace:GetServerTimeNow()
	local v7 = math.floor(v6 / 3600) % 24
	local v8 = math.floor(v6 / 86400)
	main.Limiteds.Timer.Label.Text = `Leaving in {v8}d {v7}h!`
	main.Limiteds.Visible = visible
end)
v:Start()

local function SetupFeaturedBoat()
	local featuredVesselData, v5 = Monetization:GetFeaturedVesselData()

	if not (featuredVesselData and v5) then
		return
	end

	local boats = fetched:WaitForChild("Boats")

	if not boats then
		return
	end

	local vessel = main.Featured.LimitedStock:FindFirstChild("Vessel")

	if not vessel then
		return
	end

	local v6 = client:WaitReplion("LimitedStockItems")

	local function OnButtonClick(p: string)
		if boats:FindFirstChild(featuredVesselData) and p == "Buy" or v6:GetExpect({ "Stocks", featuredVesselData }) <= 0 then
			return
		end

		if p == "Buy" then
			Monetization.BuyProduct:FireServer(v5.ProductId)
		else
			GiftController:PromptGift(
				v5.ProductId,
				featuredVesselData,
				vessels2.library[featuredVesselData].Description,
				vessels2.library[featuredVesselData].Icon
			)
		end
	end

	local function UpdateVisuals()
		local expect = v6:GetExpect({ "Stocks", featuredVesselData })
		local buyButton = vessel.BuyButton

		if expect <= 0 then
			buyButton.Text = "EXPIRED"
		else
			local boats2 = fetched:WaitForChild("Boats")

			if not boats2 then
				return
			end

			local child = boats2:FindFirstChild(featuredVesselData)
			local robuxPrice = Monetization:GetRobuxPrice(v5.ProductId)

			if robuxPrice then
				buyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
			end

			if child then
				buyButton.Text = "OWNED"
			end
		end

		vessel.Amount.Text = `{expect} / {15000} Left`
	end

	local buyButton = vessel.BuyButton
	local gift = vessel.Gift
	buyButton.Activated:Connect(function()
		if boats:FindFirstChild(featuredVesselData) or v6:GetExpect({ "Stocks", featuredVesselData }) <= 0 then
			return
		end

		Monetization.BuyProduct:FireServer(v5.ProductId)
	end)
	gift.Activated:Connect(function()
		OnButtonClick("Gift")
	end)
	UpdateVisuals()
	v6:OnChange({ "Stocks", featuredVesselData }, function()
		UpdateVisuals()
	end)
	boats.ChildAdded:Connect(function(child)
		if child.Name == featuredVesselData then
			UpdateVisuals()
		end
	end)
end

SetupFeaturedBoat()
local bundle = main.Limiteds.Products.Bundle
local limitedBobbers2 = shopNEW.Container.List.LimitedBobbers
bundle.BuyButton.Activated:Connect(function()
	if not (bundle:FindFirstChild("BuyButton") and bundle.BuyButton.Text ~= "Owned") then
		return
	end

	Monetization.BuyProduct:FireServer(limitedBobbers.Bobbers.Bundle.ProductId)
end)
bundle.View.Activated:Connect(function()
	ShowroomController:ShowBundle(bundle.Title.Text)
end)
limitedBobbers2.BuyButton.Activated:Connect(function()
	local buyButton = limitedBobbers2:FindFirstChild("BuyButton")

	if not (buyButton and buyButton.Text ~= "Owned") then
		return
	end

	Monetization.BuyProduct:FireServer(limitedBobbers.Bobbers.Bundle.ProductId)
end)
local v5 = {}
local contains = {}

for k in Monetization.products.LimitedBobbers.Bobbers do
	if k == "Bundle" then
		continue
	end

	table.insert(v5, k)
	local _ = bobbers.Bobbers[k] and bobbers.Bobbers[k].Icon
	table.insert(contains, {
		Name = k,
		Icon = not bobbers.Bobbers[k] and "" or bobbers.Bobbers[k].Icon or "",
		Type = "Bobber"
	})
end

ShowroomController:AddBundle({
	Name = bundle.Title.Text,
	ProductId = limitedBobbers.Bobbers.Bundle.ProductId,
	Order = 6,
	Contains = contains
}, bundle)
bundle.Gift.Activated:Connect(function()
	if not GiftController.isGifting then
		GiftController:PromptGift(
			limitedBobbers.Bobbers.Bundle.ProductId,
			"Fischer's Bobbler Bundle",
			`Contains: {table.concat(v5, ", ")}`,
			nil,
			nil,
			"Bundle",
			"Fischers Bobbler Bundle"
		)
	end
end)
limitedBobbers2.Gift.Activated:Connect(function()
	if not GiftController.isGifting then
		GiftController:PromptGift(
			limitedBobbers.Bobbers.Bundle.ProductId,
			"Fischer's Bobbler Bundle",
			`Contains: {table.concat(v5, ", ")}`,
			nil,
			nil,
			"Bundle",
			"Fischers Bobbler Bundle"
		)
	end
end)

local function SetupVessels()
	local v7 = client:WaitReplion("LimitedStockItems")
	local limitedStock = main:WaitForChild("Featured"):WaitForChild("LimitedStock")
	local v8 = {}
	local v9 = {}

	for k, v10 in vessels2.library do
		if v10.LimitedAmount then
			table.insert(v8, k)
		end
	end

	for k, v10 in vessels2.library do
		if not v10.ExpirationDate or table.find(v8, k) then
			continue
		end

		table.insert(v8, k)
	end

	local function updateSortListPrice()
		for _, v10 in v8 do
			local robuxPrice = Monetization:GetRobuxPrice(Monetization.products.Vessels.vessels[v10].ProductId)

			if robuxPrice then
				v9[v10] = utf8.char(57346) .. tostring(robuxPrice)
			else
				v9[v10] = "???"
			end
		end
	end

	updateSortListPrice()
	local v10 = nil

	local function VesselButtonClick(childName: string, flag: boolean?)
		local serverTimeNow = workspace:GetServerTimeNow()
		local v11 = vessels2.library[childName]

		if not v11 or v11.ExpirationDate and v11.ExpirationDate.UnixTimestamp - serverTimeNow <= 0 or v11.LimitedAmount and v7:GetExpect({
			"Stocks",
			childName
		}) <= 0 or not v11.ProductId then
			return
		end

		if flag == true then
			GiftController:PromptGift(v11.ProductId, childName, v11.Description, v11.Icon)
			return
		end

		local boats = fetched:FindFirstChild("Boats")

		if not boats or boats:FindFirstChild(childName) then
			return
		end

		Monetization.BuyProduct:FireServer(v11.ProductId)
	end

	local function UpdateVesselsFrame()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v11 = serverTimeNow / 60 % 60

		if v11 % 5 == 0 and v11 ~= v10 then
			v10 = v11
			task.spawn(function()
				updateSortListPrice()
			end)
		end

		local boats = fetched:FindFirstChild("Boats")

		if not boats then
			return
		end

		for i = 1, #v8 do
			local v12 = v8[i]
			local v13 = vessels2.library[v12]
			local child = limitedStock:FindFirstChild(v12)

			if not child then
				continue
			end

			if child and child:GetAttribute("Setupped") ~= true then
				child:SetAttribute("Setupped", true)
				local v14 = v12
				child:WaitForChild("BuyButton").Activated:Connect(function()
					VesselButtonClick(v14)
				end)
				local v15 = v12
				child:WaitForChild("Gift").Activated:Connect(function()
					VesselButtonClick(v15, true)
				end)
			end

			local v14

			if v13.LimitedAmount then
				local expect = v7:GetExpect({ "Stocks", v12 })
				child.Amount.Text = `{expect} / {v13.LimitedAmount}`
				v14 = expect > 0
			else
				v14 = true
			end

			if v14 == true and v13.ExpirationDate ~= nil then
				local v15 = v13.ExpirationDate.UnixTimestamp - serverTimeNow

				if v15 > 0 then
					local universalTime = DateTime.fromUnixTimestamp(v15):ToUniversalTime()
					local day = universalTime.Day
					local hour = universalTime.Hour
					local minute = universalTime.Minute
					local second = universalTime.Second
					local v16 = ""

					if day and day > 0 then
						v16 ..= `{day}d`
					end

					if day > 0 or hour > 0 then
						v16 ..= `{day > 0 and " " or ""}{hour}h`
					end

					if minute > 0 or hour > 0 then
						v16 ..= `{hour > 0 and " " or ""}{minute}m`
					end

					if second > 0 or minute > 0 then
						v16 ..= `{minute > 0 and " " or ""}{second}s`
					end
				else
					v14 = false
				end
			end

			if v14 == true then
				local buyButton = child:WaitForChild("BuyButton")
				local child2 = boats:FindFirstChild(v12)
				buyButton.Text = utf8.char(57346) .. tostring(v9[v12])

				if child2 then
					buyButton.Text = "OWNED"
				end
			else
				local buyButton_2 = child:WaitForChild("BuyButton")
				buyButton_2.Text = "EXPIRED"
			end
		end
	end

	local v11 = Timer.new(1)
	v11.Tick:Connect(function()
		UpdateVesselsFrame()
	end)
	v11:StartNow()
end

local function SetupBundleFrames()
	fetched:WaitForChild("Cache"):WaitForChild("Bundles")

	for _, frame in CollectionService:GetTagged("BundleViewer") do
		if not frame:IsA("Frame") then
			continue
		end

		local bundle2 = Bundles[frame.Name]

		if not bundle2 then
			continue
		end

		if bundle2.FakePrice and frame:FindFirstChild("DiscountOff") then
			frame.DiscountOff.Text = "R$ " .. bundle2.FakePrice
		end

		for _ = 1, 5 do
			local bundle3 = Monetization.products.Bundles.bundles[frame.Name]
			local robuxPrice = bundle3 and Monetization:GetRobuxPrice(bundle3.ProductId)

			if robuxPrice then
				if not frame:FindFirstChild("BuyButton") then
					break
				end

				frame.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
				break
			else
				task.wait(5)
			end
		end

		local activatedConnection = nil
		local activatedConnection2

		if frame:FindFirstChild("BuyButton") then
			local v7 = bundle2
			activatedConnection2 = frame.BuyButton.Activated:Connect(function()
				Monetization.BuyProduct:FireServer(v7.ProductId)
			end)
		else
			activatedConnection2 = nil
		end

		if frame:FindFirstChild("View") then
			local v7 = frame
			frame.View.Activated:Connect(function()
				ShowroomController:ShowBundle(v7.Name)
			end)
		end

		if frame:FindFirstChild("Gift") then
			local v7 = bundle2
			activatedConnection = frame.Gift.Activated:Connect(function()
				local v8 = {}

				for k, reward in v7.Rewards do
					table.insert(v8, (`{reward.Value} ({reward.Type})`))
				end

				GiftController:PromptGift(v7.ProductId, nil, (`Contains: {table.concat(v8, ", ")}`))
			end)
		end

		if BundleController:RequestState(frame.Name) == true then
			local v7 = frame
			BundleController.OnBundleDisabled:Connect(function(p: string)
				if p == v7.Name then
					if activatedConnection2 then
						activatedConnection2:Disconnect()
						activatedConnection2 = nil
					end

					if activatedConnection then
						activatedConnection:Disconnect()
						activatedConnection = nil
					end

					if v7:FindFirstChild("BuyButton") then
						v7.BuyButton.Text = "Off Sale"
						v7.BuyButton.TextColor3 = Color3.fromRGB(74, 74, 74)
						local border = v7.BuyButton:WaitForChild("border")
						border.Color = Color3.fromRGB(74, 74, 74)
						local corner = v7.BuyButton:WaitForChild("corner")
						corner.ImageColor3 = Color3.fromRGB(74, 74, 74)
					end
				end
			end)
		else
			if activatedConnection2 then
				activatedConnection2:Disconnect()
				activatedConnection2 = nil
			end

			if activatedConnection then
				activatedConnection:Disconnect()
				activatedConnection = nil
			end

			if frame:FindFirstChild("BuyButton") then
				frame.BuyButton.Text = "Off Sale"
				frame.BuyButton.TextColor3 = Color3.fromRGB(74, 74, 74)
				local border = frame.BuyButton:WaitForChild("border")
				border.Color = Color3.fromRGB(74, 74, 74)
				local corner = frame.BuyButton:WaitForChild("corner")
				corner.ImageColor3 = Color3.fromRGB(74, 74, 74)
			end
		end

		local shopNEW2 = HudController:GetSafeZone():FindFirstChild("shopNEW")
		local contains2 = {}

		for _, reward in bundle2.Rewards do
			local name = reward.Value
			local type = reward.Type
			local icon = ""

			if type == "Ship" then
				icon = vessels.library[name].Icon
				type = "Boat"
			elseif type == "Lantern" then
				icon = lanterns[name].Icon
			elseif type == "Bobber" then
				icon = not bobbers.Bobbers[name] and "" or bobbers.Bobbers[name].Icon or ""
			elseif type == "Halo" then
				icon = halos[name].Icon
			elseif type == "Item" then
				icon = not items.Items[name] and "" or items.Items[name].Icon or ""
			elseif type == "RodSkin" then
				icon = not RodSkins.Skins[name] and "" or RodSkins.Skins[name].Icon or ""
			end

			table.insert(contains2, {
				Name = name,
				Icon = icon,
				Type = type,
				ShowcaseOffset = reward.ShowcaseOffset
			})
		end

		if not (shopNEW2 and frame:IsDescendantOf(shopNEW2)) then
			ShowroomController:AddBundle({
				Name = frame.Name,
				ProductId = bundle2.ProductId,
				IsBundle = true,
				Order = 1,
				Contains = contains2
			}, frame)
		end
	end
end

SetupBundleFrames()

if limitedBobbers.Bobbers.Bundle.PurchaseCoins then
	bundle.CoinsBuyButton.Text = `{CurrencyController:GetDisplay()}{addCommas(limitedBobbers.Bobbers.Bundle.PurchaseCoins)}`
	bundle.CoinsBuyButton.Activated:Connect(function()
		Net:Invoke("LimitedBobbers.BuyBundleWithCoins")
	end)
	limitedBobbers2.CoinsBuyButton.Text = `{CurrencyController:GetDisplay()}{addCommas(limitedBobbers.Bobbers.Bundle.PurchaseCoins)}`
	limitedBobbers2.CoinsBuyButton.Activated:Connect(function()
		Net:Invoke("LimitedBobbers.BuyBundleWithCoins")
	end)
end

task.spawn(function()
	local robuxPrice = Monetization:GetRobuxPrice(limitedBobbers.Bobbers.Bundle.ProductId)

	if robuxPrice then
		bundle.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
		limitedBobbers2.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
	end

	MarketplaceService:GetProductInfo(limitedBobbers.Bobbers.Bundle.ProductId, Enum.InfoType.Product)
end)

for childName, bobber in limitedBobbers.Bobbers do
	if childName == "Bundle" then
		continue
	end

	local child = main.Limiteds.Products:FindFirstChild(childName)

	if not child then
		continue
	end

	local bobber2 = bobbers.Bobbers[childName]
	child.Title.Text = childName:upper()
	child.Icon.Img.Image = not bobber2 and "" or bobber2.Icon or ""
	local v7 = bobber
	local v8 = childName
	child.Gift.Activated:Connect(function()
		if not GiftController.isGifting then
			GiftController:PromptGift(v7.ProductId, v8, nil, bobber2 and bobber2.Icon, nil, "Bobbers", v8)
		end
	end)
	local v10 = childName
	local v11 = bobber
	child.BuyButton.Activated:Connect(function()
		local stats = fetched:FindFirstChild("Stats")

		if not stats or stats:FindFirstChild("bobber") and stats.bobber:FindFirstChild(v10) then
			return
		end

		Monetization.BuyProduct:FireServer(v11.ProductId)
	end)
	local viewportFrame = child.Icon.ViewportFrame
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	local v12 = childName
	child.Preview.Activated:Connect(function()
		VisualizerController:Visualize((assets.getAsync("bobber", v12)))
	end)
	local v13 = bobber
	local v14 = child
	task.spawn(function()
		local robuxPrice = Monetization:GetRobuxPrice(v13.ProductId)

		if robuxPrice then
			v14.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
		end
	end)
	local child2 = shopNEW.Container.List.LimitedBobbers.Bobbers:FindFirstChild(childName)

	if not child2 then
		continue
	end

	local bobber3 = bobbers.Bobbers[childName]
	child2.Image = not bobber3 and "" or bobber3.Icon or ""
	local v15 = bobber
	local v16 = childName
	child2.Gift.Activated:Connect(function()
		if not GiftController.isGifting then
			GiftController:PromptGift(v15.ProductId, v16, nil, bobber3 and bobber3.Icon, nil, "Bobbers", v16)
		end
	end)
	local v18 = childName
	local v19 = bobber
	child2.BuyButton.Activated:Connect(function()
		local stats = fetched:FindFirstChild("Stats")

		if not stats or stats:FindFirstChild("bobber") and stats.bobber:FindFirstChild(v18) then
			return
		end

		Monetization.BuyProduct:FireServer(v19.ProductId)
	end)
	local v20 = childName
	child2.Preview.Activated:Connect(function()
		VisualizerController:Visualize((assets.getAsync("bobber", v20)))
	end)
	local v21 = bobber
	local v22 = child2
	task.spawn(function()
		local robuxPrice = Monetization:GetRobuxPrice(v21.ProductId)

		if robuxPrice then
			v22.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
		end
	end)
end

local v7 = Timer.new(1)
v7.Tick:Connect(function()
	local stats = fetched:FindFirstChild("Stats")

	if not stats then
		return
	end

	local bobber = stats:FindFirstChild("bobber")

	if not bobber then
		return
	end

	for childName, _ in limitedBobbers.Bobbers do
		if childName == "Bundle" then
			continue
		end

		local child = main.Limiteds.Products:FindFirstChild(childName)

		if not (child and bobber:FindFirstChild(childName)) then
			continue
		end

		local buyButton = child:FindFirstChild("BuyButton")

		if buyButton then
			buyButton.Text = "Owned"
		end
	end

	if not (limitedBobbers.Bobbers.Bundle.ProductId and fetched:FindFirstChild("PurchasedProducts")) then
		return
	end

	local bundle2 = main.Limiteds.Products.Bundle
	local buyButton = bundle2:FindFirstChild("BuyButton")

	if not buyButton then
		return
	end

	for _, child in pairs(bobber:GetChildren()) do
		if not limitedBobbers.Bobbers[child.Name] then
			continue
		end

		local coinsBuyButton = bundle2:FindFirstChild("CoinsBuyButton")
		coinsBuyButton.Text = "Owned"
		buyButton.Text = "Owned"
	end

	local limitedBobbers3 = shopNEW.Container.List.LimitedBobbers
	local buyButton2 = limitedBobbers3:FindFirstChild("BuyButton")

	if not buyButton2 then
		return
	end

	for _, child in pairs(bobber:GetChildren()) do
		if not limitedBobbers.Bobbers[child.Name] then
			continue
		end

		local coinsBuyButton_2 = limitedBobbers3:FindFirstChild("CoinsBuyButton")
		coinsBuyButton_2.Text = "Owned"
		buyButton2.Text = "Owned"
	end
end)
v7:StartNow()
local credits = main.Credits

local function updateCoinsDisplay()
	for k, credit in Monetization.products.Credits do
		local child = credits:FindFirstChild((tostring(k)))

		if not child then
			continue
		end

		local cache = fetched:FindFirstChild("Cache")

		if not cache then
			break
		end

		local credit2 = Monetization.products.Credits[k .. "FirstTimeOffer"]
		local robuxPrice = Monetization:GetRobuxPrice(credit.ProductId)
		local robuxPrice2 = credit2 and Monetization:GetRobuxPrice(credit2.ProductId)

		if credit2 then
			local firstTimeTag = credit2.FirstTimeTag

			if firstTimeTag and not cache:FindFirstChild(firstTimeTag) then
				if robuxPrice2 then
					child.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice2)
				end

				child.BuyButton.offer.Visible = true
				continue
			end
		end

		if robuxPrice then
			child.BuyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
		end

		child.BuyButton.offer.Visible = false
	end
end

for k, credit in Monetization.products.Credits do
	local child = credits:FindFirstChild((tostring(k)))

	if not child then
		continue
	end

	local cache = fetched:FindFirstChild("Cache")

	if not cache then
		return
	end

	child.Price.Text = `+{CurrencyController:GetDisplay()} {addCommas(credit.Credits)}`

	if k == "25000_Credits" then
		child.Price.Text = `{CurrencyController:GetDisplay()} 20,000 + 5,000`
	end

	local credit2 = Monetization.products.Credits[k .. "FirstTimeOffer"]
	local credit3 = Monetization.products.Credits[k .. "Gift"]
	local v10 = credit
	child.BuyButton.Activated:Connect(function()
		if credit2 then
			local firstTimeTag = credit2.FirstTimeTag

			if firstTimeTag and not cache:FindFirstChild(firstTimeTag) then
				Monetization.BuyProduct:FireServer(credit2.ProductId)
				return
			end
		end

		Monetization.BuyProduct:FireServer(v10.ProductId)
	end)
	local v12 = credit
	local v13 = k
	child.Gift.Activated:Connect(function()
		if not GiftController.isGifting then
			GiftController:PromptGift(credit3.ProductId, `{addCommas(v12.Credits)} C$`, nil, nil, nil, "Credits", v13)
		end
	end)
	Monetization:GetRobuxPrice(credit.ProductId)

	if credit2 then
		Monetization:GetRobuxPrice(credit2.ProductId)
	end

	task.spawn(function()
		updateCoinsDisplay()
	end)
end

Net:RemoteEvent("Monetization/UpdateCreditsPrice").OnClientEvent:Connect(function()
	task.spawn(function()
		updateCoinsDisplay()
	end)
end)
events:WaitForChild("anno_server_chat").OnClientEvent:Connect(function(p: string)
	local TextChatService = game:GetService("TextChatService")
	TextChatService:WaitForChild("TextChannels").RBXSystem:DisplaySystemMessage("<font color = \"rgb(255,0,0)\">" .. p .. "</font>")
end)
task.wait(5)

for _, gamepass in Monetization.gamepasses do
	if not gamepass.Hide then
		ConstructGamepass(gamepass.GamepassId, gamepass.Priority)
	end
end

local uIListLayout = script.Parent.Products.Views.Main.UIListLayout
uIListLayout.SpacerEnd.Parent = uIListLayout.Parent
ConstructGamepassGifting()

local function updatePolicyRestrictedGamepassTiles()
	local paidRandomItemsRestricted = isPaidRandomItemsRestricted() -- equivalent call inferred; original call site unknown

	for k, v8 in pairs(v3) do
		if not randomPaidItems[k] then
			continue
		end

		for _, v9 in v8 do
			v9.Visible = not paidRandomItemsRestricted
		end
	end
end

updatePolicyRestrictedGamepassTiles()
localPlayer:GetAttributeChangedSignal("PolicyPaidRandomItemsRestricted"):Connect(updatePolicyRestrictedGamepassTiles)