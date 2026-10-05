local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Dragon2").Transformed.X.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local cameraShaker = Util.CameraShaker
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).Magnitude <= p2 then
			callback()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function numLoop(p, p2, value, fn, value2)
	local v = (p2 - p) / (value or 1)
	local lastTime = tick()
	local v2 = value2 or 60

	while tick() - lastTime < (1 + v) * 1 / v2 do
		local v3 = p + (tick() - lastTime) * v
		fn(v3)

		if p2 < v3 then
			break
		else
			task.wait(1 / v2)
		end
	end

	fn(p2)
end

local function ClawSlash(cFrame, folder, player)
	for i = 1, 6 do
		local v = i
		task.spawn(function()
			local clone = assets.Phase1.SlashModel:Clone()
			clone.PrimaryPart.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")

			if v == 1 then
				clone.PrimaryPart.CFrame = clone.PrimaryPart.CFrame * CFrame.new(-25, 0, 0) * CFrame.Angles(
					0,
					0,
					-0.2617993877991494
				)
			elseif v == 2 then
				clone.PrimaryPart.CFrame = clone.PrimaryPart.CFrame * CFrame.new(25, 0, 0) * CFrame.Angles(
					0,
					0,
					-0.4363323129985824
				)
			elseif v == 3 then
				clone.PrimaryPart.CFrame = clone.PrimaryPart.CFrame * CFrame.new(75, -25, 0) * CFrame.Angles(
					0,
					0,
					-0.5235987755982988
				)
			elseif v == 4 then
				clone.PrimaryPart.CFrame = clone.PrimaryPart.CFrame * CFrame.new(25, 0, 0) * CFrame.Angles(
					0,
					0,
					0.2617993877991494
				)
			elseif v == 5 then
				clone.PrimaryPart.CFrame = clone.PrimaryPart.CFrame * CFrame.new(-25, 0, 0) * CFrame.Angles(
					0,
					0,
					0.4363323129985824
				)
			elseif v == 6 then
				clone.PrimaryPart.CFrame = clone.PrimaryPart.CFrame * CFrame.new(-75, -25, 0) * CFrame.Angles(
					0,
					0,
					0.5235987755982988
				)
			end

			clone.PrimaryPart.CFrame = clone.PrimaryPart.CFrame * CFrame.Angles(2.6179938779914944, 0, 0)
			task.spawn(function()
				task.spawn(function()
					numLoop(100, 150, 5, function(p)
						clone:ScaleTo(p / 100)
					end)
				end)
				task.wait(0.25)

				for i2, beam in pairs(clone:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local v2 = beam:GetAttribute("EndDelay") / 2
					local tween = TweenService:Create(
						beam,
						TweenInfo.new(v2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween:Play()
					local v4 = beam
					task.spawn(function()
						tween.Completed:Wait()
						v4:Destroy()
					end)
				end
			end)
			task.spawn(function()
				local v2 = 0.125 * math.random() + 0.1

				for i2 = 1, 3 do
					local tween = TweenService:Create(
						clone.PrimaryPart,
						TweenInfo.new(v2 / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = clone.PrimaryPart.CFrame * CFrame.Angles(-1.2217304763960306, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end

				local tween = TweenService:Create(
					clone.PrimaryPart,
					TweenInfo.new(v2 * 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone.PrimaryPart.CFrame * CFrame.Angles(-0.6108652381980153, 0, 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end)
		end)
	end
end

local function Curve(clone, position, p, p2)
	local position2 = clone.Position
	local magnitude = (position2 - position).Magnitude
	clone.CFrame = CFrame.new(position2, position)
	local v = (position2 - position) / 2
	local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
	local v2 = position3 + Vector3.new(math.random(-p2, p2), math.random(-p2, p2), math.random(-p2, p2))
	local v3 = position4 + Vector3.new(math.random(-p2, p2), math.random(-p2, p2), math.random(-p2, p2))
	local lastTime = tick()
	local v4 = magnitude / p / 60

	while tick() - lastTime < v4 do
		local v5 = (tick() - lastTime) / v4
		local v6 = cubicBezier(v5, position2, v2, v3, position)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v6, position), v5)
		RunService.Heartbeat:Wait()
	end
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
return function(data)
	local player = data.Player
	local root = data.Root
	local endPosition = data.EndPosition
	local cframe = CFrame.lookAt(root.Position, endPosition) * CFrame.new(0, 25, -25)

	if (cframe.p - workspace.CurrentCamera.CFrame.p).Magnitude > 1500 then
		return
	end

	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DragonFruitVFXColor")
	Util.Debris:AddItem(folder, 15)
	local clone = assets.Phase1.StartImpact:Clone()
	clone.CFrame = cframe * CFrame.new(0, 0, -5)
	Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
	Util.Sound:Play("BF_WD_Western_X_Aerial_01", root.Position)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		task.spawn(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)
	end

	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
	ClawSlash(cframe, folder, player)
	local position = cframe.Position
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= 250 then
			cameraShaker:ShakeOnce(10, 7, 0.15, 0.75)
		end
	end

	if game.Players.LocalPlayer == player then
		task.spawn(function()
			local currentCamera = workspace.CurrentCamera
			TweenService:Create(
				currentCamera,
				TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					FieldOfView = 95
				}
			):Play()
			task.wait(0.15)
			TweenService:Create(currentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				FieldOfView = 70
			}):Play()
		end)
	end

	task.wait(0.115)

	local function FlyRock(cFrame, raycastResult, folder2)
		local clone2 = assets.Phase3.Rock:Clone()
		clone2.CanCollide = true
		rocks:ApplyCollision(clone2, nil, true)
		clone2.CFrame = cFrame
		clone2.Size += Vector3.new(0, math.random(0, 1), 0)
		clone2.Size = clone2.Size * math.random(1, 3) * 2
		clone2.Position = raycastResult.Position
		clone2.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
		clone2.Material = raycastResult.Instance.Material
		clone2.Color = raycastResult.Instance.Color
		Util.SetParentOverrideWithColor(clone2, folder2, player, "DragonFruitVFXColor")
		clone2.Color = raycastResult.Instance.Color
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
		bodyVelocity.P = 3000
		Util.SetParentOverrideWithColor(bodyVelocity, clone2, player, "DragonFruitVFXColor")
		local vector2 = Vector3.new(math.random(-30, 30) * 2, 0, math.random(-30, 30) * 2)
		local vector3 = Vector3.new(0, math.random(150, 200) / 1.25, 0)
		local v = math.random(120, 250) * 1.75
		bodyVelocity.Velocity = CFrame.new(clone2.Position, clone2.Position + vector2 + vector3).LookVector * v
		task.delay(1 * math.random() + 2.5, function()
			TweenService:Create(
				clone2,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
				{
					Size = createVector(0, 0, 0)
				}
			):Play()
		end)
		task.delay(0.025 * math.random() + 0.05, function()
			bodyVelocity:Destroy()
		end)
	end

	local v = cframe * CFrame.new(0, 0, -50)
	local v2 = math.min(300, (endPosition - v.p).Magnitude)
	local clone2 = assets.Phase2.ProjectileModel:Clone()
	clone2:SetPrimaryPartCFrame(v)
	Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
	local v3 = false

	for _, child in pairs(clone2:GetChildren()) do
		if child == clone2.PrimaryPart then
			continue
		end

		local folder2 = child
		task.spawn(function()
			local primaryPart = folder2.PrimaryPart

			for i, emitter in pairs(folder2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emitter:Emit(1)
			end

			local clone3 = assets.Phase2.Aura:Clone()
			clone3.CFrame = folder2.AuraPoint.CFrame
			Util.SetParentOverrideWithColor(clone3, folder2.AuraPoint, player, "DragonFruitVFXColor")
			clone3.Anchored = false
			clone3.Massless = true
			clone3.Weld.Part1 = folder2.AuraPoint
			task.spawn(function()
				numLoop(150, 200, 2.5, function(p)
					folder2:ScaleTo(p / 100)
				end)
			end)
			local orientation, v4, v5 = cframe:ToOrientation()
			local v6 = math.deg(v4)
			local v7 = v2
			local cFrame = CFrame.new(primaryPart.Position, primaryPart.Position + cframe.LookVector) * CFrame.new(
				0,
				0,
				-v7
			)
			task.spawn(function()
				local v9 = cFrame * CFrame.new(math.random(-100, 100), 0, -100).Position

				for i = 1, 3 do
					task.spawn(function()
						local clone4 = assets.Phase2.StarTrail:Clone()
						clone4.CFrame = clone3.CFrame
						Util.SetParentOverrideWithColor(clone4, folder, player, "DragonFruitVFXColor")

						for i2, emitter in pairs(clone4:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") or folder2:IsA("Trail") then
								emitter.Enabled = true
							end
						end

						local v10 = 150 * math.random(10, 20) / 5
						Curve(clone4, v9, math.random(7, 10) * 1.25, v10)

						for i2, emitter in pairs(clone4:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") or folder2:IsA("Trail") then
								emitter.Enabled = false
							end
						end
					end)
				end
			end)
			local v9 = false
			task.spawn(function()
				local clone4 = assets.Phase3.Spark:Clone()
				clone4.CFrame = cframe
				Util.SetParentOverrideWithColor(clone4, folder, player, "DragonFruitVFXColor")

				for i, effect in pairs(clone4:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				local effects = {}
				local v10 = false

				for i, effect in pairs(clone4:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						table.insert(effects, effect)
					end
				end

				local now = tick()
				local total = 0.5

				while true do
					local cFrame2 = clone3.CFrame * CFrame.new(0, 50, 0)
					local raycastResult = workspace:Raycast(
						cFrame2.Position,
						CFrame.new(cFrame2.Position).UpVector * -150,
						raycastParams
					)

					if raycastResult and raycastResult.Instance and raycastResult.Instance.Name == "WaterBase-Plane" then
						raycastResult = nil
					end

					if raycastResult then
						clone4.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05
						clone4.CFrame = CFrame.new(clone4.Position, clone4.Position + cframe.LookVector)
						clone4.Orientation = Vector3.new(0, clone4.Orientation.Y, clone4.Orientation.Z)

						if v10 == false then
							v10 = true

							for k, v12 in pairs(effects) do
								v12.Enabled = true
							end
						end

						if not v3 then
							v3 = true
							Util.Sound:Play("BF_Western_X_GroundDebris_01_V2", clone2.PrimaryPart.Position)
						end

						local cFrame3 = cFrame2
						task.spawn(function()
							FlyRock(cFrame3, raycastResult, folder)
						end)

						if folder2:GetAttribute("R") or folder2:GetAttribute("L") then
							if now - tick() <= 0 then
								now = tick() + 0.15
								local clone5 = assets.Phase3.GroundBurnModel:Clone()
								clone5:ScaleTo(math.random(10, 20) / 10)
								local primaryPart2 = clone5.PrimaryPart
								primaryPart2.CFrame = clone4.CFrame * CFrame.new(
									math.random(-25, 25),
									0,
									math.random(-150, -10)
								)
								Util.SetParentOverrideWithColor(clone5, folder, player, "DragonFruitVFXColor")

								for i, emitter in pairs(primaryPart2:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									emitter.Enabled = true
									local v13 = emitter
									task.delay(0.5, function()
										v13.Enabled = false
									end)
								end
							end

							task.spawn(function()
								for i = 1, 5 do
									local clone5 = assets.Phase3.Rock:Clone()

									if folder2:GetAttribute("R") then
										clone5.CFrame = CFrame.new(clone4.Position, clone4.Position + cframe.LookVector) * CFrame.new(
											total * 35,
											0,
											-i * 15
										)
									else
										clone5.CFrame = CFrame.new(clone4.Position, clone4.Position + cframe.LookVector) * CFrame.new(
											total * -35,
											0,
											-i * 15
										)
									end

									clone5.CanCollide = false
									clone5.Anchored = true
									clone5.Size = Vector3.new(
										math.random(10, 12),
										math.random(10, 12),
										math.random(10, 12)
									)
									clone5.Size = clone5.Size * math.random(2, 3) * total * (1.2 + math.random() * 0.4)
									clone5.Orientation = Vector3.new(
										math.random(-90, 90) / 5,
										math.random(-90, 90) / 5,
										math.random(-90, 90) / 5
									)
									clone5.Material = raycastResult.Instance.Material
									clone5.Color = raycastResult.Instance.Color
									Util.SetParentOverrideWithColor(clone5, folder, player, "DragonFruitVFXColor")
									clone5.Color = raycastResult.Instance.Color
									local tween = TweenService:Create(
										clone5,
										TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
										{
											Size = clone5.Size
										}
									)
									clone5.Size = createVector(0, 0, 0)
									tween:Play()
									task.delay(1 * math.random() + 1.25, function()
										TweenService:Create(
											clone5,
											TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
											{
												Size = createVector(0, 0, 0)
											}
										):Play()
									end)
									task.wait(0.025)
								end
							end)
						end

						if folder2:GetAttribute("R") or folder2:GetAttribute("L") then
							local clone5 = assets.Phase3.SideFlameModel:Clone()
							clone5:ScaleTo(total)
							local primaryPart2 = clone5.PrimaryPart

							if folder2:GetAttribute("R") then
								primaryPart2.CFrame = CFrame.new(clone3.Position, clone3.Position + cframe.LookVector) * CFrame.new(
									70,
									0,
									0
								) * CFrame.Angles(0, 0, -0.5235987755982988)
							else
								primaryPart2.CFrame = CFrame.new(clone3.Position, clone3.Position + cframe.LookVector) * CFrame.new(
									-70,
									0,
									0
								) * CFrame.Angles(0, 0, 0.5235987755982988)
							end

							Util.SetParentOverrideWithColor(clone5, folder, player, "DragonFruitVFXColor")

							for i, emitter in pairs(primaryPart2:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								emitter.Enabled = true
								local v13 = emitter
								task.delay(0.5, function()
									v13.Enabled = false
								end)
							end
						end
					elseif v10 == true then
						v10 = false

						for k, v12 in pairs(effects) do
							v12.Enabled = false
						end
					end

					total += 0.1
					task.wait(0.1)

					if v9 ~= true then
						continue
					end

					for i, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					break
				end
			end)
			cFrame *= CFrame.fromOrientation(
				math.rad(primaryPart.Orientation.X),
				math.rad(primaryPart.Orientation.Y - v6),
				(math.rad(primaryPart.Orientation.Z))
			)
			cFrame *= CFrame.Angles(
				math.rad(math.random(-10, 10) / 10),
				math.rad(math.random(-10, 10) / 10),
				(math.rad(math.random(-10, 10) / 10))
			)
			local v10 = v7 / v2 * 0.5
			local tween = TweenService:Create(
				primaryPart,
				TweenInfo.new(v10, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = cFrame
				}
			)
			tween:Play()
			task.spawn(function()
				local C0 = folder2.Beam.Motor6D.C0

				repeat
					folder2.Beam.Motor6D.C0 = C0 * CFrame.Angles(
						math.rad(math.random(-15, 15) / 5),
						math.rad(math.random(-15, 15) / 5),
						(math.rad(math.random(-15, 15) / 5))
					)
					task.wait(0.01)
				until v9 == true
			end)
			tween.Completed:Wait()
			v9 = true

			for i, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("Beam") then
					local v11 = effect:GetAttribute("EndDelay") / 2
					local tween2 = TweenService:Create(
						effect,
						TweenInfo.new(v11, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween2:Play()
					local v13 = effect
					task.spawn(function()
						tween2.Completed:Wait()
						v13:Destroy()
					end)
				elseif effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end

			local clone4 = assets.Phase3.EndAura:Clone()
			clone4.CFrame = clone3.CFrame
			Util.SetParentOverrideWithColor(clone4, folder, player, "DragonFruitVFXColor")

			for i, emitter in pairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v11 = emitter
				task.spawn(function()
					if v11:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v11:GetAttribute("EmitDelay"))
					end

					v11:Emit(v11:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown
		end)
	end
end