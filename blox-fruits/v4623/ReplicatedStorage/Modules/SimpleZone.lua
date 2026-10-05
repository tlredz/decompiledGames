local createVector = vector.create
local SimpleZone = {}
SimpleZone.__index = SimpleZone
local v = {}
local Tracking = require(game.ReplicatedStorage.Modules.Tracking)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local Lock = require(game.ReplicatedStorage.Modules.Util.Lock)
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()
local RunService2 = game:GetService("RunService")
RunService2:IsServer()
local v2 = {
	playerEntered = not isClient,
	playerExited = not isClient,
	localPlayerEntered = isClient,
	localPlayerExited = isClient
}
local now = 1
local v3 = false
local flag = false
local v4 = nil

local function Update()
	if flag then
		return false
	end

	local v5 = os.clock() - now >= 1
	flag = true
	now = os.clock()
	local v6 = {}
	local v7 = {}
	local v8 = {}
	local v9 = {}

	for _, v10 in pairs(v) do
		table.insert(v6, v10)
	end

	for i = #v6, 1, -1 do
		local v10 = v6[i]
		local region = v10.region
		v6[i] = nil
		local isLocked = v10._lock:IsLocked()
		local lock = v10._lock:GetLock("_Destroyed")

		if not (not isLocked or lock) then
			continue
		end

		local v11 = {
			uid = v10.uid,
			entries = {}
		}
		local v12 = {
			uid = v10.uid,
			entries = {}
		}
		table.insert(v7, v11)
		table.insert(v8, v12)
		local entries = v12.entries
		local entries2 = v11.entries
		local players = Tracking:GetPlayers()

		for k, _ in pairs(v10.distances) do
			local tracker = Tracking:GetTracker(k)

			if not (tracker and tracker.Player) then
				v10.distances[k] = nil
			end
		end

		if #players > 0 then
			for i2 = #players, 1, -1 do
				local player = players[i2]
				local tracker = Tracking:GetTracker(player)

				if tracker and tracker.Player then
					if region.infinite and not v10.within[player] then
						entries[player] = true
					end
				else
					table.remove(players, i2)
				end
			end

			if #players > 0 and region.radius then
				for _, player in pairs(players) do
					local distanceFromOrigin = v10:DistanceFromOrigin(player, -1)

					if not distanceFromOrigin then
						continue
					end

					if isClient then
						v10.distances[player] = distanceFromOrigin
					end

					if distanceFromOrigin.default <= region.radius then
						entries[player] = true
					end
				end
			end
		end

		for k, _ in pairs(v10.within) do
			if not entries[k] or lock then
				entries2[k] = true
			end
		end

		if lock then
			v9[v10.uid] = true
		end
	end

	if #v7 > 0 then
		for i = #v7, 1, -1 do
			local v10 = v7[i]
			local v11 = v[v10.uid]

			for k, _ in pairs(v10.entries) do
				if not (v11.within[k] and (not v11.region.infinite or v9[v11.uid] or not k.Parent)) then
					continue
				end

				v11.within[k] = nil

				if v11.localPlayerExited then
					v11.localPlayerExited:Fire()
				elseif v11.playerExited then
					v11.playerExited:Fire(k)
				end
			end

			table.clear(v10.entries)
		end
	end

	if #v8 > 0 then
		for i = #v8, 1, -1 do
			local v10 = v8[i]
			local v11 = v[v10.uid]

			for k in v10.entries do
				if v11.within[k] or v11._lock:IsLocked() then
					continue
				end

				v11.within[k] = os.time()

				if v11.localPlayerEntered then
					v11.localPlayerEntered:Fire()
				elseif v11.playerEntered then
					v11.playerEntered:Fire(k)
				end
			end

			table.clear(v10.entries)
		end
	end

	for k in v9 do
		local v10 = v[k]
		v[k] = nil

		if not v10 then
			continue
		end

		for _, v11 in pairs(v10) do
			if not (typeof(v11) == "table" and v11.Destroy) then
				continue
			end

			v11:Destroy()
			table.clear(v11)
		end

		if v10.debugPart then
			v10.debugPart:Destroy()
			v10.debugPart = nil
		end

		table.clear(v10.within)
		table.clear(v10.distances)
	end

	if (v5 or v3) and v4 then
		v4:Fire()
	end

	table.clear(v6)
	flag = false
	v3 = false
	return true
end

function SimpleZone.BindToUpdate(_, callback)
	if not v4 then
		v4 = Signal.new()
	end

	task.spawn(callback)
	return v4:Connect(function()
		return callback()
	end)
end

function SimpleZone._Update(_)
	v3 = true
	Update()
end

function SimpleZone.new(data, group: string, p2: number?)
	assert(group, "Zone needs group")
	assert(data.radius, "Zone needs radius")
	assert(data.cf, "Zone needs cf")
	local radius = data.radius * 0.5
	local cf = data.cf
	local infinite = data.infinite
	local object = setmetatable({
		_lock = Lock.new(true),
		region = {
			cf = cf,
			radius = radius,
			infinite = infinite,
			radiusType = data.radiusType
		},
		_group = group,
		debugPart = nil,
		timeIn = p2 or workspace:GetServerTimeNow(),
		uid = tostring(math.random()),
		distances = {},
		within = {}
	}, SimpleZone)

	function object:Connect(p4, callback)
		if not v2[p4] then
			return
		end

		if not self[p4] then
			self[p4] = Signal.new()
		end

		return self[p4]:Connect(function(...)
			return callback(...)
		end)
	end

	object:Disable()
	v[object.uid] = object
	return object
end

function SimpleZone:Destroy()
	self._lock:Lock("_Destroyed")
end

function SimpleZone:Enable()
	self._lock:Unlock("_Enabled")
end

function SimpleZone:Disable()
	self._lock:Lock("_Enabled")
end

function SimpleZone.GetPlayersInZoneArray(p)
	local result = {}

	for k, _ in pairs(p.within) do
		table.insert(result, k)
	end

	return result
end

function SimpleZone:DistanceFromOrigin(p2, p3: number?)
	local distance = self.distances[p2]
	local region = self.region

	if not (p3 and p3 <= os.clock() - now) then
		return distance
	end

	local tracker = Tracking:GetTracker(p2)
	local v5 = tracker and tracker:getRoot()

	if not v5 then
		return distance
	end

	local position = v5.Position
	local magnitude = (position - region.cf.p).Magnitude
	local magnitude2 = (position * createVector(1, 0, 1) - region.cf.p * createVector(1, 0, 1)).Magnitude
	return {
		default = (position * region.radiusType - region.cf.p * region.radiusType).Magnitude,
		withY = magnitude,
		withoutY = magnitude2
	}
end

function SimpleZone.FindPlayer(p, p2, flag2: boolean?)
	if flag2 then
		Update()
	end

	return p.within[p2] ~= nil
end

function SimpleZone.SetInfiniteRegion(p, infinite: boolean)
	p.region.infinite = infinite
end

task.spawn(function()
	while true do
		if os.clock() - now < 1 then
			task.wait()
		else
			Update()
		end
	end
end)
return SimpleZone