local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetWaterHeightAtLocation = require(ReplicatedStorage.Util.GetWaterHeightAtLocation)
local cframe = CFrame.new(
	-1190.04871,
	20.2823486,
	1968.2467,
	-0.779071033,
	0.0790071487,
	0.621937454,
	-3.7252903e-9,
	0.992027581,
	-0.126021132,
	-0.62693572,
	-0.0981794149,
	-0.772859931
)
local v = {
	flattenedUnit = function(vector: Vector3)
		local vector2 = Vector3.new(vector.X, 0, vector.Z)

		if vector2.Magnitude < 0.0001 then
			return nil
		end

		return vector2.Unit
	end
}

function v.resolve()
	local flattenedUnit = v.flattenedUnit(cframe.LookVector)
	local flattenedUnit2 = v.flattenedUnit(cframe.RightVector)

	if not (flattenedUnit and flattenedUnit2) then
		return nil, "the Lookout base CFrame has an invalid scene orientation"
	end

	local v2 = cframe.Position + flattenedUnit * 270
	local waterHeightAtLocation = GetWaterHeightAtLocation(v2)

	if typeof(waterHeightAtLocation) == "number" then
		return {
			Center = Vector3.new(v2.X, waterHeightAtLocation, v2.Z),
			Forward = flattenedUnit,
			Right = flattenedUnit2,
			CameraCFrame = cframe
		}, nil
	end

	return nil, "the Middle Town water height is unavailable"
end

return table.freeze(v)