local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
return {
	XZ = function(vector: Vector3, vector2: Vector3)
		t.strict(t.Vector3)(vector)
		t.strict(t.Vector3)(vector2)
		local v = vector - vector2
		return Vector3.new(v.X, 0, v.Z).Magnitude
	end
}