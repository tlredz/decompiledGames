local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local TopBarButton = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.TopBarButton)
local Vide = require(ReplicatedStorage.Packages.Vide)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local Config = require(script.Config)
local IndexMenu = require(script.IndexMenu)
local IndexRow = require(script.IndexRow)
local Remotes = require(script.Remotes)
require(script.Types)
local isServer = RunService:IsServer()
local DataManager = nil
local ClientState = nil

if isServer then
	local ServerScriptService = game:GetService("ServerScriptService")
	DataManager = require(ServerScriptService.DataManager)
else
	ClientState = require(ReplicatedStorage.ClientState)
end

local ITEMS = Items.ITEMS
local v = {}
local v2 = {}
local v3 = 0
local v4 = nil
local v5 = nil
local v6 = nil

local function buildCatalog()
	if #v > 0 then
		return
	end

	for k, v7 in pairs(ITEMS) do
		table.insert(v, {
			key = k,
			label = v7.name,
			icon = v7.icon,
			rarity = v7.rarity,
			multiplier = v7.multiplier,
			category = v7.EventKey or Config.MAIN_CATEGORY
		})
	end

	table.sort(v, function(a, b)
		if a.multiplier == b.multiplier then
			return a.label < b.label
		end

		return a.multiplier < b.multiplier
	end)
end

local function collectTiers(list, tiers)
	if type(list) ~= "table" then
		return
	end

	for _, v7 in ipairs(list) do
		local key = Items.KeyOf(v7)

		if not (key ~= "" and ITEMS[key]) then
			continue
		end

		local tier = Items.TierOf(v7)
		local v8 = tiers[key]

		if v8 == nil or v8 < tier then
			tiers[key] = tier
		end
	end
end

local function sanitizeLog(everOwnedItems)
	local result = {}

	if type(everOwnedItems) ~= "table" then
		return result
	end

	for k, item in pairs(everOwnedItems) do
		if not (type(k) == "string" and type(item) == "number" and ITEMS[k]) then
			continue
		end

		result[k] = math.clamp(math.floor(item), 0, Items.MAX_TIER)
	end

	return result
end

local function sameTiers(items, items2)
	if type(items) ~= "table" then
		return false
	end

	for k, item in pairs(items2) do
		if items[k] ~= item then
			return false
		end
	end

	for k in pairs(items) do
		if items2[k] == nil then
			return false
		end
	end

	return true
end

local function foldEverOwned(p)
	local activeData = DataManager:GetActiveData(p)

	if not activeData then
		return nil
	end

	local result = sanitizeLog(activeData.everOwnedItems)
	local v7 = {}
	collectTiers(activeData.Items, v7)
	collectTiers(activeData.EquippedItems, v7)

	for k, v8 in pairs(v7) do
		local v9 = result[k]

		if v9 == nil or v9 < v8 then
			result[k] = v8
		end
	end

	if not sameTiers(activeData.everOwnedItems, result) then
		activeData.everOwnedItems = result
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sendState(p, p2)
	v2[p] = p2
	Remotes.stateUpdate:fire(p, p2)
end

local function serverInit()
	Remotes.requestState:connect(function(p)
		local v7 = foldEverOwned(p)

		if v7 then
			sendState(p, v7) -- equivalent call inferred; original call site unknown
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		foldEverOwned(player)
		v2[player] = nil
	end)
end

local function serverUpdate()
	local now = os.clock()

	if now - v3 < Config.OWNERSHIP_POLL_SECONDS then
		return
	end

	v3 = now

	for _, v7 in ipairs(Players:GetPlayers()) do
		local v8 = foldEverOwned(v7)

		if not v8 or sameTiers(v2[v7], v8) then
			continue
		end

		sendState(v7, v8) -- equivalent call inferred; original call site unknown
	end
end

local function bonusLabel(p: number, p2: number)
	return string.format("+%d%%", (math.floor(Items.GetTieredMultiplier(p, p2) * 100 + 0.5)))
end

