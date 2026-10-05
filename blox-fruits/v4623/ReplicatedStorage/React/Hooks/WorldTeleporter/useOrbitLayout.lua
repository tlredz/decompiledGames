local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
local TRANSITION = CONSTANTS.TRANSITION
local RINGS = CONSTANTS.RINGS
local RING_ORDER = CONSTANTS.RING_ORDER
local uDim = UDim2.fromScale(0, 0)
local v = {
	getMode = function(p: number)
		if CONSTANTS.MID_RING_LIMIT < p then
			return "Double"
		end

		return "Solo"
	end,
	getRingConfig = function(p, p2)
		return RINGS[p][p2]
	end,
	getRingId = function(p, p2: number, p3: number)
		local v2

		if p2 <= p3 * CONSTANTS.INNER_RING_RATIO then
			v2 = p2 <= CONSTANTS.MID_RING_LIMIT
		else
			v2 = false
		end

		if p == "Double" and v2 then
			return "Inner"
		end

		return "Outer"
	end,
	getPhase = function(p, p2: number)
		return p.Direction * 6.283185307179586 * p2 / p.Period
	end,
	getAlpha = function(p: number, p2: number)
		local v2 = math.clamp((p2 - p) / TRANSITION.DURATION, 0, 1)
		return TweenService:GetValue(v2, TRANSITION.EASING_STYLE, TRANSITION.EASING_DIRECTION), v2
	end,
	getConfigKey = function(list, p, flag: boolean)
		local v2 = table.create(#list + 2)

		for k, v3 in list do
			v2[k] = v3.Index.Key
		end

		table.insert(v2, not p and ">" or `>{p.Index.Key}`)
		table.insert(v2, flag and "+" or "-")
		return table.concat(v2, "|")
	end,
	buildIslandTarget = function(island, ring, slotAngle: number, isCentered: boolean, flag: boolean)
		local islandSize = ring.IslandSize
		local max

		if isCentered then
			max = 0
		elseif flag then
			max = ring.Radius.Max
		else
			max = ring.Radius.Min
		end

		local max2

		if isCentered then
			max2 = islandSize.Max
		elseif flag then
			max2 = islandSize.Min
		else
			max2 = islandSize.Default
		end

		return {
			Island = island,
			Ring = ring,
			SlotAngle = slotAngle,
			Radius = max,
			Size = max2,
			Presence = 1,
			IsCentered = isCentered
		}
	end,
	getLeaveTarget = function(p)
		local clone = table.clone(p)
		clone.Presence = 0
		clone.Size = uDim
		return clone
	end,
	getIfSameIslandTarget = function(data, data2)
		return data.Ring == data2.Ring and data.SlotAngle == data2.SlotAngle and data.Radius == data2.Radius and data.Size == data2.Size and data.Presence == data2.Presence and data.IsCentered == data2.IsCentered
	end
}

function v.solveIslandTargets(data, p, p2)
	local result = {}
	local centered = data.Centered
	local key

	if centered then
		key = centered.Index.Key
	end

	local isExpanded = data.IsExpanded
	local count = #data.Orbit
	local ringIds = table.create(count)
	local v2 = {
		Inner = 0,
		Outer = 0
	}
	local v3 = {
		Inner = 0,
		Outer = 0
	}
	local v4 = nil

	for k, v5 in data.Orbit do
		local ringId = v.getRingId(p, k, count)
		ringIds[k] = ringId

		if v5.Index.Key == key then
			v4 = ringId
		else
			v2[ringId] += 1
		end
	end

	for k, v5 in data.Orbit do
		if v5.Index.Key == key then
			continue
		end

		local v6 = ringIds[k]
		local ringConfig = v.getRingConfig(p, v6)
		assert(ringConfig, (`missing {v6} ring config for {p} mode`))
		v3[v6] += 1
		local v7 = 6.283185307179586 * v3[v6] / v2[v6]
		result[v5.Index.Key] = v.buildIslandTarget(v5, ringConfig, v7, false, isExpanded)
	end

	if not (centered and v4) then
		return result
	end

	local v5 = p2[centered.Index.Key]
	local v6

	if v5 then
		v6 = v.getRingConfig(p, v5.Target.Ring.Id)
	end

	local v7 = v6 or v.getRingConfig(p, v4)
	assert(v7, (`missing {v4} ring config for {p} mode`))
	local v8 = not v5 and 0 or v5.Target.SlotAngle
	result[centered.Index.Key] = v.buildIslandTarget(centered, v7, v8, true, true)
	return result
end

function v.evaluateIsland(data, p: number)
	local alpha, v2 = v.getAlpha(data.StartedAt, p)
	local target = data.Target
	local v3 = target.SlotAngle + v.getPhase(target.Ring, p) + data.AngleOffset
	return
		data.FromAngle + (v3 - data.FromAngle) * alpha,
		data.FromRadius + (target.Radius - data.FromRadius) * alpha,
		data.FromSize:Lerp(target.Size, alpha),
		data.FromPresence + (target.Presence - data.FromPresence) * alpha,
		v2
end

function v.newIslandTrack(p: string, target, startedAt: number)
	return {
		Key = p,
		Target = target,
		AngleOffset = 0,
		FromAngle = target.SlotAngle + v.getPhase(target.Ring, startedAt),
		FromRadius = 0,
		FromSize = uDim,
		FromPresence = 0,
		StartedAt = startedAt
	}
end

function v:retargetIsland(target, startedAt: number)
	local island, fromRadius, fromSize, fromPresence = v.evaluateIsland(self, startedAt)
	local v5 = target.SlotAngle + v.getPhase(target.Ring, startedAt)
	local v6 = v5 - island
	local v7 = v6 - 6.283185307179586 * math.round(v6 / 6.283185307179586)
	self.Target = target
	self.AngleOffset = island + v7 - v5
	self.FromAngle = island
	self.FromRadius = fromRadius
	self.FromSize = fromSize
	self.FromPresence = fromPresence
	self.StartedAt = startedAt
end

function v.solveRingTargets(p, flag: boolean, p2)
	local result = {}

	for _, v2 in RING_ORDER do
		local ringConfig = v.getRingConfig(p, v2)
		local v3 = p2[v2]

		if ringConfig then
			local diameter

			if flag then
				diameter = ringConfig.Diameter.Max
			else
				diameter = ringConfig.Diameter.Min
			end

			result[v2] = {
				Config = ringConfig,
				Diameter = diameter,
				Presence = 1
			}
		elseif v3 then
			result[v2] = {
				Config = v3.Target.Config,
				Diameter = v3.Target.Diameter,
				Presence = 0
			}
		end
	end

	return result
end

function v.evaluateRing(data, p: number)
	local alpha, v2 = v.getAlpha(data.StartedAt, p)
	return
		data.FromDiameter + (data.Target.Diameter - data.FromDiameter) * alpha,
		data.FromPresence + (data.Target.Presence - data.FromPresence) * alpha,
		v2
end

function v.getIfSameRingTarget(data, data2)
	return data.Config == data2.Config and data.Diameter == data2.Diameter and data.Presence == data2.Presence
end

function v:reconcile(config)
	local mode = v.getMode(#config.Orbit)
	local solveIslandTargets = v.solveIslandTargets(config, mode, self.Islands)

	for k, solveIslandTarget in solveIslandTargets do
		local island = self.Islands[k]

		if island then
			if v.getIfSameIslandTarget(island.Target, solveIslandTarget) then
				island.Target = solveIslandTarget
			else
				v.retargetIsland(island, solveIslandTarget, self.Elapsed)
			end
		else
			self.Islands[k] = v.newIslandTrack(k, solveIslandTarget, self.Elapsed)
		end
	end

	for k, island in self.Islands do
		if solveIslandTargets[k] or not (island.Target.Presence > 0) then
			continue
		end

		v.retargetIsland(island, v.getLeaveTarget(island.Target), self.Elapsed)
	end

	local solveRingTargets = v.solveRingTargets(mode, config.IsExpanded, self.Rings)

	for k, solveRingTarget in solveRingTargets do
		local ring = self.Rings[k]

		if ring then
			if not v.getIfSameRingTarget(ring.Target, solveRingTarget) then
				local ring2, fromPresence = v.evaluateRing(ring, self.Elapsed)
				ring.Target = solveRingTarget
				ring.FromDiameter = ring2
				ring.FromPresence = fromPresence
				ring.StartedAt = self.Elapsed
			end
		else
			self.Rings[k] = {
				Target = solveRingTarget,
				FromDiameter = 0,
				FromPresence = 0,
				StartedAt = self.Elapsed
			}
		end
	end

	self.Mode = mode
	self.Config = config
end

function v.snap(data)
	local startedAt = data.Elapsed - TRANSITION.DURATION

	for _, island in data.Islands do
		island.StartedAt = startedAt
	end

	for _, ring in data.Rings do
		ring.StartedAt = startedAt
	end
end

function v.buildLayout(data)
	local v2 = {}
	local values = {}

	for k, island in data.Islands do
		local island2, radius, size, presence, v6 = v.evaluateIsland(island, data.Elapsed)

		if v6 >= 1 and island.Target.Presence <= 0 then
			table.insert(v2, k)
		else
			table.insert(values, (table.freeze({
				Key = k,
				Island = island.Target.Island,
				RingId = island.Target.Ring.Id,
				Angle = island2,
				Radius = radius,
				Size = size,
				Presence = presence,
				IsCentered = island.Target.IsCentered
			})))
		end
	end

	for _, v3 in v2 do
		data.Islands[v3] = nil
	end

	table.sort(values, function(a, b)
		return a.Key < b.Key
	end)
	local values2 = {}

	for _, id in RING_ORDER do
		local ring = data.Rings[id]

		if not ring then
			continue
		end

		local ring2, presence, v5 = v.evaluateRing(ring, data.Elapsed)

		if v5 >= 1 and ring.Target.Presence <= 0 then
			data.Rings[id] = nil
		else
			table.insert(values2, (table.freeze({
				Id = id,
				Diameter = ring2,
				Presence = presence,
				BorderOffset = ring.Target.Config.BorderOffset
			})))
		end
	end

	return (table.freeze({
		Mode = data.Mode,
		Islands = table.freeze(values),
		Rings = table.freeze(values2)
	}))
end

return function(orbit, centered, flag: boolean?)
	local v2 = useDrawContext() ~= "Offscreen"
	local isExpanded = flag == true or centered ~= nil
	local v4 = { (v.getConfigKey(orbit, centered, isExpanded)) }
	local v5 = React.useMemo(function()
		return (table.freeze({
			Orbit = orbit,
			Centered = centered,
			IsExpanded = isExpanded
		}))
	end, v4)
	local ref = React.useRef(nil)
	local state, setState = React.useState(function()
		local current = {
			Elapsed = 0,
			Config = nil,
			Mode = "Solo",
			Islands = {},
			Rings = {}
		}
		v.reconcile(current, v5)
		v.snap(current)
		ref.current = current
		return v.buildLayout(current)
	end)
	React.useEffect(function()
		local current = ref.current
		assert(current, "missing orbit simulation")

		if current.Config ~= v5 then
			v.reconcile(current, v5)

			if not v2 then
				v.snap(current)
			end

			setState(v.buildLayout(current))
		end

		if not v2 then
			return function() end
		end

		local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			current.Elapsed += dt
			setState(v.buildLayout(current))
		end)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end, { v5, v2 })
	return state
end