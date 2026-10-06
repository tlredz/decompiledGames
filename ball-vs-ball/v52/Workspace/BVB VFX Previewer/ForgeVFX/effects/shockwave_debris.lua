local createVector = vector.create
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local module = require("../mod/attributes")
local module2 = require("../mod/tween")
require("../types")
local module3 = require("../mod/utility")
local module4 = require("../pkg/Promise")
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

	if module3.PLUGIN_CONTEXT then
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

	local inheritanceEnabled = module.get(instance, "InheritanceEnabled", true)
	local inheritanceRadius = module.get(instance, "InheritanceRadius", 5)
	local collisionGroup = module.get(p, "RayCollisionGroup", "Default")
	local v3 = module.get(p, "FilterTag", "")
	local v4 = module.get(p, "FilterType", "Exclude")
	local ignoreCanCollide = module.get(p, "IgnoreCanCollide", false)
	local overlapParams

	if inheritanceEnabled then
		local inheritanceMaxResults = module.get(instance, "InheritanceMaxResults", 5)
		overlapParams = OverlapParams.new()
		overlapParams.MaxParts = inheritanceMaxResults
		overlapParams.CollisionGroup = collisionGroup
		overlapParams.RespectCanCollide = not ignoreCanCollide
		overlapParams.FilterType = Enum.RaycastFilterType[v4]
		overlapParams.FilterDescendantsInstances = CollectionService:GetTagged(v3)

		if v4 == "Exclude" then
			overlapParams:AddToFilter({ workspace.Terrain })
		end
	end

	local emitDelay = module.get(instance, "EmitDelay", 0)
	local range = module.getRange(instance, "Amount", NumberRange.new(5, 10), NumberRange.new(0, 1e999))
	local range2 = module.getRange(instance, "Lifetime", NumberRange.new(2, 3), NumberRange.new(0, 1e999))
	local range3 = module.getRange(instance, "Airtime", NumberRange.new(0.5, 0.5), NumberRange.new(0, 1e999))
	local range4 = module.getRange(instance, "LinearMagnitude", NumberRange.new(15, 25))
	local range5 = module.getRange(instance, "AngularMagnitude", NumberRange.new(5, 15))
	local sizeScaleEnd = module.get(instance, "SizeScaleEnd", createVector(0, 0, 0))
	local minSize = module.get(instance, "MinSize", createVector(2, 1, 2))
	local maxSize = module.get(instance, "MaxSize", createVector(3, 2, 3))
	local minDirection = module.get(instance, "MinDirection", createVector(-1, -1, -1))
	local maxDirection = module.get(instance, "MaxDirection", createVector(1, 1, 1))
	local integer = random:NextInteger(range.Min, range.Max)
	local sizeCurve = module.get(instance, "Size_Curve", module3.default_bezier)
	local transparencyCurve = module.get(instance, "Transparency_Curve", module3.default_bezier)
	local transparencyDuration = module.get(instance, "Transparency_Duration", 0.5)
	local sizeDuration = module.get(instance, "Size_Duration", 0.5)
	local transparencyStart = module.get(instance, "Transparency_Start", 0)
	local transparencyEnd = module.get(instance, "Transparency_End", 1)
	local v5 = {}
	local finisheds = {}
	instance.CanCollide = false
	local transformedOriginExtents = module3.getTransformedOriginExtents(p)
	local position = transformedOriginExtents.Position

	if overlapParams then
		local partBoundsInRadius = workspace:GetPartBoundsInRadius(position, inheritanceRadius, overlapParams)

		for _, v6 in partBoundsInRadius do
			if v6.Transparency ~= 1 then
				table.insert(v5, v6)
			end
		end
	end

	task.wait(emitDelay)

	for _ = 1, integer do
		local v6

		if #v5 == 0 then
			v6 = false
		else
			v6 = v5[random:NextInteger(1, #v5)]
		end

		local randomId = module3.getRandomId()
		local v7 = v:get(randomId)
		local _getReal = v7._getReal()
		module3.copyProperties(instance, _getReal, module3.COPY_PART_PROPERTIES)
		module3.copyProperties(instance, _getReal, module3.COPY_EXTENDED_PART_PROPERTIES)

		if #instance:GetChildren() ~= 0 then
			local clone = instance:Clone()

			for _, child in clone:GetChildren() do
				child.Parent = _getReal
			end

			clone:Destroy()
		end

		local v8 = list.effects.prepareEmitOnFinish(_getReal, list)
		local v9 = list.effects.prepareEmitFolder(_getReal, "EmitOnImpact", list)

		if v9 and #v9:GetChildren() > 0 then
			local touchedConnection = nil
			local parent = _getReal
			local v11 = v9
			touchedConnection = _getReal.Touched:Connect(function(otherPart)
				if not (ignoreCanCollide or otherPart:CanCollideWith(parent)) or otherPart:IsDescendantOf(workspace.Terrain) or v4 == "Exclude" and otherPart:HasTag(v3) then
					return
				end

				touchedConnection:Disconnect()
				local v12 = list.effects.emitFromFolder(v11, parent, list.depth + 1, list)
				table.insert(finisheds, v12.Finished)
			end)
			table.insert(list, function()
				if touchedConnection then
					touchedConnection:Disconnect()
					touchedConnection = nil
				end
			end)
		end

		v7.Anchored = false
		v7.CanCollide = true

		if v7.CollisionGroup == "Default" then
			v7.CollisionGroup = "ForgeDebris"
		end

		v7.CFrame = CFrame.new(position)
		local vector2 = Vector3.new(
			random:NextNumber(minSize.X, maxSize.X),
			random:NextNumber(minSize.Y, maxSize.Y),
			random:NextNumber(minSize.Z, maxSize.Z)
		)
		v7.Size = vector2

		if v6 then
			v7.Material = v6.Material
			v7.Color = v6.Color
			v7.Transparency = v6.Transparency
		else
			v7.Transparency = transparencyStart
		end

		table.insert(list, function()
			local index = table.find(_getReals, _getReal)

			if index then
				table.remove(_getReals, index)
			end

			if v then
				v:free(randomId)
			end
		end)
		table.insert(_getReals, _getReal)
		v7.AssemblyLinearVelocity = transformedOriginExtents:VectorToWorldSpace(v7.AssemblyLinearVelocity)
		local vectorToWorldSpace = transformedOriginExtents:VectorToWorldSpace((module3.randomUnitVector(
			minDirection,
			maxDirection
		)))
		v7:ApplyImpulse(v7.AssemblyMass * module3.getImpulseForce(
			position,
			position + vectorToWorldSpace.Unit * random:NextNumber(range4.Min, range4.Max),
			random:NextNumber(range3.Min, range3.Max)
		))
		v7:ApplyAngularImpulse(v7.AssemblyMass * random:NextUnitVector() * random:NextNumber(range5.Min, range5.Max))
		table.insert(finisheds, list.effects.emitNested(_getReal, list.depth + 1, list).Finished)
		local parent2 = _getReal
		task.delay(random:NextNumber(range2.Min, range2.Max), function()
			local size = v7.Size
			local transparency = v7.Transparency

			if size ~= vector2 * sizeScaleEnd then
				table.insert(list, module2.fromParams(sizeCurve, sizeDuration, function(p2, p3)
					v7.Size = size:Lerp(vector2 * sizeScaleEnd, p2)
					return p3
				end))
			end

			if transparency ~= transparencyEnd then
				table.insert(list, module2.fromParams(transparencyCurve, transparencyDuration, function(p2, p3)
					v7.Transparency = module3.lerp(transparency, transparencyEnd, p2)
					return p3
				end))
			end

			local v16 = list.effects.emitOnFinish(v8, parent2, list.depth + 1, list)
			table.insert(finisheds, v16.Finished)
		end)
	end

	task.wait(range2.Max + math.max(transparencyDuration, sizeDuration))
	module4.all(finisheds):await()
end

return ShockwaveDebris