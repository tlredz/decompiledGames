local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local sunCloud = FX:WaitForChild("Soul").SunCloud
local _ = Util.Sound
local masterClock = Util.MasterClock
local _ = Util.Debris
local lightningBolt = Util.LightningBolt

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback((humanoidRootPart.Position - p).magnitude)
		end
	end
end

local v = {
	loopActive = false,
	ActivePairs = {}
}

function v:StartRenderLoop()
	task.spawn(function()
		local _, result = pcall(function()
			if #v.ActivePairs > 0 then
				v.loopActive = true

				while #v.ActivePairs > 0 do
					for k, activePair in pairs(v.ActivePairs) do
						local v2 = activePair[1]
						local v3 = activePair[2]
						local v4 = activePair[3]
						local v5 = activePair[4]
						local v6 = activePair[5] > 0 and 10 or 6

						if v2 == nil or v2.Parent == nil or v2.Parent.Parent == nil then
							if v3 then
								v3:Destroy()
							end

							if v4 then
								v4:Destroy()
							end

							table.remove(v.ActivePairs, k)
						else
							if activePair[6] >= 375 then
								activePair[6] = 1
							else
								activePair[6] += 1
							end

							if v5 == 0 then
								v3:SetPrimaryPartCFrame(cflerp(
									v3.PrimaryPart.CFrame,
									v2.CFrame * CFrame.new(v6, math.sin(activePair[6] / 30) * 0.5 + 1.5, 0),
									0.1
								))
								v4:SetPrimaryPartCFrame(cflerp(
									v4.PrimaryPart.CFrame,
									v2.CFrame * CFrame.new(-v6, math.sin(activePair[6] / 30) * 0.5 + 1.5, 0),
									0.1
								))
							elseif v5 ~= 1 then
								if v5 == 2 then
									v4:SetPrimaryPartCFrame(cflerp(
										v4.PrimaryPart.CFrame,
										v2.CFrame * CFrame.new(-v6, math.sin(activePair[6] / 30) * 0.5 + 1.5, 0),
										0.1
									))
								elseif v5 == 3 then
									v3:SetPrimaryPartCFrame(cflerp(
										v3.PrimaryPart.CFrame,
										v2.CFrame * CFrame.new(v6, math.sin(activePair[6] / 30) * 0.5 + 1.5, 0),
										0.1
									))
								end
							end
						end
					end

					RunService.RenderStepped:Wait()
				end

				v.loopActive = false
			end
		end)

		if result then
			warn("[Soul Fruit] Something went wrong in the Sun & Cloud main loop: \n", result)

			if #v.ActivePairs > 0 then
				for _, activePair in pairs(v.ActivePairs) do
					if activePair[2] then
						activePair[2]:Destroy()
					end

					if activePair[3] then
						activePair[3]:Destroy()
					end
				end

				v.loopActive = false
				v.ActivePairs = {}
			end
		end
	end)
end

function v:GetInfo(p)
	if #v.ActivePairs > 0 then
		for _, activePair in pairs(v.ActivePairs) do
			if activePair[1] == p then
				return activePair
			end
		end
	end

	return nil
end

function v:Add(p, p2)
	local info = v:GetInfo(p)

	if info then
		return info
	end

	local clone = sunCloud.Sun:Clone()
	local clone2 = sunCloud.Cloud:Clone()
	clone:SetPrimaryPartCFrame(p.CFrame * CFrame.new(6, 40, 0))
	clone2:SetPrimaryPartCFrame(p.CFrame * CFrame.new(-6, 40, 0))
	clone.Parent = _WorldOrigin
	clone2.Parent = _WorldOrigin
	table.insert(v.ActivePairs, {
		p,
		clone,
		clone2,
		0,
		p2,
		1
	})

	if v.loopActive then
		return
	end

	v:StartRenderLoop()
end

