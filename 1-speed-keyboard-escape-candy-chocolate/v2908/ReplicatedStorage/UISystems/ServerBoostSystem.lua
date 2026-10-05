local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerBoostConfig = require(ReplicatedStorage.FeatureConfigs.ServerBoostConfig)
local Config = require(ReplicatedStorage.Config)
local BonusManager = require(ReplicatedStorage.BonusManager)
local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
local remo = require(ReplicatedStorage.Packages.remo)
local SoundManager = require(ReplicatedStorage.SoundManager)
local MarketplaceInfoCache = require(ReplicatedStorage.Utilities.MarketplaceInfoCache)
local ProfileStore

if RunService:IsServer() then
	ProfileStore = require(ServerScriptService.ProfileStore)
else
	ProfileStore = nil
end

local remotes = remo.createRemotes({
	RequestServerBoostPurchase = remo.remote(),
	ReceiveFreeServerBoostList = remo.remote()
})
local ServerBoostSystem = {}
local flag = false
local fn
local v = {}
local v2 = {}
local flag2 = false
local flag3 = true
local v3 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getServerBoostXPEntry()
	local serverBoost = BonusManager:GetActiveServerBonuses().ServerBoost
	local XP = serverBoost and serverBoost.XP

	if XP then
		return {
			kind = "ServerBoost",
			mult = XP.mult,
			endTime = XP.endTime
		}
	end

	return nil
end

local function getRemaining(p)
	if not p then
		return 0
	end

	if p.currentEndsAt then
		return BonusManager:GetRemainingTime(p.currentEndsAt)
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getConfiguredProduct(p: number?)
	if p then
		return ServerBoostConfig.GetProducts()[p]
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getProductById(p: number)
	for _, v4 in ipairs(ServerBoostConfig.GetProducts()) do
		if v4.ProductId == p then
			return v4
		end
	end

	return nil
end

local function getProductIndexForMultiplier(p: number?)
	if not p then
		return nil
	end

	for i, v4 in ipairs(ServerBoostConfig.GetProducts()) do
		if v4.Multiplier == p then
			return i
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getNextProductId(p)
	if not p then
		local v4 = ServerBoostConfig.GetProducts()[1]
		return v4 and v4.ProductId or nil
	end

	if p.nextProductId and p.nextProductId ~= 0 then
		return p.nextProductId
	end

	local configuredProduct = getConfiguredProduct(p.nextProductIndex) -- equivalent call inferred; original call site unknown
	return configuredProduct and configuredProduct.ProductId or nil
end

local function getNextMultiplier(p)
	if not p then
		local v4 = ServerBoostConfig.GetProducts()[1]
		return v4 and v4.Multiplier or nil
	end

	if p.nextMultiplier then
		return p.nextMultiplier
	end

	local configuredProduct = getConfiguredProduct(p.nextProductIndex) -- equivalent call inferred; original call site unknown
	return configuredProduct and configuredProduct.Multiplier or nil
end

local function readServerBoostState()
	local serverBoostXPEntry = getServerBoostXPEntry() -- equivalent call inferred; original call site unknown

	if serverBoostXPEntry then
		local mult = serverBoostXPEntry.mult
		local v4

		if mult then
			for i, v6 in ipairs(ServerBoostConfig.GetProducts()) do
				if v6.Multiplier ~= mult then
					continue
				end

				v4 = i
				break
			end
		end

		local nextProductIndex

		if v4 then
			nextProductIndex = v4 + 1
		end

		local configuredProduct = getConfiguredProduct(nextProductIndex) -- equivalent call inferred; original call site unknown
		local v6 = {
			currentMultiplier = serverBoostXPEntry.mult,
			currentEndsAt = serverBoostXPEntry.endTime,
			nextProductIndex = nextProductIndex,
			nextProductId = 0,
			nextMultiplier = 0,
			maxed = 0
		}
		local nextProductId

		if configuredProduct then
			nextProductId = configuredProduct.ProductId or nil
		end

		v6.nextProductId = nextProductId
		local nextMultiplier

		if configuredProduct then
			nextMultiplier = configuredProduct.Multiplier or nil
		end

		v6.nextMultiplier = nextMultiplier
		v6.maxed = configuredProduct == nil
		return v6
	else
		local v5 = ServerBoostConfig.GetProducts()[1]
		local v4 = {
			nextProductIndex = 1,
			nextProductId = v5 and v5.ProductId or nil,
			nextMultiplier = 0,
			maxed = false
		}
		local v6 = ServerBoostConfig.GetProducts()[1]
		v4.nextMultiplier = v6 and v6.Multiplier or nil
		return v4
	end
