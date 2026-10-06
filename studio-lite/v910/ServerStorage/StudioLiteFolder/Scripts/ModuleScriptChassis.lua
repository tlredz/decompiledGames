local createVector = vector.create
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local parent = script.Parent
local parent2 = parent.Parent
local Effects = require(parent:WaitForChild("Effects"))
local constraints = parent2:WaitForChild("Constraints")
local v = {
	MaxSpeed = 127.73431262973017,
	ReverseSpeed = 71.85055085422321,
	DrivingTorque = 60000,
	BrakingTorque = 90000,
	StrutSpringStiffnessFront = 40000,
	StrutSpringDampingFront = 6000,
	StrutSpringStiffnessRear = 40000,
	StrutSpringDampingRear = 6000,
	TorsionSpringStiffness = 2000,
	TorsionSpringDamping = 150,
	MaxSteer = 0.55,
	WheelFriction = 2
}
local v2 = nil
local v3 = nil
local motorMaxTorque2 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function gravityAdjust()
	local v11 = Workspace.Gravity / 196.2
	v3 = v.DrivingTorque * v11
	motorMaxTorque2 = v.BrakingTorque * v11
	v5 = v.StrutSpringStiffnessFront * v11
	v6 = v.StrutSpringDampingFront * math.sqrt(v11)
	v7 = v.StrutSpringStiffnessRear * v11
	v8 = v.StrutSpringDampingRear * math.sqrt(v11)
	v9 = v.TorsionSpringStiffness * v11
	v10 = v.TorsionSpringDamping * math.sqrt(v11)
end

local function convertProperty(p, p2)
	if p == "MaxSpeed" or p == "ReverseSpeed" then
		return p2 / 0.6263
	end

	return p2
end

local attributeChangedConnection = nil

local function updateFromConfiguration()
	local parent3 = script.Parent.Parent

	for attributeName, _ in pairs(v) do
		local attribute = parent3:GetAttribute(attributeName)

		if not attribute then
			continue
		end

		local v11 = v

		if attributeName == "MaxSpeed" or attributeName == "ReverseSpeed" then
			attribute /= 0.6263
		end

		v11[attributeName] = attribute
	end

	attributeChangedConnection = parent3.AttributeChanged:Connect(function(attributeName)
		if v[attributeName] == nil then
			return
		end

		local attribute = parent3:GetAttribute(attributeName)
		local v11 = v

		if attributeName == "MaxSpeed" or attributeName == "ReverseSpeed" then
			attribute /= 0.6263
		end

		v11[attributeName] = attribute
		gravityAdjust() -- equivalent call inferred; original call site unknown

		if v2 then
			v2.InitializeDrivingValues()
		end
	end)
end

updateFromConfiguration()
gravityAdjust() -- equivalent call inferred; original call site unknown
workspace.Changed:Connect(function(p)
	if p == "Gravity" then
		gravityAdjust() -- equivalent call inferred; original call site unknown

		if v2 then
			v2.InitializeDrivingValues()
		end
	end
end)
local v11 = nil
local steeringPrismatic = nil
local redressMount = nil

local function getVehicleMotors()
	local cylindricalConstraints = {}

	for _, cylindricalConstraint in pairs(constraints:GetChildren()) do
		if cylindricalConstraint:IsA("CylindricalConstraint") then
			table.insert(cylindricalConstraints, cylindricalConstraint)
		end
	end

	return cylindricalConstraints
end

local function getSprings(p)
	local springConstraints = {}
	local trailer = parent2:FindFirstChild("Trailer")

	local function search(children)
		for _, springConstraint in pairs(children) do
			if not springConstraint:IsA("SpringConstraint") then
				continue
			end

			if p == "StrutFront" then
				if string.find(springConstraint.Name, "StrutSpringF") then
					table.insert(springConstraints, springConstraint)
				end
			elseif p == "StrutRear" then
				if not string.find(springConstraint.Name, "StrutSpringF") and string.find(
					springConstraint.Name,
					"StrutSpring"
				) then
					table.insert(springConstraints, springConstraint)
				end
			elseif p == "TorsionBar" and string.find(springConstraint.Name, "TorsionBarSpring") then
				table.insert(springConstraints, springConstraint)
			end
		end
	end

	search(constraints:GetChildren())

	if trailer then
		search(trailer.Constraints:GetChildren())
	end

	return springConstraints