local function cycleTier(p: string)
	local v7 = v5

	if not v7 then
		return
	end

	local clone = table.clone(v7())
	clone[p] = ((clone[p] or 0) + 1) % (Items.MAX_TIER + 1)
	v7(clone)
end

local function viewItems()
	local v8 = v5
	local v9 = not v4 and {} or v4()
	local v10 = not v8 and {} or v8()
	local result = table.create(#v)

	for i, v11 in ipairs(v) do
		local tier = v10[v11.key] or 0
		local v13 = v9[v11.key]
		local v14 = {
			id = v11.key,
			label = v11.label,
			icon = v11.icon,
			rarity = v11.rarity,
			bonus = 0,
			nextBonus = 0,
			stat = 0,
			tier = 0,
			category = 0,
			owned = 0
		}
		local multiplier = v11.multiplier
		v14.bonus = string.format("+%d%%", (math.floor(Items.GetTieredMultiplier(multiplier, tier) * 100 + 0.5)))
		local nextBonus

		if tier < Items.MAX_TIER then
			local multiplier2 = v11.multiplier
			local v16 = tier + 1
			nextBonus = string.format("+%d%%", (math.floor(Items.GetTieredMultiplier(multiplier2, v16) * 100 + 0.5)))
		end

		v14.nextBonus = nextBonus
		v14.stat = Config.STAT_LABEL
		v14.tier = tier
		v14.category = v11.category
		v14.owned = v13 ~= nil and tier <= v13
		result[i] = v14
	end

	return result
end

local function clientInit()
	buildCatalog()
	v4 = Vide.source({})
	v5 = Vide.source({})
	Remotes.stateUpdate:connect(function(p)
		local v7 = v4

		if v7 then
			v7(p)
		end
	end)
	Remotes.requestState:fire()
end

local v7 = {
	OnClose = function() end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleModal()
	local v8 = v6

	if not v8 then
		return
	end

	Remotes.requestState:fire()
	ClientState:ToggleModal(v8, v7)
end

local function clientUIInit()
	local speedGameUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("SpeedGameUI")
	local topButtons = speedGameUI:WaitForChild("Frames"):WaitForChild("TopButtons")
	Vide.mount(function()
		TopBarButton({
			Name = "ItemIndexButton",
			LayoutOrder = Config.BUTTON_LAYOUT_ORDER,
			Emoji = Config.BUTTON_EMOJI,
			BackgroundColor = Config.BUTTON_COLOR,
			Parent = topButtons,
			OnActivated = toggleModal
		})
		local indexMenu = IndexMenu({
			Visible = false,
			Items = viewItems,
			Categories = Config.CATEGORIES,
			ItemCategories = Config.ITEM_CATEGORIES,
			MainCategory = Config.MAIN_CATEGORY,
			OnSelect = cycleTier,
			OnClose = function()
				ClientState:CloseCurrentModal()
			end
		})
		indexMenu:SetAttribute("ModalVisibleY", Config.MODAL_VISIBLE_Y)
		v6 = indexMenu
		return indexMenu
	end, speedGameUI)
end

local ItemIndex = {
	Component = function(p)
		return IndexMenu(p)
	end,
	Row = function(p)
		return IndexRow(p)
	end,
	isEnabled = function()
		return Config.ENABLED
	end,
	getEverOwnedTiers = function(p)
		if isServer then
			assert(p, "itemIndex.getEverOwnedTiers requires a player on the server")
			return (foldEverOwned(p))
		end

		local v8 = v4

		if v8 then
			return (v8())
		end

		return nil
	end,
	toggle = function()
		assert(not isServer, "itemIndex.toggle is client-only")
		toggleModal() -- equivalent call inferred; original call site unknown
	end
}
FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if not Config.ENABLED then
			return
		end

		if isServer then
			serverInit()
		else
			clientInit()
		end
	end,
	OnUIInit = function()
		if Config.ENABLED then
			clientUIInit()
		end
	end,
	OnUpdate = function()
		if Config.ENABLED and isServer then
			serverUpdate()
		end
	end
})
return ItemIndex