end

local function getNextProduct(p)
	local nextProductId = getNextProductId(p or readServerBoostState()) -- equivalent call inferred; original call site unknown

	if not nextProductId then
		return nil
	end

	for _, v5 in ipairs(ServerBoostConfig.GetProducts()) do
		if v5.ProductId == nextProductId then
			return v5
		end
	end

	return nil
end

local function checkLadderPurchaseAllowed(p, p2)
	local currentMultiplier = p2.currentMultiplier or 1

	if ServerBoostConfig.GetAddTime() and p.Multiplier == currentMultiplier and currentMultiplier > 1 then
		return true, ""
	end

	local nextMultiplier = p2.nextMultiplier

	if nextMultiplier and p.Multiplier == nextMultiplier then
		return true, ""
	end

	return
		false,
		string.format(
			"ladder mismatch: bought x%d on x%d server (next x%s)",
			p.Multiplier,
			currentMultiplier,
			not nextMultiplier and "max" or tostring(nextMultiplier)
		)
end

local function checkProductPurchaseAllowed(p, p2)
	local productById = getProductById(p.ProductId) -- equivalent call inferred; original call site unknown

	if productById == nil then
		return false, "product not configured for this world"
	end

	if not flag3 then
		return false, "purchases disabled"
	end

	if flag2 then
		return false, "shutdown"
	end

	return checkLadderPurchaseAllowed(p, p2)
end

local function refundAsFreeBoost(p, p2)
	NotificationSystem:ShowGeneralNotificationForPlayer(
		p,
		"An error occured with your purchase.",
		Color3.fromRGB(255, 86, 86),
		10
	)
	NotificationSystem:ShowGeneralNotificationForPlayer(
		p,
		`You've been granted a x{p2.Multiplier} free server boost.`,
		Color3.fromRGB(100, 255, 86),
		10
	)
	ServerBoostSystem.GrantFreeServerBoost(p, p2.ProductId)
end

local function applyProductPurchase(p, data, p2)
	local duration = data.Duration

	if ServerBoostConfig.GetAddTime() and data.Multiplier >= (p2.currentMultiplier or 1) then
		duration += ServerBoostSystem.GetRemainingTime(p2)
	end

	BonusManager:StopBonus("server", "XP", nil, "ServerBoost")
	BonusManager:ActivateBonus("server", "XP", data.Multiplier, duration, nil, "ServerBoost")
	NotificationSystem:ShowGeneralNotificationForEveryone(
		`{p.DisplayName} bought x{data.Multiplier} XP for everyone in the server!`,
		Color3.fromRGB(86, 165, 255),
		6
	)
	SoundManager:PlayForEveryone("NOTIF2")

	if not v2[p] then
		v2[p] = {}
	end

	table.insert(v2[p], data.ProductId)
	task.delay(data.Duration, function()
		local v4 = v2[p]

		if not v4 then
			return
		end

		local index = table.find(v4, data.ProductId)

		if index then
			table.remove(v4, index)
		end

		if #v4 == 0 then
			v2[p] = nil
		end
	end)
end

