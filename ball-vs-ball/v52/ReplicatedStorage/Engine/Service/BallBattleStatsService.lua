local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local Core = require(script.Core)
local v = 6
local v2 = RunService:IsStudio() and "BallBattleStats_Studio" or "BallBattleStats"
local remoteFunction = Net:RemoteFunction("BallBattleStats/Get")
local remoteFunction2 = Net:RemoteFunction("BallBattleStats/GetAll")
local flag = false
local flag2 = false
local v3 = nil
local dataStore = nil
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = 0
local flag3 = false
local v10 = nil

local function getConfig()
	if not v10 then
		local Config = require(script.Parent.Config)
		v10 = Config
	end

	return v10
end

local function validId(value)
	return typeof(value) == "string" and #value > 0 and #value <= 45 and utf8.len(value) ~= nil
end

local function getStore()
	if not dataStore then
		dataStore = DataStoreService:GetDataStore(v2)
	end

	return dataStore
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applySnapshot(p, p2)
	if typeof(p2) ~= "table" then
		return
	end

	local success, result = pcall(Core.summarize, p2)

	if success then
		v4[p] = result
		v6[p] = nil
	end
end

local function fetchBall(p)
	if v4[p] then
		return true
	end

	if v5[p] then
		local v11 = os.clock() + 15

		while v5[p] and os.clock() < v11 do
			task.wait(0.05)
		end

		return v4[p] ~= nil
	else
		local v11 = v6[p]

		if v11 and os.clock() < v11 then
			return false
		end

		v5[p] = true
		local success, result = pcall(function()
			if not dataStore then
				dataStore = DataStoreService:GetDataStore(v2)
			end

			return dataStore:GetAsync("ball:" .. p) or Core.empty()
		end)
		v5[p] = nil

		if success then
			local success2, result2 = pcall(Core.summarize, result)

			if success2 then
				v4[p] = result2
				v6[p] = nil
				return true
			else
				v6[p] = os.clock() + 30
				warn("[BallBattleStats] 数据结构异常 " .. p .. ": " .. tostring(result2))
				return false
			end
		else
			v6[p] = os.clock() + 30
			warn("[BallBattleStats] 读取失败 " .. p .. ": " .. tostring(result))
			return false
		end
	end
end

local function serverGet(value)
	local v11

	if typeof(value) == "string" and #value > 0 and #value <= 45 then
		v11 = utf8.len(value) ~= nil
	else
		v11 = false
	end

	if not v11 then
		return {
			ok = false,
			reason = "invalidBallId"
		}
	end

	if fetchBall(value) then
		return {
			ok = true,
			data = v4[value]
		}
	end

	return {
		ok = false,
		reason = "unavailable"
	}
end

