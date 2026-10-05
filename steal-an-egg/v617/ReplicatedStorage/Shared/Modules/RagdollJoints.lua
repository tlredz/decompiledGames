local v = {
	Attachment = true
}
local v2 = {
	BallSocketConstraint = true,
	HingeConstraint = true
}
local v3 = {
	Root = true,
	Neck = true
}

local function purgeTagged(instance, attributeName: string, p, name: string?)
	for _, v4 in not instance and {} or instance:GetChildren() do
		local attribute = p[v4.ClassName] and v4:GetAttribute(attributeName)

		if attribute and (not name or attribute == name) then
			v4:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unrig(instance)
	purgeTagged(instance.Parent, "RagdollConstraint", v2, instance.Name)
	purgeTagged(instance.Part0, "RagdollAttachment", v, instance.Name)
	purgeTagged(instance.Part1, "RagdollAttachment", v, instance.Name)
end

local function anchorPoint(parent, ragdollAttachment: string, p: string, cFrame: CFrame)
	local attachment = Instance.new("Attachment")
	attachment.Name = `RagdollAttachment_{ragdollAttachment}_{p}`
	attachment:SetAttribute("RagdollAttachment", ragdollAttachment)
	attachment.Parent = parent
	attachment.CFrame = cFrame
	return attachment
end

local function rig(instance)
	local part0 = instance.Part0
	local part1 = instance.Part1

	if not (part0 and part1) then
		return nil
	end

	unrig(instance) -- equivalent call inferred; original call site unknown
	local name = instance.Name
	local ballSocketConstraint = Instance.new("BallSocketConstraint")
	local C0 = instance.C0
	local attachment = Instance.new("Attachment")
	attachment.Name = `RagdollAttachment_{name}_A`
	attachment:SetAttribute("RagdollAttachment", name)
	attachment.Parent = part0
	attachment.CFrame = C0
	local C1 = instance.C1
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = `RagdollAttachment_{name}_B`
	attachment2:SetAttribute("RagdollAttachment", name)
	attachment2.Parent = part1
	attachment2.CFrame = C1
	ballSocketConstraint.Name = `RagdollConstraint_{name}`
	ballSocketConstraint:SetAttribute("RagdollConstraint", name)
	ballSocketConstraint.Parent = instance.Parent
	ballSocketConstraint.Attachment0 = attachment
	ballSocketConstraint.Attachment1 = attachment2
	ballSocketConstraint.LimitsEnabled = true
	ballSocketConstraint.TwistLimitsEnabled = true

	if not v3[name] then
		return ballSocketConstraint
	end

	ballSocketConstraint:Destroy()
	local hingeConstraint = Instance.new("HingeConstraint")
	hingeConstraint.Name = `RagdollConstraint_{name}`
	hingeConstraint:SetAttribute("RagdollConstraint", name)
	hingeConstraint.Parent = instance.Parent
	hingeConstraint.Attachment0 = attachment
	hingeConstraint.Attachment1 = attachment2
	hingeConstraint.LimitsEnabled = true
	return hingeConstraint
end

local function eachMotor(folder, fn)
	for _, motor6D in folder:GetDescendants() do
		if motor6D:IsA("Motor6D") then
			fn(motor6D)
		end
	end
end

local RagdollJoints = {}

function RagdollJoints.Bind(p)
	eachMotor(p, function(p2)
		rig(p2)
		p2.Enabled = false
	end)
end

function RagdollJoints.Release(p)
	eachMotor(p, function(instance)
		if instance.Parent then
			unrig(instance) -- equivalent call inferred; original call site unknown
			instance.Enabled = true
		end
	end)
end

return RagdollJoints