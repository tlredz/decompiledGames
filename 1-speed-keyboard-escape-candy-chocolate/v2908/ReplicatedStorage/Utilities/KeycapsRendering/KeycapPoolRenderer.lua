local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChunkSystem = require(script.Parent.Parent.ChunkSystem)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local KeycapStreamConfig = require(script.Parent.KeycapStreamConfig)
local KeycapRecordSchema = require(script.Parent.KeycapRecordSchema)
local noneSentinel = KeycapRecordSchema.NoneSentinel
local KeycapPoolRenderer = {}
KeycapPoolRenderer.__index = KeycapPoolRenderer
KeycapPoolRenderer.ReturnedToPool = Signal.new()

function KeycapPoolRenderer.new(template, folder, surfaceAppearances)
	local self = setmetatable({}, KeycapPoolRenderer)
	self._template = template
	self._folder = folder
	self._surfaceAppearances = surfaceAppearances
	self._grid = ChunkSystem.new(KeycapStreamConfig.ChunkDimensions, KeycapStreamConfig.ChunkSize)
	self._byId = {}
	self._pools = {}
	self._instanceCounts = {}
	self._loadedByChar = {}
	self._loadedChunks = {}
	self._desiredChunks = {}
	self._loadQueue = {}
	self._loadQueueDirty = false
	self._unloadQueue = {}
	self._currentChunk = nil
	self._camPos = nil
	self._avgLoadSec = 0
	self._avgUnloadSec = 0
	self._loadTimeSamples = table.create(30)
	self._unloadTimeSamples = table.create(30)
	self._renderingEnabled = true
	return self
end

local function recordWindowAverage(list, p: number)
	table.insert(list, p)

	if #list > 30 then
		table.remove(list, 1)
	end

	local total = 0

	for i = 1, #list do
		total += list[i]
	end

	return total / #list
end

function KeycapPoolRenderer:_isChunkVisible(object)
	if self._desiredChunks[object] then
		return true
	end

	local _currentChunk = self._currentChunk

	if not _currentChunk then
		return false
	end

	local chunkSize = KeycapStreamConfig.ChunkSize
	local position = _currentChunk:GetPosition()
	local position2 = object:GetPosition()
	local v

	if math.abs(position2.X - position.X) <= chunkSize then
		v = math.abs(position2.Z - position.Z) <= chunkSize
	else
		v = false
	end

	if KeycapStreamConfig.ChunkDimensions == 3 then
		return v and math.abs(position2.Y - position.Y) <= chunkSize
	end

	return v
end

function KeycapPoolRenderer:AddRecord(state)
	if not self._byId[state.Id] then
		self._byId[state.Id] = state
		local chunk = self._grid:GetChunk(state.Position, true)
		chunk:AddObject(state)
		state._chunk = chunk

		if self._renderingEnabled and self:_isChunkVisible(chunk) then
			self._desiredChunks[chunk] = true
			self._loadedChunks[chunk] = true
			table.insert(self._loadQueue, state)
			self._loadQueueDirty = true
		end
	end
end

function KeycapPoolRenderer:RemoveRecord(p: number)
	local v = self._byId[p]

	if v then
		self._byId[p] = nil
		local _chunk = v._chunk

		if _chunk then
			_chunk:RemoveObject(v)
		end

		v._chunk = nil
		local _unloadRecord = self:_unloadRecord(v)

		if _unloadRecord then
			KeycapPoolRenderer.ReturnedToPool:FireImmediate({ _unloadRecord })
		end
	end
end

function KeycapPoolRenderer:Clear()
	local _unloadRecords = {}

	for _, v in pairs(self._byId) do
		local _unloadRecord = self:_unloadRecord(v)

		if _unloadRecord then
			table.insert(_unloadRecords, _unloadRecord)
		end
	end

	if #_unloadRecords > 0 then
		KeycapPoolRenderer.ReturnedToPool:FireImmediate(_unloadRecords)
	end

	table.clear(self._byId)
	table.clear(self._loadQueue)
	self._loadQueueDirty = false
	table.clear(self._unloadQueue)
	table.clear(self._loadedByChar)
	table.clear(self._loadedChunks)
	table.clear(self._desiredChunks)
	self._currentChunk = nil
	self._camPos = nil
	self._avgLoadSec = 0
	self._avgUnloadSec = 0
	table.clear(self._loadTimeSamples)
	table.clear(self._unloadTimeSamples)
	self._grid = ChunkSystem.new(KeycapStreamConfig.ChunkDimensions, KeycapStreamConfig.ChunkSize)
end

