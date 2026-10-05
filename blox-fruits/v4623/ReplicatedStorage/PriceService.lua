local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local ServiceProxy = require(game.ReplicatedStorage.Packages.ServiceProxy)
require(game.ReplicatedStorage.Packages.Signal)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local SaleService = require(game.ReplicatedStorage.SaleService)
local ComingSoonUtil = require(game.ReplicatedStorage.Util.ComingSoonUtil)
local Shop = require(game.ReplicatedStorage.Shop)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v2 = nil
local flag = false
local v3 = {}
local v4 = {}
local info = LoggerBuilder.new():tag(script.Name):tag("Service"):tag("Economy"):traceback():build().info
local class = {}
class.__index = class

function class:Destroy()
	if not self._IsInitialized then
		return
	end

	self._IsInitialized = false

	if v2 == self then
		v2 = nil
	end

	local _OnPriceChangeConnection = self._OnPriceChangeConnection

	if _OnPriceChangeConnection then
		_OnPriceChangeConnection:Disconnect()
	end
end

function class:GetIfInitialized()
	if v2 then
		return v2._IsInitialized
	end

	return false
end

function class:ScheduleCallback(value, callback)
	if typeof(value) == "number" then
		assert(typeof(callback) == "function", "bad callback")
		assert(self._IsInitialized, "SaleService isn't initialized")
		local GUID = HttpService:GenerateGUID(false)
		info((`secheduling callback: {GUID}`))
		self._Callbacks[value] = self._Callbacks[value] or {}
		self._Callbacks[value][GUID] = callback
		return function()
			if self._IsInitialized then
				info((`callback {GUID} disconnected`))
				self._Callbacks[value][GUID] = nil
				local count = 0

				for _, _ in pairs(self._Callbacks[value]) do
					count += 1
				end

				if count == 0 then
					self._Callbacks[value] = nil
				end
			end
		end
	else
		assert(typeof(value) == "function", "bad callback")
		local GUID = HttpService:GenerateGUID(false)
		info((`secheduling generic callback: {GUID}`))
		self._GenericCallbacks[GUID] = value
		return function()
			if self._IsInitialized then
				info((`generic callback {GUID} disconnected`))
				self._GenericCallbacks[GUID] = nil
			end
		end
	end
end

function class.getPrice(value)
	local v5

	if typeof(value) == "number" then
		v5 = ItemConfig.match(value):unwrap()
	else
		v5 = ItemConfig.match(value, "Redeemable"):unwrap()
	end

	local itemId = v5.Index.ItemId

	if RunService:IsRunning() and not GlobalUtil.FFlags.IsUnitTest then
		if v5.Index.IdType == "Redeemable" and ComingSoonUtil.getIsComingSoon(itemId) then
			return nil
		end

		local nullable = Shop.match(itemId):asNullable()

		if nullable then
			local nullable2 = nullable.RestrictedToSales:asNullable()

			if nullable2 then
				local v6 = false

				for _, v8 in ipairs(nullable2) do
					if not SaleService:GetIfActive(v8) then
						continue
					end

					v6 = true
					break
				end

				if not v6 then
					return nil
				end
			end
		end
	end

	local v6

	if v5.Economy and v5.Economy.GamepassId then
		v6 = v4[v5.Economy.GamepassId] or nil
	end

	if v6 then
		return v6
	end

	local v7

	if v5.Economy and v5.Economy.ProductId then
		v7 = v3[v5.Economy.ProductId] or nil
	end

	return v7 or v5 and v5.Economy and v5.Economy.RobuxPrice or nil
end

function class.init()
	info("init PriceService")

	while flag do
		task.wait()
	end

	if class:GetIfInitialized() then
		local v5 = v2
		assert(v5, "bad initialization")
		return function()
			v5:Destroy()
		end
	else
		flag = true
		local success, result = pcall(function()
			local object = setmetatable({
				_IsInitialized = true,
				_GenericCallbacks = {},
				_Callbacks = {},
				_Connections = {}
			}, class)

			if RunService:IsRunning() and not GlobalUtil.FFlags.IsUnitTest then
				task.spawn(function()
					while not SaleService:GetIfInitialized() do
						task.wait()
					end

					local function updateAll(itemIds)
						for _, item in itemIds do
							local price = object.getPrice(item)
							info((`firing callbacks for itemId {item} with new price {price}`))

							for _, _GenericCallback in object._GenericCallbacks do
								local v5 = _GenericCallback
								local v6 = item
								local v7 = price
								task.spawn(function()
									v5(v6, v7)
								end)
							end

							local _Callback = object._Callbacks[item]

							if not _Callback then
								continue
							end

							for _, v5 in _Callback do
								local v6 = v5
								local v7 = price
								task.spawn(function()
									v6(v7)
								end)
							end
						end
					end

					table.insert(object._Connections, (SaleService.OnSaleChanged:Connect(function(p, _)
						local itemIds = {}

						for _, v5 in Shop.LIBRARY.ALL do
							local nullable = v5.RestrictedToSales:asNullable()

							if nullable and table.find(nullable, p.Key) then
								table.insert(itemIds, v5.ItemId)
							end
						end

						updateAll(itemIds)
					end)))
					ComingSoonUtil.OnChanged:Connect(function()
						local itemIds = {}

						for _, v5 in ComingSoonUtil.getIsComingSoonList() do
							table.insert(itemIds, v5.Index.ItemId)
						end

						updateAll(itemIds)
					end)
				end)
			end

			if RunService:IsRunning() then
				local productIds = {}

				for _, v5 in ItemConfig.Query.select({
					Economy = {
						ProductId = {
							Operation = "NEQ",
							Value = nil
						}
					}
				}) do
					assert(v5.Economy and v5.Economy.ProductId, "bad product-id")
					table.insert(productIds, v5.Economy.ProductId)
				end

				local gamepassIds = {}

				for _, v5 in ItemConfig.Query.select({
					Economy = {
						GamepassId = {
							Operation = "NEQ",
							Value = nil
						}
					}
				}) do
					assert(v5.Economy and v5.Economy.GamepassId, "bad product-id")
					table.insert(gamepassIds, v5.Economy.GamepassId)
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function refreshDiscountsAsync()
					local function process(list, p, items)
						local count = #list
						local v5 = {}

						local function fetch(p2)
							local success2, result2 = pcall(function()
								return MarketplaceService:GetProductInfoAsync(p2, p)
							end)

							if success2 then
								v5[p2] = result2
							end

							count -= 1
						end

						for _, v6 in list do
							task.spawn(fetch, v6)
						end

						while count > 0 do
							task.wait()
						end

						local v6 = {}

						for k, v7 in v5 do
							if v7.PriceInRobux == v7.UserBasePriceInRobux then
								continue
							end

							items[k] = v7.PriceInRobux
							v6[k] = true
						end

						for k, _ in items do
							if not v6[k] then
								items[k] = nil
							end
						end
					end

					process(productIds, Enum.InfoType.Product, v3)
					process(gamepassIds, Enum.InfoType.GamePass, v4)
				end

				task.spawn(function()
					refreshDiscountsAsync() -- equivalent call inferred; original call site unknown
				end)
			end

			if v2 then
				local v5 = v2
				assert(v5, "bad prior")
				v2 = object
				v5:Destroy()
			else
				v2 = object
			end

			info("PriceService initialized")
			return function()
				object:Destroy()
			end
		end)
		flag = false

		if not success then
			error((`Failed to initialize LiveOpsService: {result}`))
		end

		return function() end
	end
end

return ServiceProxy(function()
	return v2 or class
end)