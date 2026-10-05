local v = {}

local function getUIDConstants(value)
	local v2 = v[value]

	if v2 then
		return v2
	end

	local v3 = 0

	for i = 1, #value do
		v3 = (v3 * 31 + string.byte(value, i)) % 1000000
	end

	local v4 = {
		offsetX = v3 % 1000 / 1000,
		offsetY = v3 * 7 % 1000 / 1000,
		offsetZ = v3 * 13 % 1000 / 1000,
		frequencyX = v3 % 100 / 500 + 0.3,
		frequencyY = v3 * 3 % 100 / 500 + 0.2,
		frequencyZ = v3 * 5 % 100 / 500 + 0.25
	}
	v[value] = v4
	return v4
end

return {
	GetPosition = function(p, p2: number, p3: string)
		local uIDConstants = getUIDConstants(p3)
		local v2 = p2 * 0.25
		local size = p.Size
		local v3 = (size.X - 1) / 2
		local v4 = (size.Y - 1) / 2
		local v5 = (size.Z - 1) / 2
		local v6 = math.sin(v2 * uIDConstants.frequencyX + uIDConstants.offsetX * 3.141592653589793 * 2) * v3 * 0.8
		local v7 = math.sin(v2 * uIDConstants.frequencyY + uIDConstants.offsetY * 3.141592653589793 * 2) * v4 * 0.6
		local v8 = math.cos(v2 * uIDConstants.frequencyZ + uIDConstants.offsetZ * 3.141592653589793 * 2) * v5 * 0.8
		local vector = Vector3.new(
			v6 + math.cos(v2 * uIDConstants.frequencyX * 0.5 + uIDConstants.offsetZ) * v3 * 0.2,
			v7,
			v8 + math.sin(v2 * uIDConstants.frequencyZ * 0.7 + uIDConstants.offsetX) * v5 * 0.2
		)
		return p.Position + vector
	end
}