end

local function getMotorVelocity(p)
	return p.Attachment1.WorldAxis:Dot(p.Attachment1.Parent.RotVelocity)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function adjustSpring(spring, stiffness, damping)
	spring.Stiffness = stiffness
	spring.Damping = damping
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setMotorTorque(motorMaxTorque)
	for _, v12 in pairs(v11) do
		v12.MotorMaxTorque = motorMaxTorque
	end
end

local function setMotorTorqueDamped(p, dot, p2)
	for _, v12 in pairs(v11) do
		if v.MaxSpeed == 0 then
			v12.MotorMaxTorque = 0
		else
			local maxSpeed = v.MaxSpeed

			if p2 < 0 and dot < 0 then
				maxSpeed = v.ReverseSpeed
			end

			local v13 = math.abs(v2.driverSeat.Velocity.Magnitude / maxSpeed)
			v12.MotorMaxTorque = math.exp(v13 * -3 * v13) * p
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setMotorMaxAcceleration(motorMaxAngularAcceleration)
	for _, v12 in pairs(v11) do
		v12.MotorMaxAngularAcceleration = motorMaxAngularAcceleration
	end
end

v2 = {}
v2.root = parent2:FindFirstChild("Chassis")
v2.driverSeat = v2.root:FindFirstChildOfClass("VehicleSeat")
v2.passengerSeats = {
	v2.root:FindFirstChild("SeatFR"),
	v2.root:FindFirstChild("SeatRL"),
	v2.root:FindFirstChild("SeatRR")
}
local v12 = v2.root:FindFirstChild("SuspensionFL").Wheel.Size.y / 2
v2.driverSeat.MaxSpeed = v.MaxSpeed * v12

function v2.InitializeDrivingValues()
	v11 = getVehicleMotors()
	local springs = getSprings("StrutFront")
	local springs2 = getSprings("StrutRear")
	local springs3 = getSprings("TorsionBar")
	redressMount = v2.root:WaitForChild("RedressMount")
	steeringPrismatic = constraints:FindFirstChild("SteeringPrismatic")
	steeringPrismatic.UpperLimit = v.MaxSteer
	steeringPrismatic.LowerLimit = -v.MaxSteer

	for _, spring in pairs(springs) do
		adjustSpring(spring, v5, v6) -- equivalent call inferred; original call site unknown
	end

	for _, spring in pairs(springs2) do
		adjustSpring(spring, v7, v8) -- equivalent call inferred; original call site unknown
	end

	for _, spring in pairs(springs3) do
		adjustSpring(spring, v9, v10) -- equivalent call inferred; original call site unknown
	end

	local children = v2.root:GetChildren()

	for i = 1, #children do
		local model = children[i]

		if not model:IsA("Model") then
			continue
		end

		local wheel = model:FindFirstChild("Wheel")

		if not wheel then
			continue
		end

		local customPhysicalProperties = wheel.CustomPhysicalProperties
		wheel.CustomPhysicalProperties = PhysicalProperties.new(
			customPhysicalProperties.Density,
			v.WheelFriction,
			customPhysicalProperties.Elasticity,
			customPhysicalProperties.FrictionWeight,
			customPhysicalProperties.ElasticityWeight
		)
	end

	setMotorTorque(10000) -- equivalent call inferred; original call site unknown
end

function v2.GetDriverSeat()
	return v2.driverSeat
end

function v2.GetPassengerSeats()
	return v2.passengerSeats
end

function v2.GetBase()
	return v2.root.PrimaryPart or v2.root:FindFirstChild("FloorPanel")
end

function v2.SetMotorVelocity(angularVelocity)
	for _, v13 in pairs(v11) do
		v13.AngularVelocity = angularVelocity
	end
end

