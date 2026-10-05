local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.CFrame)
local strict2 = t.strict(t.Vector3)
return function(cframe: CFrame, vector: Vector3, vector2: Vector3)
	strict(cframe)
	strict2(vector)
	strict2(vector2)
	local abs = cframe:PointToObjectSpace(vector2):Abs()
	local v = vector / 2
	return abs:Max(v) == v
end