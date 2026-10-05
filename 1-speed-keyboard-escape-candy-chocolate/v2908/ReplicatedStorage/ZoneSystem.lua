local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Signal"))
local ZoneSystem = {
	TAG = "Zone",
	ID_ATTRIBUTE = "ZoneId"
}

function ZoneSystem.GetZoneId(instance)
	return instance:GetAttribute(ZoneSystem.ID_ATTRIBUTE)
end

function ZoneSystem.GetZonesById(p, p2: string?)
	local result = {}

	for _, v in ipairs(ZoneSystem.GetZones()) do
		if v:GetAttribute(p2 or ZoneSystem.ID_ATTRIBUTE) == p then
			table.insert(result, v)
		end
	end

	return result
end

function ZoneSystem.GetSafeZonesById(p)
	local result = {}

	for _, v in ipairs(ZoneSystem.GetZones()) do
		if not (v:GetAttribute(ZoneSystem.ID_ATTRIBUTE) == p and v:GetAttribute("SafeZone") == true) then
			continue
		end

		table.insert(result, v)
	end

	return result
end

function ZoneSystem.GetSafeZones()
	return ZoneSystem.GetZonesById(true, "SafeZone")
end

function ZoneSystem.GetSASZones()
	local result = {}

	for _, v in ipairs(ZoneSystem.GetZones()) do
		if not (v:GetAttribute(ZoneSystem.ID_ATTRIBUTE) == "SAS" and typeof(v:GetAttribute("SAS")) == "number") then
			continue
		end

		table.insert(result, v)
	end

	return result
end

function ZoneSystem.GetSASZoneById(p: number)
	for _, v in ipairs(ZoneSystem.GetZones()) do
		if v:GetAttribute(ZoneSystem.ID_ATTRIBUTE) == "SAS" and v:GetAttribute("SAS") == p then
			return v
		end
	end

	return nil
end

function ZoneSystem.GetTaggedParts(tag: string)
	local parts = {}

	for _, part in ipairs(CollectionService:GetTagged(tag)) do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	return parts
end

function ZoneSystem.GetZones()
	return ZoneSystem.GetTaggedParts(ZoneSystem.TAG)
end

local function pointInZone(instance, p)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(p)
	local v = instance.Size * 0.5
	return math.abs(pointToObjectSpace.X) <= v.X and math.abs(pointToObjectSpace.Y) <= v.Y and math.abs(pointToObjectSpace.Z) <= v.Z
end

function ZoneSystem.GetZoneAt(p, p2)
	local v = p2 or ZoneSystem.GetZones()
	local position = p.Position

	for _, v2 in ipairs(v) do
		local pointToObjectSpace = v2.CFrame:PointToObjectSpace(position)
		local v3 = v2.Size * 0.5
		local v4

		if math.abs(pointToObjectSpace.X) <= v3.X and math.abs(pointToObjectSpace.Y) <= v3.Y then
			v4 = math.abs(pointToObjectSpace.Z) <= v3.Z
		else
			v4 = false
		end

		if v4 then
			return v2
		end
	end

	return nil
end

function ZoneSystem.CreateTracker(callback, value)
	local v = value or 0.1
	local v2 = {
		Entered = Signal.new(),
		Exited = Signal.new()
	}
	local v3 = {}
	local total = 0

	local function setZone(player, object)
		local userId = player.UserId
		local v4 = v3[userId]

		if object == v4 then
			return
		end

		if v4 then
			v2.Exited:Fire(player, v4, v4:GetAttributes())
		end

		if object then
			v2.Entered:Fire(player, object, object:GetAttributes())
		end

		v3[userId] = object
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < v then
			return
		end

		total = 0
		local zones = ZoneSystem.GetZones()
		local v4 = {}

		for _, v5 in ipairs(callback()) do
			local player = v5.player

			if not player then
				continue
			end

			v4[player.UserId] = true
			local hrp = v5.hrp
			local v6

			if hrp then
				v6 = ZoneSystem.GetZoneAt(hrp, zones) or nil
			end

			setZone(player, v6)
		end

		for k, v5 in pairs(v3) do
			if v4[k] then
				continue
			end

			local playerByUserId = Players:GetPlayerByUserId(k)

			if playerByUserId then
				v2.Exited:Fire(playerByUserId, v5, v5:GetAttributes())
			end

			v3[k] = nil
		end
	end)

	function v2:GetZone(p)
		return v3[p.UserId]
	end

	function v2.Stop(_)
		heartbeatConnection:Disconnect()
		v2.Entered:Destroy()
		v2.Exited:Destroy()
		table.clear(v3)
	end

	return v2
end

local function entryFor(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoid and humanoid.Health > 0 then
		return {
			player = player,
			hrp = humanoidRootPart
		}
	end

	return {
		player = player
	}
end

local tracker

if RunService:IsClient() then
	local localPlayer = Players.LocalPlayer
	tracker = ZoneSystem.CreateTracker(function()
		return { (entryFor(localPlayer)) }
	end)
else
	tracker = ZoneSystem.CreateTracker(function()
		local result = {}

		for _, v2 in ipairs(Players:GetPlayers()) do
			table.insert(result, (entryFor(v2)))
		end

		return result
	end)
end

ZoneSystem.entered = tracker.Entered
ZoneSystem.exited = tracker.Exited
ZoneSystem.tracker = tracker

local function filteredById(p, p2)
	local function wrap(p3)
		return function(_, callback)
			return p[p3](p, function(p4, p5, p6)
				if p6[ZoneSystem.ID_ATTRIBUTE] == p2 then
					callback(p4, p5, p6)
				end
			end)
		end
	end

	local v3 = "Connect"
	local v2 = {
		Connect = function(self, callback)
			return p[v3](p, function(p3, p4, p5)
				if p5[ZoneSystem.ID_ATTRIBUTE] == p2 then
					callback(p3, p4, p5)
				end
			end)
		end,
		Once = 0
	}
	local v4 = "Once"

	function v2.Once(_, callback)
		return p[v4](p, function(p3, p4, p5)
			if p5[ZoneSystem.ID_ATTRIBUTE] == p2 then
				callback(p3, p4, p5)
			end
		end)
	end

	return v2
end

function ZoneSystem.EnteredId(p)
	return (filteredById(tracker.Entered, p))
end

function ZoneSystem.ExitedId(p)
	return (filteredById(tracker.Exited, p))
end

function ZoneSystem.GetCurrentZone(p)
	return tracker:GetZone(p)
end

return ZoneSystem