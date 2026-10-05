local createVector = vector.create
local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
local HeldMotion = {
	getFlatDirection = function(cframe: CFrame, vector2: Vector3)
		local v = (vector2 - cframe.Position) * createVector(1, 0, 1)

		if v.Magnitude > 0.001 then
			return v.Unit
		end

		local v2 = cframe.LookVector * createVector(1, 0, 1)

		if v2.Magnitude > 0.001 then
			return v2.Unit
		end

		return createVector(-0, -0, -1)
	end
}

function HeldMotion.getSpinCFrame(cframe: CFrame, vector2: Vector3, p: number)
	local flatDirection = HeldMotion.getFlatDirection(cframe, vector2)
	local magnitude = ((vector2 - cframe.Position) * createVector(1, 0, 1)).Magnitude
	local v = cframe.Position + flatDirection * math.min(p * 60, magnitude)
	return CFrame.lookAt(v, v + flatDirection)
end

function HeldMotion.getLandingPosition(vector2: Vector3, p: number)
	local waterHeightAtLocation = GetWaterHeightAtLocation(vector2)
	return (Vector3.new(vector2.X, math.max(vector2.Y, waterHeightAtLocation) + p, vector2.Z))
end

return HeldMotion