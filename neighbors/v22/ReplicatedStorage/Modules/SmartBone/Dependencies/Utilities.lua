local createVector = vector.create
local HttpService = game:GetService("HttpService")
local Config = require(script.Parent:WaitForChild("Config"))
local DefaultObjectSettings = require(script.Parent:WaitForChild("DefaultObjectSettings"))
local v = {
	Block = "Box",
	Ball = "Sphere",
	Capsule = "Capsule",
	Sphere = "Sphere",
	Box = "Box",
	Cylinder = "Cylinder"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function YAxisSafeUnit(cross: Vector3)
	if cross.Magnitude <= 1e-6 then
		return createVector(-0, -1, -0)
	end

	return cross.Unit
end

local Utilities = {
	LogIndent = 0,
	GetRotationBetween = function(vector2: Vector3, vector3: Vector3)
		local dot = vector2:Dot(vector3)
		local magnitude = vector2:Cross(vector3).Magnitude
		local v2 = math.atan2(magnitude, dot)
		local yAxisSafeUnit = YAxisSafeUnit(vector2:Cross(vector3)) -- equivalent call inferred; original call site unknown

		if not (magnitude < 1e-6) then
			return CFrame.fromAxisAngle(yAxisSafeUnit, v2)
		end

		if dot > 0 then
			return CFrame.new()
		end

		local vector4 = math.abs(vector2.X) > math.abs(vector2.Z) and Vector3.new(-vector2.Y, vector2.X, 0) or Vector3.new(
			0,
			-vector2.Z,
			vector2.Y
		)
		return CFrame.fromAxisAngle(vector4.Unit, 3.141592653589793)
	end,
	GetCFrameAxis = function(cframe: CFrame, p: string)
		local eulerAnglesXYZ, v2, v3 = cframe:ToEulerAnglesXYZ()

		if p == "X" then
			return eulerAnglesXYZ
		elseif p == "Y" then
			return v2
		elseif p == "Z" then
			return v3
		end

		return nil
	end,
	GatherObjectSettings = function(instance)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function Expect(attribute, typeName: string, attributeName: string)
			if typeof(attribute) == typeName then
				return true
			end

			warn((`[SmartBone][Object] Expected attribute {attributeName} on {instance.Name} to be of type {typeName}, got type {typeof(attribute)}`))
			return false
		end

		local result = {}

		for attributeName, defaultObjectSetting in DefaultObjectSettings do
			local attribute = instance:GetAttribute(attributeName)

			if attribute ~= nil then
				-- equivalent call inferred; original call site unknown
				if not Expect(attribute, typeof(defaultObjectSetting), attributeName) then
					attribute = nil
				end
			end

			result[attributeName] = attribute == nil and defaultObjectSetting or attribute
		end

		return result
	end,
	GatherBoneSettings = function(instance)
		local function Attrib(attributeName: string)
			return instance:GetAttribute(attributeName)
		end

		local function Expect(p, p2: string, p3: string)
			if typeof(p) ~= p2 then
				warn((`[SmartBone][Bone] Expected attribute {p3} on {instance.Name} to be of type {p2}, got type {typeof(p)}`))
			end
		end

		local xAxisLocked = instance:GetAttribute("XAxisLocked") or false
		local yAxisLocked = instance:GetAttribute("YAxisLocked") or false
		local zAxisLocked = instance:GetAttribute("ZAxisLocked") or false
		local xAxisLimits = instance:GetAttribute("XAxisLimits") or NumberRange.new(-1e999, 1e999)
		local yAxisLimits = instance:GetAttribute("YAxisLimits") or NumberRange.new(-1e999, 1e999)
		local zAxisLimits = instance:GetAttribute("ZAxisLimits") or NumberRange.new(-1e999, 1e999)
		local radius = instance:GetAttribute("Radius") or 0.25
		local rotationLimit = instance:GetAttribute("RotationLimit") or 180
		local force = instance:GetAttribute("Force") or "¬"
		local gravity = instance:GetAttribute("Gravity") or "¬"

		if typeof(xAxisLocked) ~= "boolean" then
			warn((`[SmartBone][Bone] Expected attribute XAxisLocked on {instance.Name} to be of type boolean, got type {typeof(xAxisLocked)}`))
		end

		if typeof(yAxisLocked) ~= "boolean" then
			warn((`[SmartBone][Bone] Expected attribute YAxisLocked on {instance.Name} to be of type boolean, got type {typeof(yAxisLocked)}`))
		end

		if typeof(zAxisLocked) ~= "boolean" then
			warn((`[SmartBone][Bone] Expected attribute ZAxisLocked on {instance.Name} to be of type boolean, got type {typeof(zAxisLocked)}`))
		end

		if typeof(xAxisLimits) ~= "NumberRange" then
			warn((`[SmartBone][Bone] Expected attribute XAxisLimits on {instance.Name} to be of type NumberRange, got type {typeof(xAxisLimits)}`))
		end

		if typeof(yAxisLimits) ~= "NumberRange" then
			warn((`[SmartBone][Bone] Expected attribute YAxisLimits on {instance.Name} to be of type NumberRange, got type {typeof(yAxisLimits)}`))
		end

		if typeof(zAxisLimits) ~= "NumberRange" then
			warn((`[SmartBone][Bone] Expected attribute ZAxisLimits on {instance.Name} to be of type NumberRange, got type {typeof(zAxisLimits)}`))
		end

		if typeof(radius) ~= "number" then
			warn((`[SmartBone][Bone] Expected attribute Radius on {instance.Name} to be of type number, got type {typeof(radius)}`))
		end

		if typeof(rotationLimit) ~= "number" then
			warn((`[SmartBone][Bone] Expected attribute RotationLimit on {instance.Name} to be of type number, got type {typeof(rotationLimit)}`))
		end

		if force ~= "¬" and typeof(force) ~= "Vector3" then
			warn((`[SmartBone][Bone] Expected attribute Force on {instance.Name} to be of type Vector3, got type {typeof(force)}`))
		end

		if force ~= "¬" and typeof(gravity) ~= "Vector3" then
			warn((`[SmartBone][Bone] Expected attribute Gravity on {instance.Name} to be of type Vector3, got type {typeof(gravity)}`))
		end

		return {
			AxisLocked = { xAxisLocked, yAxisLocked, zAxisLocked },
			XAxisLimits = xAxisLimits,
			YAxisLimits = yAxisLimits,
			ZAxisLimits = zAxisLimits,
			RotationLimit = rotationLimit,
			Radius = radius,
			Force = force,
			Gravity = gravity
		}
	end,
	ClosestPointOnLine = function(vector2: Vector3, vector3: Vector3, max: number, vector4: Vector3)
		return vector2 + vector3 * math.clamp((vector4 - vector2):Dot(vector3), -max, max)
	end,
	ClosestPointInBox = function(cframe: CFrame, vector2: Vector3, vector3: Vector3)
		local pointToObjectSpace = cframe:PointToObjectSpace(vector3)
		local X = vector2.X
		local X2 = vector2.X
		local Z = vector2.Z
		local X3 = pointToObjectSpace.X
		local Y = pointToObjectSpace.Y
		local Z2 = pointToObjectSpace.Z

		if pointToObjectSpace ~= pointToObjectSpace or vector2 ~= vector2 then
			return false, cframe.Position, createVector(0, 1, 0)
		end

		local v2 = math.clamp(X3, -X * 0.5, X * 0.5)
		local v3 = math.clamp(Y, -X2 * 0.5, X2 * 0.5)
		local v4 = math.clamp(Z2, -Z * 0.5, Z * 0.5)

		if v2 ~= X3 or v3 ~= Y or v4 ~= Z2 then
			local v5 = cframe * Vector3.new(v2, v3, v4)
			return false, v5, (vector3 - v5).unit
		end

		local v5 = X3 - X * 0.5
		local v6 = Y - X2 * 0.5
		local v7 = Z2 - Z * 0.5
		local v8 = -X3 - X * 0.5
		local v9 = -Y - X2 * 0.5
		local v10 = -Z2 - Z * 0.5
		local v11 = math.max(v5, v6, v7, v8, v9, v10)

		if v11 == v5 then
			return true, cframe * Vector3.new(X * 0.5, Y, Z2), cframe.XVector
		end

		if v11 == v6 then
			return true, cframe * Vector3.new(X3, X2 * 0.5, Z2), cframe.YVector
		end

		if v11 == v7 then
			return true, cframe * Vector3.new(X3, Y, Z * 0.5), cframe.ZVector
		end

		if v11 == v8 then
			return true, cframe * Vector3.new(-X * 0.5, Y, Z2), -cframe.XVector
		end

		if v11 == v9 then
			return true, cframe * Vector3.new(X3, -X2 * 0.5, Z2), -cframe.YVector
		end

		if v11 == v10 then
			return true, cframe * Vector3.new(X3, Y, -Z * 0.5), -cframe.ZVector
		end

		warn("CLOSEST POINT ON BOX FAIL")
		return false, createVector(0, 0, 0), createVector(0, 1, 0)
	end,
	GetCollider = function(part)
		local selfCollider = part:FindFirstChild("self.Collider")
		local v2

		if selfCollider and selfCollider:IsA("ModuleScript") then
			local module = require(selfCollider)
			local v3 = nil
			pcall(function()
				v3 = HttpService:JSONDecode(module)
			end)
			v2 = v3
		end

		if v2 then
			return v2
		end

		local function GetShapeName(part2)
			local colliderShape = part2:GetAttribute("ColliderShape")

			if colliderShape then
				return colliderShape
			end

			if part2:IsA("Part") then
				return part2.Shape.Name
			end

			return "Box"
		end

		return {
			{
				Type = v[part:GetAttribute("ColliderShape") or not part:IsA("Part") and "Box" or part.Shape.Name] or "Box",
				ScaleX = 1,
				ScaleY = 1,
				ScaleZ = 1,
				OffsetX = 0,
				OffsetY = 0,
				OffsetZ = 0,
				RotationX = 0,
				RotationY = 0,
				RotationZ = 0
			}
		}
	end
}

function Utilities.SB_INDENT_LOG()
	Utilities.LogIndent += 1
end

function Utilities.SB_UNINDENT_LOG()
	Utilities.LogIndent -= 1
	Utilities.LogIndent = math.max(Utilities.LogIndent, 0)
end

function Utilities.SB_ASSERT_CB(p, callback, ...)
	if p == false or p == nil then
		callback(...)
	end
end

function Utilities.SB_VERBOSE_LOG(p: string)
	if not Config.LOG_VERBOSE then
		return
	end

	local v2 = string.rep("    ", Utilities.LogIndent)
	print((`{v2}[SmartBone][Log]: {p}`))
end

function Utilities.SB_VERBOSE_WARN(p: string)
	if not Config.LOG_VERBOSE then
		return
	end

	local v2 = string.rep("    ", Utilities.LogIndent)
	warn((`{v2}[SmartBone][Warn]: {p}`))
end

function Utilities.SB_VERBOSE_ERROR(p: string)
	if not Config.LOG_VERBOSE then
		return
	end

	local v2 = string.rep("    ", Utilities.LogIndent)
	error((`{v2}[SmartBone][Error]: {p}`))
end

return Utilities