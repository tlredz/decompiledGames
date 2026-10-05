local CrossyRoadMotion = {
	speed = function(p, p2)
		return 20 + 60 * ((p - 1) / (p2 - 1)) ^ 1.35
	end,
	interval = function(p, p2)
		local v = math.max(1.4, 90 / p2) + p % 3 * 0.15

		if p >= 16 then
			return v / 1.15 or v
		end

		return v
	end,
	position = function(data, p, p2, p3, p4)
		local v = p.x + math.max(0, p2 - p.born) * data.speed * data.direction
		local v2 = math.clamp((v + p3) / (2 * p3) * 20, 0, 20)
		local v3 = math.min(19, (math.floor(v2)))
		local v4 = data.samples[v3 + 1].Y + (data.samples[v3 + 2].Y - data.samples[v3 + 1].Y) * (v2 - v3)
		local v5 = data.center + p4 * v
		return Vector3.new(v5.X, v4 + 3, v5.Z), v
	end,
	contact = function(p, p2, p3, p4, p5)
		local vector = p - p3
		local vector2 = p2 - p4 - vector
		return (vector + vector2 * (not (vector2:Dot(vector2) > 0) and 0 or math.clamp(
			-vector:Dot(vector2) / vector2:Dot(vector2),
			0,
			1
		) or 0)).Magnitude <= p5
	end,
	finite = function(value)
		return type(value) == "number" and value == value and math.abs(value) < 1000000000000
	end
}

function CrossyRoadMotion.vector(data)
	return typeof(data) == "Vector3" and CrossyRoadMotion.finite(data.X) and CrossyRoadMotion.finite(data.Y) and CrossyRoadMotion.finite(data.Z)
end

return CrossyRoadMotion