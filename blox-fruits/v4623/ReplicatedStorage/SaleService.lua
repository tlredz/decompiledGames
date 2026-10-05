local HttpService = game:GetService("HttpService")
local ServiceProxy = require(game.ReplicatedStorage.Packages.ServiceProxy)
local Option = require(game.ReplicatedStorage.Packages.Option)
local Type = require(game.ReplicatedStorage.Packages.Type)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local ValentinesDay2026 = require(game.ReplicatedStorage.EventConfig.ValentinesDay2026)
local Time = require(game.ReplicatedStorage.Util.Time)
local Easter2026 = require(game.ReplicatedStorage.EventConfig.Easter2026)
local MagnetEvent26 = require(game.ReplicatedStorage.EventConfig.MagnetEvent26)
local literal = Type.literal(
	"WinterCombo24",
	"HolidayEssentials24",
	"ULTIMATEBUNDLE24",
	"HalloweenBundle2025",
	"HolidayBundle2025",
	"UltimateBundle2025",
	"FoxSpiritBundle2025",
	"Valentines2026Bundle",
	"HolidayChromatics2024",
	"EagleChromatics2025",
	"Easter2026",
	"MagnetChromaticGacha2026"
)
local v = nil
local class = {}
class.__index = class
class.Type = {
	SaleKey = literal
}

function class:Destroy()
	if not self._IsInitialized then
		return
	end

	self._IsInitialized = false
	self.OnSaleChanged:Destroy()

	if v == self then
		v = nil
	end
end

function class:GetIfInitialized()
	if v then
		return v._IsInitialized
	end

	return false
end

function class:ScheduleCallback(p2)
	assert(self._IsInitialized, "SaleService isn't initialized")
	local GUID = HttpService:GenerateGUID(false)
	self._Callbacks[GUID] = p2
	return function()
		if self._IsInitialized then
			self._Callbacks[GUID] = nil
		end
	end
end

function class:GetSaleByKey(p2: string)
	assert(self._IsInitialized, "SaleService isn't initialized")
	local _Sale = self._Sales[p2]

	if not _Sale then
		error((`no sale at key {p2}`))
	end

	return _Sale
end

function class:GetAllSales()
	assert(self._IsInitialized, "SaleService isn't initialized")
	local _Sales = {}

	for _, _Sale in pairs(self._Sales) do
		table.insert(_Sales, _Sale)
	end

	return _Sales
end

function class:GetIfValidKey(p2: string)
	assert(self._IsInitialized, "SaleService isn't initialized")
	return self._Sales[p2] ~= nil
end

function class:GetIfActive(p2: string)
	assert(self._IsInitialized, "SaleService isn't initialized")
	local _Sale = self._Sales[p2]
	assert(_Sale, (`invalid key: "{p2}"`))
	local unixTimestampMillis = DateTime.now().UnixTimestampMillis
	local match = Option.match(_Sale.Date.Start, function(p3)
		return unixTimestampMillis > p3.UnixTimestampMillis
	end, function()
		return true
	end)
	local match2 = Option.match(_Sale.Date.Finish, function(p3)
		return unixTimestampMillis > p3.UnixTimestampMillis
	end, function()
		return false
	end)

	if match and not match2 then
		return true
	end

	return false
end

function class.init()
	if class:GetIfInitialized() then
		local v2 = v
		assert(v2, "bad initialization")
		return function()
			v2:Destroy()
		end
	else
		local values = {}

		local function newSale(p: string, start, finish)
			assert(values[p] == nil, (`duplicate sale key at "{p}"`))
			values[p] = table.freeze({
				Key = p,
				Date = table.freeze({
					Start = start,
					Finish = finish
				})
			})
		end

		local some = Option.some(DateTime.fromUniversalTime(2025, 1, 3, 11, 59))
		local some2 = Option.some(DateTime.fromUniversalTime(2026, 1, 1, 17, 0))
		newSale("WinterCombo24", Option.none(), some)
		newSale("HolidayEssentials24", Option.none(), some)
		newSale("ULTIMATEBUNDLE24", Option.none(), some)
		newSale("HalloweenBundle2025", Option.none(), Option.some(DateTime.fromUniversalTime(2025, 11, 17, 14, 0)))
		newSale("HolidayBundle2025", Option.none(), some2)
		newSale("UltimateBundle2025", Option.none(), some2)
		newSale("FoxSpiritBundle2025", Option.none(), some2)
		newSale(
			"Valentines2026Bundle",
			Option.some(ValentinesDay2026.START_AT:ToDateTimeUTC()),
			Option.some(ValentinesDay2026.EVERYTHING_BACK_TO_NORMAL_AT:ToDateTimeUTC())
		)
		newSale(
			"Easter2026",
			Option.some(Easter2026.START_AT:ToDateTimeUTC()),
			Option.some(Easter2026.EVERYTHING_BACK_TO_NORMAL_AT:ToDateTimeUTC())
		)
		newSale(
			"HolidayChromatics2024",
			Option.some(Time.new("PST", 2024, 12, 21, 18):ToDateTimeUTC()),
			Option.some(Time.new("PST", 2024, 12, 28, 18):ToDateTimeUTC())
		)
		newSale(
			"EagleChromatics2025",
			Option.some(Time.new("PST", 2025, 4, 17, 21):ToDateTimeUTC()),
			Option.some(Time.new("PST", 2025, 4, 27, 9):ToDateTimeUTC())
		)
		newSale(
			"MagnetChromaticGacha2026",
			Option.none(),
			Option.some(MagnetEvent26.NO_MORE_GAMEPLAY_AT:ToDateTimeUTC())
		)
		table.freeze(values)
		local object = setmetatable({
			_IsInitialized = true,
			_Sales = values,
			OnSaleChanged = Signal.new(),
			_Callbacks = {}
		}, class)
		task.spawn(function()
			local function getActiveSales()
				local ifActives = {}

				for k, _ in pairs(object._Sales) do
					ifActives[k] = object:GetIfActive(k)
				end

				return ifActives
			end

			local activeSales = getActiveSales()

			while object._IsInitialized do
				local activeSales2 = getActiveSales()

				for k, activeSale in pairs(activeSales2) do
					if activeSales[k] == activeSale then
						continue
					end

					if activeSale then
						for _, _Callback in pairs(object._Callbacks) do
							local v2 = _Callback
							local v3 = k
							task.spawn(function()
								v2(object._Sales[v3], "SaleStart")
								object.OnSaleChanged:Fire(object._Sales[v3], "SaleStart")
							end)
						end
					else
						for _, _Callback in pairs(object._Callbacks) do
							local v2 = _Callback
							local v3 = k
							task.spawn(function()
								v2(object._Sales[v3], "SaleFinish")
								object.OnSaleChanged:Fire(object._Sales[v3], "SaleFinish")
							end)
						end
					end
				end

				task.wait(1)
				activeSales = activeSales2
			end
		end)

		if v then
			local v2 = v
			assert(v2, "bad prior")
			v = object
			v2:Destroy()
		else
			v = object
		end

		return function()
			object:Destroy()
		end
	end
end

return ServiceProxy(function()
	return v or class
end)