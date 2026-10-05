local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
require(script.Parent.ReactInternalTypes)
local Shared = require(parent.Shared)
local console = Shared.console
local ReactFiberSchedulerPrioritiesroblox = require(script.Parent["ReactFiberSchedulerPriorities.roblox"])
local SafeFlags = require(parent.SafeFlags)
local v = SafeFlags.createGetFFlag("ReactInlineMergeLanes")()
local Shared2 = require(parent.Shared)
local invariant = Shared2.invariant
local immediatePriority = ReactFiberSchedulerPrioritiesroblox.ImmediatePriority
local userBlockingPriority = ReactFiberSchedulerPrioritiesroblox.UserBlockingPriority
local normalPriority = ReactFiberSchedulerPrioritiesroblox.NormalPriority
local lowPriority = ReactFiberSchedulerPrioritiesroblox.LowPriority
local idlePriority = ReactFiberSchedulerPrioritiesroblox.IdlePriority
local noPriority = ReactFiberSchedulerPrioritiesroblox.NoPriority
local ReactFiberLane = {
	SyncLanePriority = 15,
	SyncBatchedLanePriority = 14,
	InputDiscreteLanePriority = 12,
	InputContinuousLanePriority = 10,
	DefaultLanePriority = 8,
	TransitionPriority = 6,
	NoLanePriority = 0,
	NoLanes = 0,
	NoLane = 0,
	SyncLane = 1,
	SyncBatchedLane = 2,
	InputDiscreteHydrationLane = 4,
	DefaultHydrationLane = 256,
	DefaultLanes = 3584,
	RetryLanes = 62914560,
	SomeRetryLane = 33554432,
	SelectiveHydrationLane = 67108864,
	IdleHydrationLane = 134217728,
	OffscreenLane = 1073741824,
	NoTimestamp = -1
}
local noLanePriority = ReactFiberLane.NoLanePriority

function ReactFiberLane.getCurrentUpdateLanePriority()
	return noLanePriority
end

function ReactFiberLane.setCurrentUpdateLanePriority(p)
	noLanePriority = p
end

local defaultLanePriority = ReactFiberLane.DefaultLanePriority

local function getHighestPriorityLanes(p)
	if bit32.band(1, p) ~= 0 then
		defaultLanePriority = 15
		return 1
	end

	if bit32.band(2, p) ~= 0 then
		defaultLanePriority = 14
		return 2
	end

	if bit32.band(4, p) ~= 0 then
		defaultLanePriority = 13
		return 4
	end

	local v2 = bit32.band(24, p)

	if v2 ~= 0 then
		defaultLanePriority = 12
		return v2
	end

	if bit32.band(p, 32) ~= 0 then
		defaultLanePriority = 11
		return 32
	end

	local v3 = bit32.band(192, p)

	if v3 ~= 0 then
		defaultLanePriority = 10
		return v3
	end

	if bit32.band(p, 256) ~= 0 then
		defaultLanePriority = 9
		return 256
	end

	local v4 = bit32.band(3584, p)

	if v4 ~= 0 then
		defaultLanePriority = 8
		return v4
	end

	if bit32.band(p, 4096) ~= 0 then
		defaultLanePriority = 7
		return 4096
	end

	local v5 = bit32.band(4186112, p)

	if v5 ~= 0 then
		defaultLanePriority = 6
		return v5
	end

	local v6 = bit32.band(62914560, p)

	if v6 ~= 0 then
		defaultLanePriority = 5
		return v6
	end

	if bit32.band(p, 67108864) ~= 0 then
		defaultLanePriority = 4
		return 67108864
	end

	if bit32.band(p, 134217728) ~= 0 then
		defaultLanePriority = 3
		return 134217728
	end

	local v7 = bit32.band(805306368, p)

	if v7 ~= 0 then
		defaultLanePriority = 2
		return v7
	end

	if bit32.band(1073741824, p) ~= 0 then
		defaultLanePriority = 1
		return 1073741824
	end

	if ReactGlobals.__DEV__ then
		console.error("Should have found matching lanes. This is a bug in React.")
	end

	defaultLanePriority = 8
	return p
end

function ReactFiberLane.schedulerPriorityToLanePriority(p)
	if p == immediatePriority then
		return 15
	end

	if p == userBlockingPriority then
		return 10
	end

	if p == normalPriority or p == lowPriority then
		return 8
	end

	if p == idlePriority then
		return 2
	end

	return 0
end

