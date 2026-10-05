local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Utility = require(script.Parent.Utility)
local gameSettings = require(script.Parent.gameSettings)
local Shop = {
	itemsforsale = {},
	cashiers = 0
}
local cashiers = {
	Wen = require(script.Cashiers.Wen),
	Product = require(script.Cashiers.Product),
	Gamepass = require(script.Cashiers.Gamepass),
	Spins = require(script.Cashiers.Spins)
}
local DemonHorns = require(script.Cashiers["Demon Horns"])
cashiers["Demon Horns"] = DemonHorns
local GoldenFish = require(script.Cashiers["Golden Fish"])
cashiers["Golden Fish"] = GoldenFish
local MetalScraps = require(script.Cashiers["Metal Scraps"])
cashiers["Metal Scraps"] = MetalScraps
local SilkThread = require(script.Cashiers["Silk Thread"])
cashiers["Silk Thread"] = SilkThread
local RefinementOre = require(script.Cashiers["Refinement Ore"])
cashiers["Refinement Ore"] = RefinementOre
local MythicRefinementOre = require(script.Cashiers["Mythic Refinement Ore"])
cashiers["Mythic Refinement Ore"] = MythicRefinementOre
cashiers.RunPoints = require(script.Cashiers.RunPoints)
local OuwigaharaToken = require(script.Cashiers["Ouwigahara Token"])
cashiers["Ouwigahara Token"] = OuwigaharaToken
Shop.cashiers = cashiers
local isServer = RunService:IsServer()

if isServer then
	Shop.OrderProcessers = {
		Item = require(script.OrderProcessers.Item),
		Spins = require(script.OrderProcessers.Spins),
		Product = require(script.OrderProcessers.Product),
		Clan = require(script.OrderProcessers.Clan),
		Grant = require(script.OrderProcessers.Grant)
	}
end

for _, moduleScript in ipairs(script.Content:QueryDescendants("ModuleScript")) do
	local name = moduleScript.Name
	local module = require(moduleScript)

	if module.Price then
		Shop.itemsforsale[name] = module
	else
		for k, v2 in module do
			Shop.itemsforsale[k] = v2
		end
	end
end

Shop.ProductIdToItem = {}
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function warmProductPrice(p: number)
	task.spawn(Shop.cashiers.Product.GetRobuxPrice, p)
end

function Shop.RegisterItem(p: string, state)
	local v3 = Shop.itemsforsale[p]

	if v3 ~= nil and v3.Seller ~= nil and state.Seller ~= nil then
		for _, v4 in v3.Seller do
			if table.find(state.Seller, v4) == nil then
				table.insert(state.Seller, v4)
			end
		end
	end

	local price = state.Price

	if price == nil then
		v2 = v2 or require(script.Parent.Collectibles.Items)
		local v4 = v2[p]

		if v4 == nil then
			price = nil
		else
			price = v4.Price or nil
		end

		if price == nil then
			warn((`Shop: "{p}" has no price on its listing or its item module, not listed`))
			return false
		else
			state.Price = price
		end
	end

	Shop.itemsforsale[p] = state

	if price.Product == nil then
		return true
	end

	Shop.ProductIdToItem[price.Product] = p
	warmProductPrice(price.Product) -- equivalent call inferred; original call site unknown
	return true
end

local listingLocked
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil

for k, v10 in Shop.itemsforsale do
	if not (v10.Price ~= nil and v10.Price.Product ~= nil) then
		continue
	end

	Shop.ProductIdToItem[v10.Price.Product] = k
	warmProductPrice(v10.Price.Product) -- equivalent call inferred; original call site unknown
end

function Shop.RegisterProductMapping(p: number, p2: string)
	Shop.ProductIdToItem[p] = p2
	warmProductPrice(p) -- equivalent call inferred; original call site unknown
end

function Shop.ListingsOfType(p: string, p2: string?)
	local clones = {}

	for k, v10 in Shop.itemsforsale do
		if v10.Type ~= p then
			continue
		end

		local clone = table.clone(v10)
		clone.Name = k

		if typeof(v10.Price) == "table" and v10.Price.Product ~= nil then
			clone.Price = Shop.cashiers.Product.GetRobuxPrice(v10.Price.Product)
		end

		table.insert(clones, clone)
	end

	table.sort(clones, function(a, b)
		if p2 == nil or tonumber(a[p2]) == nil or tonumber(b[p2]) == nil then
			return a.Name < b.Name
		end

		return a[p2] < b[p2]
	end)

	for _, v10 in clones do
		v10.OrePrice = Shop.GetOrePrice(v10.Name)
	end

	return clones
end

local function oreRate()
	local sellRobuxPayout = gameSettings.SellRobuxPayout

	if sellRobuxPayout == nil or sellRobuxPayout.Item == nil or (sellRobuxPayout.RobuxEach or 0) <= 0 then
		return nil
	end

	return sellRobuxPayout
end

-- equivalent calls inferred from this helper; original call sites unknown
local function oreHeld(p, item: string)
	local heldItem = Utility.HeldItem(p, item)

	if heldItem == nil then
		return 0
	end

	local amount = heldItem:FindFirstChild("Amount")
	return amount ~= nil and amount.Value or 1
end

