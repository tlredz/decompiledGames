local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local F = FX:WaitForChild("EasternDragon").F
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")

if not F:GetAttribute("ScaledUp") then
	F:SetAttribute("ScaledUp", true)

	for _, child in pairs(F:GetChildren()) do
		local v = child.Name == "Phase3" and 2.5 or 2
		local v2 = child.Name == "Phase2" and 1.75 or v

		if child:IsA("Folder") then
			for _, part in pairs(child:GetChildren()) do
				if part:IsA("BasePart") then
					Util.ResizeModel(part, v2, part.Position)
				end
			end
		elseif child:IsA("BasePart") then
			Util.ResizeModel(child, v2, child.Position)
		end
	end
end

local Util2 = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util2.Sound
local destroyAfter = Util2.DestroyAfter
local heartbeatLoopFor = Util2.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util2.LightningBolt
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

-- equivalent calls inferred from this helper; original call sites unknown
local function cameraShakeAt(position: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 100) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
		Util2.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

local function mockRootPart(_, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	destroyAfter(part, 14)
	return part
end

return function(data)
	local player = data.player

	if data.hrp == nil or data.hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = data.hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (data.hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	local v

	if data.collision == true then
		if localPlayer == player then
			local _ = data.hrp
			local cFrame = data.dragonCF.DragonCFrameWithoutOffsetClient.Value
			local part = Instance.new("Part")
			part.Name = "Mock" .. part.Name
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Transparency = 1
			part.CFrame = cFrame
			part.Parent = _WorldOrigin
			destroyAfter(part, 14)
			v = part
			heartbeatLoopFor2(3, function()
				v.CFrame = data.dragonCF.DragonCFrameWithoutOffsetClient.Value
			end)
		else
			local _ = data.hrp
			local cFrame = data.dragonCF.Value
			local part = Instance.new("Part")
			part.Name = "Mock" .. part.Name
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Transparency = 1
			part.CFrame = cFrame
			part.Parent = _WorldOrigin
			destroyAfter(part, 14)
			v = part
			heartbeatLoopFor2(3, function()
				v.CFrame = data.dragonCF.Value
			end)
		end
	else
		local _ = data.hrp
		local dragonCF = data.dragonCF
		local part = Instance.new("Part")
		part.Name = "Mock" .. part.Name
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 1
		part.CFrame = dragonCF
		part.Parent = _WorldOrigin
		destroyAfter(part, 14)
		v = part
		heartbeatLoopFor2(3, function()
			v.CFrame = data.dragonCF
		end)
	end

	local v2 = F

	local function AlignCFrame(data2, p)
		local v3 = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
		local p2 = data2.p
		local unit = data2.LookVector:Cross(v3).Unit
		local unit2 = (unit.Magnitude > 0.001 and unit or data2.RightVector).Unit
		local unit3 = unit2:Cross(v3).Unit
		return CFrame.fromMatrix(p2, unit2, v3, unit3)
	end

	local function viewerIsClose(p, p2, callback)
		local character = localPlayer.Character

		if character ~= nil then
			local rootPart = character:FindFirstChildOfClass("Humanoid").RootPart

			if rootPart and (rootPart.Position - p).Magnitude <= p2 then
				callback()
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DeleteImpactAfterDuration(folder)
		task.spawn(function()
			local v3 = 0

			for _, emitter in ipairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					v3 = math.max(v3, emitter.Lifetime.Max)
				end
			end

			task.wait(v3)
			folder:Destroy()
		end)
	end

	local function GroundImpact(data2)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function RockCrater(result, skillVisuals, data3)
			task.spawn(function()
				local rockType = data3.RockType
				local halfRadius = data3.Radius / 2
				local size = data3.Size
				local duration = data3.Duration
				local amount = data3.Amount
				local v4 = AlignCFrame(CFrame.new(result.Position), result.Normal) + result.Normal * 0.05
				local v5 = {}

				for _ = 1, amount do
					local clone = rockType:Clone()
					Util2.SetParentOverrideWithColor(clone, skillVisuals, player, "DragonFruitVFXColor")
					destroyAfter(clone, 7)
					table.insert(v5, clone)
				end

				task.spawn(function()
					task.wait(duration * 2)

					for _, v6 in pairs(v5) do
						v6:Destroy()
					end

					v5 = nil
				end)
				local v6 = 360 / #v5
				local total = 0

				for _, v7 in pairs(v5) do
					total += v6
					v7.CFrame = v4 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, halfRadius)

					if math.random(1, 3) < 2 then
						v7.CFrame = CFrame.new(v7.Position, result.Position) * CFrame.new(0, 0, 50)
					end

					v7.CFrame = CFrame.new(v7.Position, result.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 3,
						math.random(100, 100)
					)
					local part, v8 = Workspace:FindPartOnRayWithIgnoreList(
						Ray.new(v7.Position + createVector(0, 1, 0), createVector(-0, -20, -0)),
						raycastParams.FilterDescendantsInstances
					)

					if part then
						local v9 = (v7.Position - result.Position).Magnitude / 300
						local v10 = size * math.random(15, 30) / 10
						local v11 = size * math.random(5, 20) / 10
						local v12 = size * math.random(30, 50) / 10
						v7.Size = Vector3.new(v10 * v9, v11 * v9, v12 * v9)
						v7.Position = v8 + Vector3.new(0, -v7.Size.Y * math.random(5, 6) / 15, 0)
						v7.CFrame = CFrame.new(v7.Position, result.Position) * CFrame.new(
							0,
							math.random(-5, 5) / 3,
							math.random(-25, 25)
						)
						v7.CFrame = CFrame.new(
							v7.Position,
							v4.Position + Vector3.new(0, math.random(-55, -45) / 100 + v7.Size.Y / 200, 0)
						) * CFrame.Angles(math.rad(-math.random(10, 15) / 2 - 45 * v9), 0, 0) * CFrame.Angles(
							0,
							0,
							(math.rad((math.random(-5, 5))))
						)
						v7.Material = part.Material
						v7.Color = part.Color
					else
						v7:Destroy()
						v5[v7] = nil
					end

					TweenService:Create(
						v7,
						TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
						{
							Position = v7.Position + Vector3.new(0, v7.Size.Y * math.random(3, 5) / 10, 0)
						}
					):Play()
					local v9 = v7
					local v10 = v7
					task.spawn(function()
						wait(duration + math.random(10, 50) / 100)
						local tween = TweenService:Create(
							v9,
							TweenInfo.new(
								0.5,
								Enum.EasingStyle.Back,
								Enum.EasingDirection.In,
								0,
								false,
								math.random(10, 35) / 100
							),
							{
								Position = v9.Position + Vector3.new(
									math.random(-1, 1),
									-v9.Size.Y * math.random(20, 25) / 10,
									math.random(-1, 1)
								)
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v9:Destroy()
						v5[v9] = nil
					end)
				end
			end)
		end

		local function GroundFlyRocks(result, skillVisuals, data3, fn, fn2)
			local cframe = CFrame.new(result.Position)
			local material = result.Material
			local color = result.Instance.Color
			local rockType = data3.RockType
			local rockAmount = data3.RockAmount
			local rockSize = data3.RockSize
			local positionOffset = data3.PositionOffset
			local rockRotationAmount = data3.RockRotationAmount
			local rockRotationSpeed = data3.RockRotationSpeed
			local rockRotationPower = data3.RockRotationPower
			local duration = data3.Duration

			for _ = 1, rockAmount do
				task.spawn(function()
					task.wait(math.random(0, 10) / 100)
					local clone = rockType:Clone()
					clone.Position = cframe.Position + Vector3.new(
						math.random(-positionOffset, positionOffset),
						math.random(1, positionOffset / 10) + rockSize,
						math.random(-positionOffset, positionOffset)
					)
					clone.Size = createVector(5, 1, 5)
					clone.Size += Vector3.new(0, math.random(0, 5) / 10, 0)
					clone.Size *= math.random(3, 6)
					clone.Material = material
					clone.Color = color
					clone.CanCollide = false
					rocks:ApplyCollision(clone, nil, true)
					task.delay(0.25, function()
						clone.CanCollide = true
					end)
					Util2.SetParentOverrideWithColor(clone, skillVisuals, player, "DragonFruitVFXColor")
					clone.Color = color
					destroyAfter(clone, 7)
					task.spawn(function()
						for _, emitter in ipairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end

						task.wait(duration + math.random(10, 50) / 100)

						for _, emitter in ipairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						TweenService:Create(
							clone,
							TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
							{
								Size = createVector(0, 0, 0)
							}
						):Play()
					end)
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = createVector(1, 1, 1) * 1e999
					bodyVelocity.P = 15000
					Util2.SetParentOverrideWithColor(bodyVelocity, clone, player, "DragonFruitVFXColor")
					destroyAfter(bodyVelocity, 7)
					fn(bodyVelocity, clone)
					clone.Attachment0.Orientation = createVector(0, 0, 0)
					local v3 = math.random(-rockRotationPower, rockRotationPower)
					local v4 = math.random(-rockRotationPower, rockRotationPower)
					local v5 = math.random(-rockRotationPower, rockRotationPower)
					local v6 = v3 / rockRotationAmount
					local v7 = v4 / rockRotationAmount
					local v8 = v5 / rockRotationAmount
					task.spawn(function()
						task.wait(0.05)

						for i = 1, rockRotationAmount do
							if clone:FindFirstChild("Attachment0") == nil then
								return
							end

							v3 = math.clamp(v3 - v6, 0, rockRotationPower * 1.5)
							v4 = math.clamp(v4 - v7, 0, rockRotationPower * 1.5)
							v5 = math.clamp(v5 - v8, 0, rockRotationPower * 1.5)
							local tween = TweenService:Create(
								clone.Attachment0,
								TweenInfo.new(rockRotationSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone.Attachment0.CFrame * CFrame.Angles(
										math.rad(v3),
										math.rad(v4),
										(math.rad(v5))
									)
								}
							)
							tween:Play()
							tween.Completed:Wait()
							tween:Destroy()

							if i ~= rockRotationAmount then
								continue
							end

							for _, emitter in ipairs(clone:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end

						if not clone.Parent then
							return
						end

						clone.AlignOrientation:Destroy()
					end)
					task.wait(0.75)
					task.wait(math.random(0, 10) / 100)
					local clone2 = v2.Phase3.RockExplosion:Clone()
					clone2.CFrame = clone.CFrame
					Util2.SetParentOverrideWithColor(clone2, data2.SkillVisuals, player, "DragonFruitVFXColor")
					destroyAfter(clone2, 7)

					for _, emitter in ipairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v9 = emitter
						task.spawn(function()
							if v9:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v9:GetAttribute("EmitDelay"))
							end

							v9:Emit(v9:GetAttribute("EmitCount"))
						end)
					end

					DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
					task.spawn(function()
						for _ = 1, math.random(2, 3) do
							task.spawn(function()
								local clone3 = rockType:Clone()
								clone3.Position = clone.Position
								clone3.Size = createVector(5, 1, 5)
								clone3.Size += Vector3.new(0, math.random(0, 5) / 10, 0)
								clone3.Size *= math.random(2, 4)
								clone3.Material = clone.Material
								clone3.Color = clone.Color
								task.delay(0.6666666666666666, function()
									clone.CanCollide = true
								end)
								Util2.SetParentOverrideWithColor(clone3, skillVisuals, player, "DragonFruitVFXColor")
								clone3.Color = clone.Color
								destroyAfter(clone3, 7)
								local clone4 = v2.Phase3.RockFlame:Clone()
								clone4.Anchored = false
								clone4.Position = clone3.Position
								clone4.Size = clone3.Size
								clone4.WeldConstraint.Part1 = clone3
								Util2.SetParentOverrideWithColor(clone4, clone3, player, "DragonFruitVFXColor")
								destroyAfter(clone4, 7)
								task.spawn(function()
									task.wait(2.5)

									for _, emitter in ipairs(clone4:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end
								end)
								task.spawn(function()
									task.wait(duration / 3 + math.random(10, 50) / 100)
									TweenService:Create(
										clone3,
										TweenInfo.new(
											0.5,
											Enum.EasingStyle.Linear,
											Enum.EasingDirection.Out,
											0,
											false,
											0.25
										),
										{
											Color = Util2.WrapColor3Constructor(
												Color3.fromRGB(7, 7, 7),
												player,
												"DragonFruitVFXColor"
											)
										}
									):Play()
									task.wait(duration / 3 + 1)
									local clone5 = v2.Phase3.RockFlame2:Clone()
									clone5.Anchored = false
									clone5.Position = clone3.Position
									clone5.Size = clone3.Size
									clone5.WeldConstraint.Part1 = clone3
									Util2.SetParentOverrideWithColor(clone5, clone3, player, "DragonFruitVFXColor")
									destroyAfter(clone5, 7)
									TweenService:Create(
										clone3,
										TweenInfo.new(
											0.2,
											Enum.EasingStyle.Linear,
											Enum.EasingDirection.Out,
											0,
											false,
											0.25
										),
										{
											Size = createVector(0, 0, 0)
										}
									):Play()
									task.wait(0.35)

									for _, emitter in ipairs(clone5:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end
								end)
								local linearVelocity = Instance.new("LinearVelocity")
								linearVelocity.Attachment0 = clone3.Attachment0
								linearVelocity.MaxForce = 700000
								Util2.SetParentOverrideWithColor(linearVelocity, clone3, player, "DragonFruitVFXColor")
								destroyAfter(linearVelocity, 7)
								fn2(linearVelocity, clone3)
								clone3.Attachment0.Orientation = createVector(0, 0, 0)
								local v9 = math.random(-rockRotationPower, rockRotationPower)
								local v10 = math.random(-rockRotationPower, rockRotationPower)
								local v11 = math.random(-rockRotationPower, rockRotationPower)
								local v12 = v9 / rockRotationAmount
								local v13 = v10 / rockRotationAmount
								local v14 = v11 / rockRotationAmount
								task.spawn(function()
									task.wait(0.05)

									for _ = 1, rockRotationAmount do
										v9 = math.clamp(v9 - v12, 0, rockRotationPower * 1.5)
										v10 = math.clamp(v10 - v13, 0, rockRotationPower * 1.5)
										v11 = math.clamp(v11 - v14, 0, rockRotationPower * 1.5)
										local tween = TweenService:Create(
											clone3.Attachment0,
											TweenInfo.new(
												rockRotationSpeed,
												Enum.EasingStyle.Linear,
												Enum.EasingDirection.Out
											),
											{
												CFrame = clone3.Attachment0.CFrame * CFrame.Angles(
													math.rad(v9),
													math.rad(v10),
													(math.rad(v11))
												)
											}
										)
										tween:Play()
										tween.Completed:Wait()
										tween:Destroy()
									end

									clone3.AlignOrientation:Destroy()
								end)
								destroyAfter(clone3, 10)
							end)
						end

						clone:Destroy()
					end)
				end)
			end
		end

		local _ = data2.ExplosionCFrame
		local v3 = {
			Radius = 150,
			Size = 25,
			Duration = 3.5,
			Amount = 30,
			RockType = v2.CraterRock
		}
		local v4 = {
			RockAmount = 7,
			RockSize = 25,
			PositionOffset = 175,
			RockRotationAmount = 5,
			RockRotationSpeed = 0.15,
			RockRotationPower = 100,
			Duration = 1.5,
			RockType = v2.FlyRock
		}
		RockCrater(data2.Result, data2.SkillVisuals, v3) -- equivalent call inferred; original call site unknown
		GroundFlyRocks(data2.Result, data2.SkillVisuals, v4, function(p, _)
			local v5 = math.random(110, 140) * 2.5
			destroyAfter(p, math.random(30, 60) / 100)
			p.Velocity = Vector3.new(math.random() - 0.5, 0.3, math.random() - 0.5).Unit * v5
		end, function(p, _)
			destroyAfter(p, math.random(10, 20) / 100)
			p.VectorVelocity = Vector3.new(math.random(-30, 30) * 2, math.random(30, 50), math.random(-30, 30) * 2) * 2 * 2.5
		end)
	end

	local function FallExplosion(p)
		local explosionCFrame = p.ExplosionCFrame

		if player == game.Players.LocalPlayer then
			Util2.CameraShaker:ShakeOnce(12, 12, 0.1, 1.4)
		end

		task.spawn(function()
			local position = explosionCFrame.Position
			local character = localPlayer.Character

			if character ~= nil then
				local rootPart = character:FindFirstChildOfClass("Humanoid").RootPart

				if rootPart and (rootPart.Position - position).Magnitude <= 100 then
					cameraShakeAt(explosionCFrame.Position, 200, 7, 15, 0.15, 0.25) -- equivalent call inferred; original call site unknown
				end
			end

			local clone = v2.Phase3.Explosion:Clone()
			clone.CFrame = explosionCFrame
			Util2.SetParentOverrideWithColor(clone, p.SkillVisuals, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				task.spawn(function()
					if v3:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v3:GetAttribute("EmitDelay"))
					end

					v3:Emit(v3:GetAttribute("EmitCount"))

					if v3.Parent.Name == "Explosion2" then
						v3.Enabled = true
						task.wait(4.5)
						v3.Enabled = false
					end
				end)
			end

			task.spawn(function()
				local clone2 = v2.Phase3.GroundBurn:Clone()
				clone2.CFrame = explosionCFrame
				Util2.SetParentOverrideWithColor(clone2, p.SkillVisuals, player, "DragonFruitVFXColor")
				destroyAfter(clone2, 7)

				for _, emitter in ipairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.wait(2.5)

				for _, emitter in ipairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			task.wait(0.1)
			local clone2 = v2.Phase3.Explosion2:Clone()
			clone2.CFrame = explosionCFrame
			Util2.SetParentOverrideWithColor(clone2, p.SkillVisuals, player, "DragonFruitVFXColor")
			destroyAfter(clone2, 7)

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				task.spawn(function()
					if v3:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v3:GetAttribute("EmitDelay"))
					end

					v3:Emit(v3:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
			local clone3 = v2.Phase3.Explosion3:Clone()
			clone3.CFrame = explosionCFrame
			Util2.SetParentOverrideWithColor(clone3, p.SkillVisuals, player, "DragonFruitVFXColor")
			destroyAfter(clone3, 7)

			for _, emitter in ipairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				task.spawn(function()
					if v3:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v3:GetAttribute("EmitDelay"))
					end

					v3:Emit(v3:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
			task.spawn(function()
				for i = 1, 3 do
					local v3 = i
					task.spawn(function()
						local clone4 = v2.Phase3.TornadoSlashModel:Clone()
						clone4.PrimaryPart.CFrame = explosionCFrame * CFrame.new(0, math.random(5, 25), 0) * CFrame.Angles(
							0,
							v3 * 90,
							0
						)
						Util2.SetParentOverrideWithColor(clone4, p.SkillVisuals, player, "DragonFruitVFXColor")
						local v4 = 5 + math.random(-10, 25) / 10
						clone4:ScaleTo(v4)
						local v5 = math.random(5, 12) / 100
						local v6 = math.random(10, 35)

						for i2 = 1, 5 do
							local tween = TweenService:Create(
								clone4.PrimaryPart,
								TweenInfo.new(v5 / (i2 + 0.1), Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone4.PrimaryPart.CFrame * CFrame.new(0, 5 + v6 / i2, 0) * CFrame.Angles(
										0,
										-0.6544984694978736,
										0
									)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end

						for i2, beam in pairs(clone4:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							local v7 = beam
							task.spawn(function()
								local tween = TweenService:Create(
									v7,
									TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Width0 = 0,
										Width1 = 0
									}
								)
								tween:Play()
								tween.Completed:Wait()
								v7:Destroy()
							end)
						end

						task.spawn(function()
							for i2 = v4 * 10, v4 * 10 + 15 do
								clone4:ScaleTo(i2 / 10 * 2.5)
								task.wait()
							end
						end)

						for i2 = 1, 5 do
							local tween = TweenService:Create(
								clone4.PrimaryPart,
								TweenInfo.new(v5 * 2 / (i2 + 0.1), Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone4.PrimaryPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(
										0,
										-0.7853981633974483,
										0
									)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end
					end)
				end
			end)
			task.spawn(function()
				for i = 1, 5 do
					local v3 = i
					task.spawn(function()
						local clone4 = v2.Phase3.TornadoSlashModel2:Clone()
						clone4.PrimaryPart.CFrame = explosionCFrame * CFrame.new(0, math.random(5, 25), 0) * CFrame.Angles(
							0,
							v3 * 45,
							0
						)
						Util2.SetParentOverrideWithColor(clone4, p.SkillVisuals, player, "DragonFruitVFXColor")
						clone4:ScaleTo(10 + math.random(-10, 25) / 10)
						local v4 = math.random(5, 12) / 100
						local v5 = math.random(10, 35)

						for i2, beam in pairs(clone4:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							local v6 = beam
							task.spawn(function()
								local tween = TweenService:Create(
									v6,
									TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Width0 = 0,
										Width1 = 0
									}
								)
								tween:Play()
								tween.Completed:Wait()
								v6:Destroy()
							end)
						end

						for i2 = 1, 5 do
							local tween = TweenService:Create(
								clone4.PrimaryPart,
								TweenInfo.new(v4 / (i2 + 0.1), Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone4.PrimaryPart.CFrame * CFrame.new(0, 5 + v5 / i2, 0) * CFrame.Angles(
										0,
										-1.090830782496456,
										0
									)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end

						local tween = TweenService:Create(
							clone4.PrimaryPart,
							TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone4.PrimaryPart.CFrame * CFrame.new(0, 25, 0) * CFrame.Angles(
									0,
									-1.4835298641951802,
									0
								)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end)
				end
			end)
		end)
		local position = explosionCFrame.Position
		local character = localPlayer.Character

		if character ~= nil then
			local rootPart = character:FindFirstChildOfClass("Humanoid").RootPart

			if rootPart and (rootPart.Position - position).Magnitude <= 100 then
				task.spawn(function()
					local screenColorEDF = v2.Phase3.ScreenColorEDF
					local v3 = game.Lighting:FindFirstChild("ScreenColorEDF")

					if v3 then
						v3:SetAttribute("UsedTimes", v3:GetAttribute("UsedTimes") + 1)
					else
						v3 = Instance.new("ColorCorrectionEffect")
					end

					Util2.SetParentOverrideWithColor(v3, game.Lighting, player, "DragonFruitVFXColor")
					local usedTimes = v3:GetAttribute("UsedTimes")
					local tween = TweenService:Create(v3, TweenInfo.new(0.1), {
						Brightness = screenColorEDF.Brightness,
						Contrast = screenColorEDF.Contrast,
						Saturation = screenColorEDF.Saturation,
						TintColor = screenColorEDF.TintColor
					})
					tween:Play()
					local bloomEffect = Instance.new("BloomEffect")
					Util2.SetParentOverrideWithColor(bloomEffect, game.Lighting, player, "DragonFruitVFXColor")
					bloomEffect.Size += 10
					task.wait(0.1)
					local v4 = TweenService:Create(bloomEffect, TweenInfo.new(0.25), {
						Size = 54
					}):Play()
					task.delay(0.25, function()
						v4 = TweenService:Create(bloomEffect, TweenInfo.new(0.25), {
							Size = 0
						}):Play()
						task.wait(0.25)
						bloomEffect:Destroy()
					end)
					task.spawn(function()
						if v3:GetAttribute("UsedTimes") == usedTimes then
							tween = TweenService:Create(v3, TweenInfo.new(0.5), {
								TintColor = Util2.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 255, 255),
									player,
									"DragonFruitVFXColor"
								),
								Brightness = 0,
								Contrast = 0,
								Saturation = 0
							})
							tween:Play()
							tween.Completed:Wait()

							if v3:GetAttribute("UsedTimes") == usedTimes then
								v3:Destroy()
							end
						end
					end)
				end)
			end
		end

		GroundImpact(p)
	end

	local function SpinSlash(cFrame, folder)
		local function TailWhip(p, clone, data2)
			local multiplier = data2.Multiplier
			local slashAngle = data2.SlashAngle
			local slashAngle2 = data2.SlashAngle2
			local yPosition = data2.YPosition
			local slashType = data2.SlashType
			local slashIterations = data2.SlashIterations
			local slashSpinAngle = data2.SlashSpinAngle
			local slashFinalSpinAngle = data2.SlashFinalSpinAngle
			local slashEndSpeed = data2.SlashEndSpeed
			local clone2 = slashType:Clone()
			clone2.CFrame = clone.CFrame
			clone2.Anchored = false
			clone2.Weld.Part0 = clone
			clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * CFrame.new(
				0,
				yPosition,
				0
			) * slashAngle * slashAngle2
			Util2.SetParentOverrideWithColor(clone2, p, player, "DragonFruitVFXColor")
			destroyAfter(clone2, 7)

			for _, descendant in ipairs(clone2:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= multiplier
					descendant.CurveSize1 *= multiplier
					descendant.Width0 *= multiplier
					descendant.Width1 *= multiplier
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * multiplier,
						descendant.Position.Y * multiplier,
						descendant.Position.Z * multiplier
					)
				end
			end

			for _, descendant in ipairs(clone2:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.Enabled = true
					local startDelay = descendant:GetAttribute("StartDelay")
					local v3 = descendant
					local v4 = descendant:GetAttribute("EndDelay")
					task.spawn(function()
						local tween = TweenService:Create(
							v3,
							TweenInfo.new(v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Width0 = v3.Width0 * 1.5,
								Width1 = v3.Width1 * 1.5,
								CurveSize0 = v3.CurveSize0 * 1.5,
								CurveSize1 = v3.CurveSize1 * 1.5
							}
						)
						v3.Width0 = 0
						v3.Width1 = 0
						task.wait(startDelay)
						tween:Play()
					end)
				elseif descendant:IsA("Attachment") then
					TweenService:Create(
						descendant,
						TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(
								descendant.Position.X * 1.5,
								descendant.Position.Y * 1.5,
								descendant.Position.Z * 1.5
							)
						}
					):Play()
				end
			end

			for _ = 1, slashIterations do
				local tween = TweenService:Create(
					clone2.Weld,
					TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * CFrame.Angles(
							0,
							math.rad(slashSpinAngle),
							0
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end

			clone2.Weld.Enabled = false
			clone2.Anchored = true
			TweenService:Create(
				clone2,
				TweenInfo.new(slashEndSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					CFrame = clone2.CFrame * CFrame.Angles(0, math.rad(slashFinalSpinAngle), 0)
				}
			):Play()

			for _, effect in ipairs(clone2:GetDescendants()) do
				if effect:IsA("Beam") then
					local v3 = effect
					task.spawn(function()
						local endDelay = v3:GetAttribute("EndDelay")
						local tween = TweenService:Create(
							v3,
							TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v3:Destroy()
					end)
				elseif effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end
		end

		local clone = v2.Phase4.TailSpin:Clone()
		clone.CFrame = cFrame
		Util2.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
		destroyAfter(clone, 7)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.spawn(function()
			task.wait(0.07)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		local clone2 = v2.Phase4.StartImpact:Clone()
		clone2.CFrame = cFrame
		Util2.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
		destroyAfter(clone2, 7)

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		task.spawn(function()
			TailWhip(folder, clone2, {
				Multiplier = 3,
				SlashAngle = CFrame.Angles(0, math.rad((math.random(-170, -150))), 0),
				SlashAngle2 = CFrame.Angles(math.rad(math.random(1, 5) / 100), 0, 0),
				YPosition = 5,
				SlashType = v2.Phase4.TailWhipSlash,
				SlashIterations = 3,
				SlashSpinAngle = 50,
				SlashFinalSpinAngle = 70,
				SlashEndSpeed = 0.25
			})
		end)
		task.spawn(function()
			task.wait(0.15)
			TailWhip(folder, clone2, {
				Multiplier = 3.5,
				SlashAngle = CFrame.new(0, 5, 0) * CFrame.Angles(0, 2.6179938779914944, 0),
				SlashAngle2 = CFrame.Angles(0.08726646259971647, 0, 0),
				YPosition = 15,
				SlashType = v2.Phase4.SmallTailWhipSlash,
				SlashIterations = 3,
				SlashSpinAngle = 120,
				SlashFinalSpinAngle = 150,
				SlashEndSpeed = 0.75
			})
		end)
		task.wait(0.15)
		local clone3 = v2.Phase4.StartImpact2:Clone()
		clone3.CFrame = cFrame
		Util2.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")
		destroyAfter(clone3, 7)

		for _, emitter in ipairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		local clone4 = v2.Phase4.EndSpin:Clone()
		clone4.CFrame = cFrame
		Util2.SetParentOverrideWithColor(clone4, folder, player, "DragonFruitVFXColor")
		destroyAfter(clone4, 7)

		for _, emitter in ipairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end
	end

	local folder = Instance.new("Folder")
	Util2.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DragonFruitVFXColor")
	destroyAfter(folder, 15)

	if data.collision == false then
		sound:Play("BF_V3_Dragon_Full_WhiteGlove_Sweep_01", v.CFrame)
		SpinSlash(v.CFrame, folder)
	else
		local v3 = {
			SkillVisuals = folder,
			Result = {
				Position = data.rayPosition,
				Normal = data.rayNormal,
				Instance = data.rayInstance,
				Material = data.rayMaterial
			},
			ExplosionCFrame = AlignCFrame(CFrame.new(data.rayPosition), data.rayNormal) + data.rayNormal * 0.05
		}
		sound:Play("BF_V3_WhiteGlove_F_Explosion_02-002", v3.ExplosionCFrame.Position)
		FallExplosion(v3)
	end
end