function KeycapPoolRenderer:_unloadAllActive()
	table.clear(self._loadQueue)
	self._loadQueueDirty = false
	table.clear(self._unloadQueue)
	local _unloadRecords = {}

	for _, v in pairs(self._byId) do
		local _unloadRecord = self:_unloadRecord(v)

		if _unloadRecord then
			table.insert(_unloadRecords, _unloadRecord)
		end
	end

	if #_unloadRecords > 0 then
		KeycapPoolRenderer.ReturnedToPool:FireImmediate(_unloadRecords)
	end

	table.clear(self._loadedChunks)
	table.clear(self._desiredChunks)
	self._currentChunk = nil
end

function KeycapPoolRenderer:SetRenderingEnabled(renderingEnabled: boolean)
	if self._renderingEnabled ~= renderingEnabled then
		self._renderingEnabled = renderingEnabled

		if renderingEnabled then
			self._currentChunk = nil
		else
			self:_unloadAllActive()
		end
	end
end

function KeycapPoolRenderer:IsRenderingEnabled()
	return self._renderingEnabled
end

function KeycapPoolRenderer:_registerLoaded(state)
	if state._loadedIndex then
		return
	end

	local char = state.Char
	local states = self._loadedByChar[char]

	if not states then
		states = {}
		self._loadedByChar[char] = states
	end

	local loadedIndex = #states + 1
	states[loadedIndex] = state
	state._loadedIndex = loadedIndex
end

function KeycapPoolRenderer:_unregisterLoaded(state)
	local _loadedIndex = state._loadedIndex

	if not _loadedIndex then
		return
	end

	local v = self._loadedByChar[state.Char]
	local count = #v
	state._loadedIndex = nil

	if _loadedIndex ~= count then
		local v2 = v[count]
		v[_loadedIndex] = v2
		v2._loadedIndex = _loadedIndex
	end

	v[count] = nil
end

function KeycapPoolRenderer:_reclaimForChar(p: string)
	local _unloadQueue = self._unloadQueue

	for i = #_unloadQueue, 1, -1 do
		local v = _unloadQueue[i]
		local _chunk = v._chunk

		if _chunk and self._desiredChunks[_chunk] then
			table.remove(_unloadQueue, i)

			if not v._activeInstance then
				table.insert(self._loadQueue, v)
				self._loadQueueDirty = true
			end
		elseif v.Char == p then
			table.remove(_unloadQueue, i)
			local _unloadRecord = self:_unloadRecord(v)

			if _unloadRecord then
				KeycapPoolRenderer.ReturnedToPool:FireImmediate({ _unloadRecord })
				table.remove(self._pools[p])
				return _unloadRecord
			end
		end
	end

	return nil
end

function KeycapPoolRenderer:_stealFarthestLoaded(p: string, vector: Vector3)
	local v = self._loadedByChar[p]
	local v2 = not v and 0 or #v or 0

	if v2 == 0 then
		return nil
	end

	local _camPos = self._camPos

	if not _camPos then
		return nil
	end

	local X = _camPos.X
	local Y = _camPos.Y
	local Z = _camPos.Z
	local v3 = vector.X - X
	local v4 = vector.Y - Y
	local v5 = vector.Z - Z
	local v6 = v3 * v3 + v4 * v4 + v5 * v5
	local stealMaxCameraDistance = KeycapStreamConfig.StealMaxCameraDistance

	if stealMaxCameraDistance * stealMaxCameraDistance < v6 then
		return nil
	end

	local v7 = nil

	for i = 1, v2 do
		local v8 = v[i]

		if not v8._activeInstance then
			continue
		end

		local position = v8.Position
		local v9 = position.X - X
		local v10 = position.Y - Y
		local v11 = position.Z - Z
		local v12 = v9 * v9 + v10 * v10 + v11 * v11

		if not (v6 < v12) then
			continue
		end

		v7 = v8
		v6 = v12
	end

	if not v7 then
		return nil
	end

	local _activeInstance = v7._activeInstance
	v7._activeInstance = nil
	self:_unregisterLoaded(v7)
	local _chunk = v7._chunk

	if _chunk and self._desiredChunks[_chunk] then
		table.insert(self._loadQueue, v7)
		self._loadQueueDirty = true
	end

	KeycapPoolRenderer.ReturnedToPool:FireImmediate({ _activeInstance })
	return _activeInstance
end

function KeycapPoolRenderer:_takeFromPool(childName: string, vector: Vector3)
	local _pool = self._pools[childName]

	if not _pool then
		_pool = {}
		self._pools[childName] = _pool
	end

	local v = table.remove(_pool)

	if v then
		return v
	end

	local v2 = self._instanceCounts[childName] or 0

	if v2 < KeycapStreamConfig.MaxInstancesPerChar then
		local clone = self._template:Clone()
		clone:SetAttribute(KeycapStreamConfig.StreamedAttributeName, true)
		local child = self._surfaceAppearances:FindFirstChild(childName)

		if child then
			local clone_2 = child:Clone()
			clone_2.Parent = clone
		end

		self._instanceCounts[childName] = v2 + 1
		return clone
	else
		local _reclaimForChar = self:_reclaimForChar(childName)

		if _reclaimForChar then
			return _reclaimForChar
		end

		return self:_stealFarthestLoaded(childName, vector)
	end
