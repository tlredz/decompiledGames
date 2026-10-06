local HookGrappleSolver = {}

function HookGrappleSolver.solve(state, point: Vector2, list, point2: Vector2)
	local v = #list + 1

	if not state.ropePositions or #state.ropePositions ~= v then
		local vector = Vector2.new(math.cos(state.rotationAngle or 0), (math.sin(state.rotationAngle or 0)))
		local ropePositions2 = table.create(v)
		ropePositions2[1] = point

		for i = 1, #list do
			ropePositions2[i + 1] = ropePositions2[i] + vector * list[i]
		end

		state.ropePositions = ropePositions2
		state.appliedRotationAngle = state.rotationAngle
	end

	local ropePositions = state.ropePositions
	local appliedRotationAngle = state.appliedRotationAngle or state.rotationAngle
	local v2 = state.rotationAngle - appliedRotationAngle

	if v2 ~= 0 then
		local v3 = math.cos(v2)
		local v4 = math.sin(v2)

		for i = 2, v do
			local v5 = ropePositions[i] - ropePositions[1]
			ropePositions[i] = ropePositions[1] + Vector2.new(v5.X * v3 - v5.Y * v4, v5.X * v4 + v5.Y * v3)
		end
	end

	state.appliedRotationAngle = state.rotationAngle
	ropePositions[1] = point

	local function clampToArena(point3: Vector2)
		return Vector2.new(math.clamp(point3.X, -point2.X, point2.X), (math.clamp(point3.Y, -point2.Y, point2.Y)))
	end

	for i = 2, v do
		local ropePosition = ropePositions[i]
		ropePositions[i] = Vector2.new(
			math.clamp(ropePosition.X, -point2.X, point2.X),
			(math.clamp(ropePosition.Y, -point2.Y, point2.Y))
		)
	end

	for _ = 1, 6 do
		ropePositions[1] = point

		for i = 1, #list do
			local ropePosition = ropePositions[i]
			local ropePosition2 = ropePositions[i + 1]
			local v3 = ropePosition2 - ropePosition
			local magnitude = v3.Magnitude

			if not (magnitude > 1e-6) then
				continue
			end

			local v4 = (magnitude - list[i]) / magnitude

			if i == 1 then
				ropePositions[1 + 1] = ropePosition2 - v3 * v4
			else
				local v5 = v3 * (v4 * 0.5)
				ropePositions[i] = ropePosition + v5
				ropePositions[i + 1] = ropePosition2 - v5
			end
		end
	end

	for i = 2, v do
		local ropePosition = ropePositions[i]
		ropePositions[i] = Vector2.new(
			math.clamp(ropePosition.X, -point2.X, point2.X),
			(math.clamp(ropePosition.Y, -point2.Y, point2.Y))
		)
	end

	ropePositions[1] = point
	return ropePositions
end

function HookGrappleSolver.solveExtended(state, point: Vector2, list, point2: Vector2)
	local v = #list + 1
	local vector = Vector2.new(math.cos(state.rotationAngle), (math.sin(state.rotationAngle)))

	local function rayDistanceToArenaEdge()
		return (math.max(
			0,
			(math.min(
				not (math.abs(vector.X) > 1e-6) and 1e999 or ((vector.X > 0 and point2.X or -point2.X) - point.X) / vector.X,
				not (math.abs(vector.Y) > 1e-6) and 1e999 or ((vector.Y > 0 and point2.Y or -point2.Y) - point.Y) / vector.Y
			))
		))
	end

	local v2 = table.create(v)
	v2[1] = 0
	local total = 0

	for i = 1, #list do
		total += list[i]
		v2[i + 1] = total
	end

	local v3 = math.min(total, (rayDistanceToArenaEdge()))
	local ropePositions = state.ropePositions

	if not ropePositions or #ropePositions ~= v then
		ropePositions = table.create(v)
		state.ropePositions = ropePositions
	end

	ropePositions[1] = point

	for i = 2, v do
		ropePositions[i] = point + vector * math.min(v2[i], v3)
	end

	state.appliedRotationAngle = state.rotationAngle
	return ropePositions
end

return HookGrappleSolver