function ReactFiberLane.lanePriorityToSchedulerPriority(p)
	if p == 15 or p == 14 then
		return immediatePriority
	end

	if p == 13 or p == 12 or p == 11 or p == 10 then
		return userBlockingPriority
	end

	if p == 9 or p == 8 or p == 7 or p == 6 or p == 4 or p == 5 then
		return normalPriority
	end

	if p == 3 or p == 2 or p == 1 then
		return idlePriority
	end

	if p == 0 then
		return noPriority
	end

	invariant(false, "Invalid update priority: %s. This is a bug in React.", p)
	error("unreachable")
end

local pickArbitraryLaneIndex
local getLowestPriorityLane

function ReactFiberLane.getNextLanes(data, p)
	local pendingLanes = data.pendingLanes

	if pendingLanes == 0 then
		defaultLanePriority = 0
		return 0
	end

	local v2 = 0
	local v3 = 0
	local expiredLanes = data.expiredLanes
	local suspendedLanes = data.suspendedLanes
	local pingedLanes = data.pingedLanes

	if expiredLanes == 0 then
		local v4 = bit32.band(pendingLanes, 134217727)

		if v4 == 0 then
			local v5 = bit32.band(pendingLanes, (bit32.bnot(suspendedLanes)))

			if v5 == 0 then
				if pingedLanes ~= 0 then
					v2 = getHighestPriorityLanes(pingedLanes)
					v3 = defaultLanePriority
				end
			else
				v2 = getHighestPriorityLanes(v5)
				v3 = defaultLanePriority
			end
		else
			local v5 = bit32.band(v4, (bit32.bnot(suspendedLanes)))

			if v5 == 0 then
				local v6 = bit32.band(v4, pingedLanes)

				if v6 ~= 0 then
					v2 = getHighestPriorityLanes(v6)
					v3 = defaultLanePriority
				end
			else
				v2 = getHighestPriorityLanes(v5)
				v3 = defaultLanePriority
			end
		end
	else
		defaultLanePriority = 15
		v2 = expiredLanes
		v3 = 15
	end

	if v2 == 0 then
		return 0
	end

	local v4 = bit32.band(pendingLanes, bit32.lshift(getLowestPriorityLane(v2), 1) - 1)

	if p ~= 0 and p ~= v4 and bit32.band(p, suspendedLanes) == 0 then
		getHighestPriorityLanes(p)

		if v3 <= defaultLanePriority then
			return p
		else
			defaultLanePriority = v3
		end
	end

	local entangledLanes = data.entangledLanes

	if entangledLanes == 0 then
		return v4
	end

	local entanglements = data.entanglements
	local v5 = bit32.band(v4, entangledLanes)

	while v5 > 0 do
		local v6 = pickArbitraryLaneIndex(v5)
		local v7 = bit32.lshift(1, v6)
		v4 = bit32.bor(v4, entanglements[v6])
		v5 = bit32.band(v5, (bit32.bnot(v7)))
	end

	return v4
end

function ReactFiberLane.getMostRecentEventTime(p, p2)
	local eventTimes = p.eventTimes
	local v2 = -1

	while p2 > 0 do
		local v3 = pickArbitraryLaneIndex(p2)
		local v4 = bit32.lshift(1, v3)
		local eventTime = eventTimes[v3]

		if v2 < eventTime then
			v2 = eventTime
		end

		p2 = bit32.band(p2, (bit32.bnot(v4)))
	end

	return v2
end

function ReactFiberLane.computeExpirationTime(p, p2: number)
	getHighestPriorityLanes(p)
	local v2 = defaultLanePriority

	if v2 >= 10 then
		return p2 + 250
	end

	if v2 >= 6 then
		return p2 + 5000
	end

	return -1
end

function ReactFiberLane:markStarvedLanesAsExpired(p: number)
	local pendingLanes = self.pendingLanes
	local suspendedLanes = self.suspendedLanes
	local pingedLanes = self.pingedLanes
	local expirationTimes = self.expirationTimes

	while pendingLanes > 0 do
		local v2 = pickArbitraryLaneIndex(pendingLanes)
		local v3 = bit32.lshift(1, v2)
		local expirationTime = expirationTimes[v2]

		if expirationTime == -1 then
			if bit32.band(v3, suspendedLanes) == 0 or bit32.band(v3, pingedLanes) ~= 0 then
				getHighestPriorityLanes(v3)
				local v4 = defaultLanePriority
				local v5

				if v4 >= 10 then
					v5 = p + 250
				else
					v5 = not (v4 >= 6) and -1 or p + 5000
				end

				expirationTimes[v2] = v5
			end
		elseif expirationTime <= p then
			self.expiredLanes = bit32.bor(self.expiredLanes, v3)
		end

		pendingLanes = bit32.band(pendingLanes, (bit32.bnot(v3)))
	end
end

function ReactFiberLane.getHighestPriorityPendingLanes(p)
	return (getHighestPriorityLanes(p.pendingLanes))
