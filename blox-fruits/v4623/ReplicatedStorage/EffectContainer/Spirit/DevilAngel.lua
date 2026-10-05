local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local devilAngel = FX:WaitForChild("Spirit").DevilAngel
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

						if v2 == nil or not v2:IsDescendantOf(workspace) then
							if v3 then
								v3:Destroy()
							end

							if v4 then
								v4:Destroy()
							end

							table.remove(v.ActivePairs, k)
						else
							if activePair[5] >= 375 then
								activePair[5] = 1
							else
								activePair[5] += 1
							end

							if v5 == 0 then
								v3:SetPrimaryPartCFrame(cflerp(
									v3.PrimaryPart.CFrame,
									v2.CFrame * CFrame.new(6, math.sin(activePair[5] / 30) * 0.5 + 1.5, 0),
									0.1
								))
								v4:SetPrimaryPartCFrame(cflerp(
									v4.PrimaryPart.CFrame,
									v2.CFrame * CFrame.new(-6, math.sin(activePair[5] / 30) * 0.5 + 1.5, 0),
									0.1
								))
							elseif v5 ~= 1 then
								if v5 == 2 then
									v4:SetPrimaryPartCFrame(cflerp(
										v4.PrimaryPart.CFrame,
										v2.CFrame * CFrame.new(-6, math.sin(activePair[5] / 30) * 0.5 + 1.5, 0),
										0.1
									))
								elseif v5 == 3 then
									v3:SetPrimaryPartCFrame(cflerp(
										v3.PrimaryPart.CFrame,
										v2.CFrame * CFrame.new(6, math.sin(activePair[5] / 30) * 0.5 + 1.5, 0),
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
			warn("[Spirit Fruit] Something went wrong in the Angel & Devil main loop: \n", result)

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

function v:Add(p)
	local info = v:GetInfo(p)

	if info then
		return info
	end

	local clone = devilAngel.Devil:Clone()
	local clone2 = devilAngel.Angel:Clone()
	clone:SetPrimaryPartCFrame(p.CFrame * CFrame.new(6, 40, 0))
	clone2:SetPrimaryPartCFrame(p.CFrame * CFrame.new(-6, 40, 0))
	clone.Parent = _WorldOrigin
	clone2.Parent = _WorldOrigin
	clone.AnimationController:LoadAnimation(clone.Idle):Play()
	clone2.AnimationController:LoadAnimation(clone2.Idle):Play()
	table.insert(v.ActivePairs, {
		p,
		clone,
		clone2,
		0,
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
				local clone = devilAngel.TransformFX:Clone()
				Util.Debris:AddItem(clone, 2)
				clone.Position = activePair[2].RootPart.Position
				clone.Parent = _WorldOrigin
				clone.Flames:Emit(10)
				clone.Embers:Emit(10)
				Util.Sound:Play("Engulf", clone, nil, 1, 1)
				activePair[2]:Destroy()
			end

			if activePair[3] then
				local clone = devilAngel.TransformFX:Clone()
				Util.Debris:AddItem(clone, 2)
				clone.Position = activePair[3].RootPart.Position
				clone.Parent = _WorldOrigin
				clone.ColdMist:Emit(10)
				clone.Snow:Emit(10)
				Util.Sound:Play("IceShoot", clone, nil, 3, 1.5)
				activePair[3]:Destroy()
			end

			table.remove(v.ActivePairs, k)
		end
	end
end

return function(data)
	local actionID = data.ActionID
	local root = data.Root

	if root then
		if actionID == 1 then
			v:Add(root)
			return
		elseif actionID == 2 then
			v:Remove(root)
			return
		elseif actionID == 3 then
			return
		end

		if actionID == 4 then
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

					local v2 = info[1]
					local v3 = info[3]
					Util.Sound:Play("Grab", v2, nil, 1.2, 0.6)
					Util.Sound:Play("FlybySwoosh", v2, nil, 2, 0.5)
					local v4 = 0.01

					while running() and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and v3 and v2 do
						v4 = math.clamp(v4 + 0.04, 0.02, 0.95)

						if v3.PrimaryPart then
							v3:SetPrimaryPartCFrame(cflerp(v3.PrimaryPart.CFrame, v2.CFrame * CFrame.new(0, -2, 0), v4))
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

					local v2 = info[1]
					local v3 = info[2]
					Util.Sound:Play("Grab", v2, nil, 1.2, 0.6)
					Util.Sound:Play("FlybySwoosh", v2, nil, 2, 0.5)
					local v4 = 0.01

					while running() and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and v3 and v2 do
						v4 = math.clamp(v4 + 0.04, 0.02, 0.95)
						v3:SetPrimaryPartCFrame(cflerp(v3.PrimaryPart.CFrame, v2.CFrame * CFrame.new(0, -2.5, 0), v4))
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
					local v2 = lifetime - (masterClock:GetTime() - timestamp)
					local lastTime = tick()

					-- equivalent calls inferred from this helper; original call sites unknown
					local function running()
						return tick() - lastTime < startupTime or data.HoldValue and data.HoldValue.Value == true
					end

					local v3 = info[1]
					local v4 = info[2]
					Util.Sound:Play("SetFire2", v3, nil, 1.2, 0.6)
					Util.Sound:Play("FlybySwoosh", v3, nil, 2, 0.5)
					local v5 = 0.01

					while running() and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and v4 and v3 do
						v5 = math.clamp(v5 + 0.04, 0.02, 0.98)
						local _ = (tick() - lastTime) / v2
						local v6 = (tick() - lastTime) / 100 / (v2 / 100)
						local lerped = startCF:Lerp(startCF * CFrame.new(0, 0, -distance), v6)
						v4:SetPrimaryPartCFrame(cflerp(v4.PrimaryPart.CFrame, lerped, v5))
						RunService.RenderStepped:Wait()
					end

					task.wait(0.5)
					info[4] = 0
					v4.AnimationController:LoadAnimation(v4.Action):Play()
				end
			end)
		elseif actionID == 7 then
			task.spawn(function()
				local info = v:GetInfo(root)

				if info then
					info[4] = 3
					local timestamp = data.Timestamp
					local _ = data.Lifetime
					local v2 = data.Lifetime - (masterClock:GetTime() - timestamp)
					local startCF = data.StartCF
					local distance = data.Distance
					local boolValue = Instance.new("BoolValue")
					Util.Debris:AddItem(boolValue, 2)
					boolValue.Name = "StopSoulForces"
					boolValue.Parent = root.Parent
					local lastTime = tick()

					-- equivalent calls inferred from this helper; original call sites unknown
					local function running()
						return tick() - lastTime < v2 or data.HoldValue and data.HoldValue.Value == true
					end

					local v3 = info[1]
					local v4 = info[3]
					local v5 = Util.BodyMover.new(v3.Parent):Create("BodyPosition", {
						Priority = -10000,
						Position = startCF.Position
					})
					local v6 = Util.BodyMover.new(v3.Parent):Create("BodyGyro", {
						CFrame = startCF
					})
					Util.Sound:Play("ElectricBuzz", v3, nil, 1, 1.5)
					local v7 = 0.01

					while running() and v4 and v3 do
						v7 = math.clamp(v7 + 0.2, 0.02, 0.95)
						v5:Set(cflerp(v3.CFrame, startCF * CFrame.new(0, 0, -distance), v7).Position)
						v4:SetPrimaryPartCFrame(cflerp(v4.PrimaryPart.CFrame, v3.CFrame * CFrame.new(0, -3, 0), v7))
						RunService.RenderStepped:Wait()
					end

					task.delay(0.5, function()
						if v5 then
							v5:Destroy()
						end

						if v6 then
							v6:Destroy()
						end
					end)
					info[4] = 0
					v4.AnimationController:LoadAnimation(v4.Action):Play()
				end
			end)
		elseif actionID == 8 then
			local function disableParticles(instance)
				for _, child in pairs(instance:GetChildren()) do
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
					local v2 = math.max(duration - (masterClock:GetTime() - timestamp), 0.5)

					if (endPoint.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
						return
					end

					info[4] = 1
					local time = masterClock:GetTime()

					-- equivalent calls inferred from this helper; original call sites unknown
					local function running()
						if masterClock:GetTime() - time < v2 then
							return masterClock:GetTime() - time < minimum or holdValue and holdValue.Value == true
						end

						return false
					end

					local v3 = info[1]
					local v4 = info[2]
					local v5 = info[3]
					local v6 = v2 + 2
					local clone = devilAngel.IceBeamStart:Clone()
					Util.Debris:AddItem(clone, v6)
					clone.Size = createVector(4, 4, 4)
					clone.CFrame = v5.RootPart.CFrame * CFrame.new(0, 0, -2)
					clone.Parent = _WorldOrigin
					clone.Attachment.Sparkle:Emit(2)
					clone.Attachment.SparkleDark:Emit(2)
					local clone2 = devilAngel.IceBeamHit:Clone()
					Util.Debris:AddItem(clone2, v6)
					clone2.Position = endPoint.Position
					clone2.Parent = _WorldOrigin
					local magnitude = (clone.Position - clone2.Position).Magnitude
					local cFrame = CFrame.new(clone.Position, clone2.Position) * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					)
					local clone3 = devilAngel.IceBeam:Clone()
					Util.Debris:AddItem(clone3, v6)
					clone3.CFrame = cFrame
					clone3.Size = Vector3.new(magnitude, 4, 4)
					clone3.Parent = _WorldOrigin
					local v8 = lightningBolt.new(
						clone.Attachment,
						clone2.Attachment,
						math.random(-20, 20),
						math.random(-20, 20),
						math.random(15, 20),
						Color3.fromRGB(85, 170, 255)
					)
					v8.Color = Color3.fromRGB(85, 170, 255)
					v8.AnimationSpeed = 20
					v8.Thickness = 0.6
					v8.CurveSize0 = 0
					v8.CurveSize1 = 0
					v8.PulseSpeed = 45
					v8.Thickness = 3
					v8.MinThicknessMultiplier = 0.2
					v8.MaxThicknessMultiplier = 2
					v8.MaxAngleOffset = 0.3490658503988659
					local clone4 = devilAngel.SolarBeamStart:Clone()
					Util.Debris:AddItem(clone4, v6)
					clone4.Size = createVector(4, 4, 4)
					clone4.CFrame = v4.RootPart.CFrame * CFrame.new(0, 0, -2)
					clone4.Parent = _WorldOrigin
					clone4.Attachment.Sparkle:Emit(2)
					clone4.Attachment.SparkleDark:Emit(2)
					local clone5 = devilAngel.SolarBeamHit:Clone()
					Util.Debris:AddItem(clone5, v6)
					clone5.Position = endPoint.Position
					clone5.Parent = _WorldOrigin
					local magnitude2 = (clone4.Position - clone5.Position).Magnitude
					local cFrame2 = CFrame.new(clone4.Position, clone5.Position) * CFrame.new(0, 0, -magnitude2 / 2) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					)
					local clone6 = devilAngel.SolarBeam:Clone()
					Util.Debris:AddItem(clone6, v6)
					clone6.CFrame = cFrame2
					clone6.Size = Vector3.new(magnitude2, 4, 4)
					clone6.Parent = _WorldOrigin
					local v10 = lightningBolt.new(
						clone4.Attachment,
						clone5.Attachment,
						math.random(-20, 20),
						math.random(-20, 20),
						math.random(15, 20),
						Color3.fromRGB(213, 151, 88)
					)
					v10.Color = Color3.fromRGB(213, 151, 88)
					v10.AnimationSpeed = 20
					v10.Thickness = 0.6
					v10.CurveSize0 = 0
					v10.CurveSize1 = 0
					v10.PulseSpeed = 45
					v10.Thickness = 3
					v10.MinThicknessMultiplier = 0.2
					v10.MaxThicknessMultiplier = 2
					v10.MaxAngleOffset = 0.3490658503988659
					local v11 = Util.Sound:Play("SoulBeams", v3, nil, 1, 1)
					local parent = Util.Sound:Play("SoulBeams", endPoint, nil, 1, 1.4)
					local flangeSoundEffect = Instance.new("FlangeSoundEffect")
					flangeSoundEffect.Depth = 1
					flangeSoundEffect.Rate = 1
					flangeSoundEffect.Parent = parent
					local v13 = Util.Sound:Play("ElectricLoop", endPoint, nil, 1, 1)
					Util.Sound:Play("ElectricBuzz", endPoint, nil, 0.4, 3)
					local now = tick() - 1

					while true do
						local v14 = running() -- equivalent call inferred; original call site unknown

						if v14 and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and v4 and v5 and v3 and endPoint then
							if tick() - now > 0.03 then
								clone5.Attachment.Sparkle:Emit(1)
								clone5.Attachment.SparkleDark:Emit(1)
								clone2.Attachment.Sparkle:Emit(1)
								clone2.Attachment.SparkleDark:Emit(1)
								now = tick()
							end

							clone4.CFrame = v4.RootPart.CFrame * CFrame.new(0, 0, -2)
							clone.CFrame = v5.RootPart.CFrame * CFrame.new(0, 0, -2)
							local position = clone5.Position
							clone5.Position = position + (endPoint.Position - position) * 0.15
							local position2 = clone2.Position
							clone2.Position = position2 + (endPoint.Position - position2) * 0.15
							v4:SetPrimaryPartCFrame(cflerp(
								v4.PrimaryPart.CFrame,
								CFrame.new((v3.CFrame * CFrame.new(10, 2.5, 0)).Position, endPoint.Position),
								0.15
							))
							v5:setPrimaryPartCFrame(cflerp(
								v5.PrimaryPart.CFrame,
								CFrame.new((v3.CFrame * CFrame.new(-10, 2.5, 0)).Position, endPoint.Position),
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
									local v17 = magnitude5 < 40 and 40 or magnitude5
									Util.CameraShaker:ShakeOnce(46 / v17, 15, 0.2, 0.2)
								end
							end

							RunService.RenderStepped:Wait()
						else
							Util.Sound:Play("Charge", clone5.Position, nil, 2, 3)
							local clone7 = devilAngel.ExplosionReady:Clone()
							Util.Debris:AddItem(clone7, 4)
							clone7.Position = clone5.Position
							local spikeWave = clone7.SpikeWave
							local suctionRibbons = clone7.SuctionRibbons
							clone7.Parent = _WorldOrigin
							task.spawn(function()
								for i = 1, 4 do
									spikeWave:Emit(3)
									suctionRibbons:Emit(3)
									task.wait(0.15)
								end
							end)

							if v13 then
								v13:Destroy()
							end

							for _, v17 in pairs({
								clone6,
								clone3,
								clone4,
								clone
							}) do
								if v17 == nil then
									continue
								end

								local tween = TweenService:Create(
									v17,
									TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
									{
										Size = Vector3.new(v17.Shape == Enum.PartType.Ball and 0 or v17.Size.X, 0, 0)
									}
								)
								local v18 = v17
								tween.Completed:Connect(function()
									if v18 then
										v18.Transparency = 1
										disableParticles(v18)
										task.delay(1, function()
											v18:Destroy()
										end)
									end
								end)
								tween:Play()
							end

							for _, v17 in pairs({ v11, parent }) do
								if v17 == nil then
									continue
								end

								local tween = TweenService:Create(
									v17,
									TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
									{
										Volume = 0
									}
								)
								local v18 = v17
								tween.Completed:Connect(function()
									if v18 then
										v18:Destroy()
									end
								end)
								tween:Play()
							end

							if v8 then
								v8:Destroy()
							end

							if v10 then
								v10:Destroy()
							end

							for _, v17 in pairs({
								clone,
								clone2,
								clone4,
								clone5
							}) do
								disableParticles(v17.Attachment)
							end

							info[4] = 0
							v4.AnimationController:LoadAnimation(v4.Action):Play()
							v5.AnimationController:LoadAnimation(v5.Action):Play()
							break
						end
					end
				end
			end)
		end
	end
end