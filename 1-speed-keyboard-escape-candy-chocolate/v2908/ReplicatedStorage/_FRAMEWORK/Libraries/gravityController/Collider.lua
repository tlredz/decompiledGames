require(script.Parent.Types)
local physicalProperties = PhysicalProperties.new(0.7, 0, 0, 100, 100)

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveHipHeight(p)
	if p.RigType == Enum.HumanoidRigType.R15 then
		return p.HipHeight
	end

	return 2
end

local function resolveMetrics(p, p2, data)
	local hipHeight = resolveHipHeight(p2) -- equivalent call inferred; original call site unknown
	local scale = math.max(hipHeight / 2, 0.25)
	return {
		scale = scale,
		colliderRadius = data.colliderRadius * scale,
		colliderForwardOffset = data.colliderForwardOffset * scale,
		groundDistance = data.groundDistance * scale,
		groundRingRadius = data.groundRingRadius * scale,
		footOffset = hipHeight + p.Size.Y * 0.5 + 0.05
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveOffset(metrics)
	return CFrame.new(0, metrics.colliderRadius - metrics.footOffset, metrics.colliderForwardOffset)
end

local function smoothBody(folder)
	local result = {}

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.CanCollide) then
			continue
		end

		table.insert(result, {
			part = part,
			properties = part.CustomPhysicalProperties
		})
		part.CustomPhysicalProperties = PhysicalProperties.new(part.CurrentPhysicalProperties.Density, 0, 0, 100, 100)
	end

	return result
end

local Collider = {}

function Collider.create(parent, p, p2, p3)
	local metrics = resolveMetrics(p, p2, p3)
	local offset = resolveOffset(metrics) -- equivalent call inferred; original call site unknown
	local v = metrics.colliderRadius * 2
	local bodyParts = smoothBody(parent)
	local model = Instance.new("Model")
	model.Name = "GravityCollider"
	local part = Instance.new("Part")
	part.Name = "Sphere"
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(v, v, v)
	part.Massless = true
	part.Transparency = 1
	part.CanQuery = false
	part.CustomPhysicalProperties = physicalProperties
	part.CollisionGroup = p.CollisionGroup
	part.CFrame = p.CFrame * offset
	part.Parent = model
	local weld = Instance.new("Weld")
	weld.C0 = offset
	weld.Part0 = p
	weld.Part1 = part
	weld.Parent = part
	local attachment = Instance.new("Attachment")
	attachment.Name = "GravityOrientation"
	attachment.Parent = p
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = attachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Responsiveness = p3.orientationResponsiveness
	alignOrientation.MaxTorque = 1e999
	alignOrientation.MaxAngularVelocity = 1e999
	alignOrientation.CFrame = p.CFrame.Rotation
	alignOrientation.Parent = p
	model.Parent = parent
	return {
		model = model,
		sphere = part,
		weld = weld,
		attachment = attachment,
		alignOrientation = alignOrientation,
		offset = offset,
		metrics = metrics,
		bodyParts = bodyParts
	}
end

function Collider:refresh(p, p2, p3)
	local metrics = resolveMetrics(p, p2, p3)
	local offset = resolveOffset(metrics) -- equivalent call inferred; original call site unknown
	local v = metrics.colliderRadius * 2
	self.sphere.Size = Vector3.new(v, v, v)
	self.weld.C0 = offset
	self.offset = offset
	self.metrics = metrics
end

function Collider.setCollisionGroup(p, collisionGroup: string)
	p.sphere.CollisionGroup = collisionGroup
end

function Collider.setOrientation(p, cFrame: CFrame)
	p.alignOrientation.CFrame = cFrame
end

function Collider.setMotionEnabled(p, enabled: boolean)
	p.alignOrientation.Enabled = enabled
end

function Collider.destroy(data)
	data.alignOrientation:Destroy()
	data.attachment:Destroy()
	data.model:Destroy()

	for _, bodyPart in data.bodyParts do
		bodyPart.part.CustomPhysicalProperties = bodyPart.properties
	end
end

return Collider