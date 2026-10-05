local createVector = vector.create
local HitReplayMath = {
	vector = function(data)
		return typeof(data) == "Vector3" and data.X == data.X and data.Y == data.Y and data.Z == data.Z and data.Magnitude < 1000000
	end,
	bounds = function(p, data)
		if p ~= "Melee" then
			return {
				width = 0.95 * (data.Width + 2 * data.RunnerRadius),
				height = 0.95 * data.Height,
				near = 0,
				far = 0.95 * (data.Reach + data.RunnerRadius)
			}
		end

		local v = data.RunnerRadius + data.ContactPadding
		return {
			width = 1.9 * (data.HitHalfWidth + v),
			height = 1.9 * data.Height,
			near = 0.95 * data.MinForward,
			far = 0.95 * (data.HandRadius + v)
		}
	end
}

function HitReplayMath.sweep(p, p2, p3, p4, p5, data)
	if not HitReplayMath.vector(p5) or p5.Magnitude < 0.01 then
		return false
	end

	local v = p5 * createVector(1, 0, 1)

	if v.Magnitude < 0.01 then
		return false
	end

	local unit = v.Unit
	local cross = unit:Cross(createVector(0, 1, 0))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function coordinates(vector2)
		return (Vector3.new(vector2:Dot(cross), vector2.Y, vector2:Dot(unit)))
	end

	local v3 = coordinates(p3 - p) -- equivalent call inferred; original call site unknown
	local vector2 = p4 - p2
	local v4 = Vector3.new(vector2:Dot(cross), vector2.Y, vector2:Dot(unit)) - v3
	local v5 = 0
	local v6 = 1

	local function slab(p6, p7, p8, p9)
		if math.abs(p7) < 1e-6 then
			return p8 <= p6 and p6 <= p9
		else
			local v7 = (p8 - p6) / p7
			local v8 = (p9 - p6) / p7

			if v8 < v7 then
				v8, v7 = v7, v8
			end

			local v9 = math.max(v5, v7)
			local v10 = math.min(v6, v8)
			v5 = v9
			v6 = v10
			return v5 <= v6
		end
	end

	local X = v3.X
	local X2 = v4.X
	local v7 = -data.width / 2
	local halfWidth = data.width / 2
	local v9

	if math.abs(X2) < 1e-6 then
		if v7 <= X then
			v9 = X <= halfWidth
		else
			v9 = false
		end
	else
		local v10 = (v7 - X) / X2
		local v11 = (halfWidth - X) / X2

		if v11 < v10 then
			v11, v10 = v10, v11
		end

		v5 = math.max(v5, v10)
		v6 = math.min(v6, v11)
		v9 = v5 <= v6
	end

	if not v9 then
		return false
	end

	local Y = v3.Y
	local Y2 = v4.Y
	local v10 = -data.height / 2
	local halfHeight = data.height / 2
	local v12

	if math.abs(Y2) < 1e-6 then
		if v10 <= Y then
			v12 = Y <= halfHeight
		else
			v12 = false
		end
	else
		local v13 = (v10 - Y) / Y2
		local v14 = (halfHeight - Y) / Y2

		if v14 < v13 then
			v14, v13 = v13, v14
		end

		v5 = math.max(v5, v13)
		v6 = math.min(v6, v14)
		v12 = v5 <= v6
	end

	if not v12 then
		return false
	end

	local Z = v3.Z
	local Z2 = v4.Z
	local near = data.near
	local far = data.far
	local v13

	if math.abs(Z2) < 1e-6 then
		if near <= Z then
			v13 = Z <= far
		else
			v13 = false
		end
	else
		local v14 = (near - Z) / Z2
		local v15 = (far - Z) / Z2

		if v15 < v14 then
			v15, v14 = v14, v15
		end

		v5 = math.max(v5, v14)
		v6 = math.min(v6, v15)
		v13 = v5 <= v6
	end

	if v13 then
		return true, p:Lerp(p2, v5), p3:Lerp(p4, v5)
	end

	return false
end

function HitReplayMath.sample(list, p)
	for i = #list, 1, -1 do
		if math.abs(list[i].at - p) < 1e-6 then
			return table.clone(list[i])
		end
	end

	for i = #list, 2, -1 do
		local v = list[i - 1]
		local v2 = list[i]

		if not (v.at <= p and p <= v2.at) then
			continue
		end

		if v.character ~= v2.character or v.reset ~= v2.reset or v.relocation ~= v2.relocation or v.active ~= v2.active or v.role ~= v2.role or v.safe ~= v2.safe or v2.at - v.at > 0.15 or (v2.position - v.position).Magnitude > 14 then
			return nil
		end

		local v3 = not (v2.at > v.at) and 0 or (p - v.at) / (v2.at - v.at) or 0
		local clone = table.clone(v)
		clone.position = v.position:Lerp(v2.position, v3)
		return clone
	end

	return nil
end

return HitReplayMath