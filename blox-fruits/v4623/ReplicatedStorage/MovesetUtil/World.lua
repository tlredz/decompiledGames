return {
	mapRay = function(vector: Vector3, vector2: Vector3)
		return workspace:FindPartOnRayWithWhitelist(Ray.new(vector, vector2), { workspace.Map })
	end
}