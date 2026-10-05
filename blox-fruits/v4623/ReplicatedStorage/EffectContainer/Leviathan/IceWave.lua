local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local iceWave = FX:WaitForChild("Leviathan").IceWave
local _ = Util.MasterClock
local boatTween = Util.BoatTween
local debris = Util.Debris
local _ = Util.Sound
local misc = Util.Luno.Misc
local _ = Util.PartCache

local function flyingIceChunk(p, p2, p3)
	local v = math.random(20, 200) / 10 * (p3 * 0.5)
	local clone = iceWave.IceBlock:Clone()
	Util.Debris:AddItem(clone, 5)
	clone.Size = Vector3.new(v, v, v)
	clone.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	clone.Anchored = false

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			misc.scaleParticle(emitter, p3, true)
		end

		if emitter:isA("Attachment") then
			emitter.Position *= p3
		end
	end

	clone.Parent = _WorldOrigin
	clone.Velocity = clone.CFrame.lookVector.Unit * math.random(150, 250)
	clone.RotVelocity = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
	clone.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	local v2 = boatTween:Create(clone, {
		Time = math.random(10, 25) / 10,
		EasingStyle = "Sine",
		EasingDirection = "In",
		StepType = "Heartbeat",
		Reverses = false,
		Goal = {
			Size = createVector(0.1, 0.1, 0.1)
		}
	})
	v2.Completed:Connect(function()
		if clone then
			clone.Anchored = true
			clone.Transparency = 1

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		task.delay(1, function()
			if clone then
				clone:Destroy()
			end
		end)
	end)
	v2:Play()
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function decalShockwave(cFrame, p, p2, _, scale, p3)
	task.spawn(function()
		local clone = iceWave.DecWave:Clone()
		debris:AddItem(clone, p2 + 1)
		clone.CFrame = cFrame
		clone.Mesh.Scale = scale
		clone.Parent = _WorldOrigin
		local v = {
			"rbxassetid://13117093477",
			"rbxassetid://13117093094",
			"rbxassetid://13117092741",
			"rbxassetid://13117092522",
			"rbxassetid://13117092280",
			"rbxassetid://13117092086",
			"rbxassetid://13117091790"
		}
		local v2 = 1 / (60 / p2)

		for i = 1, #v do
			local transparency = i / #v
			clone.Mesh.Scale = clone.Mesh.Scale:Lerp(p3, transparency)
			clone.CFrame = clone.CFrame:Lerp(p, transparency)
			clone.Decal.Texture = v[i]
			clone.Decal.Transparency = transparency
			task.wait(v2)
		end

		clone.Decal.Texture = ""

		if clone then
			clone:Destroy()
		end
	end)
end

