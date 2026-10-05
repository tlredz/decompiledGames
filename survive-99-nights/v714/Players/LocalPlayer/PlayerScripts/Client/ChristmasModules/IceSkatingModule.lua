local createVector = vector.create
local IceSkatingModule = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local flag = false
local v = nil
local track = nil

function IceSkatingModule.IsIceSkating()
	return flag
end

function IceSkatingModule.StartSkating()
	Client.WalkspeedController.SetOverallSpeed("IceSkating", 0, "Vehicle")

	if Client.SledClient.IsSledding() then
		Client.SledClient.RequestExitSled()
	end

	Client.Sound.Play("IceSkating")
	flag = true
	local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")
	local humanoid = localPlayer.Character:WaitForChild("Humanoid")
	humanoid.HipHeight = 0.4
	track = humanoid:LoadAnimation(game.ReplicatedStorage.Core.Animations.Character.IceSkate)
	track:Play()
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = humanoidRootPart.RootAttachment
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = createVector(100000, 0, 100000)
	linearVelocity.Parent = humanoidRootPart
	v = linearVelocity
	linearVelocity.VectorVelocity = humanoidRootPart.Velocity * createVector(1, 0, 1)
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = humanoidRootPart.RootAttachment
	alignOrientation.RigidityEnabled = false
	alignOrientation.Responsiveness = 50
	alignOrientation.Parent = humanoidRootPart
	local attachment = Instance.new("Attachment")
	attachment.Position = createVector(-0.6, -3.39, -0.5)
	attachment.Parent = humanoidRootPart
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = createVector(-0.65, -3.39, -0.5)
	attachment2.Parent = humanoidRootPart
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Lifetime = 10
	trail.Brightness = 5
	trail.LightEmission = 1
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
	trail.Parent = humanoidRootPart
	local attachment3 = Instance.new("Attachment")
	attachment3.Position = createVector(0.6, -3.39, -0.5)
	attachment3.Parent = humanoidRootPart
	local attachment4 = Instance.new("Attachment")
	attachment4.Position = createVector(0.65, -3.39, -0.5)
	attachment4.Parent = humanoidRootPart
	local clone = trail:Clone()
	clone.Attachment0 = attachment3
	clone.Attachment1 = attachment4
	clone.Parent = humanoidRootPart
	local enabled = false
	local enabled2 = true
	trail.Enabled = false
	clone.Enabled = false
	Vector3.new()
	local v4 = 0
	local v5 = nil
	local count = 0

	local function touchIceGate(otherPart)
		otherPart.BrickColor = BrickColor.new("Sea green")
		task.delay(2, function()
			otherPart.Color = Color3.fromRGB(255, 152, 220)
		end)
		local gateNumber = otherPart:GetAttribute("GateNumber")

		if gateNumber == 1 then
			local flag2 = false

			if v5 == otherPart.Parent:GetAttribute("NumberGates") then
				count += 1
				local parent = otherPart.Parent.Parent

				if count >= 3 and parent:GetAttribute("LapsComplete") == nil then
					Client.Events.IceSkatingLapsComplete:Fire(parent)
					flag2 = true
				end
			end

			if flag2 then
				Client.Interface.LapCounterLabel.Text = "Challenge complete!"
			else
				Client.Interface.LapCounterLabel.Text = "Laps: " .. count
			end

			Client.Interface.LapCounterLabel.Visible = true
			v5 = 1
		elseif v5 and gateNumber == v5 + 1 then
			v5 = gateNumber
		end
	end

	local touchedConnection = humanoidRootPart.Touched:Connect(function(otherPart)
		if otherPart.Name == "IceRaceGate" then
			touchIceGate(otherPart)
		end
	end)

	while Client.PlayerHandler.Alive do
		local v6 = task.wait()

		if not linearVelocity.Parent then
			break
		end

		local position = humanoidRootPart.Position
		local raycastResult = workspace:Raycast(
			position,
			createVector(0, -20, 0),
			Client.CollisionUtility.DefaultParams
		)

		if raycastResult == nil then
			break
		end

		local magnitude = (raycastResult.Position - humanoidRootPart.Position).Magnitude

		if magnitude < 3.41 and raycastResult.Material ~= Enum.Material.Ice then
			break
		end

		local moveDirection = humanoid.MoveDirection
		humanoid.HipHeight = 0.4
		local vectorVelocity = linearVelocity.VectorVelocity
		local _ = humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)

		if IsNaN(vectorVelocity) then
			vectorVelocity = Vector3.new()
		end

		local v7 = moveDirection * 25 * v6

		if moveDirection.Magnitude < 0.1 then
			local magnitude2 = vectorVelocity.Magnitude

			if 35 * v6 < magnitude2 then
				v7 = -vectorVelocity.Unit * 35 * v6
			else
				v7 = -vectorVelocity
			end
		end

		local vectorVelocity2 = vectorVelocity + v7
		local v9 = Client.WalkspeedController.IsSprinting() and 50 or 30

		if v9 < vectorVelocity2.Magnitude then
			vectorVelocity2 = vectorVelocity2.Unit * v9
		end

		local unit = vectorVelocity2.Unit
		local angleBetweenVectors, v10 = Client.Utility.GetAngleBetweenVectors(unit, moveDirection)
		local v11 = 1.2217304763960306 * v6
		local v12 = math.min(angleBetweenVectors, v11) * v10

		if moveDirection.Magnitude > 0.1 then
			if math.abs(v12) < v11 then
				vectorVelocity2 = CFrame.lookAlong(humanoidRootPart.Position, moveDirection).LookVector * vectorVelocity2.Magnitude
			else
				vectorVelocity2 = (CFrame.lookAlong(humanoidRootPart.Position, vectorVelocity2.Unit) * CFrame.Angles(
					0,
					v12,
					0
				)).LookVector * vectorVelocity2.Magnitude
			end
		end

		linearVelocity.VectorVelocity = vectorVelocity2
		local unit2 = vectorVelocity2.Unit

		if not IsNaN(unit2) then
			alignOrientation.CFrame = CFrame.lookAlong(humanoidRootPart.Position, vectorVelocity2.Unit)
		end

		local timePosition = track.TimePosition

		if v4 < 0.4 and timePosition > 0.4 then
			enabled = true
			enabled2 = false
		elseif v4 < 1.15 and timePosition > 1.15 then
			enabled = false
			enabled2 = true
		end

		if magnitude > 3.41 then
			clone.Enabled = false
			trail.Enabled = false
		else
			clone.Enabled = enabled
			trail.Enabled = enabled2
		end

		local v13 = math.clamp(vectorVelocity2.Magnitude / 30, 0.2, 2)
		local v14 = magnitude > 3.41 and 0.4 or v13
		track:AdjustSpeed(v14)
		v4 = timePosition
	end

	humanoid.HipHeight = 0
	IceSkatingModule.StopSkating()
	Client.Interface.LapCounterLabel.Visible = false
	touchedConnection:Disconnect()
	local worldCFrame = attachment.WorldCFrame
	local worldCFrame2 = attachment2.WorldCFrame
	attachment.Parent = workspace.Terrain
	attachment2.Parent = workspace.Terrain
	attachment.WorldCFrame = worldCFrame
	attachment2.WorldCFrame = worldCFrame2
	local worldCFrame3 = attachment3.WorldCFrame
	local worldCFrame4 = attachment4.WorldCFrame
	attachment3.Parent = workspace.Terrain
	attachment4.Parent = workspace.Terrain
	attachment3.WorldCFrame = worldCFrame3
	attachment4.WorldCFrame = worldCFrame4
	alignOrientation:Destroy()
	task.delay(11, function()
		attachment:Destroy()
		attachment2:Destroy()
		trail:Destroy()
		attachment3:Destroy()
		attachment4:Destroy()
		clone:Destroy()
	end)
