local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Net = require(ReplicatedStorage.Packages.Net)
local ServerTeleport = require(ReplicatedStorage.Packages.ServerTeleport)
local ServerTypeService = require(script.Parent.ServerTypeService)
local PartyService = require(script.Parent.PartyService)
local ModeServerDirectory = require(script.Parent.ModeServerDirectory)
local ModeServerCapacity = require(script.Parent.ModeServerCapacity)
local v = ModeServerCapacity.new({
	map = MemoryStoreService:GetHashMap("ModeAdmissionV1"),
	now = os.time
})
local remoteEvent = Net:RemoteEvent("ModeTeleportRequest")
local remoteEvent2 = Net:RemoteEvent("ModeTeleportFeedback")
local random = Random.new()
local v2 = ModeServerDirectory.new({
	getMap = function(p)
		return MemoryStoreService:GetSortedMap(p)
	end,
	clock = os.clock,
	wallTime = os.time,
	random = function(p, p2)
		return random:NextInteger(p, p2)
	end,
	newSignal = function()
		return Instance.new("BindableEvent")
	end,
	jobId = game.JobId,
	privateServerId = game.PrivateServerId
})
local ModeTeleportService = {
	server = {}
}
local v3 = {}
local v4 = {}
local flag = false
local v5 = false
local v6 = nil
local __reservedServerAccessCode = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function reply(player, p)
	if player.Parent == Players then
		remoteEvent2:FireClient(player, p)
	end
end

local flag2 = false

local function publishNow()
	if v5 or game.JobId == "" or v6 ~= ServerTypeService.TWO_V_TWO_POOL_NAME then
		return
	end

	if not __reservedServerAccessCode then
		for _, v7 in Players:GetPlayers() do
			local teleportData = v7:GetJoinData().TeleportData

			if not (type(teleportData) == "table" and teleportData.__reservedServerAccessCode) then
				continue
			end

			__reservedServerAccessCode = teleportData.__reservedServerAccessCode
			break
		end
	end

	if not __reservedServerAccessCode then
		return
	end

	local v7 = {}

	for _, v8 in Players:GetPlayers() do
		v7[tostring(v8.UserId)] = true
	end

	local v8 = workspace:FindFirstChild("大厅") and workspace["大厅"]:FindFirstChild("双人对战")
	local ready = v8 and v8:GetAttribute("ready") == true
	v.publish(__reservedServerAccessCode, v7, Players.MaxPlayers, ready, game.JobId)
	local v10, v11 = v2.publish(v6, {
		jobId = game.JobId,
		privateServerId = game.PrivateServerId,
		accessCode = __reservedServerAccessCode,
		playerCount = #Players:GetPlayers(),
		maxPlayers = Players.MaxPlayers,
		updatedAt = os.time(),
		admissionVersion = 1,
		ready = ready
	})

	if not v10 then
		error(v11)
	end
end

local function publish()
	if flag2 then
		return
	end

	flag2 = true
	local success, result = pcall(publishNow)
	flag2 = false

	if not success then
		error(result)
	end
end

local function release(data)
	if data.dest and data.dest.accessCode then
		local userIds = {}

		for _, member in data.members do
			if data.departed[member] or member.Parent ~= Players then
				continue
			end

			table.insert(userIds, member.UserId)
		end

		local success, result = pcall(v.release, data.dest.accessCode, data.id, userIds)

		if not success then
			warn("[ModeTeleport] release: " .. tostring(result))
		end
	end
end