function Shop.GetOrePrice(p: string)
	local v10 = Shop.itemsforsale[p]

	if v10 == nil or v10.AllowOre ~= true then
		return nil
	end

	local product = typeof(v10.Price) == "table" and v10.Price.Product or nil

	if product == nil then
		return nil
	end

	local sellRobuxPayout = gameSettings.SellRobuxPayout

	if sellRobuxPayout == nil or sellRobuxPayout.Item == nil or (sellRobuxPayout.RobuxEach or 0) <= 0 then
		sellRobuxPayout = nil
	end

	if sellRobuxPayout == nil then
		return nil
	end

	local baseRobuxPrice = Shop.cashiers.Product.GetBaseRobuxPrice(product)

	if baseRobuxPrice == nil then
		return nil
	end

	return (math.max(math.ceil(baseRobuxPrice / sellRobuxPayout.RobuxEach), 1))
end

function Shop.GetOreContent(p, p2: string, p3: number?)
	local orePrice = Shop.GetOrePrice(p2)

	if orePrice == nil then
		return nil
	end

	local sellRobuxPayout = gameSettings.SellRobuxPayout

	if sellRobuxPayout == nil or sellRobuxPayout.Item == nil or (sellRobuxPayout.RobuxEach or 0) <= 0 then
		sellRobuxPayout = nil
	end

	v2 = v2 or require(script.Parent.Collectibles.Items)
	local v10 = v2[sellRobuxPayout.Item]
	local price = orePrice * Shop.EffectiveAmount(p2, p3)
	local v12 = {
		Icon = v10 == nil and "" or v10.Icon or "",
		Price = price,
		Item = sellRobuxPayout.Item
	}
	local v13

	if p ~= nil then
		v13 = Utility.GetData(p) or nil
	end

	if v13 == nil then
		return v12
	end

	local held = oreHeld(v13, sellRobuxPayout.Item) -- equivalent call inferred; original call site unknown
	v12.Held = held
	v12.CanBuy = price <= v12.Held
	return v12
end

function Shop.CanBuyWithOre(p, p2: string, p3, p4: number?)
	local orePrice = Shop.GetOrePrice(p2)

	if orePrice == nil then
		return false, "Not sold for ore"
	end

	local v10 = p3 or Utility.GetData(p)

	if v10 == nil then
		return false, "Data not ready"
	end

	local v11, v12 = listingLocked(p, p2)

	if v11 then
		return false, v12
	end

	local sellRobuxPayout = gameSettings.SellRobuxPayout

	if sellRobuxPayout == nil or sellRobuxPayout.Item == nil or (sellRobuxPayout.RobuxEach or 0) <= 0 then
		sellRobuxPayout = nil
	end

	local v13 = orePrice * Shop.EffectiveAmount(p2, p4)
	local v14 = oreHeld(v10, sellRobuxPayout.Item) -- equivalent call inferred; original call site unknown

	if v14 < v13 then
		return false, (`Need {Utility.addCommasToNumber(v13)} {sellRobuxPayout.Item}`)
	end

	return true
end

local Players = game:GetService("Players")
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})
local object3 = setmetatable({}, {
	__mode = "k"
})

function Shop.ResolveGiftRecipient(p, p2: string, childName)
	if typeof(childName) ~= "string" or childName == "" or Shop.itemsforsale[p2] == nil then
		return nil
	end

	local player = Players:FindFirstChild(childName)

	if player == nil or not player:IsA("Player") then
		return nil, (`{childName} is not in this server`)
	end

	if player == p then
		return nil
	end

	if Utility.GetData(player) == nil then
		return nil, (`{player.DisplayName}'s data is still loading`)
	end

	local v10, v11 = listingLocked(player, p2)

	if v10 then
		return nil, (`{player.DisplayName} can't receive this: {v11 or "they don't qualify"}`)
	end

	return player
end

local function giftFolder(p, flag: boolean?)
	local _, parent = Utility.GetData(p)

	if parent == nil then
		return nil
	end

	local v11 = parent:FindFirstChild("PendingGifts")

	if v11 == nil and flag then
		v11 = Instance.new("Folder")
		v11.Name = "PendingGifts"
		v11.Parent = parent
	end

	return v11
end

function Shop.SetGiftIntent(p, p2: string, p3)
	local v10 = Shop.itemsforsale[p2]
	local product

	if not (v10 == nil or v10.Price == nil) then
		product = v10.Price.Product or nil
	end

	if product == nil then
		return
	end

	local name = tostring(product)
	local v12 = object3[p]

	if p3 == nil then
		if v12 ~= nil then
			v12[product] = nil
		end

		local _, v13 = Utility.GetData(p)
		local pendingGifts

		if v13 ~= nil then
			pendingGifts = v13:FindFirstChild("PendingGifts")
		end

		local child = pendingGifts ~= nil and pendingGifts:FindFirstChild(name) or nil

		if child ~= nil then
			child:Destroy()
		end
	else
		if v12 == nil then
			v12 = {}
			object3[p] = v12
		end

		v12[product] = p3.Name
		local _, parent = Utility.GetData(p)
		local parent2

		if parent ~= nil then
			parent2 = parent:FindFirstChild("PendingGifts")

			if parent2 == nil then
				parent2 = Instance.new("Folder")
				parent2.Name = "PendingGifts"
				parent2.Parent = parent
			end
		end

		if parent2 == nil then
			return
		end

		local v15 = parent2:FindFirstChild(name)

		if v15 == nil then
			v15 = Instance.new("StringValue")
			v15.Name = name
			v15.Parent = parent2
		end

		v15.Value = p3.Name
	end
end

