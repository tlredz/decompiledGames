local RenderMath = {
	lerpColor = function(color: Color3, color2: Color3, p: number)
		return Color3.new(
			color.R + (color2.R - color.R) * p,
			color.G + (color2.G - color.G) * p,
			color.B + (color2.B - color.B) * p
		)
	end,
	getMaxBladeCount = function(p)
		local v = 0

		for _, role in p.roles do
			if role.skill.trigger == "Passive" then
				v = math.max(v, role.skill.maxBladeCount)
			elseif role.skill.trigger == "PassiveSword" or role.skill.trigger == "PassiveAxe" then
				v = math.max(v, 1)
			end
		end

		return v
	end,
	appendUniqueIntersection = function(list, p)
		for _, v in ipairs(list) do
			if math.abs(v - p) <= 0.0001 then
				return
			end
		end

		table.insert(list, p)
	end
}

function RenderMath.collectVerticalIntersections(list, p)
	local v = {}

	for k, v2 in list do
		local v3 = list[k % #list + 1]
		local v4 = math.min(v2.X, v3.X)
		local v5 = math.max(v2.X, v3.X)

		if p < v4 - 0.0001 or v5 + 0.0001 < p then
			continue
		end

		if math.abs(v3.X - v2.X) <= 0.0001 then
			if math.abs(p - v2.X) <= 0.0001 then
				RenderMath.appendUniqueIntersection(v, v2.Y)
				RenderMath.appendUniqueIntersection(v, v3.Y)
			end
		else
			local v6 = (p - v2.X) / (v3.X - v2.X)

			if v6 >= -0.0001 and v6 <= 1.0001 then
				RenderMath.appendUniqueIntersection(v, v2.Y + (v3.Y - v2.Y) * v6)
			end
		end
	end

	table.sort(v)
	return v
end

function RenderMath.collectHorizontalIntersections(list, p)
	local v = {}

	for k, v2 in list do
		local v3 = list[k % #list + 1]
		local v4 = math.min(v2.Y, v3.Y)
		local v5 = math.max(v2.Y, v3.Y)

		if p < v4 - 0.0001 or v5 + 0.0001 < p then
			continue
		end

		if math.abs(v3.Y - v2.Y) <= 0.0001 then
			if math.abs(p - v2.Y) <= 0.0001 then
				RenderMath.appendUniqueIntersection(v, v2.X)
				RenderMath.appendUniqueIntersection(v, v3.X)
			end
		else
			local v6 = (p - v2.Y) / (v3.Y - v2.Y)

			if v6 >= -0.0001 and v6 <= 1.0001 then
				RenderMath.appendUniqueIntersection(v, v2.X + (v3.X - v2.X) * v6)
			end
		end
	end

	table.sort(v)
	return v
end

function RenderMath.buildZoneRegionSignature(data)
	local v = {
		string.format("%d", data.regionId),
		string.format("%.3f,%.3f", data.startPosition.X, data.startPosition.Y),
		string.format("%.3f,%.3f", data.endPosition.X, data.endPosition.Y)
	}

	for _, v2 in data.polygon do
		table.insert(v, string.format("%.3f,%.3f", v2.X, v2.Y))
	end

	return table.concat(v, "|")
end

function RenderMath.getOwningSlotId(p, value: string)
	for k, _ in p.slots do
		if value == k or string.find(value, k, 1, true) then
			return k
		end
	end

	return nil
end

function RenderMath.shouldHighlightSameMaterialEnemy(p, p2, p3: string?, p4: string, flag: boolean?)
	if p3 == nil or p4 == p3 then
		return false
	end

	if flag then
		return true
	end

	local v = p2[p3]
	local v2 = p2[p4]
	local v3 = v and p.roles[v]
	local v4 = v2 and p.roles[v2]
	return v3 ~= nil and v4 ~= nil and v3.templateName == v4.templateName
end

function RenderMath.scaled(p: number, p2: number)
	return p * p2
end

function RenderMath.worldFromArena(cframe: CFrame, p: number, point: Vector2, value: number?)
	return cframe:PointToWorldSpace((Vector3.new(point.X * p, point.Y * p, -RenderMath.scaled(value or 0, p))))
end

function RenderMath.arenaFromWorld(cframe: CFrame, p: number, vector: Vector3)
	local pointToObjectSpace = cframe:PointToObjectSpace(vector)
	return Vector2.new(pointToObjectSpace.X / p, pointToObjectSpace.Y / p)
end

local cframe = CFrame.Angles(0, 1.5707963267948966, 0)

function RenderMath.getEffectArenaRotation(cframe2: CFrame)
	return cframe2.Rotation * cframe:Inverse()
end

function RenderMath.getArenaBallCFrame(cframe2: CFrame, vector: Vector3)
	return CFrame.lookAt(vector, vector + cframe2.UpVector, cframe2.LookVector)
end

function RenderMath.resolveDirectionFacingCFrame(vector: Vector3, vector2: Vector3, vector3: Vector3, cframe2: CFrame)
	if (vector2 - vector).Magnitude < 0.001 then
		return nil
	end

	return CFrame.lookAt(vector, vector2, vector3) * cframe2:Inverse()
end

function RenderMath.getConcealedAimingCFrame(cframe2: CFrame, vector: Vector3, cframe3: CFrame)
	return RenderMath.resolveDirectionFacingCFrame(vector, vector - cframe2.UpVector, cframe2.LookVector, cframe3) or RenderMath.getArenaBallCFrame(
		cframe2,
		vector
	) * cframe3:Inverse()
end

local v = {
	SnakeTail = "Direction",
	VampireAttach = "Target",
	MachineGun = "Target",
	ThiefKnives = "Target",
	ChargedBow = "Target",
	DogCannon = "Target",
	SpearThrust = "Direction",
	OnePunch = "Target"
}
RenderMath.FACING_DIRECTION = "Direction"
RenderMath.FACING_TARGET = "Target"

function RenderMath.getFacingMode(p: string?)
	if p == nil then
		return nil
	end

	return v[p]
end

function RenderMath.findNearestEnemy(items, p)
	local v2 = 1e999
	local v3 = nil

	for _, item in items do
		if not (item.team and p.team and item.team ~= p.team) then
			continue
		end

		local vector = item.position - p.position
		local dot = vector:Dot(vector)

		if not (dot < v2) then
			continue
		end

		v3 = item
		v2 = dot
	end

	return v3
end

function RenderMath.resolveBallCFrame(cframe2: CFrame, p: number, p2, data, p3, vector: Vector3)
	local v2 = p2[data.roleId]
	local forwardOffset = v2 and v2.forwardOffset or CFrame.identity
	local arenaBallCFrame = RenderMath.getArenaBallCFrame(cframe2, vector)
	local facingMode = RenderMath.getFacingMode(data.skill and data.skill.trigger)

	if facingMode == nil then
		return arenaBallCFrame * forwardOffset:Inverse()
	end

	local v3

	if data.direction == nil then
		v3 = false
	else
		v3 = data.direction.Magnitude > 0.001
	end

	local position = nil

	if facingMode == RenderMath.FACING_DIRECTION and v3 then
		position = data.position + data.direction
	elseif p3 and p3.position then
		position = p3.position
	elseif v3 then
		position = data.position + data.direction
	end

	if position == nil then
		return arenaBallCFrame * forwardOffset:Inverse()
	end

	local worldFromArena = RenderMath.worldFromArena(cframe2, p, position)
	return RenderMath.resolveDirectionFacingCFrame(vector, worldFromArena, cframe2.LookVector, forwardOffset) or arenaBallCFrame * forwardOffset:Inverse()
end

return RenderMath