local function destination(poolName, members, id)
	if poolName == "standard" then
		return {
			placeId = game.PlaceId,
			pool = "standard",
			updatedAt = os.time()
		}
	end

	local userIds = {}

	for _, v7 in members do
		table.insert(userIds, v7.UserId)
	end

	for _ = 1, 3 do
		local v7, v8 = v2.pick(poolName, #members)

		if v8 then
			error(v8)
		end

		if not v7 then
			break
		end

		if v.claim(v7.accessCode, id, userIds) then
			return {
				placeId = game.PlaceId,
				pool = poolName,
				accessCode = v7.accessCode,
				privateServerId = v7.privateServerId,
				jobId = v7.jobId,
				updatedAt = os.time()
			}
		else
			v2.exclude(v7)
		end
	end

	local accessCode, privateServerId = v.create(poolName, random:NextInteger(1, 16), id, function()
		return TeleportService:ReserveServerAsync(game.PlaceId)
	end)

	if not accessCode then
		error("服务器启动中")
	end

	if not v.claim(accessCode, id, userIds) then
		error("新服名额暂不可用")
	end

	return {
		placeId = game.PlaceId,
		pool = poolName,
		accessCode = accessCode,
		privateServerId = privateServerId,
		updatedAt = os.time()
	}
end

local function finish(state)
	if state.finished then
		return
	end

	state.finished = true
	local members = {}

	for _, member in state.members do
		if state.departed[member] or member.Parent ~= Players then
			continue
		end

		table.insert(members, member)
	end

	if state.data and #members > 0 then
		local success, result = pcall(PartyService.server.finishTransfer, state.data, members, state.id)

		if not success then
			warn("[ModeTeleport] recovery: " .. tostring(result))
		end
	end

	if state.confirmedFailure then
		release(state)
	end

	for _, member in state.members do
		if v3[member] ~= state then
			continue
		end

		v3[member] = nil

		if member.Parent ~= Players then
			continue
		end

		member:SetAttribute("ModeTeleportPending", nil)

		if state.started and member.Parent == Players then
			remoteEvent2:FireClient(member, "failed")
		end
	end
end

local function unlocked(player)
	local PlayerData = require(script.Parent.PlayerData)
	local v7 = PlayerData.server.Service:waitForData(player)

	if player.Parent ~= Players or not v7 then
		return false, "failed"
	end

	local ExperienceService = require(script.Parent.ExperienceService)

	if ExperienceService.isFeatureUnlocked(v7.exp.total(), "2v2模式") then
		return true
	end

	local Config = require(script.Parent.Config)
	local lvl = Config.lvl
	local _2v2 = lvl and lvl.byFeatureUnlock and lvl.byFeatureUnlock["2v2模式"]
	local v8 = nil

	if type(_2v2) ~= "table" then
		return false, "locked", v8
	end

	for _, v9 in _2v2 do
		if type(v9.lvl) ~= "number" then
			continue
		end

		local lvl2 = math.floor(v9.lvl)

		if not v8 or lvl2 < v8 then
			v8 = lvl2
		end
	end

	return false, "locked", v8
end

local function run(state, player, poolName)
	local v7 = {}

	for _, member in state.members do
		v7[member] = true
	end

	for i = 1, 3 do
		if os.clock() > state.deadline then
			break
		end

		if i > 1 then
			task.wait((state.flooded and 10 or 2 ^ (i - 1)) + random:NextNumber(0, 1))
		end

		local members = {}

		for _, member in state.members do
			if state.departed[member] or member.Parent ~= Players then
				continue
			end

			table.insert(members, member)
		end

		if #members == 0 then
			break
		end

		local v9 = i
		local v10 = #members < #state.members
		local success, result = pcall(function()
			if not state.data then
				local teleportMembers, v12 = PartyService.server.getTeleportMembers(player, v7)

				if not teleportMembers or #teleportMembers ~= #state.members then
					error(v12 or "队伍成员已变化")
				end

				for k, member in state.members do
					if teleportMembers[k] ~= member then
						error("队伍成员已变化")
					end
				end

				state.dest = destination(poolName, state.members, state.id)

				if os.clock() > state.deadline then
					error("选服超时")
				end

				state.data = PartyService.server.beginTransfer(player, state.dest, state.members, state.id)
				state.data.__poolName = poolName
				state.data.__modeRequestId = state.id

				if state.dest.accessCode then
					state.data.__reservedServerAccessCode = state.dest.accessCode
				end
			end

			state.generation = v9
			state.failed = {}
			state.confirmedFailure = false
			local options

			if v10 and state.retryOptions then
				options = state.retryOptions
			else
				options = Instance.new("TeleportOptions")

				if state.dest.accessCode then
					options.ReservedServerAccessCode = state.dest.accessCode
				end

				local clone = table.clone(state.data)
				clone.__modeGeneration = v9
				options:SetTeleportData(clone)
			end

			local teleportData = options:GetTeleportData()
			teleportData.__modeGeneration = v9
			options:SetTeleportData(teleportData)

			if os.clock() > state.deadline then
				error("传送准备超时")
			end

			state.options = options
			TeleportService:TeleportAsync(state.dest.placeId, members, options)
		end)

		if success then
			local v12 = math.min(state.deadline, os.clock() + 18)

			while os.clock() < v12 do
				local flag3 = true

				for _, v13 in members do
					if v13.Parent ~= Players or (state.departed[v13] or state.failed[v13]) then
						continue
					end

					flag3 = false
				end

				if flag3 then
					break
				else
					task.wait(0.2)
				end
			end

			local flag3 = true

			for _, v13 in members do
				if v13.Parent ~= Players or (state.departed[v13] or state.failed[v13]) then
					continue
				end

				flag3 = false
			end

			if flag3 then
				local flag4 = true

				for _, member in state.members do
					if state.departed[member] or member.Parent ~= Players then
						continue
					end

					flag4 = false
				end

				if flag4 then
					break
				end

				if state.terminal then
					state.confirmedFailure = true
					break
				end

				local v13 = false

				for _, member in state.members do
					if state.departed[member] then
						v13 = true
					end
				end

				if not v13 then
					state.confirmedFailure = true
					PartyService.server.finishTransfer(state.data, state.members, state.id)
					release(state)

					if state.dest.accessCode then
						v2.exclude(state.dest)
					end

					state.data = nil
					state.dest = nil
					state.options = nil
				end
			else
				while os.clock() < state.deadline do
					local v13 = false

					for _, v14 in members do
						if v14.Parent ~= Players or (state.departed[v14] or state.failed[v14]) then
							continue
						end

						v13 = true
					end

					if not v13 then
						break
					end

					task.wait(0.2)
				end

				break
			end
		else
			warn("[ModeTeleport] round " .. i .. ": " .. tostring(result))

			if state.options then
				break
			else
				state.confirmedFailure = true
			end
		end
	end

	finish(state)
end

local function init()
	if flag then
		return
	end

	flag = true
	PartyService.server.init()
	task.spawn(function()
		v6 = ServerTeleport.getServerType()

		if v6 ~= ServerTypeService.TWO_V_TWO_POOL_NAME then
			return
		end

		while not v5 do
			local success, result = pcall(publish)

			if not success then
				warn("[ModeTeleport] heartbeat: " .. tostring(result))
			end

			task.wait(20 + random:NextNumber(0, 3))
		end
	end)
	local flag3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function changed()
		if flag3 then
			return
		end

		flag3 = true
		task.delay(1, function()
			flag3 = false
			local success, result = pcall(publish)

			if not success then
				warn("[ModeTeleport] roster: " .. tostring(result))
			end
		end)
	end

	Players.PlayerAdded:Connect(changed)
	Players.PlayerRemoving:Connect(function(player)
		local v7 = v3[player]

		if v7 then
			v7.departed[player] = true
			v3[player] = nil
		end

		v4[player] = nil
		changed() -- equivalent call inferred; original call site unknown
	end)
	game:BindToClose(function()
		v5 = true

		if v6 == ServerTypeService.TWO_V_TWO_POOL_NAME and game.JobId ~= "" then
			if __reservedServerAccessCode then
				pcall(v.publish, __reservedServerAccessCode, {}, Players.MaxPlayers, false, game.JobId)
			end

			v2.remove(v6, game.JobId)
		end
	end)
	TeleportService.TeleportInitFailed:Connect(function(p, p2, p3, _, retryOptions)
		local v7 = v3[p]
		local teleportData = retryOptions and retryOptions:GetTeleportData()

		if not v7 or v7.finished or type(teleportData) ~= "table" or teleportData.__modeRequestId ~= v7.id or teleportData.__modeGeneration ~= v7.generation then
			return
		end

		warn("[ModeTeleport] " .. p2.Name .. ": " .. tostring(p3))
		v7.failed[p] = true
		v7.retryOptions = retryOptions

		if p2 == Enum.TeleportResult.Flooded then
			v7.flooded = true
		elseif p2 ~= Enum.TeleportResult.Failure and p2 ~= Enum.TeleportResult.GameFull then
			v7.terminal = true
		end
	end)
	remoteEvent.OnServerEvent:Connect(function(player, poolName)
		if poolName == "standard" or poolName == ServerTypeService.TWO_V_TWO_POOL_NAME then
			if v3[player] then
				reply(player, "teleporting") -- equivalent call inferred; original call site unknown
			elseif os.clock() - (v4[player] or -1e999) < 3 then
				reply(player, "failed") -- equivalent call inferred; original call site unknown
			else
				v4[player] = os.clock()
				local v7 = {
					id = HttpService:GenerateGUID(false),
					members = { player },
					departed = {},
					deadline = os.clock() + 55
				}
				v3[player] = v7
				local success, result = pcall(function()
					local serverType = ServerTeleport.getServerType()

					if serverType == "standard" or serverType == ServerTypeService.TWO_V_TWO_POOL_NAME then
						if poolName == ServerTypeService.TWO_V_TWO_POOL_NAME then
							local v8, v9, v10 = unlocked(player)

							if not v8 then
								remoteEvent2:FireClient(player, v9, v10)
								return
							end
						end

						local teleportMembers, v8, v9 = PartyService.server.getTeleportMembers(player)

						if not teleportMembers then
							remoteEvent2:FireClient(player, v8, v9)
							return
						end

						for _, teleportMember in teleportMembers do
							if not (v3[teleportMember] and v3[teleportMember] ~= v7) then
								continue
							end

							reply(player, "busy") -- equivalent call inferred; original call site unknown
							return
						end

						v7.members = teleportMembers
						v7.started = true

						for _, teleportMember in teleportMembers do
							v3[teleportMember] = v7
							teleportMember:SetAttribute("ModeTeleportPending", true)
							reply(teleportMember, "teleporting") -- equivalent call inferred; original call site unknown
						end

						run(v7, player, poolName)
					else
						reply(player, "invalid") -- equivalent call inferred; original call site unknown
					end
				end)

				if not success then
					warn("[ModeTeleport] " .. tostring(result))
				end

				if not v7.finished then
					finish(v7)
				end
			end
		else
			reply(player, "invalid") -- equivalent call inferred; original call site unknown
		end
	end)
end

ModeTeleportService.server.init = init
return ModeTeleportService