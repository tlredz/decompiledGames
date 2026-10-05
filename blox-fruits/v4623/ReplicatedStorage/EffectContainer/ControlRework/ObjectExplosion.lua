local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("StarterPlayer")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local M1 = FX:WaitForChild("ControlRework").M1
local c_Katsuo = FX:WaitForChild("ControlRework").C_Katsuo
local lightningBoltShafi = Util.LightningBoltShafi

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

local function RecolorControlColorSequence(player, p)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColorSequenceConstructor(p, player, "ControlFruitVFXColor")
	end

	return p
end

local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local shared = script.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
local Rocks = require(shared.Rocks)
local objectExplosion = FX:WaitForChild("ControlRework"):WaitForChild("Gameplay"):WaitForChild("ObjectExplosion")
require(ReplicatedStorage.Effect)
local random = Random.new()
return function(data)
	if typeof(data.Player) == "Instance" and data.Player:IsA("Player") and not data.Player:FindFirstChild("PlayerGui") and data.Player ~= game.Players.LocalPlayer then
		local folder_2 = Instance.new("Folder", data.Player)
		folder_2.Name = "PlayerGui"
	end

	Util.CameraShaker:Shake("Pilar Hard")
	local position = data.Position
	local normal = data.Normal
	local object = data.Object
	local energized = data.Energized
	local color = energized and Color3.fromRGB(75, 75, 75) or object.Color
	local v = not (normal and position)
	local v2 = M1[v and "AutoDestroyExplosion" or "Explosion"]
	local clone = v2:Clone()
	clone:ScaleTo(data.Scale)
	local v3 = clone.Main.Size.X / v2.Main.Size.X
	local v4 = math.floor(v3)
	local v5 = clone.Main.Size.X / 2
	local cFrame = v and object.CFrame or CFrame.lookAt(position, position + normal) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	) * CFrame.new(0, 0.5, 0)
	clone:PivotTo(cFrame)
	local v6 = data.Scale < 6.4 and data.Scale > 4 and 2 or data.Scale > 6.4 and 3 or 1
	Util.Sound:Play(
		({ "CTRLFRT_Fist_Explode_Small_01-001", "M1_CubeExplode_Medium_V2_01", "M1_CubeExplode_Large_V2_01" })[v6],
		cFrame.Position
	)
	Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, data.Player, "ControlFruitVFXColor")
	VisualHelper:EmitAll(clone)
	Util.Debris:AddItem(clone, 6)
	local beams = clone.Main.Beams
	VisualHelper:Tween(beams, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
		Orientation = beams.Orientation + createVector(0, 550, 0)
	})

	for _, beam in beams:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		VisualHelper:Tween(beam, TweenInfo.new(0.2 + math.random() * 0.1, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	Util.Debris:AddItem(beams, 0.5)
	local clone2 = c_Katsuo.BallNeon:Clone()
	clone2.CFrame = cFrame
	clone2.Transparency = 0.8
	local player = data.Player
	local color2 = Color3.fromRGB(18, 35, 195)

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		color2 = Util.WrapColor3Constructor(color2, player, "ControlFruitVFXColor")
	end

	clone2.Color = color2
	clone2.Size = createVector(1, 1, 1) * (clone.Main.Size.Y * 0.65)
	clone2.Parent = workspace._WorldOrigin
	VisualHelper:Tween(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		Size = clone.Main.Size * 1.3,
		Transparency = 1
	})
	Util.Debris:AddItem(clone2, 0.25)
	local clone3 = c_Katsuo.BallNeon:Clone()
	clone3.CFrame = cFrame
	clone3.Transparency = 0.75
	local player2 = data.Player
	local color3 = Color3.fromRGB(18, 35, 195)

	if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
		color3 = Util.WrapColor3Constructor(color3, player2, "ControlFruitVFXColor")
	end

	clone3.Color = color3
	clone3.Size = createVector(1, 1, 1) * clone.Main.Size.Y
	clone3.Parent = workspace._WorldOrigin
	VisualHelper:Tween(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		Size = clone.Main.Size * 1.9,
		Transparency = 1
	})
	Util.Debris:AddItem(clone3, 0.15)

	local function NewBolt(attachment, attachment2, value: number?)
		local v7 = lightningBoltShafi.new(
			attachment,
			attachment2,
			math.clamp((value or 2) * v4, 4, 12),
			math.clamp(v4 * 0.75, 0, 3.25),
			workspace._WorldOrigin
		)
		v7.CurveSize0 = 0
		v7.CurveSize1 = 0
		v7.MinRadius = 1
		v7.MaxRadius = 7
		v7.Frequency = 0.7
		v7.AnimationSpeed = math.random(4.5, 8.5)
		local maxThicknessMultiplier = 0.3 + math.random() * 0.75
		v7.MinThicknessMultiplier = 0.1
		v7.MaxThicknessMultiplier = maxThicknessMultiplier
		v7.MinTransparency = 0
		v7.MaxTransparency = 1
		v7.PulseSpeed = 40
		v7.PulseLength = 1000000
		v7.FadeLength = 0.2
		local player3 = data.Player
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(125, 164, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 93, 255))
		})

		if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
			colorSequence = Util.WrapColorSequenceConstructor(colorSequence, player3, "ControlFruitVFXColor")
		end

		v7.Color = colorSequence
		v7.ContractFrom = 0.5
		v7.ColorOffsetSpeed = 3
		return v7
	end

	local attachment = Instance.new("Attachment")
	attachment.WorldPosition = cFrame.Position
	attachment.Parent = workspace.Terrain
	Util.Debris:AddItem(attachment, 4)

	if not data.IsCustom then
		for i = 1, 2 do
			local clone4 = M1.SliceCubes["Part" .. i]:Clone()
			clone4.Size = object.Size * createVector(0.5, 1, 1)
			clone4.CFrame = object.CFrame * CFrame.new((i == 1 and -0.25 or 0.25) * object.Size.X, 0, 0)
			clone4.Color = color
			clone4.Material = object.Material
			local v7

			if energized then
				for k, v8 in { M1.SliceCubes["Gradient" .. i], M1.SliceCubes["Outline" .. i] } do
					local clone5 = v8:Clone()
					clone5.Name = string.sub(clone5.Name, 1, #clone5.Name - 1)
					clone5.CFrame = clone4.CFrame
					clone5.Weld.Part1 = clone4
					clone5.Mesh.Scale = clone4.Size / clone4.MeshSize * (k == 1 and 1.007 or 1.0235)
					Util.SetParentOverrideWithColor(clone5, clone4, data.Player, "ControlFruitVFXColor")
				end

				v7 = NewBolt(attachment, Instance.new("Attachment", clone4))
			else
				v7 = nil
			end

			clone4.Parent = workspace._WorldOrigin
			clone4.AssemblyLinearVelocity = createVector(0, 1, 0) * math.random(60, 80)
			clone4.AssemblyAngularVelocity += Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
			task.delay(0.4, function()
				local number = random:NextNumber(1.5, 2.5)

				for k, part in {
					clone4,
					energized and clone4.Gradient.Mesh or nil,
					energized and clone4.Outline.Mesh or nil
				} do
					local scope = VisualHelper
					scope:Tween(part, TweenInfo.new(number, Enum.EasingStyle.Sine), {
						[part:IsA("MeshPart") and "Size" or "Scale"] = createVector(0, 0, 0)
					})
				end

				local v9

				if energized then
					v9 = task.wait(math.random() * 0.5)
					v7:Destroy()
				else
					v9 = 0
				end

				task.wait(number - v9)
				clone4:Destroy()
			end)
		end
	end

	if v then
		local circleWave = clone.CircleWave
		local size = circleWave.Size
		circleWave.Size = size * 1.3
		VisualHelper:Tween(circleWave, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			CFrame = circleWave.CFrame * CFrame.new(0, v4 * 1.5, 0),
			Transparency = 1,
			Size = size
		})
		local clone4 = c_Katsuo.BallNeon:Clone()
		clone4.CFrame = cFrame
		clone4.Transparency = 0.94
		local player3 = data.Player
		local color4 = Color3.fromRGB(89, 133, 255)

		if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
			color4 = Util.WrapColor3Constructor(color4, player3, "ControlFruitVFXColor")
		end

		clone4.Color = color4
		clone4.Size = createVector(1, 1, 1) * (clone.Main.Size.Y * 0.65)
		clone4.Parent = workspace._WorldOrigin
		VisualHelper:Tween(clone4, TweenInfo.new(0.55, Enum.EasingStyle.Sine), {
			Size = clone4.Size * 2.5,
			Transparency = 1
		})
		Util.Debris:AddItem(clone4, 0.55)
	else
		clone.Main.Center.Hold.SmokeToggle.Enabled = true
		local energized2 = clone.Energized

		if energized then
			energized2.Parent = workspace.Terrain
			VisualHelper:SetEnableAll(clone.Main.EnergizedFloor, true)
		else
			clone.Main.Energized:Destroy()
			clone.Main.EnergizedFloor:Destroy()
			energized2:Destroy()
		end

		local circleBeam = clone.Main.CircleBeam
		circleBeam.Orientation = Vector3.new(0, math.random(360))

		for _, v7 in { circleBeam.Beam1, circleBeam.Beam2 } do
			v7.Enabled = true
			VisualHelper:Tween(v7, TweenInfo.new(0.16, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		Util.Debris:AddItem(circleBeam, 0.3)

		if object.Name == "Main" then
			local model = Instance.new("Model", workspace._WorldOrigin)
			Util.Debris:AddItem(model, 5)
			local cframe = CFrame.new(cFrame.Position)
			local raycastParams = RaycastParams.new()
			raycastParams.IgnoreWater = false
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Map }
			local position2 = cframe.Position
			local raycastResult = workspace:Raycast(
				position2 + createVector(0, 1, 0),
				CFrame.new(position2).UpVector * -50,
				raycastParams
			) or workspace:Raycast(position2 + createVector(0, 1, 0), data.Normal * -50, raycastParams)

			if not raycastResult then
				return
			end

			if v6 == 2 then
				local v7 = 1 + (data.Scale - 4) / 8
				task.spawn(function()
					task.spawn(function()
						local clone4 = objectExplosion.Phase1.Spike.Normal:Clone()
						clone4.Size *= v7
						clone4.CFrame = cframe * CFrame.new(0, -25, 0)
						clone4.Parent = model
						local tween = TweenService:Create(
							clone4,
							TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Size = clone4.Size * 1.5,
								CFrame = clone4.CFrame * CFrame.new(0, 50, 0)
							}
						)
						clone4.Size *= 0.5
						tween:Play()
						tween.Completed:Wait()
						TweenService:Create(
							clone4,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1,
								CFrame = clone4.CFrame * CFrame.new(0, -clone4.Size.Y / 2, 0),
								Size = Vector3.new(clone4.Size.X * 0, clone4.Size.Y * 0, clone4.Size.Z * 0)
							}
						):Play()
					end)
					task.spawn(function()
						local v8 = cframe.Position + createVector(0, -10, 0)
						local v9 = 50 * v7

						for i = 1, 10 do
							local v10 = i / 10 * 3.141592653589793 * 2
							local v11 = math.cos(v10) * v9
							local v12 = math.sin(v10) * v9
							local v13 = math.random(1, 3)
							local clone4 = objectExplosion.Phase1.Clouds["MeshPart" .. v13]:Clone()
							clone4.Size *= v7
							clone4.Position = v8 + Vector3.new(v11, math.random(0, 10), v12)
							local HSV, v14, _ = raycastResult.Instance.Color:ToHSV()
							clone4.Color = Color3.fromHSV(HSV, v14, 0.45)
							clone4.Parent = model
							clone4.CFrame = CFrame.new(clone4.Position, v8)
							TweenService:Create(clone4, TweenInfo.new(0.25), {
								Size = clone4.Size * 2
							}):Play()
							task.delay(0.2, function()
								TweenService:Create(clone4, TweenInfo.new(0.25), {
									Size = clone4.Size * 0
								}):Play()
							end)
						end
					end)
					task.spawn(function()
						local v8 = cframe.Position + createVector(0, 5, 0)
						local v9 = 40 * v7

						for i = 1, 8 do
							local v10 = i / 8 * 3.141592653589793 * 2
							local v11 = math.cos(v10) * v9
							local v12 = math.sin(v10) * v9
							local clone4 = objectExplosion.Phase1.Spike.Skinnier:Clone()
							clone4.Size *= v7
							clone4.Position = v8 + Vector3.new(v11, math.random(-10, 20), v12)
							clone4.Parent = model
							clone4.CFrame = CFrame.new(clone4.Position, v8) * CFrame.new(0, 0, -math.random(5, 15)) * CFrame.Angles(
								0.6108652381980153,
								math.rad((math.random(-180, 180))),
								0
							)
							TweenService:Create(clone4, TweenInfo.new(0.15), {
								Size = clone4.Size * 1.35
							}):Play()
							task.delay(0.1, function()
								TweenService:Create(clone4, TweenInfo.new(0.1), {
									Size = Vector3.new(0, clone4.Size.Y, 0)
								}):Play()
								task.wait(0.1)
								TweenService:Create(clone4, TweenInfo.new(0.25), {
									Size = clone4.Size * 0
								}):Play()
							end)
						end
					end)
					local clone4 = objectExplosion.Phase1.GroundCrack2:Clone()
					clone4.CFrame = cframe
					Util.SetParentOverrideWithColor(clone4, model, data.Player, "ControlFruitVFXColor")
					local v8 = cframe.Position + createVector(0, -10, 0)
					local v9 = 70 * v7

					for i = 1, 10 do
						local v10 = i / 10 * 3.141592653589793 * 2
						local v11 = math.cos(v10) * v9
						local v12 = math.sin(v10) * v9
						local clone5 = clone4.Impact1:Clone()
						Util.ResizeModel(clone5, v7, clone5.Position)
						clone5.Anchored = true
						clone5.WeldConstraint.Enabled = false
						clone5.Position = v8 + Vector3.new(v11, math.random(0, 50), v12)
						clone5.Parent = model
						clone5.CFrame = CFrame.new(clone5.Position, v8) * CFrame.Angles(
							math.rad(35 + math.random(-10, 20)),
							0,
							(math.rad(5 + math.random(-10, 10) / 3))
						)
						local v13 = math.random(1, #clone4.Impact1.Attach1:GetChildren())

						for _, beam in pairs(clone5:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							if beam.Name == "Beam" .. v13 then
								beam.Brightness = math.random(5, 7) / 2
								beam.LightEmission = math.random(5, 8) / 10
								beam.Enabled = true
								TweenService:Create(beam, TweenInfo.new(0.05), {
									Width0 = beam.Width0 + math.random(-5, 35) / 100,
									Width1 = beam.Width1 + math.random(-5, 55) / 1
								}):Play()
								local v14 = beam
								task.delay(0.025, function()
									TweenService:Create(v14, TweenInfo.new(0.05), {
										Width0 = v14.Width0 + 0.17,
										Width1 = v14.Width1 + 0.17
									}):Play()
									task.wait(0.035 * math.random())

									for i2 = 90, 100 do
										v14.Transparency = NumberSequence.new(i2 / 100, i2 / 100)
										task.wait(0.0015)
									end
								end)
							else
								beam:Destroy()
							end
						end

						local tween = TweenService:Create(clone5.Attach1, TweenInfo.new(0.1 + math.random() * 0.05), {
							Position = clone5.Attach1.Position + Vector3.new(0, math.random(25, 100), 0)
						})
						clone5.Attach1.Position = createVector(0, 0, 0)
						tween:Play()
					end

					clone4.Impact1:Destroy()
					local clone5 = objectExplosion.Phase1.GroundCrack0:Clone()
					Util.ResizeModel(clone5, v7, clone5.Position)
					clone5.CFrame = cframe
					Util.SetParentOverrideWithColor(clone5, model, data.Player, "ControlFruitVFXColor")

					for _, emitter in pairs(clone5:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v10 = emitter
						task.spawn(function()
							if v10:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v10:GetAttribute("EmitDelay"))
							end

							if v10.Parent.Name == "Impact2" then
								v10.Color = ColorSequence.new(
									raycastResult.Instance.Color,
									raycastResult.Instance.Color
								)
							end

							v10:Emit(v10:GetAttribute("EmitCount"))
						end)
					end

					task.spawn(function()
						for _ = 1, 5 do
							task.spawn(function()
								local clone6 = objectExplosion.Phase1.SmallTrailModel:Clone()
								local primaryPart = clone6.PrimaryPart
								clone6:ScaleTo(math.random(10, 35) / 15 * (1 + (v7 - 1) * 0.5))
								primaryPart.CFrame = cframe * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
								Util.SetParentOverrideWithColor(clone6, model, data.Player, "ControlFruitVFXColor")
								rocks:ApplyCollision(primaryPart, nil, true)
								primaryPart.CFrame = primaryPart.CFrame * CFrame.new(0, 0, -math.random(45, 70)) * CFrame.Angles(
									0,
									0,
									(math.rad(math.random(-180, 180) / 15))
								) * CFrame.Angles(math.rad(math.random(35, 50) * 1.75), 0, 0)
								primaryPart.Anchored = false

								for _, effect in pairs(primaryPart:GetDescendants()) do
									if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
										continue
									end

									effect.Enabled = true
									effect.Color = ColorSequence.new(
										raycastResult.Instance.Color,
										raycastResult.Instance.Color
									)
								end

								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
								bodyVelocity.P = 5000
								bodyVelocity.Parent = primaryPart
								local v10 = v7 * math.random(500, 1150) / 1.1
								task.delay(math.random(10, 30) / 150, function()
									bodyVelocity.Velocity = primaryPart.CFrame.LookVector * v10 / 5
									task.wait()
									bodyVelocity:Destroy()
									task.wait(0.35)
									primaryPart.CanCollide = true
								end)
								bodyVelocity.Velocity = primaryPart.CFrame.LookVector * v10
								task.wait(1)

								for _, effect in pairs(primaryPart:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end
							end)
						end
					end)
					task.spawn(function()
						for _ = 1, 5 do
							task.spawn(function()
								local clone6 = objectExplosion.Phase1.ProjectileModel:Clone()
								local primaryPart = clone6.PrimaryPart
								clone6:ScaleTo(math.random(10, 30) / 15 * (1 + (v7 - 1) * 0.5))
								primaryPart.CFrame = cframe * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
								Util.SetParentOverrideWithColor(clone6, model, data.Player, "ControlFruitVFXColor")
								rocks:ApplyCollision(primaryPart, nil, true)
								primaryPart.CFrame = primaryPart.CFrame * CFrame.new(
									0,
									math.random(1, 25),
									-math.random(35, 60)
								) * CFrame.Angles(0, 0, (math.rad(math.random(-180, 180) / 15))) * CFrame.Angles(
									math.rad(math.random(35, 80) * 1.5),
									0,
									0
								)
								primaryPart.Anchored = false

								for _, effect in pairs(primaryPart:GetDescendants()) do
									if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
										continue
									end

									effect.Enabled = true
									effect.Color = ColorSequence.new(
										raycastResult.Instance.Color,
										raycastResult.Instance.Color
									)
								end

								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
								bodyVelocity.P = 5000
								bodyVelocity.Parent = primaryPart
								local v10 = v7 * math.random(200, 300) / 1.05
								task.delay(math.random(10, 30) / 200, function()
									bodyVelocity:Destroy()
									task.wait(0.25)
									primaryPart.CanCollide = true
								end)
								bodyVelocity.Velocity = primaryPart.CFrame.LookVector * v10
								task.wait(0.5 + math.random() * 0.35)

								for _, effect in pairs(primaryPart:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end
							end)
						end
					end)
					task.spawn(function()
						local v10 = cframe

						for _ = 1, 5 do
							local clone6 = objectExplosion.Phase1.SpinTrailModel:Clone()
							clone6.PrimaryPart.CFrame = v10 * CFrame.new(0, -10, 0) * CFrame.Angles(
								0,
								math.rad((math.random(-180, 180))),
								0
							)
							clone6:ScaleTo(20 * v7)
							Util.SetParentOverrideWithColor(clone6, model, data.Player, "ControlFruitVFXColor")

							for _, effect in pairs(clone6:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
									continue
								end

								effect.Enabled = true
								effect.Color = ColorSequence.new(
									raycastResult.Instance.Color,
									raycastResult.Instance.Color
								)
							end

							local v11 = math.random(3, 5)
							local v12 = math.random(10, 15) * 7
							clone6.PrimaryPart.Attach0.Position = Vector3.new(-v11, 0, -v12)
							clone6.PrimaryPart.Attach1.Position = Vector3.new(v11, 0, -v12)
							local v13 = 0.15 + math.random(-15, 15) / 100
							TweenService:Create(
								clone6.PrimaryPart.Attach0,
								TweenInfo.new(v13 * 5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									Position = Vector3.new(-v11 / 2, 0, -v12 / 2)
								}
							):Play()
							TweenService:Create(
								clone6.PrimaryPart.Attach1,
								TweenInfo.new(v13 * 5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									Position = Vector3.new(v11 / 2, 0, -v12 / 2)
								}
							):Play()
							local folder = clone6
							local v16 = math.random(35, 50) * 0.85
							task.spawn(function()
								local v17 = math.random(8, 35) / 2

								for i = 1, 10 do
									local tween = TweenService:Create(
										folder.PrimaryPart,
										TweenInfo.new(v13 / 5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
										{
											CFrame = folder.PrimaryPart.CFrame * CFrame.new(0, v17, 0) * CFrame.Angles(
												0,
												math.rad(v16),
												0
											)
										}
									)
									tween:Play()
									tween.Completed:Wait()
								end

								for i, effect in pairs(folder:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end
							end)
						end
					end)

					local function FlyRock(cFrame2, raycastResult2, model2)
						local clone6 = objectExplosion.Phase1.Rock:Clone()
						clone6.CFrame = cFrame2
						clone6.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
						clone6.Size = clone6.Size * math.random(1, 3) * (1 + (v7 - 1) * 0.5)
						clone6.Orientation = Vector3.new(
							math.random(-90, 90),
							math.random(-90, 90),
							math.random(-90, 90)
						)
						clone6.Material = raycastResult2.Instance.Material
						clone6.Color = raycastResult2.Instance.Color
						clone6.CanCollide = false
						clone6.Parent = model2
						rocks:ApplyCollision(clone6, nil, true)
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
						bodyVelocity.P = 10000
						bodyVelocity.Parent = clone6
						local vector2 = Vector3.new(math.random(-30, 30) * 2, 0, math.random(-30, 30) * 2)
						local vector3 = Vector3.new(0, math.random(150, 200) / 1.5, 0)
						local v10 = math.random(250, 400) / 1.75 * v7
						bodyVelocity.Velocity = CFrame.new(clone6.Position, clone6.Position + vector2 + vector3).LookVector * v10
						task.delay(1 * math.random() + 0.5, function()
							TweenService:Create(
								clone6,
								TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
								{
									Size = createVector(0, 0, 0)
								}
							):Play()
						end)
						task.delay(0.075 * math.random() + 0.025, function()
							bodyVelocity:Destroy()
							task.wait(0.1)
							clone6.CanCollide = true
						end)
					end

					for _ = 1, 10 do
						task.spawn(function()
							FlyRock(
								cframe * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
									0,
									0,
									-math.random(125, 150) / 100
								),
								raycastResult,
								model
							)
						end)
					end
				end)
			elseif v6 == 3 then
				local v7 = 1 + (data.Scale - 6.4) / 8
				task.spawn(function()
					task.spawn(function()
						local clone4 = objectExplosion.Phase1.Spike.Normal:Clone()
						clone4.Size *= v7
						clone4.CFrame = cframe
						clone4.Parent = model
						local tween = TweenService:Create(
							clone4,
							TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Size = clone4.Size * 2,
								CFrame = clone4.CFrame * CFrame.new(0, 80, 0) * CFrame.Angles(0, 3.12413936106985, 0)
							}
						)
						clone4.Size *= 0.5
						tween:Play()
						tween.Completed:Wait()
						TweenService:Create(
							clone4,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1,
								CFrame = clone4.CFrame * CFrame.new(0, -clone4.Size.Y / 2, 0) * CFrame.Angles(
									0,
									-1.9024088846738192,
									0
								),
								Size = Vector3.new(clone4.Size.X * 0, clone4.Size.Y * 0, clone4.Size.Z * 0)
							}
						):Play()
					end)
					task.spawn(function()
						local v8 = cframe.Position + createVector(0, 5, 0)
						local v9 = 60 * v7

						for i = 1, 8 do
							local v10 = i / 8 * 3.141592653589793 * 2
							local v11 = math.cos(v10) * v9
							local v12 = math.sin(v10) * v9
							local clone4 = objectExplosion.Phase1.Spike.Skinnier:Clone()
							clone4.Size *= v7
							clone4.Position = v8 + Vector3.new(v11, math.random(-10, 20), v12)
							clone4.Parent = model
							clone4.CFrame = CFrame.new(clone4.Position, v8) * CFrame.new(0, 0, -math.random(5, 15)) * CFrame.Angles(
								0.6108652381980153,
								math.rad((math.random(-180, 180))),
								0
							)
							TweenService:Create(clone4, TweenInfo.new(0.5), {
								Size = clone4.Size * 2
							}):Play()
							task.delay(0.5, function()
								TweenService:Create(clone4, TweenInfo.new(0.1), {
									Size = Vector3.new(0, clone4.Size.Y, 0)
								}):Play()
								task.wait(0.1)
								TweenService:Create(clone4, TweenInfo.new(0.25), {
									Size = clone4.Size * 0
								}):Play()
							end)
						end
					end)
					task.spawn(function()
						local v8 = cframe.Position + createVector(0, -10, 0)
						local v9 = 70 * v7

						for i = 1, 10 do
							local v10 = i / 10 * 3.141592653589793 * 2
							local v11 = math.cos(v10) * v9
							local v12 = math.sin(v10) * v9
							local v13 = math.random(1, 3)
							local clone4 = objectExplosion.Phase1.Clouds["MeshPart" .. v13]:Clone()
							clone4.Size *= v7
							clone4.Position = v8 + Vector3.new(v11, math.random(0, 10), v12)
							local HSV, v14, _ = raycastResult.Instance.Color:ToHSV()
							clone4.Color = Color3.fromHSV(HSV, v14, 0.45)
							clone4.Parent = model
							clone4.CFrame = CFrame.new(clone4.Position, v8)
							TweenService:Create(
								clone4,
								TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									Size = clone4.Size * 2
								}
							):Play()
							local folder = clone4
							task.delay(1, function()
								TweenService:Create(
									folder,
									TweenInfo.new(
										1.5 + math.random() * 0.5,
										Enum.EasingStyle.Back,
										Enum.EasingDirection.In
									),
									{
										Size = folder.Size * 0
									}
								):Play()

								for i2, emitter in pairs(folder:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v15 = emitter
									task.spawn(function()
										v15.Color = ColorSequence.new(
											raycastResult.Instance.Color,
											raycastResult.Instance.Color
										)
										v15:Emit(v15:GetAttribute("EmitCount"))
									end)
								end
							end)
						end
					end)
					task.spawn(function()
						local v8 = cframe.Position + createVector(0, -10, 0)
						local v9 = 70 * v7

						for i = 1, 15 do
							local v10 = i / 15
							local v11 = v10 * 3.141592653589793 * 2
							local v12 = v9 + i * 2
							local v13 = math.cos(v11) * v12
							local v14 = math.sin(v11) * v12
							local v16 = math.random(1, 3)
							local clone4 = objectExplosion.Phase1.Clouds["MeshPart" .. v16]:Clone()
							local HSV, v17, _ = raycastResult.Instance.Color:ToHSV()
							clone4.Color = Color3.fromHSV(HSV, v17, math.random(35, 50) / 100)
							clone4.Size = clone4.Size * 0.35 * v7
							clone4.Transparency = 1
							clone4.Parent = model
							local v18 = (v10 * 1 + 1) * (0.6 + math.random() * 0.4)
							local size2 = clone4.Size * v18
							clone4.Size = size2
							clone4.Position = v8 + Vector3.new(v13, i * 10, v14)
							clone4.CFrame = CFrame.new(clone4.Position, v8)
							local tween = TweenService:Create(
								clone4,
								TweenInfo.new(
									0.6 + math.random() * 0.4,
									Enum.EasingStyle.Back,
									Enum.EasingDirection.Out
								),
								{
									Size = size2 * 2,
									Transparency = 0,
									CFrame = clone4.CFrame * CFrame.Angles(
										(math.random() - 0.5) * 0.2,
										(math.random() - 0.5) * 0.2,
										(math.random() - 0.5) * 0.2
									) + Vector3.new(v13, 0, v14).Unit * size2.Magnitude / 4
								}
							)
							tween:Play()

							for _, emitter in pairs(clone4:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								emitter.Enabled = true
								emitter.Color = ColorSequence.new(
									raycastResult.Instance.Color,
									raycastResult.Instance.Color
								)
							end

							local folder = clone4
							task.spawn(function()
								tween.Completed:Wait()
								TweenService:Create(
									folder,
									TweenInfo.new(
										1.2 + math.random() * 0.8,
										Enum.EasingStyle.Back,
										Enum.EasingDirection.In
									),
									{
										Size = size2 * 0,
										Transparency = 1,
										CFrame = folder.CFrame * CFrame.Angles(
											(math.random() - 0.5) * 0.2,
											(math.random() - 0.5) * 0.2,
											(math.random() - 0.5) * 0.2
										) + Vector3.new(v13, 0, v14).Unit * size2.Magnitude / 2
									}
								):Play()
								task.wait(1)

								for i2, emitter in pairs(folder:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v24 = emitter
									task.spawn(function()
										v24.Enabled = false
										v24:Emit(v24:GetAttribute("EmitCount"))
									end)
								end
							end)
							RunService.Heartbeat:Wait()
						end
					end)
					local clone4 = objectExplosion.Phase1.GroundCrack2:Clone()
					clone4.CFrame = cframe
					Util.SetParentOverrideWithColor(clone4, model, data.Player, "ControlFruitVFXColor")
					local v8 = cframe.Position + createVector(0, -10, 0)
					local v9 = 70 * v7

					for i = 1, 10 do
						local v10 = i / 10 * 3.141592653589793 * 2
						local v11 = math.cos(v10) * v9
						local v12 = math.sin(v10) * v9
						local clone5 = clone4.Impact1:Clone()
						Util.ResizeModel(clone5, v7, clone5.Position)
						clone5.Anchored = true
						clone5.WeldConstraint.Enabled = false
						clone5.Position = v8 + Vector3.new(v11, math.random(0, 50), v12)
						clone5.Parent = model
						clone5.CFrame = CFrame.new(clone5.Position, v8) * CFrame.Angles(
							math.rad(35 + math.random(-10, 20)),
							0,
							(math.rad(5 + math.random(-10, 10) / 3))
						)
						local v13 = math.random(1, #clone4.Impact1.Attach1:GetChildren())

						for _, beam in pairs(clone5:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							if beam.Name == "Beam" .. v13 then
								beam.Brightness = math.random(5, 7) / 2
								beam.LightEmission = math.random(5, 8) / 10
								beam.Enabled = true
								TweenService:Create(beam, TweenInfo.new(0.05), {
									Width0 = beam.Width0 + math.random(-5, 35) / 100,
									Width1 = beam.Width1 + math.random(-5, 55) / 1
								}):Play()
								local v14 = beam
								task.delay(0.025, function()
									TweenService:Create(v14, TweenInfo.new(0.05), {
										Width0 = v14.Width0 + 0.17,
										Width1 = v14.Width1 + 0.17
									}):Play()
									task.wait(0.035 * math.random())

									for i2 = 90, 100 do
										v14.Transparency = NumberSequence.new(i2 / 100, i2 / 100)
										task.wait(0.0015)
									end
								end)
							else
								beam:Destroy()
							end
						end

						local tween = TweenService:Create(clone5.Attach1, TweenInfo.new(0.1 + math.random() * 0.05), {
							Position = clone5.Attach1.Position + Vector3.new(0, math.random(25, 100), 0)
						})
						clone5.Attach1.Position = createVector(0, 0, 0)
						tween:Play()
					end

					clone4.Impact1:Destroy()
					local clone5 = objectExplosion.Phase1.GroundCrack:Clone()
					Util.ResizeModel(clone5, v7, clone5.Position)
					clone5.CFrame = cframe
					Util.SetParentOverrideWithColor(clone5, model, data.Player, "ControlFruitVFXColor")

					for _, emitter in pairs(clone5:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v10 = emitter
						task.spawn(function()
							if v10:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v10:GetAttribute("EmitDelay"))
							end

							if v10.Parent.Name == "Impact2" then
								v10.Color = ColorSequence.new(
									raycastResult.Instance.Color,
									raycastResult.Instance.Color
								)
							end

							v10:Emit(v10:GetAttribute("EmitCount"))
						end)
					end

					local clone6 = objectExplosion.Phase1.GroundCrack3:Clone()
					Util.ResizeModel(clone6, v7, clone6.Position)
					clone6.CFrame = cframe
					Util.SetParentOverrideWithColor(clone6, model, data.Player, "ControlFruitVFXColor")

					for _, emitter in pairs(clone6:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v10 = emitter
						task.spawn(function()
							if v10:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v10:GetAttribute("EmitDelay"))
							end

							if v10.Parent.Name == "Impact2" then
								v10.Color = ColorSequence.new(
									raycastResult.Instance.Color,
									raycastResult.Instance.Color
								)
							end

							v10:Emit(v10:GetAttribute("EmitCount"))
						end)
					end

					task.spawn(function()
						for _ = 1, 5 do
							task.spawn(function()
								local clone7 = objectExplosion.Phase1.SmallTrailModel:Clone()
								local primaryPart = clone7.PrimaryPart
								clone7:ScaleTo(math.random(10, 35) / 10 * (1 + (v7 - 1) * 0.5))
								primaryPart.CFrame = cframe * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
								Util.SetParentOverrideWithColor(clone7, model, data.Player, "ControlFruitVFXColor")
								rocks:ApplyCollision(primaryPart, nil, true)
								primaryPart.CFrame = primaryPart.CFrame * CFrame.new(0, 0, -math.random(45, 70)) * CFrame.Angles(
									0,
									0,
									(math.rad(math.random(-180, 180) / 15))
								) * CFrame.Angles(math.rad(math.random(35, 50) * 1.75), 0, 0)
								primaryPart.Anchored = false

								for _, effect in pairs(primaryPart:GetDescendants()) do
									if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
										continue
									end

									effect.Enabled = true
									effect.Color = ColorSequence.new(
										raycastResult.Instance.Color,
										raycastResult.Instance.Color
									)
								end

								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
								bodyVelocity.P = 5000
								bodyVelocity.Parent = primaryPart
								local v10 = v7 * math.random(500, 1150) / 1.1
								task.delay(math.random(10, 30) / 150, function()
									bodyVelocity.Velocity = primaryPart.CFrame.LookVector * v10 / 5
									task.wait()
									bodyVelocity:Destroy()
									task.wait(0.35)
									primaryPart.CanCollide = true
								end)
								bodyVelocity.Velocity = primaryPart.CFrame.LookVector * v10
								task.wait(1)

								for _, effect in pairs(primaryPart:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end
							end)
						end
					end)
					task.spawn(function()
						for _ = 1, 5 do
							task.spawn(function()
								local clone7 = objectExplosion.Phase1.ProjectileModel:Clone()
								local primaryPart = clone7.PrimaryPart
								clone7:ScaleTo(math.random(10, 30) / 10 * (1 + (v7 - 1) * 0.5))
								primaryPart.CFrame = cframe * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
								Util.SetParentOverrideWithColor(clone7, model, data.Player, "ControlFruitVFXColor")
								rocks:ApplyCollision(primaryPart, nil, true)
								primaryPart.CFrame = primaryPart.CFrame * CFrame.new(
									0,
									math.random(1, 25),
									-math.random(35, 60)
								) * CFrame.Angles(0, 0, (math.rad(math.random(-180, 180) / 15))) * CFrame.Angles(
									math.rad(math.random(35, 80) * 1.5),
									0,
									0
								)
								primaryPart.Anchored = false

								for _, effect in pairs(primaryPart:GetDescendants()) do
									if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
										continue
									end

									effect.Enabled = true
									effect.Color = ColorSequence.new(
										raycastResult.Instance.Color,
										raycastResult.Instance.Color
									)
								end

								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
								bodyVelocity.P = 5000
								bodyVelocity.Parent = primaryPart
								local v10 = v7 * math.random(200, 300) / 1.05
								task.delay(math.random(10, 30) / 200, function()
									bodyVelocity:Destroy()
									task.wait(0.25)
									primaryPart.CanCollide = true
								end)
								bodyVelocity.Velocity = primaryPart.CFrame.LookVector * v10
								task.wait(0.5 + math.random() * 0.35)

								for _, effect in pairs(primaryPart:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end
							end)
						end
					end)
					task.spawn(function()
						local v10 = cframe

						for _ = 1, 5 do
							local clone7 = objectExplosion.Phase1.SpinTrailModel:Clone()
							clone7.PrimaryPart.CFrame = v10 * CFrame.new(0, -10, 0) * CFrame.Angles(
								0,
								math.rad((math.random(-180, 180))),
								0
							)
							clone7:ScaleTo(25 * v7)
							Util.SetParentOverrideWithColor(clone7, model, data.Player, "ControlFruitVFXColor")

							for _, effect in pairs(clone7:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
									continue
								end

								effect.Enabled = true
								effect.Color = ColorSequence.new(
									raycastResult.Instance.Color,
									raycastResult.Instance.Color
								)
							end

							local v11 = math.random(3, 5)
							local v12 = math.random(10, 15) * 10
							clone7.PrimaryPart.Attach0.Position = Vector3.new(-v11, 0, -v12)
							clone7.PrimaryPart.Attach1.Position = Vector3.new(v11, 0, -v12)
							local v13 = 0.15 + math.random(-15, 15) / 100
							TweenService:Create(
								clone7.PrimaryPart.Attach0,
								TweenInfo.new(v13 * 5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									Position = Vector3.new(-v11 / 2, 0, -v12 / 2)
								}
							):Play()
							TweenService:Create(
								clone7.PrimaryPart.Attach1,
								TweenInfo.new(v13 * 5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									Position = Vector3.new(v11 / 2, 0, -v12 / 2)
								}
							):Play()
							local folder = clone7
							local v16 = math.random(35, 50) * 0.85
							task.spawn(function()
								local v17 = math.random(8, 35) / 2

								for i = 1, 10 do
									local tween = TweenService:Create(
										folder.PrimaryPart,
										TweenInfo.new(v13 / 5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
										{
											CFrame = folder.PrimaryPart.CFrame * CFrame.new(0, v17, 0) * CFrame.Angles(
												0,
												math.rad(v16),
												0
											)
										}
									)
									tween:Play()
									tween.Completed:Wait()
								end

								for i, effect in pairs(folder:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end
							end)
						end
					end)

					local function FlyRock(cFrame2, raycastResult2, model2)
						local clone7 = objectExplosion.Phase1.Rock:Clone()
						clone7.CFrame = cFrame2
						clone7.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
						clone7.Size = clone7.Size * math.random(1, 3) * (1 + (v7 - 1) * 0.5)
						clone7.Orientation = Vector3.new(
							math.random(-90, 90),
							math.random(-90, 90),
							math.random(-90, 90)
						)
						clone7.Material = raycastResult2.Instance.Material
						clone7.Color = raycastResult2.Instance.Color
						clone7.CanCollide = false
						clone7.Parent = model2
						rocks:ApplyCollision(clone7, nil, true)
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
						bodyVelocity.P = 10000
						bodyVelocity.Parent = clone7
						local vector2 = Vector3.new(math.random(-30, 30) * 2, 0, math.random(-30, 30) * 2)
						local vector3 = Vector3.new(0, math.random(150, 200) / 1.5, 0)
						local v10 = math.random(250, 400) / 1.75 * v7
						bodyVelocity.Velocity = CFrame.new(clone7.Position, clone7.Position + vector2 + vector3).LookVector * v10
						task.delay(1 * math.random() + 0.5, function()
							TweenService:Create(
								clone7,
								TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
								{
									Size = createVector(0, 0, 0)
								}
							):Play()
						end)
						task.delay(0.075 * math.random() + 0.025, function()
							bodyVelocity:Destroy()
							task.wait(0.1)
							clone7.CanCollide = true
						end)
					end

					for _ = 1, 10 do
						task.spawn(function()
							FlyRock(
								cframe * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
									0,
									0,
									-math.random(125, 150) / 100
								),
								raycastResult,
								model
							)
						end)
					end
				end)
			end
		end

		Rocks:CircleRocks(
			cFrame.Position,
			math.floor(v3 * 2) + 4,
			v5 * 0.75,
			createVector(8.5, 2.25, 3.5) * (0.7 + v3 * 0.1),
			0,
			{ workspace.Terrain }
		)
		Rocks:CircleRocks(
			cFrame.Position,
			v4 + 3,
			v5 * 0.9,
			createVector(6.5, 2.5, 6.5) * (0.7 + v3 * 0.1),
			0,
			{ workspace.Terrain }
		)
		Rocks:CircleRocks(
			cFrame.Position,
			v4 + 2,
			v5 * 1.1,
			createVector(6.5, 2.5, 5) * (0.9 + v3 * 0.1),
			0,
			{ workspace.Terrain }
		)

		for _ = 1, 8 do
			local cframe = CFrame.lookAt(
				cFrame * CFrame.Angles(
					math.rad((random:NextNumber(-90, 90))),
					0,
					(math.rad((random:NextNumber(-90, 90))))
				) * CFrame.new(0, v5 * random:NextNumber(0.5, 0.7), 0).Position,
				position
			)
			local clone4 = M1.Rock:Clone()
			clone4.Color = color
			clone4.Size = createVector(4.6, 1.15, 3.2) * v4 * random:NextNumber(0.7, 1.4)
			clone4.CFrame = cframe * CFrame.Angles(1.5707963267948966, 1.5707963267948966, 0)
			local v7

			if energized then
				for k, v8 in { M1.GradientRock, M1.OutlineRock } do
					local clone5 = v8:Clone()
					clone5.Name = string.sub(clone5.Name, 1, #clone5.Name - 4)
					clone5.CFrame = clone4.CFrame
					clone5.Weld.Part1 = clone4
					clone5.Mesh.Scale = clone4.Size / clone4.MeshSize * (k == 1 and 1.007 or 1.0235)
					clone5.Parent = clone4
				end

				v7 = NewBolt(attachment, Instance.new("Attachment", clone4))
			else
				v7 = nil
			end

			clone4.Parent = workspace._WorldOrigin
			clone4.AssemblyLinearVelocity = (cframe.LookVector - createVector(0, 0.6, 0)) * -math.random(60, 80)
			clone4.AssemblyAngularVelocity += Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)) * 0.45
			task.delay(0.4, function()
				local number = random:NextNumber(2.5, 3.5)

				for k, part in {
					clone4,
					energized and clone4.Gradient.Mesh or nil,
					energized and clone4.Outline.Mesh or nil
				} do
					local scope = VisualHelper
					scope:Tween(part, TweenInfo.new(number, Enum.EasingStyle.Sine), {
						[part:IsA("MeshPart") and "Size" or "Scale"] = createVector(0, 0, 0)
					})
				end

				local v9

				if energized then
					v9 = task.wait(math.random() * 0.5)
					v7:Destroy()
				else
					v9 = 0
				end

				task.wait(number - v9)
				clone4:Destroy()
			end)
		end

		local meshs = clone.Meshs
		local airMeshHuge = meshs.AirMeshHuge
		local airMeshStorm = meshs.AirMeshStorm
		local superFlash = meshs.SuperFlash
		local flash = meshs.Flash
		local bodyFlash = meshs.BodyFlash
		local circleWave = meshs.CircleWave
		VisualHelper:Tween(airMeshHuge.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Scale = airMeshHuge.Mesh.Scale * createVector(2, 1.25, 2)
		})
		VisualHelper:Tween(airMeshHuge.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		Util.Debris:AddItem(airMeshHuge, 1)
		VisualHelper:Tween(airMeshStorm.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
			Scale = airMeshStorm.Mesh.Scale * createVector(3, 1, 3)
		})
		VisualHelper:Tween(airMeshStorm.Decal, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(airMeshStorm, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
			CFrame = airMeshStorm.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		})
		Util.Debris:AddItem(airMeshStorm, 1)
		VisualHelper:Tween(flash.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(flash.Mesh, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Scale = flash.Mesh.Scale * createVector(2.35, 1, 2.35)
		})
		Util.Debris:AddItem(flash, 1)
		VisualHelper:Tween(bodyFlash.Decal, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(bodyFlash.Mesh, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Scale = bodyFlash.Mesh.Scale * createVector(3, 1.8, 3)
		})
		Util.Debris:AddItem(bodyFlash, 1)
		local scale = superFlash.Mesh.Scale * 2.25
		superFlash.Mesh.Scale /= 2
		VisualHelper:Tween(superFlash.Decal, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
			Transparency = 1
		})
		VisualHelper:Tween(superFlash.Mesh, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
			Scale = scale
		})
		Util.Debris:AddItem(superFlash, 1)
		local size = circleWave.Size
		circleWave.Size = size * 0.7
		VisualHelper:Tween(circleWave, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			CFrame = circleWave.CFrame * CFrame.new(0, v4 * 1.5, 0),
			Transparency = 1,
			Size = size
		})

		for i = 1, 3 do
			local v8 = cFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
				0,
				1,
				-math.random(v5 + 5, v5 + 25)
			)
			local rayCast = MathHelper:RayCast(
				v8.Position,
				v8.UpVector * -10,
				{ workspace.Map },
				Enum.RaycastFilterType.Include
			)

			if rayCast then
				local clone4 = c_Katsuo.BoltExplosion:Clone()
				clone4.CFrame = CFrame.new(rayCast.Position + createVector(0, 0.05, 0))
				Util.SetParentOverrideWithColor(clone4, workspace._WorldOrigin, data.Player, "ControlFruitVFXColor")
				VisualHelper:EmitAll(clone4)
				Util.Debris:AddItem(clone4, 1)
			end

			if i == 2 and energized then
				VisualHelper:EmitAll(energized2)
			end

			if i == 3 then
				break
			else
				task.wait(0.125)
			end
		end

		clone.Main.Center.Hold.SmokeToggle.Enabled = false

		if not energized then
			return
		end

		local clone4 = c_Katsuo.BallNeon:Clone()
		clone4.CFrame = cFrame
		clone4.Transparency = 0.95
		local player3 = data.Player
		local color4 = Color3.fromRGB(65, 116, 255)

		if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
			color4 = Util.WrapColor3Constructor(color4, player3, "ControlFruitVFXColor")
		end

		clone4.Color = color4
		clone4.Size = createVector(1, 1, 1) * clone.Main.Size.Y
		clone4.Parent = workspace._WorldOrigin
		VisualHelper:Tween(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Size = clone.Main.Size * 1.6,
			Transparency = 1
		})
		Util.Debris:AddItem(clone4, 0.15)
		local beams2 = energized2.Beams
		VisualHelper:Tween(beams2, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = beams2.Orientation + createVector(0, 360, 0)
		})

		for _, beam in beams2:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			VisualHelper:Tween(beam, TweenInfo.new(0.1 + math.random(3) * 0.025, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		VisualHelper:EmitAll(energized2)
		Util.Debris:AddItem(energized2, 2)
		task.wait(0.15)

		for _, child in clone.Main.EnergizedFloor:GetChildren() do
			child.Enabled = false
			child.TimeScale = 0.2
		end
	end
end