local function peekGiftIntent(p, p2: number)
	local v10 = object3[p]
	local v11

	if v10 ~= nil then
		v11 = v10[p2] or nil
	end

	if v11 ~= nil then
		return v11, false
	end

	local _, v12 = Utility.GetData(p)
	local pendingGifts

	if v12 ~= nil then
		pendingGifts = v12:FindFirstChild("PendingGifts")
	end

	local child = pendingGifts ~= nil and pendingGifts:FindFirstChild((tostring(p2))) or nil

	if child == nil then
		return nil, false
	end

	return child.Value, true
end

local function clearGiftIntent(p, p2: number)
	local v10 = object3[p]

	if v10 ~= nil then
		v10[p2] = nil
	end

	local _, v11 = Utility.GetData(p)
	local pendingGifts

	if v11 ~= nil then
		pendingGifts = v11:FindFirstChild("PendingGifts")
	end

	local child = pendingGifts ~= nil and pendingGifts:FindFirstChild((tostring(p2))) or nil

	if child ~= nil then
		child:Destroy()
	end
end

function Shop.GiftConsent(p, instance, p2: string, value)
	local v10 = Shop.itemsforsale[p2]

	if v10 == nil or v10.AskFirst ~= true then
		return true
	end

	if instance == nil then
		if typeof(value) == "string" and value ~= "" then
			return false, (`{value} is not available any more`)
		end

		return true
	else
		local v11 = object2[instance]

		if v11 ~= nil and os.clock() - v11 < 20 then
			return false, (`{instance.DisplayName} was just asked, give them a moment`)
		end

		if instance:GetAttribute("Invites") ~= true then
			return false, (`{instance.DisplayName} is not accepting requests right now`)
		end

		if object[instance] then
			return false, (`{instance.DisplayName} is already being asked about a gift`)
		end

		object[instance] = true
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
		local success, result = pcall(function()
			return SignalFunction.ToClient(instance, "InferPopup", {
				Type = "CenterBottomQuestion",
				Content = `{Utility.NameTag(p.DisplayName, true)} wants to buy you {Utility.NameTag(p2, true)}. Accept?`,
				Timout = 10
			})
		end)
		object[instance] = nil

		if not success or result ~= "Yes" then
			object2[instance] = os.clock()
		end

		if not success then
			return false, (`{instance.DisplayName} could not be asked`)
		end

		if result == "Yes" then
			return true
		end

		return false, (`{instance.DisplayName} said no`)
	end
end

local function giftNotify(playerByUserId, p, p2: string)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent).ToClient(p, "Notify", {
		Text = `{playerByUserId.DisplayName} gifted you {p2}!`,
		Type = "Success",
		Duration = 10
	})
end

if isServer then
	local v10 = nil
	local v11 = nil

	function Shop.BuyWithOre(p, p2: string, p3, p4: number?)
		local v12 = p3 or Utility.GetData(p)

		if v12 == nil then
			return false, "Data not ready"
		end

		local effectiveAmount = Shop.EffectiveAmount(p2, p4)
		local canBuyWithOre, v13 = Shop.CanBuyWithOre(p, p2, v12, effectiveAmount)

		if not canBuyWithOre then
			return false, v13
		end

		local v14 = Shop.itemsforsale[p2]
		local v15

		if v14 ~= nil then
			v15 = Shop.OrderProcessers[v14.Type] or nil
		end

		if v15 == nil then
			return false, "Bad listing"
		end

		local sellRobuxPayout = gameSettings.SellRobuxPayout

		if sellRobuxPayout == nil or sellRobuxPayout.Item == nil or (sellRobuxPayout.RobuxEach or 0) <= 0 then
			sellRobuxPayout = nil
		end

		local v16 = Shop.GetOrePrice(p2) * effectiveAmount
		local Item = v10

		if not Item then
			local ServerStorage = game:GetService("ServerStorage")
			Item = require(ServerStorage.SAM.Services.Removers.Item)
		end

		v10 = Item

		if not v10(p, sellRobuxPayout.Item, v16) then
			return false, (`Need {Utility.addCommasToNumber(v16)} {sellRobuxPayout.Item}`)
		end

		if v15(p, v12, p2, effectiveAmount, v14) then
			local Analytics = v11

			if not Analytics then
				local ServerStorage = game:GetService("ServerStorage")
				Analytics = require(ServerStorage.SAM.Services.Reporting.Analytics)
			end

			v11 = Analytics
			v11.Economy(p, sellRobuxPayout.Item, "Sink", v16, "ShopPurchase", p2)
			return true
		else
			local ServerStorage = game:GetService("ServerStorage")
			require(ServerStorage.SAM.Services.Adders.Item)(
				p,
				sellRobuxPayout.Item,
				v16,
				nil,
				nil,
				nil,
				"ShopOreRefund"
			)
			return false, "Something went wrong"
		end
	end
end

local function getCashier(p: string)
	local cashier = Shop.cashiers[p]

	if cashier == nil then
		warn((`Shop: no cashier for currency "{p}", listing refused`))
	end

	return cashier
end

local v10 = nil

local function pricedFor(localPlayer, k: string, p: number, p2: number)
	local v11 = p * p2

	if k ~= "Wen" or v11 <= 0 then
		return v11
	end

	if localPlayer == nil and not isServer then
		local Players2 = game:GetService("Players")
		localPlayer = Players2.LocalPlayer
	end

	if localPlayer == nil then
		return v11
	end

	local data = Utility.GetData(localPlayer)
	local clan

	if data ~= nil then
		clan = data:FindFirstChild("Clan") or nil
	end

	if clan == nil then
		return v11
	end

	v10 = v10 or require(script.Parent.Parent.Clans)

	if v10.HasPassive(clan.Value, "Serenity Discount") then
		return (math.ceil(v11 * 0.7))
	end

	return v11
