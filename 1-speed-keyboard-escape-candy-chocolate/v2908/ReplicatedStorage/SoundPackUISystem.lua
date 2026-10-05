local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local SoundPacks = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("SoundPacks"))
local components = ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("Components")
local SoundPacksView = require(components:WaitForChild("SoundPacksView"))
local GamepassPrices = require(components:WaitForChild("GamepassPrices"))
local localPlayer = Players.LocalPlayer
local SoundPackUISystem = {}
local v = nil
local v2 = {}
local prices = {}
local isForSales = {}
local v3 = {}
local attribute = localPlayer:GetAttribute(SoundPacks.ATTRIBUTE_NAME)

if type(attribute) ~= "string" or not SoundPacks.GetSound(attribute) then
	localPlayer:SetAttribute(SoundPacks.ATTRIBUTE_NAME, SoundPacks.DEFAULT_SOUND)
end

local function gamepassIdFor(p: string?)
	if not p then
		return nil
	end

	local v4 = Config.GAMEPASS_IDS[p]

	if v4 and v4 ~= 0 then
		return v4
	end

	return nil
end

local function isPackUnlocked(_: string, p)
	if p.unlock.type == "Free" then
		return true
	end

	local gamepassKey = p.unlock.gamepassKey
	return gamepassKey ~= nil and v2[gamepassKey] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function promptPackGamepass(p: string)
	local pack = SoundPacks.GetPack(p)

	if pack then
		local gamepassKey = pack.unlock.gamepassKey

		if gamepassKey then
			pack = Config.GAMEPASS_IDS[gamepassKey]

			if not pack or pack == 0 then
				pack = nil
			end
		else
			pack = nil
		end
	end

	if pack then
		MarketplaceService:PromptGamePassPurchase(localPlayer, pack)
	end
end

local function updatePackVisibility()
	if not v then
		return
	end

	for _, v4 in ipairs(SoundPacks.GetSortedPacks()) do
		local pack = v4.pack

		if pack.unlock.type ~= "Gamepass" then
			continue
		end

		local gamepassKey = pack.unlock.gamepassKey
		local v5

		if gamepassKey == nil then
			v5 = false
		else
			v5 = v2[gamepassKey] == true
		end

		local v6 = gamepassKey == nil or v3[gamepassKey] == true
		local v7 = gamepassKey == nil or isForSales[gamepassKey] ~= false
		v:SetPackVisible(v4.key, v5 or v6 and v7)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshGamepassStateAsync()
	task.spawn(function()
		local v4 = false

		for _, v5 in ipairs(SoundPacks.GetRequiredGamepassKeys()) do
			local v6

			if v5 then
				v6 = Config.GAMEPASS_IDS[v5]

				if not v6 or v6 == 0 then
					v6 = nil
				end
			end

			if v6 then
				if not v2[v5] then
					local success, result = pcall(
						MarketplaceService.UserOwnsGamePassAsync,
						MarketplaceService,
						localPlayer.UserId,
						v6
					)

					if success and result then
						v2[v5] = true
						v4 = true
					end
				end

				local infoAsync = GamepassPrices.GetInfoAsync(v6)

				if infoAsync then
					if infoAsync.price and prices[v5] ~= infoAsync.price then
						prices[v5] = infoAsync.price
						v4 = true
					end

					if isForSales[v5] ~= infoAsync.isForSale then
						isForSales[v5] = infoAsync.isForSale
						v4 = true
					end
				end
			end

			if v3[v5] then
				continue
			end

			v3[v5] = true
			v4 = true
		end

		if v4 and v then
			v:RefreshLocks()
			updatePackVisibility()
		end
	end)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if p ~= localPlayer or not p3 then
		return
	end

	for _, v4 in ipairs(SoundPacks.GetRequiredGamepassKeys()) do
		local v5

		if v4 then
			v5 = Config.GAMEPASS_IDS[v4]

			if not v5 or v5 == 0 then
				v5 = nil
			end
		end

		if v5 ~= p2 then
			continue
		end

		v2[v4] = true

		if v then
			v:RefreshLocks()
			updatePackVisibility()
		end

		break
	end
end)
local random = Random.new()
local v4 = 0

local function previewSound(p: string)
	local now = os.clock()

	if now - v4 < SoundPacks.PREVIEW_COOLDOWN then
		return
	end

	v4 = now
	local randomAsset = SoundPacks.PickRandomAsset(SoundPacks.ResolveSoundAssets(p), random)
	local sound = Instance.new("Sound")
	sound.SoundId = randomAsset.assetId
	sound.Volume = SoundPacks.PREVIEW_VOLUME * randomAsset.volume
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
	task.delay(3, function()
		if sound.Parent then
			sound:Destroy()
		end
	end)
end

local function findModal()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return nil
	end

	for _, guiObject in ipairs(CollectionService:GetTagged("SoundPackModal")) do
		if guiObject:IsA("GuiObject") and guiObject:IsDescendantOf(playerGui) then
			return guiObject
		end
	end

	return nil
end

function SoundPackUISystem:UpdateDisplay()
	if not v then
		return
	end

	v:SetEquipped((localPlayer:GetAttribute(SoundPacks.ATTRIBUTE_NAME)))
	v:RefreshLocks()
	updatePackVisibility()
end

function SoundPackUISystem:InitLogic()
	if v then
		self:UpdateDisplay()
		refreshGamepassStateAsync() -- equivalent call inferred; original call site unknown
	else
		local modal = findModal()

		if not modal then
			warn("[SoundPackUISystem] Modal taggé 'SoundPackModal' introuvable")
			return
		end

		v = SoundPacksView.Hydrate(modal, {
			equipped = localPlayer:GetAttribute(SoundPacks.ATTRIBUTE_NAME),
			isPackUnlocked = isPackUnlocked,
			getPriceText = function(_, p)
				local v5 = p.unlock.gamepassKey and prices[p.unlock.gamepassKey]
				return v5 and GamepassPrices.Format(v5) or nil
			end,
			onSoundActivated = function(p, _, p2, p3)
				if p2 then
					promptPackGamepass(p3) -- equivalent call inferred; original call site unknown
				else
					localPlayer:SetAttribute(SoundPacks.ATTRIBUTE_NAME, p)
					previewSound(p)
				end
			end,
			onSoundHovered = function(p, _, _)
				previewSound(p)
			end
		})
		updatePackVisibility()
		localPlayer:GetAttributeChangedSignal(SoundPacks.ATTRIBUTE_NAME):Connect(function()
			if v then
				v:SetEquipped((localPlayer:GetAttribute(SoundPacks.ATTRIBUTE_NAME)))
			end
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setupCloseBtn(button)
			if button:IsA("GuiButton") then
				button.MouseButton1Click:Connect(function()
					ClientState:CloseCurrentModal()
				end)
			end
		end

		for _, v5 in ipairs(CollectionService:GetTagged("SoundPackCloseBtn")) do
			setupCloseBtn(v5) -- equivalent call inferred; original call site unknown
		end

		CollectionService:GetInstanceAddedSignal("SoundPackCloseBtn"):Connect(setupCloseBtn)
		refreshGamepassStateAsync() -- equivalent call inferred; original call site unknown
	end
end

return SoundPackUISystem