end

function ReactFiberLane.getLanesToRetrySynchronouslyOnError(p)
	local v2 = bit32.band(p.pendingLanes, 3221225471)

	if v2 ~= 0 then
		return v2
	end

	if bit32.band(v2, 1073741824) == 0 then
		return 0
	end

	return 1073741824
end

function ReactFiberLane.returnNextLanesPriority()
	return defaultLanePriority
end

function ReactFiberLane.includesNonIdleWork(p)
	return bit32.band(p, 134217727) ~= 0
end

function ReactFiberLane.includesOnlyRetries(p)
	return bit32.band(p, 62914560) == p
end

function ReactFiberLane.includesOnlyTransitions(p)
	return bit32.band(p, 4186112) == p
end

local pickArbitraryLane
local findUpdateLane

findUpdateLane = function(p, p2)
	if p ~= 0 then
		if p == 15 then
			return 1
		elseif p == 14 then
			return 2
		end

		if p == 12 then
			local v2 = pickArbitraryLane((bit32.band(24, (bit32.bnot(p2)))))

			if v2 == 0 then
				return findUpdateLane(10, p2)
			end

			return v2
		elseif p == 10 then
			local v2 = pickArbitraryLane((bit32.band(192, (bit32.bnot(p2)))))

			if v2 == 0 then
				return findUpdateLane(8, p2)
			end

			return v2
		elseif p == 8 then
			local v2 = pickArbitraryLane((bit32.band(3584, (bit32.bnot(p2)))))

			if v2 == 0 then
				v2 = pickArbitraryLane((bit32.band(4186112, (bit32.bnot(p2)))))

				if v2 == 0 then
					return (pickArbitraryLane(3584))
				end
			end

			return v2
		elseif p ~= 6 and p ~= 5 and p == 2 then
			local v2 = pickArbitraryLane((bit32.band(805306368, (bit32.bnot(p2)))))

			if v2 == 0 then
				return (pickArbitraryLane(805306368))
			end

			return v2
		end
	end

	invariant(false, "Invalid update priority: %s. This is a bug in React.", p)
	error("unreachable")
end

ReactFiberLane.findUpdateLane = findUpdateLane

function ReactFiberLane.findTransitionLane(p, p2)
	local v2 = pickArbitraryLane((bit32.band(4186112, (bit32.bnot(p2)))))

	if v2 == 0 then
		v2 = pickArbitraryLane((bit32.band(4186112, (bit32.bnot(p)))))

		if v2 == 0 then
			return (pickArbitraryLane(4186112))
		end
	end

	return v2
end

function ReactFiberLane.findRetryLane(p)
	local v2 = pickArbitraryLane((bit32.band(62914560, (bit32.bnot(p)))))

	if v2 == 0 then
		return (pickArbitraryLane(62914560))
	end

	return v2
end

local function getHighestPriorityLane(p)
	return (bit32.band(p, -p))
end

getLowestPriorityLane = function(p)
	local v2 = 31 - bit32.countlz(p)

	if v2 < 0 then
		return 0
	end

	return (bit32.lshift(1, v2))
end

local function getEqualOrHigherPriorityLanes(p)
	return bit32.lshift(getLowestPriorityLane(p), 1) - 1
end

pickArbitraryLane = function(p)
	return (bit32.band(p, -p))
end

ReactFiberLane.pickArbitraryLane = pickArbitraryLane

pickArbitraryLaneIndex = function(p)
	return 31 - bit32.countlz(p)
end

function ReactFiberLane.includesSomeLane(p, p2)
	return bit32.band(p, p2) ~= 0
end

function ReactFiberLane.isSubsetOfLanes(p, p2)
	return bit32.band(p, p2) == p2
end

local function mergeLanes(p, p2)
	return (bit32.bor(p, p2))
end

if v then
	mergeLanes = bit32.bor
end

ReactFiberLane.mergeLanes = mergeLanes

function ReactFiberLane.removeLanes(p, p2)
	return (bit32.band(p, (bit32.bnot(p2))))
end

function ReactFiberLane.laneToLanes(p)
	return p
end

function ReactFiberLane.higherPriorityLane(p, p2)
	if p == 0 or p2 == 0 then
		if p == 0 then
			return p2
		end

		return p
	elseif p < p2 then
		return p
	else
		return p2
	end
end

function ReactFiberLane.higherLanePriority(p, p2)
	if p == 0 or not (p2 < p) then
		return p2
	end

	return p
end