function v:Remove(p)
	if #v.ActivePairs > 0 then
		for k, activePair in pairs(v.ActivePairs) do
			if not (activePair[1] == nil or activePair[1] == p) then
				continue
			end

			if activePair[2] then
				local clone = sunCloud.TransformFX:Clone()
				Util.Debris:AddItem(clone, 2)
				clone.Position = activePair[2].RootPart.Position
				clone.Parent = _WorldOrigin
				clone.Flames:Emit(10)
				clone.Embers:Emit(8)
				Util.Sound:Play("Engulf", clone, nil, 1, 1)
				activePair[2]:Destroy()
			end

			if activePair[3] then
				local clone = sunCloud.TransformFX:Clone()
				Util.Debris:AddItem(clone, 2)
				clone.Position = activePair[3].RootPart.Position
				clone.Parent = _WorldOrigin
				clone.DarkClouds:Emit(10)
				clone.BranchSparks:Emit(8)
				Util.Sound:Play("ElectricBallShot", clone, nil, 1, 2)
				activePair[3]:Destroy()
			end

			table.remove(v.ActivePairs, k)
		end
	end
end

local v2 = {
	Calm = {
		BranchSparks = {
			Enabled = false
		},
		Sparks = {
			Enabled = false,
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.874), NumberSequenceKeypoint.new(1, 0) }),
			Rate = 2,
			Speed = NumberRange.new(10, 25)
		},
		DarkClouds = {
			Enabled = false
		},
		LightClouds = {
			Enabled = true
		},
		Wind = {
			Enabled = true
		},
		FlickerWaves = {
			Enabled = false
		}
	},
	Neutral = {
		BranchSparks = {
			Enabled = true
		},
		Sparks = {
			Enabled = true,
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.874), NumberSequenceKeypoint.new(1, 0) }),
			Rate = 2,
			Speed = NumberRange.new(10, 25)
		},
		DarkClouds = {
			Enabled = true
		},
		LightClouds = {
			Enabled = false
		},
		Wind = {
			Enabled = false
		},
		FlickerWaves = {
			Enabled = false
		}
	},
	Fury = {
		BranchSparks = {
			Enabled = true
		},
		Sparks = {
			Enabled = true,
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.91), NumberSequenceKeypoint.new(1, 0) }),
			Rate = 5,
			Speed = NumberRange.new(50, 60)
		},
		DarkClouds = {
			Enabled = true
		},
		LightClouds = {
			Enabled = false
		},
		Wind = {
			Enabled = false
		},
		FlickerWaves = {
			Enabled = true
		}
	}
}
local v3 = {
	Calm = {
		Embers = {
			Enabled = true
		},
		Flames = {
			Enabled = true,
			Squash = NumberSequence.new(0),
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 2.4) }),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.333, 0.1),
				NumberSequenceKeypoint.new(0.41, 0.825),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Acceleration = createVector(0, 0, 0),
			Speed = NumberRange.new(2, 5),
			Lifetime = NumberRange.new(0.5, 1),
			ZOffset = -1
		},
		Rays = {
			Enabled = true,
			Squash = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0.525, 0.788),
				NumberSequenceKeypoint.new(1, 0, 0)
			}),
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3.88), NumberSequenceKeypoint.new(1, 0) }),
			ZOffset = -3
		},
		Rings = {
			Enabled = true,
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.501, 4.15),
				NumberSequenceKeypoint.new(0.758, 4.92),
				NumberSequenceKeypoint.new(1, 5)
			})
		}
	},
	Neutral = {
		Embers = {
			Enabled = true
		},
		Flames = {
			Enabled = true,
			Squash = NumberSequence.new(0),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 2.3, 1.2),
				NumberSequenceKeypoint.new(1, 0)
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.333, 0.1),
				NumberSequenceKeypoint.new(0.658, 0.431),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Acceleration = createVector(0, 20, 10),
			Speed = NumberRange.new(2, 5),
			Lifetime = NumberRange.new(0.5, 1),
			ZOffset = 0
		},
		Rays = {
			Enabled = true,
			Squash = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0.525, 0.788),
				NumberSequenceKeypoint.new(1, 0, 0)
			}),
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3.88), NumberSequenceKeypoint.new(1, 0) }),
			ZOffset = -3
		},
		Rings = {
			Enabled = true,
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.501, 4.15),
				NumberSequenceKeypoint.new(0.758, 4.92),
				NumberSequenceKeypoint.new(1, 5)
			})
		}
	},
	Fury = {
		Embers = {
			Enabled = true
		},
		Flames = {
			Enabled = true,
			Squash = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0.0645, 1.35),
				NumberSequenceKeypoint.new(1, 0)
			}),
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 7.98) }),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.333, 0.1),
				NumberSequenceKeypoint.new(0.41, 0.825),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Acceleration = createVector(0, 0, 0),
			Speed = NumberRange.new(2, 5),
			Lifetime = NumberRange.new(0.5, 1),
			ZOffset = -0.5
		},
		Rays = {
			Enabled = true,
			Squash = NumberSequence.new({
				NumberSequenceKeypoint.new(0, -0.75),
				NumberSequenceKeypoint.new(0.5, 0.862, 0.788),
				NumberSequenceKeypoint.new(1, -0.825, 0)
			}),
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 5.57, 1.04), NumberSequenceKeypoint.new(1, 0) }),
			ZOffset = -3
		},
		Rings = {
			Enabled = true,
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.501, 6.34),
				NumberSequenceKeypoint.new(0.758, 7.92),
				NumberSequenceKeypoint.new(1, 8.74)
			})
		}
	}
}

