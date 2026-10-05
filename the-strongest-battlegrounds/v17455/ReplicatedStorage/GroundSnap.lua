local createVector = vector.create
local Workspace = game:GetService("Workspace")
local GroundSnap = {}

local function _num(value, p)
	if type(value) == "number" and value == value then
		return value
	end

	return p
end

local function _collectIncludes(data)
	local v = {}
	local v2 = {}
	local workspace = type(data) == "table" and typeof(data.Workspace) == "Instance" and data.Workspace:IsA("Workspace") and data.Workspace or Workspace

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(instance)
		if typeof(instance) ~= "Instance" or v2[instance] then
			return
		end

		v2[instance] = true
		table.insert(v, instance)
	end

	local v3

	if type(data) == "table" then
		v3 = data.IncludeDefaults == false
	else
		v3 = false
	end

	if not v3 then
		local map = workspace:FindFirstChild("Map")

		if typeof(map) == "Instance" and not v2[map] then
			v2[map] = true
			table.insert(v, map)
		end

		local built = workspace:FindFirstChild("Built")

		if typeof(built) == "Instance" and not v2[built] then
			v2[built] = true
			table.insert(v, built)
		end
	end

	if type(data) ~= "table" then
		return v
	end

	if type(data.Include) == "table" then
		for _, v4 in ipairs(data.Include) do
			add(v4) -- equivalent call inferred; original call site unknown
		end
	end

	if typeof(data.IncludeMap) == "Instance" then
		local includeMap = data.IncludeMap

		if typeof(includeMap) == "Instance" and not v2[includeMap] then
			v2[includeMap] = true
			table.insert(v, includeMap)
		end
	end

	if typeof(data.IncludeBuilt) ~= "Instance" then
		return v
	end

	local includeBuilt = data.IncludeBuilt

	if typeof(includeBuilt) ~= "Instance" or v2[includeBuilt] then
		return v
	end

	v2[includeBuilt] = true
	table.insert(v, includeBuilt)
	return v
end

function GroundSnap.getDefaultFloorIncludes(workspace)
	return (_collectIncludes({
		Workspace = workspace,
		IncludeDefaults = true
	}))
end

