local CatmullRom = require(script:WaitForChild("CatmullRom"))
local Curves = {}

function Curves.Make(_, list)
	local count = #list

	if count <= 1 then
		return function(_)
			local v = list[1]
			return v.X, v.Y, v.Z
		end
	end

	if count == 2 then
		-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
		local function lerp(p, p2, p3)
			return p * (1 - p3) + p2 * p3
		end

		return function(p)
			local v = list[1]
			local v2 = list[2]
			local v3 = lerp(v.X, v2.X, p)
			local v4 = lerp(v.Y, v2.Y, p)
			return v3, v4, lerp(v.Z, v2.Z, p)
		end
	elseif count == 3 then
		-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
		local function cubicbezier(p, p2, p3, p4)
			return (1 - p4) ^ 2 * p + 2 * (1 - p4) * p4 * p2 + p4 ^ 2 * p3
		end

		return function(p)
			local v = list[1]
			local v2 = list[2]
			local v3 = list[3]
			local v4 = cubicbezier(v.X, v2.X, v3.X, p)
			local v5 = cubicbezier(v.Y, v2.Y, v3.Y, p)
			return v4, v5, cubicbezier(v.Z, v2.Z, v3.Z, p)
		end
	end

	if not (count >= 4) then
		return
	end

	local vectors = {}

	for k, v in pairs(list) do
		vectors[k] = Vector3.new(v.X, v.Y, v.Z)
	end

	local v = CatmullRom.Path.create(vectors)
	return function(p)
		local pointOnPath = v.GetPointOnPath(p)
		return pointOnPath.X, pointOnPath.Y, pointOnPath.Z
	end
end

function Curves.V3(_, p, p2, p3)
	return (Vector3.new(p, p2, p3))
end

return Curves