local function promptServerBoostPurchase(p)
	if not flag3 then
		NotificationSystem:ShowGeneralNotificationForPlayer(
			p,
			"Server Boost Purchases are currently disabled...",
			Color3.fromRGB(255, 100, 100),
			4
		)
		return
	end

	local nextProductId = getNextProductId(readServerBoostState() or readServerBoostState()) -- equivalent call inferred; original call site unknown
	local v5

	if nextProductId then
		for _, v7 in ipairs(ServerBoostConfig.GetProducts()) do
			if v7.ProductId ~= nextProductId then
				continue
			end

			v5 = v7
			break
		end
	end

	if not v5 or v5.ProductId == 0 then
		warn("[ServerBoostUISystem] No valid next server boost product for " .. p.Name)
		return
	end

	local amountOfFreeServerBoost = ServerBoostSystem.GetAmountOfFreeServerBoost(p)

	if amountOfFreeServerBoost[tostring(v5.ProductId)] and amountOfFreeServerBoost[tostring(v5.ProductId)] >= 1 then
		ServerBoostSystem.SetAmountOfFreeServerBoost(
			p,
			v5.ProductId,
			amountOfFreeServerBoost[tostring(v5.ProductId)] - 1
		)
		ServerBoostSystem.ProductPurchased(p, (ServerBoostConfig.GetProductConfigByProductId(v5.ProductId)))
	else
		MarketplaceService:PromptProductPurchase(p, v5.ProductId)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCachedProductInfo(productId: number)
	return (MarketplaceInfoCache.GetCached(productId, Enum.InfoType.Product))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function loadProductInfo(productId: number)
	if MarketplaceInfoCache.GetCached(productId, Enum.InfoType.Product) then
		return
	end

	MarketplaceInfoCache.Request(productId, Enum.InfoType.Product, function(p)
		if p and fn then
			fn()
		end
	end)
end

local function preloadProductInfo()
	for _, v4 in ipairs(ServerBoostConfig.GetProducts()) do
		if not (v4.ProductId and v4.ProductId ~= 0) then
			continue
		end

		loadProductInfo(v4.ProductId) -- equivalent call inferred; original call site unknown
	end
end

local function findPriceLabel(buttonUI)
	local price = buttonUI:FindFirstChild("Price", true)

	if price and (price:IsA("TextLabel") or price:IsA("TextButton")) then
		return price
	end

	local priceLabel = buttonUI:FindFirstChild("PriceLabel", true)

	if priceLabel and (priceLabel:IsA("TextLabel") or priceLabel:IsA("TextButton")) then
		return priceLabel
	end

	return nil
end

local function setButtonEnabled(button, flag4: boolean)
	button.Active = flag4
	button.AutoButtonColor = flag4

	if button:IsA("ImageButton") then
		button.ImageTransparency = flag4 and 0 or 0.45
	elseif button:IsA("TextButton") then
		button.TextTransparency = flag4 and 0 or 0.45
	end
end

