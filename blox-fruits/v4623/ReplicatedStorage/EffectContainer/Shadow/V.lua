local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local v = {
	[0] = createVector(15, 0.4, 15),
	[1] = createVector(27.5, 0.44000003, 27.5),
	[2] = createVector(42, 0.48000002, 42),
	[3] = createVector(121, 0.88000005, 121)
}
local v2 = {
	[0] = 30,
	[1] = 62.5,
	[2] = 120,
	[3] = 270
}

-- equivalent calls inferred from this helper; original call sites unknown
local function viewerIsClose(p, p2, fn)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			fn()
		end
	end
end

local function growShrinkAnimations(p, motor6Ds, p2, p3)
	local steppedConnection = nil
	local v3 = {}
	local v4 = p2 / 4 - 1
	local v5 = {
		Neck = CFrame.new(0, v4, 0),
		Waist = CFrame.new(0, v4, 0),
		LeftShoulder = CFrame.new(-v4, 0, 0) * CFrame.Angles(0, 0, (math.rad(-(100 + v4)))),
		RightShoulder = CFrame.new(v4, 0, 0) * CFrame.Angles(0, 0, (math.rad(100 + v4)))
	}

	if p == "Grow" then
		task.spawn(function()
			steppedConnection = RunService.Stepped:connect(function()
				for _, item in pairs(motor6Ds) do
					if item == nil then
						continue
					end

					v3[item] = cflerp(not v3[item] and item.Transform or v3[item], v5[item.Name], p3)
					item.Transform = v3[item]
				end
			end)
		end)
	elseif p == "Shrink" then
		task.spawn(function()
			steppedConnection = RunService.Stepped:connect(function()
				for _, item in pairs(motor6Ds) do
					if item == nil then
						continue
					end

					v3[item] = cflerp(not v3[item] and v5[item.Name] or v3[item], CFrame.new(0, 0, 0), p3)
					item.Transform = v3[item]
				end
			end)
		end)
	end

	return steppedConnection
end

local function shockWave2(cframe)
	local clone = script.Shockwave2:Clone()
	Util.Debris:AddItem(clone, 4)
	clone.CFrame = cframe * CFrame.new(0, 50, 0)
	clone.Size = createVector(2, 100, 2)
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Size = createVector(150, 1, 150),
			CFrame = clone.CFrame * CFrame.new(0, -50, 0)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end

local function suctionWave(cframe, cFrame, size, size2)
	local clone = script.SuctionWave:Clone()
	Util.Debris:AddItem(clone, 4)
	clone.CFrame = cframe * CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
	clone.Size = size
	clone.Transparency = 0.4
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Size = size2,
			CFrame = cFrame
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end

