local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local X2BoostConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("X2BoostConfig"))
local Ads = require(ReplicatedStorage:WaitForChild("Monetization"):WaitForChild("Ads"))
local MarketplaceInfoCache = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("MarketplaceInfoCache"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local x2BoostSync = remotes:WaitForChild("X2BoostSync")
local localPlayer = Players.LocalPlayer
local X2BoostUISystem = {}
local flag = false
local thread = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function formatTime(remaining: number)
	local v = math.floor(remaining / 60)
	local v2 = math.floor(remaining % 60)
	return string.format("%02d:%02d", v, v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRemaining()
	local x2BoostExpiresAt = ClientState:Get().X2BoostExpiresAt

	if x2BoostExpiresAt then
		return (math.max(0, x2BoostExpiresAt - os.time()))
	end

	return 0
end

function X2BoostUISystem:UpdateDisplay()
	local remaining = getRemaining() -- equivalent call inferred; original call site unknown
	local v = remaining > 0

	for _, guiObject in ipairs(CollectionService:GetTagged("X2BoostTimerLabel")) do
		if not (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) then
			continue
		end

		if v then
			guiObject.Text = "x2 Active — " .. formatTime(remaining)
			guiObject.Visible = true
		else
			guiObject.Text = ""
			guiObject.Visible = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startTimer()
	if thread then
		return
	end

	thread = task.spawn(function()
		while true do
			if not (getRemaining() > 0) then
				break
			end

			X2BoostUISystem:UpdateDisplay()
			task.wait(1)
		end

		X2BoostUISystem:UpdateDisplay()
		thread = nil
	end)
end

local v = {
	Buy10Min = X2BoostConfig.PRODUCTS[1].ProductId,
	Buy30Min = X2BoostConfig.PRODUCTS[2].ProductId,
	Buy1Hour = X2BoostConfig.PRODUCTS[3].ProductId
}

local function handleBuyButton(instance)
	if instance:GetAttribute("IsConnected") then
		return
	end

	instance:SetAttribute("IsConnected", true)
	local v2 = v[instance:GetAttribute("Action")]
	local price = instance:FindFirstChild("Price")

	if price and v2 then
		MarketplaceInfoCache.Request(v2, Enum.InfoType.Product, function(p)
			if p and p.PriceInRobux then
				price.Text = tostring(p.PriceInRobux)
			end
		end)
	end

	instance.MouseButton1Click:Connect(function()
		if v2 then
			MarketplaceService:PromptProductPurchase(localPlayer, v2)
		end
	end)
end

local flag2 = false
local v2 = nil
local v3 = nil
local v4 = nil
local thread2 = nil
local color = Color3.fromRGB(128, 128, 128)

-- equivalent calls inferred from this helper; original call sites unknown
local function setAdBtnGrayed(flag3: boolean)
	if not v2 then
		return
	end

	if flag3 then
		v3 = v3 or v2.ImageColor3
		v4 = v4 or v2.BackgroundColor3
		v2.AutoButtonColor = false
		v2.ImageColor3 = color
		v2.BackgroundColor3 = color
	else
		v2.AutoButtonColor = true
		v2.ImageColor3 = v3 or Color3.new(1, 1, 1)
		v2.BackgroundColor3 = v4 or Color3.new(1, 1, 1)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startAdPoll()
	if thread2 then
		return
	end

	thread2 = task.spawn(function()
		repeat
			task.wait(30)
		until Ads.checkForAds()

		flag2 = false
		setAdBtnGrayed(false) -- equivalent call inferred; original call site unknown
		thread2 = nil
	end)
end

local function onDebounceEnd()
	task.spawn(function()
		if Ads.checkForAds() then
			flag2 = false
			setAdBtnGrayed(false) -- equivalent call inferred; original call site unknown
		else
			startAdPoll() -- equivalent call inferred; original call site unknown
		end
	end)
end

local function setupAdRewardButton(instance)
	if instance:GetAttribute("IsConnected") then
		return
	end

	instance:SetAttribute("IsConnected", true)
	v2 = instance
	task.spawn(function()
		if not Ads.checkForAds() then
			flag2 = true
			setAdBtnGrayed(true) -- equivalent call inferred; original call site unknown
			startAdPoll() -- equivalent call inferred; original call site unknown
		end

		instance.MouseButton1Click:Connect(function()
			if flag2 then
				return
			end

			flag2 = true
			setAdBtnGrayed(true) -- equivalent call inferred; original call site unknown
			local requestAdX2Boost = remotes:FindFirstChild("RequestAdX2Boost")

			if requestAdX2Boost then
				requestAdX2Boost:FireServer()
			end

			task.delay(30, onDebounceEnd)
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function handleButton(button)
	if button:GetAttribute("Action") == "AdReward10Min" then
		setupAdRewardButton(button)
	else
		handleBuyButton(button)
	end
end

function X2BoostUISystem:InitLogic()
	if flag then
		return
	end

	flag = true
	x2BoostSync.OnClientEvent:Connect(function(p)
		if type(p) == "table" and p.expiresAt then
			ClientState:Update({
				X2BoostExpiresAt = p.expiresAt
			})
			startTimer() -- equivalent call inferred; original call site unknown
		else
			ClientState:Update({
				X2BoostExpiresAt = nil
			})
		end

		self:UpdateDisplay()
	end)

	for _, button in ipairs(CollectionService:GetTagged("x2BoostButton")) do
		if not button:IsA("GuiButton") then
			continue
		end

		handleButton(button) -- equivalent call inferred; original call site unknown
	end

	CollectionService:GetInstanceAddedSignal("x2BoostButton"):Connect(function(button)
		if button:IsA("GuiButton") then
			handleButton(button) -- equivalent call inferred; original call site unknown
		end
	end)
	self:UpdateDisplay()
end

return X2BoostUISystem