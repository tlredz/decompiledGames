local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local v = false
local v2 = {}

local function ensureOrbCollisionConfigured(_noCollideGroups)
	if not v then
		v = true
		pcall(function()
			PhysicsService:RegisterCollisionGroup("AAWinOrb")
		end)
	end

	for _, item in _noCollideGroups do
		if v2[item] then
			continue
		end

		v2[item] = true
		local v3 = item
		pcall(function()
			PhysicsService:RegisterCollisionGroup(v3)
		end)
	end
end

local OrbController = {}
OrbController.__index = OrbController

function OrbController.new(remote, options)
	local v3 = options or {}
	local self = setmetatable({}, OrbController)
	self._remote = remote
	self._giantOrbRemote = v3.giantOrbRemote or nil
	self._activeOrbs = {}
	self._player = Players.LocalPlayer
	self._despawnSec = v3.despawnSec or 60
	self._parent = v3.parent or workspace
	self._orbSpawnZone = nil
	self._amountByPhase = v3.amountByPhase or {}
	self._timelineCues = v3.timelineCues or {}
	self._noCollideGroups = v3.noCollideGroups or {}

	if #self._noCollideGroups > 0 then
		ensureOrbCollisionConfigured(self._noCollideGroups)
	end

	return self
end

function OrbController:scan(instance)
	local scriptables = instance:FindFirstChild("Scriptables")
	local zones = scriptables and scriptables:FindFirstChild("Zones")
	local orbsSpawn = zones and zones:FindFirstChild("OrbsSpawn")

	if orbsSpawn and orbsSpawn:IsA("BasePart") then
		self._orbSpawnZone = orbsSpawn
	else
		warn("[OrbController] OrbsSpawn BasePart not found at mapClone.Scriptables.Zones.OrbsSpawn")
	end
end

function OrbController:isScanned()
	return self._orbSpawnZone ~= nil
end

function OrbController:getAmountForPhase(p2: number)
	return self._amountByPhase[p2] or 0
end

function OrbController:getAmountForTimeline(p2: number)
	local amount = 0

	for _, _timelineCue in self._timelineCues do
		if _timelineCue.Time <= p2 then
			amount = _timelineCue.Amount
		else
			break
		end
	end

	return amount
end

function OrbController:_spawnOne(position: Vector3, instance, flag: boolean?)
	local clone = instance:Clone()
	local primaryPart = nil

	if clone:IsA("Model") then
		clone:PivotTo(CFrame.new(position))

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			if flag then
				part.Size *= 5
			end

			part.Anchored = false
			part.CanCollide = false
		end

		primaryPart = clone.PrimaryPart

		if primaryPart then
			primaryPart.CanCollide = true
		end
	elseif clone:IsA("BasePart") then
		if flag then
			clone.Size *= 5
		end

		clone.CFrame = CFrame.new(position)
		clone.Anchored = false
		clone.CanCollide = true
		primaryPart = clone
	end

	if not primaryPart then
		clone:Destroy()
		return
	end

	if #self._noCollideGroups > 0 then
		primaryPart.CollisionGroup = "AAWinOrb"
	end

	clone.Parent = self._parent
	table.insert(self._activeOrbs, clone)
	local flag2 = false
	local _remote = self._remote
	local _giantOrbRemote

	if flag then
		_giantOrbRemote = self._giantOrbRemote or nil
	else
		_giantOrbRemote = nil
	end

	local _player = self._player
	local _despawnSec = self._despawnSec
	local touchedConnection = nil
	touchedConnection = primaryPart.Touched:Connect(function(otherPart)
		local character = _player.Character

		if not (character and otherPart:IsDescendantOf(character)) or flag2 then
			return
		end

		flag2 = true
		touchedConnection:Disconnect()
		local index = table.find(self._activeOrbs, clone)

		if index then
			table.remove(self._activeOrbs, index)
		end

		clone:Destroy()

		if _giantOrbRemote then
			_giantOrbRemote:FireServer()
		else
			_remote:FireServer()
		end
	end)
	task.delay(_despawnSec, function()
		if flag2 then
			return
		end

		flag2 = true
		touchedConnection:Disconnect()
		local index = table.find(self._activeOrbs, clone)

		if index then
			table.remove(self._activeOrbs, index)
		end

		if clone and clone.Parent then
			clone:Destroy()
		end
	end)