function swapMood(list, p)
	local particleAttachment = list[2].RootPart.ParticleAttachment
	local particleAttachment2 = list[3].RootPart.ParticleAttachment
	local retopo_Cube003 = list[3]["Retopo_Cube.003"]
	local cube015 = list[2]["Cube.015"]
	list[5] = p

	local function changeParticles(p2, particleAttachment3, p3)
		for k, v4 in pairs(p2[p3]) do
			local v5 = k
			local v6 = v4
			local _, _ = pcall(function()
				local child = particleAttachment3:FindFirstChild(v5)

				if child then
					for k2, v7 in pairs(v6) do
						child[k2] = v7
					end
				end
			end)
		end
	end

	for _, surfaceAppearance in pairs(retopo_Cube003:GetChildren()) do
		if surfaceAppearance:IsA("SurfaceAppearance") then
			surfaceAppearance:Destroy()
		end
	end

	if p == -2 or p == -1 then
		local clone_2 = sunCloud.NormalSurface:Clone()
		clone_2.Parent = retopo_Cube003
		cube015.Transparency = 0
		changeParticles(v3, particleAttachment, "Calm")
		changeParticles(v2, particleAttachment2, "Calm")
	elseif p == 0 then
		if list[3].Name == "CloudBig" then
			local clone = sunCloud.Cloud:Clone()
			local v4 = list[3]
			clone:SetPrimaryPartCFrame(v4.RootPart.CFrame)
			list[3] = clone
			clone.Parent = _WorldOrigin
			particleAttachment2 = clone.RootPart.ParticleAttachment
			v4:Destroy()
			local clone2 = sunCloud.TransformFX:Clone()
			Util.Debris:AddItem(clone2, 2)
			clone2.Position = particleAttachment2.WorldPosition
			clone2.Parent = _WorldOrigin
			clone2.DarkClouds:Emit(10)
			clone2.BranchSparks:Emit(8)
			Util.Sound:Play("ElectricBallShot", clone2, nil, 2, 2)
			local clone3 = sunCloud.TransformFX:Clone()
			Util.Debris:AddItem(clone3, 2)
			clone3.Position = particleAttachment.WorldPosition
			clone3.Parent = _WorldOrigin
			clone3.Flames:Emit(10)
			clone3.Embers:Emit(8)
			Util.Sound:Play("Engulf", clone3, nil, 1.3, 1)
		end

		local clone_3 = sunCloud.DarkSurface:Clone()
		clone_3.Parent = retopo_Cube003
		cube015.Transparency = 1
		changeParticles(v3, particleAttachment, "Neutral")
		changeParticles(v2, particleAttachment2, "Neutral")
		local playingAnimationTracks = list[2].AnimationController:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in pairs(playingAnimationTracks) do
			playingAnimationTrack:Stop()
		end

		local playingAnimationTracks2 = list[3].AnimationController:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in pairs(playingAnimationTracks2) do
			playingAnimationTrack:Stop()
		end
	elseif p == 1 or p == 2 then
		if list[3].Name ~= "CloudBig" then
			local clone = sunCloud.CloudBig:Clone()
			local v4 = list[3]
			clone:SetPrimaryPartCFrame(v4.RootPart.CFrame)
			list[3] = clone
			clone.Parent = _WorldOrigin
			particleAttachment2 = clone.RootPart.ParticleAttachment
			v4:Destroy()
			local clone2 = sunCloud.TransformFX:Clone()
			Util.Debris:AddItem(clone2, 2)
			clone2.Position = particleAttachment2.WorldPosition
			clone2.Parent = _WorldOrigin
			clone2.DarkClouds:Emit(10)
			clone2.BranchSparks:Emit(8)
			Util.Sound:Play("ElectricBallShot", clone2, nil, 1.5, 2)
			local clone3 = sunCloud.TransformFX:Clone()
			Util.Debris:AddItem(clone3, 2)
			clone3.Position = particleAttachment.WorldPosition
			clone3.Parent = _WorldOrigin
			clone3.Flames:Emit(10)
			clone3.Embers:Emit(8)
			Util.Sound:Play("Engulf", clone3, nil, 1, 1)
			local track = list[2].AnimationController:LoadAnimation(list[2].SunAngry)
			track:Play()
			track:AdjustSpeed(1)
			task.spawn(function()
				wait(1)
				track.TimePosition = 1
				track:AdjustSpeed(0)
			end)
			local track2 = list[3].AnimationController:LoadAnimation(clone.BigCloudAngry)
			track2:Play()
			track2:AdjustSpeed(1)
			task.spawn(function()
				wait(1)
				track2.TimePosition = 1
				track2:AdjustSpeed(0)
			end)
		end

		cube015.Transparency = 1
		changeParticles(v3, particleAttachment, "Fury")
		changeParticles(v2, particleAttachment2, "Fury")
	end
