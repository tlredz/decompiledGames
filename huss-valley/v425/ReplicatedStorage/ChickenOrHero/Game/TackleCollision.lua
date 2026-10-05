local createVector = vector.create
return table.freeze({
	new = function(p)
		local humanoidRootPart = p.HumanoidRootPart
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { p }
		raycastParams.RespectCanCollide = true
		raycastParams.CollisionGroup = humanoidRootPart.CollisionGroup
		raycastParams.IgnoreWater = true
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = { p }
		overlapParams.RespectCanCollide = true
		overlapParams.CollisionGroup = humanoidRootPart.CollisionGroup
		overlapParams.MaxParts = 1
		return {
			params = raycastParams,
			overlap = overlapParams,
			size = Vector3.new(humanoidRootPart.Size.X + 0.2, 1.6, humanoidRootPart.Size.Z + 0.2),
			stopped = false
		}
	end,
	limit = function(state, p, p2, p3, p4)
		if state.stopped or p3 <= 0 then
			return 0
		end

		local v = math.max(p4, 0.004166666666666667)
		local v2 = math.max(0.7, p3 * 0.065)
		local v3 = math.max(v2, p3 * v) + 0.22
		local cframe = CFrame.lookAt(p.Position, p.Position + p2)

		if #workspace:GetPartBoundsInBox(cframe, state.size - createVector(0.15, 0.2, 0.15), state.overlap) > 0 then
			state.stopped = true
			return 0
		end

		local blockcast = workspace:Blockcast(cframe, state.size, p2 * v3, state.params)

		if not blockcast or (blockcast.Normal:Dot(p2) >= -0.05 or math.abs(blockcast.Normal.Y) > 0.75) then
			return p3
		end

		local v4 = math.max(0, blockcast.Distance - 0.22)

		if v4 <= 0.08 then
			state.stopped = true
			return 0
		else
			return (math.min(p3, p3 * math.clamp(v4 / v2, 0, 1), v4 / v))
		end
	end
})