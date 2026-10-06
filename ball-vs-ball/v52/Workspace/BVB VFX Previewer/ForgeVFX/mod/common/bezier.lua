local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local module = require("../attributes")
local module2 = require("../shape")
local module3 = require("../tween")
local module4 = require("../utility")
local module5 = require("../color/Oklab")
local module6 = require("../../obj/Bezier")
local Bezier = {
	drawFuncMap = {
		Box = {
			Volume = module2.getPointWithinBox,
			Surface = module2.getPointOnBox
		},
		Cylinder = {
			Volume = function(p, p2, p3, p4, p5)
				return module2.getPointWithinCylinder(p, 0, p5, p2, p3, p4)
			end,
			Surface = function(p, p2, p3, p4, p5)
				return module2.getPointWithinCylinder(p, 1, p5, p2, p3, p4)
			end
		},
		Sphere = {
			Volume = function(p, p2, p3, p4, p5)
				return module2.getPointWithinSphere(p, 0, p5, p2, p3, p4)
			end,
			Surface = function(p, p2, p3, p4, p5)
				return module2.getPointWithinSphere(p, 1, p5, p2, p3, p4)
			end
		},
		Disc = {
			Volume = function(p, p2, p3, p4, p5)
				return module2.getPointWithinDisc(p, 0, p5, p2, p3, p4)
			end,
			Surface = function(p, p2, p3, p4, p5)
				return module2.getPointWithinDisc(p, 1, p5, p2, p3, p4)
			end
		}
	},
	getColorAtTime = function(sequence, p: number)
		local keypoints = sequence.Keypoints

		if p <= keypoints[1].Time then
			return keypoints[1].Value
		end

		if keypoints[#keypoints].Time <= p then
			return keypoints[#keypoints].Value
		end

		local v = nil
		local v2 = nil

		for i = 1, #keypoints do
			local keypoint = keypoints[i]

			if keypoint.Time == p then
				return keypoint.Value
			end

			if keypoint.Time < p then
				v = keypoint
			elseif p < keypoint.Time then
				v2 = keypoint
				break
			end
		end

		if v and v2 then
			local v3 = (p - v.Time) / (v2.Time - v.Time)
			return v.Value:Lerp(v2.Value, v3)
		else
			return keypoints[1].Value
		end
	end,
	getColorAtTimeOklab = function(sequence, p: number)
		local keypoints = sequence.Keypoints

		if p <= keypoints[1].Time then
			return keypoints[1].Value
		end

		if keypoints[#keypoints].Time <= p then
			return keypoints[#keypoints].Value
		end

		local v = nil
		local v2 = nil

		for i = 1, #keypoints do
			local keypoint = keypoints[i]

			if keypoint.Time == p then
				return keypoint.Value
			end

			if keypoint.Time < p then
				v = keypoint
			elseif p < keypoint.Time then
				v2 = keypoint
				break
			end
		end

		if v and v2 then
			local v3 = (p - v.Time) / (v2.Time - v.Time)
			local lerped = module5.fromSRGB(v.Value):Lerp(module5.fromSRGB(v2.Value), v3)
			return module5.toSRGB(lerped)
		else
			return keypoints[1].Value
		end
	end
}

function Bezier.getColorWithEasingOklab(p, value: number, object)
	local v = 1 - object:getEase((math.clamp(value, 0, 1))).y
	return Bezier.getColorAtTimeOklab(p, (math.clamp(v, 0, 1)))
end

function Bezier.createHitboxParams(data, p, instance)
	local overlapParams = OverlapParams.new()
	overlapParams.MaxParts = 1
	overlapParams.FilterType = Enum.RaycastFilterType[data.filterType]
	overlapParams.CollisionGroup = data.collisionGroup
	overlapParams.RespectCanCollide = not data.ignoreCanCollide
	overlapParams:AddToFilter(CollectionService:GetTagged(data.filterTag))

	if data.filterType == "Exclude" then
		local part = instance and instance:FindFirstAncestorOfClass("Part")
		overlapParams:AddToFilter({ workspace.Terrain, p, part })
	end

	return overlapParams
end

function Bezier.calculateEmissionCFrame(cframe: CFrame, vector2: Vector3, data, callback, object, p, flag: boolean)
	local v

	if flag then
		v = cframe * CFrame.new(createVector(0, 0, 0), Vector3.FromNormalId(data.emissionDirection)).Rotation
	elseif callback then
		v = callback(nil, cframe, vector2, data.emissionDirection, data.partial)
	else
		v = cframe
	end

	local vector3 = Vector3.FromNormalId(data.emissionDirection)
	local cross = vector3:Cross(cframe.LookVector)

	if cross.Magnitude < 0.001 then
		cross = vector3:Cross(cframe.UpVector)
	end

	local v2 = v * (CFrame.fromAxisAngle(
		vector3,
		(math.rad((object:NextNumber(-data.spreadAngle.X, data.spreadAngle.X))))
	) * CFrame.fromAxisAngle(cross, (math.rad((object:NextNumber(-data.spreadAngle.Y, data.spreadAngle.Y))))))

	if data.face == "Inward" or data.face == "InAndOut" and object:NextInteger(0, 1) == 1 then
		v2 *= CFrame.fromOrientation(0, 3.141592653589793, 0)
	end

	if p and data.mirror and (v2.Position - p.WorldPosition).Unit:Dot(v2.RightVector) >= 0 then
		local v3 = data.mirrorRot * module4.DEG_TO_RAD
		return v2 * CFrame.fromOrientation(v3.X, v3.Y, v3.Z)
	end

	return v2
end

function Bezier.createBezierWithEndpoint(list, cframe: CFrame, p, p2)
	if not p then
		return module6.new(list)
	end

	local worldPositions = {}

	for k, v in list do
		local worldPosition

		if k == #list - 1 then
			worldPosition = p2 and p2.WorldPosition or p.WorldPosition
		elseif k == #list then
			worldPosition = p.WorldPosition
		else
			worldPosition = cframe * (v - list[1])
		end

		table.insert(worldPositions, worldPosition)
	end

	return module6.new(worldPositions)
end

function Bezier.createPosGetter(object, list, cframe: CFrame, p, flag: boolean?)
	return function(p2: number)
		local selected

		if flag == false then
			selected = object:getPosition(p2)
		else
			selected = object:getPositionArcSpace(p2)
		end

		if p then
			return selected
		end

		return cframe * (selected - list[1])
	end
end

function Bezier.readCommonAttributes(p)
	return {
		emitDelay = module.get(p, "EmitDelay", 0),
		emitCount = module.get(p, "EmitCount", 1),
		emitDuration = module.get(p, "EmitDuration", 0),
		destroyDelay = module.get(p, "DestroyDelay", 0),
		duration = module.getRange(p, "Duration", NumberRange.new(1, 1), NumberRange.new(0, 1e999)),
		shapeType = module.getEnum(p, "Shape", "Box", {
			"Box",
			"Cylinder",
			"Sphere",
			"Disc"
		}),
		shapeStyle = module.getEnum(p, "ShapeStyle", "Volume", { "Volume", "Surface" }),
		emissionDirection = Enum.NormalId[module.getEnum(p, "EmissionDirection", "Top", {
			"Top",
			"Bottom",
			"Left",
			"Right",
			"Front",
			"Back"
		})],
		face = module.getEnum(p, "ShapeFace", "Outward", { "InAndOut", "Inward", "Outward" }),
		spreadAngle = module.get(p, "SpreadAngle", createVector(0, 0, 0)),
		partial = module.get(p, "ShapePartial", 1),
		syncPosition = module.get(p, "SyncPosition", false),
		mirror = module.get(p, "MirrorPaths", true),
		mirrorRot = module.get(p, "MirrorRotation", createVector(0, 0, 180)),
		projectileEnabled = module.get(p, "ProjectileEnabled", false),
		projectileMatchEnd = module.get(p, "MatchEndDirection", false),
		projectileSpeed = module.get(p, "ProjectileSpeed", 30),
		projectileLifetime = module.getRange(p, "ProjectileLifetime", NumberRange.new(1, 1), NumberRange.new(0, 1e999)),
		hitboxEnabled = module.get(p, "HitboxEnabled", false),
		hitboxCollisionGroup = module.get(p, "HitboxCollisionGroup", "Default"),
		hitboxFilterTag = module.get(p, "HitboxFilterTag", ""),
		hitboxFilterType = module.get(p, "HitboxFilterType", "Exclude"),
		hitboxIgnoreCanCollide = module.get(p, "HitboxIgnoreCanCollide", false),
		speedStart = module.get(p, "Speed_Start", 1),
		speedEnd = module.get(p, "Speed_End", 1)
	}
end

function Bezier.getCurrentOriginCFrame(instance, cframe: CFrame)
	if instance:IsA("BasePart") then
		return instance.CFrame
	end

	if instance:IsA("Attachment") then
		return instance.WorldCFrame
	end

	return cframe
end

function Bezier.findEndAttachments(instance)
	local attachment = instance:FindFirstChild("End")
	local T1 = attachment and attachment:FindFirstChild("T1")

	if attachment and not attachment:IsA("Attachment") then
		attachment = nil
	end

	if T1 and not T1:IsA("Attachment") then
		T1 = nil
	end

	return attachment, T1
end

function Bezier.validateParent(p)
	local parent = p.Parent

	if not parent then
		return nil
	end

	if not parent:IsA("BasePart") and not parent:IsA("Attachment") then
		parent = p
	end

	return parent
end

function Bezier.getPerpendicularVectors(vector2: Vector3)
	local cross = vector2:Cross(createVector(0, 1, 0))

	if cross.Magnitude < 0.001 then
		cross = vector2:Cross(createVector(0, 0, 1))
	end

	local unit = cross.Unit
	return unit, vector2:Cross(unit).Unit
end

function Bezier.createPropertyTween(list, p, p2: string, p3: number, p4: number, p5: number, callback, callback2, p6)
	if p4 == p5 then
		return
	end

	table.insert(list, module3.fromParams(module.get(p, p2 .. "_Curve", module4.default_bezier), p3, function(p7, p8)
		callback(module4.lerp(p4, p5, p7))
		return p8 * callback2()
	end, p6))
end

return Bezier