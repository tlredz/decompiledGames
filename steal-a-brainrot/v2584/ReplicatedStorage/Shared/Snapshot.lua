local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local remoteEvent = Net:RemoteEvent("Snapshot/RealiableChannel")
local unreliableRemoteEvent = Net:UnreliableRemoteEvent("Snapshot/UnrealiableChannel")
local isServer = RunService:IsServer()
local instant = FFlags:GetInstant("SnapshotDelay", 0.1)
local lerp = CFrame.identity.Lerp
local toOrientation = CFrame.identity.ToOrientation
local fuzzyEq = CFrame.identity.FuzzyEq
local bulkMoveTo = workspace.BulkMoveTo
local v = 0
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getTag(p: number)
	return (`SnapshotObj_{p}`)
end

local function getId(instance)
	local v6 = v2[instance]

	if v6 then
		return v6
	end

	v += 1
	v %= 65535
	local v7 = v
	v2[instance] = v7
	v3[v7] = instance
	v4[tostring(v7)] = instance
	v5[tostring(v7)] = true
	instance:AddTag((`SnapshotObj_{v7}`))
	return v7
end

local function getObjectFromId(p)
	return v3[p]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearId(p)
	if v3[p] then
		v2[v3[p]] = nil
		v3[p] = nil
	end

	v4[tostring(p)] = nil
end

local v6 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function removeObject(p)
	local v7 = v6[p]

	if v7 then
		local v8 = v2[v7]

		if not v8 then
			v += 1
			v %= 65535
			v8 = v
			v2[v7] = v8
			v3[v8] = v7
			v4[tostring(v8)] = v7
			v5[tostring(v8)] = true
			v7:AddTag((`SnapshotObj_{v8}`))
		end

		clearId(v8) -- equivalent call inferred; original call site unknown
	end

	v6[p] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addObject(instance, instance2)
	if not v2[instance2] then
		v += 1
		v %= 65535
		local v7 = v
		v2[instance2] = v7
		v3[v7] = instance2
		v4[tostring(v7)] = instance2
		v5[tostring(v7)] = true
		instance2:AddTag((`SnapshotObj_{v7}`))
	end

	v6[instance] = instance2
end

local function create(instance, instance2)
	assert(isServer, "create can only be used by server")
	addObject(instance, instance2) -- equivalent call inferred; original call site unknown
	local destroyingConnection = instance2.Destroying:Once(function()
		removeObject(instance) -- equivalent call inferred; original call site unknown
	end)
	local destroyingConnection2 = instance.Destroying:Once(function()
		removeObject(instance) -- equivalent call inferred; original call site unknown
	end)
	return function()
		destroyingConnection:Disconnect()
		destroyingConnection2:Disconnect()
		removeObject(instance) -- equivalent call inferred; original call site unknown
	end
end

if isServer then
	local total = 0
	local pivots = {}
	local players = {}
	RunService.PostSimulation:Connect(function(dt: number)
		total += dt

		if total < 0.05 then
			return
		end

		total = 0
		debug.profilebegin("Snapshot:Step")

		if next(v5) then
			for _, player in players do
				remoteEvent:FireClient(player, v5)
			end

			table.clear(v5)
		end

		local serverTimeNow = workspace:GetServerTimeNow()
		local buf = buffer.create(890)
		local count = 0
		local total2 = 0

		local function sendBuffer()
			if total2 == 0 then
				return
			end

			debug.profilebegin("Snapshot:SendBuffer")
			local buf2 = buffer.create(total2 + 10)
			buffer.copy(buf2, 10, buf, 0, total2)
			buffer.writef64(buf2, 0, serverTimeNow)
			buffer.writeu16(buf2, 8, count)

			for _, player in players do
				unreliableRemoteEvent:FireClient(player, buf2)
			end

			buf = buffer.create(890)
			count = 0
			total2 = 0
			debug.profileend()
		end

		debug.profilebegin("Snapshot:BuildBuffer")

		for k, v7 in v6 do
			local v8 = v2[v7]

			if not v8 then
				v += 1
				v %= 65535
				v8 = v
				v2[v7] = v8
				v3[v8] = v7
				v4[tostring(v8)] = v7
				v5[tostring(v8)] = true
				v7:AddTag((`SnapshotObj_{v8}`))
			end

			local pivot = k:GetPivot()
			local v9 = pivots[k]

			if v9 and fuzzyEq(pivot, v9) then
				continue
			end

			if total2 + 26 > 900 then
				sendBuffer()
			end

			pivots[k] = pivot
			count += 1
			buffer.writeu16(buf, total2, v8)
			local v10 = total2 + 2
			local X = pivot.X
			buffer.writef32(buf, v10, X)
			local v11 = total2 + 6
			local Y = pivot.Y
			buffer.writef32(buf, v11, Y)
			local v12 = total2 + 10
			local Z = pivot.Z
			buffer.writef32(buf, v12, Z)
			local v13, v14, v15 = toOrientation(pivot)
			local v16 = total2 + 14
			buffer.writef32(buf, v16, v13)
			local v17 = total2 + 18
			buffer.writef32(buf, v17, v14)
			local v18 = total2 + 22
			buffer.writef32(buf, v18, v15)
			total2 += 26
		end

		debug.profileend()
		sendBuffer()
		debug.profileend()
	end)

	local function onPlayerLoaded(player)
		if table.find(players, player) then
			return
		end

		table.insert(players, player)

		if next(v4) then
			remoteEvent:FireClient(player, v4)
		end
	end

	Players.PlayerRemoving:Connect(function(player)
		local index = table.find(players, player)

		if index then
			table.remove(players, index)
		end
	end)
	remoteEvent.OnServerEvent:Connect(onPlayerLoaded)

	for _, v7 in Players:GetPlayers() do
		task.defer(onPlayerLoaded, v7)
	end
