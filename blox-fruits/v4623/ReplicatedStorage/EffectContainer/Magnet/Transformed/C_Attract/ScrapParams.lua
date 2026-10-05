local createVector = vector.create
return {
	get = function(p: number, vector2: Vector3, p2: number)
		local random = Random.new(p + p2)
		local v = vector2 + createVector(0, 10, 0)
		local v2 = 1 - p2 / 39 * 2
		local v3 = math.sqrt(1 - v2 * v2)
		local v4 = 2.399963229728653 * p2
		local finalPos = v + Vector3.new(math.cos(v4) * v3, v2, math.sin(v4) * v3) * 30
		local unit = (finalPos - (vector2 + createVector(0, 1, 0))).Unit
		local v6

		if random:NextNumber() < 0.85 then
			v6 = random:NextInteger(70, 100) / 100
		else
			v6 = random:NextInteger(0, 20) / 100
		end

		local unit2 = (unit + Vector3.new(0, -v6, 0)).Unit
		local integer = random:NextInteger(150, 250)
		local vector3 = Vector3.new(random:NextInteger(-30, 30), 0, random:NextInteger(-30, 30))
		return {
			finalPos = finalPos,
			biasedDir = unit2,
			shootDist = integer,
			targetPos = finalPos + unit2 * integer + vector3,
			tweenTime = 0.25 + random:NextNumber() * 0.2
		}
	end
}