end

Shop.PricedFor = pricedFor

function Shop.SanitizeAmount(p)
	local v11 = tonumber(p)
	return (math.clamp(math.floor((v11 == nil or v11 ~= v11 or v11 == 1e999 or v11 == -1e999) and 1 or v11), 1, 99))
end

function Shop.EffectiveAmount(p: string, p2)
	local v11 = Shop.SanitizeAmount(p2)

	if v11 > 1 then
		v2 = v2 or require(script.Parent.Collectibles.Items)
		local v12 = v2[p]
		return v12 ~= nil and (v12.Skills ~= nil or v12.HasCombat or v12.Unique == true) and 1 or v11
	end

	return v11
end

function Shop.Buy(p, p2: string, p3, p4: number?)
	if not isServer or (p == nil or p2 == nil) then
		return
	end

	local v11 = p3 or Utility.GetData(p)

	if v11 == nil then
		return
	end

	local effectiveAmount = Shop.EffectiveAmount(p2, p4)
	local v12 = Shop.itemsforsale[p2]

	if v12 == nil then
		return
	end

	local flag = false

	for k in v12.Price do
		local cashier = Shop.cashiers[k]

		if cashier == nil then
			warn((`Shop: no cashier for currency "{k}", listing refused`))
		end

		if cashier == nil then
			return
		end

		if cashier.Deferred then
			flag = true
		end
	end

	if flag then
		for k, v13 in v12.Price do
			local cashier = Shop.cashiers[k]

			if cashier.Deferred then
				cashier.Buy(v11, v13, p, p2)
			end
		end
	else
		if not Shop.OrderProcessers[v12.Type](p, v11, p2, effectiveAmount, v12) then
			return false
		end

		for k, v13 in v12.Price do
			Shop.cashiers[k].Buy(v11, pricedFor(p, k, v13, effectiveAmount), p, p2)
		end

		return true
	end
end

function Shop.BuyDeferredAndWait(p, p2: string, p3)
	if not isServer then
		return false
	end

	local v11 = Shop.itemsforsale[p2]
	local product

	if v11 == nil or v11.Price == nil then
		product = nil
	else
		product = v11.Price.Product or nil
	end

	local gamepass

	if v11 == nil or v11.Price == nil then
		gamepass = nil
	else
		gamepass = v11.Price.Gamepass or nil
	end

	if product == nil and gamepass == nil then
		return false
	end

	Shop.Buy(p, p2, p3, 1)
	local v12 = false
	local v13 = false
	local promptGamePassPurchaseFinishedConnection

	if product == nil then
		promptGamePassPurchaseFinishedConnection = MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p4, p5: number, flag: boolean)
			if p4 == p and p5 == gamepass then
				v12 = true
				v13 = flag == true
			end
		end)
	else
		promptGamePassPurchaseFinishedConnection = MarketplaceService.PromptProductPurchaseFinished:Connect(function(p4: number, p5: number, flag: boolean)
			if p4 == p.UserId and p5 == product then
				v12 = true
				v13 = flag == true
			end
		end)
	end

	local v14 = os.clock() + 120

	while not v12 and os.clock() < v14 and p.Parent ~= nil do
		task.wait(0.25)
	end

	promptGamePassPurchaseFinishedConnection:Disconnect()

	if v12 and not v13 then
		Shop.SetGiftIntent(p, p2, nil)
	end

	return v12 and v13
end

function Shop.GetPrice(p: string, flag: boolean?, p2)
	if p == nil then
		return
	end

	local v11 = Shop.itemsforsale[p]

	if v11 == nil then
		return
	end

	if not flag then
		return v11.Price
	end

	local v12 = ""

	for k, v13 in v11.Price do
		local cashier = Shop.cashiers[k]

		if cashier == nil then
			warn((`Shop: no cashier for currency "{k}", listing refused`))
		end

		local v14

		if cashier ~= nil then
			v14 = cashier.FormulateTextPlusText((pricedFor(p2, k, v13, 1))) or nil
		end

		if v14 ~= nil then
			v12 = v12 == "" and v14 or v12 .. " and " .. v14
		end
	end

	return v12
end

function Shop.GetContent(p: string, p2)
	if p == nil then
		return
	end

	local v11 = Shop.itemsforsale[p]

	if v11 == nil then
		return
	end

	local contents = {}

	for k, v12 in v11.Price do
		local cashier = Shop.cashiers[k]

		if cashier == nil then
			warn((`Shop: no cashier for currency "{k}", listing refused`))
		end

		if cashier == nil then
			return nil
		end

		local content = cashier.GetContent(cashier.Deferred and v12 or pricedFor(p2, k, v12, 1))

		if content ~= nil then
			table.insert(contents, content)
		end
	end

	return contents
end

