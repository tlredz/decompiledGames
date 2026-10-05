local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeUnit(p)
	if p.Magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return p.Unit
end

return function(p, p2, p3)
	local parentIndex = p.ParentIndex
	local bone = p3.Bones[parentIndex]

	if not bone then
		return p2
	end

	local rotationLimit = bone.RotationLimit

	if rotationLimit >= 180 then
		return p2
	end

	local bone2 = p3.Bones[bone.ParentIndex]

	if not bone2 then
		return p2
	end

	local position = bone.Position
	local vector2 = SafeUnit(bone.Position - bone2.Position) -- equivalent call inferred; original call site unknown
	local magnitude = (p2 - position).Magnitude
	local safeUnit = SafeUnit(p2 - position) -- equivalent call inferred; original call site unknown

	if rotationLimit <= 0 then
		return position + vector2 * magnitude
	end

	local rotationLimit2 = math.rad(p.RotationLimit)

	if rotationLimit2 <= math.acos((vector2:Dot(safeUnit))) then
		local safeUnit2 = SafeUnit(vector2:Cross(safeUnit)) -- equivalent call inferred; original call site unknown
		safeUnit = CFrame.fromAxisAngle(safeUnit2, rotationLimit2) * vector2
	end

	if safeUnit ~= safeUnit then
		safeUnit = vector2
	end

	return position + safeUnit * magnitude
end