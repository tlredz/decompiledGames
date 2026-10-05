local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

local function stopBallMovement(instance)
	local primaryPart = instance.PrimaryPart

	if not primaryPart then
		return
	end

	local constraints = instance:FindFirstChild("Constraints")

	if not constraints then
		return
	end

	local controlAngularVelocity = constraints:FindFirstChild("ControlAngularVelocity")

	if not controlAngularVelocity then
		return
	end

	controlAngularVelocity.AngularVelocity = createVector(0, 0, 0)
	primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	primaryPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

local function getVelocityVector(vector2: Vector3, unit: Vector3)
	if unit.Magnitude > 1 then
		unit = unit.Unit
	end

	local unit2 = (vector2 * createVector(1, 0, 1)).Unit
	return unit2:Cross(createVector(0, 1, 0)) * unit.X - unit2 * unit.Z
end

-- equivalent calls inferred from this helper; original call sites unknown
local function calculatePitch(magnitude: number)
	local v = math.min(9, magnitude / 50 + 1)

	if v < 0.3 then
		return 0.3
	end

	return v
end

local function createBallInputControls(instance)
	local controls = require(StarterPlayer:FindFirstChild("PlayerModule") or Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
	local v = nil
	local body = instance:WaitForChild("Body")

	if not body then
		return
	end

	local exterior = body:WaitForChild("Exterior")

	if not exterior then
		return
	end

	local collisionBall = exterior:WaitForChild("CollisionBall")

	if not collisionBall then
		return
	end

	local v2 = collisionBall.Size.X / 2
	local controlAngularVelocity = instance:WaitForChild("Constraints"):WaitForChild("ControlAngularVelocity")

	if not controlAngularVelocity then
		return
	end

	local controlAlignOrientation = instance:WaitForChild("Constraints"):WaitForChild("ControlAlignOrientation")

	if not controlAlignOrientation then
		return
	end

	if instance.PrimaryPart then
		controlAlignOrientation.CFrame = instance.PrimaryPart.CFrame
	end

	local speed = instance:GetAttribute("Speed")
	local formatted = `'Speed' attribute must be set on {instance:GetFullName()}`
	assert(speed, formatted)
	local currentCamera = Workspace.CurrentCamera
	local steppedConnection = nil
	local flag = false
	local v3 = 1

	local function onStepped()
		local lookVector = currentCamera.CFrame.LookVector
		local moveVector = controls:GetMoveVector()

		if moveVector.Magnitude > 1 then
			moveVector = moveVector.Unit
		end

		local unit = (lookVector * createVector(1, 0, 1)).Unit
		local v4 = unit:Cross(createVector(0, 1, 0)) * moveVector.X - unit * moveVector.Z
		local v5 = speed * v3 / v2
		controlAngularVelocity.AngularVelocity = Vector3.new(v4.Z, 0, -v4.X) * v5

		if controlAlignOrientation and v4 ~= createVector(0, 0, 0) then
			controlAlignOrientation.CFrame = CFrame.lookAt(createVector(0, 0, 0), v4)
		end

		if v and instance.PrimaryPart then
			v.Pitch = calculatePitch(instance.PrimaryPart.AssemblyLinearVelocity.Magnitude)
		end
	end

	return {
		enable = function()
			if flag then
				return
			end

			flag = true
			steppedConnection = RunService.Stepped:Connect(onStepped)

			if v then
				v:Play()
			end
		end,
		disable = function()
			if not flag then
				return
			end

			flag = false
			local v4 = instance
			local primaryPart = v4.PrimaryPart

			if primaryPart then
				local constraints = v4:FindFirstChild("Constraints")
				local controlAngularVelocity2 = constraints and constraints:FindFirstChild("ControlAngularVelocity")

				if controlAngularVelocity2 then
					controlAngularVelocity2.AngularVelocity = createVector(0, 0, 0)
					primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
					primaryPart.AssemblyAngularVelocity = createVector(0, 0, 0)
				end
			end

			if steppedConnection then
				steppedConnection:Disconnect()
				steppedConnection = nil
			end

			if v then
				v:Stop()
			end
		end,
		setSpeed = function(p: number)
			speed = p
		end,
		setBoostMultiplier = function(p: number)
			v3 = p
		end,
		setEngineSound = function(p)
			v = p
		end
	}
end

return createBallInputControls