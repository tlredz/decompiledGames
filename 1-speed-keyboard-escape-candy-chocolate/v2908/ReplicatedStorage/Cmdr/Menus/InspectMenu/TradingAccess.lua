local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local ProfileAccess = require(script.Parent.ProfileAccess)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	ContractId = true,
	OtherUserId = true,
	WorldIndex = true,
	Given = true,
	Received = true,
	Timestamp = true
}
local strictInterface = t.strictInterface({
	userId = t.intersection(t.integer, t.numberMin(1))
})
local strictInterface2 = t.strictInterface({
	userId = t.intersection(t.integer, t.numberMin(1)),
	banned = t.boolean
})

local function formatValue(value)
	if type(value) == "string" then
		return value
	end

	local success, result = pcall(HttpService.JSONEncode, HttpService, value)

	if success then
		return result
	end

	return (tostring(value))
end

local function normalizeOffer(items)
	local v2 = {}

	if type(items) == "table" then
		for _, item in items do
			local result = Items.KeyOf(item)
			local tier = Items.TierOf(item)

			if result == "" then
				if type(item) == "string" then
					result = item
				else
					local success
					success, result = pcall(HttpService.JSONEncode, HttpService, item)

					if not success then
						result = tostring(item)
					end
				end
			end

			local formatted = ("%*\0%*"):format(result, tier)
			local v3 = v2[formatted]

			if v3 then
				v3.amount += 1
			else
				local v4 = Items.ITEMS[result]
				local v5 = {
					key = result,
					displayName = 0,
					tier = 0,
					amount = 1
				}

				if v4 then
					result = v4.name
				end

				v5.displayName = result
				v5.tier = tier
				v2[formatted] = v5
			end
		end
	end

	local result = {}

	for _, v3 in v2 do
		table.insert(result, v3)
	end

	table.sort(result, function(a, b)
		if a.displayName == b.displayName then
			return a.tier < b.tier
		end

		return a.displayName < b.displayName
	end)
	return result
end

local function normalizeHistory(tradeHistory)
	local result = {}

	if type(tradeHistory) ~= "table" then
		return result
	end

	for k, item in tradeHistory do
		if type(k) ~= "number" then
			continue
		end

		if type(item) == "table" then
			local v2 = {}

			for k2, item2 in item do
				if type(k2) ~= "string" or v[k2] then
					continue
				end

				local result2

				if type(item2) == "string" then
					result2 = item2
				else
					local success
					success, result2 = pcall(HttpService.JSONEncode, HttpService, item2)

					if not success then
						result2 = tostring(item2)
					end
				end

				table.insert(v2, (`{k2}: {result2}`))
			end

			table.sort(v2)
			local v3 = {
				index = k,
				contractId = tostring(item.ContractId or "Unknown"),
				otherUserId = tonumber(item.OtherUserId) or 0,
				worldIndex = 0,
				timestamp = 0,
				given = 0,
				received = 0,
				details = 0
			}
			local worldIndex

			if type(item.WorldIndex) == "string" then
				worldIndex = item.WorldIndex
			else
				worldIndex = tonumber(item.WorldIndex) or 0
			end

			v3.worldIndex = worldIndex
			v3.timestamp = tonumber(item.Timestamp) or 0
			v3.given = normalizeOffer(item.Given)
			v3.received = normalizeOffer(item.Received)
			v3.details = table.concat(v2, " | ")
			table.insert(result, v3)
		else
			local result2

			if type(item) == "string" then
				result2 = item
			else
				local success
				success, result2 = pcall(HttpService.JSONEncode, HttpService, item)

				if not success then
					result2 = tostring(item)
				end
			end

			table.insert(result, {
				index = k,
				contractId = "Unknown",
				otherUserId = 0,
				worldIndex = 0,
				timestamp = 0,
				given = {},
				received = {},
				details = result2
			})
		end
	end

	table.sort(result, function(a, b)
		return a.index < b.index
	end)
	return result
end

local function buildResponse(userId: number, p: string?, ok: boolean?)
	local v2 = ProfileAccess.Read(userId)
	local data = v2.Data or {}

	if ok == nil then
		ok = v2.Ok
	end

	return {
		ok = ok,
		message = p or v2.Message,
		editable = v2.Ok and (v2.IsLocal or not v2.IsSessionActive),
		tradeBanned = data.TradeBanned == true,
		history = normalizeHistory(data.TradeHistory)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildInvalidResponse(message: string)
	return {
		ok = false,
		message = message,
		editable = false,
		tradeBanned = false,
		history = {}
	}
end

return {
	getTrading = AdminRemote.RegisterClientEvent(
		"Inspect_Trading_GetTrading",
		"cui.inspect.moderation",
		false,
		function(_, p)
			if strictInterface(p) then
				return (buildResponse(p.userId))
			end

			return buildInvalidResponse("Invalid trading-history request")
		end
	),
	setTradeBanned = AdminRemote.RegisterClientEvent(
		"Inspect_Trading_SetTradeBanned",
		"cui.inspect.moderation",
		true,
		function(p, p2)
			if not strictInterface2(p2) then
				return buildInvalidResponse("Invalid trading-ban request")
			end

			local canTarget, v2 = ProfileAccess.CanTarget(p, p2.userId)

			if not canTarget and p2.userId ~= p.UserId then
				return (buildResponse(p2.userId, v2, false))
			end

			local v3, v4 = ProfileAccess.Write(p2.userId, {
				TradeBanned = p2.banned
			})
			return (buildResponse(p2.userId, v4, v3))
		end
	)
}