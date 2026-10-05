local GetWaterHeightAtLocation = require(script.Parent.GetWaterHeightAtLocation)
return {
	ROOT_OFFSET = -0.25,
	get = function(instance, vector: Vector3)
		local v, v2, v3, v4 = GetWaterHeightAtLocation(vector)
		local v5 = not instance:FindFirstChild("TRex")

		if v5 then
			v5 = not (v4 and (not v4.AllowSwim or v4.HalfSize.Y * 2 < v4.MinSwimDepth))
		end

		if instance:FindFirstChild("Mammoth") then
			v -= 6
		end

		return v, v2, v3, v4, v5
	end
}