local createVector = vector.create
local character = game.Players.LocalPlayer.Character
local humanoidRootPart = character.HumanoidRootPart
local value = script:WaitForChild("Car").Value
local configurations = value:WaitForChild("Configurations")
local RaycastModule = require(value.CarScript.RaycastModule)
local vector2 = Vector2.new()
value.DriveSeat.Changed:connect(function(p)
	if p == "Steer" then
		vector2 = Vector2.new(value.DriveSeat.Steer, vector2.Y)
	elseif p == "Throttle" then
		vector2 = Vector2.new(vector2.X, value.DriveSeat.Throttle)
	end
end)
local total = 0

for _, part in pairs(value:GetChildren()) do
	if part:IsA("BasePart") then
		total += part:GetMass() * 196.2
	end
end

local v = total * configurations.Suspension.Value
local v2 = v / configurations.Bounce.Value
local bodyVelocity = Instance.new("BodyVelocity", value.Chassis)
bodyVelocity.velocity = createVector(0, 0, 0)
bodyVelocity.maxForce = createVector(0, 0, 0)
local bodyAngularVelocity = Instance.new("BodyAngularVelocity", value.Chassis)
bodyAngularVelocity.angularvelocity = createVector(0, 0, 0)
bodyAngularVelocity.maxTorque = createVector(0, 0, 0)
local total2 = 0

local function UpdateThruster(child)
	local bodyThrust = child:FindFirstChild("BodyThrust") or Instance.new("BodyThrust", child)
	local v3, v4 = RaycastModule.new(
		child.Position,
		child.CFrame:vectorToWorldSpace(createVector(0, -1, 0)) * configurations.Height.Value
	)
	local magnitude = (v4 - child.Position).magnitude

	if v3 and v3.CanCollide then
		bodyThrust.force = Vector3.new(
			0,
			(configurations.Height.Value - magnitude) ^ 2 * (v / configurations.Height.Value ^ 2),
			0
		)
		local v5 = child.CFrame:toObjectSpace(CFrame.new(child.Velocity + child.Position)).p * v2
		bodyThrust.force -= Vector3.new(0, v5.Y, 0)
	else
		bodyThrust.force = createVector(0, 0, 0)
	end

	local wheelWeld = child:FindFirstChild("WheelWeld")

	if wheelWeld then
		wheelWeld.C0 = CFrame.new(
			0,
			-math.min(magnitude, configurations.Height.Value * 0.8) + wheelWeld.Part1.Size.Y / 2,
			0
		)
		local v5 = value.Chassis.CFrame:inverse() * child.CFrame
		local vectorToObjectSpace = value.Chassis.CFrame:vectorToObjectSpace(value.Chassis.Velocity)

		if v5.Z < 0 then
			local v6 = vectorToObjectSpace.Z > 0 and -1 or 1
			wheelWeld.C0 *= CFrame.Angles(0, value.Chassis.RotVelocity.Y / 2 * v6, 0)
		end

		wheelWeld.C0 *= CFrame.Angles(total2, 0, 0)
	end
end

local function IsGrounded()
	if not value:FindFirstChild("Chassis") then
		return
	end

	local v3, _ = RaycastModule.new(
		(value.Chassis.CFrame * CFrame.new(0, 0, value.Chassis.Size.Z / 2 - 1)).p,
		value.Chassis.CFrame:vectorToWorldSpace(createVector(0, -1, 0)) * (configurations.Height.Value + 0.2)
	)

	if v3 and v3.CanCollide then
		return true
	end

	return false
end

while value:FindFirstChild("DriveSeat") and character.Humanoid.SeatPart == value.DriveSeat do
	local v3 = task.wait()

	if IsGrounded() then
		if vector2.Y == 0 then
			bodyVelocity.maxForce = Vector3.new(total / 2, total / 4, total / 2)
		else
			local v5 = humanoidRootPart.CFrame.lookVector * vector2.Y * configurations.Speed.Value
			humanoidRootPart.Velocity = humanoidRootPart.Velocity:Lerp(v5, 0.1)
			bodyVelocity.maxForce = createVector(0, 0, 0)
		end

		local cFrame = humanoidRootPart.CFrame
		local Y = vector2.Y
		local vectorToWorldSpace = cFrame:vectorToWorldSpace((Vector3.new(
			Y * configurations.Speed.Value / 50,
			0,
			-humanoidRootPart.RotVelocity.Y * 5 * vector2.Y
		)))
		local v4 = -humanoidRootPart.CFrame:vectorToObjectSpace(humanoidRootPart.Velocity).unit.Z
		total2 += math.rad(-configurations.Speed.Value / 5 * vector2.Y)

		if math.abs(v4) > 0.1 then
			local cFrame2 = humanoidRootPart.CFrame
			local v5 = -vector2.X * v4
			vectorToWorldSpace += cFrame2:vectorToWorldSpace((Vector3.new(0, v5 * configurations.TurnSpeed.Value, 0)))
			bodyAngularVelocity.maxTorque = createVector(0, 0, 0)
		else
			bodyAngularVelocity.maxTorque = Vector3.new(total / 4, total / 2, total / 4)
		end

		humanoidRootPart.RotVelocity = humanoidRootPart.RotVelocity:Lerp(vectorToWorldSpace, 6 * v3)
	else
		bodyVelocity.maxForce = createVector(0, 0, 0)
		bodyAngularVelocity.maxTorque = createVector(0, 0, 0)
	end

	for _, child in pairs(value:GetChildren()) do
		if child.Name == "Thruster" then
			UpdateThruster(child)
		end
	end
end

for _, child in pairs(value:GetChildren()) do
	if child:FindFirstChild("BodyThrust") then
		child.BodyThrust:Destroy()
	end
end

bodyVelocity:Destroy()
bodyAngularVelocity:Destroy()
script:Destroy()