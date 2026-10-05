local createVector = vector.create
local SledClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local UserInputService = game:GetService("UserInputService")
local folder = nil
Client.InteractionHandler.RegisterInteraction("Sled", function(p)
	SledClient.RequestEnterSled(p)
end)

function IsNaN(p)
	return p ~= p
end

function SledClient.IsSledding()
	return folder ~= nil
end

function StartDrivingSled()
	local v = folder
	local primaryPart = v.PrimaryPart
	local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
	localPlayer.Character:FindFirstChild("Torso")
	local part = Instance.new("Part")
	part.Size = createVector(5, 2, 8)
	part.Transparency = 1
	part.Massless = true
	part.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0.5, -(part.Size.Z / 2))
	part.Name = "SledZone"
	part.CollisionGroup = "Vehicles"
	local attachment = Instance.new("Attachment", part)
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	linearVelocity.MaxAxesForce = createVector(100000, 0, 100000)
	linearVelocity.Parent = part
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment
	alignOrientation.RigidityEnabled = true
	alignOrientation.Parent = part
	alignOrientation.CFrame = CFrame.lookAlong(
		Vector3.new(),
		(humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)).Unit
	)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = part
	weldConstraint.Part1 = humanoidRootPart
	weldConstraint.Parent = part
	part.Parent = workspace.Particles
	Client.WalkspeedController.SetOverallSpeed("Sled", 0, "Vehicle")
	humanoid.AutoRotate = false
	Vector3.new()
	local v2, v3, v4

	if v.Name == "Admin Sled" then
		v2 = 500
		v3 = 1
		v4 = 150
	else
		v2 = 25
		v3 = 2
		v4 = 50
	end

	local flag = false
	local total = 0
	local steppedConnection = nil
	task.spawn(function()
		local RunService = game:GetService("RunService")
		steppedConnection = RunService.Stepped:Connect(function() end)

		while Client.PlayerHandler.Alive do
			local v5 = task.wait()

			if not humanoidRootPart.Parent or folder ~= v then
				break
			end

			local moveDirection = humanoid.MoveDirection
			local vectorVelocity = linearVelocity.VectorVelocity
			local v6 = humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)

			if IsNaN(vectorVelocity) then
				vectorVelocity = Vector3.new()
			end

			local vector2

			if flag then
				vector2 = Vector3.new()
			else
				vector2 = moveDirection
			end

			local v7 = vector2 * v2 * v5

			if vector2.Magnitude < 0.1 then
				local v8 = flag and v3 or 35
				local magnitude = vectorVelocity.Magnitude

				if v8 * v5 < magnitude then
					v7 = -vectorVelocity.Unit * v8 * v5
				else
					v7 = -vectorVelocity
				end
			end

			local vectorVelocity2 = vectorVelocity + v7
			local v9 = v4

			if v9 < vectorVelocity2.Magnitude then
				vectorVelocity2 = vectorVelocity2.Unit * v9
			end

			if v6.Magnitude > 5 and vectorVelocity2.Magnitude > v6.Magnitude * 3 then
				vectorVelocity2 = vectorVelocity2.Unit * v6.Magnitude
			end

			local v10 = math.clamp(vectorVelocity2.Magnitude / v9, 0, 1) * 220
			local lookVector = alignOrientation.CFrame.LookVector
			local unit = vectorVelocity2.Unit
			local lookVector2 = humanoidRootPart.CFrame.LookVector

			if math.deg((Client.Utility.GetAngleBetweenVectors(unit, lookVector2))) > 160 then
				unit = -unit
			end

			if flag then
				if moveDirection.Magnitude > 0.1 then
					unit = (moveDirection * createVector(1, 0, 1)).Unit
				else
					unit = (humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)).Unit
				end
			end

			local angleBetweenVectors, v11 = Client.Utility.GetAngleBetweenVectors(lookVector, unit)
			local v12 = math.rad(v10) * v5
			local v13 = math.min(angleBetweenVectors, v12) * v11
			local magnitude = vectorVelocity2.Magnitude

			if v4 - 1 <= magnitude and not flag and math.deg((math.abs(angleBetweenVectors))) < 45 then
				print("Start skating")
				flag = true
				Client.Sound.Play("SledPushing")
				localPlayer:SetAttribute("Sledding", true)
				Client.Events.PlayAnimation:Fire("SledSit")
			elseif (vectorVelocity2.Magnitude < 25 or v6.Magnitude < 25) and flag then
				print("Stop skating")
				Client.Events.StopSound:Fire("SledPushing", {
					FadeTime = 0.2
				})
				flag = false
				localPlayer:SetAttribute("Sledding", nil)
				Client.Events.StopAnimation:Fire("SledSit")
				vectorVelocity2 = vectorVelocity2.Unit * 25
			end

			if flag then
				if math.abs(v13) < v12 then
					alignOrientation.CFrame = CFrame.lookAlong(alignOrientation.CFrame.Position, unit)
				else
					alignOrientation.CFrame *= CFrame.Angles(0, v13, 0)
				end

				linearVelocity.VectorVelocity = alignOrientation.CFrame.LookVector * vectorVelocity2.Magnitude
			else
				linearVelocity.VectorVelocity = vectorVelocity2

				if math.abs(v13) < v12 then
					alignOrientation.CFrame = CFrame.lookAlong(alignOrientation.CFrame.Position, unit)
				else
					alignOrientation.CFrame *= CFrame.Angles(0, v13, 0)
				end
			end

			local size = part.Size
			local v14 = humanoidRootPart.Position.Y - 2
			local v15 = part.CFrame * CFrame.new(-size.X / 2, 0, -size.Z / 2)
			local v16 = part.CFrame * CFrame.new(size.X / 2, 0, -size.Z / 2)
			local v17 = part.CFrame * CFrame.new(-size.X / 2, 0, size.Z / 2)
			local v18 = part.CFrame * CFrame.new(size.X / 2, 0, size.Z / 2)
			local groundPosition = Client.CollisionUtility.GetGroundPosition(v15.Position)
			local groundPosition2 = Client.CollisionUtility.GetGroundPosition(v16.Position)
			local groundPosition3 = Client.CollisionUtility.GetGroundPosition(v17.Position)
			local groundPosition4 = Client.CollisionUtility.GetGroundPosition(v18.Position)
			local Y = groundPosition and groundPosition.Y
			local Y2 = groundPosition2 and groundPosition2.Y

			if groundPosition3 then
				local _ = groundPosition3.Y
			end

			if groundPosition4 then
				local _ = groundPosition4.Y
			end

			local v19

			if Y and Y2 then
				v19 = math.max(Y, Y2)
			else
				v19 = Y or Y2 or v14
			end

			local v20 = math.clamp(v19, v14 - 2, v14 + 1)
			local v21 = humanoidRootPart.Position.Y - 2.4
			local unit2 = (humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)).Unit
			local v22 = CFrame.lookAlong(humanoidRootPart.Position, unit2) * CFrame.new(0, 0, -4.5)
			local v23 = v22 + Vector3.new(0, (v20 + v21) / 2 - v22.Y + 0.25, 0)
			local Z = part.Size.Z
			local v24 = v20 - v21
			local v25 = (not (math.abs(v24) > 0.01) and 0 or math.asin(v24 / Z)) - total
			total += v25 * 8 * v5
			local cFrame = v23 * CFrame.Angles(total, 0, 0)
			primaryPart.AlignPosition.Position = cFrame.Position
			primaryPart.AlignOrientation.CFrame = cFrame
			primaryPart.AlignPosition.Enabled = true
			primaryPart.AlignOrientation.Enabled = true
			v:PivotTo(cFrame)
		end

		part:Destroy()
		Client.Events.StopAnimation:Fire("SledSit")
		steppedConnection:Disconnect()
	end)
