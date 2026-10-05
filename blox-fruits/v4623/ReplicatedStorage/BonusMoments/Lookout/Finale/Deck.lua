local createVector = vector.create
local RunService = game:GetService("RunService")
local CharacterPresentation = require(script.Parent.Parent.CharacterPresentation)
local Scene = require(script.Parent.Parent.Scene)
require(script.Parent.Types)
local v = {}
local v2 = {
	getSurfacePosition = function(p, vector2: Vector3)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { p.Boat }
		raycastParams.IgnoreWater = true
		raycastParams.RespectCanCollide = true
		local vector3 = Vector3.new(vector2.X, p.DeckY + 5, vector2.Z)
		local raycastResult = workspace:Raycast(vector3, createVector(-0, -40, -0), raycastParams)
		local v3

		if raycastResult then
			v3 = raycastResult.Position.Y + 0.03
		else
			v3 = p.DeckY
		end

		return (Vector3.new(vector2.X, v3, vector2.Z))
	end,
	calculateStandingCFrame = function(instance, vector2: Vector3, vector3: Vector3)
		local v3 = Scene.flattenedUnit(vector3) or createVector(0, 0, 1)
		instance:PivotTo(CFrame.lookAt(vector2, vector2 + v3))
		local boundingBox, v4 = instance:GetBoundingBox()
		local v5 = boundingBox.Position.Y - v4.Y * 0.5
		return instance:GetPivot() + createVector(0, 1, 0) * (vector2.Y - v5)
	end
}

function v.buildPathMetrics(list)
	local magnitudes = {}
	local total = 0

	for i = 1, #list - 1 do
		local magnitude = (list[i + 1] - list[i]).Magnitude
		table.insert(magnitudes, magnitude)
		total += magnitude
	end

	return magnitudes, total
end

function v2.createMarineEntrance(ship, instance, vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, vector6: Vector3, vector7: Vector3, startDelay: number, isFollower: boolean)
	local dot = (vector3 - vector2):Dot(vector7)
	local path = {
		vector3,
		v2.getSurfacePosition(ship, vector2 + vector6 * 10 + vector7 * dot),
		v2.getSurfacePosition(ship, vector2 + vector6 * 5 + vector7 * dot * 0.8),
		vector4
	}
	local pathMetrics, totalLength = v.buildPathMetrics(path)
	local v5 = path[2] - path[1]
	local standingCFrame = v2.calculateStandingCFrame(instance, path[1], v5)
	instance:PivotTo(standingCFrame)
	return {
		Ship = ship,
		Marine = instance,
		Path = path,
		SegmentLengths = pathMetrics,
		TotalLength = totalLength,
		StandingHeight = standingCFrame.Position.Y - path[1].Y,
		FinalFacing = vector5,
		StartDelay = startDelay,
		IsFollower = isFollower,
		CombatIdleTrack = nil
	}
end

function v2.createSubpath(data, path, vector2: Vector3)
	local pathMetrics, totalLength = v.buildPathMetrics(path)
	return {
		Ship = data.Ship,
		Marine = data.Marine,
		Path = path,
		SegmentLengths = pathMetrics,
		TotalLength = totalLength,
		StandingHeight = data.StandingHeight,
		FinalFacing = vector2,
		StartDelay = 0,
		IsFollower = data.IsFollower,
		CombatIdleTrack = data.CombatIdleTrack
	}
end

