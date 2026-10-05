return {
	getCorners = function(cframe: CFrame, vector: Vector3)
		local v2 = cframe + cframe.LookVector * vector.Z / 2
		local v3 = cframe - cframe.LookVector * vector.Z / 2
		local v4 = v2 + v2.UpVector * vector.Y / 2
		local v5 = v2 - v2.UpVector * vector.Y / 2
		local v6 = v3 + v3.UpVector * vector.Y / 2
		local v7 = v3 - v3.UpVector * vector.Y / 2
		return {
			topFrontRight = (v4 + v4.RightVector * vector.X / 2).Position,
			topFrontLeft = (v4 - v4.RightVector * vector.X / 2).Position,
			bottomFrontRight = (v5 + v5.RightVector * vector.X / 2).Position,
			bottomFrontLeft = (v5 - v5.RightVector * vector.X / 2).Position,
			topBackRight = (v6 + v6.RightVector * vector.X / 2).Position,
			topBackLeft = (v6 - v6.RightVector * vector.X / 2).Position,
			bottomBackRight = (v7 + v7.RightVector * vector.X / 2).Position,
			bottomBackLeft = (v7 - v7.RightVector * vector.X / 2).Position
		}
	end
}