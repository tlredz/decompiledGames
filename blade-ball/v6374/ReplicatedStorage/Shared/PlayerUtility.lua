local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local UserService = game:GetService("UserService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Observers)
local v2 = require3(ReplicatedStorage2.Packages.Promise)
local v3 = require3(ReplicatedStorage2.Packages.Freeze)
local v4 = require3(ReplicatedStorage2.Packages.Signal)
local v5 = require3(ReplicatedStorage2.Common.Utils.Utilities.FFlag)
require3(ReplicatedStorage2.Common.Utils)
local v6 = require3(ReplicatedStorage2.Packages.Net)
local remoteFunction = v6:RemoteFunction("PlayerUtility/ShareFunction")
local remoteEvent = v6:RemoteEvent("PlayerUtility/ShareEvent")
local PlayerUtility = {
	Quota = 250,
	QuotaConsumed = v4.new(),
	QuotaReturned = v4.new()
}
local v7 = v4.new()
local v8 = v4.new()
local v9 = {}
local v10 = {}
local merged = {}
local merged2 = {}
v.observePlayer(function(player)
	merged = v3.Dictionary.set(merged, player.UserId, {
		LegacyAPI = false,
		Id = player.UserId,
		Username = player.Name
	})
	merged2 = v3.Dictionary.set(merged2, player.UserId, {
		Id = player.UserId,
		Username = player.Name,
		DisplayName = player.DisplayName,
		HasVerifiedBadge = player.HasVerifiedBadge
	})
	return function()
		merged = v3.Dictionary.remove(merged, player.UserId)
		merged2 = v3.Dictionary.remove(merged2, player.UserId)
	end
end)
local v11 = {}
local v12 = {}

local function canUseUserService()
	return v5.TimeoutFFlag("UseUserServiceInPlayerUtility", 5, false)
end

local promisify = v2.promisify(function(p: number, p2, p3)
	return Players:GetUserThumbnailAsync(p, p2, p3)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function getMemoryStoreOf(p: string)
	local MemoryStoreService = game:GetService("MemoryStoreService")
	return MemoryStoreService:GetHashMap((`UserCache-{p}`))
end

function PlayerUtility.LoadCachedUsers(_, p: string)
	assert(RunService:IsServer(), "You can only run this on the server")
	local memoryStoreOf = getMemoryStoreOf(p) -- equivalent call inferred; original call site unknown
	return v2.new(function(callback, _)
		local async = memoryStoreOf:GetAsync("Main")
		local v13 = type(async) ~= "table" and {} or async
		local v14 = {}

		for k, v15 in v13 do
			local id = tonumber(k)

			if not id then
				continue
			end

			table.insert(v14, id)
			merged2 = v3.Dictionary.set(merged2, id, v15)
			merged = v3.Dictionary.set(merged, id, {
				LegacyAPI = false,
				Id = id,
				Username = v15.Username
			})
		end

		local mapped = v3.Dictionary.map(v14, function(_, p2: number)
			return merged2[p2], (tostring(p2))
		end)
		local mapped2 = v3.Dictionary.map(v14, function(_, p2: number)
			return merged[p2], (tostring(p2))
		end)

		if v3.Dictionary.count(mapped) > 0 or v3.Dictionary.count(mapped2) > 0 then
			remoteEvent:FireAllClients(mapped, mapped2)
		end

		return callback(v13)
	end)
end

function PlayerUtility:RequestCacheUser(p: string, p2)
	assert(RunService:IsServer(), "You can only run this on the server")
	local memoryStoreOf = getMemoryStoreOf(p) -- equivalent call inferred; original call site unknown
	return v2.new(function(callback)
		local expect = self:GetUser(p2, nil, true):expect()
		return callback(memoryStoreOf:UpdateAsync("Main", function(p3)
			local result = type(p3) ~= "table" and {} or p3
			local _ = DateTime.now().UnixTimestamp

			for _, v13 in expect do
				if v13.Username ~= "[Failed to load]" then
					result[tostring(v13.Id)] = v13
				end
			end

			return result
		end, 86400))
	end)
end

function PlayerUtility.GetRequestBudget(p)
	return p.Quota
end

function PlayerUtility:GetUser(p, value: number?, flag: boolean?)
	if type(p) == "table" then
		return v2.all(v3.List.map(p, function(p2)
			return self:GetUser(p2, value, flag)
		end))
	end

	local id = tonumber(p) or 0

	if id <= 0 then
		return v2.resolve({
			Id = id,
			Username = `Player{id}`,
			DisplayName = `Player{id}`,
			HasVerifiedBadge = false
		})
	end

	if merged2[id] and not flag then
		return v2.resolve(merged2[id])
	end

	if not table.find(v12, id) then
		v12 = v3.List.insert(v12, 1, id)
	end

	return v2.fromEvent(v7, function()
		return merged2[id] ~= nil
	end):timeout(value or 600):andThen(function()
		return merged2[id]
	end):catch(function(...)
		warn((`[PlayerUtility] [GetUser] Failed to fetch "{id}" after {math.floor((value or 600) * 100) / 100}s`))
		return v2.reject(...)
	end)
end

function PlayerUtility:GetUsername(p, value: number?)
	if type(p) == "table" then
		return v2.all(v3.List.map(p, function(p2)
			return self:GetUsername(p2, value)
		end))
	end

	local v13 = tonumber(p) or 0
	local v14 = merged[v13]

	if v14 then
		return v2.resolve(v14.Username)
	end

	return v2.race({ self:GetUser(v13, value):andThen(function(p2)
			return p2.Username
		end):catch(function()
			return "[Failed to load]"
		end), v2.fromEvent(v8, function()
			return merged[v13] ~= nil
		end):timeout(value or 600):andThen(function()
			local v15 = merged[v13]

			if not v15 then
				return "[Failed to load]"
			end

			if not v15.DidWarn and v15.LegacyAPI then
				warn((`[PlayerUtility] [GetUsername] Failed to fetch "{v13}" Username from UserService, user was fetched from Legacy API`))
				v15.DidWarn = true
			end

			return v15.Username
		end):catch(function()
			warn((`[PlayerUtility] [GetUsername] Failed to fetch "{v13}" after {math.floor((value or 600) * 100) / 100}s`))
			return "[Failed to load]"
		end) })
end

function PlayerUtility:GetDisplayName(p, p2: number?)
	if type(p) == "table" then
		return v2.all(v3.List.map(p, function(p3)
			return self:GetDisplayName(p3, p2)
		end))
	end

	return self:GetUser(p, p2):andThen(function(p3)
		return p3.DisplayName
	end):catch(function()
		return "[Failed to load]"
	end)
end

function PlayerUtility.GetPlayerHeadshot(_, p: number, p2)
	local v13 = v9[p]

	if v13 then
		return v2.resolve(v13)
	end

	local v14 = v10[p]

	if v14 then
		return v14
	end

	local v15 = p2 or Enum.ThumbnailSize.Size48x48
	local tap = promisify(p, Enum.ThumbnailType.HeadShot, v15):tap(function(p3)
		v9[p] = p3
	end)
	v10[p] = tap
	tap:finally(function()
		v10[p] = nil
	end)
	return tap
end

local fetchBatchUserService

fetchBatchUserService = function(list)
	if #list == 0 then
		return {}
	end

	PlayerUtility.Quota -= #list
	PlayerUtility.QuotaConsumed:Fire(#list, PlayerUtility.Quota)
	local success, result = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync(list)
	end)
	task.delay(60, function()
		PlayerUtility.Quota += #list
		PlayerUtility.QuotaReturned:Fire(#list, PlayerUtility.Quota)
	end)

	if success then
		return v3.List.map(result, function(p, _)
			return p, p.Id
		end)
	end

	task.wait(2)
	local v14 = math.min(math.min(#list // 2 + 1, #list), PlayerUtility.Quota)
	local slice = v3.List.slice(list, 1, v14)

	if #slice == 0 then
		return {}
	end

	return (fetchBatchUserService(slice))
end

local function fetchLegacyBatch(list)
	if #list == 0 then
		return {}
	end

	PlayerUtility.Quota -= #list
	PlayerUtility.QuotaConsumed:Fire(#list, PlayerUtility.Quota)
	local _, v14 = v2.all(v3.List.map(list, function(p: number)
		return v2.new(function(callback, _)
			local success, result = pcall(function()
				return Players:GetNameFromUserIdAsync(p)
			end)

			if not (success or string.find(result, "HTTP 429") or string.find(result, "HTTP 502")) then
				success = true
				result = "[Failed to load]"
			end

			task.delay(60, function()
				PlayerUtility.Quota += 1
				PlayerUtility.QuotaReturned:Fire(1, PlayerUtility.Quota)
			end)
			return callback({
				success = success,
				result = result
			})
		end)
	end)):timeout(30):await()
	local result = {}

	for k, v15 in v14 do
		if v15.success then
			result[list[k]] = {
				Username = v15.result
			}
		elseif not (string.find(v15.result, "HTTP 429") or string.find(v15.result, "HTTP 502")) then
			warn((`Failed to fecth username from "{list[k]}":\n{v15.result}`))
		end
	end

	return result
end

local function fetchBatch(list)
	if #list <= 0 then
		return {}
	end

	local filtered = v3.List.filter(list, function(p: number)
		return (v11[p] or 0) <= 4
	end)
	local filtered2 = v3.List.filter(list, function(p: number)
		return not table.find(filtered, p)
	end)
	return v3.List.merge(v2.try(fetchLegacyBatch, filtered2):expect(), v2.try(fetchBatchUserService, filtered):expect())
end

task.spawn(function()
	while true do
		if PlayerUtility.Quota <= 0 then
			task.wait(5)
		else
			local v13 = math.min(PlayerUtility.Quota, 200)
			local v14 = v3.List.take(v12, v13)
			v12 = v3.List.slice(v12, v13 + 1)
			local v15 = fetchBatch(v14)

			for _, id in v14 do
				if v15[id] then
					continue
				end

				local v17 = v11[id] or 0
				v11[id] = v17 + 1

				if v17 < 8 then
					if not table.find(v12, id) then
						v12 = v3.List.insert(v12, 1, id)
					end
				else
					v3.Dictionary.set(v15, id, {
						Id = id,
						Username = "[Failed to load]",
						DisplayName = "[Failed to load]",
						HasVerifiedBadge = false
					})
				end
			end

			for k, v16 in pairs(v15) do
				if v16.Id == nil then
					if not merged2[k] then
						merged2 = v3.Dictionary.set(merged2, k, {
							Id = k,
							Username = "[Failed to load]",
							DisplayName = "[Failed to load]",
							HasVerifiedBadge = false
						})
					end

					merged = v3.Dictionary.set(merged, k, {
						LegacyAPI = true,
						Id = k,
						Username = v16.Username
					})
				else
					merged2 = v3.Dictionary.set(merged2, k, v16)
					merged = v3.Dictionary.set(merged, k, {
						LegacyAPI = false,
						Id = k,
						Username = v16.Username
					})

					if v11[v16.Id] and v16.Username ~= "[Failed to load]" then
						v11[v16.Id] = nil
					end
				end

				v12 = v3.List.removeValue(v12, k)
			end

			v7:Fire(v15, canUseUserService)
			v8:FireDeferred(v15, canUseUserService)
			task.wait(2)
		end
	end
end)

if RunService:IsServer() then
	v7:Connect(function(p)
		local mapped = v3.Dictionary.map(p, function(_, p2: number)
			return merged2[p2], (tostring(p2))
		end)
		local mapped2 = v3.Dictionary.map(p, function(_, p2: number)
			return merged[p2], (tostring(p2))
		end)

		if v3.Dictionary.count(mapped) > 0 or v3.Dictionary.count(mapped2) > 0 then
			remoteEvent:FireAllClients(mapped, mapped2)
		end
	end)
	local v13 = {}
	Players.PlayerRemoving:Connect(function(player)
		v13[player] = nil
	end)

	remoteFunction.OnServerInvoke = function(p)
		if v13[p] then
			return nil, nil
		end

		v13[p] = true
		return v3.Dictionary.map(merged2, function(p2, p3)
			return p2, (tostring(p3))
		end), (v3.Dictionary.map(merged2, function(p2, p3)
			return p2, (tostring(p3))
		end))
	end
else
	local function merge(p, p2)
		if not (p and p2) then
			return
		end

		local mapped = v3.Dictionary.map(p, function(p3, p4)
			return p3, (tonumber(p4))
		end)
		local mapped2 = v3.Dictionary.map(p2, function(p3, p4)
			return p3, (tonumber(p4))
		end)
		merged2 = v3.Dictionary.merge(merged2, mapped)
		merged = v3.Dictionary.merge(merged, mapped2)

		for k in mapped do
			v12 = v3.List.removeValue(v12, k)
			v11[k] = nil
		end

		for k in mapped2 do
			v12 = v3.List.removeValue(v12, k)
			v11[k] = nil
		end
	end

	task.spawn(function()
		merge(remoteFunction:InvokeServer())
	end)
	remoteEvent.OnClientEvent:Connect(merge)
end

return PlayerUtility