function v.sampleEntrance(data, value: number)
	local v3 = data.TotalLength * math.clamp(value, 0, 1)
	local v4 = 0

	for k, segmentLength in data.SegmentLengths do
		local v5 = v4 + segmentLength

		if v3 <= v5 or k == #data.SegmentLengths then
			local v6 = not (segmentLength > 0) and 1 or (v3 - v4) / segmentLength
			local v7 = data.Path[k]
			local v8 = data.Path[k + 1]
			return v7:Lerp(v8, (math.clamp(v6, 0, 1))), v8 - v7
		else
			v4 = v5
		end
	end

	return data.Path[#data.Path], data.FinalFacing
end

function v.getLowestMarineFootY(instance)
	local v3 = nil

	for _, childName in {
		"LeftFoot",
		"RightFoot",
		"Left Leg",
		"Right Leg"
	} do
		local part = instance:FindFirstChild(childName, true)

		if not (part and part:IsA("BasePart")) then
			continue
		end

		local v4 = math.abs(part.CFrame.RightVector.Y) * part.Size.X * 0.5 + math.abs(part.CFrame.UpVector.Y) * part.Size.Y * 0.5 + math.abs(part.CFrame.LookVector.Y) * part.Size.Z * 0.5
		local v5 = part.Position.Y - v4

		if v3 then
			v3 = math.min(v3, v5)
		else
			v3 = v5
		end
	end

	return v3
end

function v2.pivotMarineAtFeet(data, vector2: Vector3, vector3: Vector3)
	local v3 = Scene.flattenedUnit(vector3) or Scene.flattenedUnit(data.FinalFacing) or createVector(0, 0, 1)
	local v4 = vector2 + createVector(0, 1, 0) * data.StandingHeight
	data.Marine:PivotTo(CFrame.lookAt(v4, v4 + v3))
	local lowestMarineFootY = v.getLowestMarineFootY(data.Marine)

	if lowestMarineFootY then
		data.Marine:PivotTo(data.Marine:GetPivot() + createVector(0, 1, 0) * (vector2.Y - lowestMarineFootY))
	end
end

function v2.stopAnimationTrack(object)
	if object then
		pcall(function()
			object:Stop(0.12)
		end)
	end
end

function v2.animateEntrances(data, items, p: number)
	local v3 = {}
	local flag = false
	local v4 = false

	for _, item in items do
		local combatIdleTrack = CharacterPresentation.playCombatIdle(item.Marine)
		item.CombatIdleTrack = combatIdleTrack
		v4 = not combatIdleTrack or v4
		local v6 = CharacterPresentation.playRun(item.Marine)

		if v6 then
			v3[item] = v6
		else
			flag = true
		end
	end

	local currentDialogueBeat = data.currentDialogueBeat()
	local total = 0

	while total < p and data.canContinue(currentDialogueBeat) do
		total += RunService.Heartbeat:Wait()

		for _, item in items do
			local v5 = math.max(p - item.StartDelay, 0.01)
			local v6 = math.clamp((total - item.StartDelay) / v5, 0, 1)
			local entrance, v7 = v.sampleEntrance(item, v6)
			local surfacePosition = v2.getSurfacePosition(item.Ship, entrance)
			v2.pivotMarineAtFeet(item, surfacePosition, v7)
		end
	end

	if not data.isLive() then
		return false
	end

	for _, item in items do
		local v5 = item.Path[#item.Path]
		v2.pivotMarineAtFeet(item, v5, item.FinalFacing)
		v2.stopAnimationTrack(v3[item])
	end

	if flag then
		warn("[Lookout] A finale marine could not play NPC_Run during its boarding entrance")
	end

	if v4 then
		warn("[Lookout] A finale marine could not play the Dragon hybrid equipped idle")
	end

	return true
end

function v2.animateSubpath(data, data2, p: number, p2)
	local currentDialogueBeat = data.currentDialogueBeat()
	local total = 0

	while total < p and data.canContinue(currentDialogueBeat) do
		total += RunService.Heartbeat:Wait()
		local v3 = math.clamp(total / p, 0, 1)
		local entrance, v4 = v.sampleEntrance(data2, v3)
		local surfacePosition = v2.getSurfacePosition(data2.Ship, entrance)
		v2.pivotMarineAtFeet(data2, surfacePosition, v4)
	end

	v2.stopAnimationTrack(p2)

	if not data.isLive() then
		return false
	end

	v2.pivotMarineAtFeet(data2, data2.Path[#data2.Path], data2.FinalFacing)
	return true
end

function v2.animateHeadToward(data, instance, vector2: Vector3, p: number)
	local head = instance:FindFirstChild("Head", true)
	local neck = instance:FindFirstChild("Neck", true)

	if not (head and head:IsA("BasePart") and neck and neck:IsA("Motor6D") and neck.Part0) then
		return data.isLive()
	end

	local v3 = vector2 - head.Position

	if v3.Magnitude < 0.001 then
		return data.isLive()
	end

	local vectorToObjectSpace = neck.Part0.CFrame:VectorToObjectSpace(v3.Unit)
	local v4 = math.clamp(math.asin(vectorToObjectSpace.Y), -0.3490658503988659, 0.3490658503988659)
	local v5 = math.clamp(
		math.atan2(-vectorToObjectSpace.X, -vectorToObjectSpace.Z),
		-0.9599310885968813,
		0.9599310885968813
	)
	local C0 = neck.C0
	local C02 = CFrame.new(C0.Position) * CFrame.Angles(v4, v5, 0) * C0.Rotation
	local currentDialogueBeat = data.currentDialogueBeat()
	local total = 0

	while total < p and data.canContinue(currentDialogueBeat) do
		total += RunService.Heartbeat:Wait()
		local v7 = math.clamp(total / p, 0, 1)
		neck.C0 = C0:Lerp(C02, v7 * v7 * (3 - v7 * 2))
	end

	if not data.isLive() then
		return false
	end

	neck.C0 = C02
	return true
end

return table.freeze(v2)