local count = 0
local signal = Util.Signal2.new()
local v = false
return function(data)
	local ID = data.ID

	if ID == 0 then
		if not v then
			local v2 = {}

			if data.Tail and data.Tail:FindFirstChild("Animations") then
				for _, child in pairs(data.Tail.Animations:GetChildren()) do
					table.insert(v2, child.AnimationId)
				end
			end

			for _, descendant in pairs(iceWave:GetDescendants()) do
				if descendant:IsA("Decal") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
					table.insert(v2, descendant.Texture)
				elseif descendant:IsA("MeshPart") then
					table.insert(v2, descendant.MeshId)

					if descendant.TextureID ~= "" then
						table.insert(v2, descendant.TextureID)
					end
				elseif descendant:IsA("SpecialMesh") and descendant.MeshId and descendant.MeshId ~= "" then
					table.insert(v2, descendant.MeshId)
				end
			end

			task.spawn(function()
				local ContentProvider = game:GetService("ContentProvider")
				ContentProvider:PreloadAsync(v2)
			end)
			v = true
		end

		task.wait(data.Timestamp - workspace:GetServerTimeNow())

		if not misc.cameraInRange(data.CFrame.Position, 3000) then
			return
		end

		local tail = data.Tail
		tail.HumanoidRootPart.WeldConstraint.Enabled = false
		tail.RootPart.Anchored = true
		local changedConnection = nil
		changedConnection = data.Allowed.Changed:Connect(function()
			if not data.Allowed.Value then
				tail.RootPart.Anchored = false
				tail.RootPart.CFrame = tail.HumanoidRootPart.CFrame
				tail.HumanoidRootPart.WeldConstraint.Enabled = true
				changedConnection:Disconnect()
			end
		end)
		local track = tail.Humanoid.Animator:LoadAnimation(tail.Animations.MainBackward)
		track:Play(1, 1, 2)
		track.Priority = Enum.AnimationPriority.Action
		track.TimePosition = 1.3
		track:GetMarkerReachedSignal("End"):Wait()

		if not data.Allowed.Value then
			track:Stop(0)
			return
		end

		track:AdjustSpeed(0)
		local clone = iceWave.Bubble:Clone()
		clone.Parent = workspace._WorldOrigin
		clone.CFrame = data.CFrame * CFrame.new(0, 0, 300)
		clone.Transparency = 0.8
		debris:AddItem(clone, 4)
		local TweenService = game:GetService("TweenService")
		TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 7, true), {
			Transparency = 0.2
		}):Play()
		task.wait(2)

		if not data.Allowed.Value then
			return
		end

		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(clone, TweenInfo.new(0.6), {
			Transparency = 1
		}):Play()
		tail.RootPart.CFrame = data.CFrame
		track.TimePosition = track:GetTimeOfKeyframe("End")
		track:AdjustSpeed(-2)
		track:Stop(0.4)
		tail.Humanoid.Animator:LoadAnimation(tail.Animations.TailSwipe):Play(0.4)
		task.wait(1.1)
		task.wait(1.9)

		if not data.Allowed.Value then
			track:Stop(0)
			return
		end

		track:Play(1, 1, 2)
		track.Priority = Enum.AnimationPriority.Action
		track.TimePosition = 1.3
		track:GetMarkerReachedSignal("End"):Wait()

		if not data.Allowed.Value then
			track:Stop(0)
			return
		end

		tail.RootPart.Anchored = false
		tail.RootPart.CFrame = tail.HumanoidRootPart.CFrame
		tail.HumanoidRootPart.WeldConstraint.Enabled = true
		track.TimePosition = track:GetTimeOfKeyframe("End")
		track:AdjustSpeed(-2)
		track:Stop(0.4)
	elseif ID == 1 then
		local _ = data.Timestamp
		local lifetime = data.Lifetime
		local cFrame = data.CFrame
		local baseSize = data.BaseSize
		local scaler = data.Scaler
		local _ = data.Radius
		local onWater = data.OnWater
		local _ = data.Seed
		local spikes = data.Spikes
		local v2 = count

		local function check()
			return v2 == count
		end

		task.wait(data.Timestamp - workspace:GetServerTimeNow())

		if not (data.Allowed.Value and v2 == count) then
			return
		end

		if misc.cameraInRange(cFrame.p, 3000) then
			local maid = Util.Maid.new()

			local function r(p, p2)
				return math.random() * (p2 - p) + p
			end

			if onWater then
				Effect.new("Leviathan.Splash"):replicate({
					CFrame = cFrame,
					Scale = scaler
				})
			end

			local cframe = CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
			local cFrame3 = CFrame.new(cFrame.p + Vector3.new(0, 15 * scaler, 0)) * cframe
			local v4 = CFrame.new(cFrame.p + createVector(0, 0, 0)) * cframe
			Color3.fromRGB(250, 350, 1000)
			decalShockwave(cFrame3, v4, 0.9, nil, createVector(0.2, 3, 0.2) * scaler, createVector(2, 0.6, 2) * scaler) -- equivalent call inferred; original call site unknown
			local cFrame4 = CFrame.new(cFrame.p + Vector3.new(0, 20 * scaler, 0)) * cframe
			local v9 = CFrame.new(cFrame.p + createVector(0, 0, 0)) * cframe
			Color3.fromRGB(150, 250, 1200)
			decalShockwave(cFrame4, v9, 1, nil, createVector(0.2, 5, 0.2) * scaler, createVector(4, 1.2, 4) * scaler) -- equivalent call inferred; original call site unknown
			Util.Sound:Play("IceSummon", cFrame.p, nil, 1.1, 0.4)
			Util.Sound:Play("DragonExplosion", cFrame.p, nil, 0.4, 0.6)
			Util.Sound:Play("IceShoot", cFrame.p, nil, math.random(4, 5), 0.7)
			local clone = iceWave.EruptParticles:Clone()
			debris:AddItem(clone, 5)
			clone.Position = cFrame.p
			clone.Size *= scaler
			clone.Parent = _WorldOrigin

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				misc.scaleParticle(emitter, scaler, true)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			maid:GiveTask(clone)

			if (workspace.CurrentCamera.CFrame.p - cFrame.p).Magnitude <= 800 then
				Util.CameraShaker:ShakeOnce(7, 11, 0.45, 0.55)
			end

			if onWater then
				for _ = 1, math.random(5, 7) do
					flyingIceChunk(cFrame.p, createVector(0, 1, 0), scaler / 2)
				end
			end

			local v13 = os.clock() + lifetime
			task.spawn(function()
				if v2 ~= count then
					return
				end

				local clone2 = iceWave.ForceParticles:Clone()
				debris:AddItem(clone2, 5)
				clone2.Size *= scaler

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						misc.scaleParticle(emitter, scaler, true)
					end
				end

				clone2.Parent = _WorldOrigin
				clone2.CFrame = cFrame * CFrame.new(0, 25, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone2.LeftAttach.Puff:Emit(2)
				clone2.RightAttach.Puff:Emit(2)
				local lastTime = os.clock()
				local v14 = 0.016666666666666666

				for _ = 1, 30 do
					if v2 ~= count then
						break
					end

					if os.clock() - lastTime > 0.01 then
						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") and emitter.Name ~= "Puff" then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						lastTime = os.clock()
					end

					clone2.CFrame *= CFrame.new(0, -0.4166 * scaler * v14 * 60, 0)
					v14 = RunService.Heartbeat:Wait()
				end
			end)
			maid:GiveTask(spikes)
			local v14 = 0

			for i, folder in pairs(spikes:GetChildren()) do
				local maid2 = Util.Maid.new()
				local floorCF = folder:GetAttribute("FloorCF")
				local cFrame2 = folder.CFrame
				local cFrame5 = folder.CFrame * CFrame.new(
					0,
					-(cFrame2.Position.Y + 5) / cFrame2.UpVector.Y - folder.Size.Y / 2,
					0
				)
				folder.Transparency = 0
				folder.CFrame = cFrame5
				local v16 = false
				local v17 = folder
				maid2:GiveTask(folder:GetPropertyChangedSignal("Parent"):Connect(function()
					if not v17.Parent and spikes.Parent and not v16 then
						if v14 < os.clock() then
							Util.Sound:Play("Ice_pheasant_hit", v17.CFrame.Position, nil, 0.4, 0.6)
							v14 = os.clock() + 1
						end

						local clone2 = v17:Clone()
						clone2.CanCollide = false
						clone2.CanTouch = false
						clone2.CanQuery = false
						clone2.Transparency = 1
						clone2.Parent = _WorldOrigin

						for i2, emitter in pairs(clone2:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							misc.scaleParticle(emitter, 0.25, true)
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end

						debris:AddItem(clone2, 3)
						maid2:DoCleaning()
					end
				end))
				maid2:GiveTask(folder)

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						misc.scaleParticle(emitter, 16, true)
					end
				end

				local clone2 = folder:Clone()
				clone2.Material = Enum.Material.Ice
				clone2.Size -= createVector(0.1, 0.1, 0.1)
				clone2.Transparency = 1
				clone2.Parent = _WorldOrigin
				local v19 = boatTween:Create(folder, {
					Time = math.random() * 0.15000000000000002 + 0.3,
					EasingStyle = "Sine",
					EasingDirection = "Out",
					StepType = "Heartbeat",
					Reverses = false,
					Goal = {
						CFrame = cFrame2,
						Color = Color3.fromRGB(121, 161, 168)
					}
				})
				maid2:GiveTask(clone2)
				local v21 = folder
				local maid3 = maid2
				maid2:GiveTask(v19.Completed:Connect(function()
					clone2.Transparency = 0
					clone2.CFrame = v21.CFrame
					clone2.Parent = _WorldOrigin
					v21.CanCollide = true
					boatTween:Create(v21, {
						Time = 1,
						EasingStyle = "Sine",
						EasingDirection = "In",
						StepType = "Heartbeat",
						Reverses = false,
						Goal = {
							Transparency = 0.6
						}
					}):Play()
					task.wait(v13 - os.clock() - 1)
					v16 = true

					if v21 and v2 == count and v21.Parent then
						local time = math.random() * 0.5 + 0.5
						local v24 = boatTween:Create(clone2, {
							Time = time,
							EasingStyle = "Sine",
							EasingDirection = "In",
							StepType = "Heartbeat",
							Reverses = false,
							Goal = {
								CFrame = cFrame5
							}
						})
						boatTween:Create(v21, {
							Time = time,
							EasingStyle = "Sine",
							EasingDirection = "In",
							StepType = "Heartbeat",
							Reverses = false,
							Goal = {
								CFrame = cFrame5
							}
						}):Play()
						boatTween:Create(v21, {
							Time = math.random() * 0.09999999999999998 + 0.2,
							EasingStyle = "Sine",
							EasingDirection = "In",
							StepType = "Heartbeat",
							Reverses = false,
							Goal = {
								Transparency = 1
							}
						}):Play()
						maid3:GiveTask(v24.Completed:Connect(function()
							if v21 then
								v21:Destroy()
								clone2:Destroy()
							end

							v24 = nil
						end))
						v24:Play()
					end
				end))
				v19:Play()
				local folder2 = folder
				task.delay(0.2, function()
					for i2, emitter in pairs(folder2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end
				end)

				if i % 3 == 0 then
					local clone3 = iceWave.IcePatch:Clone()
					clone3.Size = createVector(1, 1, 1)
					clone3.CFrame = CFrame.new(floorCF.p) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
					clone3.CanCollide = false
					clone3.Parent = _WorldOrigin
					maid2:GiveTask(clone3)
					debris:AddItem(clone3, lifetime + 3)
					local size = createVector(20, 4.5, 20) * Vector3.new(baseSize.X / 8, 1, baseSize.Z / 8)
					local v24 = boatTween:Create(clone3, {
						Time = math.random() * 0.1 + 0.15,
						EasingStyle = "Sine",
						EasingDirection = "Out",
						StepType = "Heartbeat",
						Reverses = false,
						Goal = {
							Size = size,
							Color = Color3.fromRGB(121, 161, 168)
						}
					})
					local maid4 = maid2
					maid2:GiveTask(v24.Completed:Connect(function()
						clone3.CanCollide = true
						local clone4 = clone3:Clone()
						maid4:GiveTask(clone4)
						clone4.Size = clone3.Size - createVector(0.1, 0.1, 0.1)
						clone4.Parent = _WorldOrigin
						clone4.Material = Enum.Material.Ice
						clone4.Parent = _WorldOrigin
						boatTween:Create(clone3, {
							Time = 1,
							EasingStyle = "Sine",
							EasingDirection = "In",
							StepType = "Heartbeat",
							Reverses = false,
							Goal = {
								Transparency = 0.6
							}
						}):Play()
						boatTween:Create(clone4, {
							Time = 1,
							EasingStyle = "Sine",
							EasingDirection = "In",
							StepType = "Heartbeat",
							Reverses = false,
							Goal = {
								Transparency = 0.6
							}
						})
						task.wait(v13 - os.clock() - 1)

						if clone3 and v2 == count then
							local time = math.random() * 0.5 + 0.5
							local v27 = boatTween:Create(clone3, {
								Time = time,
								EasingStyle = "Sine",
								EasingDirection = "In",
								StepType = "Heartbeat",
								Reverses = false,
								Goal = {
									Size = createVector(1, 1, 1),
									Color = Color3.fromRGB(90, 120, 125)
								}
							})
							boatTween:Create(clone4, {
								Time = time,
								EasingStyle = "Sine",
								EasingDirection = "In",
								StepType = "Heartbeat",
								Reverses = false,
								Goal = {
									Size = createVector(1, 1, 1),
									Color = Color3.fromRGB(90, 120, 125)
								}
							}):Play()
							maid4:GiveTask(v27.Completed:Connect(function()
								if clone3 then
									clone3:Destroy()
									clone4:Destroy()
								end

								v27 = nil
							end))
							v27:Play()
						end
					end))
					v24:Play()
				end

				maid:GiveTask(maid2)
			end

			spikes.Parent = workspace.Map
			maid:GiveTask(signal:Once(function()
				maid:DoCleaning()
			end))
			maid:GiveTask(spikes:GetPropertyChangedSignal("Parent"):Connect(function()
				if not spikes.Parent then
					maid:DoCleaning()
				end
			end))
			task.delay(v13 - os.clock(), function()
				maid:DoCleaning()
			end)
		end
	elseif ID == 3 then
		count += 1
		signal:Fire()
	elseif ID == 4 then
		if typeof(data.HRP) ~= "Instance" then
			return
		end

		local clone = iceWave.IceBlock:Clone()
		clone.Transparency = 0.5
		clone.Size = clone.Size * createVector(1, 1.3, 1) * (data.HRP.Size.X / 2)
		clone.CanCollide = false
		clone.CanQuery = false
		clone.Anchored = false
		clone.Massless = true
		clone.IceFlakes.Enabled = false
		clone.Parent = workspace._WorldOrigin
		debris:AddItem(clone, 3)
		local weld = Instance.new("Weld", clone)
		weld.Part0 = data.HRP
		weld.Part1 = clone
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Map }
		raycastParams.FilterType = Enum.RaycastFilterType.Include

		while data.HRP.Parent do
			local raycastResult = workspace:Raycast(
				data.HRP.Position,
				data.HRP.Velocity * 0.03333333333333333,
				raycastParams
			)

			if raycastResult and raycastResult.Instance or (data.HRP.Position + data.HRP.Velocity * 0.03333333333333333).Y <= -4 then
				break
			else
				task.wait()
			end
		end

		if clone.Parent then
			clone.Mist.Enabled = false
			clone.Trail.Enabled = false
			boatTween:Create(clone, {
				Time = 0.15,
				EasingStyle = "Sine",
				EasingDirection = "Out",
				StepType = "Heartbeat",
				Reverses = false,
				Goal = {
					Transparency = 1
				}
			}):Play()
		end
	end
end