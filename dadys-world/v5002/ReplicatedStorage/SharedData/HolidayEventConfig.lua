local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Universe = require(ReplicatedStorage.SharedUtils.Universe)
local HolidayEventConfig = {
	TEST_REALM_FORCES_EVENT = true,
	IS_TEST_REALM = Universe:IsTestRealm()
}
HolidayEventConfig.FORCED_BY_TEST_REALM = HolidayEventConfig.TEST_REALM_FORCES_EVENT and HolidayEventConfig.IS_TEST_REALM
HolidayEventConfig.ENABLED = true
HolidayEventConfig.CURRENT_EVENT = "Halloween2026"
HolidayEventConfig.EVENTS_ENABLED = true
HolidayEventConfig.MAP_NAMES_LIST = { "HalloweenMap", "HalloweenMap2" }
HolidayEventConfig.HOLIDAY_KEY = "Halloween26"
HolidayEventConfig.EVENT_MODULE = require(ReplicatedStorage.SharedData.Halloween26)
HolidayEventConfig.CURRENCY_NAME = "Pumpkins"
HolidayEventConfig.COLLECTIBLE_ITEM_NAME = "Pumpkins"
local SimulatedTime = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("SimulatedTime"))
HolidayEventConfig.ShopModule = require(ReplicatedStorage.SharedData.HolidayShops.Halloween)
HolidayEventConfig.UIVisible = true
HolidayEventConfig.SpawnOnEventFloors = true
HolidayEventConfig.EventFloorInterval = 5
HolidayEventConfig.EventFloorChance = 25
HolidayEventConfig.HolidayMonsters = {
	"GourdyMonster",
	"RibeccaMonster",
	"SoulvesterMonster",
	"EclipseMonster"
}
HolidayEventConfig.HolidayMaps = { "HalloweenMap", "HalloweenMap2" }
HolidayEventConfig.FreeItemName = "DandyCorn"
HolidayEventConfig.NPCName = "GourdyStore"
HolidayEventConfig.NPCDisplayName = "Gourdy"
HolidayEventConfig.CurrencyKey = "Pumpkins"
HolidayEventConfig.CurrencyDisplay = "Pumpkins"
HolidayEventConfig.CurrencyIcon = "rbxassetid://94528019756373"
HolidayEventConfig.ContentFlag = "Halloween"
local DevProductConfig = require(ReplicatedStorage.SharedData.DevProductConfig)
local products = DevProductConfig.GetProducts()
HolidayEventConfig.Products = {
	Small = products.PUMPKINS_300,
	Medium = products.PUMPKINS_1450,
	Large = products.PUMPKINS_2950,
	Mega = products.PUMPKINS_5000
}
HolidayEventConfig.CatchUpProduct = products.CALENDAR_MISSED_DAY
HolidayEventConfig.ProductAmounts = {
	Small = 300,
	Medium = 1450,
	Large = 2950,
	Mega = 5000
}
HolidayEventConfig.ProductImages = {
	Christmas = {
		Small = "rbxassetid://117535279645113",
		Medium = "rbxassetid://130274403795365",
		Large = "rbxassetid://81178585728332",
		Mega = "rbxassetid://114960265446651"
	},
	Easter = {
		Small = "rbxassetid://125257101552043",
		Medium = "rbxassetid://140580724633984",
		Large = "rbxassetid://129111454643054",
		Mega = "rbxassetid://100652502671553"
	},
	Halloween = {
		Small = "rbxassetid://102687191173758",
		Medium = "rbxassetid://98957273993823",
		Large = "rbxassetid://89120694011053",
		Mega = "rbxassetid://128479283080145"
	}
}
HolidayEventConfig.AnalyticsCurrencyName = "Pumpkins"
HolidayEventConfig.MULTIPLIER_EVENTS = {
	{
		name = "Halloween 2x Pumpkins - Oct 9-11",
		multiplier = 2,
		startDate = {
			year = 2026,
			month = 10,
			day = 9,
			hour = 4,
			min = 0
		},
		endDate = {
			year = 2026,
			month = 10,
			day = 12,
			hour = 3,
			min = 59
		},
		enabled = true
	},
	{
		name = "Halloween 2x Pumpkins - Oct 16-18",
		multiplier = 2,
		startDate = {
			year = 2026,
			month = 10,
			day = 16,
			hour = 4,
			min = 0
		},
		endDate = {
			year = 2026,
			month = 10,
			day = 19,
			hour = 3,
			min = 59
		},
		enabled = true
	},
	{
		name = "Halloween 2x Pumpkins - Oct 23-25",
		multiplier = 2,
		startDate = {
			year = 2026,
			month = 10,
			day = 23,
			hour = 4,
			min = 0
		},
		endDate = {
			year = 2026,
			month = 10,
			day = 26,
			hour = 3,
			min = 59
		},
		enabled = true
	},
	{
		name = "Halloween 2x Pumpkins - Oct 30-31",
		multiplier = 2,
		startDate = {
			year = 2026,
			month = 10,
			day = 30,
			hour = 4,
			min = 0
		},
		endDate = {
			year = 2026,
			month = 11,
			day = 1,
			hour = 3,
			min = 59
		},
		enabled = true
	}
}