listingLocked = function(instance, p: string)
	local v11 = Shop.itemsforsale[p]

	if v11 == nil then
		return false
	end

	if isServer and v11.Seller ~= nil then
		local NearNpc = v3

		if not NearNpc then
			local ServerStorage = game:GetService("ServerStorage")
			NearNpc = require(ServerStorage.SAM.Utility.NearNpc)
		end

		v3 = NearNpc
		local NearSellerStand = v4

		if not NearSellerStand then
			local ServerStorage = game:GetService("ServerStorage")
			NearSellerStand = require(ServerStorage.SAM.Utility.NearSellerStand)
		end

		v4 = NearSellerStand

		if not (v3(instance, v11.Seller) or v4(instance, v11.Seller, p)) then
			return true, "Too far from the seller"
		end
	end

	if (instance:GetAttribute("SaveDisabled") == true or instance:GetAttribute("SaveDisabledSlot") == true) and typeof(v11.Price) == "table" and v11.Price.Product ~= nil then
		return true, "Not while in a run"
	end

	if instance:GetAttribute("SaveDisabledSlot") == true and typeof(v11.Price) == "table" then
		v2 = v2 or require(script.Parent.Collectibles.Items)
		local v12

		if v11.Type == "Item" then
			v12 = v2[p]
		end

		if v12 == nil or v12.AccountWide ~= true then
			for k in v11.Price do
				local cashier = Shop.cashiers[k]

				if cashier ~= nil and cashier.AccountBalance == true then
					return true, "Only on a normal run"
				end
			end
		end
	end

	if v11.RequiresVIP == true then
		v5 = v5 or require(script.Parent.VipAccess)

		if not v5.Has(instance) then
			return true, "VIP required"
		end
	end

	v6 = v6 or require(script.Parent.ClanEvents)

	if v6.Read(instance)[p] ~= nil then
		return true, "Not while its event runs"
	end

	if v11.RequiresGamepass ~= nil and not Shop.OwnsGamepassListing(instance, v11.RequiresGamepass) then
		return true, (`{v11.RequiresGamepass} required`)
	end

	if v11.RequiresSide ~= nil then
		v7 = v7 or require(script.Parent.PlayerProgression)

		if table.find(v7.SidesFor(instance), v11.RequiresSide) == nil then
			return true, (`{v11.RequiresSide}s only`)
		end
	end

	if v11.Requirements ~= nil then
		v8 = v8 or require(script.Parent.Collectibles.ItemRequirements)

		if not v8.Passes(Utility.GetData(instance), v11.Requirements) then
			return true, v8.Describe(v11.Requirements)
		end
	end

	if v11.Type == "Item" then
		v2 = v2 or require(script.Parent.Collectibles.Items)
		local v12 = v2[p]
		local data = Utility.GetData(instance)

		if v12 ~= nil and v12.Unique == true and data ~= nil and Utility.HeldItem(data, p) ~= nil then
			return true, "Already owned"
		end
	end

	local requiresQuestDone = v11.RequiresQuestDone

	if requiresQuestDone == nil then
		return false
	end

	v9 = v9 or require(script.Parent.Subsets.Gameplay.Quests)

	if v9.GetPlayerQuestState(instance, requiresQuestDone) == "Done" then
		return false
	end

	local questInfo = v9.GetQuestInfo(requiresQuestDone)

	if questInfo ~= nil and questInfo.QuestInstance ~= nil then
		requiresQuestDone = questInfo.QuestInstance.Name or requiresQuestDone
	end

	return true, (`{Utility.NameTag(requiresQuestDone)} completed`)
end

function Shop.CanBuyResults(p, p2: string, p3, p4: number?)
	if p2 == nil then
		return
	end

	local v11 = p3 or Utility.GetData(p)

	if v11 == nil then
		return
	end

	local effectiveAmount = Shop.EffectiveAmount(p2, p4)
	local v12 = Shop.itemsforsale[p2]

	if v12 == nil then
		return
	end

	local contents = {}

	for k, v13 in v12.Price do
		local cashier = Shop.cashiers[k]

		if cashier == nil then
			warn((`Shop: no cashier for currency "{k}", listing refused`))
		end

		if cashier == nil then
			return nil
		end

		local content = cashier.GetContent(cashier.Deferred and v13 or pricedFor(p, k, v13, 1))

		if content == nil then
			continue
		end

		content.CanBuy = cashier.CanBuy(v11, cashier.Deferred and v13 or pricedFor(p, k, v13, effectiveAmount))
		table.insert(contents, content)
	end

	return contents
end

function Shop.GetCartTotals(items, p)
	local result = {}
	local total = 0

	if typeof(items) ~= "table" then
		return result, 0
	end

	for k, item in items do
		if not (typeof(k) == "string" and typeof(item) == "number") then
			continue
		end

		local v11 = Shop.itemsforsale[k]

		if not (v11 ~= nil and v11.Price ~= nil and v11.Price.Product == nil and v11.Price.Gamepass == nil) then
			continue
		end

		local effectiveAmount = Shop.EffectiveAmount(k, item)
		total += effectiveAmount

		for k2, v12 in v11.Price do
			result[k2] = (result[k2] or 0) + pricedFor(p, k2, v12, effectiveAmount)
		end
	end

	return result, total
end

function Shop.GetCartDeferred(items)
	local result = {}

	if typeof(items) ~= "table" then
		return result
	end

	for k in items do
		if typeof(k) ~= "string" then
			continue
		end

		local v11 = Shop.itemsforsale[k]

		if not (v11 ~= nil and v11.Price ~= nil and (v11.Price.Product ~= nil or v11.Price.Gamepass ~= nil)) then
			continue
		end

		table.insert(result, k)
	end

	return result
end

function Shop.CanBuyCart(p, items, p2)
	local v11 = p2 or Utility.GetData(p)

	if v11 == nil then
		return false
	end

	if typeof(items) == "table" then
		for k in items do
			local v12, v13 = listingLocked(p, k)

			if v12 then
				return false, v13
			end
		end
	end

	local cartTotals, v12 = Shop.GetCartTotals(items, p)

	if v12 < 1 then
		return #Shop.GetCartDeferred(items) > 0
	end

	for k, cartTotal in cartTotals do
		local cashier = Shop.cashiers[k]

		if cashier == nil then
			warn((`Shop: no cashier for currency "{k}", listing refused`))
		end

		if cashier == nil then
			return false
		end

		if not cashier.CanBuy(v11, cartTotal) then
			return false, cashier.FormulateTextPlusText(cartTotal)
		end
	end

	return true
