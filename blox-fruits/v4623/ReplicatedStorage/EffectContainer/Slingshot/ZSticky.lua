local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local _ = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local slingshot_Z = FX:WaitForChild("Slingshot").Slingshot_Z
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function ParticleState(folder, enabled, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end
	end
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local random = Random.new()
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function AnimateOctopus(clone, folder, p, p2)
	task.spawn(function()
		for _, child in clone:GetChildren() do
			if string.sub(child.Name, 1, 7) ~= "OctoArm" then
				continue
			end

			local v2 = child
			task.spawn(function()
				local v3

				if p2 then
					v3 = random:NextNumber(0.2, 0.5)
				else
					v3 = random:NextNumber(1, 3)
				end

				local number = random:NextNumber(-7, 7)

				while clone.Parent == folder do
					TweenService:Create(
						v2:WaitForChild("Arm"),
						TweenInfo.new(v3 / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
						{
							CurveSize1 = number
						}
					):Play()

					if clone:GetAttribute("Grabbed") ~= true then
						local tween = TweenService:Create(
							v2.B,
							TweenInfo.new(v3 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true),
							{
								Position = Vector3.new(
									random:NextNumber(-8, 8),
									random:NextNumber(0, 3),
									random:NextNumber(-8, 8)
								)
							}
						)
						tween:Play()
						v[v2] = tween
						task.delay(v3, function()
							if table.find(v, tween) then
								v[v2] = nil
							end

							tween:Destroy()
						end)
					end

					task.wait(v3)
				end
			end)
		end

		local v2 = 0.25

		if p == true then
			local attributeChangedConnection = nil
			attributeChangedConnection = clone.AttributeChanged:Connect(function(attributeName)
				if clone:GetAttribute(attributeName) == true then
					v2 = 0.02
					return
				end

				v2 = 0.25
				attributeChangedConnection:Disconnect()
			end)
		end

		while clone.Parent == folder do
			if clone:WaitForChild("OctoHead").Particles.Head.Enabled == false then
				break
			end

			local clone2 = slingshot_Z["InkDrop" .. math.random(1, 2)]:Clone()
			clone2.Position = clone:WaitForChild("OctoHead").Position
			clone2.Parent = folder
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = Vector3.new(
				random:NextNumber(-1, 1),
				random:NextNumber(0.5, 1),
				random:NextNumber(-1, 1)
			).Unit * random:NextNumber(10, 30)
			bodyVelocity.Parent = clone2
			task.delay(random:NextNumber(0.2, 0.4), bodyVelocity.Destroy, bodyVelocity)
			local raycastResult = workspace:Raycast(clone2.Position, clone2.Velocity.Unit * 3, raycastParams)
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				raycastResult = workspace:Raycast(clone2.Position, clone2.Velocity.Unit * 3, raycastParams)

				if raycastResult then
					heartbeatConnection:Disconnect()
					clone2.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					)
					clone2.Anchored = true
					local folder2 = clone2

					for i, emitter in pairs(folder2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					task.delay(4, function()
						clone2:Destroy()
					end)
				end
			end)
			task.wait(v2)
		end
	end)
end

return function(player)
	local origin = player.origin
	local _ = player.dir

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	if player.stage == 1 then
		local tool = player.tool
		local holding = player.holding or tool and tool:FindFirstChild("Holding")

		if not holding then
			return
		end

		local hrp = player.hrp
		local holdKey = player.holdKey or player.userId or not player.Character and "unknown" or player.Character.Name or "unknown"
		local folder = Instance.new("Folder")
		folder.Name = "OctopusHoldEffect_" .. tostring(holdKey)
		folder.Parent = _WorldOrigin
		local equippedAttachment = Util.GetEquippedAttachment(player.Character, player.Attachment)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getAttachmentCFrame()
			if equippedAttachment then
				return equippedAttachment.WorldCFrame
			end

			return hrp.CFrame
		end

		local clone = slingshot_Z.Octopus:Clone()
		clone:ScaleTo(0.2)

		for _, beam in clone:GetDescendants() do
			if beam.Name == "Arm" and beam:IsA("Beam") then
				beam.Width0 = 1.6
			end
		end

		local attachmentCFrame = getAttachmentCFrame() -- equivalent call inferred; original call site unknown
		clone:PivotTo(attachmentCFrame * CFrame.new(0, -1.2, 0))
		clone.Parent = folder
		local v2 = sound:Play("BF_WPN_Slingshot_Z_Hold_01", clone.OctoHead)
		AnimateOctopus(clone, folder, true, true) -- equivalent call inferred; original call site unknown

		while holding and holding.Value do
			local attachmentCFrame2 = getAttachmentCFrame() -- equivalent call inferred; original call site unknown
			clone:PivotTo(attachmentCFrame2 * CFrame.new(0, -1.2, 0))
			task.wait()
		end

		if v2 then
			sound:FadeOut(v2, 0.2)
		end

		Util.Debris:AddItem(folder, 3)
	elseif player.stage == 2 then
		local holdKey = player.holdKey or player.userId or not player.Character and "unknown" or player.Character.Name or "unknown"
		local child = _WorldOrigin:FindFirstChild("OctopusHoldEffect_" .. tostring(holdKey))
		local proxy = player.proxy

		if not proxy then
			return
		end

		local _ = player.maxRange
		local speed = player.speed
		local lifetime = player.lifetime

		if not child then
			return
		end

		child.Name = ""
		local octopus = child.Octopus
		octopus:SetAttribute("Flying", true)
		local ink = octopus.OctoHead.Ink

		for _, emitter in pairs(ink:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local launchCFrame = player.launchCFrame
		local clone = slingshot_Z.Launch:Clone()
		clone.CFrame = launchCFrame
		clone.Parent = child

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		sound:Play("BF_WPN_Slingshot_Z_Fire_01", launchCFrame.Position)
		local targetPosition = player.targetPosition
		octopus:ScaleTo(0.2)
		octopus:PivotTo(launchCFrame)
		local position = octopus.OctoHead.Position
		local position2 = nil
		local vector = Vector3.new(0, -workspace.Gravity, 0)
		local position3 = launchCFrame.Position
		local v2 = (targetPosition - position3 - vector * 0.5) * speed
		local v3 = nil
		local lastTime = os.clock()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(_)
			if lifetime <= os.clock() - lastTime or proxy:GetAttribute("Destroyed") then
				heartbeatConnection:Disconnect()
				octopus:SetAttribute("Flying", false)

				if proxy:GetAttribute("Destroyed") then
					octopus:PivotTo(CFrame.new(proxy:GetAttribute("Destroyed")))
				end

				local clone2 = slingshot_Z.DisapearOctopus:Clone()
				clone2.CFrame = octopus.OctoHead.CFrame
				clone2.Parent = child

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local folder = octopus

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, beam in octopus:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Width0 = 0
					beam.Width1 = 0
				end

				task.wait(5)
				child:Destroy()
			end

			v3 = os.clock() - lastTime
			position2 = CFrame.new(vector * 0.5 * (speed * v3) ^ 2 + v2 * v3 + position3).Position
			octopus:PivotTo(CFrame.lookAt(position2, position) * CFrame.Angles(0, 3.141592653589793, 0))
			position = position2
		end)
		task.wait(lifetime + 3)

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		if child then
			child:Destroy()
		end
	elseif player.stage == 3 then
		local character = player.character or player.Character
		local folder = Instance.new("Folder")
		folder.Name = "SlingshotZBoom"
		folder.Parent = _WorldOrigin
		local clone = slingshot_Z.Octopus:Clone()
		clone:PivotTo(CFrame.lookAt(player.targetPosition, player.targetPosition + player.normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.new(0, 3, 0))
		clone.Parent = folder
		local capsule = clone.OctoHead.Capsule

		for _, emitter in pairs(capsule:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		AnimateOctopus(clone, folder, false, nil) -- equivalent call inferred; original call site unknown
		local clone2 = slingshot_Z.Impact:Clone()
		clone2.CFrame = CFrame.lookAt(player.targetPosition, player.targetPosition + player.normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.new(0, 0.1, 0)
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		sound:Play("BF_WPN_Slingshot_Z_Explosion_01", player.targetPosition)
		local grabbedRoots = {}
		local count = 0
		local lastTime = os.clock()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if os.clock() - lastTime >= player.floorTime then
				heartbeatConnection:Disconnect()
				local clone3 = slingshot_Z.DisapearOctopus:Clone()
				clone3.CFrame = clone:WaitForChild("OctoHead").CFrame
				clone3.Parent = folder

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				sound:Play("BF_WPN_Slingshot_Z_Tentacle_Explode_01_V2", clone3.Position)
				local folder2 = clone

				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, weld in clone:GetDescendants() do
					if not weld:IsA("Weld") then
						continue
					end

					local clone4 = slingshot_Z.Grab:Clone()
					clone4.Position = weld.Parent.Position
					clone4.Parent = folder

					for _, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					weld:Destroy()
				end

				for _, child in folder:GetChildren() do
					if child.Name ~= "OctoWrap" then
						continue
					end

					local clone4 = slingshot_Z.Grab:Clone()
					clone4.Position = child.Position
					clone4.Parent = folder

					for _, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					child:Destroy()
				end

				for _, child in clone:GetChildren() do
					if string.sub(child.Name, 1, 7) ~= "OctoArm" then
						continue
					end

					child.Arm.Width0 = 0
					TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
						Position = clone:WaitForChild("OctoHead").Position
					}):Play()
					TweenService:Create(child.Arm, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end

				task.wait(0.3)
				clone:Destroy()
				task.wait(3)
				folder:Destroy()
			end

			if count < 8 then
				for _, grabbedRoot in player.grabbedRoots do
					if grabbedRoot.Name ~= "HumanoidRootPart" or grabbedRoot.Parent == character or table.find(
						grabbedRoots,
						grabbedRoot
					) then
						continue
					end

					table.insert(grabbedRoots, grabbedRoot)
					count += 1
					local child = clone:WaitForChild("OctoArm" .. count)
					child:SetAttribute("Grabbed", true)
					v[child]:Cancel()
					local position = child.Position
					local lastTime2 = tick()

					while tick() - lastTime2 < 0.1 do
						local v4 = (tick() - lastTime2) / 0.1
						child.Position = position + (grabbedRoot.Position - position) * v4
						task.wait()
					end

					if not grabbedRoot:FindFirstChild("OctoGrab") then
						local attachment = Instance.new("Attachment")
						attachment.Name = "OctoGrab"
						attachment.Parent = grabbedRoot
						Util.Debris:AddItem(attachment, 5)
					end

					child.Arm.Attachment1 = grabbedRoot:FindFirstChild("OctoGrab")
					local clone3 = slingshot_Z.Grab:Clone()
					clone3.CFrame = grabbedRoot.CFrame
					clone3.Parent = folder

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					Util.Sound:Play("BF_WPN_Slingshot_Z_Tentacle_Grab_01", grabbedRoot)
					child.Arm.Width1 = 3
					local clone4 = slingshot_Z.OctoWrap:Clone()
					clone4.Weld.Part0 = grabbedRoot
					clone4.Parent = folder
				end
			end
		end)
	end
end