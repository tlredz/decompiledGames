local AccessoryAdjustmentsClientPreview = {}
game:GetService("ReplicatedStorage")

local function attachmentParentPart(p)
	if p == nil then
		return nil
	end

	local parent = p.Parent

	if parent == nil or not parent:IsA("BasePart") then
		return nil
	end

	return parent
end

local function otherConnectedPart(rigidConstraint, handle)
	if rigidConstraint:IsA("RigidConstraint") then
		local attachment0 = rigidConstraint.Attachment0
		local parent

		if attachment0 ~= nil then
			parent = attachment0.Parent

			if parent == nil or not parent:IsA("BasePart") then
				parent = nil
			end
		end

		local attachment1 = rigidConstraint.Attachment1
		local parent2

		if attachment1 ~= nil then
			parent2 = attachment1.Parent

			if parent2 == nil or not parent2:IsA("BasePart") then
				parent2 = nil
			end
		end

		if parent2 == handle and parent ~= nil then
			return parent
		end

		if parent == handle and parent2 ~= nil then
			return parent2
		end

		return nil
	else
		if rigidConstraint.Part1 == handle and rigidConstraint.Part0 ~= nil and rigidConstraint.Part0:IsA("BasePart") then
			return rigidConstraint.Part0
		end

		if rigidConstraint.Part0 == handle and rigidConstraint.Part1 ~= nil and rigidConstraint.Part1:IsA("BasePart") then
			return rigidConstraint.Part1
		end

		return nil
	end
end

local function resolveConnectorHandleSide(rigidConstraint, handle)
	if rigidConstraint:IsA("RigidConstraint") then
		local attachment0 = rigidConstraint.Attachment0
		local attachment1 = rigidConstraint.Attachment1

		if attachment1 ~= nil and attachment1.Parent == handle then
			return true, attachment1.CFrame
		end

		if attachment0 == nil or attachment0.Parent ~= handle then
			return nil, nil
		end

		return false, attachment0.CFrame
	else
		if rigidConstraint.Part1 == handle then
			return true, rigidConstraint.C1
		end

		if rigidConstraint.Part0 == handle then
			return false, rigidConstraint.C0
		end

		return nil, nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setConnectorStoredCFrame(rigidConstraint, legacyWeldAdjustC1: boolean, cframe: CFrame)
	if rigidConstraint:IsA("RigidConstraint") then
		local attachment1

		if legacyWeldAdjustC1 == true then
			attachment1 = rigidConstraint.Attachment1
		else
			attachment1 = rigidConstraint.Attachment0
		end

		if attachment1 ~= nil then
			attachment1.CFrame = cframe
		end
	elseif legacyWeldAdjustC1 == true then
		rigidConstraint.C1 = cframe
	else
		rigidConstraint.C0 = cframe
	end
end

local function isConnectorEnabled(rigidConstraint)
	if rigidConstraint:IsA("RigidConstraint") then
	end

	return rigidConstraint.Enabled
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setConnectorEnabled(rigidConstraint, enabled: boolean)
	if rigidConstraint:IsA("RigidConstraint") then
	end

	rigidConstraint.Enabled = enabled
end

local function findLegacyWeldOnHandle(folder)
	local accessoryWeld = folder:FindFirstChild("AccessoryWeld")

	if accessoryWeld ~= nil and (accessoryWeld:IsA("Weld") or accessoryWeld:IsA("RigidConstraint")) then
		return accessoryWeld
	end

	for _, weld in folder:GetDescendants() do
		if weld:IsA("Weld") then
			return weld
		end
	end

	for _, rigidConstraint in folder:GetDescendants() do
		if rigidConstraint:IsA("RigidConstraint") then
			return rigidConstraint
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapNoiseVec3(vector: Vector3, p: number)
	return (Vector3.new(
		math.abs(vector.X) < p and 0 or vector.X,
		math.abs(vector.Y) < p and 0 or vector.Y,
		math.abs(vector.Z) < p and 0 or vector.Z
	))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rotationFromDescriptionDelta(vector: Vector3)
	local v = snapNoiseVec3(vector, 0.001) -- equivalent call inferred; original call site unknown
	return CFrame.Angles(math.rad(v.X), math.rad(v.Y), (math.rad(v.Z)))
end

local function _rotationDeltaFromDescriptionRotations(vector: Vector3, vector2: Vector3)
	local cframe = rotationFromDescriptionDelta(vector) -- equivalent call inferred; original call site unknown
	return rotationFromDescriptionDelta(vector2) * cframe:Inverse()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function accessoryBindRotation(accessory)
	if accessory == nil or accessory:IsA("Accessory") ~= true then
		return CFrame.new()
	end

	local attachmentPoint = accessory.AttachmentPoint
	return attachmentPoint - attachmentPoint.Position