local function windSaucer(p, size, size2)
	local clone = script.WindSaucer:Clone()
	debris:AddItem(clone, 3)
	clone.CFrame = p * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
	clone.Size = size
	clone.Parent = _WorldOrigin
	clone.Transparency = 1
	local v3 = math.random(100, 120) / 100
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(v3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = size2,
			CFrame = clone.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, 2.251474735072685, 0)
		}
	)
	local tween2 = TweenService:Create(
		clone,
		TweenInfo.new(v3 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Transparency = 0.8
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween2:Play()
	tween:Play()
end

local function blastStar(cFrame)
	local clone = script.ShockwaveParticles:Clone()
	debris:AddItem(clone, 3)
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin

	for _, child in pairs(clone:GetChildren()) do
		if child.Name == "Star" then
			child:Emit(2)
		elseif child.Name == "FogSpray" then
			local v3 = child
			task.spawn(function()
				for i = 1, 5 do
					v3:Emit(10)
					wait(0.25)
				end
			end)
		elseif child.Name == "Wind" then
			local v3 = child
			task.spawn(function()
				for i = 1, 5 do
					v3:Emit(2)
					wait(0.3)
				end
			end)
		else
			child.Enabled = true
			TweenService:Create(child, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
				Range = 0
			}):Play()
		end
	end
end

return function(player)
	local stage = player.Stage

	if stage == 1 then
		local root = player.Root
		local character = player.Character
		local auraStage = player.AuraStage

		if root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
				return
			end

			local v3 = Util.Sound:Play("ShadowGlide", root, nil, 2, 2)
			local tween = TweenService:Create(
				v3,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					PlaybackSpeed = 0.5
				}
			)
			tween.Completed:Connect(function()
				v3:Destroy()
			end)
			tween:Play()
		end

		local upperTorso = character and character:FindFirstChild("UpperTorso")

		if upperTorso then
			local part = Instance.new("Part")
			part.CanCollide = false
			part.CanTouch = false
			part.Color = Color3.fromRGB(0, 0, 0)
			part.Material = Enum.Material.Neon
			part.Size = createVector(0.5, 0.5, 0.5)
			part.Massless = true
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = Enum.MeshType.Sphere
			specialMesh.Offset = createVector(0, 0, 0)
			specialMesh.Parent = part
			part.CFrame = upperTorso.CFrame
			part.Parent = upperTorso
			local motor6D = Instance.new("Motor6D")
			motor6D.Parent = part
			motor6D.Part0 = upperTorso
			motor6D.Part1 = part
			local clone = script.Rays:Clone()
			clone.Parent = part
			clone.Enabled = true
			local clone2 = script.Vortex:Clone()
			clone2.Parent = part
			clone2.Enabled = true
			local clone3 = script.Wind:Clone()
			clone3.Parent = part
			clone3.Enabled = true
			local v3 = {
				[0] = 12,
				[1] = 24,
				[2] = 36,
				[3] = 50
			}
			TweenService:Create(
				specialMesh,
				TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
				{
					Scale = Vector3.new(
						upperTorso.Size.X + v3[auraStage],
						upperTorso.Size.Y + v3[auraStage],
						upperTorso.Size.Z + v3[auraStage]
					)
				}
			):Play()
			local v4 = {
				"Neck",
				"Waist",
				"RightShoulder",
				"LeftShoulder"
			}
			local motor6Ds = {}

			for _, motor6D2 in pairs(character:GetDescendants()) do
				if not (motor6D2:IsA("Motor6D") and table.find(v4, motor6D2.Name)) then
					continue
				end

				table.insert(motor6Ds, motor6D2)
			end

			local holdValue = player.HoldValue
			local humanoid = upperTorso.Parent:FindFirstChild("Humanoid")

			if humanoid then
				local diedConnection = nil

				if humanoid then
					diedConnection = humanoid.Died:Connect(function()
						diedConnection:Disconnect()
					end)
				else
					diedConnection = nil
				end

				local lastTime = tick()

				local function running()
					return tick() - lastTime < 0.5 or diedConnection and player.HoldValue and player.HoldValue.Value == true
				end

				local shadowV = Util.Anims:Get(character, "ShadowV")
				task.spawn(function()
					shadowV:Play()
					shadowV:AdjustSpeed(1)
					wait(0.3)
					shadowV.TimePosition = 0.55
					shadowV:AdjustSpeed(0)
				end)
				local connection = growShrinkAnimations("Grow", motor6Ds, v3[auraStage], 0.15)
				TweenService:Create(humanoid, TweenInfo.new(0.5), {
					CameraOffset = Vector3.new(0, v3[auraStage] / 3, 0)
				}):Play()
				local lastTime2 = tick()

				while (tick() - lastTime < 0.5 or diedConnection and player.HoldValue and player.HoldValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and upperTorso and humanoid do
					if tick() - lastTime2 >= 0.2 and part ~= nil then
						lastTime2 = tick()
					end

					RunService.RenderStepped:Wait()
				end

				TweenService:Create(humanoid, TweenInfo.new(0.5), {
					CameraOffset = createVector(0, 0, 0)
				}):Play()

				if connection then
					connection:Disconnect()
				end

				local connection2 = growShrinkAnimations("Shrink", motor6Ds, v3[auraStage], 0.15)
				task.spawn(function()
					wait(0.5)

					if connection2 then
						connection2:Disconnect()
					end
				end)
				shadowV.TimePosition = 0.8
				shadowV:AdjustSpeed(1)

				if diedConnection then
					diedConnection:Disconnect()
				end

				local tween = TweenService:Create(
					specialMesh,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Scale = createVector(0.5, 0.5, 0.5)
					}
				)
				tween.Completed:Connect(function()
					clone.Enabled = false
					clone2.Enabled = false
					clone3.Enabled = false
					task.spawn(function()
						wait(3)

						if part then
							part:Destroy()
						end
					end)
				end)
				tween:Play()
			end
		end
	elseif stage == 2 then
		local position = player.Position
		local auraStage = player.AuraStage

		if position then
			if (position - workspace.CurrentCamera.CFrame.p).magnitude > 1200 then
				return
			end

			Effect.new("Shadow.Misc"):replicate({
				Type = 3,
				Position = position,
				Size = 45
			})
			math.max(55, player.Scale)
			local fieldLife = player.FieldLife
			local clone = script.Tornado:Clone()
			debris:AddItem(clone, 1)
			clone.Size = Vector3.new()
			clone.CFrame = CFrame.new(player.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
			clone.Parent = _WorldOrigin
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(150, 70, 150),
					CFrame = clone.CFrame * CFrame.Angles(0, 3.12413936106985, 0),
					Transparency = 1
				}
			)
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
			task.spawn(function()
				local function fn()
					Util.CameraShaker:ShakeOnce(10, 12, 0.25, 2)
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					colorCorrectionEffect.Parent = game.Lighting
					local tween2 = TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.2), {
						Brightness = 0.25,
						Contrast = 0.25,
						Saturation = 0.25,
						TintColor = Color3.fromRGB(80, 0, 255)
					})
					tween2.Completed:Connect(function()
						task.wait(0.3)
						local tween3 = TweenService:Create(colorCorrectionEffect, TweenInfo.new(1.6), {
							Brightness = 0,
							Contrast = 0,
							Saturation = 0,
							TintColor = Color3.new(1, 1, 1)
						})
						tween3.Completed:Connect(function()
							colorCorrectionEffect:Destroy()
						end)
						tween3:Play()
					end)
					tween2:Play()
				end

				viewerIsClose(position, 120, fn) -- equivalent call inferred; original call site unknown
				local v4 = v2[auraStage]

				for _ = 0, 3 do
					local clone2 = script.WindSaucer:Clone()
					debris:AddItem(clone2, 3)
					clone2.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
					clone2.Size = createVector(1, 1, 1)
					clone2.Parent = _WorldOrigin
					local tween2 = TweenService:Create(
						clone2,
						TweenInfo.new(
							math.random(90, 120) / 100,
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out,
							0,
							false,
							0
						),
						{
							Size = Vector3.new(120 + v4 / 2, 25 + v4 / 2, 120 + v4 / 2),
							Transparency = 1,
							CFrame = clone2.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, 3.12413936106985, 0)
						}
					)
					tween2.Completed:Connect(function()
						clone2:Destroy()
					end)
					tween2:Play()
					wait(0.2)
				end

				for _ = 0, 15 do
					local vector2 = Vector3.new(120 + v4 / 2, 25 + v4 / 2, 120 + v4 / 2)
					local v5 = math.random(-20, 20)
					windSaucer(
						CFrame.new(position) * CFrame.Angles(
							math.rad((math.random(-15, 15))),
							math.rad((math.random(-15, 15))),
							(math.rad((math.random(-15, 15))))
						),
						Vector3.new(120 + v4 / 2, 25 + v4 / 2, 120 + v4 / 2),
						vector2 + Vector3.new(v5, math.random(-5, 5), v5)
					)
					wait(0.5)
				end
			end)
			local clone2 = script.ShadowVBurst:Clone()
			debris:AddItem(clone2, fieldLife + 8)
			clone2.Position = position
			clone2.Parent = _WorldOrigin
			local ray, v3 = Util.Ray(
				position,
				CFrame.new(position, position - createVector(0, 1, 0)).LookVector * 10,
				{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
			)
			local clone3 = script.EerieFogPlane:Clone()
			debris:AddItem(clone3, fieldLife + 9)
			clone3.Size = v[auraStage]
			local position2

			if ray then
				position2 = v3 or position
			else
				position2 = position
			end

			clone3.Position = position2
			clone3.Parent = _WorldOrigin

			if not ray then
				clone3.GroundSmog:Destroy()
			end

			if auraStage == 3 then
				Util.Sound:Play("ShadowGlide", position, nil, 2 - auraStage / 4, 3)
			end

			local v5 = v2[auraStage]
			shockWave2(CFrame.new(position))
			blastStar(CFrame.new(position))
			suctionWave(
				CFrame.new(position),
				CFrame.new(position) + createVector(0, 50, 0),
				Vector3.new(v5 + 150, 3, v5 + 150),
				createVector(5, 100, 5)
			)
			Util.Sound:Play("GenericExplosion3", position, nil, 0.9 + math.random(-10, 10) / 100, 0.25)
			Util.Sound:Play("ShortExplosion3_2", position)
			Util.Sound:Play("NewDarkness2", position)
			Util.Sound:Play("NewDarkness3", position)
			local v6 = Util.Sound:Play("CrowShot", position, nil, 2 - auraStage / 4, 8)
			local tween2 = TweenService:Create(
				v6,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					PlaybackSpeed = 0.2
				}
			)
			tween2.Completed:Connect(function()
				v6:Destroy()
			end)
			tween2:Play()

			if ray then
				local groundSmog = clone3.GroundSmog
				local tween3 = TweenService:Create(
					groundSmog,
					TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						TimeScale = 0.2
					}
				)
				groundSmog.TimeScale = 1
				groundSmog.Enabled = true
				tween3:Play()
			end

			local smoke = clone3.Smoke
			smoke.Rate = 50 + v2[auraStage] * 0.75
			local tween3 = TweenService:Create(
				smoke,
				TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					TimeScale = 0.25
				}
			)
			smoke.TimeScale = 1
			smoke.Enabled = true
			tween3:Play()

			for _, child in pairs(clone2:GetChildren()) do
				if string.find(child.Name, "Linger") then
					continue
				end

				if child.Name == "Wind" then
					child:Emit(3)
				else
					child:Emit(25)
				end
			end

			clone2.Smoke1.Rate = 50 + v2[auraStage] * 0.75
			clone2.Smoke2.Rate = 50 + v2[auraStage] * 0.75
			clone2.Smoke3.Rate = 50 + v2[auraStage] * 0.75
			clone2.Linger_Smoke.Rate = 50 + v2[auraStage] * 0.75
			local linger_GlowDust = clone2.Linger_GlowDust
			linger_GlowDust.Speed = NumberRange.new(40, 100 + v2[auraStage] * 1.5)
			linger_GlowDust.Rate = v2[auraStage] * 0.5
			linger_GlowDust.Enabled = true
			wait(fieldLife)
			linger_GlowDust.Enabled = false

			if ray then
				clone3.GroundSmog.Enabled = false
			end

			clone3.Smoke.Enabled = false
		end
	elseif stage == 3 then
		local life = player.Life
		local clone = script.ShadowOverlay:Clone()
		debris:AddItem(clone, life + 5)
		local overlay = clone.Overlay
		overlay.ImageTransparency = 1
		clone.Parent = game.Players.LocalPlayer.PlayerGui
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		debris:AddItem(colorCorrectionEffect, life + 3)
		colorCorrectionEffect.Name = "ShadowVColorCorrection"
		colorCorrectionEffect.Parent = game:GetService("Lighting")
		local tween = TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
			{
				Saturation = -0.6
			}
		)
		local tween2 = TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Saturation = 0
			}
		)
		tween2.Completed:Connect(function()
			colorCorrectionEffect:Destroy()
		end)
		local tween3 = TweenService:Create(
			overlay,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				ImageTransparency = 0
			}
		)
		local tween4 = TweenService:Create(
			overlay,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
			{
				ImageTransparency = 1
			}
		)
		tween4.Completed:Connect(function()
			clone:Destroy()
		end)
		tween3:Play()
		tween:Play()
		wait(life)
		tween4:Play()
		tween2:Play()
	end
end