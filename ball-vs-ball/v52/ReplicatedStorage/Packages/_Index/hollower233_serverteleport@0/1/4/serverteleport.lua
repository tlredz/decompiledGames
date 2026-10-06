local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local flag = false
local v = {}

local function getRegistries(p: string)
	local v2 = v[p]

	if not v2 then
		v2 = {
			registry = MemoryStoreService:GetSortedMap(p .. "_ReservedServerRegistryV1"),
			liveTimeRegistry = MemoryStoreService:GetSortedMap(p .. "_ReservedServerLiveTimeRegistryV1")
		}
		v[p] = v2
	end

	return v2
end

local function startPool(__poolName: string, __reservedServerAccessCode: string?)
	local v2 = v[__poolName]

	if not v2 then
		v2 = {
			registry = MemoryStoreService:GetSortedMap(__poolName .. "_ReservedServerRegistryV1"),
			liveTimeRegistry = MemoryStoreService:GetSortedMap(__poolName .. "_ReservedServerLiveTimeRegistryV1")
		}
		v[__poolName] = v2
	end

	local v3 = false

	local function writeHeartbeat()
		if game.JobId == "" then
			if not v3 then
				v3 = true
				warn("[ServerTeleport] game.JobId 为空（Studio 会话），跳过心跳写入；保留服发现在 Studio 下不可用")
			end
		else
			local v4 = {
				accessCode = __reservedServerAccessCode,
				privateServerId = game.PrivateServerId,
				jobId = game.JobId,
				playerCount = #Players:GetPlayers(),
				updatedAt = os.time(),
				liveTime = math.floor(workspace.DistributedGameTime)
			}
			local success, result = pcall(v2.registry.SetAsync, v2.registry, game.JobId, v4, 90, v4.updatedAt)

			if not success then
				warn("[ServerTeleport] heartbeat write failed (registry): " .. tostring(result))
			end

			local success2, result2 = pcall(
				v2.liveTimeRegistry.SetAsync,
				v2.liveTimeRegistry,
				game.JobId,
				v4,
				90,
				v4.liveTime
			)

			if not success2 then
				warn("[ServerTeleport] heartbeat write failed (liveTimeRegistry): " .. tostring(result2))
			end
		end
	end

	game:BindToClose(function()
		if game.JobId == "" then
			return
		end

		local success, result = pcall(v2.registry.RemoveAsync, v2.registry, game.JobId)

		if not success then
			warn("[ServerTeleport] deregister failed (registry): " .. tostring(result))
		end

		local success2, result2 = pcall(v2.liveTimeRegistry.RemoveAsync, v2.liveTimeRegistry, game.JobId)

		if not success2 then
			warn("[ServerTeleport] deregister failed (liveTimeRegistry): " .. tostring(result2))
		end
	end)

	while true do
		writeHeartbeat()
		task.wait(20)
	end
end

return {
	server = {
		init = function(value: string?, p)
			if flag then
				error("[ServerTeleport] init() called more than once")
			end

			flag = true
			task.spawn(function()
				local __reservedServerAccessCode = nil
				local __poolName

				if type(value) == "string" and value ~= "" then
					__poolName = value
				elseif game.PrivateServerId == "" or game.PrivateServerOwnerId ~= 0 then
					__poolName = "standard"
				else
					local teleportData = (Players:FindFirstChildWhichIsA("Player") or Players.PlayerAdded:Wait()):GetJoinData().TeleportData

					if type(teleportData) == "table" then
						__poolName = teleportData.__poolName or nil
					end

					if type(__poolName) ~= "string" or __poolName == "" then
						error("[ServerTeleport] reserved server booted without __poolName in TeleportData")
					end

					__reservedServerAccessCode = teleportData.__reservedServerAccessCode
				end

				script:SetAttribute("serverType", __poolName)

				if __poolName ~= "standard" and not (p and p[__poolName]) then
					startPool(__poolName, __reservedServerAccessCode)
				end
			end)
		end,
		teleport = function(poolName: string, data)
			if not flag then
				error("[ServerTeleport] teleport() called before init()")
			end

			local clone = table.clone(data.teleportData or {})
			clone.__poolName = poolName
			local result = data.reservedServerAccessCode
			local targetServer = data.targetServer or "reserved"

			if result == nil and targetServer == "reserved" then
				local success
				success, result = pcall(TeleportService.ReserveServerAsync, TeleportService, game.PlaceId)

				if not success or type(result) ~= "string" or result == "" then
					warn("[ServerTeleport] failed to reserve server: " .. tostring(result))
					return
				end
			end

			local teleportOptions = Instance.new("TeleportOptions")

			if type(result) == "string" and result ~= "" then
				clone.__reservedServerAccessCode = result
				teleportOptions.ReservedServerAccessCode = result
			else
				teleportOptions.ShouldReserveServer = targetServer == "reserved"
			end

			teleportOptions:SetTeleportData(clone)
			local success, result2 = pcall(
				TeleportService.TeleportAsync,
				TeleportService,
				game.PlaceId,
				data.plrList,
				teleportOptions
			)

			if not success then
				warn("[ServerTeleport] teleport failed: " .. tostring(result2))
			end
		end,
		getActiveReservedServers = function(p: string, p2: string?, flag2: boolean?, p3)
			if not flag then
				error("[ServerTeleport] getActiveReservedServers() called before init()")
			end

			local v2 = v[p]

			if not v2 then
				v2 = {
					registry = MemoryStoreService:GetSortedMap(p .. "_ReservedServerRegistryV1"),
					liveTimeRegistry = MemoryStoreService:GetSortedMap(p .. "_ReservedServerLiveTimeRegistryV1")
				}
				v[p] = v2
			end

			local liveTimeRegistry = p2 == "liveTime" and v2.liveTimeRegistry or v2.registry
			local v3 = flag2 ~= false
			local descending = v3 and Enum.SortDirection.Descending or Enum.SortDirection.Ascending
			local v4

			if not (v3 or not p3) then
				v4 = p3
			end

			local success, rangeAsync = pcall(
				liveTimeRegistry.GetRangeAsync,
				liveTimeRegistry,
				descending,
				200,
				v4,
				v3 and p3 or nil
			)

			if not success then
				return {}, nil, (tostring(rangeAsync))
			end

			local now = os.time()
			local result = {}

			for _, v5 in rangeAsync do
				local value = v5.value

				if type(value) ~= "table" then
					continue
				end

				local v6 = now - (tonumber(value.updatedAt) or 0) <= 60
				local v7

				if value.jobId == game.JobId then
					v7 = false
				else
					v7 = value.privateServerId ~= game.PrivateServerId
				end

				if type(value.accessCode) == "string" and value.accessCode ~= "" and v6 and v7 then
					table.insert(result, value)
				end
			end

			return result, #rangeAsync >= 200 and rangeAsync[#rangeAsync].sortKey or nil, nil
		end
	},
	getServerType = function()
		local serverType = script:GetAttribute("serverType")

		if serverType == nil then
			script:GetAttributeChangedSignal("serverType"):Wait()
			serverType = script:GetAttribute("serverType")
		end

		return serverType
	end
}