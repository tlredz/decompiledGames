local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local IceSkatingEffectsVectorForce = {}

function IceSkatingEffectsVectorForce.SetupVectorForce(state, data)
	local rootPart = state.rootPart
	local humanoid = state.humanoid
	rootPart.CustomPhysicalProperties = PhysicalProperties.new(data.density or 0.7, data.friction or 0.02, 0, 100, 0)
	humanoid.MaxSlopeAngle = 89
	local walkSpeedMultiplier = data.walkSpeedMultiplier or 1.5
	state.appliedMultiplier = walkSpeedMultiplier
	local attachment = Instance.new("Attachment")
	attachment.Name = "IceSkatingForceAttachment"
	attachment.Parent = rootPart
	local vectorForce = Instance.new("VectorForce")
	vectorForce.Name = "IceSkatingVectorForce"
	vectorForce.Attachment0 = attachment
	vectorForce.Force = createVector(0, 0, 0)
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Parent = rootPart
	local autoRotate = humanoid.AutoRotate
	humanoid.AutoRotate = false

	local function ShouldPausePhysics()
		local character = state.character

		if not (character and humanoid) or humanoid.Health <= 0 or character:FindFirstChild("Grabbed") then
			return true
		end

		if character:FindFirstChild("Invincible") then
			return true
		end

		local decoding = character:FindFirstChild("Decoding")

		if decoding and decoding.Value ~= nil or character:FindFirstChild("BoxAbilityActive") or character:GetAttribute("HoldAbilityActive") or character:GetAttribute("Transforming") then
			return true
		end

		return false
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not (state.active and rootPart and rootPart.Parent) then
			vectorForce.Force = createVector(0, 0, 0)
		elseif ShouldPausePhysics() then
			vectorForce.Force = createVector(0, 0, 0)
			local character = state.character
			local decoding = character and character:FindFirstChild("Decoding")
			local v = decoding and decoding.Value ~= nil
			local grabbed = character and character:FindFirstChild("Grabbed")
			local transforming = character and character:GetAttribute("Transforming")
			local holdAbilityActive = character and character:GetAttribute("HoldAbilityActive")

			if v or grabbed or transforming or holdAbilityActive then
				local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
				rootPart.AssemblyLinearVelocity = Vector3.new(0, assemblyLinearVelocity.Y, 0)
			end
		else
			local moveDirection = humanoid.MoveDirection
			local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity

			if humanoid:GetState() == Enum.HumanoidStateType.Freefall and assemblyLinearVelocity.Y > 5 then
				rootPart.AssemblyLinearVelocity = Vector3.new(
					assemblyLinearVelocity.X,
					math.max(assemblyLinearVelocity.Y * 0.85, -50),
					assemblyLinearVelocity.Z
				)
			end

			if moveDirection.Magnitude > 0.1 then
				vectorForce.Force = moveDirection * 1400 * rootPart.AssemblyMass
				local cframe = CFrame.lookAt(rootPart.Position, rootPart.Position + moveDirection)
				rootPart.CFrame = rootPart.CFrame:Lerp(cframe, 0.05)
			else
				vectorForce.Force = createVector(0, 0, 0)
			end

			humanoid.PlatformStand = false
		end
	end)
	print("[VectorForce] AutoRotate disabled for drift feel")
	return {
		connection = heartbeatConnection,
		vectorForce = vectorForce,
		attachment = attachment,
		multiplier = walkSpeedMultiplier,
		originalAutoRotate = autoRotate
	}
end

