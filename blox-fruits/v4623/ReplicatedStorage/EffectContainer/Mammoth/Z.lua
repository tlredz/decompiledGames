local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function debrisPart(data, p, p2)
	for _ = 1, _G.FastMode and 1 or math.random(1, 2) do
		local v = math.random(20, 40) / 10
		local part = Instance.new("Part")
		part.Material = data.Material
		part.Transparency = data.Transparency
		part.Reflectance = data.Reflectance
		part.Color = data.Color
		part.Size = Vector3.new(v, v, v)
		part.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
			math.rad((math.random(-13, 13))),
			math.rad((math.random(-13, 13))),
			(math.rad((math.random(-13, 13))))
		)
		part.CanCollide = false
		part.Parent = _WorldOrigin
		part.Velocity = part.CFrame.lookVector.Unit * Vector3.new(
			math.random(-156, 199),
			math.random(90, 130),
			math.random(-195, 195)
		)
		part.RotVelocity = Vector3.new(math.random(-7, 7), math.random(-7, 7), math.random(-7, 7))
		local tween = TweenService:Create(part, TweenInfo.new(3.9), {
			Size = createVector(0, 0, 0)
		})
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
		return part
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local mammoth = FX:WaitForChild("Mammoth")

local function attack(plr, hrp, hold, MAMMOTH_Z)
	local accessory = Instance.new("Accessory")
	accessory.Name = "MammothAccessory"
	accessory.Parent = plr.Character
	local clone = mammoth.MammothSilhouette:Clone()

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		for _, part in pairs(clone:GetChildren()) do
			if part:IsA("MeshPart") then
				TweenService:Create(part, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play()
			end
		end
	end

	local primaryPart = clone.PrimaryPart
	local body = clone.body
	local _ = clone.AnimationController
	primaryPart.CFrame = hrp.CFrame
	clone.Parent = accessory
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = primaryPart
	motor6D.Part1 = hrp
	motor6D.C0 = motor6D.Part1.CFrame:inverse()
	motor6D.C1 = motor6D.Part1.CFrame:inverse() * CFrame.new(0, -8, 0)
	motor6D.Name = "RigWeld"
	motor6D.Parent = primaryPart
	local clone2 = mammoth.Ground:Clone()
	clone2.CFrame = primaryPart.CFrame * CFrame.new(0, -7, 0)
	clone2.Parent = _WorldOrigin
	task.spawn(function()
		local clone3 = mammoth.FormEmit:Clone()
		clone3.CFrame = hrp.CFrame * CFrame.new(0, -1.5, 0)
		clone3.Parent = _WorldOrigin
		Util.Debris:AddItem(clone3, 3)
		task.spawn(function()
			local descendants = clone3:GetDescendants()
			local v = {}

			for k, emitter in pairs(descendants) do
				if emitter:IsA("ParticleEmitter") then
					v[k] = {
						count = emitter:GetAttribute("EmitCount") or 0,
						delay = emitter:GetAttribute("EmitDelay") or 0
					}
				end
			end

			for k, descendant in pairs(descendants) do
				if not v[k] then
					continue
				end

				if v[k].delay > 0 then
					local v2 = k
					local v3 = descendant
					task.spawn(function()
						task.wait(v[v2].delay)
						v3:Emit(v[v2].count)
					end)
				else
					descendant:Emit(v[k].count)
				end
			end
		end)
	end)

	for _, part in pairs(clone:GetChildren()) do
		if part:IsA("MeshPart") and part.Name ~= "eye" then
			TweenService:Create(
				part,
				TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false, 0),
				{
					Transparency = 0
				}
			):Play()
		end
	end

	local thread = task.delay(0.2, function()
		clone.eyeL.EyeL.Eye.Enabled = true
		clone.eyeL.EyeL.EYEGLOW:Emit(3)
		clone.eyeR.EyeR.Eye.Enabled = true
		clone.eyeR.EyeR.EYEGLOW:Emit(3)
	end)

	while hold and hold.Value and hold.Parent and hold.Parent:IsDescendantOf(workspace) do
		wait()
	end

	local v = MAMMOTH_Z == false
	local flag = false

	if hold and hold.Parent then
		for _ = 1, 100 do
			task.wait(0.03333333333333333)

			if v then
				MAMMOTH_Z = plr.Character:FindFirstChild("MAMMOTH_Z")
			end

			if not (MAMMOTH_Z and MAMMOTH_Z:GetAttribute("MammothZStart")) then
				continue
			end

			flag = true
			break
		end
	end

	Util.Debris:AddItem(clone2, 3.5)
	Util.Debris:AddItem(accessory, 2.5)

	if MAMMOTH_Z then
		MAMMOTH_Z.Name = "DESTROYING"
	end

	if flag then
		Util.Sound:Play("MammothSpawn", hrp.Position, nil, 1 + math.random(-5, 5) / 100, 2.5)
		local cframe = CFrame.new(MAMMOTH_Z:GetAttribute("MammothZStart"), MAMMOTH_Z:GetAttribute("MammothZEnd"))
		local sliceDistance = MAMMOTH_Z:GetAttribute("SliceDistance")
		local lookVector = cframe.LookVector
		local v2 = cframe.Position + lookVector * 0
		local rayMap, v3, _ = Util.RayMap(v2, createVector(0, -40, 0))
		local descendants = clone2:GetDescendants()

		local function slices(p, p2)
			local clone3 = FX:WaitForChild("Mammoth").Slice.slices:Clone()
			local primaryPart2 = clone3.PrimaryPart
			primaryPart2.CFrame = cframe * CFrame.new(0, -7, 0) * CFrame.Angles(
				1.5707963267948966,
				math.rad(p),
				(math.rad(p2 + 30))
			)
			Util.Sound:Play("port2", hrp.Position, nil, 1 + math.random(-5, 5) / 100, 1.75)
			TweenService:Create(
				primaryPart2,
				TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{
					Transparency = 1
				}
			):Play()
			TweenService:Create(primaryPart2, TweenInfo.new(0.65, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
				Size = createVector(34.094, 0.759, 75.118)
			}):Play()
			TweenService:Create(primaryPart2, TweenInfo.new(0.65, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
				CFrame = primaryPart2.CFrame * CFrame.new(-sliceDistance, 0, 0)
			}):Play()
			task.spawn(function()
				task.wait(0.555)
				TweenService:Create(
					primaryPart2,
					TweenInfo.new(0.01, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						Transparency = 1
					}
				):Play()
			end)
			clone3.Parent = _WorldOrigin
			Util.Sound:Play("MammothSlice", primaryPart2.Position, nil, 0.8 + math.random(-5, 5) / 100, 0.75)
			body.RedBack.black2:Emit(3)

			if rayMap then
				local clone4 = FX:WaitForChild("Mammoth").Slice.slices1GROUND:Clone()
				local primaryPart3 = clone4.PrimaryPart
				local lookVector2 = cframe.LookVector
				local v4 = v3 + lookVector2 * 0 + createVector(0, 2.8, 0)
				local cframe2 = CFrame.new(Vector3.new(), lookVector2)
				primaryPart3.CFrame = CFrame.new(v4) * cframe2 * CFrame.Angles(
					1.5707963267948966,
					math.rad(p),
					(math.rad(p2 + 30))
				)
				Util.Debris:AddItem(clone4, 2)
				TweenService:Create(
					primaryPart3,
					TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						Transparency = 1
					}
				):Play()
				TweenService:Create(
					primaryPart3,
					TweenInfo.new(0.65, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
					{
						Size = createVector(34.094, 0.759, 75.118)
					}
				):Play()
				TweenService:Create(
					primaryPart3,
					TweenInfo.new(0.65, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
					{
						CFrame = primaryPart3.CFrame * CFrame.new(-sliceDistance, 0, 0)
					}
				):Play()
				task.spawn(function()
					task.wait(0.555)
					TweenService:Create(
						primaryPart3,
						TweenInfo.new(0.01, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Transparency = 1
						}
					):Play()
				end)
				clone4.Parent = _WorldOrigin
				Util.Debris:AddItem(primaryPart3, 2)

				for _, emitter in pairs(descendants) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				if not _G.FastMode then
					task.spawn(function()
						task.wait(0.15)
						local lastTime = tick()

						while tick() - lastTime < 0.47 do
							task.wait(0.016666666666666666)

							for _ = 1, 2 do
								local raycastResult = workspace:Raycast(
									Vector3.new(
										primaryPart2.Attachment2.WorldPosition.X,
										primaryPart2.Position.Y + 7.5,
										primaryPart2.Attachment2.WorldPosition.Z
									),
									createVector(0, -37.5, 0),
									raycastParams
								)

								if not raycastResult then
									continue
								end

								local clone5 = FX:WaitForChild("Mammoth").Slice.RockSplint:Clone()
								clone5.CFrame = CFrame.new(raycastResult.Position) * CFrame.new(
									math.random(-30, 30) / 10,
									-5,
									math.random(-70, 70) / 10
								)
								clone5.Size = Vector3.new(
									math.random(88, 118) / 10,
									math.random(10, 16) / 10,
									math.random(92, 132) / 10
								)
								clone5.Parent = _WorldOrigin
								clone5.Material = raycastResult.Material
								clone5.Color = raycastResult.Instance.Color
								TweenService:Create(clone5, TweenInfo.new(0.2), {
									CFrame = clone5.CFrame * CFrame.new(0, math.random(45, 45) / 10, 0) * CFrame.Angles(
										math.rad((math.random(-10, 10))),
										math.rad((math.random(-360, 360))),
										(math.rad((math.random(-10, 10))))
									)
								}):Play()
								task.delay(1, function()
									local tween = TweenService:Create(clone5, TweenInfo.new(0.5), {
										Position = clone5.Position - createVector(0, 7, 0)
									})
									tween.Completed:Connect(function()
										clone5:Destroy()
									end)
									tween:Play()
								end)
							end
						end
					end)
				end

				task.spawn(function()
					task.wait(0.07)
					local lastTime = tick()

					while tick() - lastTime < 0.26666666666666666 do
						task.wait(0.016666666666666666)
						local v5 = primaryPart2.Position + createVector(0, 7.5, 0)
						local rayMap2, v6, v7 = Util.RayMap(v5, createVector(0, -37.5, 0))

						if rayMap2 then
							debrisPart(rayMap2, v6, v7)
						end
					end
				end)
			end

			if plr == game.Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(2, 9, 0.1, 0.3, createVector(3, 3, 3), createVector(3, 3, 5))
			end

			for _, child in pairs(primaryPart2.emit:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			task.spawn(function()
				task.spawn(function()
					task.wait(0.08)

					for _ = 1, 4 do
						task.wait(0.04)
						primaryPart2.slash.Effect:Emit(2)
					end
				end)
				task.wait(0.27)
				Util.Sound:Play("MammothSliceOpen", clone3.exp.Position, nil, 1 + math.random(-5, 5) / 100, 0.15)
				task.wait(0.06)

				for _, emitter in pairs(clone3.exp:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				primaryPart2.sparks.Particle.Enabled = false
				clone3.exp.Attachment.flash:Emit(8)
				Util.Debris:AddItem(clone3, 2)
			end)
		end

		local mammothZUntrans = Util.Anims:Get(clone, "MammothZUntrans")
		mammothZUntrans:Play(nil, nil, 0.6)
		slices(0, 45)
		slices(0, 60)
		slices(0, 75)
		task.wait(0.3)
		mammothZUntrans:AdjustSpeed(0.3)
		primaryPart.Anchored = true
		motor6D:Destroy()
		task.wait(0.2)
		body.SiloTrailPerm.smoke.Enabled = false
		clone.eyeR.EyeR.Eye.Enabled = false
		clone.eyeL.EyeL.Eye.Enabled = false
		Util.Sound:Play("MammothUntransform", hrp, nil, 1 + math.random(-5, 5) / 100, 2)
		local children = body.Disperse:GetChildren()

		for _, emitter in pairs(children) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		return deduplicatedTail()
	else
		task.cancel(thread)
		primaryPart.Anchored = true
		motor6D:Destroy()
		body.SiloTrailPerm.smoke.Enabled = false
		clone.eyeR.EyeR.Eye.Enabled = false
		clone.eyeL.EyeL.Eye.Enabled = false
		return deduplicatedTail()
	end
end

return function(data)
	local plr = data.plr
	local hrp = data.hrp
	local hold = data.hold
	local ref = data.ref

	if (hrp.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	attack(plr, hrp, hold, ref)
end