end

local function conjugateOffsetByBind(cframe: CFrame, cframe2: CFrame)
	return cframe * cframe2 * cframe:Inverse()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function compensatedOffsetFromDescriptionDelta(cframe: CFrame, vector: Vector3, vector2: Vector3)
	local v = snapNoiseVec3(vector, 0.00001) -- equivalent call inferred; original call site unknown
	return CFrame.new(v) * (cframe * rotationFromDescriptionDelta(vector2) * cframe:Inverse())
end

local function scaleRatiosFromDescScale0(vector: Vector3, vector2: Vector3)
	local v = vector.X == 0 and 1 or vector2.X / vector.X
	local selected = vector.Y == 0 and 1 or vector2.Y / vector.Y

	if vector.Z == 0 then
		return v, selected, 1
	end

	return v, selected, vector2.Z / vector.Z
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isNearZero(p: number)
	return math.abs(p) <= 1e-6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isVectorNearZero(vector: Vector3)
	return isNearZero(vector.X) and isNearZero(vector.Y) and isNearZero(vector.Z)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasMeaningfulScaleDelta(p: number, p2: number, p3: number)
	return isNearZero(p - 1) == false or (isNearZero(p2 - 1) == false or isNearZero(p3 - 1) == false)
end

local function restoreLegacyWeldStoredCFrame(data)
	if data.legacyWeld == nil or data.legacyWeldCStored == nil or data.legacyWeldAdjustC1 == nil then
		return
	end

	setConnectorStoredCFrame(data.legacyWeld, data.legacyWeldAdjustC1, data.legacyWeldCStored) -- equivalent call inferred; original call site unknown
end

local function applyNeckLegacyWeldScaleShift(data, p: number, p2: number, p3: number, flag: boolean?)
	if data.accessoryType ~= Enum.AccessoryType.Neck then
		return
	end

	local handle = data.handle

	if handle == nil or data.part0 == nil or data.legacyWeld == nil or data.legacyWeldCStored == nil or data.legacyWeldAdjustC1 == nil then
		return
	end

	local v = ((p + p2 + p3) / 3 - 1) * -data.handleSizeStart.Y * 0.5
	local v2 = -data.part0.CFrame.UpVector * v
	local legacyWeldCStored = data.legacyWeldCStored
	local v3 = legacyWeldCStored - legacyWeldCStored.Position
	local v4

	if data.legacyWeldAdjustC1 == true then
		v4 = handle.CFrame:VectorToObjectSpace(v2)
	else
		v4 = data.part0.CFrame:VectorToObjectSpace(v2)
	end

	local v5 = CFrame.new(legacyWeldCStored.Position + v4) * v3
	setConnectorStoredCFrame(data.legacyWeld, data.legacyWeldAdjustC1, v5) -- equivalent call inferred; original call site unknown

	if flag ~= true then
		handle.Anchored = false
	end
end

local function tryBuildLegacyWeldBaseline(accessoryType, rigidConstraint, handle, descPos: Vector3, descRot: Vector3, descScale: Vector3)
	local part = otherConnectedPart(rigidConstraint, handle)

	if part == nil then
		return nil
	end

	local connectorHandleSide, legacyWeldCStored = resolveConnectorHandleSide(rigidConstraint, handle)

	if connectorHandleSide == nil or legacyWeldCStored == nil then
		return nil
	end

	if rigidConstraint:IsA("RigidConstraint") then
	end

	return {
		accessoryType = accessoryType,
		weld = nil,
		weldWasEnabled = nil,
		legacyWeld = rigidConstraint,
		legacyWeldWasEnabled = rigidConstraint.Enabled,
		legacyWeldAdjustC1 = connectorHandleSide,
		legacyWeldCStored = legacyWeldCStored,
		handle = handle,
		handleCFrameStart = handle.CFrame,
		handleSizeStart = handle.Size,
		handlePivotOffsetStart = handle.PivotOffset,
		descPos0 = descPos,
		descRot0 = descRot,
		descScale0 = descScale,
		part0 = part,
		partToHandleStart = part.CFrame:ToObjectSpace(handle.CFrame)
	}
end