end

localPlayer.CharacterAdded:Connect(function()
	if flag then
		IceSkatingModule.StopSkating()
	end
end)

function IceSkatingModule.StopSkating()
	flag = false
	Client.Events.StopSound:Fire("IceSkating", {
		FadeTime = 0.2
	})

	if v then
		v:Destroy()
		v = nil
	end

	if track then
		track:Stop()
		track = nil
	end

	Client.WalkspeedController.RemoveSpeedChange("IceSkating")
end

function TrackSlippingOnIce(instance)
	WalkingOnIce = true
	local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")
	local humanoid = localPlayer.Character:WaitForChild("Humanoid")
	local total = 0

	if instance and instance:GetAttribute("VerySlippery") then
		print("VERY SLIPPERY")
	end

	local position = humanoidRootPart.Position

	while Client.PlayerHandler.Alive do
		local v2 = task.wait()
		local position2 = humanoidRootPart.Position
		local raycastResult = workspace:Raycast(
			position2,
			createVector(0, -20, 0),
			Client.CollisionUtility.DefaultParams
		)

		if raycastResult == nil or raycastResult.Material ~= Enum.Material.Ice then
			break
		end

		local magnitude = (raycastResult.Position - humanoidRootPart.Position).Magnitude
		local _ = ((position2 - position) * createVector(1, 0, 1)).Magnitude
		total += humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed * v2

		if not (magnitude < 3.01 and raycastResult.Material == Enum.Material.Ice and total >= 16) then
			continue
		end

		SlipOnIce()
		break
	end

	WalkingOnIce = false
end

function SlipOnIce()
	SlippingOnIce = true

	if Client.SledClient.IsSledding() then
		Client.SledClient.RequestExitSled()
	end

	Client.Sound.Play("SlipIce")
	Client.Events.PlayAnimation:Fire("SlipOnIce")
	Client.WalkspeedController.SetOverallSpeed("SlipOnIce", 0, "Vehicle")
	task.delay(3.5, function()
		Client.WalkspeedController.RemoveSpeedChange("SlipOnIce")
		SlippingOnIce = false
	end)
end

function IsNaN(p)
	return p ~= p
end

function CharacterAdded(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		if not Client.PlayerHandler.Alive then
			return
		end

		if humanoid.FloorMaterial == Enum.Material.Ice then
			while localPlayer.Character and humanoid.FloorMaterial == Enum.Material.Ice do
				local position = humanoidRootPart.Position
				local raycastResult = workspace:Raycast(
					position,
					createVector(0, -5, 0),
					Client.CollisionUtility.DefaultParams
				)
				local magnitude = raycastResult and (raycastResult.Position - humanoidRootPart.Position).Magnitude

				if raycastResult and magnitude < 3.01 and not (flag or SlippingOnIce or WalkingOnIce) then
					if localPlayer:GetAttribute("IceSkates") then
						IceSkatingModule.StartSkating()
					else
						TrackSlippingOnIce(raycastResult.Instance)
					end
				end

				task.wait()
			end
		end
	end)
end

function IceSkatingModule.Init() end

return IceSkatingModule