function IceSkatingEffectsVectorForce.SetupGradualSpeedRamp(state, p)
	local humanoid = state.humanoid
	local character = state.character
	local baseWalkSpeed2 = 26

	if character then
		local stats = character:FindFirstChild("Stats")

		if stats then
			local runSpeed = stats:FindFirstChild("RunSpeed")

			if runSpeed then
				baseWalkSpeed2 = runSpeed.Value
				print("[VectorForce] Using RunSpeed from stats:", baseWalkSpeed2)
			end
		end
	end

	if not state.baseWalkSpeed then
		state.baseWalkSpeed = baseWalkSpeed2
		print("[VectorForce] Base skating speed set to RunSpeed:", baseWalkSpeed2)
	end

	local baseWalkSpeed = state.baseWalkSpeed
	local walkSpeed = baseWalkSpeed * (p.walkSpeedMultiplier or 1.15)
	local speedRampDuration = p.speedRampDuration or 1
	humanoid.WalkSpeed = baseWalkSpeed
	local tween = TweenService:Create(
		humanoid,
		TweenInfo.new(speedRampDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			WalkSpeed = walkSpeed
		}
	)
	tween:Play()
	print("[VectorForce] Gradual speed ramp:", baseWalkSpeed, "→", walkSpeed, "over", speedRampDuration, "seconds")
	return {
		tween = tween,
		originalSpeed = baseWalkSpeed
	}
end

function IceSkatingEffectsVectorForce.SetupBodyVelocity(data, data2)
	local rootPart = data.rootPart
	local humanoid = data.humanoid
	rootPart.CustomPhysicalProperties = PhysicalProperties.new(data2.density or 0.7, data2.friction or 0.02, 0, 100, 0)
	humanoid.MaxSlopeAngle = 89
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "IceSkatingBodyVelocity"
	bodyVelocity.MaxForce = createVector(1e999, 0, 1e999)
	bodyVelocity.Velocity = createVector(0, 0, 0)
	bodyVelocity.Parent = rootPart
	local maxSpeed = data2.maxSpeed or 14
	local accelerationFactor = data2.accelerationFactor or 0.5
	local frictionFactor = data2.frictionFactor or 0.8
	local velocity = createVector(0, 0, 0)

	local function ShouldPausePhysics()
		local character = data.character

		if not (character and humanoid) or humanoid.Health <= 0 or character:FindFirstChild("Grabbed") then
			return true
		end

		if character:FindFirstChild("Invincible") then
			return true
		end

		local decoding = character:FindFirstChild("Decoding")

		if decoding and decoding.Value ~= nil or character:FindFirstChild("BoxAbilityActive") or character:GetAttribute("HoldAbilityActive") or character:GetAttribute("Transforming") then
			return true
		end

		return false
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not (data.active and rootPart and rootPart.Parent) then
			bodyVelocity.Velocity = createVector(0, 0, 0)
		elseif ShouldPausePhysics() then
			bodyVelocity.Velocity = createVector(0, 0, 0)
			velocity = createVector(0, 0, 0)
			local character = data.character
			local decoding = character and character:FindFirstChild("Decoding")
			local v2 = decoding and decoding.Value ~= nil
			local grabbed = character and character:FindFirstChild("Grabbed")
			local transforming = character and character:GetAttribute("Transforming")
			local holdAbilityActive = character and character:GetAttribute("HoldAbilityActive")

			if v2 or grabbed or transforming or holdAbilityActive then
				local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
				rootPart.AssemblyLinearVelocity = Vector3.new(0, assemblyLinearVelocity.Y, 0)
			end
		else
			local moveDirection = humanoid.MoveDirection
			local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity

			if humanoid:GetState() == Enum.HumanoidStateType.Freefall and assemblyLinearVelocity.Y > 5 then
				rootPart.AssemblyLinearVelocity = Vector3.new(
					assemblyLinearVelocity.X,
					math.max(assemblyLinearVelocity.Y * 0.85, -50),
					assemblyLinearVelocity.Z
				)
			end

			if moveDirection.Magnitude > 0.1 then
				local v2 = moveDirection * maxSpeed
				velocity = velocity:Lerp(v2, accelerationFactor)
			else
				velocity *= frictionFactor
			end

			bodyVelocity.Velocity = velocity
		end
	end)
	print(
		"[BodyVelocity] System enabled - Max speed:",
		maxSpeed,
		"Accel:",
		accelerationFactor,
		"Friction:",
		frictionFactor
	)
	return {
		connection = heartbeatConnection,
		bodyVelocity = bodyVelocity
	}
end

return IceSkatingEffectsVectorForce