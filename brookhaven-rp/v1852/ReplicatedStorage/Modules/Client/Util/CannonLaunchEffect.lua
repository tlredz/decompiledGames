local createVector = vector.create
local RunService = game:GetService("RunService")
return function(instance, vector2: Vector3, p: number, p2: number)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local rootAttachment = humanoidRootPart:FindFirstChild("RootAttachment")

	if not rootAttachment then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Parent = humanoidRootPart
	attachment.WorldCFrame = CFrame.new(
		humanoidRootPart.CFrame.Position,
		humanoidRootPart.CFrame.Position + humanoidRootPart.AssemblyLinearVelocity.Unit
	)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Massless = true
	part.CanQuery = false
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.Parent = workspace
	part.CFrame = CFrame.new(humanoidRootPart.CFrame.Position, humanoidRootPart.CFrame.Position + vector2)
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = part
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.AlignType = Enum.AlignType.AllAxes
	alignOrientation.Attachment0 = rootAttachment
	alignOrientation.Attachment1 = attachment2
	alignOrientation.Parent = humanoidRootPart
	alignOrientation.Responsiveness = 200
	alignOrientation.MaxAngularVelocity = 500
	alignOrientation.MaxTorque = 5000
	alignOrientation.RigidityEnabled = false
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		attachment2.CFrame *= CFrame.Angles(0, 15.707963267948966 * dt, 0)
		attachment.WorldCFrame = CFrame.new(
			humanoidRootPart.CFrame.Position,
			humanoidRootPart.CFrame.Position + humanoidRootPart.AssemblyLinearVelocity.Unit
		)
	end)
	local vectorForce = Instance.new("VectorForce")
	vectorForce.Parent = humanoidRootPart
	vectorForce.Attachment0 = rootAttachment
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Force = createVector(0, 1, 0) * workspace.Gravity * humanoidRootPart.AssemblyMass
	vectorForce.ApplyAtCenterOfMass = true
	vectorForce.Enabled = true
	humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
	humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.CFrame.Position, humanoidRootPart.CFrame.Position + vector2) * CFrame.Angles(
		1.5707963267948966,
		0,
		0
	)
	humanoidRootPart:ApplyImpulse(vector2.Unit * humanoidRootPart.AssemblyMass * p)
	task.delay(0.2, function()
		alignOrientation.Attachment1 = attachment
		vectorForce:Destroy()
	end)
	local lastTime = tick()

	repeat
		task.wait(0.1)
	until instance:FindFirstChild("Glider") and tick() - lastTime > 0.2 or p2 < tick() - lastTime

	renderSteppedConnection:Disconnect()
	alignOrientation:Destroy()
	part:Destroy()
	attachment2:Destroy()

	if instance:FindFirstChild("Glider") and tick() - lastTime > 0.5 then
		RunService.Stepped:Wait()
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		humanoidRootPart.CFrame = CFrame.new(
			humanoidRootPart.CFrame.Position,
			humanoidRootPart.CFrame.Position + humanoidRootPart.AssemblyLinearVelocity.Unit
		)
	end
end