end

localPlayer.CharacterAdded:Connect(function()
	SledClient.RequestExitSled()
end)

function SledClient.RequestEnterSled(instance)
	if folder or not Client.PlayerHandler.Alive or instance:GetAttribute("Driver") or not localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	if Client.IceSkatingModule.IsIceSkating() then
		return
	end

	Client.Events.StopDraggingItem:Fire()
	Client.Events.PlayAnimation:Fire("SledPush")
	instance:SetAttribute("LocalDriver", localPlayer.UserId)
	task.delay(1.5, function()
		instance:SetAttribute("LocalDriver", nil)
	end)
	Client.Events.RequestEnterSled:FireServer(instance)
	folder = instance

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	local pivot = instance:GetPivot()
	local _ = pivot - pivot.Position + localPlayer.Character:GetPivot().Position
	StartDrivingSled()
end

function SledClient.RequestExitSled()
	if not folder then
		return
	end

	print("Exit sled")
	Client.Events.StopSound:Fire("SledPushing", {
		FadeTime = 0.2
	})
	Client.Events.StopAnimation:Fire("SledPush")
	localPlayer:SetAttribute("Sledding", nil)

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = true
		part.CanQuery = true
		part.CanTouch = true
	end

	folder.Engine.AlignPosition.Enabled = false
	folder.Engine.AlignOrientation.Enabled = false
	Client.Events.RequestExitSled:FireServer(folder)
	Client.WalkspeedController.RemoveSpeedChange("Sled")
	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.AutoRotate = true
	end

	folder = nil
end

function SledAdded(instance)
	local function updateAvailable()
		if instance == folder and instance:GetAttribute("Driver") and instance:GetAttribute("Driver") ~= localPlayer.UserId then
			SledClient.RequestExitSled()
		end

		local proximityInteraction = instance:WaitForChild("Engine"):WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")

		if instance:GetAttribute("Driver") or instance:GetAttribute("LocalDriver") then
			proximityInteraction.Enabled = false
			instance:RemoveTag("Interaction")
		else
			proximityInteraction.Enabled = true
			instance:AddTag("Interaction")
		end
	end

	instance:GetAttributeChangedSignal("Driver"):Connect(updateAvailable)
	instance:GetAttributeChangedSignal("LocalDriver"):Connect(updateAvailable)
	updateAvailable()
end

UserInputService.JumpRequest:Connect(function()
	if folder then
		SledClient.RequestExitSled()
	end
end)

function SledClient.Init()
	task.spawn(function()
		Client.Utility.ForAllTagged("Sled", SledAdded)
	end)
end

return SledClient