end

function Shop.FormatTotalsTextPlus(items)
	local v11 = ""

	for k, item in items do
		local cashier = Shop.cashiers[k]

		if cashier == nil then
			warn((`Shop: no cashier for currency "{k}", listing refused`))
		end

		local v12

		if cashier ~= nil then
			v12 = cashier.FormulateTextPlusText(item) or nil
		end

		if v12 ~= nil then
			v11 = v11 == "" and v12 or v11 .. " and " .. v12
		end
	end

	return v11
end

function Shop.GetPriceRichText(p: string, value: number?, p2)
	if p == nil then
		return
	end

	local v11 = Shop.itemsforsale[p]

	if v11 == nil then
		return
	end

	local v12 = ""

	for k, v13 in v11.Price do
		local cashier = Shop.cashiers[k]

		if cashier == nil then
			warn((`Shop: no cashier for currency "{k}", listing refused`))
		end

		if cashier == nil then
			return nil
		end

		local formulateRichText = cashier.FormulateRichText(cashier.Deferred and v13 or pricedFor(
			p2,
			k,
			v13,
			value or 1
		))

		if formulateRichText then
			v12 = v12 == "" and formulateRichText or v12 .. " and " .. formulateRichText
		end
	end

	return v12
end

function Shop.GetSellValue(p: string)
	v2 = v2 or require(script.Parent.Collectibles.Items)
	local v11 = v2[p]

	if v11 ~= nil and v11.NoSell then
		return nil
	end

	local v12 = Shop.itemsforsale[p]
	local price = v12 ~= nil and v12.Price or v11 ~= nil and v11.Price or nil

	if price == nil then
		return nil
	end

	local total = 0

	for k, v13 in price do
		if k == "Wen" then
			total += v13
		else
			local cashier = Shop.cashiers[k]

			if cashier ~= nil and cashier.Deferred then
				local getBaseRobuxPrice = cashier.GetBaseRobuxPrice or cashier.GetRobuxPrice

				if getBaseRobuxPrice == nil then
					return nil
				end

				v13 = getBaseRobuxPrice(v13)
				k = "Robux"
			end

			local v14 = gameSettings.CurrencyToWen[k]

			if v13 == nil or v14 == nil then
				return nil
			else
				total += v13 * v14.To / v14.From
			end
		end
	end

	return (math.floor(total * gameSettings.sellReturnFactor))
end

function Shop.GetSellPayout(p: string)
	v2 = v2 or require(script.Parent.Collectibles.Items)
	local v11 = v2[p]

	if v11 ~= nil and v11.NoSell then
		return nil
	end

	local v12 = Shop.itemsforsale[p]
	local price = v12 ~= nil and v12.Price or v11 ~= nil and v11.Price or nil

	if price == nil then
		return nil
	end

	local result = {}
	local flag = false

	for k, v13 in price do
		local cashier = Shop.cashiers[k]

		if cashier == nil or not cashier.Deferred then
			if k ~= "Wen" and v2[k] == nil then
				return nil
			end

			local v14 = math.floor(v13 * gameSettings.sellReturnFactor)
			local v15 = v14 < 1 and v13 > 0 and 1 or v14

			if v15 >= 1 then
				result[k] = (result[k] or 0) + v15
				flag = true
			end
		else
			local getBaseRobuxPrice = cashier.GetBaseRobuxPrice or cashier.GetRobuxPrice

			if getBaseRobuxPrice == nil then
				return nil
			end

			local baseRobuxPrice = getBaseRobuxPrice(v13)
			local robux = gameSettings.CurrencyToWen.Robux

			if baseRobuxPrice == nil or robux == nil then
				return nil
			end

			local v14 = baseRobuxPrice * gameSettings.sellReturnFactor
			local sellRobuxPayout = gameSettings.SellRobuxPayout

			if sellRobuxPayout ~= nil and sellRobuxPayout.Item ~= nil and (sellRobuxPayout.RobuxEach or 0) > 0 then
				local v15 = math.floor(v14 / sellRobuxPayout.RobuxEach)

				if v15 >= 1 then
					result[sellRobuxPayout.Item] = (result[sellRobuxPayout.Item] or 0) + v15
					v14 -= v15 * sellRobuxPayout.RobuxEach
					flag = true
				end
			end

			local v15 = math.floor(v14 * robux.To / robux.From)

			if v15 >= 1 then
				result.Wen = (result.Wen or 0) + v15
				flag = true
			end
		end
	end

	if flag then
		return result
	end

	return nil
end

function Shop.GetSellContent(p: string)
	local sellPayout = Shop.GetSellPayout(p)

	if sellPayout == nil then
		return nil
	end

	local result = {}

	for k, price in sellPayout do
		local cashier = Shop.cashiers[k]
		local v12

		if not (cashier == nil or cashier.GetContent == nil) then
			v12 = cashier.GetContent(price) or nil
		end

		if v12 == nil then
			v2 = v2 or require(script.Parent.Collectibles.Items)
			local v13 = v2[k]
			v12 = {
				Icon = 0,
				Price = 0
			}
			local icon

			if v13 ~= nil then
				icon = v13.Icon or nil
			end

			v12.Icon = icon
			v12.Price = price
		end

		v12.Currency = k
		table.insert(result, v12)
	end

	table.sort(result, function(a, b)
		if a.Currency == "Wen" == (b.Currency == "Wen") then
			return a.Currency < b.Currency
		end

		return a.Currency == "Wen"
	end)
	return result
