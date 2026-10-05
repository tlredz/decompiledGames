local v = {
	finite = function(value)
		return type(value) == "number" and value == value and math.abs(value) < 10000000
	end
}

function v.vector(data)
	return typeof(data) == "Vector3" and v.finite(data.X) and v.finite(data.Y) and v.finite(data.Z)
end

function v.valid(data)
	local v2

	if type(data) == "table" and typeof(data.cf) == "CFrame" then
		v2 = v.vector(data.cf.Position) and v.vector(data.min) and v.vector(data.max)

		if v2 then
			if data.min.X < data.max.X and data.min.Y < data.max.Y then
				return data.min.Z < data.max.Z
			else
				return false
			end
		end
	else
		return false
	end

	return v2
end

function v.clamp(p, data)
	local pointToObjectSpace = data.cf:PointToObjectSpace(p)
	return data.cf:PointToWorldSpace((Vector3.new(
		math.clamp(pointToObjectSpace.X, data.min.X, data.max.X),
		math.clamp(pointToObjectSpace.Y, data.min.Y, data.max.Y),
		(math.clamp(pointToObjectSpace.Z, data.min.Z, data.max.Z))
	)))
end

function v.inside(p, p2)
	return v.vector(p) and (p - v.clamp(p, p2)).Magnitude < 0.01
end

function v.bounds(part, data)
	if not (part and part:IsA("BasePart")) then
		return
	end

	if part:IsA("UnionOperation") then
		local v2 = part.Size * 0.5
		local cFrame = part.CFrame
		local v3 = math.abs(cFrame.RightVector.X) * v2.X + math.abs(cFrame.UpVector.X) * v2.Y + math.abs(cFrame.LookVector.X) * v2.Z
		local v4 = math.abs(cFrame.RightVector.Y) * v2.X + math.abs(cFrame.UpVector.Y) * v2.Y + math.abs(cFrame.LookVector.Y) * v2.Z
		local v5 = math.abs(cFrame.RightVector.Z) * v2.X + math.abs(cFrame.UpVector.Z) * v2.Y + math.abs(cFrame.LookVector.Z) * v2.Z
		local v6 = {
			cf = CFrame.new(part.Position),
			min = Vector3.new(-v3 + data.FieldInset, v4 + data.MinHeight, -v5 + data.FieldInset),
			max = Vector3.new(v3 - data.FieldInset, v4 + data.MaxHeight, v5 - data.FieldInset)
		}
		return v.valid(v6) and v6 or nil
	else
		local v2 = part.Size * 0.5
		local Y = v2.Y
		local v3 = Y + data.MaxHeight

		for _, part2 in part.Parent:GetChildren() do
			if not (part2:IsA("BasePart") and part2.Name:find("InvisWall")) then
				continue
			end

			local objectSpace = part.CFrame:ToObjectSpace(part2.CFrame)
			local v4 = part2.Size * 0.5
			local vector = Vector3.new(
				math.abs(objectSpace.RightVector.Y) * v4.X,
				math.abs(objectSpace.UpVector.Y) * v4.Y,
				math.abs(objectSpace.LookVector.Y) * v4.Z
			)
			local v5 = vector.X + vector.Y + vector.Z

			if not (v5 <= 4) then
				continue
			end

			local v6 = objectSpace.Position.Y - v5

			if Y + 10 < v6 then
				v3 = math.min(v3, objectSpace.Position.Y - v5 - data.FieldInset)
			end
		end

		local v4 = {
			cf = part.CFrame,
			min = Vector3.new(-v2.X + data.FieldInset, Y + data.MinHeight, -v2.Z + data.FieldInset),
			max = Vector3.new(v2.X - data.FieldInset, v3, v2.Z - data.FieldInset)
		}
		return v.valid(v4) and v4 or nil
	end
end

function v.creatorBounds(p, folder, p2)
	local bounds = v.bounds(p, p2)

	if not bounds then
		return
	end

	local min = bounds.min
	local max = bounds.max

	if folder then
		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") or not (part.Transparency < 1) or part:GetAttribute("WeaponVFX") then
				continue
			end

			local v2 = part.Size * 0.5

			for i = -1, 1, 2 do
				for i2 = -1, 1, 2 do
					for i3 = -1, 1, 2 do
						local pointToObjectSpace = bounds.cf:PointToObjectSpace(part.CFrame:PointToWorldSpace(v2 * Vector3.new(
							i,
							i2,
							i3
						)))
						min = Vector3.new(
							math.min(min.X, pointToObjectSpace.X - 12),
							math.min(min.Y, pointToObjectSpace.Y + 2),
							(math.min(min.Z, pointToObjectSpace.Z - 12))
						)
						max = Vector3.new(
							math.max(max.X, pointToObjectSpace.X + 12),
							math.max(max.Y, pointToObjectSpace.Y + 30),
							(math.max(max.Z, pointToObjectSpace.Z + 12))
						)
					end
				end
			end
		end
	end

	bounds.min = min
	bounds.max = max
	return v.valid(bounds) and bounds or nil
end

function v.alpha(p, p2)
	return 1 - math.exp(-p * math.max(0, p2))
end

function v.angles(p)
	local lookVector = p.LookVector
	return math.atan2(-lookVector.X, -lookVector.Z), (math.asin((math.clamp(lookVector.Y, -1, 1))))
end

function v.deadzone(p)
	local magnitude = p.Magnitude

	if magnitude < 0.16 then
		return Vector2.zero
	end

	return p.Unit * math.clamp((magnitude - 0.16) / 0.84, 0, 1)
end

return table.freeze(v)