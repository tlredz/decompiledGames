local createVector = vector.create
return function(instance)
	local thisLight = instance:FindFirstChild("ThisLight")
	local v = {}
	local v2 = {}
	local clones = {}
	local heartbeatConnections = {}
	local v3 = {}

	local function Aura()
		game:GetService("Debris")
		local TweenService = game:GetService("TweenService")
		game:GetService("Players")
		local folder = instance
		local humanoid = folder:WaitForChild("Humanoid")
		local rootPart = humanoid.RootPart
		local thrown = workspace.Thrown
		local head = folder:WaitForChild("Head")
		local leftArm = folder:WaitForChild("Left Arm")
		local rightArm = folder:WaitForChild("Right Arm")
		local leftLeg = folder:WaitForChild("Left Leg")
		local rightLeg = folder:WaitForChild("Right Leg")
		local torso = folder:WaitForChild("Torso")
		game:GetService("ReplicatedStorage")
		local modules = script.modules
		local _ = workspace.CurrentCamera
		local BoatTween = require(modules.BoatTween)
		local Flipbook = require(modules.Flipbook)
		local attachment = Instance.new("Attachment")
		attachment.Name = "BeamAttachment"
		attachment.Parent = rootPart
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

		local function emitparticles(folder2, p)
			for _, descendant in ipairs(folder2:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					local v4 = descendant
					task.spawn(function()
						local emitDelay = v4:GetAttribute("EmitDelay") or 0
						local emitCount = v4:GetAttribute("EmitCount") or 0

						if v4:GetAttribute("EmitDuration") and v4:GetAttribute("EmitDuration") > 0 then
							v4.Enabled = true
							task.wait(v4:GetAttribute("EmitDuration"))
							v4.Enabled = false
						else
							task.wait(emitDelay)
							v4:Emit(emitCount)
						end
					end)
				elseif descendant:IsA("PointLight") and descendant.Name == "SpecialLight" then
					local v4 = descendant
					task.spawn(function()
						v4.Enabled = true
						local brightness = v4:GetAttribute("Brightness")
						local range = v4:GetAttribute("Range")
						local tween = v4:GetAttribute("Tween")
						TweenService:Create(v4, TweenInfo.new(tween, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
							Brightness = brightness,
							Range = range
						}):Play()
					end)
				elseif descendant:IsA("Beam") then
					local v4 = descendant
					task.spawn(function()
						local emitDuration = v4:GetAttribute("EmitDuration")
						local emitDelay = v4:GetAttribute("EmitDelay") or 0
						local v5 = v4.Width0 * p
						local v6 = v4.Width1 * p
						task.wait(emitDelay)
						local transparency = v4.Transparency
						v4.Transparency = NumberSequence.new(1)
						v4.Enabled = true
						BoatTween:Create(v4, {
							Time = emitDuration / 2,
							EasingStyle = "Sine",
							EasingDirection = "In",
							Goal = {
								Transparency = transparency
							}
						}):Play()
						task.delay(0.5, function()
							BoatTween:Create(v4, {
								Time = 0.5,
								EasingStyle = "Sine",
								EasingDirection = "In",
								Goal = {
									Transparency = NumberSequence.new(1)
								}
							}):Play()
						end)
					end)
				end
			end
		end

		local TweenService2 = game:GetService("TweenService")
		local v4 = {}

		local function captureBeamTransparency(p)
			local v5 = {}

			for _, keypoint in ipairs(p.Transparency.Keypoints) do
				table.insert(v5, {
					Time = keypoint.Time,
					Value = keypoint.Value
				})
			end

			v4[p] = v5
		end

		local function lerpTransparency(list, p, p2)
			local numberSequenceKeypoints = {}

			for i, v5 in ipairs(list) do
				local v6 = p[i]
				local v7 = v5.Value + (v6.Value - v5.Value) * p2
				table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v5.Time, v7))
			end

			return NumberSequence.new(numberSequenceKeypoints)
		end

		local function fadeBeam(p, p2)
			if not v4[p] then
				captureBeamTransparency(p)
			end

			task.spawn(function()
				local lastTime = os.clock()
				local v5 = {}
				local v6 = 0

				for _, keypoint in ipairs(p.Transparency.Keypoints) do
					table.insert(v5, {
						Time = keypoint.Time,
						Value = keypoint.Value
					})
				end

				local v7 = {}

				for _, v8 in ipairs(v4[p]) do
					table.insert(v7, {
						Time = v8.Time,
						Value = p2 and v8.Value or 1
					})
				end

				p.Enabled = true

				if p2 then
					local numberSequenceKeypoints = {}

					for _, v8 in ipairs(v4[p]) do
						table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v8.Time, 1))
					end

					p.Transparency = NumberSequence.new(numberSequenceKeypoints)
					v5 = {}

					for _, keypoint in ipairs(p.Transparency.Keypoints) do
						table.insert(v5, {
							Time = keypoint.Time,
							Value = keypoint.Value
						})
					end
				end

				while v6 < 0.25 do
					v6 = os.clock() - lastTime
					p.Transparency = lerpTransparency(v5, v7, math.clamp(v6 / 0.25, 0, 1))
					task.wait()
				end

				local numberSequenceKeypoints = {}

				for _, v8 in ipairs(v7) do
					table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v8.Time, v8.Value))
				end

				p.Transparency = NumberSequence.new(numberSequenceKeypoints)

				if not p2 then
					p.Enabled = false
				end
			end)
		end

		local function enableparticles(folder2)
			for _, effect in ipairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				elseif effect:IsA("Beam") then
					if not v4[effect] then
						captureBeamTransparency(effect)
					end

					local v6 = effect
					local v7 = true
					task.spawn(function()
						local lastTime = os.clock()
						local v8 = {}
						local v9 = 0

						for i, keypoint in ipairs(v6.Transparency.Keypoints) do
							table.insert(v8, {
								Time = keypoint.Time,
								Value = keypoint.Value
							})
						end

						local v10 = {}

						for i, v11 in ipairs(v4[v6]) do
							table.insert(v10, {
								Time = v11.Time,
								Value = v7 and v11.Value or 1
							})
						end

						v6.Enabled = true

						if v7 then
							local numberSequenceKeypoints = {}

							for i, v11 in ipairs(v4[v6]) do
								table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v11.Time, 1))
							end

							v6.Transparency = NumberSequence.new(numberSequenceKeypoints)
							v8 = {}

							for i, keypoint in ipairs(v6.Transparency.Keypoints) do
								table.insert(v8, {
									Time = keypoint.Time,
									Value = keypoint.Value
								})
							end
						end

						while v9 < 0.25 do
							v9 = os.clock() - lastTime
							v6.Transparency = lerpTransparency(v8, v10, math.clamp(v9 / 0.25, 0, 1))
							task.wait()
						end

						local numberSequenceKeypoints = {}

						for i, v11 in ipairs(v10) do
							table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v11.Time, v11.Value))
						end

						v6.Transparency = NumberSequence.new(numberSequenceKeypoints)

						if not v7 then
							v6.Enabled = false
						end
					end)
				end
			end
		end

		local function disableparticles(folder2)
			for _, effect in ipairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				elseif effect:IsA("Beam") then
					if not v4[effect] then
						captureBeamTransparency(effect)
					end

					local v6 = effect
					local v7 = false
					task.spawn(function()
						local lastTime = os.clock()
						local v8 = {}
						local v9 = 0

						for i, keypoint in ipairs(v6.Transparency.Keypoints) do
							table.insert(v8, {
								Time = keypoint.Time,
								Value = keypoint.Value
							})
						end

						local v10 = {}

						for i, v11 in ipairs(v4[v6]) do
							table.insert(v10, {
								Time = v11.Time,
								Value = v7 and v11.Value or 1
							})
						end

						v6.Enabled = true

						if v7 then
							local numberSequenceKeypoints = {}

							for i, v11 in ipairs(v4[v6]) do
								table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v11.Time, 1))
							end

							v6.Transparency = NumberSequence.new(numberSequenceKeypoints)
							v8 = {}

							for i, keypoint in ipairs(v6.Transparency.Keypoints) do
								table.insert(v8, {
									Time = keypoint.Time,
									Value = keypoint.Value
								})
							end
						end

						while v9 < 0.25 do
							v9 = os.clock() - lastTime
							v6.Transparency = lerpTransparency(v8, v10, math.clamp(v9 / 0.25, 0, 1))
							task.wait()
						end

						local numberSequenceKeypoints = {}

						for i, v11 in ipairs(v10) do
							table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v11.Time, v11.Value))
						end

						v6.Transparency = NumberSequence.new(numberSequenceKeypoints)

						if not v7 then
							v6.Enabled = false
						end
					end)
				end
			end
		end

		local function weld(p, part)
			part.CFrame = p.CFrame
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = p
			weldConstraint.Part1 = part
			weldConstraint.Parent = p
			table.insert(v2, weldConstraint)
			return weldConstraint
		end

		local function decal(parent)
			local texture = script.Texture

			for _, child in ipairs(texture:GetChildren()) do
				local clone = child:Clone()
				clone.Parent = parent
				TweenService2:Create(clone, TweenInfo.new(1), {
					Transparency = 0.15
				}):Play()
				Flipbook.animate(clone, false, 90, 2)
				table.insert(clones, clone)
			end
		end

		local function winds(parent, p)
			for _ = 1, 8 do
				task.spawn(function()
					local time = math.random() * 1 + 0.5
					local v6 = math.random() * 1 + 0.7
					local clone = script.Wind:Clone()
					clone.Parent = parent
					clone.CFrame = p * CFrame.fromEulerAnglesXYZ(0, math.random(-360, 360), 0)
					clone.Mesh.Scale = clone.Mesh.Scale * v6
					Flipbook.animate(clone.Decal, false, math.random(30, 60), 1)
					BoatTween:Create(clone.Mesh, {
						Time = time,
						EasingStyle = "Sine",
						EasingDirection = "In",
						Goal = {
							Scale = createVector(14, 7, 14) * v6,
							Offset = createVector(0, 5, 0) * v6
						}
					}):Play()
					TweenService2:Create(
						clone.Decal,
						TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
						{
							Transparency = 0
						}
					):Play()
					local heartbeatConnection = nil
					local lastTime = tick()
					table.insert(heartbeatConnections, heartbeatConnection)
					local RunService = game:GetService("RunService")
					heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
						local v7 = math.clamp((tick() - lastTime) / 3, 0, 1)
						local cframe = CFrame.Angles(0, math.rad(100 * dt * 1), 0)
						clone.CFrame = CFrame.new(clone.Position) * ((clone.CFrame - clone.CFrame.Position) * cframe)

						if v7 >= 1 and heartbeatConnection then
							heartbeatConnection:Disconnect()
						end
					end)
				end)
			end
		end

		local function windbeam(parent, p)
			local random = Random.new()
			local windbeam1

			if random:NextNumber() <= 0.7 then
				windbeam1 = script.windbeam.windbeam1
			else
				windbeam1 = script.windbeam.windbeam2
			end

			local v5

			if windbeam1 == script.windbeam.windbeam1 then
				v5 = math.floor(random:NextNumber(1.3, 2) * 10 + 0.5) / 10
			else
				v5 = math.floor(random:NextNumber(1, 1.5) * 10 + 0.5) / 10
			end

			script.windbeam:ScaleTo(v5)
			local clone = windbeam1:Clone()
			clone.Parent = parent
			clone.CFrame = p * CFrame.fromEulerAnglesXYZ(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			)
			emitparticles(clone, 3)
		end

		local function windmesh(parent, p)
			local v5 = math.floor(Random.new():NextNumber(1, 2) * 10 + 0.5) / 10
			local clone = script.Mesh:Clone()
			clone.Parent = parent
			clone.CFrame = p * CFrame.fromEulerAnglesXYZ(0, math.rad((math.random(-360, 360))), 0)
			Flipbook.animate(clone.d1, false, 30, 1)
			BoatTween:Create(clone.Mesh, {
				Time = 0.3 * v5,
				EasingStyle = "Linear",
				EasingDirection = "In",
				Goal = {
					Scale = Vector3.new(15 * v5, 8, 15 * v5)
				}
			}):Play()
		end

		local v5 = true

		local function fn(folder2, _)
			if not v5 then
				warn("Wait for animation cooldown.")
				return
			end

			local humanoidRootPart = folder2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v5 = false

			if thisLight then
				thisLight = false
				local aura = folder:FindFirstChild("Aura")

				if aura then
					disableparticles(aura)
					local clone = script.Burst:Clone()
					clone.CFrame = humanoidRootPart.CFrame
					clone.Parent = game.Workspace.Thrown
					emitparticles(clone, 1)
					task.wait(0.1)
					aura:Destroy()
				end

				for _, decal2 in pairs(folder:GetDescendants()) do
					if decal2:IsA("Decal") and decal2.Name == "e" then
						decal2:Destroy()
					end
				end

				local thisLight2 = folder:FindFirstChild("ThisLight")

				if thisLight2 then
					TweenService2:Create(thisLight2, TweenInfo.new(1, Enum.EasingStyle.Sine), {
						FillTransparency = 1,
						OutlineTransparency = 1
					}):Play()
					game.Debris:AddItem(thisLight2, 1)
				end

				for _, v6 in ipairs(v3) do
					if v6 then
						v6:Destroy()
					end
				end

				table.clear(v3)

				for _, v6 in ipairs(v2) do
					if v6 and v6.Parent then
						v6:Destroy()
					end
				end

				table.clear(v2)

				for _, v6 in ipairs(v) do
					if v6 then
						v6:Destroy()
					end
				end

				table.clear(v)

				for _, v6 in ipairs(clones) do
					if v6 then
						v6:Destroy()
					end
				end

				table.clear(clones)

				for _, connection in ipairs(heartbeatConnections) do
					if connection then
						connection:Disconnect()
					end
				end

				table.clear(heartbeatConnections)
				local vFXFolderName = folder:GetAttribute("VFXFolderName")
				print(vFXFolderName)

				if vFXFolderName then
					local child = thrown:FindFirstChild(vFXFolderName)
					print(child)

					if child then
						child:Destroy()
						print(child.Parent)
					end
				end

				v5 = true
			else
				shared.sfx({
					SoundId = "rbxassetid://107033316042301",
					Parent = folder.PrimaryPart,
					Volume = 2
				}):Play()
				local folder3 = Instance.new("Folder")
				folder3.Name = "VFXContainer" .. folder.Name .. script.Name
				folder3.Parent = thrown
				game.Debris:AddItem(folder3, 500)
				thisLight = true
				folder2:SetAttribute("VFXFolderName", folder3.Name)
				humanoid:LoadAnimation(script.Animation):Play()
				local clone = script.Aura:Clone()
				clone.Name = "Aura"
				clone.Parent = folder
				local v6 = head
				local head2 = clone.Head
				head2.CFrame = v6.CFrame
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = v6
				weldConstraint.Part1 = head2
				weldConstraint.Parent = v6
				table.insert(v2, weldConstraint)
				local v7 = leftArm
				local leftArm2 = clone["Left Arm"]
				leftArm2.CFrame = v7.CFrame
				local weldConstraint2 = Instance.new("WeldConstraint")
				weldConstraint2.Part0 = v7
				weldConstraint2.Part1 = leftArm2
				weldConstraint2.Parent = v7
				table.insert(v2, weldConstraint2)
				local v8 = leftLeg
				local leftLeg2 = clone["Left Leg"]
				leftLeg2.CFrame = v8.CFrame
				local weldConstraint3 = Instance.new("WeldConstraint")
				weldConstraint3.Part0 = v8
				weldConstraint3.Part1 = leftLeg2
				weldConstraint3.Parent = v8
				table.insert(v2, weldConstraint3)
				local v9 = rightArm
				local rightArm2 = clone["Right Arm"]
				rightArm2.CFrame = v9.CFrame
				local weldConstraint4 = Instance.new("WeldConstraint")
				weldConstraint4.Part0 = v9
				weldConstraint4.Part1 = rightArm2
				weldConstraint4.Parent = v9
				table.insert(v2, weldConstraint4)
				local v10 = rightLeg
				local rightLeg2 = clone["Right Leg"]
				rightLeg2.CFrame = v10.CFrame
				local weldConstraint5 = Instance.new("WeldConstraint")
				weldConstraint5.Part0 = v10
				weldConstraint5.Part1 = rightLeg2
				weldConstraint5.Parent = v10
				table.insert(v2, weldConstraint5)
				local v11 = torso
				local torso2 = clone.Torso
				torso2.CFrame = v11.CFrame
				local weldConstraint6 = Instance.new("WeldConstraint")
				weldConstraint6.Part0 = v11
				weldConstraint6.Part1 = torso2
				weldConstraint6.Parent = v11
				table.insert(v2, weldConstraint6)
				local aura = clone.Aura
				aura.CFrame = humanoidRootPart.CFrame
				local weldConstraint7 = Instance.new("WeldConstraint")
				weldConstraint7.Part0 = humanoidRootPart
				weldConstraint7.Part1 = aura
				weldConstraint7.Parent = humanoidRootPart
				table.insert(v2, weldConstraint7)
				enableparticles(clone)
				local v12 = {}

				for _, descendant in ipairs(clone:GetDescendants()) do
					if descendant.Name == "Constellation" then
						table.insert(v12, {
							Attachment = descendant,
							BasePosition = descendant.Position
						})
					end
				end

				local highlight = Instance.new("Highlight")
				highlight.Name = "ThisLight"
				highlight.FillColor = Color3.new(1, 0, 0)
				highlight.FillTransparency = 1
				highlight.OutlineColor = Color3.fromRGB(247, 255, 153)
				highlight.OutlineTransparency = 1
				highlight.Parent = folder2
				table.insert(v, highlight)
				TweenService2:Create(highlight, TweenInfo.new(1), {
					OutlineTransparency = 0
				}):Play()
				task.spawn(function()
					local v13 = {}
					local v14 = {}
					local v15 = {}

					for _, descendant in ipairs(folder2:GetDescendants()) do
						if descendant:IsA("Part") and descendant.Parent.Name ~= "Aura" then
							local name = descendant.Name

							if name == "Left Leg" or name == "Right Leg" then
								table.insert(v13, descendant)
							elseif name == "Left Arm" or name == "Right Arm" or name == "Torso" then
								table.insert(v14, descendant)
							elseif name == "Head" then
								table.insert(v15, descendant)
							end
						elseif descendant:IsA("Accessory") then
							local attachment2 = descendant:FindFirstChildWhichIsA("Attachment", true)

							if attachment2 then
								local name = attachment2.Name:lower()

								if name:find("leg") then
									table.insert(v13, descendant.Handle)
								elseif name:find("torso") or name:find("body") or name:find("arm") or name:find("shoulder") or name:find("back") then
									table.insert(v14, descendant.Handle)
								elseif name:find("head") or name:find("face") or name:find("hat") or name:find("hair") then
									table.insert(v15, descendant.Handle)
								end
							end
						end
					end

					local function decalParts(list)
						for _, v16 in ipairs(list) do
							decal(v16)
						end
					end

					task.wait(0.3)
					task.wait(0.3)
					TweenService2:Create(clone.Head.eyes, TweenInfo.new(0.5), {
						Transparency = 0
					}):Play()
				end)
				local clone2 = script.Start:Clone()
				clone2.CFrame = humanoidRootPart.CFrame
				clone2.Parent = folder3
				emitparticles(clone2, 2)
				local clone3 = script.Burst:Clone()
				clone3.CFrame = humanoidRootPart.CFrame
				clone3.Parent = folder3
				local heartbeatConnection = nil
				local lastTime = tick()
				local total = 0
				local total2 = 0
				local RunService = game:GetService("RunService")
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					local v13 = math.clamp((tick() - lastTime) / 0.6, 0, 1)
					total += dt

					if total >= 0.025 then
						total = 0
					end

					total2 += dt

					if total2 >= 0.1 then
						total2 = 0
					end

					if v13 >= 1 and heartbeatConnection then
						heartbeatConnection:Disconnect()
					end
				end)
				local RunService2 = game:GetService("RunService")
				local heartbeatConnection2 = RunService2.Heartbeat:Connect(function(_)
					local now = tick()

					for i, v13 in ipairs(v12) do
						local attachment2 = v13.Attachment
						local basePosition = v13.BasePosition

						if not attachment2 then
							continue
						end

						local v14 = (now + i * 0.5) * 1
						attachment2.Position = basePosition + Vector3.new(
							math.sin(v14) * 0.1,
							math.cos(v14 * 1.2) * 0.1,
							math.sin(v14 * 0.7) * 0.1
						)
					end
				end)
				table.insert(heartbeatConnections, heartbeatConnection2)
				task.delay(0.5, function()
					v5 = true
				end)
				task.delay(0.8, function()
					emitparticles(clone3, 1)
				end)
			end
		end

		if thisLight then
			fn(folder)
		else
			fn(folder, true)
		end
	end

	Aura()
end