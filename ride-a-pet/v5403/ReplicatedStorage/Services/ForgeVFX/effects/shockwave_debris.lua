local createVector = vector.create
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local module = require("../mod/tween")
local module2 = require("../mod/utility")
local module3 = require("../pkg/Promise")
require("../obj/ObjectCache")
local random = Random.new()
local _getReals = {}
local v = nil
local renderSteppedConnection = nil
local ShockwaveDebris = {}

function ShockwaveDebris.init(p)
	if renderSteppedConnection then
		return
	end

	v = p

	if RunService:IsStudio() and script:FindFirstAncestorOfClass("Plugin") then
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if #_getReals == 0 then
				return
			end

			workspace:StepPhysics(dt, _getReals)
		end)
	end
end

function ShockwaveDebris.deinit()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v = nil

	for _, v2 in _getReals do
		v2:Destroy()
	end

	table.clear(_getReals)
end

function ShockwaveDebris.emit(p, instance, list)
	if not v then
		return
	end

	local attribute = module2.getAttribute(instance, "InheritanceEnabled", true)
	local attribute2 = module2.getAttribute(instance, "InheritanceRadius", 5)
	local overlapParams

	if attribute then
		local attribute3 = module2.getAttribute(instance, "InheritanceMaxResults", 5)
		local attribute4 = module2.getAttribute(p, "RayCollisionGroup", "Default")
		local attribute5 = module2.getAttribute(p, "FilterTag", "")
		local attribute6 = module2.getAttribute(p, "FilterType", "Exclude")
		local attribute7 = module2.getAttribute(p, "IgnoreCanCollide", false)
		overlapParams = OverlapParams.new()
		overlapParams.MaxParts = attribute3
		overlapParams.CollisionGroup = attribute4
		overlapParams.RespectCanCollide = not attribute7
		overlapParams.FilterType = Enum.RaycastFilterType[attribute6]
		overlapParams.FilterDescendantsInstances = CollectionService:GetTagged(attribute5)

		if attribute6 == "Exclude" then
			overlapParams:AddToFilter({ workspace.Terrain })
		end
	end

	local attribute3 = module2.getAttribute(instance, "EmitDelay", 0)
	local rangeAttribute = module2.getRangeAttribute(
		instance,
		"Amount",
		NumberRange.new(5, 10),
		NumberRange.new(0, 1e999)
	)
	local rangeAttribute2 = module2.getRangeAttribute(
		instance,
		"Lifetime",
		NumberRange.new(2, 3),
		NumberRange.new(0, 1e999)
	)
	local rangeAttribute3 = module2.getRangeAttribute(
		instance,
		"Airtime",
		NumberRange.new(0.5, 0.5),
		NumberRange.new(0, 1e999)
	)
	local rangeAttribute4 = module2.getRangeAttribute(instance, "LinearMagnitude", NumberRange.new(15, 25))
	local rangeAttribute5 = module2.getRangeAttribute(instance, "AngularMagnitude", NumberRange.new(5, 15))
	local attribute4 = module2.getAttribute(instance, "SizeScaleEnd", createVector(0, 0, 0))
	local attribute5 = module2.getAttribute(instance, "MinSize", createVector(2, 1, 2))
	local attribute6 = module2.getAttribute(instance, "MaxSize", createVector(3, 2, 3))
	local attribute7 = module2.getAttribute(instance, "MinDirection", createVector(-1, -1, -1))
	local attribute8 = module2.getAttribute(instance, "MaxDirection", createVector(1, 1, 1))
	local integer = random:NextInteger(rangeAttribute.Min, rangeAttribute.Max)
	local attribute9 = module2.getAttribute(instance, "Size_Curve", module2.default_bezier)
	local attribute10 = module2.getAttribute(instance, "Transparency_Curve", module2.default_bezier)
	local attribute11 = module2.getAttribute(instance, "Transparency_Duration", 0.5)
	local attribute12 = module2.getAttribute(instance, "Size_Duration", 0.5)
	local attribute13 = module2.getAttribute(instance, "Transparency_Start", 0)
	local attribute14 = module2.getAttribute(instance, "Transparency_End", 1)
	local v2 = {}
	local finisheds = {}
	instance.CanCollide = false

	if overlapParams then
		local partBoundsInRadius = workspace:GetPartBoundsInRadius(p.WorldPosition, attribute2, overlapParams)

		for _, v3 in partBoundsInRadius do
			if v3.Transparency ~= 1 then
				table.insert(v2, v3)
			end
		end
	end

	task.wait(attribute3)

	for _ = 1, integer do
		local v3

		if #v2 == 0 then
			v3 = false
		else
			v3 = v2[random:NextInteger(1, #v2)]
		end

		local ranomId = module2.getRanomId()
		local v4 = v:get(ranomId)
		local _getReal = v4._getReal()
		module2.copyProperties(instance, _getReal, module2.COPY_PART_PROPERTIES)
		module2.copyProperties(instance, _getReal, module2.COPY_EXTENDED_PART_PROPERTIES)

		if #instance:GetChildren() ~= 0 then
			local clone = instance:Clone()

			for _, child in clone:GetChildren() do
				child.Parent = _getReal
			end

			clone:Destroy()
		end

		v4.Anchored = false
		v4.CanCollide = true
		v4.Transparency = attribute13

		if v4.CollisionGroup == "Default" then
			v4.CollisionGroup = "ForgeDebris"
		end

		v4.CFrame = CFrame.new(p.WorldPosition)
		local vector2 = Vector3.new(
			random:NextNumber(attribute5.X, attribute6.X),
			random:NextNumber(attribute5.Y, attribute6.Y),
			random:NextNumber(attribute5.Z, attribute6.Z)
		)
		v4.Size = vector2

		if v3 then
			v4.Material = v3.Material
			v4.Color = v3.Color
			v4.Transparency = v3.Transparency
		end

		table.insert(list, function()
			local index = table.find(_getReals, _getReal)

			if index then
				table.remove(_getReals, index)
			end

			if v then
				v:free(ranomId)
			end
		end)
		table.insert(_getReals, _getReal)
		v4.AssemblyLinearVelocity = p.WorldCFrame:VectorToWorldSpace(v4.AssemblyLinearVelocity)
		local randomUnitVector = module2.randomUnitVector(attribute7, attribute8)
		local vectorToWorldSpace = p.WorldCFrame:VectorToWorldSpace(randomUnitVector)
		v4:ApplyImpulse(v4.AssemblyMass * module2.getImpulseForce(
			p.WorldPosition,
			p.WorldPosition + vectorToWorldSpace.Unit * random:NextNumber(rangeAttribute4.Min, rangeAttribute4.Max),
			random:NextNumber(rangeAttribute3.Min, rangeAttribute3.Max)
		))
		v4:ApplyAngularImpulse(v4.AssemblyMass * random:NextUnitVector() * random:NextNumber(
			rangeAttribute5.Min,
			rangeAttribute5.Max
		))

		if shared.vfx and #v4:GetChildren() ~= 0 then
			table.insert(finisheds, shared.vfx.emit(v4).Finished)
		end

		task.delay(random:NextNumber(rangeAttribute2.Min, rangeAttribute2.Max), function()
			local size = v4.Size

			if size ~= vector2 * attribute4 then
				table.insert(list, module.fromParams(attribute9, attribute12, function(p2, p3)
					v4.Size = size:Lerp(vector2 * attribute4, p2)
					return p3
				end))
			end

			if attribute13 == attribute14 then
				v4.Transparency = attribute13
			else
				table.insert(list, module.fromParams(attribute10, attribute11, function(p2, p3)
					v4.Transparency = module2.lerp(attribute13, attribute14, p2)
					return p3
				end))
			end
		end)
	end

	task.wait(rangeAttribute2.Max + math.max(attribute11, attribute12))
	module3.all(finisheds):await()
end

return ShockwaveDebris