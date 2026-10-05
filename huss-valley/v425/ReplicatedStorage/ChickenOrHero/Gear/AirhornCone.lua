local v = {
	Range = 14,
	MaxHeight = 6
}

function v.contains(p, _, p2, value)
	local v2 = p2 - p
	local vector = Vector3.new(v2.X, 0, v2.Z)
	return math.abs(v2.Y) <= v.MaxHeight and vector.Magnitude <= v.Range + (value or 0)
end

return table.freeze(v)