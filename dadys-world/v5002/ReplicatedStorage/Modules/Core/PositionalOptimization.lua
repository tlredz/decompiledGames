local createVector = vector.create
local PositionalOptimization = {}

function PositionalOptimization.PredictMovement(part, p)
	if not (part and part:IsA("BasePart")) then
		return createVector(0, 0, 0)
	end

	local position = part.Position
	local assemblyLinearVelocity = part.AssemblyLinearVelocity
	local vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)

	if vector2.Magnitude < 0.5 then
		return position
	end

	return position + vector2.Unit * p
end

function PositionalOptimization.GetCollinearTargetPositionOffset(p, p2, p3)
	if p3 == 0 then
		return p
	end

	local v = p2 - p

	if v.Magnitude < 0.1 then
		return p
	end

	if v.Magnitude < p3 then
		return p2
	end

	return p + v.Unit * p3
end

return PositionalOptimization