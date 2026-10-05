local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ShopLibrary = require(ReplicatedStorage.Modules.ShopLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
require(Players.LocalPlayer.PlayerScripts.Controllers.MonetizationController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.DailyShopRefreshed = Signal.new()
	self.DailyShop = {}
	self.DailyShopDay = nil
	self._fetched_daily_shop = false
	self._refresh_time = 0
	self:_Init()
	return self
end

function class:GetDailyShopRefreshTimeRemaining()
	return (math.max(0, (math.ceil(self._refresh_time - tick()))))
end

function class:GetDailyShop()
	if not self._fetched_daily_shop then
		task.defer(self._FetchDailyShop, self)
	end

	return self.DailyShop
end

function class:GetShopEntry(p)
	if ShopLibrary.Entries[p] then
		return ShopLibrary.Entries[p]
	end

	for _, v in pairs(self:GetDailyShop()) do
		if v.EntryName == p then
			return v
		end
	end
end

function class:UpdateDailyShop(options)
	self.DailyShop = options or {}
	self.DailyShopRefreshed:Fire()
end

function class:UpdateDailyShopCountdown(value)
	self._refresh_time = tick() + (value or 0)
end

function class:PurchaseShopEntry(p, p2, p3)
	local shopEntry = self:GetShopEntry(p)
	assert(shopEntry ~= nil)

	if p2 then
		ReplicatedStorage.Remotes.Data.BuyShopEntry:FireServer(
			shopEntry.EntryName,
			p2,
			1,
			self:_GetIntendedDailyShopDay()
		)
	elseif p3 and shopEntry.ProductIDTriple then
		ReplicatedStorage.Remotes.Data.BuyShopEntryRobux:FireServer(
			shopEntry.EntryName,
			true,
			self:_GetIntendedDailyShopDay()
		)
	elseif shopEntry.ProductID then
		ReplicatedStorage.Remotes.Data.BuyShopEntryRobux:FireServer(
			shopEntry.EntryName,
			false,
			self:_GetIntendedDailyShopDay()
		)
	end
end

function class:BuyDailyShopRefresh()
	ReplicatedStorage.Remotes.Data.RefreshDailyShop:FireServer(self:_GetIntendedDailyShopDay())
end

function class:_GetIntendedDailyShopDay()
	if self.DailyShopDay then
		return self.DailyShopDay + PlayerDataController:Get("DailyShopSeedShift")
	end

	warn("self.DailyShopDay is nil")
	task.spawn(self._FetchDailyShop, self)
	return -1
end

function class:_UpdateDailyShop(options)
	local v = options or {}
	self.DailyShopDay = v.Day
	self:UpdateDailyShopCountdown(v.TimeRemaining)
	self:UpdateDailyShop(v.Data)
end

function class:_FetchDailyShop()
	if self._fetched_daily_shop then
		return
	end

	self._fetched_daily_shop = true
	local result

	repeat
		local success
		success, result = pcall(
			ReplicatedStorage.Remotes.Data.RequestDailyShop.InvokeServer,
			ReplicatedStorage.Remotes.Data.RequestDailyShop
		)
	until success

	self:_UpdateDailyShop(result)
end

function class:_Init()
	ReplicatedStorage.Remotes.Data.UpdateDailyShop.OnClientEvent:Connect(function(...)
		self:_UpdateDailyShop(...)
	end)
end

return class._new()