local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LerpFunction = {}

function LerpFunction.SetUpLerpModel(instance)
	instance:WaitForChild("Humanoid")
	Vector3.new(0, instance.PrimaryPart.Size.Y / 2 + instance.Humanoid.HipHeight, 0)
	local part = Instance.new("Part")
	part.Name = instance.Name .. "GuidePart"
	part.Parent = workspace
	part.CFrame = instance.HumanoidRootPart.CFrame
	part.TopSurface = Enum.SurfaceType.Smooth
	part.Anchored = true
	part.Size = createVector(1, 1, 1)
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Transparency = 1
	local attachment = Instance.new("Attachment")
	attachment.Name = "Attachment0"
	attachment.Parent = instance.PrimaryPart
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "Attachment1"
	attachment2.Parent = part
	local clone = ReplicatedStorage.Parts.AlignPosition:Clone()
	clone.Parent = instance.PrimaryPart
	local clone2 = ReplicatedStorage.Parts.AlignOrientation:Clone()
	clone2.Parent = instance.PrimaryPart
	clone.Attachment0 = attachment
	clone2.Attachment0 = attachment
	clone.Attachment1 = attachment2
	clone2.Attachment1 = attachment2
	part.Anchored = true
	return part
end

function LerpFunction.LerpFunction(instance, instance2, p)
	local position = instance2.Position
	local v = p
	local unit = (v - position).Unit
	local v2 = (v - position).Magnitude + 0.65
	local v3 = position + unit * v2
	local cframe = CFrame.new(v.X, v.Y, v.Z)
	local v4 = instance.PrimaryPart.Size.Y / 2 + instance.Humanoid.HipHeight
	local cframe2 = CFrame.new(0, -v4, 0)
	local cframe3 = CFrame.new(0, v4, 0)
	local cFrame = instance2.CFrame
	local v5 = cframe * cframe3
	local cframe4 = CFrame.lookAt(instance2.Position, v5.Position)
	local v6 = cframe4
	local orientation, v7, v8 = cframe4:ToOrientation()
	local v9 = v5 * CFrame.fromOrientation(0, v7, 0)
	local walkSpeed = instance.Humanoid.WalkSpeed
	local v10 = instance2.CFrame * cframe2
	local v11 = (v10.Position - v).Magnitude / walkSpeed
	local now = tick()
	local total = 0
	local v12 = false
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt
		local v13 = total / v11
		local lerped = cFrame.Position:Lerp(v9.Position, v13)
		local value = TweenService:GetValue(
			math.clamp(total / (1 / walkSpeed), 0.25, 1),
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		local lerped2 = cFrame.Rotation:Lerp(v9.Rotation, value)
		instance2:PivotTo(CFrame.new(lerped) * lerped2)

		if v13 >= 1 then
			v12 = true
			heartbeatConnection:Disconnect()
		end
	end)
	local walkSpeedChangedConnection = nil
	walkSpeedChangedConnection = instance.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if instance.Humanoid.WalkSpeed ~= walkSpeed and instance.Humanoid.Health >= 0 then
			heartbeatConnection:Disconnect()
			walkSpeed = instance.Humanoid.WalkSpeed

			if instance and instance.Parent ~= nil then
				if walkSpeed > 0 then
					position = instance2.Position
					v = p
					unit = (v - position).Unit
					v2 = (v - position).Magnitude + 0.65
					v3 = position + unit * v2
					cframe = CFrame.new(v.X, v.Y, v.Z)
					v4 = instance.PrimaryPart.Size.Y / 2 + instance.Humanoid.HipHeight
					cframe2 = CFrame.new(0, -v4, 0)
					cframe3 = CFrame.new(0, v4, 0)
					cFrame = instance2.CFrame
					v9 = cframe * cframe3
					cframe4 = CFrame.lookAt(instance2.Position, v9.Position)
					v6 = cframe4
					orientation, v7, v8 = cframe4:ToOrientation()
					v9 *= CFrame.fromOrientation(0, v7, 0)
					v10 = instance2.CFrame * cframe2
					v11 = (v10.Position - v).Magnitude / walkSpeed
					now = tick()
					total = 0
					v12 = false
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						total += dt
						local v13 = total / v11
						local lerped = cFrame.Position:Lerp(v9.Position, v13)
						local value = TweenService:GetValue(
							math.min(total / (1 / walkSpeed), 1),
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						)
						local lerped2 = cFrame.Rotation:Lerp(v9.Rotation, value)
						instance2:PivotTo(CFrame.new(lerped) * lerped2)

						if v13 >= 1 then
							v12 = true
							heartbeatConnection:Disconnect()
						end
					end)
				else
					heartbeatConnection = RunService.Heartbeat:Connect(function(_)
						instance2.CFrame = instance.PrimaryPart.CFrame
					end)
				end
			end
		end

		if instance.Parent == nil or not (instance.Humanoid.Health <= 0) then
			return
		end

		walkSpeedChangedConnection:Disconnect()
		heartbeatConnection:Disconnect()
	end)
	instance.Destroying:Connect(function()
		walkSpeedChangedConnection:Disconnect()
		heartbeatConnection:Disconnect()

		if instance2 then
			instance2:Destroy()
		end
	end)

	while true do
		task.wait()

		if instance.Parent ~= nil and instance.Humanoid.Health <= 0 then
			break
		end

		if v12 ~= true then
			continue
		end

		heartbeatConnection:Disconnect()
		walkSpeedChangedConnection:Disconnect()
		break
	end
end

return LerpFunction