function ReactFiberLane.createLaneMap(p)
	return {
		[0] = p,
		[1] = p,
		[2] = p,
		[3] = p,
		[4] = p,
		[5] = p,
		[6] = p,
		[7] = p,
		[8] = p,
		[9] = p,
		[10] = p,
		[11] = p,
		[12] = p,
		[13] = p,
		[14] = p,
		[15] = p,
		[16] = p,
		[17] = p,
		[18] = p,
		[19] = p,
		[20] = p,
		[21] = p,
		[22] = p,
		[23] = p,
		[24] = p,
		[25] = p,
		[26] = p,
		[27] = p,
		[28] = p,
		[29] = p,
		[30] = p,
		[31] = p
	}
end

function ReactFiberLane:markRootUpdated(p, p2: number)
	self.pendingLanes = bit32.bor(self.pendingLanes, p)
	local v2 = p - 1
	self.suspendedLanes = bit32.band(self.suspendedLanes, v2)
	self.pingedLanes = bit32.band(self.pingedLanes, v2)
	self.eventTimes[31 - bit32.countlz(p)] = p2
end

function ReactFiberLane:markRootSuspended(p)
	self.suspendedLanes = bit32.bor(self.suspendedLanes, p)
	self.pingedLanes = bit32.band(self.pingedLanes, (bit32.bnot(p)))
	local expirationTimes = self.expirationTimes

	while p > 0 do
		local v2 = pickArbitraryLaneIndex(p)
		local v3 = bit32.lshift(1, v2)
		expirationTimes[v2] = -1
		p = bit32.band(p, (bit32.bnot(v3)))
	end
end

function ReactFiberLane:markRootPinged(p, _: number)
	self.pingedLanes = bit32.bor(self.pingedLanes, (bit32.band(self.suspendedLanes, p)))
end

function ReactFiberLane:markRootExpired(p)
	self.expiredLanes = bit32.bor(self.expiredLanes, (bit32.band(p, self.pendingLanes)))
end

function ReactFiberLane:markDiscreteUpdatesExpired()
	self.expiredLanes = bit32.bor(self.expiredLanes, (bit32.band(24, self.pendingLanes)))
end

function ReactFiberLane.hasDiscreteLanes(p)
	return bit32.band(p, 24) ~= 0
end

function ReactFiberLane:markRootMutableRead(p)
	self.mutableReadLanes = bit32.bor(self.mutableReadLanes, (bit32.band(p, self.pendingLanes)))
end

function ReactFiberLane:markRootFinished(pendingLanes)
	local v2 = bit32.band(self.pendingLanes, (bit32.bnot(pendingLanes)))
	self.pendingLanes = pendingLanes
	self.suspendedLanes = 0
	self.pingedLanes = 0
	self.expiredLanes = bit32.band(self.expiredLanes, pendingLanes)
	self.mutableReadLanes = bit32.band(self.mutableReadLanes, pendingLanes)
	self.entangledLanes = bit32.band(self.entangledLanes, pendingLanes)
	local entanglements = self.entanglements
	local eventTimes = self.eventTimes
	local expirationTimes = self.expirationTimes

	while v2 > 0 do
		local v3 = pickArbitraryLaneIndex(v2)
		local v4 = bit32.lshift(1, v3)
		entanglements[v3] = 0
		eventTimes[v3] = -1
		expirationTimes[v3] = -1
		v2 = bit32.band(v2, (bit32.bnot(v4)))
	end
end

function ReactFiberLane:markRootEntangled(p)
	self.entangledLanes = bit32.bor(self.entangledLanes, p)
	local entanglements = self.entanglements
	local v2 = p

	while v2 > 0 do
		local v3 = pickArbitraryLaneIndex(v2)
		local v4 = bit32.lshift(1, v3)
		entanglements[v3] = bit32.bor(entanglements[v3], p)
		v2 = bit32.band(v2, (bit32.bnot(v4)))
	end
end

function ReactFiberLane.getBumpedLaneForHydration(p, p2)
	getHighestPriorityLanes(p2)
	local v2 = defaultLanePriority
	local v3 = nil

	if v2 == 15 or v2 == 14 then
		v3 = 0
	elseif v2 == 13 or v2 == 12 then
		v3 = 4
	elseif v2 == 11 or v2 == 10 then
		v3 = 32
	elseif v2 == 9 or v2 == 8 then
		v3 = 256
	elseif v2 == 7 or v2 == 6 or v2 == 5 then
		v3 = 4096
	elseif v2 == 4 then
		v3 = 67108864
	elseif v2 == 3 or v2 == 2 then
		v3 = 134217728
	elseif v2 == 1 or v2 == 0 then
		v3 = 0
	else
		invariant(false, "Invalid lane: %s. This is a bug in React.", (tostring(v3)))
	end

	if bit32.band(v3, (bit32.bor(p.suspendedLanes, p2))) == 0 then
		return v3
	end

	return 0
end

return ReactFiberLane