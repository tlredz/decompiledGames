local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Physics = {}

function Physics.ApplyForce(_, vector2: Vector3, parent, value: number)
	local unit = (parent.Position - vector2).Unit
	local mass = parent:GetMass()

	if parent.Parent:IsA("Model") then
		mass = 0

		for _, part in parent.Parent:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			mass += part:GetMass()
			part:SetNetworkOwner(nil)
		end
	end

	local force = unit * (value or 100) * mass
	local attachment = Instance.new("Attachment")
	attachment.Parent = parent
	attachment.WorldPosition = parent.Position
	local vectorForce = Instance.new("VectorForce")
	vectorForce.Force = force
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Attachment0 = attachment
	vectorForce.Parent = parent
	Debris:AddItem(vectorForce, 0.1)
	Debris:AddItem(attachment, 0.1)
end

function Physics.ApplyImpact(_, vector2: Vector3, vector3: Vector3, parent, value: number)
	local mass = parent:GetMass()
	local force = ((vector3 - vector2).Unit * math.min((vector3 - vector2).Magnitude, 1e999)).Unit * (value or 3000) * mass
	local attachment = Instance.new("Attachment")
	attachment.Parent = parent
	attachment.Position = parent.CFrame:pointToObjectSpace(vector3)
	local vectorForce = Instance.new("VectorForce")
	vectorForce.Force = force
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Attachment0 = attachment
	vectorForce.ApplyAtCenterOfMass = false
	vectorForce.Parent = parent
	Debris:AddItem(vectorForce, 0.1)
	Debris:AddItem(attachment, 0.1)
end

function Physics.Knockback(_, parent, p, p2)
	local attachment = parent:FindFirstChildOfClass("Attachment") or Instance.new("Attachment")
	attachment.Parent = parent
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.MaxForce = 9999999
	linearVelocity.VectorVelocity = p * p2
	linearVelocity.Parent = parent
	TweenService:Create(linearVelocity, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		VectorVelocity = (p + createVector(0, 100, 0)) * 0.1
	}):Play()
	Debris:AddItem(linearVelocity, 0.15)
end

function Physics.MovePart(_, parent, position: Vector3, duration: number)
	local attachment = parent:FindFirstChild("Attachment")

	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Parent = parent
	end

	local v2 = parent:FindFirstChildOfClass("AlignPosition")
	local v3 = parent:FindFirstChildOfClass("AlignOrientation")

	if not v2 then
		v2 = Instance.new("AlignPosition")
		v2.Mode = Enum.PositionAlignmentMode.OneAttachment
		v2.ApplyAtCenterOfMass = true
		v2.Attachment0 = attachment
		v2.MaxForce = 1000000
		v2.Responsiveness = 200
		v2.Parent = parent
	end

	if not v3 then
		v3 = Instance.new("AngularVelocity")
		v3.Enabled = false
		v3.MaxTorque = 99999999
		v3.Attachment0 = attachment
		v3.Parent = parent
	end

	v2.MaxVelocity = (parent.Position - position).Magnitude / duration
	v2.Position = position
	v3.Enabled = true
	v2.Enabled = true
	task.delay(duration, function()
		v3.Enabled = false
		v2.Enabled = false
	end)
end

function Physics.JoinParts(_, p, part, options)
	local C0 = (options or {}).C0
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = p
	motor6D.Part1 = part
	motor6D.Parent = p
	local cFrameValue = part:FindFirstChildOfClass("CFrameValue")

	if cFrameValue then
		motor6D.C0 = cFrameValue.Value
	end

	if C0 then
		motor6D.C0 = C0
	end

	return motor6D
end

function Physics.Weld(_, p, part)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = p
	weldConstraint.Part1 = part
	weldConstraint.Parent = p
end

function Physics.NoCollide(_, folder, p)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		if p == true then
			part.CollisionGroup = "NoCollide"
		else
			part.CollisionGroup = "Default"
		end
	end
end

return Physics