local function serverGetAll()
	if not v10 then
		local Config = require(script.Parent.Config)
		v10 = Config
	end

	local v11 = v10
	local cnIds = {}

	for _, v12 in ipairs(v11.ball.list) do
		local cnId = v12.cnId
		local v13

		if typeof(cnId) == "string" and #cnId > 0 and #cnId <= 45 then
			v13 = utf8.len(cnId) ~= nil
		else
			v13 = false
		end

		if not v13 or v4[v12.cnId] then
			continue
		end

		table.insert(cnIds, v12.cnId)
	end

	if #cnIds > 0 then
		local v12 = os.clock() + 15
		local v13 = 0
		local count = 0

		for _ = 1, math.min(8, #cnIds) do
			v13 += 1
			task.spawn(function()
				while os.clock() < v12 do
					count += 1
					local v14 = cnIds[count]

					if not v14 then
						break
					end

					fetchBall(v14)
				end

				v13 -= 1
			end)
		end

		while v13 > 0 and os.clock() < v12 do
			task.wait(0.05)
		end
	end

	local result = {}

	for _, v12 in ipairs(v11.ball.list) do
		local v13 = v4[v12.cnId]

		if v13 and (v13.games > 0 or v13.mirror.games > 0) then
			result[v12.cnId] = v13
		end
	end

	return result
end

local function init()
	assert(RunService:IsServer(), "server.init is server-only")

	if flag then
		return
	end

	flag = true
	v3 = Core.new(function(p, p2)
		if not dataStore then
			dataStore = DataStoreService:GetDataStore(v2)
		end

		applySnapshot(p, dataStore:UpdateAsync("ball:" .. p, function(p3)
			return Core.merge(p3, p2)
		end)) -- equivalent call inferred; original call site unknown
	end, function(p, p2, p3)
		flag3 = true
		warn("[BallBattleStats] " .. (p3 and "Requeued" or "Dropped") .. " batch for " .. p .. ": " .. tostring(p2))
	end)

	if not v10 then
		local Config = require(script.Parent.Config)
		v10 = Config
	end

	local v11 = v10

	remoteFunction.OnServerInvoke = function(p, value)
		local now = os.clock()

		if v7[p] and now - v7[p] < 1 then
			return {
				ok = false,
				reason = "rateLimited"
			}
		end

		v7[p] = now
		local v12

		if typeof(value) == "string" and #value > 0 and #value <= 45 then
			v12 = utf8.len(value) ~= nil
		else
			v12 = false
		end

		if v12 and v11.ball.byCnId[value] then
			return (serverGet(value))
		end

		return {
			ok = false,
			reason = "unknownBall"
		}
	end

	remoteFunction2.OnServerInvoke = function(p)
		local now = os.clock()

		if v8[p] and now - v8[p] < 10 then
			return nil
		end

		v8[p] = now
		return (serverGetAll())
	end

	Players.PlayerRemoving:Connect(function(player)
		v7[player] = nil
		v8[player] = nil
	end)
	task.spawn(function()
		local controlFlowState = 8

		while true do
			if controlFlowState == 0 then
				if v3.hasWork() then
					controlFlowState = 1
				else
					controlFlowState = 2
				end

				continue
			elseif controlFlowState == 1 then
				if flag2 then
					controlFlowState = 4
				else
					controlFlowState = 3
				end

				continue
			elseif controlFlowState == 2 then
				if flag2 then
					controlFlowState = 6
				else
					controlFlowState = 7
				end

				continue
			elseif controlFlowState == 3 then
				local now = os.clock()

				if v9 <= now then
					controlFlowState = 4
				else
					controlFlowState = 2
				end

				continue
			else
				if controlFlowState == 4 then
					if v3.step() then
						controlFlowState = 5
					else
						controlFlowState = 0
					end
				else
					if controlFlowState == 5 then
						v9 = os.clock() + v
					else
						if controlFlowState == 6 then
							break
						end

						if controlFlowState == 7 then
							task.wait(0.1)
						elseif controlFlowState ~= 8 then
							break
						end
					end

					controlFlowState = 0
				end

				continue
			end
		end
	end)
	task.spawn(function()
		local v12 = 1800

		while not flag2 do
			task.wait(v12 * (0.8 + math.random() * 0.4))

			if flag2 then
				break
			end

			if flag3 then
				v12 = math.min(v12 * 2, 7200)
			else
				v12 = math.max(v12 * 0.75, 1800)
			end

			flag3 = false
			local v13 = v3.enqueue()

			if v13 > 0 then
				v = math.max(6, v12 * 0.7 / v13)
			end
		end
	end)
	game:BindToClose(function()
		flag2 = true
		v3.close()

		while v3.hasWork() do
			task.wait(0.05)
		end
	end)
end

local function record(value, value2, p)
	assert(RunService:IsServer(), "server.record is server-only")
	local v11

	if typeof(value) == "string" and #value > 0 and #value <= 45 then
		v11 = utf8.len(value) ~= nil
	else
		v11 = false
	end

	if v11 then
		local v12

		if typeof(value2) == "string" and #value2 > 0 and #value2 <= 45 then
			v12 = utf8.len(value2) ~= nil
		else
			v12 = false
		end

		if v12 then
			if not flag then
				init()
			end

			return v3.record(value, value2, p)
		end
	end

	warn("[BallBattleStats] Invalid ball ID; record dropped")
	return false
end

local v11 = nil
local now = 0
local BallBattleStatsService = {}

function BallBattleStatsService.get(value)
	if RunService:IsServer() then
		return (serverGet(value))
	end

	local v12

	if typeof(value) == "string" and #value > 0 and #value <= 45 then
		v12 = utf8.len(value) ~= nil
	else
		v12 = false
	end

	if not v12 then
		return {
			ok = false,
			reason = "invalidBallId"
		}
	end

	if v4[value] then
		return {
			ok = true,
			data = v4[value]
		}
	end

	if v5[value] then
		return {
			ok = false,
			reason = "loading"
		}
	end

	v5[value] = true
	local success, result = pcall(function()
		return remoteFunction:InvokeServer(value)
	end)
	v5[value] = nil

	if not success or typeof(result) ~= "table" then
		return {
			ok = false,
			reason = "unavailable"
		}
	end

	if result.ok then
		v4[value] = result.data
	end

	return result
end

function BallBattleStatsService.getAll()
	if RunService:IsServer() then
		return (serverGetAll())
	end

	if v11 and os.clock() - now < 300 then
		return v11
	end

	local success, result = pcall(function()
		return remoteFunction2:InvokeServer()
	end)

	if not success or typeof(result) ~= "table" then
		return v11 or {}
	end

	v11 = result
	now = os.clock()

	for k, v12 in pairs(result) do
		v4[k] = v12
	end

	return result
end

function BallBattleStatsService.debugSeedClient(items)
	assert(not RunService:IsServer(), "debugSeedClient 只能由客户端调用")
	local v12 = {}

	for k, item in pairs(items) do
		local success, result = pcall(Core.summarize, item)

		if success then
			v12[k] = result
		end
	end

	v11 = v12
	now = os.clock()
	table.clear(v4)

	for k, v13 in pairs(v12) do
		v4[k] = v13
	end
end

BallBattleStatsService.server = {
	init = init,
	record = record
}
return BallBattleStatsService