end

function KeycapPoolRenderer:_loadRecord(state)
	if self._byId[state.Id] ~= state or state._activeInstance then
		return true
	end

	local _takeFromPool = self:_takeFromPool(state.Char, state.Position)

	if not _takeFromPool then
		return false
	end

	_takeFromPool.Color = state.Color
	_takeFromPool.Size = state.Size
	_takeFromPool.CFrame = state.Rotation + state.Position
	_takeFromPool:SetAttribute(KeycapStreamConfig.PositionAttributeName, state.Position)
	_takeFromPool:SetAttribute(KeycapStreamConfig.RotationAttributeName, state.Rotation)
	local musicType = state.MusicType

	if musicType == noneSentinel then
		musicType = nil
	end

	_takeFromPool:SetAttribute("MusicType", musicType)
	local keyType = state.KeyType

	if keyType == noneSentinel then
		keyType = nil
	end

	_takeFromPool:SetAttribute("Type", keyType)
	local surfaceAppearance = _takeFromPool:FindFirstChildWhichIsA("SurfaceAppearance")

	if surfaceAppearance then
		surfaceAppearance.Color = state.Color
	end

	_takeFromPool.Parent = self._folder
	state._activeInstance = _takeFromPool
	self:_registerLoaded(state)
	return true
end

function KeycapPoolRenderer:_unloadRecord(state)
	local _activeInstance = state._activeInstance

	if not _activeInstance then
		return nil
	end

	self:_unregisterLoaded(state)
	_activeInstance.Parent = nil
	_activeInstance:SetAttribute(KeycapStreamConfig.PositionAttributeName, nil)
	_activeInstance:SetAttribute(KeycapStreamConfig.RotationAttributeName, nil)
	_activeInstance:SetAttribute("MusicType", nil)
	_activeInstance:SetAttribute("Type", nil)
	table.insert(self._pools[state.Char], _activeInstance)
	state._activeInstance = nil
	return _activeInstance
end

function KeycapPoolRenderer:_computeDesiredChunks(vector: Vector3)
	local chunk = self._grid:GetChunk(vector, true)
	local chunkSize = KeycapStreamConfig.ChunkSize
	local position = chunk:GetPosition()
	local v = KeycapStreamConfig.ChunkDimensions == 3 and chunkSize or 0
	local v2 = v > 0 and chunkSize or 1
	local result = {}

	for i = -chunkSize, chunkSize, chunkSize do
		for i2 = -v, v, v2 do
			for i3 = -chunkSize, chunkSize, chunkSize do
				local chunk2 = self._grid:GetChunk(Vector3.new(position.X + i, position.Y + i2, position.Z + i3), false)

				if chunk2 then
					result[chunk2] = true
				end
			end
		end
	end

	return result, chunk
end

function KeycapPoolRenderer:_sortLoadQueueByCamera()
	local _camPos = self._camPos

	if _camPos and #self._loadQueue > 1 then
		local X = _camPos.X
		local Y = _camPos.Y
		local Z = _camPos.Z
		table.sort(self._loadQueue, function(a, b)
			local position = a.Position
			local position2 = b.Position
			return (position.X - X) * (position.X - X) + (position.Y - Y) * (position.Y - Y) + (position.Z - Z) * (position.Z - Z) < (position2.X - X) * (position2.X - X) + (position2.Y - Y) * (position2.Y - Y) + (position2.Z - Z) * (position2.Z - Z)
		end)
	end
end

function KeycapPoolRenderer:_onChunkChanged(desiredChunks)
	self._desiredChunks = desiredChunks
	local _camPos = self._camPos
	local X, Y, Z

	if _camPos then
		X = _camPos.X
		Y = _camPos.Y
		Z = _camPos.Z
	else
		X = 0
		Y = 0
		Z = 0
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function chunkDist2(object2)
		local position = object2:GetPosition()
		local v = position.X - X
		local v2 = position.Y - Y
		local v3 = position.Z - Z
		return v * v + v2 * v2 + v3 * v3
	end

	table.clear(self._loadQueue)

	for k, _ in pairs(desiredChunks) do
		self._loadedChunks[k] = true

		for _, v in ipairs(k:GetObjects()) do
			if not v._activeInstance then
				table.insert(self._loadQueue, v)
			end
		end
	end

	self:_sortLoadQueueByCamera()
	self._loadQueueDirty = false
	local v = {}

	for k, _ in pairs(self._loadedChunks) do
		if not desiredChunks[k] then
			table.insert(v, k)
		end
	end

	if _camPos and #v > 1 then
		table.sort(v, function(a, b)
			local v2 = chunkDist2(a) -- equivalent call inferred; original call site unknown
			return chunkDist2(b) < v2
		end)
	end

	for _, v2 in ipairs(v) do
		self._loadedChunks[v2] = nil

		for _, v3 in ipairs(v2:GetObjects()) do
			table.insert(self._unloadQueue, v3)
		end
	end
