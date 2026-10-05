local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local VehiclePropWeldTarget = {}
VehiclePropWeldTarget.MATCH_MAX_DISTANCE = 0.25

function VehiclePropWeldTarget.ToStorage(vector: Vector3)
	return { vector.X, vector.Y, vector.Z }
end

function VehiclePropWeldTarget.FromStorage(list)
	if not t.table(list) then
		return nil
	end

	local v = list[1]
	local v2 = list[2]
	local v3 = list[3]

	if t.number(v) and t.number(v2) and t.number(v3) then
		return (Vector3.new(v, v2, v3))
	end

	return nil
end

function VehiclePropWeldTarget.FindClosestPart(folder, vector: Vector3, p: number)
	local v = 1e999
	local v2 = nil

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part:FindFirstChild("NoProp") == nil) then
			continue
		end

		local magnitude = (part.Position - vector).Magnitude

		if not (magnitude < v) then
			continue
		end

		v2 = part
		v = magnitude
	end

	if v2 == nil or p < v then
		return nil
	end

	return v2
end

return VehiclePropWeldTarget