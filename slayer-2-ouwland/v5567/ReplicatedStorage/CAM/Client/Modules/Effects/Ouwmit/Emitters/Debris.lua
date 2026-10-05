local createVector = vector.create
local utilities = script.Parent.Parent.Utilities
local OuwmitUtility = require(utilities.OuwmitUtility)
require(utilities.Types)
local Tween = require(utilities.Tween)
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

if not PhysicsService:IsCollisionGroupRegistered("ForgeDebris") then
	warn([[
Be sure to create a collision group for Forge debris using the code
PhysicsService:RegisterCollisionGroup("ForgeDebris")
PhysicsService:CollisionGroupSetCollidable("ForgeDebris", "ForgeDebris", false)]])
end

local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function getDebreeParent()
	return workspace:FindFirstChild("Debree") or workspace.Terrain
end

local originCFrame = OuwmitUtility.OriginCFrame

local function firstWhitelisted(instance, colorWhitelist)
	if colorWhitelist == nil then
		return nil
	end

	if typeof(colorWhitelist) == "table" then
		for _, childName in ipairs(colorWhitelist) do
			local child

			if typeof(childName) == "string" then
				child = instance:FindFirstChild(childName, true)
			end

			if child ~= nil then
				return child
			end
		end

		return nil
	elseif typeof(colorWhitelist) == "string" then
		return (instance:FindFirstChild(colorWhitelist, true))
	else
		return nil
	end
end

