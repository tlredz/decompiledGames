local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeUnit(p)
	if p.Magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return p.Unit
end

return function(p, p2, p3)
	local bone = p3.Bones[p.ParentIndex]

	if not bone then
		return
	end

	local freeLength = p.FreeLength
	local safeUnit = SafeUnit(p2 - bone.Position) -- equivalent call inferred; original call site unknown
	return bone.Position + safeUnit * freeLength
end