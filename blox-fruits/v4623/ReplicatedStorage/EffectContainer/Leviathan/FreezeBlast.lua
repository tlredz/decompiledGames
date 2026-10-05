local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local freezeBlast = FX:WaitForChild("Leviathan").FreezeBlast
local _ = Util.MasterClock
local boatTween = Util.BoatTween
local debris = Util.Debris
local _ = Util.Sound
local misc = Util.Luno.Misc
local _ = Util.PartCache

local function r(p, p2)
	return math.random() * (p2 - p) + p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function decalShockwave(cFrame, p, p2, _, scale, p3)
	task.spawn(function()
		local clone = freezeBlast.DecWave:Clone()
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

return function(data)
	local ID = data.ID

	if ID == 0 then
		task.wait(data.Timestamp - workspace:GetServerTimeNow())
		local teleportCFrame = data.TeleportCFrame
		local leviathan = data.Leviathan

		if not misc.cameraInRange(leviathan.PrimaryPart.CFrame.Position, 3000) then
			return
		end

		if teleportCFrame then
			local _ = leviathan.PrimaryPart.CFrame
			local track = leviathan.Humanoid.Animator:LoadAnimation(leviathan.Animations.MainBackward)
			track:Play(0.1, 0, 0)
			track.Priority = Enum.AnimationPriority.Movement
			local track2 = leviathan.Humanoid.Animator:LoadAnimation(leviathan.Animations.FastDive)
			track2.TimePosition = 1
			track2:Play(1, 1, 2)
			track2:GetMarkerReachedSignal("End"):Wait()

			if not data.Allowed.Value then
				track2:Stop()
				return
			end

			track2:AdjustSpeed(0)
			leviathan:SetPrimaryPartCFrame(teleportCFrame)
			track:Play(0, 1, 1)
			task.wait(0.1)
			track:Stop(0.6)
			track2:Stop()
			local clone = freezeBlast.WaterSplash:Clone()
			clone.Parent = _WorldOrigin
			debris:AddItem(clone, 4)
			clone.CFrame = CFrame.new(teleportCFrame.Position * createVector(1, 0, 1) + createVector(-0, -4, -0))

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				misc.scaleParticle(emitter, 20, true)

				if emitter:GetAttribute("EmitCount") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	elseif ID == 1 then
		local spawnCF = data.SpawnCF
		local chargeTime = data.ChargeTime
		local timestamp = data.Timestamp
		local spawnPart = data.SpawnPart
		local spawnOffset = data.SpawnOffset
		task.wait(data.Timestamp - workspace:GetServerTimeNow())

		if not data.Allowed.Value then
			return
		end

		if misc.cameraInRange(spawnCF.p, 3000) then
			local v = chargeTime - (workspace:GetServerTimeNow() - timestamp)

			if v > 0 then
				local clone = freezeBlast.MouthCharge:Clone()
				debris:AddItem(clone, v + 2)
				clone.CFrame = spawnCF

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						misc.scaleParticle(emitter, 2, true)
					end
				end

				if spawnPart then
					clone.CFrame = spawnPart.CFrame
					clone.Anchored = false
					local weld = Instance.new("Weld", clone)
					weld.Part0 = spawnPart
					weld.Part1 = clone

					if spawnOffset then
						weld.C0 = spawnOffset
					end
				end

				clone.Parent = _WorldOrigin
				Util.Sound:Play("IceBlock", clone, nil, 0.5, 0.5)
				Util.Sound:Play("SeaOtherBeamCharge", clone, nil, 1.2, 0.5)
				local v2 = Util.Sound:Play("WindLooped", clone, nil, 0.9, 0.5)
				local now = os.clock()
				local v3 = {
					Star = { 0.05, now },
					DarkStreaks = { 0.05, now },
					EnergyIn = { 0.25, now },
					IceFlakesLeft = { 0.1, now },
					IceFlakesRight = { 0.1, now },
					IceFogLeft = { 0.45, now },
					IceFogRight = { 0.45, now },
					IceShardsLeft = { 0.08, now },
					IceShardsRight = { 0.08, now },
					Ring = { 0.2, now },
					Vortex = { 0.15, now }
				}

				for _ = 1, 60 * chargeTime do
					if v < workspace:GetServerTimeNow() - timestamp then
						break
					end

					if clone then
						for _, child in pairs(clone.At0:GetChildren()) do
							if not v3[child.Name] then
								continue
							end

							local nows = v3[child.Name]

							if not (os.clock() - nows[2] > nows[1]) then
								continue
							end

							child:Emit(child:GetAttribute("EmitCount"))
							nows[2] = os.clock()
						end
					end

					task.wait(0.016666666666666666)
				end

				task.spawn(function()
					for i = 1, 60 do
						if not v2 then
							break
						end

						v2.Volume = misc.lerp(0.9, 0, i / 60)
						task.wait(0.016666666666666666)
					end

					if v2 then
						v2:Destroy()
					end
				end)
			end
		end
	elseif ID == 2 then
		local spawnCF = data.SpawnCF
		local duration = data.Duration
		local distance = data.Distance
		local _ = data.Timestamp
		local object = data.Object
		local _ = data.Spiked
		local seaLevel = data.SeaLevel
		local scaler = data.Scaler
		local spawnPart = data.SpawnPart
		local spawnOffset = data.SpawnOffset
		local _ = data.IceDuration or 5

		if spawnPart then
			spawnCF = spawnPart.CFrame

			if spawnOffset then
				spawnCF *= spawnOffset
			end
		end

		local v = false

		if object and misc.cameraInRange(spawnCF.p, 3000) then
			task.spawn(function()
				Util.Sound:Play("Buddha2BeamShoot", spawnCF.p, nil, math.random(5, 7) / 10, 0.75)
				local value

				if object.Value == createVector(0, 0, 0) then
					value = nil
				else
					value = object.Value
				end

				local changedConnection = object.Changed:Connect(function()
					value = object.Value or nil
				end)
				local clone = freezeBlast.BeamModel:Clone()
				debris:AddItem(clone, duration + 1)
				clone:SetPrimaryPartCFrame(spawnCF)
				clone.Parent = _WorldOrigin
				local beamRoot = clone.BeamRoot
				beamRoot.Size = Vector3.new(6, beamRoot.Size.Y * scaler, beamRoot.Size.Z * scaler)
				local beamRay = clone.BeamRay
				beamRay.Size = Vector3.new(12, beamRay.Size.Y * scaler, beamRay.Size.Z * scaler)
				local beamEnd = clone.BeamEnd
				beamEnd.Size = Vector3.new(6, beamEnd.Size.Y * scaler, beamEnd.Size.Z * scaler)

				for _, child in pairs(beamRoot.BeamFire:GetChildren()) do
					child:Emit(child:GetAttribute("EmitCount"))
				end

				local now = os.clock()
				local v2 = {}
				local v3 = spawnCF
				local cFrame = spawnCF
				local serverTimeNow = workspace:GetServerTimeNow()
				local magnitude = 0
				local _, _, _ = Util.Ray(
					v3.p,
					v3.lookVector.Unit * magnitude,
					{ workspace.Characters, workspace.Enemies },
					false
				)
				local magnitude2 = (spawnCF.p - cFrame.p).Magnitude
				local now2 = os.clock() - 0.05

				if not value then
					local v5 = {
						Air = { 0.03, now },
						IceFlakes = { 0.02, now },
						IceFog = { 0.02, now },
						Streaks = { 0.02, now }
					}

					while workspace:GetServerTimeNow() - serverTimeNow <= duration do
						local v6 = math.min((workspace:GetServerTimeNow() - serverTimeNow) / duration, 1)
						magnitude2 = (spawnCF.p - cFrame.p).Magnitude
						local ray, v7, _ = Util.Ray(
							v3.p,
							v3.lookVector.Unit * magnitude,
							{ workspace.Characters, workspace.Enemies },
							false
						)
						local lerped = spawnCF:Lerp(spawnCF * CFrame.new(0, 0, -distance), v6)
						magnitude = (cFrame.p - lerped.p).Magnitude
						beamEnd.CFrame = lerped
						beamEnd.Size = createVector(6, 6, 6)
						beamRay.CFrame = CFrame.new(spawnCF.p, lerped.p) * CFrame.new(0, 0, -magnitude2 / 2) * CFrame.Angles(
							0,
							1.5707963267948966,
							0
						)
						beamRay.Size = Vector3.new(magnitude2, 6, 6)

						if os.clock() - now2 > 0.05 then
							local clone2 = freezeBlast.BeamLayer:Clone()
							debris:AddItem(v2, 2)
							clone2.CFrame = spawnCF * CFrame.Angles(1.5707963267948966, 0, 0)
							clone2.Parent = _WorldOrigin
							table.insert(v2, { clone2, os.clock() })
							now2 = os.clock()
						end

						if #v2 > 0 then
							v3 = cFrame
							cFrame = lerped

							for _, v8 in pairs(v2) do
								if v8[1] == nil then
									continue
								end

								local v9 = (os.clock() - v8[2]) / duration

								if v9 >= 1 then
									v8[1]:Destroy()
								else
									v8[1].Position = spawnCF.Position:Lerp(beamEnd.CFrame.Position, v9)
								end
							end
						else
							v3 = cFrame
							cFrame = lerped
						end

						for _, child in pairs(beamEnd:GetChildren()) do
							if not v5[child.Name] then
								continue
							end

							local nows = v5[child.Name]

							if not (os.clock() - nows[2] > nows[1]) then
								continue
							end

							child:Emit(child:GetAttribute("EmitCount"))
							nows[2] = os.clock()
						end

						if ray then
							cFrame = CFrame.new(v7) * (cFrame - cFrame.p)
							value = cFrame.p
							break
						elseif value then
							break
						else
							RunService.RenderStepped:Wait()
						end
					end
				end

				task.spawn(function()
					local lastTime = os.clock()
					local v5 = 0.016666666666666666

					for _ = 1, 30 do
						if not (#v2 > 0) then
							break
						end

						for _, v6 in pairs(v2) do
							if v6[1] == nil then
								continue
							end

							v6[1].CFrame *= CFrame.new(0, v5 * -2 * 60, 0)
							v6[1].Decal.Transparency = misc.lerp(0, 1, (os.clock() - lastTime) / 0.5)
							v6[1].Mesh.Scale = v6[1].Mesh.Scale:Lerp(
								createVector(1, 120, 1),
								(os.clock() - lastTime) / 0.5
							)
						end

						v5 = RunService.Heartbeat:Wait()
					end

					if #v2 > 0 then
						for _, v6 in pairs(v2) do
							if v6[1] ~= nil then
								v6[1].Decal.Transparency = 1
							end
						end
					end

					task.delay(1, function()
						if #v2 > 0 then
							for _, v6 in pairs(v2) do
								if v6[1] ~= nil then
									v6[1]:Destroy()
								end
							end
						end

						v2 = nil
					end)
				end)
				beamEnd.CFrame = cFrame
				beamRay.CFrame = CFrame.new(spawnCF.p, cFrame.p) * CFrame.new(0, 0, -magnitude2 / 2) * CFrame.Angles(
					0,
					1.5707963267948966,
					0
				)
				beamRay.Size = Vector3.new(magnitude2, 6, 6)

				if beamEnd then
					for _, beam in pairs(beamEnd:GetChildren()) do
						if beam:IsA("Beam") then
							beam.Enabled = false
						end
					end

					beamEnd.Transparency = 1
				end

				task.spawn(function()
					if beamRay then
						for i = 1, 30 do
							if beamRay then
								beamRay.Size = misc.lerp(
									Vector3.new(beamRay.Size.X, 6, 6),
									Vector3.new(beamRay.Size.X, 0, 0),
									i / 30
								)
							end

							if beamRoot then
								beamRoot.Size = misc.lerp(createVector(6, 6, 6), createVector(0, 0, 0), i / 30)
							end

							task.wait()
						end

						if beamRay then
							beamRay:Destroy()
						end

						if beamRoot then
							beamRoot:Destroy()
						end
					end

					task.delay(1, function()
						if clone then
							clone:Destroy()
						end
					end)
				end)

				if not value then
					value = cFrame.Position
				end

				if changedConnection then
					changedConnection:Disconnect()
				end

				if value.Y <= seaLevel + 1 then
					v = true
					local X = value.X
					value = Vector3.new(X, -4, value.Z)
				end
			end)
		end
	else
		if ID == 3 then
			return
		end

		if ID == 4 then
			local impactPosition = data.ImpactPosition
			local scaler = data.Scaler
			local iceDuration = data.IceDuration
			local spiked = data.Spiked
			local v = impactPosition.Y <= -3
			local magnitude = (workspace.CurrentCamera.CFrame.Position - impactPosition).Magnitude

			if magnitude > 3000 then
				return
			end

			local cframe = CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
			local cFrame2 = CFrame.new(impactPosition + createVector(0, 30, 0) * scaler) * cframe
			local v3 = CFrame.new(impactPosition + createVector(0, 10, 0) * scaler) * cframe
			Color3.fromRGB(250, 350, 1000)
			decalShockwave(cFrame2, v3, 1, nil, createVector(0.2, 3, 0.2) * scaler, createVector(2.5, 1, 2.5) * scaler) -- equivalent call inferred; original call site unknown

			if magnitude <= 250 * scaler then
				local v7 = math.min(1, (250 * scaler - magnitude) / (250 * scaler))
				Util.CameraShaker:ShakeOnce(v7 * 6, v7 * 10, v7 * 0.4, v7 * 0.2)
			end

			Util.Sound:Play("IcebergExplosion", impactPosition, nil, math.random(9, 12) / 10, 0.75)
			local clone = freezeBlast.BeamHit:Clone()
			debris:AddItem(clone, 3)
			clone.CFrame = CFrame.new(impactPosition)
			clone.Parent = _WorldOrigin

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				misc.scaleParticle(emitter, scaler, true)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			if v then
				Effect.new("Leviathan.Splash"):replicate({
					CFrame = CFrame.new(impactPosition),
					Scale = 1.3
				})

				if spiked then
					local v7 = os.clock() + iceDuration
					local maid = Util.Maid.new()
					maid:GiveTask(spiked)
					local v8 = false
					local v9 = 0

					local function apply(folder)
						if folder:GetAttribute("AppliedLayer") then
							return
						end

						folder:SetAttribute("AppliedLayer", true)
						local maid2 = Util.Maid.new()
						local cFrame = folder.CFrame
						local cFrame3 = folder.CFrame * CFrame.new(
							0,
							-(cFrame.Position.Y + 5) / cFrame.UpVector.Y - folder.Size.Y / 2,
							0
						)
						folder.Transparency = 0
						folder.CFrame = cFrame3
						local v11 = false
						maid2:GiveTask(folder:GetPropertyChangedSignal("Parent"):Connect(function()
							if not folder.Parent and spiked.Parent and not v11 then
								if v9 < os.clock() then
									Util.Sound:Play("Ice_pheasant_hit", folder.CFrame.Position, nil, 0.4, 0.6)
									v9 = os.clock() + 1
								end

								local clone2 = folder:Clone()
								clone2.CanCollide = false
								clone2.CanTouch = false
								clone2.CanQuery = false
								clone2.Transparency = 1
								clone2.Parent = _WorldOrigin

								for _, emitter in pairs(clone2:GetDescendants()) do
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
						clone2.Transparency = 1
						clone2.Parent = _WorldOrigin
						local v12 = boatTween:Create(folder, {
							Time = math.random() * 0.15000000000000002 + 0.3,
							EasingStyle = "Sine",
							EasingDirection = "Out",
							StepType = "Heartbeat",
							Reverses = false,
							Goal = {
								CFrame = cFrame,
								Color = Color3.fromRGB(121, 161, 168)
							}
						})
						maid2:GiveTask(clone2)
						maid2:GiveTask(v12.Completed:Connect(function()
							clone2.Transparency = 0
							clone2.CFrame = folder.CFrame
							clone2.Parent = _WorldOrigin
							folder.CanCollide = true
							boatTween:Create(folder, {
								Time = 1,
								EasingStyle = "Sine",
								EasingDirection = "In",
								StepType = "Heartbeat",
								Reverses = false,
								Goal = {
									Transparency = 0.6
								}
							}):Play()
							task.wait(v7 - os.clock() - 1)
							v11 = true

							if folder and folder.Parent then
								local time = math.random() * 0.5 + 0.5
								local v14 = boatTween:Create(clone2, {
									Time = time,
									EasingStyle = "Sine",
									EasingDirection = "In",
									StepType = "Heartbeat",
									Reverses = false,
									Goal = {
										CFrame = cFrame3
									}
								})
								boatTween:Create(folder, {
									Time = time,
									EasingStyle = "Sine",
									EasingDirection = "In",
									StepType = "Heartbeat",
									Reverses = false,
									Goal = {
										CFrame = cFrame3
									}
								}):Play()
								boatTween:Create(folder, {
									Time = math.random() * 0.09999999999999998 + 0.2,
									EasingStyle = "Sine",
									EasingDirection = "In",
									StepType = "Heartbeat",
									Reverses = false,
									Goal = {
										Transparency = 1
									}
								}):Play()
								maid2:GiveTask(v14.Completed:Connect(function()
									if folder then
										folder:Destroy()
										clone2:Destroy()
									end

									v14 = nil
								end))
								v14:Play()
							end
						end))
						v12:Play()
						task.delay(0.2, function()
							for _, emitter in pairs(folder:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end
						end)
					end

					spiked.ChildAdded:Connect(apply)

					for _, child in pairs(spiked:GetChildren()) do
						apply(child)
					end

					spiked.Parent = workspace.Map
					maid:GiveTask(spiked:GetPropertyChangedSignal("Parent"):Connect(function()
						if not spiked.Parent then
							maid:DoCleaning()
						end
					end))
					task.delay(v7 - os.clock(), function()
						v8 = true
						maid:DoCleaning()
					end)
				end

				local clone2 = data.SpikyFloor and freezeBlast.IcePatch:Clone() or freezeBlast.ice:Clone()
				clone2.Size = createVector(1, 1, 1)
				clone2.CFrame = CFrame.new(impactPosition) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
				clone2.CanCollide = false
				clone2.Parent = _WorldOrigin
				debris:AddItem(clone2, iceDuration + 3)
				local size = Vector3.new(20, 1 + math.random() * 3, 20) * Vector3.new(scaler, 1, scaler)
				local v8 = boatTween:Create(clone2, {
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
				v8.Completed:Connect(function()
					clone2.CanCollide = true
					local clone3 = clone2:Clone()
					clone3.Size = clone2.Size - createVector(0.1, 0.1, 0.1)
					clone3.Parent = _WorldOrigin
					clone3.Material = Enum.Material.Ice
					clone3.Parent = _WorldOrigin
					boatTween:Create(clone2, {
						Time = 1,
						EasingStyle = "Sine",
						EasingDirection = "In",
						StepType = "Heartbeat",
						Reverses = false,
						Goal = {
							Transparency = 0.6
						}
					}):Play()
					boatTween:Create(clone3, {
						Time = 1,
						EasingStyle = "Sine",
						EasingDirection = "In",
						StepType = "Heartbeat",
						Reverses = false,
						Goal = {
							Transparency = 0.6
						}
					})
					task.wait(iceDuration)

					if clone2 then
						local time = math.random() * 0.5 + 0.5
						local v10 = boatTween:Create(clone2, {
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
						boatTween:Create(clone3, {
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
						v10.Completed:Connect(function()
							if clone2 then
								clone2:Destroy()
								clone3:Destroy()
							end

							v10 = nil
						end)
						v10:Play()
					end
				end)
				v8:Play()
			end

			task.spawn(function()
				local clones = {}
				local total = 5

				for i = 1, math.random(1, 3) do
					local clone2 = freezeBlast.IceTrail:Clone()
					debris:AddItem(clone2, 8)
					clone2.CFrame = CFrame.new(impactPosition + Vector3.new(0, math.random(-10, 10) / 10, 0)) * CFrame.Angles(
						0,
						math.rad(i * 120),
						0
					)
					clone2.Parent = _WorldOrigin
					clone2.Trail.Enabled = true
					clone2.Dust.Enabled = true
					clone2.Wind.Enabled = true
					clone2.IceFlakes.Enabled = true
					table.insert(clones, clone2)
				end

				local total2 = 0
				local v7 = 0.016666666666666666

				for i = 1, 60 do
					if i > 30 then
						total += math.random(-5, 5) / 60
					end

					total2 += i < 90 and 0.2 or 0.05

					for _, v8 in pairs(clones) do
						v8.CFrame *= CFrame.Angles(0, math.rad(total * v7 * 60), 0) * CFrame.new(
							0,
							v7 * 1 * 60 + math.sin(total2) * 1,
							v7 * 5 * 60
						)
					end

					v7 = RunService.RenderStepped:Wait()
				end

				if #clones > 0 then
					for _, v8 in pairs(clones) do
						for _, effect in pairs(v8:GetChildren()) do
							if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
								effect.Enabled = false
							end

							local v9 = v8
							task.delay(1.5, function()
								if v9 then
									v9:Destroy()
								end
							end)
						end
					end
				end
			end)
		end
	end
end