function AccessoryAdjustmentsClientPreview.tryCapture(instance, vector: Vector3, vector2: Vector3, vector3: Vector3)
	local handle = instance:FindFirstChild("Handle")

	if handle == nil or not handle:IsA("BasePart") then
		return nil
	end

	local parent = instance.Parent

	if parent == nil or parent:IsA("Model") ~= true then
		return nil
	end

	local accessoryType = instance.AccessoryType
	local legacyWeldOnHandle = findLegacyWeldOnHandle(handle)

	if legacyWeldOnHandle ~= nil then
		local v = tryBuildLegacyWeldBaseline(accessoryType, legacyWeldOnHandle, handle, vector, vector2, vector3)

		if v ~= nil then
			return v
		end
	end

	return nil
end

function AccessoryAdjustmentsClientPreview.apply(data, vector: Vector3, vector2: Vector3, vector3: Vector3)
	local v = vector - data.descPos0
	local v2 = vector2 - data.descRot0
	local handle = data.handle
	local v3

	if handle ~= nil then
		v3 = handle.Parent
	end

	local cframe = accessoryBindRotation(v3) -- equivalent call inferred; original call site unknown
	local v4 = compensatedOffsetFromDescriptionDelta(cframe, v, v2) -- equivalent call inferred; original call site unknown
	local descScale0 = data.descScale0
	local v5 = descScale0.X == 0 and 1 or vector3.X / descScale0.X
	local v6 = descScale0.Y == 0 and 1 or vector3.Y / descScale0.Y
	local v7 = descScale0.Z == 0 and 1 or vector3.Z / descScale0.Z
	local v8 = isVectorNearZero(v) and isNearZero(v2.X) and isNearZero(v2.Y) and isNearZero(v2.Z)
	local meaningfulScaleDelta = hasMeaningfulScaleDelta(v5, v6, v7) -- equivalent call inferred; original call site unknown
	local v9 = data.accessoryType == Enum.AccessoryType.Neck

	if v8 == false and (data.weld ~= nil or data.legacyWeld ~= nil) then
		if data.weld ~= nil then
			data.weld.Enabled = false
		end

		if data.legacyWeld ~= nil then
			setConnectorEnabled(data.legacyWeld, false) -- equivalent call inferred; original call site unknown
		end
	end

	if v8 == false and data.handle ~= nil and data.part0 ~= nil then
		data.handle.Anchored = true
		local cFrame

		if data.partToHandleStart == nil then
			cFrame = data.handle.CFrame
		else
			local v10

			if isNearZero(v2.X) == false and isNearZero(v2.Y) == true then
				v10 = isNearZero(v2.Z) == true
			else
				v10 = false
			end

			local v11

			if isNearZero(v2.X) == true and isNearZero(v2.Y) == true then
				v11 = isNearZero(v2.Z) == false
			else
				v11 = false
			end

			if v10 then
				data.handle.PivotOffset = data.handlePivotOffsetStart
				local cframe2 = CFrame.Angles(math.rad(v2.X), 0, 0)
				cFrame = data.part0.CFrame * CFrame.new(v2) * data.partToHandleStart * (cframe * cframe2 * cframe:Inverse())
			elseif v11 then
				local cframe2 = CFrame.Angles(0, 0, (math.rad(v2.Z)))
				cFrame = data.part0.CFrame * CFrame.new(v) * data.partToHandleStart * (cframe * cframe2 * cframe:Inverse())
			else
				cFrame = data.part0.CFrame * v4 * data.partToHandleStart
			end
		end

		data.handle.CFrame = cFrame
	end

	local handle2 = data.handle

	if handle2 ~= nil then
		handle2.Size = Vector3.new(
			data.handleSizeStart.X * v5,
			data.handleSizeStart.Y * v6,
			data.handleSizeStart.Z * v7
		)

		if v8 == true and meaningfulScaleDelta == true then
			if v9 == true and data.part0 ~= nil and data.legacyWeld ~= nil and data.legacyWeldCStored ~= nil and data.legacyWeldAdjustC1 ~= nil then
				applyNeckLegacyWeldScaleShift(data, v5, v6, v7)
			elseif data.legacyWeld ~= nil and data.legacyWeldCStored ~= nil and data.legacyWeldAdjustC1 ~= nil then
				local legacyWeldCStored = data.legacyWeldCStored
				local v10 = legacyWeldCStored - legacyWeldCStored.Position
				local v11 = legacyWeldCStored.Position * Vector3.new(v5, v6, v7)
				setConnectorStoredCFrame(data.legacyWeld, data.legacyWeldAdjustC1, CFrame.new(v11) * v10) -- equivalent call inferred; original call site unknown
			end

			handle2.Anchored = false
		end

		if not v8 then
			local position = data.handleCFrameStart.Position
			local v10

			if data.part0 == nil then
				v10 = position + v
			else
				v10 = position + data.part0.CFrame:VectorToWorldSpace(v)
			end

			local position2 = handle2.CFrame.Position
			handle2.CFrame += v10 - position2
		end
	end
