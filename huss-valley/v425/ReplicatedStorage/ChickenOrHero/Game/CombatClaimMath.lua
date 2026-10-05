local v = {
	finite = function(value)
		return type(value) == "number" and value == value and math.abs(value) < 1e999
	end
}

function v.vector(data)
	return typeof(data) == "Vector3" and v.finite(data.X) and v.finite(data.Y) and v.finite(data.Z) and data.Magnitude < 1000000
end

function v.compatible(data, data2)
	if data.character == data2.character and data.reset == data2.reset and data.relocation == data2.relocation and data.life == data2.life and data.lives == data2.lives then
		return data.active and data2.active and not (data.safe or data2.safe) and data.role == data2.role
	else
		return false
	end
end

function v.locate(items, p, p2, p3, data, p4)
	if not v.vector(p) or not v.finite(p2) or not v.finite(p3) or p3 < p2 or not v.finite(p4) or p4 < 0 then
		return nil
	end

	local v2 = nil
	local v3 = nil

	local function consider(item, position, at)
		if item.character ~= data.character or item.reset ~= data.reset or item.relocation ~= data.relocation or item.life ~= data.life or item.lives ~= data.lives or data.role and item.role ~= data.role or not item.active or item.safe then
			return
		end

		local magnitude = (position - p).Magnitude

		if magnitude <= p4 and (not v3 or magnitude < v3 - 1e-6 or math.abs(magnitude - v3) < 1e-6 and v2.at < at) then
			v3 = magnitude
			v2 = {
				at = at,
				position = position,
				character = item.character,
				reset = item.reset,
				relocation = item.relocation,
				role = item.role
			}
		end
	end

	for k, item in items do
		if p2 <= item.at and item.at <= p3 then
			consider(item, item.position, item.at)
		end

		local item2 = items[k - 1]

		if not (item2 and p2 <= item.at and item2.at <= p3 and v.compatible(item2, item)) then
			continue
		end

		if not (item.at - item2.at <= 0.15 and (item.position - item2.position).Magnitude <= 20) then
			continue
		end

		local v4 = item.at - item2.at

		if not (v4 > 0) then
			continue
		end

		local v5 = math.clamp((p2 - item2.at) / v4, 0, 1)
		local v6 = math.clamp((p3 - item2.at) / v4, 0, 1)
		local vector = item.position - item2.position

		if vector:Dot(vector) > 1e-6 then
			v6 = math.clamp((p - item2.position):Dot(vector) / vector:Dot(vector), v5, v6) or v6
		end

		consider(item2, item2.position:Lerp(item.position, v6), item2.at + v4 * v6)
	end

	return v2, v3
end

function v.segment(p, p2, p3)
	local v2 = v.vector(p) and v.vector(p2) and v.finite(p3)

	if v2 then
		if p3 >= 0 and p3 <= 0.08 then
			return (p - p2).Magnitude <= 150 * p3 + 1.5
		else
			return false
		end
	end

	return v2
end

return table.freeze(v)