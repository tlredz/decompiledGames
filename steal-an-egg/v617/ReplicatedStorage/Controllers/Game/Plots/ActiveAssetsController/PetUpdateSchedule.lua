return table.freeze({
	GetInterval = function(flag: boolean, flag2: boolean, vector: Vector3, p: number, vector2: Vector3?, data)
		if not data.Enabled then
			return 0
		end

		if flag then
			return data.HiddenInterval
		end

		if flag2 or vector2 == nil then
			return 0
		end

		local vector3 = vector - vector2
		local v = data.DistantDistance + p
		local dot = vector3:Dot(vector3)

		if v * v < dot then
			return data.DistantInterval
		end

		return 0
	end,
	TakeStep = function(p: number, p2: number, p3: number, flag: boolean)
		local v = p + p2

		if p3 > 0 and v + 1e-6 < p3 and not flag then
			return false, 0, v
		end

		if p3 > 0 then
			v = math.min(v, 0.25)
		end

		return true, v, 0
	end
})