end

function AccessoryAdjustmentsClientPreview.cleanupAfterApply(data, flag: boolean?, vector: Vector3?)
	if flag == true and data.handle ~= nil then
		local handle = data.handle

		if vector == nil then
			handle.Size = data.handleSizeStart
			handle.PivotOffset = data.handlePivotOffsetStart
			handle.CFrame = data.handleCFrameStart

			if data.legacyWeld ~= nil and data.legacyWeldCStored ~= nil and data.legacyWeldAdjustC1 ~= nil then
				setConnectorStoredCFrame(data.legacyWeld, data.legacyWeldAdjustC1, data.legacyWeldCStored) -- equivalent call inferred; original call site unknown
			end
		else
			if data.weld ~= nil then
				data.weld.Enabled = false
			end

			if data.legacyWeld ~= nil then
				setConnectorEnabled(data.legacyWeld, false) -- equivalent call inferred; original call site unknown
			end

			handle.Anchored = true
			local descScale0 = data.descScale0
			local v = descScale0.X == 0 and 1 or vector.X / descScale0.X
			local v2 = descScale0.Y == 0 and 1 or vector.Y / descScale0.Y
			local v3 = descScale0.Z == 0 and 1 or vector.Z / descScale0.Z
			handle.PivotOffset = data.handlePivotOffsetStart

			if data.part0 == nil or data.partToHandleStart == nil then
				handle.CFrame = data.handleCFrameStart
			else
				handle.CFrame = data.part0.CFrame * data.partToHandleStart
			end

			handle.Size = Vector3.new(
				data.handleSizeStart.X * v,
				data.handleSizeStart.Y * v2,
				data.handleSizeStart.Z * v3
			)

			if data.legacyWeld ~= nil and data.legacyWeldCStored ~= nil and data.legacyWeldAdjustC1 ~= nil and data.legacyWeld ~= nil and data.legacyWeldCStored ~= nil and data.legacyWeldAdjustC1 ~= nil then
				setConnectorStoredCFrame(data.legacyWeld, data.legacyWeldAdjustC1, data.legacyWeldCStored) -- equivalent call inferred; original call site unknown
			end
		end
	end

	if data.handle ~= nil then
		local handle = data.handle

		if flag ~= true then
			local objectSpace = data.handleCFrameStart:ToObjectSpace(handle.CFrame)

			if data.part0 ~= nil and data.partToHandleStart ~= nil then
				local objectSpace2 = data.part0.CFrame:ToObjectSpace(handle.CFrame)
				objectSpace = data.partToHandleStart:ToObjectSpace(objectSpace2)
			end

			handle.PivotOffset = objectSpace * data.handlePivotOffsetStart
		end

		handle.Anchored = false
	end

	if data.weld ~= nil and data.weldWasEnabled ~= nil then
		data.weld.Enabled = data.weldWasEnabled
	end

	if data.legacyWeld ~= nil and data.legacyWeldWasEnabled ~= nil then
		local legacyWeld = data.legacyWeld
		local legacyWeldWasEnabled = data.legacyWeldWasEnabled

		if legacyWeld:IsA("RigidConstraint") then
			legacyWeld.Enabled = legacyWeldWasEnabled
		else
			legacyWeld.Enabled = legacyWeldWasEnabled
		end
	end
end

function AccessoryAdjustmentsClientPreview.restore(data)
	if data.legacyWeld ~= nil and data.legacyWeldCStored ~= nil and data.legacyWeldAdjustC1 ~= nil then
		setConnectorStoredCFrame(data.legacyWeld, data.legacyWeldAdjustC1, data.legacyWeldCStored) -- equivalent call inferred; original call site unknown
	end

	if data.handle ~= nil then
		data.handle.Size = data.handleSizeStart
		data.handle.PivotOffset = data.handlePivotOffsetStart
		data.handle.CFrame = data.handleCFrameStart
		data.handle.Anchored = false
	end

	if data.weld ~= nil and data.weldWasEnabled ~= nil then
		data.weld.Enabled = data.weldWasEnabled
	end

	if data.legacyWeld ~= nil and data.legacyWeldWasEnabled ~= nil then
		local legacyWeld = data.legacyWeld
		local legacyWeldWasEnabled = data.legacyWeldWasEnabled

		if legacyWeld:IsA("RigidConstraint") then
			legacyWeld.Enabled = legacyWeldWasEnabled
		else
			legacyWeld.Enabled = legacyWeldWasEnabled
		end
	end
end

return AccessoryAdjustmentsClientPreview