return function(instance, instance2, data, callback)
	if instance == nil or instance2 == nil then
		return
	end

	local attribute = OuwmitUtility.GetAttribute(instance2, "InheritanceEnabled", true)
	local attribute2 = OuwmitUtility.GetAttribute(instance2, "InheritanceRadius", 5)
	local attribute3 = OuwmitUtility.GetAttribute(instance, "FilterTag", "")
	local attribute4 = OuwmitUtility.GetAttribute(instance, "FilterType", "Exclude")
	local attribute5 = OuwmitUtility.GetAttribute(instance, "IgnoreCanCollide", false)
	local overlapParams

	if attribute then
		local attribute6 = OuwmitUtility.GetAttribute(instance2, "InheritanceMaxResults", 5)
		local attribute7 = OuwmitUtility.GetAttribute(instance, "RayCollisionGroup", "Default")
		overlapParams = OverlapParams.new()
		overlapParams.MaxParts = attribute6
		overlapParams.CollisionGroup = attribute7
		overlapParams.RespectCanCollide = not attribute5

		if attribute3 == "" then
			overlapParams.FilterType = Enum.RaycastFilterType.Include
			overlapParams.FilterDescendantsInstances = RaycastHelper.Crater.FilterDescendantsInstances
		else
			overlapParams.FilterType = Enum.RaycastFilterType[attribute4]
			overlapParams.FilterDescendantsInstances = CollectionService:GetTagged(attribute3)

			if attribute4 == "Exclude" then
				overlapParams:AddToFilter({ workspace.Terrain })
			end
		end
	end

	local durationScale = OuwmitUtility.DurationScale(data)
	local v = OuwmitUtility.GetAttribute(instance2, "EmitDelay", 0) * durationScale
	local rangeAttribute = OuwmitUtility.GetRangeAttribute(
		instance2,
		"Amount",
		NumberRange.new(5, 10),
		NumberRange.new(0, 1e999)
	)
	local rangeAttribute2 = OuwmitUtility.GetRangeAttribute(
		instance2,
		"Lifetime",
		NumberRange.new(2, 3),
		NumberRange.new(0, 1e999)
	)
	local rangeAttribute3 = OuwmitUtility.GetRangeAttribute(
		instance2,
		"Airtime",
		NumberRange.new(0.5, 0.5),
		NumberRange.new(0, 1e999)
	)
	local rangeAttribute4 = OuwmitUtility.GetRangeAttribute(instance2, "LinearMagnitude", NumberRange.new(15, 25))
	local rangeAttribute5 = OuwmitUtility.GetRangeAttribute(instance2, "AngularMagnitude", NumberRange.new(5, 15))
	local attribute6 = OuwmitUtility.GetAttribute(instance2, "SizeScaleEnd", createVector(0, 0, 0))
	local attribute7 = OuwmitUtility.GetAttribute(instance2, "MinSize", createVector(2, 1, 2))
	local attribute8 = OuwmitUtility.GetAttribute(instance2, "MaxSize", createVector(3, 2, 3))
	local attribute9 = OuwmitUtility.GetAttribute(instance2, "MinDirection", createVector(-1, -1, -1))
	local attribute10 = OuwmitUtility.GetAttribute(instance2, "MaxDirection", createVector(1, 1, 1))
	local integer = random:NextInteger(rangeAttribute.Min, rangeAttribute.Max)
	local attribute11 = OuwmitUtility.GetAttribute(instance2, "Size_Curve", OuwmitUtility.default_bezier)
	local attribute12 = OuwmitUtility.GetAttribute(instance2, "Transparency_Curve", OuwmitUtility.default_bezier)
	local v2 = OuwmitUtility.GetAttribute(instance2, "Transparency_Duration", 0.5) * durationScale
	local v3 = OuwmitUtility.GetAttribute(instance2, "Size_Duration", 0.5) * durationScale
	local attribute13 = OuwmitUtility.GetAttribute(instance2, "Transparency_Start", 0)
	local attribute14 = OuwmitUtility.GetAttribute(instance2, "Transparency_End", 1)
	local v4 = instance2:GetAttribute("Transparency_Start") ~= nil or instance2:GetAttribute("Transparency_End") ~= nil
	local v5

	if data ~= nil then
		v5 = OuwmitUtility.GetColor(instance2, data)
	end

	local color

	if v5 == nil then
		color = nil
	else
		color = v5.Keypoints[1].Value
	end

	local v6 = color ~= nil and {
		Color = color,
		ColorBlacklist = data and data.ColorBlacklist
	} or nil

	if v6 == nil and data ~= nil then
		local v7 = firstWhitelisted(instance2, data.ColorWhitelist)
		local v8

		if v7 ~= nil then
			v8 = OuwmitUtility.GetColor(v7, data)
		end

		v6 = v8 ~= nil and {
			Color = v8.Keypoints[1].Value,
			ColorBlacklist = data.ColorBlacklist
		} or v6
	end

	local v7 = {}
	local count = 0
	local position = originCFrame(instance).Position
	instance2.CanCollide = false

	if overlapParams then
		local raycastResult = workspace:Raycast(
			position + createVector(0, 3, 0),
			createVector(0, 1, 0) * -(attribute2 + 6),
			RaycastHelper.Crater
		)

		if raycastResult ~= nil and raycastResult.Instance ~= nil and raycastResult.Instance:IsA("BasePart") and raycastResult.Instance.Transparency < 1 then
			count += 1
			table.insert(v7, raycastResult.Instance)
		end

		if count == 0 then
			local partBoundsInRadius = workspace:GetPartBoundsInRadius(position, attribute2, overlapParams)

			for _, v8 in partBoundsInRadius do
				if v8.Transparency == 1 then
					continue
				end

				count += 1
				table.insert(v7, v8)
			end
		end
	end

	local function Do()
		if integer == nil or integer <= 0 or not instance:IsDescendantOf(game) then
			return
		end

		local cframe = originCFrame(instance)
		local position2 = cframe.Position
		local isCollisionGroupRegistered = PhysicsService:IsCollisionGroupRegistered("ForgeDebris")
		local configuration = Instance.new("Configuration", data ~= nil and data.Parent or getDebreeParent())
		configuration.Name = `{instance2.Name} - Debris`
		local v8 = 0

		for _ = 1, integer do
			local v9

			if count > 0 then
				v9 = v7[random:NextInteger(1, count)]
			else
				v9 = false
			end

			local part = Instance.new("Part")
			local success, result = pcall(function()
				OuwmitUtility.CopyProperties(instance2, part, OuwmitUtility.COPY_PART_PROPERTIES)
				OuwmitUtility.CopyProperties(instance2, part, OuwmitUtility.COPY_EXTENDED_PART_PROPERTIES)
			end)

			if success then
				v8 += 1
				local children = instance2:GetChildren()

				if #children ~= 0 then
					for _, v11 in ipairs(children) do
						local clone = v11:Clone()
						clone.Parent = part
					end
				end

				local emitOnImpact = part:FindFirstChild("EmitOnImpact")

				if emitOnImpact == nil or not emitOnImpact:IsA("Folder") then
					emitOnImpact = nil
				else
					emitOnImpact.Parent = nil
				end

				part.Anchored = false
				part.CanCollide = true
				part.CanQuery = false
				part.CanTouch = false
				part.Parent = configuration
				part.Transparency = attribute13

				if isCollisionGroupRegistered and part.CollisionGroup == "Default" then
					part.CollisionGroup = "ForgeDebris"
				end

				part.CFrame = CFrame.new(position2)
				local vector2 = vector.create(
					random:NextNumber(attribute7.X, attribute8.X),
					random:NextNumber(attribute7.Y, attribute8.Y),
					random:NextNumber(attribute7.Z, attribute8.Z)
				)
				part.Size = vector2

				if v9 then
					part.Material = v9.Material
					part.Color = v9.Color

					if not v4 then
						part.Transparency = v9.Transparency
					end
				end

				if color ~= nil then
					part.Color = color
				end

				part.AssemblyLinearVelocity = cframe:VectorToWorldSpace(part.AssemblyLinearVelocity)
				local vectorToWorldSpace = cframe:VectorToWorldSpace((OuwmitUtility.RandomUnitVector(
					attribute9,
					attribute10,
					random
				)))
				part:ApplyImpulse(part.AssemblyMass * OuwmitUtility.GetImpulseForce(
					position2,
					position2 + vectorToWorldSpace.Unit * random:NextNumber(rangeAttribute4.Min, rangeAttribute4.Max),
					random:NextNumber(rangeAttribute3.Min, rangeAttribute3.Max) * durationScale
				))
				part:ApplyAngularImpulse(part.AssemblyMass * random:NextUnitVector() * random:NextNumber(
					rangeAttribute5.Min,
					rangeAttribute5.Max
				))

				if callback ~= nil and #children ~= 0 then
					for _, child in ipairs(part:GetChildren()) do
						callback(child, v6)
					end
				end

				local touchedConnection = nil

				if emitOnImpact ~= nil and #emitOnImpact:GetChildren() > 0 then
					part.CanTouch = true
					local parent = part
					touchedConnection = part.Touched:Connect(function(otherPart)
						if not (attribute5 or otherPart:CanCollideWith(parent)) or otherPart:IsDescendantOf(workspace.Terrain) or attribute4 == "Exclude" and attribute3 ~= "" and otherPart:HasTag(attribute3) then
							return
						end

						touchedConnection:Disconnect()
						touchedConnection = nil

						if emitOnImpact == nil or parent.Parent == nil then
							return
						end

						local children2 = emitOnImpact:GetChildren()

						for i, v12 in ipairs(children2) do
							v12.Parent = parent
						end

						emitOnImpact:Destroy()
						emitOnImpact = nil

						if callback ~= nil then
							for i, v12 in ipairs(children2) do
								callback(v12, v6)
							end
						end
					end)
				end

				local v11 = random:NextNumber(rangeAttribute2.Min, rangeAttribute2.Max) * durationScale
				local v12 = part
				task.delay(v11, function()
					if touchedConnection ~= nil then
						touchedConnection:Disconnect()
						touchedConnection = nil
					end

					if emitOnImpact ~= nil then
						emitOnImpact:Destroy()
						emitOnImpact = nil
					end

					v12.AssemblyLinearVelocity = createVector(0, 0, 0)
					v12.AssemblyAngularVelocity = createVector(0, 0, 0)
					local size = v12.Size

					if size ~= vector2 * attribute6 then
						Tween.new(attribute11, v3, function(p, p2)
							v12.Size = size:Lerp(vector2 * attribute6, p)
							return p2
						end)
					end

					if attribute13 == attribute14 then
						v12.Transparency = attribute13
					else
						Tween.new(attribute12, v2, function(p, p2)
							v12.Transparency = OuwmitUtility.lerp(attribute13, attribute14, p)
							return p2
						end)
					end

					v8 -= 1

					if v8 == 0 then
						task.delay(math.max(v3, v2), function()
							if configuration ~= nil then
								configuration:Destroy()
								configuration = nil
							end
						end)
					else
						task.delay(math.max(v3, v2), v12.Destroy, v12)
					end
				end)
			else
				warn((`Ouwmit Debris: template '{instance2.Name}' properties couldn't be copied ({result})`))
				part:Destroy()
				break
			end
		end

		if v8 == 0 and configuration ~= nil then
			configuration:Destroy()
			configuration = nil
		end
	end

	if v == nil or not (v > 0) then
		Do()
	else
		task.delay(v, Do)
	end
end