end

return function(data)
	local actionID = data.ActionID
	local root = data.Root

	if root then
		if actionID == 1 then
			local mood = data.Mood or 0
			v:Add(root, mood)
		elseif actionID == 2 then
			v:Remove(root)
		elseif actionID == 3 then
			local mood = data.Mood
			local info = v:GetInfo(root)

			if info and info[2] ~= nil and info[3] ~= nil then
				swapMood(info, mood)
			end
		elseif actionID == 4 then
			task.spawn(function()
				local info = v:GetInfo(root)

				if info then
					local holdValue = data.HoldValue
					local startupTime = data.StartupTime
					info[4] = 3
					local lastTime = tick()

					-- equivalent calls inferred from this helper; original call sites unknown
					local function running()
						return tick() - lastTime < startupTime or data.HoldValue and data.HoldValue.Value == true
					end

					local v4 = info[1]
					local v5 = info[3]
					Util.Sound:Play("Grab", v4, nil, 1.2, 0.6)
					Util.Sound:Play("FlybySwoosh", v4, nil, 2, 0.5)
					local v6 = 0.01

					while running() and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and v5 and v4 do
						v6 = math.clamp(v6 + 0.04, 0.02, 0.95)

						if v5.PrimaryPart then
							v5:SetPrimaryPartCFrame(cflerp(v5.PrimaryPart.CFrame, v4.CFrame * CFrame.new(0, -2, 0), v6))
						end

						RunService.RenderStepped:Wait()
					end

					info[4] = 0
				end
			end)
		elseif actionID == 5 then
			task.spawn(function()
				local info = v:GetInfo(root)

				if info then
					local holdValue = data.HoldValue
					local startupTime = data.StartupTime
					info[4] = 2
					local lastTime = tick()

					-- equivalent calls inferred from this helper; original call sites unknown
					local function running()
						return tick() - lastTime < startupTime or data.HoldValue and data.HoldValue.Value == true
					end

					local v4 = info[1]
					local v5 = info[2]
					Util.Sound:Play("Grab", v4, nil, 1.2, 0.6)
					Util.Sound:Play("FlybySwoosh", v4, nil, 2, 0.5)
					local v6 = 0.01

					while running() and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and v5 and v4 do
						v6 = math.clamp(v6 + 0.04, 0.02, 0.95)
						v5:SetPrimaryPartCFrame(cflerp(v5.PrimaryPart.CFrame, v4.CFrame * CFrame.new(0, -2.5, 0), v6))
						RunService.RenderStepped:Wait()
					end

					info[4] = 0
				end
			end)
		elseif actionID == 6 then
			task.spawn(function()
				local info = v:GetInfo(root)

				if info then
					local holdValue = data.HoldValue
					local startupTime = data.StartupTime
					local timestamp = data.Timestamp
					local lifetime = data.Lifetime
					local distance = data.Distance
					local startCF = data.StartCF
					info[4] = 2
					local v4 = lifetime - (masterClock:GetTime() - timestamp)
					local lastTime = tick()

					-- equivalent calls inferred from this helper; original call sites unknown
					local function running()
						return tick() - lastTime < startupTime or data.HoldValue and data.HoldValue.Value == true
					end

					local v5 = info[1]
					local v6 = info[2]
					Util.Sound:Play("SetFire2", v5, nil, 1.2, 0.6)
					Util.Sound:Play("FlybySwoosh", v5, nil, 2, 0.5)
					local v7 = 0.01

					while running() and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and v6 and v5 do
						v7 = math.clamp(v7 + 0.04, 0.02, 0.98)
						local _ = (tick() - lastTime) / v4
						local v8 = (tick() - lastTime) / 100 / (v4 / 100)
						local lerped = startCF:Lerp(startCF * CFrame.new(0, 0, -distance), v8)
						v6:SetPrimaryPartCFrame(cflerp(v6.PrimaryPart.CFrame, lerped, v7))
						RunService.RenderStepped:Wait()
					end

					wait(0.5)
					info[4] = 0
				end
			end)
		elseif actionID == 7 then
			task.spawn(function()
				local info = v:GetInfo(root)

				if info then
					info[4] = 3
					local timestamp = data.Timestamp
					local _ = data.Lifetime
					local v4 = data.Lifetime - (masterClock:GetTime() - timestamp)
					local startCF = data.StartCF
					local distance = data.Distance
					local boolValue = Instance.new("BoolValue")
					Util.Debris:AddItem(boolValue, 2)
					boolValue.Name = "StopSoulForces"
					boolValue.Parent = root.Parent
					local lastTime = tick()

					-- equivalent calls inferred from this helper; original call sites unknown
					local function running()
						return tick() - lastTime < v4 or data.HoldValue and data.HoldValue.Value == true
					end

					local v5 = info[1]
					local v6 = info[3]
					local v7 = Util.BodyMover.new(v5.Parent):Create("BodyPosition", {
						Priority = -10000,
						Position = startCF.Position
					})
					local v8 = Util.BodyMover.new(v5.Parent):Create("BodyGyro", {
						CFrame = startCF
					})
					Util.Sound:Play("ElectricBuzz", v5, nil, 1, 1.5)
					local v9 = 0.01

					while running() and v6 and v5 do
						v9 = math.clamp(v9 + 0.2, 0.02, 0.95)
						v7:Set(cflerp(v5.CFrame, startCF * CFrame.new(0, 0, -distance), v9).Position)
						v6:SetPrimaryPartCFrame(cflerp(v6.PrimaryPart.CFrame, v5.CFrame * CFrame.new(0, -3, 0), v9))
						RunService.RenderStepped:Wait()
					end

					task.spawn(function()
						wait(0.5)

						if v7 then
							v7:Destroy()
						end

						if v8 then
							v8:Destroy()
						end
					end)
					info[4] = 0
				end
			end)
		elseif actionID == 8 then
			local function disableParticles(attachment)
				for _, child in pairs(attachment:GetChildren()) do
					if child:IsA("Light") or child:IsA("ParticleEmitter") then
						child.Enabled = false
					end
				end
			end

			task.spawn(function()
				local info = v:GetInfo(root)

				if info then
					local holdValue = data.HoldValue
					local endPoint = data.EndPoint
					local _ = data.WinddownTime
					local minimum = data.Minimum
					local duration = data.Duration
					local timestamp = data.Timestamp
					local v4 = math.max(duration - (masterClock:GetTime() - timestamp), 0.5)

					if (endPoint.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
						return
					end

					info[4] = 1
					local time = masterClock:GetTime()

					-- equivalent calls inferred from this helper; original call sites unknown
					local function running()
						if masterClock:GetTime() - time < v4 then
							return masterClock:GetTime() - time < minimum or holdValue and holdValue.Value == true
						end

						return false
					end

					local v5 = info[1]
					local v6 = info[2]
					local v7 = info[3]
					local v8 = v4 + 2
					local clone = sunCloud.ElectricBeamStart:Clone()
					Util.Debris:AddItem(clone, v8)
					clone.Size = createVector(4, 4, 4)
					clone.CFrame = v7.RootPart.CFrame * CFrame.new(0, 0, -2)
					clone.Parent = _WorldOrigin
					clone.Attachment.Sparkle:Emit(2)
					clone.Attachment.SparkleDark:Emit(2)
					local clone2 = sunCloud.ElectricBeamHit:Clone()
					Util.Debris:AddItem(clone2, v8)
					clone2.Position = endPoint.Position
					clone2.Parent = _WorldOrigin
					local magnitude = (clone.Position - clone2.Position).Magnitude
					local cFrame = CFrame.new(clone.Position, clone2.Position) * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					)
					local clone3 = sunCloud.ElectricBeam:Clone()
					Util.Debris:AddItem(clone3, v8)
					clone3.CFrame = cFrame
					clone3.Size = Vector3.new(magnitude, 4, 4)
					clone3.Parent = _WorldOrigin
					local v10 = lightningBolt.new(
						clone.Attachment,
						clone2.Attachment,
						math.random(-20, 20),
						math.random(-20, 20),
						math.random(15, 20),
						Color3.fromRGB(213, 151, 88)
					)
					v10.Color = Color3.fromRGB(91, 36, 200)
					v10.AnimationSpeed = 20
					v10.Thickness = 0.6
					v10.CurveSize0 = 0
					v10.CurveSize1 = 0
					v10.PulseSpeed = 45
					v10.Thickness = 3
					v10.MinThicknessMultiplier = 0.2
					v10.MaxThicknessMultiplier = 2
					v10.MaxAngleOffset = 0.3490658503988659
					local clone4 = sunCloud.SolarBeamStart:Clone()
					Util.Debris:AddItem(clone4, v8)
					clone4.Size = createVector(4, 4, 4)
					clone4.CFrame = v6.RootPart.CFrame * CFrame.new(0, 0, -2)
					clone4.Parent = _WorldOrigin
					clone4.Attachment.Sparkle:Emit(2)
					clone4.Attachment.SparkleDark:Emit(2)
					local clone5 = sunCloud.SolarBeamHit:Clone()
					Util.Debris:AddItem(clone5, v8)
					clone5.Position = endPoint.Position
					clone5.Parent = _WorldOrigin
					local magnitude2 = (clone4.Position - clone5.Position).Magnitude
					local cFrame2 = CFrame.new(clone4.Position, clone5.Position) * CFrame.new(0, 0, -magnitude2 / 2) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					)
					local clone6 = sunCloud.SolarBeam:Clone()
					Util.Debris:AddItem(clone6, v8)
					clone6.CFrame = cFrame2
					clone6.Size = Vector3.new(magnitude2, 4, 4)
					clone6.Parent = _WorldOrigin
					local v12 = lightningBolt.new(
						clone4.Attachment,
						clone5.Attachment,
						math.random(-20, 20),
						math.random(-20, 20),
						math.random(15, 20),
						Color3.fromRGB(213, 151, 88)
					)
					v12.Color = Color3.fromRGB(213, 151, 88)
					v12.AnimationSpeed = 20
					v12.Thickness = 0.6
					v12.CurveSize0 = 0
					v12.CurveSize1 = 0
					v12.PulseSpeed = 45
					v12.Thickness = 3
					v12.MinThicknessMultiplier = 0.2
					v12.MaxThicknessMultiplier = 2
					v12.MaxAngleOffset = 0.3490658503988659
					local v13 = Util.Sound:Play("SoulBeams", v5, nil, 1, 1)
					local parent = Util.Sound:Play("SoulBeams", endPoint, nil, 1, 1.4)
					local flangeSoundEffect = Instance.new("FlangeSoundEffect")
					flangeSoundEffect.Depth = 1
					flangeSoundEffect.Rate = 1
					flangeSoundEffect.Parent = parent
					local v15 = Util.Sound:Play("ElectricLoop", endPoint, nil, 1, 1)
					Util.Sound:Play("ElectricBuzz", endPoint, nil, 0.4, 3)
					local now = tick() - 1

					while true do
						local v16 = running() -- equivalent call inferred; original call site unknown

						if v16 and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and v6 and v7 and v5 and endPoint then
							if tick() - now > 0.03 then
								clone5.Attachment.Sparkle:Emit(1)
								clone5.Attachment.SparkleDark:Emit(1)
								clone2.Attachment.Sparkle:Emit(1)
								clone2.Attachment.SparkleDark:Emit(1)
								now = tick()
							end

							clone4.CFrame = v6.RootPart.CFrame * CFrame.new(0, 0, -2)
							clone.CFrame = v7.RootPart.CFrame * CFrame.new(0, 0, -2)
							local position = clone5.Position
							clone5.Position = position + (endPoint.Position - position) * 0.15
							local position2 = clone2.Position
							clone2.Position = position2 + (endPoint.Position - position2) * 0.15
							v6:SetPrimaryPartCFrame(cflerp(
								v6.PrimaryPart.CFrame,
								CFrame.new((v5.CFrame * CFrame.new(10, 2.5, 0)).Position, endPoint.Position),
								0.15
							))
							v7:setPrimaryPartCFrame(cflerp(
								v7.PrimaryPart.CFrame,
								CFrame.new((v5.CFrame * CFrame.new(-10, 2.5, 0)).Position, endPoint.Position),
								0.15
							))
							local magnitude3 = (clone4.Position - clone5.Position).Magnitude
							local cFrame3 = CFrame.new(clone4.Position, clone5.Position) * CFrame.new(
								0,
								0,
								-magnitude3 / 2
							) * CFrame.Angles(0, 1.5707963267948966, 0)
							clone6.Size = Vector3.new(magnitude3, 4, 4)
							clone6.CFrame = cFrame3
							local magnitude4 = (clone.Position - clone2.Position).Magnitude
							local cFrame4 = CFrame.new(clone.Position, clone2.Position) * CFrame.new(
								0,
								0,
								-magnitude4 / 2
							) * CFrame.Angles(0, 1.5707963267948966, 0)
							clone3.Size = Vector3.new(magnitude4, 4, 4)
							clone3.CFrame = cFrame4
							local position3 = endPoint.Position
							local character = game.Players.LocalPlayer.Character

							if character ~= nil then
								local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

								if humanoidRootPart and (humanoidRootPart.Position - position3).magnitude <= 105 then
									local magnitude5 = (humanoidRootPart.Position - position3).magnitude
									Util.CameraShaker:ShakeOnce(46 / magnitude5, 15, 0.2, 0.2)
								end
							end

							RunService.RenderStepped:Wait()
						else
							Util.Sound:Play("Charge", clone5.Position, nil, 2, 3)
							local clone7 = sunCloud.ExplosionReady:Clone()
							Util.Debris:AddItem(clone7, 4)
							clone7.Position = clone5.Position
							local spikeWave = clone7.SpikeWave
							local suctionRibbons = clone7.SuctionRibbons
							clone7.Parent = _WorldOrigin
							task.spawn(function()
								for i = 1, 3 do
									spikeWave:Emit(2)
									suctionRibbons:Emit(2)
									wait(0.1)
								end
							end)

							if v15 then
								v15:Destroy()
							end

							for _, v19 in pairs({
								clone6,
								clone3,
								clone4,
								clone
							}) do
								if v19 == nil then
									continue
								end

								local tween = TweenService:Create(
									v19,
									TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
									{
										Size = Vector3.new(v19.Shape == Enum.PartType.Ball and 0 or v19.Size.X, 0, 0)
									}
								)
								local v20 = v19
								tween.Completed:Connect(function()
									if v20 then
										v20:Destroy()
									end
								end)
								tween:Play()
							end

							for _, v19 in pairs({ v13, parent }) do
								if v19 == nil then
									continue
								end

								local tween = TweenService:Create(
									v19,
									TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
									{
										Volume = 0
									}
								)
								local v20 = v19
								tween.Completed:Connect(function()
									if v20 then
										v20:Destroy()
									end
								end)
								tween:Play()
							end

							if v10 then
								v10:Destroy()
							end

							if v12 then
								v12:Destroy()
							end

							disableParticles(clone.Attachment)
							disableParticles(clone2.Attachment)
							disableParticles(clone4.Attachment)
							disableParticles(clone5.Attachment)
							info[4] = 0
							break
						end
					end
				end
			end)
		end
	end
end