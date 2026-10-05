local createVector = vector.create
local Maid = require(script.Parent.Utility.Maid)
local raycastParams_2 = RaycastParams.new()
raycastParams_2.FilterType = Enum.RaycastFilterType.Whitelist
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
local physicalProperties = PhysicalProperties.new(0.7, 0, 0, 1, 100)
local Collider = {}
Collider.__index = Collider
Collider.ClassName = "Collider"

function Collider.new(controller)
	local self = setmetatable({}, Collider)
	self.Model = Instance.new("Model")
	local sphere, vForce, floorDetector, jumpDetector, gyro = create(self, controller)
	self._maid = Maid.new()
	self.Controller = controller
	self.Sphere = sphere
	self.VForce = vForce
	self.FloorDetector = floorDetector
	self.JumpDetector = jumpDetector
	self.Gyro = gyro
	init(self)
	return self
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHipHeight(instance)
	if instance.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		return instance.Humanoid.HipHeight + 0.05
	end

	return 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAttachement(instance)
	if instance.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		return instance.HRP:WaitForChild("RootRigAttachment")
	end

	return instance.HRP:WaitForChild("RootAttachment")
end

function create(p, instance)
	local hipHeight = getHipHeight(instance) -- equivalent call inferred; original call site unknown
	local attachement = getAttachement(instance) -- equivalent call inferred; original call site unknown
	local part = Instance.new("Part")
	part.Name = "Sphere"
	part.Massless = true
	part.Size = createVector(2, 2, 2)
	part.Shape = Enum.PartType.Ball
	part.Transparency = 1
	part.CustomPhysicalProperties = physicalProperties
	local part2 = Instance.new("Part")
	part2.Name = "FloorDectector"
	part2.CanCollide = false
	part2.Massless = true
	part2.Size = createVector(2, 1, 1)
	part2.Transparency = 1
	local part3 = Instance.new("Part")
	part3.Name = "JumpDectector"
	part3.CanCollide = false
	part3.Massless = true
	part3.Size = createVector(2, 0.2, 1)
	part3.Transparency = 1
	local weld = Instance.new("Weld")
	weld.C0 = CFrame.new(0, -hipHeight, 0.1)
	weld.Part0 = instance.HRP
	weld.Part1 = part
	weld.Parent = part
	local weld2 = Instance.new("Weld")
	weld2.C0 = CFrame.new(0, -hipHeight - 1.5, 0)
	weld2.Part0 = instance.HRP
	weld2.Part1 = part2
	weld2.Parent = part2
	local weld3 = Instance.new("Weld")
	weld3.C0 = CFrame.new(0, -hipHeight - 1.1, 0)
	weld3.Part0 = instance.HRP
	weld3.Part1 = part3
	weld3.Parent = part3
	local vectorForce = Instance.new("VectorForce")
	vectorForce.Force = createVector(0, 0, 0)
	vectorForce.ApplyAtCenterOfMass = true
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Attachment0 = attachement
	vectorForce.Parent = instance.HRP
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 25000
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.CFrame = instance.HRP.CFrame
	bodyGyro.Parent = instance.HRP
	part2.Touched:Connect(function() end)
	part3.Touched:Connect(function() end)
	part.Parent = p.Model
	part2.Parent = p.Model
	part3.Parent = p.Model
	return part, vectorForce, part2, part3, bodyGyro
end

function init(data)
	data._maid:Mark(data.Model)
	data._maid:Mark(data.VForce)
	data._maid:Mark(data.FloorDetector)
	data._maid:Mark(data.Gyro)
	data.Model.Name = "Collider"
	data.Model.Parent = data.Controller.Character
end

function Collider.Update(p, force, cFrame)
	p.VForce.Force = force
	p.Gyro.CFrame = cFrame
end

function Collider.IsGrounded(data, p)
	local touchingParts = (p and data.JumpDetector or data.FloorDetector):GetTouchingParts()

	for _, touchingPart in pairs(touchingParts) do
		if not touchingPart:IsDescendantOf(data.Controller.Character) and touchingPart.CanCollide then
			return true
		end
	end
end

function Collider.GetStandingPart(p)
	raycastParams.FilterDescendantsInstances = { p.Controller.Character }
	local _gravityUp = p.Controller._gravityUp
	local raycastResult = workspace:Raycast(p.Sphere.Position, -1.1 * _gravityUp, raycastParams)
	return raycastResult and raycastResult.Instance
end

function Collider:Destroy()
	self._maid:Sweep()
end

return Collider