function GroundSnap.buildFloorRaycastParams(p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.IgnoreWater = type(p) == "table" and p.IgnoreWater == true
	local filterDescendantsInstances = _collectIncludes(p)
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	return raycastParams, filterDescendantsInstances
end

function GroundSnap.raycastFloor(vector2: Vector3, data)
	if typeof(vector2) ~= "Vector3" then
		return nil, "invalid_world_pos", nil
	end

	local floorRaycastParams, v = GroundSnap.buildFloorRaycastParams(data)

	if #v == 0 then
		return nil, "no_include_targets", v
	end

	local castAbove

	if type(data) == "table" then
		castAbove = data.CastAbove
	else
		castAbove = false
	end

	local v3 = math.max(0, (type(castAbove) ~= "number" or castAbove ~= castAbove) and 8 or castAbove)
	local castBelow

	if type(data) == "table" then
		castBelow = data.CastBelow
	else
		castBelow = false
	end

	local v5 = math.max(0.1, (type(castBelow) ~= "number" or castBelow ~= castBelow) and 120 or castBelow)
	local v6 = vector2 + Vector3.new(0, v3, 0)
	local vector3 = Vector3.new(0, -(v3 + v5), 0)
	local raycastResult = (type(data) == "table" and typeof(data.Workspace) == "Instance" and data.Workspace:IsA("Workspace") and data.Workspace or Workspace):Raycast(
		v6,
		vector3,
		floorRaycastParams
	)

	if raycastResult then
		return raycastResult, "hit", v
	end

	return nil, "no_hit", v
end

function GroundSnap.snapPointToFloor(vector2: Vector3, data)
	local fallbackPosition

	if type(data) == "table" and typeof(data.FallbackPosition) == "Vector3" then
		fallbackPosition = data.FallbackPosition or vector2
	else
		fallbackPosition = vector2
	end

	local raycastFloor, reason, include = GroundSnap.raycastFloor(vector2, data)

	if not raycastFloor then
		return {
			Hit = false,
			Reason = reason,
			Position = fallbackPosition,
			DeltaY = (typeof(fallbackPosition) ~= "Vector3" or typeof(vector2) ~= "Vector3") and 0 or fallbackPosition.Y - vector2.Y or 0,
			Clamped = false,
			RaycastResult = nil,
			Include = include or {}
		}
	end

	local v3

	if type(data) == "table" then
		v3 = data.OnlyWhenAirborne == false
	else
		v3 = false
	end

	local airborneThreshold

	if type(data) == "table" then
		airborneThreshold = data.AirborneThreshold
	else
		airborneThreshold = false
	end

	local v6 = math.max(
		0,
		(type(airborneThreshold) ~= "number" or airborneThreshold ~= airborneThreshold) and 0.75 or airborneThreshold
	)
	local v7 = raycastFloor.Position.Y - vector2.Y

	if not v3 and math.abs(v7) <= v6 then
		return {
			Hit = true,
			Reason = "already_grounded",
			Position = vector2,
			DeltaY = 0,
			Clamped = false,
			RaycastResult = raycastFloor,
			Include = include,
			Airborne = false
		}
	end

	local surfaceOffset

	if type(data) == "table" then
		surfaceOffset = data.SurfaceOffset
	else
		surfaceOffset = false
	end

	local v8 = (type(surfaceOffset) ~= "number" or surfaceOffset ~= surfaceOffset) and 0 or surfaceOffset
	local v9

	if type(data) == "table" then
		v9 = data.OffsetAlongNormal == true
	else
		v9 = false
	end

	local vector3

	if v9 then
		vector3 = raycastFloor.Position + raycastFloor.Normal * v8
	else
		vector3 = Vector3.new(vector2.X, raycastFloor.Position.Y + v8, vector2.Z)
	end

	local clamped = false
	local reason2 = "hit"
	local maxSnapUp

	if type(data) == "table" then
		maxSnapUp = data.MaxSnapUp
	else
		maxSnapUp = false
	end

	if type(maxSnapUp) ~= "number" or maxSnapUp ~= maxSnapUp then
		maxSnapUp = nil
	end

	if type(maxSnapUp) == "number" and maxSnapUp >= 0 then
		local v12 = vector2.Y + maxSnapUp

		if v12 < vector3.Y then
			vector3 = Vector3.new(vector3.X, v12, vector3.Z)
			reason2 = "clamped_up"
			clamped = true
		end
	end

	local maxSnapDown

	if type(data) == "table" then
		maxSnapDown = data.MaxSnapDown
	else
		maxSnapDown = false
	end

	if type(maxSnapDown) ~= "number" or maxSnapDown ~= maxSnapDown then
		maxSnapDown = nil
	end

	if type(maxSnapDown) == "number" and maxSnapDown >= 0 then
		local v12 = vector2.Y - maxSnapDown

		if vector3.Y < v12 then
			vector3 = Vector3.new(vector3.X, v12, vector3.Z)
			reason2 = "clamped_down"
			clamped = true
		end
	end

	return {
		Hit = true,
		Reason = reason2,
		Position = vector3,
		DeltaY = vector3.Y - vector2.Y,
		Clamped = clamped,
		RaycastResult = raycastFloor,
		Include = include,
		Airborne = true
	}
end

function GroundSnap.snapCFrameToFloor(cframe: CFrame, p)
	if typeof(cframe) ~= "CFrame" then
		return nil, {
			Hit = false,
			Reason = "invalid_cframe",
			Position = nil,
			DeltaY = 0,
			Clamped = false,
			RaycastResult = nil,
			Include = {}
		}
	end

	local snapPointToFloor = GroundSnap.snapPointToFloor(cframe.Position, p)
	local v = cframe - cframe.Position
	return CFrame.new(snapPointToFloor.Position) * v, snapPointToFloor
end

function GroundSnap.snapOffsetPointToFloor(cframe: CFrame, vector2: Vector3, p)
	if typeof(cframe) ~= "CFrame" then
		return {
			Hit = false,
			Reason = "invalid_cframe",
			Position = nil,
			DeltaY = 0,
			Clamped = false,
			RaycastResult = nil,
			Include = {}
		}
	end

	local v = typeof(vector2) ~= "Vector3" and createVector(0, 0, 0) or vector2
	local position = (cframe * CFrame.new(v)).Position
	return GroundSnap.snapPointToFloor(position, p)
end

return GroundSnap