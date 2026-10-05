local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local shared = script.Parent.Parent.Shared
local Holder = require(shared.Holder)
require(shared.Types)
local Entity = require(shared.Entity)
local ClockUnwrap = require(shared.ClockUnwrap)
local replicate = shared.Remotes.Replicate
local safeReplicate = shared.Remotes.SafeReplicate
local _clientOwned = Holder._clientOwned

if not _clientOwned[localPlayer] then
	_clientOwned[localPlayer] = {}
end

local v = _clientOwned[localPlayer]
local buf = buffer.create(950)
local v2 = 0
local now = 0
local v3 = false

local function MapRotation(p: number)
	return (math.round((p + 3.141592653589793) / 0.00009587526218325454))
end

local function FireEvent(state, p: string, ...)
	local _events = state._events

	if not _events then
		return
	end

	local _event = _events[p]

	if _event then
		_event:Fire(state, ...)
	end
end

local function SerializeFull(buf2: buffer, cframe: CFrame, offset: number)
	local X = cframe.X
	local Y = cframe.Y
	local Z = cframe.Z
	local orientation, v4, v5 = cframe:ToOrientation()
	buffer.writef32(buf2, offset, X)
	local v6 = offset + 4
	buffer.writef32(buf2, v6, Y)
	local v7 = v6 + 4
	buffer.writef32(buf2, v7, Z)
	local v8 = v7 + 4
	buffer.writeu16(buf2, v8, (math.round((orientation + 3.141592653589793) / 0.00009587526218325454)))
	local v9 = v8 + 2
	buffer.writeu16(buf2, v9, (math.round((v4 + 3.141592653589793) / 0.00009587526218325454)))
	local v10 = v9 + 2
	buffer.writeu16(buf2, v10, (math.round((v5 + 3.141592653589793) / 0.00009587526218325454)))
	return v10 + 2
end

local function SerializeYaw(buf2: buffer, cframe: CFrame, offset: number)
	local X = cframe.X
	local Y = cframe.Y
	local Z = cframe.Z
	local _, v4, _ = cframe:ToOrientation()
	buffer.writef32(buf2, offset, X)
	local v5 = offset + 4
	buffer.writef32(buf2, v5, Y)
	local v6 = v5 + 4
	buffer.writef32(buf2, v6, Z)
	local v7 = v6 + 4
	buffer.writeu16(buf2, v7, (math.round((v4 + 3.141592653589793) / 0.00009587526218325454)))
	return v7 + 2
end

local function Flush()
	if v2 == 0 then
		return
	end

	local buf2 = buffer.create(v2 + 4)
	buffer.writeu32(buf2, 0, (ClockUnwrap.quantize(now)))
	buffer.copy(buf2, 4, buf, 0, v2)

	if v3 then
		safeReplicate:FireServer(buf2)
	else
		replicate:FireServer(buf2)
	end

	v2 = 0
end

local function WriteEntity(id: number, latestCFrame: CFrame, FULL_ROTATION: boolean?, isHalfTicked: boolean?, _teleport: boolean?)
	if v2 + (FULL_ROTATION and 21 or 17) > 900 then
		Flush()
	end

	buffer.writeu16(buf, v2, id)
	v2 += 2
	local v4 = FULL_ROTATION and 1 or 0

	if isHalfTicked then
		v4 += 2
	end

	if _teleport then
		v4 += 4
	end

	buffer.writeu8(buf, v2, v4)
	v2 += 1

	if FULL_ROTATION then
		v2 = SerializeFull(buf, latestCFrame, v2)
		return
	end

	local v5 = buf
	local v6 = v2
	local X = latestCFrame.X
	local Y = latestCFrame.Y
	local Z = latestCFrame.Z
	local _, v7, _ = latestCFrame:ToOrientation()
	buffer.writef32(v5, v6, X)
	local v8 = v6 + 4
	buffer.writef32(v5, v8, Y)
	local v9 = v8 + 4
	buffer.writef32(v5, v9, Z)
	local v10 = v9 + 4
	buffer.writeu16(v5, v10, (math.round((v7 + 3.141592653589793) / 0.00009587526218325454)))
	v2 = v10 + 2
end

local function CFrameChanged(vector: CFrame?, cframe: CFrame?)
	return vector ~= cframe and (vector == nil or cframe == nil or vector:FuzzyEq(cframe, 0.0001) == false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckLocker(state)
	if state._cfLockFailed then
		if state._lockedCFReplication and state.isContextOwner and not state._player then
			local _GetPart = Entity._GetPart(state)

			if _GetPart then
				Entity._LockPartPhysicsReplication(_GetPart)
				state._cfLockFailed = nil
			end
		else
			state._cfLockFailed = nil
		end
	end
end

local function CheckEntity(state)
	if state.destroyed or state.paused then
		return
	end

	local entityConfig = state.entityConfig
	local TICK_RATE = entityConfig.TICK_RATE

	if state.isHalfTicked then
		TICK_RATE *= 2
	elseif state.isHalfTicked == nil then
		return
	end

	local lastReplicatedTime = now
	local v5 = lastReplicatedTime - (state.lastReplicatedTime or 0)

	if v5 < TICK_RATE then
		return
	end

	CheckLocker(state) -- equivalent call inferred; original call site unknown
	FireEvent(state, "Ticked", v5)
	local primaryPart = Entity.GetPrimaryPart(state)

	if state.autoUpdatePosition and primaryPart then
		Entity.Push(state, lastReplicatedTime, primaryPart.CFrame)
	end

	local latestCFrame = state.latestCFrame
	local lastCheckedCFrame = state.lastCheckedCFrame

	if latestCFrame then
		local v6

		if lastCheckedCFrame == latestCFrame then
			v6 = false
		else
			v6 = lastCheckedCFrame == nil or latestCFrame == nil or lastCheckedCFrame:FuzzyEq(latestCFrame, 0.0001) == false
		end

		if v6 then
			state.lastReplicatedTime = lastReplicatedTime
			local FULL_ROTATION = entityConfig.FULL_ROTATION
			state.lastCheckedCFrame = latestCFrame
			v3 = v3 or state._teleport
			WriteEntity(state.id, latestCFrame, FULL_ROTATION, state.isHalfTicked, state._teleport)
			state._teleport = nil
		end
	end
end

return {
	Update = function()
		now = os.clock()

		for k in v do
			CheckEntity(k)
		end

		Flush()
		v3 = false
	end
}