local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterReplicationConfig = require(ReplicatedStorage.Modules.Shared.CharacterReplication.CharacterReplicationConfig)
local CharacterStateSerializer = require(ReplicatedStorage.Modules.Shared.CharacterReplication.CharacterStateSerializer)
local CharacterStateInterpolator = {}
CharacterStateInterpolator.__index = CharacterStateInterpolator
local TRANSFORM_COUNT = CharacterStateSerializer.TRANSFORM_COUNT

function CharacterStateInterpolator.new()
	return (setmetatable({
		_snapshots = {},
		_output = {
			userId = 0,
			sampleTime = 0,
			positions = table.create(TRANSFORM_COUNT, createVector(0, 0, 0)),
			rotations = table.create(TRANSFORM_COUNT * 4, 0),
			rootVelocity = createVector(0, 0, 0)
		},
		_scratch = table.create(4, 0),
		_stats = {
			pushed = 0,
			rejectedStale = 0,
			evicted = 0,
			sampleEmpty = 0,
			sampleWarmup = 0,
			sampleClamped = 0,
			sampleInterpolated = 0,
			buffered = 0,
			span = 0,
			newestSampleTime = 0
		},
		_stale = 0,
		_lastExtended = 0
	}, CharacterStateInterpolator))
end

function CharacterStateInterpolator:GetStats()
	local _snapshots = self._snapshots
	local count = #_snapshots
	local _stats = self._stats
	_stats.buffered = count
	_stats.span = not (count > 1) and 0 or _snapshots[count].sampleTime - _snapshots[1].sampleTime
	_stats.newestSampleTime = not (count > 0) and 0 or _snapshots[count].sampleTime
	return _stats
end

function CharacterStateInterpolator:ResetCounters()
	local _stats = self._stats
	_stats.pushed = 0
	_stats.rejectedStale = 0
	_stats.evicted = 0
	_stats.sampleEmpty = 0
	_stats.sampleWarmup = 0
	_stats.sampleClamped = 0
	_stats.sampleInterpolated = 0
end

function CharacterStateInterpolator:GetResyncTarget(p2: number, p3: number)
	local count = #self._snapshots

	if count < 2 then
		return nil
	end

	local v = self._snapshots[count].sampleTime - self._snapshots[1].sampleTime >= CharacterReplicationConfig.INTERPOLATION_DELAY + CharacterReplicationConfig.RESYNC_MIN_HISTORY

	if v and p2 < self._snapshots[1].sampleTime then
		return self._snapshots[count].sampleTime - CharacterReplicationConfig.INTERPOLATION_DELAY
	end

	local v2 = p3 - self._lastExtended < CharacterReplicationConfig.RESYNC_LIVE_WINDOW

	if v and v2 and self._snapshots[count].sampleTime <= p2 then
		return self._snapshots[count].sampleTime - CharacterReplicationConfig.INTERPOLATION_DELAY
	end

	return nil
end

function CharacterStateInterpolator:Push(p, lastExtended: number)
	local _snapshots = self._snapshots
	local _stats = self._stats
	local count = #_snapshots

	if count > 0 and (p.sampleTime <= _snapshots[1].sampleTime or p.sampleTime > _snapshots[count].sampleTime + CharacterReplicationConfig.RESYNC_MAX_LEAD) then
		if self._stale > CharacterReplicationConfig.RESYNC_STALE_FRAMES then
			table.clear(_snapshots)
			table.insert(_snapshots, p)
			self._stale = 0
			self._lastExtended = lastExtended
			return true
		else
			_stats.rejectedStale += 1
			self._stale += 1
			return false
		end
	else
		self._stale = 0
		local v = 1

		for i = count, 1, -1 do
			if not (_snapshots[i].sampleTime < p.sampleTime) then
				continue
			end

			v = i + 1
			break
		end

		if v == count + 1 then
			self._lastExtended = lastExtended
		end

		table.insert(_snapshots, v, p)
		_stats.pushed += 1

		if count + 1 > 80 then
			table.remove(_snapshots, 1)
			_stats.evicted += 1
		end

		return false
	end
end

local function hemisphereSign(p, p2: number, p3)
	if p[p2 + 1] * p3[p2 + 1] + p[p2 + 2] * p3[p2 + 2] + p[p2 + 3] * p3[p2 + 3] + p[p2 + 4] * p3[p2 + 4] < 0 then
		return -1
	end

	return 1
end