end

function KeycapPoolRenderer:_processQueues()
	local parentBatchSize = KeycapStreamConfig.ParentBatchSize
	local unloadFrameBudgetSec = KeycapStreamConfig.UnloadFrameBudgetSec
	local loadFrameBudgetSec = KeycapStreamConfig.LoadFrameBudgetSec
	local maxUnloadToLoadTransferSec = KeycapStreamConfig.MaxUnloadToLoadTransferSec
	local v = math.min(unloadFrameBudgetSec, maxUnloadToLoadTransferSec)

	if #self._unloadQueue > 0 then
		local now = os.clock()
		local v2 = now + unloadFrameBudgetSec
		local _unloadRecords = {}

		while true do
			for _ = 1, parentBatchSize do
				local v3 = table.remove(self._unloadQueue, 1)

				if not v3 then
					break
				end

				local _chunk = v3._chunk

				if not _chunk then
					continue
				end

				if self._desiredChunks[_chunk] then
					if not v3._activeInstance then
						table.insert(self._loadQueue, v3)
						self._loadQueueDirty = true
					end
				else
					local _unloadRecord = self:_unloadRecord(v3)

					if _unloadRecord then
						table.insert(_unloadRecords, _unloadRecord)
					end
				end
			end

			local now2 = os.clock()

			if not (#self._unloadQueue == 0 or v2 <= now2) then
				continue
			end

			if #_unloadRecords > 0 then
				KeycapPoolRenderer.ReturnedToPool:FireImmediate(_unloadRecords)
			end

			local v3 = now2 - now
			v = math.min(maxUnloadToLoadTransferSec, (math.max(0, unloadFrameBudgetSec - v3)))
			local _unloadTimeSamples = self._unloadTimeSamples
			table.insert(_unloadTimeSamples, v3)

			if #_unloadTimeSamples > 30 then
				table.remove(_unloadTimeSamples, 1)
			end

			local total = 0

			for i = 1, #_unloadTimeSamples do
				total += _unloadTimeSamples[i]
			end

			self._avgUnloadSec = total / #_unloadTimeSamples
			break
		end
	end

	if #self._loadQueue > 0 then
		local currentCamera = Workspace.CurrentCamera
		self._camPos = currentCamera and currentCamera.CFrame.Position or nil

		if self._loadQueueDirty then
			self:_sortLoadQueueByCamera()
			self._loadQueueDirty = false
		end

		local now = os.clock()
		local v2 = now + loadFrameBudgetSec + v
		local count = #self._loadQueue
		local v3 = {}

		while true do
			for _ = 1, parentBatchSize do
				if count <= 0 then
					break
				end

				local v4 = table.remove(self._loadQueue, 1)
				count -= 1
				local _chunk = v4 and v4._chunk

				if not (v4 and _chunk and self._desiredChunks[_chunk]) then
					continue
				end

				if v3[v4.Char] then
					table.insert(self._loadQueue, v4)
				elseif not self:_loadRecord(v4) then
					v3[v4.Char] = true
					table.insert(self._loadQueue, v4)
				end
			end

			local now2 = os.clock()

			if not (count <= 0 or v2 <= now2) then
				continue
			end

			local v4 = now2 - now
			local _loadTimeSamples = self._loadTimeSamples
			table.insert(_loadTimeSamples, v4)

			if #_loadTimeSamples > 30 then
				table.remove(_loadTimeSamples, 1)
			end

			local total = 0

			for i = 1, #_loadTimeSamples do
				total += _loadTimeSamples[i]
			end

			self._avgLoadSec = total / #_loadTimeSamples
			break
		end
	end
end

function KeycapPoolRenderer:Start()
	RunService.Heartbeat:Connect(function()
		if self._renderingEnabled then
			local currentCamera = Workspace.CurrentCamera

			if currentCamera then
				local position = currentCamera.CFrame.Position
				self._camPos = position
				local _computeDesiredChunks, currentChunk = self:_computeDesiredChunks(position)

				if currentChunk ~= self._currentChunk then
					self._currentChunk = currentChunk
					self:_onChunkChanged(_computeDesiredChunks)
				end
			end

			self:_processQueues()
		end
	end)
end

return KeycapPoolRenderer