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
	for _ = 1, _G.FastMode and 2 or math.random(2, 3) do
		local v = math.random(30, 50) / 10
		local part = Instance.new("Part")
		part.Material = data.Material
		part.Transparency = data.Transparency
		part.Reflectance = data.Reflectance
		part.Color = data.Color
		part.Size = Vector3.new(v, v, v)
		part.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
			math.rad((math.random(-23, 23))),
			math.rad((math.random(-23, 23))),
			(math.rad((math.random(-23, 23))))
		)
		part.CanCollide = false
		part.Parent = _WorldOrigin
		part.Velocity = part.CFrame.lookVector.Unit * Vector3.new(
			math.random(-156, 199),
			math.random(90, 140),
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
FX:WaitForChild("Mammoth")

local function attack(plr, hrp, hold, mammoth, slicedis, ref)
	local children = mammoth:GetChildren()

	local function lightup()
		for _, part in pairs(children) do
			if not (part:IsA("MeshPart") and (part.Name == "Plane.010" or part.Name:find("Crystal") or part.Name:find("ArmorBlue"))) then
				continue
			end

			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					Color = Color3.fromRGB(255, 255, 255)
				}
			)
			tween:Play()
			local v2 = part
			task.spawn(function()
				task.wait(0.05)

				if tween.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				local tween2 = TweenService:Create(
					v2,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Color = Color3.fromRGB(255, 57, 57)
					}
				)
				tween2:Play()
				task.wait(0.1)

				if tween2.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				TweenService:Create(v2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Color = Color3.fromRGB(112, 22, 22)
				}):Play()
			end)
		end
	end

	local function lightoff()
		for _, part in pairs(children) do
			if not (part:IsA("MeshPart") and (part.Name == "Plane.010" or part.Name:find("Crystal") or part.Name:find("ArmorBlue"))) then
				continue
			end

			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Color = Color3.fromRGB(13, 105, 172)
			}):Play()
		end
	end

	lightup()

	while hold and hold.Value and hold.Parent and hold.Parent:IsDescendantOf(workspace) do
		wait()
	end

	local v = false

	if hold and hold.Parent then
		for _ = 1, 100 do
			wait()

			if not ref:GetAttribute("MammothZStart") then
				continue
			end

			v = true
			break
		end
	end

	if not v then
		lightoff()
		return
	end

	Util.Sound:Play("MammothSpawn", hrp.Position, nil, 1 + math.random(-5, 5) / 100, 4)
	Util.Sound:Play("port2", hrp.Position, nil, 1 + math.random(-5, 5) / 100, 4)
	local cframe = CFrame.new(ref:GetAttribute("MammothZStart"), ref:GetAttribute("MammothZEnd"))
	local lookVector = cframe.LookVector
	local v2 = cframe.Position + lookVector * 0
	local rayMap, v3, _ = Util.RayMap(v2, createVector(0, -45, 0))

	local function slices(p, p2)
		local clone = FX:WaitForChild("Mammoth").Slice.slices2:Clone()
		local primaryPart = clone.PrimaryPart
		primaryPart.Size = createVector(20.693, 0.461, 45.591)
		primaryPart.CFrame = cframe * CFrame.new(0, -7, 0) * CFrame.Angles(
			1.5707963267948966,
			math.rad(p),
			(math.rad(p2 + 30))
		)
		TweenService:Create(primaryPart, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()
		TweenService:Create(primaryPart, TweenInfo.new(0.45, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
			CFrame = primaryPart.CFrame * CFrame.new(-slicedis, 0, 0),
			Size = createVector(40.857, 0.91, 90.018)
		}):Play()
		task.spawn(function()
			task.wait(0.555)
			TweenService:Create(
				primaryPart,
				TweenInfo.new(0.01, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{
					Transparency = 1
				}
			):Play()
		end)
		clone.Parent = _WorldOrigin
		mammoth["body4.002"].RedBack.black2:Emit(5)

		if rayMap then
			local clone2 = FX:WaitForChild("Mammoth").Slice.slices2GROUND:Clone()
			local primaryPart2 = clone2.PrimaryPart
			local lookVector2 = cframe.LookVector
			local v4 = v3 + lookVector2 * 0 + createVector(0, 5.2, 0)
			local cframe2 = CFrame.new(Vector3.new(), lookVector2)
			primaryPart2.CFrame = CFrame.new(v4) * cframe2 * CFrame.Angles(
				1.5707963267948966,
				math.rad(p),
				(math.rad(p2 + 30))
			)
			TweenService:Create(
				primaryPart2,
				TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{
					Transparency = 1
				}
			):Play()
			TweenService:Create(primaryPart2, TweenInfo.new(0.65, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
				Size = createVector(34.094, 0.759, 75.118),
				CFrame = primaryPart2.CFrame * CFrame.new(-slicedis, 0, 0)
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
			clone2.Parent = _WorldOrigin
			Util.Debris:AddItem(clone2, 2)

			if not _G.FastMode then
				task.spawn(function()
					task.wait(0.07)
					local lastTime = tick()

					while tick() - lastTime < 0.284 do
						task.wait(0.016666666666666666)

						for _ = 1, 2 do
							local raycastResult = workspace:Raycast(
								Vector3.new(
									primaryPart.Attachment2.WorldPosition.X,
									primaryPart.Position.Y + 7.5,
									primaryPart.Attachment2.WorldPosition.Z
								),
								createVector(0, -49.5, 0),
								raycastParams
							)

							if not raycastResult then
								continue
							end

							local clone3 = FX:WaitForChild("Mammoth").Slice.RockSplint:Clone()
							clone3.CFrame = CFrame.new(raycastResult.Position) * CFrame.new(
								math.random(-30, 30) / 10,
								-5,
								math.random(-70, 70) / 10
							)
							clone3.Size = Vector3.new(
								math.random(110, 138) / 10,
								math.random(14, 20) / 10,
								math.random(110, 132) / 10
							)
							clone3.Parent = _WorldOrigin
							clone3.Material = raycastResult.Material
							clone3.Color = raycastResult.Instance.Color
							TweenService:Create(clone3, TweenInfo.new(0.2), {
								CFrame = clone3.CFrame * CFrame.new(0, math.random(45, 45) / 10, 0) * CFrame.Angles(
									math.rad((math.random(-10, 10))),
									math.rad((math.random(-360, 360))),
									(math.rad((math.random(-10, 10))))
								)
							}):Play()
							task.delay(1.5, function()
								local tween = TweenService:Create(clone3, TweenInfo.new(0.5), {
									Position = clone3.Position - createVector(0, 7, 0)
								})
								tween.Completed:Connect(function()
									clone3:Destroy()
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
					local v5 = primaryPart.Position + createVector(0, 7.5, 0)
					local rayMap2, v6, v7 = Util.RayMap(v5, createVector(0, -49.5, 0))

					if rayMap2 then
						debrisPart(rayMap2, v6, v7)
					end
				end
			end)
		end

		for _, child in pairs(primaryPart.emit:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		task.spawn(function()
			task.spawn(function()
				task.wait(0.08)

				for _ = 1, 4 do
					task.wait(0.04)
					primaryPart.slash.Effect:Emit(2)
				end
			end)
			task.wait(0.25)
			Util.Sound:Play("MammothImpactSlice", clone.exp.Position, 25, 1 + math.random(-5, 5) / 60, 0.15)
			primaryPart.ParticleEmitter2.Enabled = true
			primaryPart.ParticleEmitter3.Enabled = true

			for _, child in pairs(clone.exp.SparksOut:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			for _, emitter in pairs(clone.exp:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			primaryPart.sparks.Particle.Enabled = false
			clone.exp.Attachment.flash:Emit(8)
			Util.Debris:AddItem(clone, 2)
		end)
		task.delay(0.65, function()
			primaryPart.ParticleEmitter2.Enabled = false
			primaryPart.ParticleEmitter3.Enabled = false
		end)
	end

	if plr == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(3, 7, 0.1, 0.3, createVector(1, 1, 1), createVector(1.4, 2, 1.4))
	end

	Util.Sound:Play("MammothSlicePowerful", hrp.Position, 25, 0.8 + math.random(-10, -5) / 80, 0.6)
	slices(0, 45)
	slices(0, 60)
	slices(0, 75)

	if plr == game.Players.LocalPlayer then
		task.spawn(function()
			TweenService:Create(workspace.Camera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FieldOfView = 75
			}):Play()
			wait(0.052)
			TweenService:Create(workspace.Camera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				FieldOfView = 70
			}):Play()
		end)
	end

	wait(0.35)
	Util.Sound:Play("MammothSlicePowerful", hrp.Position, 25, 0.8 + math.random(-10, -5) / 80, 0.6)

	if plr == game.Players.LocalPlayer then
		task.spawn(function()
			wait(0.05)
			TweenService:Create(workspace.Camera, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FieldOfView = 80
			}):Play()
			wait(0.1)
			TweenService:Create(workspace.Camera, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				FieldOfView = 70
			}):Play()
		end)
		task.spawn(function()
			wait(0.12)
			Util.CameraShaker:ShakeOnce(4, 8, 0.1, 0.25, createVector(1, 1, 1), createVector(2, 2, 2))
			local clone = script.LTN:Clone()
			clone.Parent = game.Lighting
			Util.Debris:AddItem(clone, 2)
			TweenService:Create(clone, TweenInfo.new(0.01), {
				TintColor = Color3.fromRGB(225, 9, 9),
				Brightness = 0.3,
				Contrast = 1,
				Saturation = -2
			}):Play()
			wait(0.01)
			TweenService:Create(clone, TweenInfo.new(0.01), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = 0.8,
				Contrast = 1,
				Saturation = 1
			}):Play()
			wait(0.01)
			TweenService:Create(clone, TweenInfo.new(0.005), {
				TintColor = Color3.fromRGB(111, 7, 7),
				Brightness = 0.3,
				Contrast = 1,
				Saturation = -2
			}):Play()
			wait(0.005)
			TweenService:Create(clone, TweenInfo.new(0.037), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			}):Play()
			wait(0.07)
			Util.CameraShaker:ShakeOnce(4, 8, 0.1, 0.25, createVector(1, 1, 1), createVector(2, 2, 2))
		end)
	end

	Util.Sound:Play("MammothSpawn", hrp.Position, nil, 1 + math.random(-5, 5) / 100, 3)
	slices(0, 25)
	slices(0, 60)
	slices(0, 95)
	task.wait(0.35)
	lightoff()
end

return function(data)
	local plr = data.plr
	local hrp = data.hrp
	local hold = data.hold
	local slicedis = data.slicedis
	local ref = data.ref

	if not hrp or (hrp.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	local mammoth = hrp.Parent:FindFirstChild("Mammoth").Mammoth

	if not mammoth then
		return
	end

	attack(plr, hrp, hold, mammoth, slicedis, ref)
end