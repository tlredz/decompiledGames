local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)

local function collectParts(part)
	if part:IsA("BasePart") then
		return { part }
	end

	local parts = {}

	for _, part2 in part:GetDescendants() do
		if part2:IsA("BasePart") then
			table.insert(parts, part2)
		end
	end

	return parts
end

local function getUnitCenterAndRadius(list)
	local v = createVector(0, 0, 0)

	for _, v2 in list do
		v += v2.Position
	end

	local v2 = v / #list
	local v3 = 0

	for _, v4 in list do
		local v5 = (v4.Position - v2).Magnitude + v4.Size.Magnitude * 0.5

		if v3 < v5 then
			v3 = v5
		end
	end

	return v2, v3
end

local function captureState(items, p)
	for _, item in items do
		p[item] = {
			transparency = item.Transparency,
			canCollide = item.CanCollide,
			cframe = item.CFrame
		}
	end
end

local function applyHidden(items)
	for _, item in items do
		item.Transparency = 1
		item.CanCollide = false
	end
end

local function applyAuthored(items, p)
	for _, item in items do
		local v = p[item]
		item.Transparency = v.transparency
		item.CanCollide = v.canCollide

		if item.Anchored then
			item.CFrame = v.cframe
		end
	end
end

local function orderPartsAlongSpan(p)
	local clone = table.clone(p)

	if #clone <= 2 then
		return clone
	end

	local v = clone[1]
	local v2 = clone[2]
	local v3 = -1

	for i = 1, #clone do
		for i2 = i + 1, #clone do
			local magnitude = (clone[i].Position - clone[i2].Position).Magnitude

			if not (v3 < magnitude) then
				continue
			end

			v = clone[i]
			v2 = clone[i2]
			v3 = magnitude
		end
	end

	local v4 = v2.Position - v.Position

	if v4.Magnitude < 0.001 then
		return clone
	end

	local unit = v4.Unit
	local position = v.Position
	table.sort(clone, function(a, b)
		return (a.Position - position):Dot(unit) < (b.Position - position):Dot(unit)
	end)
	return clone
end

local function computeEndRingPositions(list, bridgeRepair)
	local v = list[1]
	local v2 = list[#list]
	local v3 = v2.Position - v.Position
	local vector2 = Vector3.new(v3.X, 0, v3.Z)
	local v4 = not (vector2.Magnitude > 0.001) and createVector(1, 0, 0) or vector2.Unit
	local vector3 = Vector3.new(0, bridgeRepair.ringLiftStuds, 0)
	return {
		v.Position - v4 * bridgeRepair.endOffsetStuds + vector3,
		v2.Position + v4 * bridgeRepair.endOffsetStuds + vector3
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isUnitTargetable(p)
	return not p.broken and os.clock() >= p.graceUntilClock
end

local function countBroken(items)
	local count = 0

	for _, item in items do
		if item.broken then
			count += 1
		end
	end

	return count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function revealPart(orderedBuiltPart, data)
	orderedBuiltPart.CanCollide = data.canCollide
	orderedBuiltPart.Transparency = data.transparency

	if orderedBuiltPart.Anchored then
		orderedBuiltPart.CFrame = data.cframe
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function finishRepair(state, p, p2)
	applyAuthored(state.builtParts, p)

	for _, brokenPart in state.brokenParts do
		brokenPart.Transparency = 1
		brokenPart.CanCollide = false
	end

	state.broken = false
	state.repairProgress = 0
	state.revealedCount = 0
	state.graceUntilClock = os.clock() + p2.graceSeconds
end

return {
	resolve = function(p, data)
		assert(RunService:IsServer(), "AllanBossRoom.Bridges.resolve is server-only")
		local potentialInstance = InstanceUtils.getPotentialInstance(p, data.bridgesGroupPath)

		if not potentialInstance then
			return nil
		end

		local bridgeRepair = data.bridgeRepair
		local v = {}
		local v2 = {}
		local v3 = {}

		for _, child in potentialInstance:GetChildren() do
			local child2 = child:FindFirstChild(data.builtBridgeName)
			local child3 = child:FindFirstChild(data.brokenBridgeName)

			if not (child2 and child3) then
				continue
			end

			local builtParts = collectParts(child2)
			local brokenParts = collectParts(child3)

			if not (#builtParts > 0 and #brokenParts > 0) then
				continue
			end

			captureState(builtParts, v)
			captureState(brokenParts, v)
			local unitCenterAndRadius, radius = getUnitCenterAndRadius(builtParts)
			local orderedBuiltParts = orderPartsAlongSpan(builtParts)
			local v8 = {
				id = `bridge{#v2 + 1}`,
				builtParts = builtParts,
				brokenParts = brokenParts,
				orderedBuiltParts = orderedBuiltParts,
				ringPositions = computeEndRingPositions(orderedBuiltParts, bridgeRepair),
				center = unitCenterAndRadius,
				radius = radius,
				broken = false,
				repairProgress = 0,
				revealedCount = 0,
				graceUntilClock = 0
			}
			table.insert(v2, v8)
			v3[v8.id] = v8
		end

		if #v2 == 0 then
			return nil
		end

		for _, v4 in v2 do
			applyAuthored(v4.builtParts, v)

			for _, brokenPart in v4.brokenParts do
				brokenPart.Transparency = 1
				brokenPart.CanCollide = false
			end
		end

		return {
			getRandomIntactTargetPosition = function()
				local count = 0

				for _, v4 in v2 do
					if v4.broken then
						count += 1
					end
				end

				if data.maxBrokenBridges <= count then
					return nil
				end

				local v4 = {}

				for _, v5 in v2 do
					if isUnitTargetable(v5) then
						table.insert(v4, v5)
					end
				end

				if #v4 == 0 then
					return nil
				end

				return v4[math.random(1, #v4)].center
			end,
			breakNearPosition = function(vector2: Vector3, p2: number)
				local count = 0

				for _, v4 in v2 do
					if v4.broken then
						count += 1
					end
				end

				for _, v4 in v2 do
					if data.maxBrokenBridges <= count then
						break
					end

					if not (isUnitTargetable(v4) and (v4.center - vector2).Magnitude <= p2 + v4.radius) then
						continue
					end

					v4.broken = true
					v4.repairProgress = 0
					v4.revealedCount = 0

					for _, builtPart in v4.builtParts do
						builtPart.Transparency = 1
						builtPart.CanCollide = false
					end

					applyAuthored(v4.brokenParts, v)
					count += 1
				end
			end,
			getRepairableUnits = function()
				local result = {}

				for _, v4 in v2 do
					if v4.broken then
						table.insert(result, {
							id = v4.id,
							ringPositions = v4.ringPositions,
							progress = v4.repairProgress
						})
					end
				end

				return result
			end,
			addRepairProgress = function(p2: string, p3: number)
				local v4 = v3[p2]

				if not (v4 and v4.broken) then
					return 1, false
				end

				v4.repairProgress = math.clamp(v4.repairProgress + math.max(0, p3), 0, 1)
				local v5 = math.floor(v4.repairProgress * #v4.orderedBuiltParts)

				while v4.revealedCount < v5 do
					v4.revealedCount += 1
					local orderedBuiltPart = v4.orderedBuiltParts[v4.revealedCount]
					revealPart(orderedBuiltPart, v[orderedBuiltPart]) -- equivalent call inferred; original call site unknown
				end

				if not (v4.repairProgress >= 1) then
					return v4.repairProgress, false
				end

				finishRepair(v4, v, bridgeRepair) -- equivalent call inferred; original call site unknown
				return 1, true
			end,
			stop = function() end
		}
	end
}