end

function Shop.GetSellTotals(items)
	local result = {}
	local total = 0

	if typeof(items) ~= "table" then
		return result, 0
	end

	for k, item in items do
		if not (typeof(k) == "string" and typeof(item) == "number") then
			continue
		end

		local v11 = math.clamp(math.floor(item), 0, 999)

		if v11 < 1 then
			continue
		end

		local sellPayout = Shop.GetSellPayout(k)

		if sellPayout == nil then
			continue
		end

		total += v11

		for k2, v12 in sellPayout do
			result[k2] = (result[k2] or 0) + v12 * v11
		end
	end

	return result, total
end

function Shop.FormatSellTotalsTextPlus(items)
	local v11 = {}
	local v12 = ""

	for k in items do
		table.insert(v11, k)
	end

	table.sort(v11, function(a, b)
		if a == "Wen" == (b == "Wen") then
			return a < b
		end

		return a == "Wen"
	end)

	for _, v13 in ipairs(v11) do
		local item = items[v13]

		if item < 1 then
			continue
		end

		local cashier = Shop.cashiers[v13]
		local v14 = cashier ~= nil and cashier.FormulateTextPlusText ~= nil and cashier.FormulateTextPlusText(item) or `{Utility.addCommasToNumber(item)} {v13}`
		v12 = v12 == "" and v14 or v12 .. " and " .. v14
	end

	if v12 == "" then
		return "nothing"
	end

	return v12
end

function Shop.OwnsGamepassListing(p, p2: string)
	local v11 = Shop.itemsforsale[p2]
	local gamepass

	if not (v11 == nil or v11.Price == nil) then
		gamepass = v11.Price.Gamepass or nil
	end

	if gamepass == nil or p == nil then
		return false
	end

	return Shop.cashiers.Gamepass.OwnsGamepass(p.UserId, gamepass)
end

function Shop.CanBuy(p, p2: string, p3, p4: number?)
	if p2 == nil then
		return
	end

	local v11 = p3 or Utility.GetData(p)

	if v11 == nil then
		return
	end

	local effectiveAmount = Shop.EffectiveAmount(p2, p4)
	local v12 = Shop.itemsforsale[p2]

	if v12 == nil then
		return false
	end

	local v13, v14 = listingLocked(p, p2)

	if v13 then
		return false, v14
	end

	for k, v17 in v12.Price do
		local cashier = Shop.cashiers[k]

		if cashier == nil then
			warn((`Shop: no cashier for currency "{k}", listing refused`))
		end

		if cashier == nil then
			return false
		end

		local v18 = cashier.Deferred and v17 or pricedFor(p, k, v17, effectiveAmount)

		if not cashier.CanBuy(v11, v18) then
			return false, (cashier.FormulateTextPlusText(v18))
		end
	end

	return true, nil
end

if not isServer then
	return Shop
end

local Players2 = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Discord = require(ServerStorage.SAM.Services.Reporting.Discord)
local ServerStorage2 = game:GetService("ServerStorage")
local MarketIcon = require(ServerStorage2.SAM.Services.Reporting.Discord.MarketIcon)

-- equivalent calls inferred from this helper; original call sites unknown
local function receiptLine(data, player, p2: string, p3: string?, reason: string?)
	task.spawn(function()
		Discord.Send("devproducts", p2, {
			player = player,
			data = {
				productId = data.ProductId,
				item = p3,
				purchaseId = data.PurchaseId,
				currencySpent = data.CurrencySpent,
				placePurchased = data.PlaceIdWherePurchased,
				userId = data.PlayerId,
				reason = reason,
				icon = MarketIcon.Resolve(data.ProductId, "Product")
			}
		})
	end)
end

function Shop.GrantProduct(p, product: number)
	if p == nil or typeof(product) ~= "number" then
		return false, "No product"
	end

	local v11 = Shop.ProductIdToItem[product]

	if v11 == nil then
		return false, (`no listing maps product {product}`)
	end

	local data = Utility.GetData(p)

	if data == nil then
		return false, "data not loaded"
	end

	local v12 = Shop.itemsforsale[v11] or {
		Type = "Item",
		Price = {
			Product = product
		}
	}
	local orderProcesser = Shop.OrderProcessers[v12.Type]

	if orderProcesser == nil then
		return false, (`no order processor for "{tostring(v12.Type)}"`)
	end

	return orderProcesser(p, data, v11, 1, v12)
end

