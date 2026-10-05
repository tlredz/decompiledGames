local createVector = vector.create
local _WorldOrigin = workspace._WorldOrigin
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.Spring
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local random = Random.new()
local beziers = Util.Beziers
local v = {
	["Right Arm"] = {
		{ "RightUpperArm", "MagmaUpperArm" },
		{ "RightLowerArm", "MagmaLowerArm" },
		{ "RightHand", "MagmaHand" }
	},
	["Left Arm"] = {
		{ "LeftUpperArm", "MagmaUpperArm" },
		{ "LeftLowerArm", "MagmaLowerArm" },
		{ "LeftHand", "MagmaHand" }
	},
	["Lance Arm"] = {
		{ "RightUpperArm", "MagmaUpperArm" },
		{ "RightLowerArm", "MagmaLanceArm" },
		{ "RightHand", "MagmaLanceHand" }
	},
	["Ultimate Arm"] = {
		{ "RightUpperArm", "MagmaUltUpperArm" },
		{ "RightLowerArm", "MagmaUltLowerArm" },
		{ "RightHand", "MagmaUltHand" }
	}
}
local _ = { CFrame.Angles(0, 0, 0.01), CFrame.Angles(0, 0, -0.007), CFrame.Angles(0, 0, 0.003) }
local _ = {
	CFrame.Angles(3.13, 0.5, 3.13),
	CFrame.Angles(-3.13, 1, 0),
	CFrame.Angles(-2, -2, -3),
	CFrame.Angles(0.13, -2, 3)
}
local tweenInfo = TweenInfo.new(0.9, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(math.random(50, 100) / 100, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
local v2 = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("ActiveSparks_Magma3", 1000, function(p)
	for k, v3 in pairs(v2) do
		local spark_p = v3.spark_p
		local life_time = v3.life_time
		local properties = v3.properties
		local time_started = v3.time_started
		local timer = v3.timer

		if tick() - time_started < life_time then
			local _ = (tick() - time_started) / life_time
			spark_p.CFrame = spark_p.CFrame * CFrame.new(0, 0, -properties.speed) * CFrame.Angles(
				math.rad(properties.angle_x * math.cos(timer / 5 + math.random(-360, 360) / 100)),
				math.rad(properties.angle_y * math.cos(timer / 5 + math.random(-360, 360) / 100)),
				(math.rad(properties.angle_z * math.cos(timer / 5 + math.random(-360, 360) / 100)))
			)
			v3.timer += p * 60
		else
			if spark_p then
				spark_p:Destroy()
			end

			v2[k] = nil
		end
	end
end)

local function spark_effect(properties)
	local life_time = properties.life_time or 2.5
	local part = Instance.new("Part")
	part.CFrame = properties.cframe * CFrame.Angles(
		math.rad((math.random(360))),
		math.rad((math.random(360))),
		(math.rad((math.random(360))))
	)
	part.Size = createVector(2, 2, 7.5) * properties.scale
	part.Color = properties.color
	part.Material = properties.material
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CastShadow = false
	part.Massless = true
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Parent = part
	part.Parent = _WorldOrigin
	table.insert(v2, {
		spark_p = part,
		life_time = life_time,
		properties = properties,
		time_started = tick(),
		timer = 1
	})
	local tween = TweenService:Create(
		specialMesh,
		TweenInfo.new(life_time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			Scale = createVector(0, 0, 0)
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		if part then
			part:Destroy()
		end
	end)
end

function getBodyFolder(p, p2)
	local v3 = workspace._WorldOrigin:FindFirstChild("MagmaBody_" .. p2 .. p.Name)

	if not v3 then
		v3 = Instance.new("Folder")
		v3.Name = "MagmaBody_" .. p2 .. p.Name
		v3.Parent = workspace._WorldOrigin
	end

	return v3
end

local function debrisPart(data, p, p2)
	local v3 = math.random(40, 100) / 10
	local part = Instance.new("Part")
	part.Material = data.Material
	part.Transparency = data.Transparency
	part.Reflectance = data.Reflectance
	part.Color = data.Color
	part.Size = Vector3.new(v3, v3, v3)
	part.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	part.CanCollide = false
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	part.Parent = _WorldOrigin
	part.Velocity = part.CFrame.lookVector.Unit * math.random(100, 150)
	part.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	local tween = TweenService:Create(
		part,
		TweenInfo.new(math.random(10, 15) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
		{
			Size = createVector(0.1, 0.1, 0.1)
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	return part
end

local function distanceCK(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function ScaleParticle(clone, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, clone.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	return
		NumberSequence.new(numberSequenceKeypoints),
		NumberRange.new(clone.Speed.Min * p, clone.Speed.Max * p),
		clone.Acceleration * p
end

return function(player)
	local effect = player.Effect

	if effect == "Body" then
		local bodyType = player.BodyType
		local fadeIn = player.FadeIn
		local orderDelay = player.OrderDelay
		local character = player.Character
		local bodyFolder = getBodyFolder(character, player.Id)

		for _, v3 in pairs(v[bodyType]) do
			local v4 = v3[1]
			local v5 = v3[2]
			local part2 = character[v4]
			local clone = FX:WaitForChild("MagmaEffects").Limbs[v5]:Clone()
			local cFrame = part2.CFrame

			if not clone.ForceAligned.Value then
				cFrame *= CFrame.Angles(random:NextNumber(-3, 3), 0, random:NextNumber(-3, 3))
			end

			clone:SetPrimaryPartCFrame(cFrame)
			clone.root.limbweld.Part1 = part2
			clone.root.limbweld.Enabled = true
			clone.Parent = bodyFolder

			for _, part in pairs(clone:GetChildren()) do
				if not (part:IsA("BasePart") and part.Name ~= "root") then
					continue
				end

				local size = part.Size * clone.Scale.Value
				part.Size = createVector(0, 0, 0)
				TweenService:Create(part, TweenInfo.new(fadeIn, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Size = size
				}):Play()
			end

			wait(orderDelay)
		end
	elseif effect == "ClearBody" then
		local character = player.Character
		local folder = workspace._WorldOrigin:FindFirstChild("MagmaBody_" .. player.Id .. character.Name)

		if folder then
			for _, part in pairs(folder:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "root" then
					TweenService:Create(part, tweenInfo2, {
						Size = createVector(0.05, 0.05, 0.05)
					}):Play()
				end
			end

			Util.Debris:AddItem(folder, 1)
		end
	elseif effect == "MagmaPuddle" then
		local cframe_to_send = player.cframe_to_send

		if (cframe_to_send.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 1200 then
			return
		end

		local scale_by_to_send = player.scale_by_to_send
		local lifetime_to_send = player.lifetime_to_send
		local _ = player.enemy_hit_to_send
		local _ = player.raycast_hit_to_send
		local raycast_pos_to_send = player.raycast_pos_to_send
		local raycast_norms_to_send = player.raycast_norms_to_send
		local clone = FX:WaitForChild("MagmaEffects").OptimizedBall:Clone()
		clone.CFrame = cframe_to_send * CFrame.Angles(1.5707963267948966, math.rad(math.random(-3600, 3600) / 100), 0)
		local size = clone.Size * Vector3.new(scale_by_to_send, scale_by_to_send, 5)
		TweenService:Create(clone, tweenInfo, {
			CFrame = clone.CFrame * CFrame.Angles(0, 0, math.random(-50, 50) / 10),
			Size = size
		}):Play()
		clone.Parent = _WorldOrigin
		coroutine.resume(coroutine.create(function()
			wait(lifetime_to_send)
			local tween = TweenService:Create(clone, tweenInfo2, {
				CFrame = clone.CFrame + createVector(0, -1.5, 0),
				Size = createVector(0, 0, 0)
			})
			tween:play()
			tween.Completed:Connect(function()
				if clone then
					clone:Destroy()
				end
			end)
		end))
		coroutine.resume(coroutine.create(function()
			for _ = 1, math.random(2, 4) do
				local clone2 = FX:WaitForChild("MagmaEffects").OptimizedBall2:Clone()
				Vector3.new(math.random(-10, 10) / 10, math.random(5, 10) / 10, math.random(-10, 10) / 10)
				clone2.PrimaryPart.CFrame = CFrame.new(raycast_pos_to_send, raycast_pos_to_send + raycast_norms_to_send) * CFrame.Angles(
					math.rad(math.random(-350, 350) / 10),
					math.rad(math.random(-350, 350) / 10),
					(math.rad(math.random(-350, 350) / 10))
				)
				clone2.PrimaryPart.Anchored = false
				clone2.Parent = _WorldOrigin

				for _, child in pairs(clone2:GetChildren()) do
					if not (child.Name ~= "root" and child.Name ~= "Sphere") then
						continue
					end

					child.Size *= scale_by_to_send / 2
					local tween = TweenService:Create(
						child,
						TweenInfo.new(math.random(30, 50) / 10, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					)
					tween:Play()
					local v5 = clone2
					tween.Completed:Connect(function()
						if v5 then
							v5:Destroy()
						end
					end)
				end

				clone2.PrimaryPart.Velocity = clone2.PrimaryPart.CFrame.lookVector * (math.random(1000, 1500) / 10)
				clone2.PrimaryPart.RotVelocity = Vector3.new(
					math.random(-50, 50) / 10,
					math.random(-50, 50) / 10,
					math.random(-50, 50) / 10
				)
			end
		end))
		local clone2 = game.ReplicatedStorage.Assets.Sphere2:Clone()
		clone2.CFrame = cframe_to_send
		clone2.Color = Color3.fromRGB(213, 115, 61)
		clone2.Material = Enum.Material.Neon
		clone2.CastShadow = false
		clone2.Transparency = 0.5
		clone2.Parent = _WorldOrigin
		local mesh = clone2.Mesh
		mesh.Scale = Vector3.new(scale_by_to_send / 1.15, scale_by_to_send / 1.15, scale_by_to_send / 1.15)
		local tween = TweenService:Create(mesh, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = Vector3.new(scale_by_to_send * 3, scale_by_to_send * 3, scale_by_to_send * 3)
		})
		tween:Play()
		coroutine.resume(coroutine.create(function()
			wait(0.125)
			TweenService:Create(clone2, TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Color = Color3.fromRGB(170, 0, 0)
			}):Play()
		end))
		tween.Completed:Connect(function()
			if clone2 then
				clone2:Destroy()
			end
		end)
	elseif effect == "MagmaBubblesImpact" then
		local cframe_to_send = player.cframe_to_send

		if (cframe_to_send.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 1000 then
			return
		end

		local scale_by_to_send = player.scale_by_to_send
		local lifetime_to_send = player.lifetime_to_send
		local _ = player.enemy_hit_to_send
		local _ = player.raycast_hit_to_send
		local raycast_pos_to_send = player.raycast_pos_to_send
		local raycast_norms_to_send = player.raycast_norms_to_send
		local p = cframe_to_send.p
		local character = game.Players.LocalPlayer.Character

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= 100 then
				Util.CameraShaker:ShakeOnce(2.5, 10, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 1))
			end
		end

		local v3 = nil

		for _ = 1, 2 do
			local clone = FX:WaitForChild("MagmaEffects").OptimizedBall2:Clone()
			v3 = clone
			local v4 = CFrame.new(math.random(-100, 100) / 10, math.random(-100, 100) / 10, math.random(-100, 100) / 10) * CFrame.Angles(
				math.rad(math.random(-350, 350) / 10),
				math.rad(math.random(-350, 350) / 10),
				(math.rad(math.random(-350, 350) / 10))
			)

			if raycast_pos_to_send or raycast_norms_to_send then
				if raycast_pos_to_send and raycast_norms_to_send then
					for _, part in pairs(clone:GetChildren()) do
						if part:IsA("BasePart") then
							part.CFrame = CFrame.new(raycast_pos_to_send, raycast_pos_to_send + raycast_norms_to_send) * v4
						end
					end
				end
			else
				for _, part in pairs(clone:GetChildren()) do
					if part:IsA("BasePart") then
						part.CFrame = cframe_to_send * v4
					end
				end
			end

			if clone:FindFirstChild("Sphere") then
				clone.Sphere:Destroy()
			end

			local cframe = CFrame.Angles(
				math.rad(math.random(-350, 350) / 10),
				math.rad(math.random(-350, 350) / 10),
				(math.rad(math.random(-350, 350) / 10))
			)

			for _, child in pairs(clone:GetChildren()) do
				if child.Name ~= "root" and child.Name ~= "Sphere" then
					TweenService:Create(
						child,
						TweenInfo.new(lifetime_to_send / 2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = child.CFrame * cframe,
							Size = child.Size * scale_by_to_send
						}
					):Play()
				end
			end

			clone.Parent = _WorldOrigin
			coroutine.resume(coroutine.create(function()
				wait(lifetime_to_send)

				for _, part in pairs(clone:GetChildren()) do
					if part:IsA("BasePart") then
						TweenService:Create(
							part,
							TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								CFrame = cframe_to_send
							}
						):Play()
					end
				end

				local v5 = false

				for _, child in pairs(clone:GetChildren()) do
					if not (child.Name ~= "root" and child.Name ~= "Sphere") then
						continue
					end

					local tween = TweenService:Create(
						child,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(0.2, 0.2, 0.2)
						}
					)
					tween:Play()

					if v5 then
						continue
					end

					tween.Completed:Connect(function()
						if clone and clone.Parent then
							clone:Destroy()
							clone = nil
						end
					end)
					v5 = true
				end
			end))
		end

		local clone = game.ReplicatedStorage.Assets.Sphere2:Clone()
		clone.CFrame = cframe_to_send
		clone.Color = Color3.fromRGB(213, 115, 61)
		clone.Material = Enum.Material.Neon
		clone.CastShadow = false
		clone.Transparency = 0
		clone.Parent = _WorldOrigin
		local mesh = clone.Mesh
		mesh.Scale = Vector3.new(scale_by_to_send / 1.15, scale_by_to_send / 1.15, scale_by_to_send / 1.15)
		local tween = TweenService:Create(mesh, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = Vector3.new(scale_by_to_send * 3, scale_by_to_send * 3, scale_by_to_send * 3)
		})
		tween:Play()
		coroutine.resume(coroutine.create(function()
			wait(0.1)
			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Color = Color3.fromRGB(170, 0, 0)
			}):Play()
		end))
		tween.Completed:Connect(function()
			if clone then
				clone:Destroy()
			end
		end)

		if player.multiple_magma_puddles then
			local amount = player.amount
			local starting_point = player.starting_point or v3.PrimaryPart

			if not starting_point then
				return
			end

			local scale_by_to_send_2 = player.scale_by_to_send_2

			for i = 1, amount do
				local v4 = CFrame.new(starting_point.Position)
				local v5 = i
				coroutine.resume(coroutine.create(function()
					local clone2 = FX:WaitForChild("MagmaEffects").template:Clone()
					clone2.CFrame = v4 * CFrame.Angles(0, math.rad(360 / amount * v5), 0)
					local v6 = clone2.CFrame * CFrame.new(0, 0, -math.random(25, 50) * scale_by_to_send_2 / 7.5)
					local ray, v7, v8 = Util.Ray(
						v6.p + createVector(0, 10, 0),
						CFrame.new(v6.p).UpVector * -500,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if ray then
						local clone3 = FX:WaitForChild("MagmaEffects").MagmaBallPhysics:Clone()
						v3 = clone3
						local v9 = CFrame.new(
							math.random(-100, 100) / 10,
							math.random(-100, 100) / 10,
							math.random(-100, 100) / 10
						) * CFrame.Angles(
							math.rad(math.random(-350, 350) / 10),
							math.rad(math.random(-350, 350) / 10),
							(math.rad(math.random(-350, 350) / 10))
						)

						for i2, part in pairs(clone3:GetChildren()) do
							if not part:IsA("BasePart") then
								continue
							end

							part.Position = starting_point.Position
							part.CFrame = CFrame.new(part.Position, CFrame.new(v7, v7 + v8).Position)
						end

						for i2, descendant in pairs(clone3:GetDescendants()) do
							if descendant:IsA("Trail") then
								descendant.Enabled = true
							end

							if not descendant:IsA("Attachment") then
								continue
							end

							if descendant.Name == "a1" then
								descendant.Position = Vector3.new(0, scale_by_to_send_2 / 1.5, 0)
							elseif descendant.Name == "a2" then
								descendant.Position = Vector3.new(0, -scale_by_to_send_2 / 1.5, 0)
							end
						end

						for i2, part in pairs(clone3:GetChildren()) do
							if part:IsA("BasePart") then
								part.Size *= scale_by_to_send_2
							end
						end

						if clone3:FindFirstChild("Sphere") then
							clone3.Sphere:Destroy()
						end

						clone3.Parent = _WorldOrigin
						local v10 = math.random(2, 3)
						local v11 = math.random(10, 20) * scale_by_to_send_2 / 5
						local v12 = math.random(50, 75)
						local v13 = math.random(85, 100)
						math.random(-35, 25)
						math.random(-50, -40)
						local v14 = math.random(150, 250) / 100
						local v15 = math.rad((math.random(360)))
						local magnitude = (clone3.PrimaryPart.Position - v7).Magnitude

						for i2, part in pairs(clone3:GetChildren()) do
							if not part:IsA("BasePart") then
								continue
							end

							local v16 = part
							coroutine.resume(coroutine.create(function()
								beziers.Interpolate(
									"Cubic",
									0,
									100,
									v14,
									nil,
									v16.CFrame,
									v16.CFrame * CFrame.new(0, v12, -magnitude / 5),
									v16.CFrame * CFrame.new(0, v13, -magnitude / 10),
									CFrame.new(v7, v7 + v8),
									v16,
									"CFrame"
								)
								v16.CFrame = CFrame.new(v7, v7 + v8) * CFrame.Angles(0, 0, v15)
								TweenService:Create(v16, TweenInfo.new(v10), {
									Size = v16.Size + Vector3.new(v11, v11, -math.random(25, 35) / 10)
								}):Play()
								coroutine.resume(coroutine.create(function()
									wait(v10 * 2)

									if v16.Name ~= "root" and v16.Name ~= "sphere" then
										local tween2 = TweenService:Create(
											v16,
											TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
											{
												Size = createVector(0, 0, 0)
											}
										)
										tween2:Play()
										tween2.Completed:Connect(function()
											if clone3 then
												clone3:Destroy()
											end
										end)
									end
								end))
							end))
						end
					end
				end))
			end
		end
	elseif effect == "MagmaDrip" then
		local target_to_send = player.target_to_send

		if not target_to_send or (target_to_send.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 1000 then
			return
		end

		local size_to_send = player.size_to_send
		local magnitude_to_send = player.magnitude_to_send
		local v3 = target_to_send.Size.X / 2 * 200
		local _ = target_to_send.Size.Y / 2 * 100
		local v4 = target_to_send.Size.Z / 2 * 200
		local clone = FX:WaitForChild("MagmaEffects").OptimizedBall2:Clone()
		local primaryPart = clone.PrimaryPart
		clone:SetPrimaryPartCFrame(target_to_send.CFrame * CFrame.new(
			math.random(-v3, v3) / 100,
			0,
			math.random(-v4, v4) / 100
		))
		local v5 = math.random(15, 50) / size_to_send

		for _, part in pairs(clone:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "root" then
				part.Size /= v5
			end
		end

		local cframe = CFrame.new(primaryPart.Position)
		local ray, v6, v7 = Util.Ray(
			cframe.p,
			cframe.UpVector * -500,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if v6.Y <= -4 then
			v6 = v6 * createVector(1, 0, 1) + createVector(0, -4, 0)
		end

		if ray then
			clone.Parent = _WorldOrigin
			local magnitude = (cframe.Position - v6).Magnitude
			local v8 = cframe * CFrame.new(0, -magnitude, 0)
			local v9 = 0.225 * ((cframe.Position - v8.Position).Magnitude / magnitude_to_send)

			for _, part in pairs(clone:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "root" then
					TweenService:Create(part, TweenInfo.new(v9 / 2), {
						Size = part.Size + Vector3.new(
							-math.random(2, 3) / 10,
							-math.random(2, 3) / 10,
							math.random(2, 3) / 10
						)
					}):Play()
				end
			end

			local v10 = math.random(2, 3)
			local v11 = math.random(10, 20) * size_to_send / 50

			if v6.Y <= -4 then
				task.delay(v9, function()
					for _, part in pairs(clone:GetChildren()) do
						if part:IsA("BasePart") then
							part.CanCollide = true
						end
					end

					local v12 = createVector(1.405, 1.488, 1.434) / v5 + Vector3.new(v11, v11, -math.random(2, 3) / 10)
					Util.Sound:Play("SteamHiss", primaryPart, nil, 5.224 / v10)
					local clones = {}

					for _, emitter in pairs(ReplicatedStorage.Assets.Models.MagmaFloors.Particles:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local clone2 = emitter:Clone()
						local size, speed, acceleration = ScaleParticle(
							clone2,
							(v12 / 4 * createVector(1, 0, 1)).Magnitude * 0.08
						)
						clone2.Size = size
						clone2.Speed = speed
						clone2.Acceleration = acceleration
						clone2.Parent = primaryPart
						table.insert(clones, clone2)
					end

					for _, v13 in pairs(clones) do
						local enable = v13:GetAttribute("Enable")
						local emit = v13:GetAttribute("Emit")

						if emit then
							v13:Emit(2 * (typeof(emit) == "number" and emit or 1))
						end

						if not enable then
							continue
						end

						if typeof(enable) == "number" then
							local v14 = v13
							task.delay(enable + v10 / 8, function()
								v14.Enabled = false
							end)
						end

						v13.Enabled = enable and true
					end
				end)
			end

			local v12 = math.rad((math.random(360)))

			for _, part in pairs(clone:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				local tween = TweenService:Create(
					part,
					TweenInfo.new(v9, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
					{
						CFrame = v8 * CFrame.Angles(0, math.rad((math.random(360))), 0)
					}
				)
				tween:Play()
				local v13 = part
				tween.Completed:Connect(function()
					v13.CFrame = CFrame.new(v6, v6 + v7) * CFrame.Angles(0, 0, v12)
					TweenService:Create(v13, TweenInfo.new(v10), {
						Size = v13.Size + Vector3.new(v11, v11, -math.random(2, 3) / 10)
					}):Play()
					coroutine.resume(coroutine.create(function()
						wait(v10 * 2)

						if v13.Name ~= "root" and v13.Name ~= "sphere" then
							local tween2 = TweenService:Create(
								v13,
								TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
								{
									Size = createVector(0, 0, 0)
								}
							)
							tween2:Play()
							tween2.Completed:Connect(function()
								if clone then
									clone:Destroy()
								end
							end)
						end
					end))
				end)
			end
		else
			clone:Destroy()
		end
	elseif effect == "MagmaTrail" then
		local part_to_send = player.part_to_send

		if not part_to_send or (part_to_send.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 1500 then
			return
		end

		local scale_by_to_send = player.scale_by_to_send
		local HttpService = game:GetService("HttpService")
		local GUID = HttpService:GenerateGUID()
		local count = 0
		local fastMode = _G.FastMode
		local RunService2 = game:GetService("RunService")
		RunService2:BindToRenderStep(GUID, Enum.RenderPriority.Last.Value, function()
			if part_to_send:IsDescendantOf(workspace) then
				count += 1

				if count % (fastMode and 5 or 3) > 0 then
					return
				end

				local clone = FX:WaitForChild("MagmaEffects").OptimizedBall:Clone()
				clone.Size *= scale_by_to_send / 2
				local v3 = part_to_send.Size.X / 2.5
				local v4 = part_to_send.Size.Y / 2.5
				local v5 = part_to_send.Size.Z / 2.5
				clone.CFrame = part_to_send.CFrame * CFrame.new(
					math.random(-v3, v3),
					math.random(-v4, v4),
					math.random(-v5, v5)
				) * CFrame.Angles(
					math.rad((math.random(360))),
					math.rad((math.random(360))),
					(math.rad((math.random(360))))
				)
				clone.Parent = _WorldOrigin
				TweenService:Create(clone, TweenInfo.new(5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
					CFrame = clone.CFrame * CFrame.Angles(
						math.rad((math.random(360))),
						math.rad((math.random(360))),
						(math.rad((math.random(360))))
					)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = clone.Size * scale_by_to_send / 2
				}):Play()
				coroutine.resume(coroutine.create(function()
					wait(math.random(20, 35) / 100)
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							CFrame = clone.CFrame,
							Size = createVector(0.1, 0.1, 0.1)
						}
					)
					tween:Play()
					tween.Completed:Connect(function()
						if clone then
							clone:Destroy()
						end
					end)
				end))
			else
				local RunService3 = game:GetService("RunService")
				RunService3:UnbindFromRenderStep(GUID)
			end
		end)
	elseif effect == "new_hound_explosion_cus_im_tired" then
		if (player.cframe_to_send.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 1500 then
			return
		end

		local clone = FX:WaitForChild("MagmaEffects").magma_ground_p:Clone()
		clone.CFrame = player.cframe_to_send
		clone.Parent = _WorldOrigin
		local clone2 = FX:WaitForChild("MagmaEffects").ad_smoke_p:Clone()
		clone2.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 25), NumberSequenceKeypoint.new(1, 35) })
		clone2.Parent = clone
		clone2:Emit(7)
		Util.Debris:AddItem(clone, 5)

		for _ = 1, 10 do
			spark_effect({
				life_time = math.random(100, 150) / 100,
				cframe = player.cframe_to_send,
				scale = player.scale_to_send / 10,
				color = math.random(1, 2) == 1 and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(0, 0, 0),
				material = Enum.Material.Neon,
				speed = math.random(35, 60) / 10,
				angle_x = math.random(-360, 360) / 10,
				angle_y = math.random(-360, 360) / 10,
				angle_z = math.random(-360, 360) / 10
			})
			local clone3 = FX:WaitForChild("MagmaEffects").OptimizedBall2:Clone()
			local vector2 = Vector3.new(
				math.random(-360, 360) / 10,
				math.random(-45, 135) / 10,
				math.random(-360, 360) / 10
			)
			local v4 = math.random(250, 300)

			for _, part in pairs(clone3:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Size *= v4 / 10
				part.CFrame = CFrame.new(player.cframe_to_send.p, player.cframe_to_send * vector2) * CFrame.Angles(
					math.rad((math.random(-360, 360))),
					math.rad((math.random(-360, 360))),
					(math.rad((math.random(-360, 360))))
				)
				part.Anchored = false
			end

			for _, emitter in pairs(clone3:GetDescendants()) do
				if not (emitter:IsA("ParticleEmitter") and emitter.Name == "smoke_p") then
					continue
				end

				emitter.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 5),
					NumberSequenceKeypoint.new(1, 10)
				})
				emitter.Speed = NumberRange.new(250)
				emitter.Rate /= 3
				emitter.Enabled = true
			end

			clone3.Parent = _WorldOrigin

			for _, child in pairs(clone3:GetChildren()) do
				if not (child.Name ~= "root" and child.Name ~= "Sphere") then
					continue
				end

				local tween = TweenService:Create(
					child,
					TweenInfo.new(math.random(10, 20) / 10, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(0, 0, 0)
					}
				)
				tween:Play()
				local folder = clone3
				tween.Completed:Connect(function()
					for i, emitter in pairs(folder:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") and emitter.Name == "smoke_p" then
							emitter.Enabled = false
						end
					end

					if folder then
						Util.Debris:AddItem(folder, 5)
					end
				end)
			end

			local velocity = clone3.PrimaryPart.CFrame.lookVector * (math.random(1500, 2000) / 10)
			local vector3 = Vector3.new(math.random(-50, 50) / 10, math.random(-50, 50) / 10, math.random(-50, 50) / 10)

			for _, part in pairs(clone3:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Velocity = velocity
				part.RotVelocity = vector3
			end
		end
	end
end