-- equivalent calls inferred from this helper; original call sites unknown
local function random()
	return math.random() * 2 - 1
end

return function(instance)
	local v = instance.Size * 0.5
	local vector = Vector3.new(v.X * random(), v.Y * random(), v.Z * random())
	return instance.CFrame:ToWorldSpace(CFrame.new(vector)).Position
end