function Shop.HandleProductReceipt(data)
	local v11 = Shop.ProductIdToItem[data.ProductId]

	if v11 == nil then
		warn((`Shop: receipt for unknown product {data.ProductId} (no listing maps it), left for retry`))
		receiptLine(data, nil, "ReceiptRefused", nil, "unknown product") -- equivalent call inferred; original call site unknown
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		local playerByUserId = Players2:GetPlayerByUserId(data.PlayerId)

		if playerByUserId == nil then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local data2, v12 = Utility.GetData(playerByUserId)

		if data2 == nil then
			receiptLine(data, playerByUserId, "ReceiptRefused", v11, "data not loaded") -- equivalent call inferred; original call site unknown
			return Enum.ProductPurchaseDecision.NotProcessedYet
		else
			local consumedReceipts

			if v12 == nil then
				consumedReceipts = nil
			else
				consumedReceipts = v12:FindFirstChild("ConsumedReceipts") or nil
			end

			if consumedReceipts ~= nil and string.find(consumedReceipts.Value, data.PurchaseId, 1, true) ~= nil then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end

			if playerByUserId:GetAttribute("SaveDisabled") == true or playerByUserId:GetAttribute("SaveDisabledSlot") == true then
				receiptLine(data, playerByUserId, "ReceiptRefused", v11, "no-persist session") -- equivalent call inferred; original call site unknown
				return Enum.ProductPurchaseDecision.NotProcessedYet
			else
				if consumedReceipts ~= nil then
					local purchaseIds = string.split(consumedReceipts.Value, ",")
					table.insert(purchaseIds, data.PurchaseId)

					while #purchaseIds > 50 do
						table.remove(purchaseIds, 1)
					end

					consumedReceipts.Value = table.concat(purchaseIds, ",")
				end

				local function unreserve()
					if consumedReceipts == nil then
						return
					end

					local v13 = string.split(consumedReceipts.Value, ",")
					local index = table.find(v13, data.PurchaseId)

					if index ~= nil then
						table.remove(v13, index)
						consumedReceipts.Value = table.concat(v13, ",")
					end
				end

				local v13 = Shop.itemsforsale[v11]
				local v14 = v13 == nil and {
					Type = "Item",
					Price = {
						Product = data.ProductId
					}
				} or v13
				v5 = v5 or require(script.Parent.VipAccess)

				if v14.RequiresVIP == true and not v5.Has(playerByUserId) then
					warn((`Shop: receipt for "{v11}" (product {data.ProductId}, {playerByUserId.Name}) refused: VIP required`))
					receiptLine(data, playerByUserId, "ReceiptRefused", v11, "VIP required") -- equivalent call inferred; original call site unknown
					unreserve()
					return Enum.ProductPurchaseDecision.NotProcessedYet
				else
					local productId = data.ProductId
					local v15 = object3[playerByUserId]
					local value

					if v15 ~= nil then
						value = v15[productId] or nil
					end

					local v16

					if value == nil then
						local _, v17 = Utility.GetData(playerByUserId)
						local pendingGifts

						if v17 ~= nil then
							pendingGifts = v17:FindFirstChild("PendingGifts")
						end

						local child = pendingGifts ~= nil and pendingGifts:FindFirstChild((tostring(productId))) or nil

						if child == nil then
							value = nil
							v16 = false
						else
							value = child.Value
							v16 = true
						end
					else
						v16 = false
					end

					local v17, v18

					if value == nil then
						v17 = data2
						v18 = playerByUserId
					else
						v18 = Shop.ResolveGiftRecipient(playerByUserId, v11, value)

						if v18 ~= nil then
							v17 = Utility.GetData(v18) or nil
						end

						if v18 == nil or v17 == nil then
							if v14.AskFirst == true then
								warn((`Shop: gift of "{v11}" to {value} held, they are not in this server`))
								receiptLine(data, playerByUserId, "ReceiptRefused", v11, `gift recipient {value} away`) -- equivalent call inferred; original call site unknown
								unreserve()
								return Enum.ProductPurchaseDecision.NotProcessedYet
							else
								v17 = data2
								v18 = playerByUserId
							end
						elseif v14.AskFirst == true and v16 and not Shop.GiftConsent(playerByUserId, v18, v11, value) then
							receiptLine(
								data,
								playerByUserId,
								"ReceiptRefused",
								v11,
								`gift consent from {value} expired`
							) -- equivalent call inferred; original call site unknown
							unreserve()
							return Enum.ProductPurchaseDecision.NotProcessedYet
						end
					end

					local success, result, v19 = pcall(Shop.OrderProcessers[v14.Type], v18, v17, v11, 1, v14)

					if not success then
						v19 = result
						result = false
					end

					if result then
						for k, v20 in v14.Price do
							local cashier = Shop.cashiers[k]

							if cashier == nil then
								warn((`Shop: no cashier for currency "{k}", listing refused`))
							end

							if cashier == nil or cashier.Deferred then
								continue
							end

							cashier.Buy(data2, pricedFor(playerByUserId, k, v20, 1), playerByUserId, v11)
						end

						local productId2 = data.ProductId
						local v20 = object3[playerByUserId]

						if v20 ~= nil then
							v20[productId2] = nil
						end

						local _, v21 = Utility.GetData(playerByUserId)
						local pendingGifts

						if v21 ~= nil then
							pendingGifts = v21:FindFirstChild("PendingGifts")
						end

						local child

						if pendingGifts ~= nil then
							child = pendingGifts:FindFirstChild((tostring(productId2))) or nil
						end

						if child ~= nil then
							child:Destroy()
						end

						if v18 ~= playerByUserId then
							giftNotify(playerByUserId, v18, v11)
						end

						local v22

						if v18 ~= playerByUserId then
							v22 = `gift to {v18.Name}`
						end

						receiptLine(data, playerByUserId, "ReceiptGranted", v11, v22) -- equivalent call inferred; original call site unknown
						return Enum.ProductPurchaseDecision.PurchaseGranted
					else
						warn((`Shop: receipt for "{v11}" (product {data.ProductId}, {playerByUserId.Name}) not granted: {tostring(v19)}`))
						receiptLine(data, playerByUserId, "ReceiptRefused", v11, `not granted: {tostring(v19)}`) -- equivalent call inferred; original call site unknown
						unreserve()
						return Enum.ProductPurchaseDecision.NotProcessedYet
					end
				end
			end
		end
	end
end

return Shop