end

function OrbController:spawnOrbs(items, p: number)
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local collectibleOrb = adminAbuse and adminAbuse:FindFirstChild("CollectibleOrb")

	if not collectibleOrb then
		warn("[OrbController] CollectibleOrb not found in ReplicatedStorage.AdminAbuse")
		return
	end

	for _, item in items do
		for _ = 1, p do
			self:_spawnOne(
				item + Vector3.new((math.random() * 2 - 1) * 3, math.random() * 1.5 + 0.5, (math.random() * 2 - 1) * 3),
				collectibleOrb
			)
		end
	end
end

function OrbController:spawnFromZone(p: number)
	if not self._orbSpawnZone then
		warn("[OrbController] spawnFromZone called before scan() — no OrbsSpawn zone")
		return
	end

	if p <= 0 then
		return
	end

	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local collectibleOrb = adminAbuse and adminAbuse:FindFirstChild("CollectibleOrb")

	if not collectibleOrb then
		warn("[OrbController] CollectibleOrb not found in ReplicatedStorage.AdminAbuse")
		return
	end

	local _orbSpawnZone = self._orbSpawnZone
	local v3 = _orbSpawnZone.Size.X * 0.5
	local v4 = _orbSpawnZone.Size.Y * 0.5
	local v5 = _orbSpawnZone.Size.Z * 0.5

	for _ = 1, p do
		local v6 = (math.random() * 2 - 1) * v3
		local v7 = (math.random() * 2 - 1) * v4
		local v8 = (math.random() * 2 - 1) * v5
		self:_spawnOne(_orbSpawnZone.CFrame:PointToWorldSpace((Vector3.new(v6, v7, v8))), collectibleOrb)
	end
end

function OrbController:spawnForPhase(p: number)
	local amountForPhase = self:getAmountForPhase(p)

	if amountForPhase <= 0 then
		return
	end

	self:spawnFromZone(amountForPhase)
end

function OrbController:spawnGiantOrbs(items, p: number)
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local bigCollectibleOrb = adminAbuse and adminAbuse:FindFirstChild("BigCollectibleOrb")

	if not bigCollectibleOrb then
		warn("[OrbController] CollectibleOrb not found in ReplicatedStorage.AdminAbuse")
		return
	end

	for _, item in items do
		for _ = 1, p do
			self:_spawnOne(
				item + Vector3.new((math.random() * 2 - 1) * 3, math.random() * 1.5 + 0.5, (math.random() * 2 - 1) * 3),
				bigCollectibleOrb,
				true
			)
		end
	end
end

function OrbController:spawnGiantFromZone(p: number)
	if not self._orbSpawnZone then
		warn("[OrbController] spawnGiantFromZone called before scan() — no OrbsSpawn zone")
		return
	end

	if p <= 0 then
		return
	end

	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local collectibleOrb = adminAbuse and adminAbuse:FindFirstChild("CollectibleOrb")

	if not collectibleOrb then
		warn("[OrbController] CollectibleOrb not found in ReplicatedStorage.AdminAbuse")
		return
	end

	local _orbSpawnZone = self._orbSpawnZone

	for _ = 1, p do
		local v3 = math.random() * 2 - 1
		local v4 = math.random() * 2 - 1
		local v5 = math.random() * 2 - 1
		self:_spawnOne(_orbSpawnZone.CFrame:PointToWorldSpace((Vector3.new(v3, v4, v5))), collectibleOrb, true)
	end
end

function OrbController:destroy()
	for _, _activeOrb in self._activeOrbs do
		if not (_activeOrb and _activeOrb.Parent) then
			continue
		end

		local v3 = _activeOrb
		pcall(function()
			v3:Destroy()
		end)
	end

	table.clear(self._activeOrbs)
	self._orbSpawnZone = nil
end

return OrbController