local BattleStateClone = {
	cloneArray = function(list)
		local result = table.create(#list)

		for k, v in list do
			result[k] = v
		end

		return result
	end,
	cloneSpiderWebs = function(list)
		local result = table.create(#list)

		for k, v in list do
			result[k] = {
				anchorPosition = v.anchorPosition,
				startPosition = v.startPosition,
				endPosition = v.endPosition
			}
		end

		return result
	end,
	cloneLaserSegments = function(list)
		local result = table.create(#list)

		for k, v in list do
			result[k] = {
				startPosition = v.startPosition,
				endPosition = v.endPosition
			}
		end

		return result
	end,
	clonePoisonSpikes = function(list)
		local wallEntries = table.create(#list)

		for k, v in list do
			wallEntries[k] = {
				spikeId = v.spikeId,
				ownerBallId = v.ownerBallId,
				wallKey = v.wallKey,
				wallPosition = v.wallPosition,
				centerPosition = v.centerPosition,
				normal = v.normal,
				tangent = v.tangent,
				width = v.width,
				depth = v.depth,
				minX = v.minX,
				maxX = v.maxX,
				minY = v.minY,
				maxY = v.maxY,
				protectedUntil = v.protectedUntil
			}
		end

		return wallEntries
	end,
	cloneHiveVenomStacks = function(list)
		local result = table.create(#list)

		for k, v in list do
			result[k] = {
				stackId = v.stackId,
				ticksRemaining = v.ticksRemaining,
				tickCooldown = v.tickCooldown,
				tickInterval = v.tickInterval,
				damage = v.damage,
				sourceBallId = v.sourceBallId
			}
		end

		return result
	end,
	cloneAcidPoisonStacks = function(list)
		local result = table.create(#list)

		for k, v in list do
			result[k] = {
				stackId = v.stackId,
				ticksRemaining = v.ticksRemaining,
				tickCooldown = v.tickCooldown,
				tickInterval = v.tickInterval,
				damage = v.damage,
				sourceBallId = v.sourceBallId,
				slowElapsed = v.slowElapsed,
				slowDuration = v.slowDuration,
				initialSlowMultiplier = v.initialSlowMultiplier
			}
		end

		return result
	end,
	clonePolygon = function(list)
		local result = table.create(#list)

		for k, v in list do
			result[k] = v
		end

		return result
	end
}

function BattleStateClone.cloneZoneRegions(list)
	local result = table.create(#list)

	for k, v in list do
		local tickProgressByEntityId = {}

		for k2, v3 in v.tickProgressByEntityId do
			tickProgressByEntityId[k2] = v3
		end

		local insideEntityIds = {}

		for k2, insideEntityId in v.insideEntityIds do
			insideEntityIds[k2] = insideEntityId
		end

		result[k] = {
			regionId = v.regionId,
			startPosition = v.startPosition,
			endPosition = v.endPosition,
			polygon = BattleStateClone.clonePolygon(v.polygon),
			remainingLifetime = v.remainingLifetime,
			tickProgressByEntityId = tickProgressByEntityId,
			insideEntityIds = insideEntityIds
		}
	end

	return result
end

return BattleStateClone