function v2.GetAverageVelocity()
	local total = 0

	for _, v13 in pairs(v11) do
		total += v13.Attachment1.WorldAxis:Dot(v13.Attachment1.Parent.RotVelocity)
	end

	return total * (1 / #v11)
end

function v2.EnableHandbrake()
	for _, v13 in pairs(v11) do
		v13.MotorMaxAngularAcceleration = 1e999
	end

	v11[3].MotorMaxTorque = motorMaxTorque2
	v11[4].MotorMaxTorque = motorMaxTorque2
	v11[3].AngularVelocity = 0
	v11[4].AngularVelocity = 0
end

function v2.UpdateSteering(p, p2)
	local driverSeat = v2.GetDriverSeat()
	local _ = v.MaxSpeed
	local maxSteer = v.MaxSteer
	local _ = driverSeat.Velocity
	local v13 = p / (0.2 * (math.abs(p2) / v.MaxSpeed) + 1)
	steeringPrismatic.TargetPosition = v13 * v13 * v13 * maxSteer
end

function v2.UpdateThrottle(p, p2)
	local v13 = 0
	local v14 = false
	local v15 = 0

	if math.abs(p2) < 0.1 then
		for _, v16 in pairs(v11) do
			v16.MotorMaxAngularAcceleration = 1e999
		end

		setMotorTorque(2000) -- equivalent call inferred; original call site unknown
	elseif math.sign(p2 * p) > 0 or math.abs(p) < 0.5 then
		for _, v16 in pairs(v11) do
			v16.MotorMaxAngularAcceleration = 1e999
		end

		local velocity = v2.driverSeat.Velocity
		local dot = velocity.Unit:Dot(v2.driverSeat.CFrame.lookVector)
		setMotorTorqueDamped(v3 * p2 * p2, dot, math.sign(p2))
		local v16 = dot < 0
		local v17 = p2 < 0
		local reverseSpeed = v16 and v17 and v.ReverseSpeed or v.MaxSpeed
		v13 = math.sign(p2) * reverseSpeed
		local _ = (v13 - p) / v13

		local function quad(p3)
			return math.sign(p3) * p3 ^ 2
		end

		local v18 = math.abs(velocity.Magnitude / reverseSpeed * 2.5)
		v15 = math.exp(v18 * -3 * v18)

		if v15 > 0 then
			v14 = true
		end
	else
		setMotorMaxAcceleration(100) -- equivalent call inferred; original call site unknown
		setMotorTorque(motorMaxTorque2 * p2 * p2) -- equivalent call inferred; original call site unknown
		v13 = math.sign(p2) * 500
	end

	v2.SetMotorVelocity(v13)
	Effects:SetThrottleEnabled(v14, v15)
end

local flag = false
local redressTarget = nil

function v2.Redress()
	if flag then
		return
	end

	flag = true
	local position = v2.driverSeat.CFrame.Position + createVector(0, 10, 0)
	local rightVector = v2.driverSeat.CFrame.RightVector
	local unit = Vector3.new(rightVector.x, 0, rightVector.z).Unit

	if not redressTarget then
		redressTarget = redressMount.RedressTarget
	end

	redressTarget.Parent = Workspace.Terrain
	redressTarget.Position = position
	redressTarget.Axis = unit
	redressTarget.SecondaryAxis = createVector(0, 1, 0)
	redressMount.RedressOrientation.Enabled = true
	redressMount.RedressPosition.Enabled = true
	task.wait(1.5)
	redressMount.RedressOrientation.Enabled = false
	redressMount.RedressPosition.Enabled = false
	redressTarget.Parent = redressMount
	task.wait(2)
	flag = false
end

function v2.Reset()
	v2.UpdateThrottle(1, 1)
	v2.UpdateSteering(1, 0)
	v2.EnableHandbrake()
	setMotorTorque(motorMaxTorque2) -- equivalent call inferred; original call site unknown
	v2.SetMotorVelocity(0)
	v2.UpdateSteering(0, 0)
	redressMount.RedressOrientation.Enabled = true
	redressMount.RedressPosition.Enabled = true
	redressMount.RedressOrientation.Enabled = false
	redressMount.RedressPosition.Enabled = false
	flag = false
end

return v2