local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local _ = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local refinedSlingshot_Z = FX:WaitForChild("RefinedSlingshot").RefinedSlingshot_Z
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

for _, effect in refinedSlingshot_Z:GetDescendants() do
	if not (effect:IsA("Trail") or effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
		continue
	end

	local value = effect.Color.Keypoints[1].Value
	local R = value.R
	local G = value.G
	local B = value.B

	if R < G and B < G or not (G < B) or not (R < B) then
		continue
	end

	Util.Recolor(effect, Color3.fromRGB(255, 134, 213), 2)
end

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
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local random = Random.new()
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function AnimateKraken(clone, folder, p, p2)
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
									random:NextNumber(-12, 12),
									random:NextNumber(0, 5),
									random:NextNumber(-12, 12)
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

			local clone2 = refinedSlingshot_Z["InkDrop" .. math.random(1, 2)]:Clone()
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
		folder.Name = "RefinedOctopusHoldEffect_" .. tostring(holdKey)
		folder.Parent = _WorldOrigin
		local equippedAttachment = Util.GetEquippedAttachment(player.Character, player.Attachment)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getAttachmentCFrame()
			if equippedAttachment then
				return equippedAttachment.WorldCFrame
			end

			return hrp.CFrame
		end

		local clone = refinedSlingshot_Z.Kraken:Clone()
		clone:ScaleTo(0.2)
		local attachmentCFrame = getAttachmentCFrame() -- equivalent call inferred; original call site unknown
		clone:PivotTo(attachmentCFrame * CFrame.new(0, -1.2, 0))
		clone.Parent = folder
		local v2 = sound:Play("BF_WPN_Slingshot_Z_Hold_01", clone.OctoHead)

		for _, beam in clone:GetDescendants() do
			if beam.Name == "Arm" and beam:IsA("Beam") then
				beam.Width0 = 1.6
			end
		end

		AnimateKraken(clone, folder, true, true) -- equivalent call inferred; original call site unknown

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
		local child = _WorldOrigin:FindFirstChild("RefinedOctopusHoldEffect_" .. tostring(holdKey))
		local kraken = nil
		local proxy = player.proxy

		if not proxy then
			return
		end

		local _ = player.maxRange
		local speed = player.speed
		local lifetime = player.lifetime

		if child then
			child.Name = ""
			kraken = child.Kraken
		end

		kraken:SetAttribute("Flying", true)
		local ink = kraken.OctoHead.Ink

		for _, emitter in pairs(ink:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local launchCFrame = player.launchCFrame
		local clone = refinedSlingshot_Z.Launch:Clone()
		clone.CFrame = launchCFrame
		clone.Parent = child

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		sound:Play("BF_WPN_Slingshot_Z_Fire_01", launchCFrame.Position)
		local targetPosition = player.targetPosition
		kraken:ScaleTo(0.2)
		kraken:PivotTo(launchCFrame)
		local position = kraken.OctoHead.Position
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
				kraken:SetAttribute("Flying", false)

				if proxy:GetAttribute("Destroyed") then
					kraken:PivotTo(CFrame.new(proxy:GetAttribute("Destroyed")))
				end

				local clone2 = refinedSlingshot_Z.DisapearKraken:Clone()
				clone2.CFrame = kraken.OctoHead.CFrame
				clone2.Parent = child

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				sound:Play("BF_WPN_Slingshot_Z_Tentacle_Explode_01_V2", clone2.Position)
				local folder = kraken

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, beam in kraken:GetDescendants() do
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
			kraken:PivotTo(CFrame.lookAt(position2, position) * CFrame.Angles(0, 3.141592653589793, 0))
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
		local miniCount = player.MiniCount
		local miniLifetime = player.MiniLifetime
		local character = player.character
		local humanoidRootPart = character.HumanoidRootPart
		local folder = Instance.new("Folder")
		folder.Name = "SlingshotZBoom"
		folder.Parent = _WorldOrigin
		local clone = refinedSlingshot_Z.Kraken:Clone()
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

		AnimateKraken(clone, folder, false, nil) -- equivalent call inferred; original call site unknown
		local clone2 = refinedSlingshot_Z.Impact:Clone()
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
				local clone3 = refinedSlingshot_Z.DisapearKraken:Clone()
				clone3.CFrame = clone:WaitForChild("OctoHead").CFrame
				clone3.Parent = folder

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

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

					local clone4 = refinedSlingshot_Z.Grab:Clone()
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

					local clone4 = refinedSlingshot_Z.Grab:Clone()
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

				local healTime = player.HealTime

				-- equivalent calls inferred from this helper; original call sites unknown
				local function disappear(instance)
					pcall(function()
						if instance and instance:FindFirstChild("OctoHead") then
							local clone4 = refinedSlingshot_Z.DisapearOctopus:Clone()
							clone4.CFrame = instance.OctoHead.CFrame
							clone4.Parent = folder

							for _, emitter in pairs(clone4:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end

							Util.Sound:Play("BF_WPN_Ink_Swarm_SquidExplode_01", clone4.Position)
						end

						if instance then
							instance:Destroy()
						end
					end)
				end

				local destroyingConnection = nil
				local diedConnection = nil
				local destroyingConnection2 = nil
				local diedConnection2 = nil

				for i = 1, miniCount do
					local v4 = i
					task.spawn(function()
						local v5 = player.MiniData[v4]
						local part = v5[1]

						if not part then
							return
						end

						local v7 = false
						local clone4 = refinedSlingshot_Z.MiniOctopus:Clone()
						clone4:PivotTo(player.StartCFrame)
						clone4.Parent = folder
						Util.Sound:Play("BF_WPN_Ink_Swarm_Fire_0" .. math.random(1, 5), player.StartCFrame)
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Velocity = v5[2]
						bodyVelocity.Parent = clone4.OctoHead
						task.delay(0.2, bodyVelocity.Destroy, bodyVelocity)
						local raycastResult = nil
						local v8 = false
						destroyingConnection = character.Destroying:Once(function()
							v8 = true
							disappear(clone4) -- equivalent call inferred; original call site unknown
							destroyingConnection:Disconnect()
						end)
						diedConnection = character.Humanoid.Died:Once(function()
							v8 = true
							disappear(clone4) -- equivalent call inferred; original call site unknown
							diedConnection:Disconnect()
						end)
						local heartbeatConnection2 = nil
						local raycastParams2 = RaycastParams.new()
						raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
						raycastParams2.FilterDescendantsInstances = { character, workspace._WorldOrigin }
						heartbeatConnection2 = RunService.Heartbeat:Connect(function()
							if clone4 and clone4:FindFirstChild("OctoHead") == nil then
								heartbeatConnection2:Disconnect()
								heartbeatConnection2 = nil
							else
								raycastResult = workspace:Raycast(
									clone4.OctoHead.Position,
									clone4.OctoHead.Velocity.Unit * 4,
									raycastParams2
								)

								if raycastResult then
									heartbeatConnection2:Disconnect()
									clone4:PivotTo(CFrame.lookAt(
										raycastResult.Position,
										raycastResult.Position + raycastResult.Normal
									) * CFrame.new(0, 0, -1) * CFrame.Angles(-1.5707963267948966, 0, 0))
									clone4.OctoHead.Trail.Enabled = false
									local weldConstraint = Instance.new("WeldConstraint")
									weldConstraint.Part0 = raycastResult.Instance
									weldConstraint.Part1 = clone4.OctoHead
									weldConstraint.Parent = clone4.OctoHead
									task.delay(miniLifetime * v5[3], function()
										if not v8 then
											v8 = true
											disappear(clone4) -- equivalent call inferred; original call site unknown
										end
									end)

									while clone4 and clone4.Parent == folder and part and not v7 and not v8 and part and part.Parent do
										task.wait()

										if not part:GetAttribute("Grabbed") then
											continue
										end

										v7 = true
										local miniGrabObj = part:FindFirstChild("MiniGrabObj")

										if not miniGrabObj then
											return
										end

										local value = miniGrabObj.Value
										destroyingConnection2 = value.Parent.Destroying:Once(function()
											v8 = true
											disappear(clone4) -- equivalent call inferred; original call site unknown
											destroyingConnection:Disconnect()
										end)
										diedConnection2 = value.Died:Once(function()
											v8 = true
											disappear(clone4) -- equivalent call inferred; original call site unknown
											diedConnection:Disconnect()
										end)
										local clone5 = refinedSlingshot_Z.MiniOctoGrab:Clone()
										local weldConstraint_2 = clone4.OctoHead:WaitForChild("WeldConstraint")
										weldConstraint_2.Part0 = nil
										clone4:PivotTo(part.CFrame)
										local weldConstraint_3 = clone4.OctoHead:WaitForChild("WeldConstraint")
										weldConstraint_3.Part0 = part
										clone5.Position = clone4.OctoHead.Position
										clone5.Parent = folder

										for i2, emitter in pairs(clone5:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") then
												emitter:Emit(emitter:GetAttribute("EmitCount"))
											end
										end

										Util.Sound:Play("BF_WPN_Slingshot_Z_Tentacle_Grab_01", clone5)
										local lastTime2 = tick()

										while clone4.Parent == folder and not v8 do
											if part:IsDescendantOf(workspace._WorldOrigin) then
												if healTime <= tick() - lastTime2 and not v8 then
													lastTime2 = tick()

													if part:IsDescendantOf(workspace._WorldOrigin) then
														local clone6 = refinedSlingshot_Z.Bezier:Clone()
														local position = clone4.OctoHead.Position
														local vector = Vector3.new(
															random:NextNumber(-20, 20),
															random:NextNumber(-10, 40),
															random:NextNumber(-20, 20)
														)
														local vector2 = Vector3.new(
															random:NextNumber(-20, 20),
															random:NextNumber(-10, 20),
															random:NextNumber(-20, 20)
														)
														local v10 = position + (humanoidRootPart.Position - position) * 0.3 + vector
														local v11 = position + (humanoidRootPart.Position - position) * 0.6 + vector2
														local position2 = humanoidRootPart.Position
														clone6.Position = position
														clone6.Parent = folder
														local lastTime3 = tick()

														while tick() - lastTime3 < 0.15 do
															local v12 = (tick() - lastTime3) / 0.15
															local v13 = position + (humanoidRootPart.Position - position) * 0.3 + vector
															local v14 = position + (humanoidRootPart.Position - position) * 0.6 + vector2
															position2 = humanoidRootPart.Position
															local v15 = position + (v13 - position) * v12
															local v16 = v13 + (v14 - v13) * v12
															local v17 = v14 + (position2 - v14) * v12
															local v18 = v15 + (v16 - v15) * v12
															clone6.Position = v18 + (v16 + (v17 - v16) * v12 - v18) * v12
															task.wait()
														end

														clone6.Position = position2

														for i2, emitter in pairs(clone6:GetDescendants()) do
															if emitter:IsA("ParticleEmitter") then
																emitter.Enabled = false
															end
														end

														clone6.Trail.Enabled = false
														local clone7 = refinedSlingshot_Z.Heal:Clone()
														clone7.Weld.Part0 = humanoidRootPart
														clone7.Parent = folder

														for i2, emitter in pairs(clone7:GetDescendants()) do
															if emitter:IsA("ParticleEmitter") then
																emitter:Emit(emitter:GetAttribute("EmitCount"))
															end
														end

														sound:Play(
															"BF_WPN_Ink_Swarm_HealingAura_01_V2",
															humanoidRootPart
														)
													else
														v8 = true
														clone4.OctoHead.Anchored = true
														disappear(clone4) -- equivalent call inferred; original call site unknown
														break
													end
												end

												task.wait()
											else
												v8 = true
												clone4.OctoHead.Anchored = true
												disappear(clone4) -- equivalent call inferred; original call site unknown
												break
											end
										end
									end
								end
							end
						end)
					end)
				end

				task.wait(0.3)
				clone:Destroy()
				task.wait(miniLifetime + 10)

				if destroyingConnection then
					destroyingConnection:Disconnect()
				end

				if diedConnection then
					diedConnection:Disconnect()
				end

				if destroyingConnection2 then
					destroyingConnection2:Disconnect()
				end

				if diedConnection2 then
					diedConnection2:Disconnect()
				end

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
					local clone3 = refinedSlingshot_Z.Grab:Clone()
					clone3.CFrame = grabbedRoot.CFrame
					clone3.Parent = folder

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					Util.Sound:Play("BF_WPN_Slingshot_Z_Tentacle_Grab_01", grabbedRoot)
					child.Arm.Width1 = 3
					local clone4 = refinedSlingshot_Z.OctoWrap:Clone()
					clone4.Weld.Part0 = grabbedRoot
					clone4.Parent = folder
				end
			end
		end)
	end
end