else
	local v7 = {}
	local v8 = 0
	local now = 0

	local function getClosestSnapshotToRenderTime(p: number, list)
		local count = #list

		if count < 2 then
			return nil, nil
		end

		local v9 = 1

		while v9 <= count do
			local v10 = (v9 + count) // 2

			if list[v10].t <= p then
				v9 = v10 + 1
			else
				count = v10 - 1
			end
		end

		local v10 = list[count]
		local v11 = list[count + 1]

		if v10 and v11 and v10.t == v11.t then
			return nil, nil
		end

		return v10, v11
	end

	local v9 = nil
	RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("snapshot:interpolate")
		debug.profilebegin("calculateRenderTime")
		local v10 = v8 + (os.clock() - now)
		v9 = (v9 or v10 - instant) + dt
		local v11 = instant - (v10 - v9)

		if instant < math.abs(v11) then
			v9 = v10 - instant
		elseif v11 > 0.01 then
			v9 = math.max(v10 - instant, v9 - dt * 0.1)
		elseif v11 < -0.01 then
			v9 = math.min(v10 - instant, v9 + dt * 0.1)
		end

		debug.profileend()
		debug.profilebegin("interpolateSnapshots")
		local count = 0
		local v13 = {}
		local v14 = {}

		for k, v15 in v7 do
			debug.profilebegin("getClosestSnapshotToRenderTime")
			local closestSnapshotToRenderTime, v16 = getClosestSnapshotToRenderTime(v9, v15)
			debug.profileend()

			if not (closestSnapshotToRenderTime and v16) then
				continue
			end

			local v17 = math.clamp(
				(v9 - closestSnapshotToRenderTime.t) / (v16.t - closestSnapshotToRenderTime.t),
				0,
				1.1
			)
			count += 1
			v13[count] = k
			v14[count] = lerp(closestSnapshotToRenderTime.cf, v16.cf, v17)
		end

		debug.profileend()
		debug.profilebegin("bulkMoveTo")
		bulkMoveTo(workspace, v13, v14, Enum.BulkMoveMode.FireCFrameChanged)
		debug.profileend()
		debug.profileend()
	end)
	unreliableRemoteEvent.OnClientEvent:Connect(function(buf: buffer)
		local v10 = 0
		local v11 = buffer.readf64(buf, v10)
		local v12 = v10 + 8

		if v11 < v8 then
			return
		end

		v8 = v11
		now = os.clock()
		local v13 = buffer.readu16(buf, v12)
		local v14 = v12 + 2

		for _ = 1, v13 do
			local v15 = buffer.readu16(buf, v14)
			local cf = CFrame.new(
				buffer.readf32(buf, v14 + 2),
				buffer.readf32(buf, v14 + 6),
				(buffer.readf32(buf, v14 + 10))
			) * CFrame.fromOrientation(
				buffer.readf32(buf, v14 + 14),
				buffer.readf32(buf, v14 + 18),
				(buffer.readf32(buf, v14 + 22))
			)
			v14 += 26
			local v17 = v3[v15]

			if not (v17 and v17.Parent) then
				continue
			end

			local v18 = {
				t = v11,
				cf = cf
			}

			if v7[v17] then
				table.insert(v7[v17], v18)
			else
				v7[v17] = { v18 }
			end

			if #v7[v17] > 25 then
				table.remove(v7[v17], 1)
			end
		end
	end)
	local connections = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindObject(p: number, part)
		if v3[p] == part then
			return
		end

		if part:IsA("BasePart") then
			part.Anchored = true
		end

		v2[part] = p
		v3[p] = part
		part.Destroying:Once(function()
			if v3[p] == part then
				v3[p] = nil
			end

			v2[part] = nil
			v7[part] = nil
		end)
	end

	local function watchId(p: number)
		if connections[p] then
			return
		end

		local tag = getTag(p) -- equivalent call inferred; original call site unknown
		connections[p] = CollectionService:GetInstanceAddedSignal(tag):Connect(function(part)
			bindObject(p, part) -- equivalent call inferred; original call site unknown
		end)
		local v10 = CollectionService:GetTagged(tag)[1]

		if typeof(v10) == "Instance" and v10.Parent then
			bindObject(p, v10) -- equivalent call inferred; original call site unknown
		end
	end

	remoteEvent.OnClientEvent:Connect(function(items)
		for k in items do
			local v10 = tonumber(k)

			if v10 then
				watchId(v10)
			end
		end
	end)
	remoteEvent:FireServer()
end

return {
	DELAY = instant,
	create = create
}