function HolidayEventConfig.GetMultiplier()
	if not HolidayEventConfig.EVENTS_ENABLED then
		return 1
	end

	local unixTimestamp = SimulatedTime.now().UnixTimestamp

	for _, v in ipairs(HolidayEventConfig.MULTIPLIER_EVENTS) do
		if not v.enabled then
			continue
		end

		local unixTimestamp2 = DateTime.fromUniversalTime(
			v.startDate.year,
			v.startDate.month,
			v.startDate.day,
			v.startDate.hour,
			v.startDate.min,
			0,
			0
		).UnixTimestamp
		local unixTimestamp3 = DateTime.fromUniversalTime(
			v.endDate.year,
			v.endDate.month,
			v.endDate.day,
			v.endDate.hour,
			v.endDate.min,
			0,
			0
		).UnixTimestamp

		if unixTimestamp2 <= unixTimestamp and unixTimestamp <= unixTimestamp3 then
			return v.multiplier
		end
	end

	return 1
end

function HolidayEventConfig.GetActiveEvent()
	if not HolidayEventConfig.EVENTS_ENABLED then
		return nil
	end

	local unixTimestamp = SimulatedTime.now().UnixTimestamp

	for _, v in ipairs(HolidayEventConfig.MULTIPLIER_EVENTS) do
		if not v.enabled then
			continue
		end

		local unixTimestamp2 = DateTime.fromUniversalTime(
			v.startDate.year,
			v.startDate.month,
			v.startDate.day,
			v.startDate.hour,
			v.startDate.min,
			0,
			0
		).UnixTimestamp
		local unixTimestamp3 = DateTime.fromUniversalTime(
			v.endDate.year,
			v.endDate.month,
			v.endDate.day,
			v.endDate.hour,
			v.endDate.min,
			0,
			0
		).UnixTimestamp

		if unixTimestamp2 <= unixTimestamp and unixTimestamp <= unixTimestamp3 then
			return {
				name = v.name,
				multiplier = v.multiplier,
				startDate = v.startDate,
				endDate = v.endDate
			}
		end
	end

	return nil
end

function HolidayEventConfig.IsEventActive()
	return HolidayEventConfig.GetMultiplier() > 1
end

function HolidayEventConfig.GetEventStatus(p)
	if HolidayEventConfig.FORCED_BY_TEST_REALM then
		return 1
	end

	local EVENT_MODULE = HolidayEventConfig.EVENT_MODULE
	local active = EVENT_MODULE and EVENT_MODULE.Active

	if not (active and active.Start and active.End) then
		return 1
	end

	if p < active.Start.UnixTimestamp then
		return 0
	end

	if active.End.UnixTimestamp < p then
		return 2
	end

	return 1
end

function HolidayEventConfig.GetBadgeText()
	local multiplier = HolidayEventConfig.GetMultiplier()
	return string.format("%.1fX %s WEEKEND!", multiplier, string.upper(HolidayEventConfig.CURRENCY_NAME))
end

function HolidayEventConfig.ShouldShowInHolidayShop(p)
	if not HolidayEventConfig.ENABLED then
		return false
	end

	if (p.HolidayTower or p.HolidaySkin) and p[HolidayEventConfig.ContentFlag] then
		return true
	end

	return false
end

function HolidayEventConfig.GetEventYear()
	return (tonumber(string.match(tostring(HolidayEventConfig.CURRENT_EVENT), "%d%d%d%d")))
end

function HolidayEventConfig.GetCurrencyPath()
	return "Seasonal." .. HolidayEventConfig.HOLIDAY_KEY .. "." .. HolidayEventConfig.CurrencyKey
end

function HolidayEventConfig.GetCurrencyModelName()
	local EVENT_MODULE = HolidayEventConfig.EVENT_MODULE
	local currencyModelName = EVENT_MODULE and EVENT_MODULE.CurrencyModelName

	if type(currencyModelName) == "string" and currencyModelName ~= "" then
		return currencyModelName
	end

	return "HolidayCollectibleItem"
end

function HolidayEventConfig.GetCurrencyPickupSound()
	local EVENT_MODULE = HolidayEventConfig.EVENT_MODULE
	local currencyPickupSound = EVENT_MODULE and EVENT_MODULE.CurrencyPickupSound

	if type(currencyPickupSound) == "string" and currencyPickupSound ~= "" then
		return currencyPickupSound
	end

	return nil
end

function HolidayEventConfig.IsHolidayMonster(p)
	if not HolidayEventConfig.ENABLED then
		return false
	end

	for _, holidayMonster in ipairs(HolidayEventConfig.HolidayMonsters) do
		if holidayMonster == p then
			return true
		end
	end

	return false
end

function HolidayEventConfig.IsHolidayMap(p)
	if not HolidayEventConfig.ENABLED then
		return false
	end

	for _, holidayMap in ipairs(HolidayEventConfig.HolidayMaps) do
		if holidayMap == p then
			return true
		end
	end

	return false
end

function HolidayEventConfig.IsEventFloor(p)
	if not HolidayEventConfig.ENABLED then
		return false
	end

	if HolidayEventConfig.SpawnOnEventFloors then
		return p % HolidayEventConfig.EventFloorInterval == 0
	end

	return false
end

if RunService:IsClient() then
	local function addUnknown(instance)
		if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
			instance.Image = HolidayEventConfig.CurrencyIcon
		elseif instance:IsA("ParticleEmitter") then
			instance.Texture = HolidayEventConfig.CurrencyIcon
		end
	end

	CollectionService:GetInstanceAddedSignal("HolidayCurrencyVisual"):Connect(addUnknown)

	for _, v in pairs(CollectionService:GetTagged("HolidayCurrencyVisual")) do
		task.spawn(addUnknown, v)
	end
end

local _ = HolidayEventConfig.FORCED_BY_TEST_REALM
return HolidayEventConfig