function CharacterStateInterpolator:Sample(sampleTime: number)
	local _snapshots = self._snapshots
	local _stats = self._stats
	local count = #_snapshots

	if count == 0 then
		_stats.sampleEmpty += 1
		return nil
	end

	if count == 1 or sampleTime <= _snapshots[1].sampleTime then
		_stats.sampleWarmup += 1
		return nil
	end

	if _snapshots[count].sampleTime <= sampleTime then
		_stats.sampleClamped += 1
		return _snapshots[count]
	end

	local v = 1

	for i = count - 1, 1, -1 do
		if not (_snapshots[i].sampleTime <= sampleTime) then
			continue
		end

		v = i
		break
	end

	local v2 = _snapshots[v - 1] or _snapshots[v]
	local _snapshot = _snapshots[v]
	local _snapshot2 = _snapshots[v + 1]
	local v3 = _snapshots[v + 2] or _snapshot2
	local v4 = _snapshot2.sampleTime - _snapshot.sampleTime

	if ((_snapshot2.positions[1] - _snapshot.positions[1]) / v4).Magnitude > 1000 then
		return _snapshot
	end

	local v5 = (sampleTime - _snapshot.sampleTime) / v4
	local v6 = v5 * v5
	local v7 = v6 * v5
	local v8 = 2 * v7 - 3 * v6 + 1
	local v9 = v7 - 2 * v6 + v5
	local v10 = -2 * v7 + 3 * v6
	local v11 = v7 - v6
	local v12 = v4 / (_snapshot2.sampleTime - v2.sampleTime)
	local v13 = v4 / (v3.sampleTime - _snapshot.sampleTime)
	local _output = self._output
	local _scratch = self._scratch
	local positions = _output.positions
	local rotations = _output.rotations
	local rotations2 = v2.rotations
	local rotations3 = _snapshot.rotations
	local rotations4 = _snapshot2.rotations
	local rotations5 = v3.rotations
	local positions2 = v2.positions
	local positions3 = _snapshot.positions
	local positions4 = _snapshot2.positions
	local positions5 = v3.positions

	for i = 1, TRANSFORM_COUNT do
		local position = positions3[i]
		local position2 = positions4[i]

		if i == 1 then
			positions[1] = v8 * position + v10 * position2 + v9 * v4 * _snapshot.rootVelocity + v11 * v4 * _snapshot2.rootVelocity
		else
			positions[i] = v8 * position + v10 * position2 + v9 * v12 * (position2 - positions2[i]) + v11 * v13 * (positions5[i] - position)
		end

		local v14 = (i - 1) * 4
		local v15 = rotations2[v14 + 1] * rotations3[v14 + 1] + rotations2[v14 + 2] * rotations3[v14 + 2] + rotations2[v14 + 3] * rotations3[v14 + 3] + rotations2[v14 + 4] * rotations3[v14 + 4] < 0 and -1 or 1
		local v16 = rotations4[v14 + 1] * rotations3[v14 + 1] + rotations4[v14 + 2] * rotations3[v14 + 2] + rotations4[v14 + 3] * rotations3[v14 + 3] + rotations4[v14 + 4] * rotations3[v14 + 4] < 0 and -1 or 1
		local v17 = rotations5[v14 + 1] * rotations3[v14 + 1] + rotations5[v14 + 2] * rotations3[v14 + 2] + rotations5[v14 + 3] * rotations3[v14 + 3] + rotations5[v14 + 4] * rotations3[v14 + 4] < 0 and -1 or 1
		local total = 0

		for i2 = 1, 4 do
			local v18 = v14 + i2
			local rotation = rotations3[v18]
			local v19 = v16 * rotations4[v18]
			local v20 = v8 * rotation + v10 * v19 + v9 * v12 * (v19 - v15 * rotations2[v18]) + v11 * v13 * (v17 * rotations5[v18] - rotation)
			_scratch[i2] = v20
			total += v20 * v20
		end

		local v18 = 1 / math.sqrt(total)
		rotations[v14 + 1] = _scratch[1] * v18
		rotations[v14 + 2] = _scratch[2] * v18
		rotations[v14 + 3] = _scratch[3] * v18
		rotations[v14 + 4] = _scratch[4] * v18
	end

	_output.userId = _snapshot.userId
	_output.sampleTime = sampleTime
	_output.rootVelocity = _snapshot.rootVelocity
	_stats.sampleInterpolated += 1
	return _output
end

return CharacterStateInterpolator