local function getUI()
	assert(RunService:IsClient(), "GetUI cannot be called through Server.")
	local success, result = pcall(function()
		return Players.LocalPlayer.PlayerGui:WaitForChild("SpeedGameUI", 60).Modals.RobuxShopModal.ScrollingFrame.ServerBoost
	end)

	if success then
		return result
	end

	return warn("Couldn't find RobuxShopModal", result)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function connectBuyButton(buttonUI)
	if buttonUI:GetAttribute("IsConnected22") then
		return
	end

	buttonUI:SetAttribute("IsConnected22", true)
	buttonUI.MouseButton1Click:Connect(function()
		ServerBoostSystem.RequestPurchase()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getButtonUI()
	local UI = getUI()

	if UI then
		return UI.Ctn.MainFrame.BtnCtn.Buy
	end

	return nil
end

fn = function()
	local state = ServerBoostSystem.GetState()
	local buttonUI = getButtonUI() -- equivalent call inferred; original call site unknown

	if not (buttonUI and buttonUI:IsA("GuiButton")) then
		return
	end

	local nextProduct = ServerBoostSystem.GetNextProduct(state)
	local canPurchase = ServerBoostSystem.CanPurchase(state)
	local priceLabel = findPriceLabel(buttonUI)
	buttonUI.Active = canPurchase
	buttonUI.AutoButtonColor = canPurchase

	if buttonUI:IsA("ImageButton") then
		buttonUI.ImageTransparency = canPurchase and 0 or 0.45
	elseif buttonUI:IsA("TextButton") then
		buttonUI.TextTransparency = canPurchase and 0 or 0.45
	end

	if nextProduct then
		buttonUI:SetAttribute("ProductId", nextProduct.ProductId)
		loadProductInfo(nextProduct.ProductId) -- equivalent call inferred; original call site unknown
	else
		buttonUI:SetAttribute("ProductId", nil)
	end

	if state.maxed then
		if priceLabel then
			priceLabel.Text = "MAX"
		elseif buttonUI:IsA("TextButton") then
			buttonUI.Text = "MAX"
		end
	elseif nextProduct then
		local cachedProductInfo = getCachedProductInfo(nextProduct.ProductId) -- equivalent call inferred; original call site unknown
		local text = not (cachedProductInfo and cachedProductInfo.PriceInRobux) and "..." or tostring(cachedProductInfo.PriceInRobux)

		if priceLabel then
			priceLabel.Text = text
		elseif buttonUI:IsA("TextButton") then
			buttonUI.Text = text
		end

		connectBuyButton(buttonUI) -- equivalent call inferred; original call site unknown
	elseif priceLabel then
		priceLabel.Text = "N/A"
	elseif buttonUI:IsA("TextButton") then
		buttonUI.Text = "N/A"
	end
end

local function updateFreeBoostDisplay()
	local UI = getUI()

	if not UI then
		return
	end

	local freeboost = UI.Ctn.MainFrame.BtnCtn.Freeboost
	local txt = freeboost.Txt
	local amountOfFreeServerBoost = ServerBoostSystem.GetAmountOfFreeServerBoost(Players.LocalPlayer)
	local v4 = {}

	for k, v5 in amountOfFreeServerBoost do
		if v5 <= 0 then
			continue
		end

		local productConfig = ServerBoostConfig.GetProductConfigByProductId(tonumber(k) or 0)

		if not productConfig then
			continue
		end

		local clone = freeboost:FindFirstChild((tostring(k)))

		if not clone then
			clone = txt:Clone()
			clone.Name = tostring(k)
			clone.LayoutOrder = productConfig.Multiplier
			clone.Parent = freeboost
			clone.Visible = true
		end

		clone.Text = `Free x{productConfig.Multiplier} boost: {v5}`
		v4[clone] = true
	end

	for _, label in freeboost:GetChildren() do
		if not label:IsA("TextLabel") or v4[label] or label == txt then
			continue
		end

		label:Destroy()
	end
end

local function updateUIDisplay()
	local UI = getUI()

	if not UI then
		return
	end

	local state = ServerBoostSystem.GetState()
	local buttonUI = getButtonUI() -- equivalent call inferred; original call site unknown
	local multiplierCtn = UI.Ctn.MainFrame.MultiplierCtn
	local timer = UI.Ctn.MainFrame.BtnCtn.Timer
	local nextProduct = ServerBoostSystem.GetNextProduct(state)

	if nextProduct then
		timer.Visible = true
		timer.Text = `Lasts {math.floor((nextProduct.Duration or 0) / 60)}min!`
	else
		timer.Visible = false
	end

	if fn then
		fn()
	end

	updateFreeBoostDisplay()

	if state.maxed then
		multiplierCtn.Middle.Visible = false
		multiplierCtn.Before.Visible = false

		if buttonUI then
			buttonUI.Visible = false
		end

		multiplierCtn.After.TextLabel.Text = `{state.currentMultiplier or 1}x`
	else
		multiplierCtn.Middle.Visible = true
		multiplierCtn.Before.Visible = true

		if buttonUI then
			buttonUI.Visible = true
		end

		multiplierCtn.After.TextLabel.Text = `{state.nextMultiplier}x`
		multiplierCtn.Before.TextLabel.Text = `{state.currentMultiplier or 1}x`
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkShutdownRefundAllowed(p: string)
	return p == "Shutdown" and ProfileStore.CloseReason ~= Enum.CloseReason.ServerEmpty
end

local function applyShutdownRefundsToProfile(p, p2)
	local v4 = v2[p]

	if not v4 then
		return
	end

	local freeServerBoost = p2.Data.FreeServerBoost
	local v5 = false

	for _, v6 in v4 do
		freeServerBoost[tostring(v6)] = (freeServerBoost[tostring(v6)] or 0) + 1
		v5 = true
	end

	v2[p] = nil

	if v5 and p.Parent == Players then
		NotificationSystem:ShowGeneralNotificationForPlayer(
			p,
			"Your server boost purchase was restored after a server shutdown.",
			Color3.fromRGB(100, 255, 86),
			10
		)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindShutdownRefundOnLastSave(p, p2)
	p2.OnLastSave:Connect(function(p3: string)
		-- equivalent call inferred; original call site unknown
		if checkShutdownRefundAllowed(p3) then
			applyShutdownRefundsToProfile(p, p2)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function prepareForShutdown()
	if not v3 then
		v3 = true
		flag2 = true
		ServerBoostSystem.ClearAllBoosts()
	end
end

function ServerBoostSystem.ProductPurchased(p, p2)
	assert(RunService:IsServer(), "[ServerBoostSystem] ProductPurchased can only be called by the server")
	local v4 = readServerBoostState()
	local productById = getProductById(p2.ProductId) -- equivalent call inferred; original call site unknown
	local v5, v6

	if productById == nil then
		v5 = false
		v6 = "product not configured for this world"
	elseif flag3 then
		if flag2 then
			v5 = false
			v6 = "shutdown"
		else
			v5, v6 = checkLadderPurchaseAllowed(p2, v4)
		end
	else
		v5 = false
		v6 = "purchases disabled"
	end

	if v5 then
		applyProductPurchase(p, p2, v4)
	else
		warn("[ServerBoostSystem]", v6, p.Name)
		refundAsFreeBoost(p, p2)
	end

	return true
end

function ServerBoostSystem.GrantFreeServerBoost(p, p2: number, value: number?)
	assert(RunService:IsServer(), "GrantFreeServerBoost can only be called on server.")

	if p2 ~= 0 then
		local productById = getProductById(p2) -- equivalent call inferred; original call site unknown

		if productById ~= nil then
			local amountOfFreeServerBoost = ServerBoostSystem.GetAmountOfFreeServerBoost(p)
			ServerBoostSystem.SetAmountOfFreeServerBoost(
				p,
				p2,
				(amountOfFreeServerBoost[tostring(p2)] or 0) + (value or 1)
			)
			return
		end
	end

	warn("[ServerBoostSystem] Ignored free boost grant for product", p2, "on world", Config.WORLD)
end

function ServerBoostSystem.GetAmountOfFreeServerBoost(p)
	if not RunService:IsServer() then
		assert(p == Players.LocalPlayer, "Cannot get amount of freeboost for other players on client side.")
		return v or {}
	end

	local DataManager = require(ServerScriptService.DataManager)
	local playerData = DataManager:GetPlayerData(p)

	if playerData then
		return playerData.FreeServerBoost or {}
	end

	return {}
end

function ServerBoostSystem.SetAmountOfFreeServerBoost(p, p2: number, p3: number)
	assert(RunService:IsServer(), "SetAmountOfFreeServerBoost can only be called on server.")
	local DataManager = require(ServerScriptService.DataManager)
	local playerData = DataManager:GetPlayerData(p)

	if playerData then
		playerData.FreeServerBoost[tostring(p2)] = math.max(p3, 0)

		if playerData.FreeServerBoost[tostring(p2)] == 0 then
			playerData.FreeServerBoost[tostring(p2)] = nil
		end

		if p.Parent == Players then
			remotes.ReceiveFreeServerBoostList:fire(p, ServerBoostSystem.GetAmountOfFreeServerBoost(p))
		end
	end
end

function ServerBoostSystem.LockDownForShutdown(_)
	prepareForShutdown() -- equivalent call inferred; original call site unknown
end

function ServerBoostSystem.ClearAllBoosts()
	assert(RunService:IsServer(), "ClearAllBoosts can only be called on server.")
	BonusManager:StopBonus("server", "XP", nil, "ServerBoost")
	return true
end

function ServerBoostSystem.GetState()
	return (readServerBoostState())
end

function ServerBoostSystem.GetRemainingTime(p)
	return getRemaining(p or readServerBoostState())
end

function ServerBoostSystem.HasActiveBoost()
	return ServerBoostSystem.GetRemainingTime() > 0
end

function ServerBoostSystem.GetNextProduct(p)
	local nextProductId = getNextProductId(p or readServerBoostState()) -- equivalent call inferred; original call site unknown

	if not nextProductId then
		return nil
	end

	for _, v5 in ipairs(ServerBoostConfig.GetProducts()) do
		if v5.ProductId == nextProductId then
			return v5
		end
	end

	return nil
end

function ServerBoostSystem.CanPurchase(p)
	local v4 = p or readServerBoostState()
	local nextProductId = getNextProductId(v4 or readServerBoostState()) -- equivalent call inferred; original call site unknown
	local v6

	if nextProductId then
		for _, v8 in ipairs(ServerBoostConfig.GetProducts()) do
			if v8.ProductId ~= nextProductId then
				continue
			end

			v6 = v8
			break
		end
	end

	return v6 ~= nil and v6.ProductId ~= 0 and v4.maxed ~= true
end

function ServerBoostSystem.RequestPurchase()
	if not RunService:IsClient() then
		return false
	end

	local v4 = readServerBoostState()

	if v4.maxed then
		NotificationSystem:ShowGeneralNotification(
			"Server boost is already at maximum.",
			Color3.fromRGB(255, 100, 100),
			4
		)
		return false
	end

	local nextProductId = getNextProductId(v4 or readServerBoostState()) -- equivalent call inferred; original call site unknown
	local v6

	if nextProductId then
		for _, v8 in ipairs(ServerBoostConfig.GetProducts()) do
			if v8.ProductId ~= nextProductId then
				continue
			end

			v6 = v8
			break
		end
	end

	if v6 and v6.ProductId ~= 0 then
		remotes.RequestServerBoostPurchase:fire()
		return true
	end

	NotificationSystem:ShowGeneralNotification(
		"No server boost available for this world.",
		Color3.fromRGB(255, 100, 100),
		4
	)
	return false
end

function ServerBoostSystem.InitLogic()
	if flag then
		return
	end

	flag = true

	if RunService:IsServer() then
		remotes.RequestServerBoostPurchase:connect(function(p)
			promptServerBoostPurchase(p)
		end)
	else
		remotes.ReceiveFreeServerBoostList:connect(function(p)
			v = p
			updateUIDisplay()
		end)
	end

	if RunService:IsServer() then
		local DataManager = require(ServerScriptService.DataManager)
		DataManager.profileLoaded:Connect(function(p, p2)
			bindShutdownRefundOnLastSave(p, p2) -- equivalent call inferred; original call site unknown
			task.wait(5)
			remotes.ReceiveFreeServerBoostList:fire(p, ServerBoostSystem.GetAmountOfFreeServerBoost(p))
		end)
		game.ServerRestartScheduled:Connect(function(p)
			local v4 = p.UnixTimestamp - workspace:GetServerTimeNow() - ServerBoostConfig.SHUTDOWN_SCHEDULE_DISALLOW_PURCHASE_TIME

			if v4 <= 0 then
				flag3 = false
			else
				task.delay(v4, function()
					flag3 = false
				end)
			end
		end)
		Players.PlayerRemoving:Connect(function(player)
			task.wait(1)
			v2[player] = nil
		end)
	else
		preloadProductInfo()
		updateUIDisplay()
		BonusManager.Changed:Connect(updateUIDisplay)
	end
end

return ServerBoostSystem