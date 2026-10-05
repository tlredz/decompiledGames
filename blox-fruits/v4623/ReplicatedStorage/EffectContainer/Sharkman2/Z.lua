local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Sharkman2").Z.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local WaitForHiddenAim = require(script.WaitForHiddenAim)

local function GetSharkmanColorOwner(player, model)
	local player2 = player.Player or player.player

	if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
		return player2
	end

	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		return player2
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(model)

	if playerFromCharacter and playerFromCharacter.Parent then
		return playerFromCharacter
	end

	return model
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

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local function curve(instance, position)
	local position2 = instance.Position
	local magnitude = (position2 - position).Magnitude
	instance.CFrame = CFrame.new(position2, position)
	local v = (position2 - position) / 2
	local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
	local v2 = math.random(5, 10) * 3
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-2, v2), math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-2, v2), math.random(-v2, v2))
	local v5 = math.random(20, 30) / 50
	local lastTime = tick()
	local v6 = magnitude / v5 / 60

	while tick() - lastTime < v6 do
		local v7 = (tick() - lastTime) / v6
		local v8 = cubicBezier(v7, position2, v3, v4, position)
		instance.CFrame = instance.CFrame:Lerp(CFrame.new(v8, position), v7)
		RunService.Heartbeat:Wait()
	end
end

local function DashTrail(clone, position)
	local position2 = clone.Position
	local magnitude = (position2 - position).Magnitude
	clone.CFrame = CFrame.new(position2, position)
	local v = (position2 - position) / 2
	local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
	local v2 = math.random(20, 30)
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-2, v2), math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-2, v2), math.random(-v2, v2))
	local v5 = math.random(15, 30) / 7
	local lastTime = tick()
	local v6 = magnitude / v5 / 60

	while tick() - lastTime < v6 do
		local v7 = (tick() - lastTime) / v6
		local v8 = cubicBezier(v7, position2, v3, v4, position)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v8, position), v7)
		RunService.Heartbeat:Wait()
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function SkillUse(player)
	local character = player.Character
	local _ = player.Humanoid
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local sharkmanColorOwner = GetSharkmanColorOwner(player, character)

	if player.Holding then
		local cFrame = humanoidRootPart.CFrame
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		local v2 = Util.Sound:Play("SharkmanK_Z_Hold_01", humanoidRootPart)
		Util.Sound:Play("SharkmanK_Z_Activate_01", humanoidRootPart)
		TweenService:Create(v2, TweenInfo.new(0.7), {
			Volume = 0.9
		}):Play()
		local cframesByClone = {}
		local v3 = {}

		for i = 1, 6 do
			local clone = assets.Phase0.WaterTrail:Clone()
			clone.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
			clone.AlignPosition.Enabled = true
			clone.Anchored = false
			clone.Massless = true

			if i == 1 then
				cframesByClone[clone] = CFrame.new(7, 0.5, 0)
			elseif i == 2 then
				cframesByClone[clone] = CFrame.new(5, 3, 0)
			elseif i == 3 then
				cframesByClone[clone] = CFrame.new(3, 1, 0)
			elseif i == 4 then
				cframesByClone[clone] = CFrame.new(-7, 0.5, 0)
			elseif i == 5 then
				cframesByClone[clone] = CFrame.new(-5, 3, 0)
			elseif i == 6 then
				cframesByClone[clone] = CFrame.new(-3, 1, 0)
			end

			local numberValue = Instance.new("NumberValue", clone)
			numberValue.Value = -1
			numberValue.Name = "NumberValue"
			v3[numberValue] = tick()
		end

		while true do
			for k, v4 in pairs(cframesByClone) do
				k.AlignPosition.Position = humanoidRootPart.CFrame * v4 * CFrame.new(0, k.NumberValue.Value, 0).Position
			end

			for k, v4 in pairs(v3) do
				if not (v4 - tick() <= 0) then
					continue
				end

				v3[k] = tick() + 2
				TweenService:Create(k, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
					Value = 1
				}):Play()
			end

			task.wait()

			if player.Holding and player.Holding.Value and player.Holding:IsDescendantOf(workspace) then
				continue
			end

			for folder2, _ in pairs(cframesByClone) do
				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end

			if v2 then
				Util.Sound:FadeOut(v2, 0.2)
			end

			Util.Debris:AddItem(folder, 2)
			return
		end
	else
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 7)
		local cFrame = player.CFrame
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 0, -5)
		Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		Util.Sound:Play("SharkmanK_Z_Release_01", humanoidRootPart)

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local duration = player.Duration
		local clone2 = assets.Phase1.Dash:Clone()
		clone2.CFrame = humanoidRootPart.CFrame
		clone2.Anchored = false
		clone2.Weld.Part1 = humanoidRootPart
		Util.SetParentOverrideWithColor(clone2, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		local v2 = {}

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			v2[emitter] = tick() + 1 / emitter.Rate
			emitter.Enabled = true
		end

		task.spawn(function()
			task.wait(0.05)

			if v2 ~= nil then
				for _ = 1, 7 do
					task.spawn(function()
						local clone3 = assets.Phase1.DashTrail:Clone()
						clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(
							math.random(-5, 5) / 2,
							math.random(-5, 5) / 2,
							math.random(-5, 5) / 3
						)
						Util.SetParentOverrideWithColor(
							clone3,
							folder,
							sharkmanColorOwner,
							"SharkmanKarateFruitVFXColor"
						)

						for _, effect in pairs(clone3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = true
							end
						end

						DashTrail(
							clone3,
							humanoidRootPart.CFrame * CFrame.new(0, -3, 50) * CFrame.new(
								math.random(-5, 5) / 2,
								math.random(-5, 5) / 2,
								math.random(-7, -5) / 3
							).Position
						)

						for _, effect in pairs(clone3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
					task.wait(0.015)
				end
			end
		end)
		local clone3 = assets.Phase1.GroundBurn:Clone()
		clone3.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone3, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local emitters = {}
		local v3 = false

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				table.insert(emitters, emitter)
			end
		end

		local clone4 = assets.Phase1.WaterClonesHolder:Clone()
		clone4.Parent = folder
		local motor6Ds = {}
		local v4 = {}
		local clonesByHumanoidRootPart = {}

		for i = 1, 6 do
			local v5 = i
			task.spawn(function()
				local clone5 = assets.Phase1.WaterClone:Clone()

				if v5 == 1 then
					clone5.HumanoidRootPart.CFrame = cFrame * CFrame.new(10, 0, 0)
					clone5:SetAttribute("Offset", createVector(10, 0, 0))
				elseif v5 == 2 then
					clone5.HumanoidRootPart.CFrame = cFrame * CFrame.new(-10, 0, 0)
					clone5:SetAttribute("Offset", createVector(-10, 0, 0))
				elseif v5 == 3 then
					clone5.HumanoidRootPart.CFrame = cFrame * CFrame.new(7, 3, -3)
					clone5:SetAttribute("Offset", createVector(7, 3, -3))
				elseif v5 == 4 then
					clone5.HumanoidRootPart.CFrame = cFrame * CFrame.new(-7, 3, -3)
					clone5:SetAttribute("Offset", createVector(-7, 3, -3))
				elseif v5 == 5 then
					clone5.HumanoidRootPart.CFrame = cFrame * CFrame.new(5, 1, 3)
					clone5:SetAttribute("Offset", createVector(5, 1, 3))
				elseif v5 == 6 then
					clone5.HumanoidRootPart.CFrame = cFrame * CFrame.new(-5, 1, 3)
					clone5:SetAttribute("Offset", createVector(-5, 1, 3))
				end

				Util.SetParentOverrideWithColor(clone5, clone4, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
				local clone6 = assets.Phase1.AlignMover:Clone()
				clone6.CFrame = cFrame
				clone6.Anchored = false
				clone6.Parent = folder
				clone6.Weld.Part0 = clone5.HumanoidRootPart
				local alignOrientation = clone6.AlignOrientation
				alignOrientation.Enabled = true
				alignOrientation.CFrame = clone5.HumanoidRootPart.CFrame
				local alignPosition = clone6.AlignPosition
				alignPosition.Enabled = true
				alignPosition.Responsiveness = 35.5
				local distance = player.Distance
				alignPosition.Position = clone5.HumanoidRootPart.CFrame * CFrame.new(0, 0, -distance).Position
				task.spawn(function()
					for i2, part in pairs(clone5:GetChildren()) do
						if not part:IsA("BasePart") then
							continue
						end

						if part.Name ~= "HumanoidRootPart" then
							part.Transparency = 1
							local clone7 = assets.Phase1.GlowBox:Clone()
							clone7.Adornee = part
							Util.SetParentOverrideWithColor(
								clone7,
								part,
								sharkmanColorOwner,
								"SharkmanKarateFruitVFXColor"
							)
						end

						local motor6D = part:FindFirstChildWhichIsA("Motor6D")

						if motor6D then
							table.insert(motor6Ds, motor6D)
						end
					end
				end)
				local clone7 = assets.Phase1.CloneTrail:Clone()
				clone7.CFrame = clone5.PrimaryPart.CFrame
				Util.SetParentOverrideWithColor(clone7, clone5, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
				clone7.WeldConstraint.Part1 = clone5.PrimaryPart
				clone7.Anchored = false
				clone7.Massless = true

				for i2, trail in pairs(clone7:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					trail.Lifetime = trail.Lifetime * math.random(25, 100) / 150
					trail.TextureLength = trail.TextureLength * math.random(75, 125) / 100
					trail.Brightness = trail.Brightness * math.random(75, 125) / 100
				end

				local clone8 = assets.Phase2.CloneHitImpact2:Clone()
				clone8.CFrame = clone5.PrimaryPart.CFrame * CFrame.new(0, 0, -3)
				Util.SetParentOverrideWithColor(clone8, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
				clone8.WeldConstraint.Part1 = clone5.PrimaryPart
				clone8.Anchored = false
				v4[clone8] = tick()
				clonesByHumanoidRootPart[clone5.HumanoidRootPart] = clone6
			end)
		end

		task.spawn(function()
			local childrenByName = {}

			while motor6Ds ~= nil do
				for _, v5 in pairs(motor6Ds) do
					local child = childrenByName[v5.Name]

					if not child then
						child = character:FindFirstChild(v5.Parent.Name) and character[v5.Parent.Name]:FindFirstChild(v5.Name)

						if child then
							childrenByName[v5.Name] = child
						end
					end

					if child then
						v5.Transform = child.Transform
					end
				end

				RunService.PreSimulation:Wait()
			end
		end)
		local clone5 = assets.Phase2.CloneHitImpact:Clone()
		clone5.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone5, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		local lastTime = tick()
		tick()

		while true do
			for k, v5 in pairs(v2) do
				if not (v5 - tick() <= 0) then
					continue
				end

				v2[k] = tick() + 1 / k.Rate
				k:Emit(k:GetAttribute("EmitCount") / 2)
			end

			if not workspace:Raycast(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector * 10, raycastParams) then
				task.spawn(function()
					local raycastResult = workspace:Raycast(
						humanoidRootPart.Position + createVector(0, 1, 0),
						createVector(-0, -25, -0),
						raycastParams
					)

					if raycastResult then
						clone3.CFrame = CFrame.new(
							raycastResult.Position + createVector(0, 0.1, 0),
							raycastResult.Position + createVector(0, 0.1, 0) + humanoidRootPart.CFrame.LookVector
						)

						if v3 == false then
							v3 = true

							for _, v5 in pairs(emitters) do
								v5.Enabled = true
								v5:Emit(1)
							end
						else
							for _, v5 in pairs(emitters) do
								v5:Emit(1)
							end
						end
					elseif v3 == true then
						v3 = false

						for _, v5 in pairs(emitters) do
							v5.Enabled = false
						end
					end
				end)
				task.wait(0.015)
				local v5 = tick() - lastTime

				if not (duration * 0.96 <= v5) then
					continue
				end
			end

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			v2 = nil

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local v5 = nil

			if player.State then
				local lastTime2 = tick()

				while tick() - lastTime2 < 1 do
					local state = player.State:GetAttribute("State")

					if state == nil then
						task.wait()
					else
						v5 = state
						break
					end
				end
			end

			motor6Ds = nil
			local flag = false

			if v5 == 1 then
				local lastTime2 = tick()
				local count = 0
				local nextPos = nil
				local flag2 = true

				for k in pairs(clonesByHumanoidRootPart) do
					local sKZAttackLoop = Util.Anims:Get(k.Parent, "SK_ZAttackLoop")
					sKZAttackLoop:Play(0)
					sKZAttackLoop.TimePosition = count / 10 % 0.6
					count += 1
				end

				while tick() - lastTime2 < 0.9 and (not player.State or player.State:GetAttribute("State") ~= 2) do
					if nextPos ~= player.State:GetAttribute("NextPos") then
						nextPos = player.State:GetAttribute("NextPos")
						flag2 = true
					end

					if flag2 then
						local _ = tick() + 0.1
						flag2 = false

						for k, v6 in pairs(clonesByHumanoidRootPart) do
							local cFrame2 = humanoidRootPart.CFrame * CFrame.new(k.Parent:GetAttribute("Offset")) * CFrame.new(
								0,
								0,
								-7
							)
							v6.AlignPosition.Position = cFrame2.Position
							v6.AlignOrientation.CFrame = cFrame2
							TweenService:Create(k, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
								CFrame = cFrame2
							}):Play()
						end

						TweenService:Create(humanoidRootPart, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
							CFrame = CFrame.new(
								player.State:GetAttribute("NextPos"),
								humanoidRootPart.Position + createVector(0, 0.000123, 0)
							) * CFrame.Angles(0, 3.141592653589793, 0)
						}):Play()
						Util.Sound:Play(
							"SharkmanK_Z_WaterKarateChops_V2_0" .. tostring(math.random(1, 4)),
							humanoidRootPart
						)
						clone5.CFrame = humanoidRootPart.CFrame * CFrame.new(
							math.random(-10, 10),
							math.random(-10, 10) / 2,
							-15 - math.random(5, 10) / 10
						)

						for _, emitter in pairs(clone5:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						for folder2, v6 in pairs(v4) do
							if not (v6 - tick() <= 0) then
								continue
							end

							v4[folder2] = tick() + math.random(10, 15) / 100

							for _, emitter in pairs(folder2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount") * 0.7)
								end
							end
						end
					end

					task.wait()
				end

				if player.Hidden and WaitForHiddenAim(player.State, 1) then
					flag = true

					for k, v6 in pairs(clonesByHumanoidRootPart) do
						v6.AlignOrientation.Enabled = false
						v6.AlignPosition.Enabled = false
						v6:Destroy()
						local parent = k.Parent

						for _, descendant in pairs(parent:GetDescendants()) do
							if descendant:IsA("Motor6D") then
								local v7 = descendant
								task.spawn(function()
									v7.Enabled = false
								end)
							elseif descendant:IsA("BasePart") then
								if descendant.Name == "CloneTrail" or descendant.Name == "HumanoidRootPart" then
									descendant:Destroy()
								else
									descendant.CanCollide = false
									descendant.Anchored = true
									local v7 = descendant
									task.spawn(function()
										curve(v7, humanoidRootPart.Position)
									end)

									if math.random(1, 4) == 1 then
										local clone6 = assets.Phase1.CloneTrail:Clone()
										clone6.CFrame = descendant.CFrame
										Util.SetParentOverrideWithColor(
											clone6,
											descendant,
											sharkmanColorOwner,
											"SharkmanKarateFruitVFXColor"
										)
										clone6.WeldConstraint.Part1 = descendant
										clone6.Anchored = false
										clone6.Massless = true

										for _, trail in pairs(clone6:GetDescendants()) do
											if not trail:IsA("Trail") then
												continue
											end

											trail.Lifetime = trail.Lifetime * math.random(25, 100) / 150
											trail.TextureLength = trail.TextureLength * math.random(75, 125) / 100
											trail.Brightness = trail.Brightness * math.random(75, 125) / 100
										end
									end

									local v8 = descendant
									task.spawn(function()
										TweenService:Create(
											v8,
											TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
											{
												Size = Vector3.new(
													v8.Size.X * math.random(5, 15) / 10,
													v8.Size.Y * math.random(5, 15) / 10,
													v8.Size.Z * math.random(5, 15) / 10
												)
											}
										):Play()
										task.wait(0.25)
										TweenService:Create(
											v8,
											TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
											{
												Size = Vector3.new(v8.Size.X * 0, v8.Size.Y * 0, v8.Size.Z * 0)
											}
										):Play()
										local glowBox = v8:FindFirstChild("GlowBox")

										if glowBox then
											task.spawn(function()
												local tween = TweenService:Create(glowBox, TweenInfo.new(0.125), {
													Transparency = 0,
													SurfaceTransparency = 0.5
												})
												tween:Play()
												tween.Completed:Wait()
												TweenService:Create(glowBox, TweenInfo.new(0.125), {
													Transparency = 1,
													SurfaceTransparency = 1
												}):Play()
											end)
										end
									end)
								end
							end
						end
					end

					task.spawn(function()
						task.wait(0.3)
						local clone6 = assets.Extra.Start:Clone()
						clone6.CFrame = humanoidRootPart.CFrame
						Util.SetParentOverrideWithColor(
							clone6,
							folder,
							sharkmanColorOwner,
							"SharkmanKarateFruitVFXColor"
						)

						for _, emitter in pairs(clone6:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown
						task.wait(0.1)
						local clone7 = assets.Extra.StartImpact:Clone()
						clone7.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
						Util.SetParentOverrideWithColor(
							clone7,
							folder,
							sharkmanColorOwner,
							"SharkmanKarateFruitVFXColor"
						)
						Util.Sound:Play("SharkmanK_Z_Release_01", humanoidRootPart)

						for _, emitter in pairs(clone7:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v6 = emitter
							task.spawn(function()
								if v6:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v6:GetAttribute("EmitDelay"))
								end

								v6:Emit(v6:GetAttribute("EmitCount"))
							end)
						end

						DeleteImpactAfterDuration(clone7) -- equivalent call inferred; original call site unknown
						local cframe = CFrame.lookAt(
							player.State:GetAttribute("NextPos"),
							player.State:GetAttribute("MousePos") + createVector(0, 1, 0) * player.height
						)
						local speed = player.Speed
						local lifetime = player.Lifetime
						local clone8 = assets.Extra.Projectile:Clone()
						clone8.CFrame = cframe
						Util.SetParentOverrideWithColor(
							clone8,
							folder,
							sharkmanColorOwner,
							"SharkmanKarateFruitVFXColor"
						)
						local v6 = (cframe.LookVector + createVector(0, 0.6, 0)).Unit * speed
						local lastTime3 = tick()
						local flag3 = false
						local hiddenGrab = player.HiddenGrab
						hiddenGrab.Value = clone8.CFrame
						local raycastResult = workspace:Raycast(clone8.Position, v6.Unit * 6, raycastParams)
						local heartbeatConnection = nil
						heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
							if lifetime < tick() - lastTime3 then
								heartbeatConnection:Disconnect()
								clone8:Destroy()
								flag3 = true
							else
								raycastResult = workspace:Raycast(clone8.Position, v6.Unit * 6, raycastParams)

								if raycastResult then
									heartbeatConnection:Disconnect()
									clone8:Destroy()
									flag3 = true
								end

								v6 += createVector(0, -300, 0) * dt
								local v8 = clone8.Position + v6 * dt
								clone8.CFrame = CFrame.lookAt(v8, v8 + v6)
								hiddenGrab.Value = clone8.CFrame
							end
						end)

						repeat
							task.wait()
						until flag3

						hiddenGrab.Value = clone8.CFrame
						clone8:Destroy()
						local clone9 = assets.Extra.Explosion:Clone()

						if not raycastResult then
							clone9.Explosion2:Destroy()
						end

						clone9.CFrame = clone8.CFrame
						Util.SetParentOverrideWithColor(
							clone9,
							folder,
							sharkmanColorOwner,
							"SharkmanKarateFruitVFXColor"
						)
						Util.Sound:Play("SharkmanK_X_Explode_01", clone9.CFrame.Position)

						for _, emitter in pairs(clone9:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v7 = emitter
							task.spawn(function()
								if v7:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v7:GetAttribute("EmitDelay"))
								end

								v7:Emit(v7:GetAttribute("EmitCount"))
							end)
						end

						DeleteImpactAfterDuration(clone9) -- equivalent call inferred; original call site unknown

						if raycastResult then
							local clone10 = assets.Extra.WaterSplash:Clone()
							clone10.CFrame = clone9.CFrame * CFrame.new(0, 10, 0)
							Util.SetParentOverrideWithColor(
								clone10,
								folder,
								sharkmanColorOwner,
								"SharkmanKarateFruitVFXColor"
							)

							for _, emitter in pairs(clone10:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								emitter.Enabled = true
								emitter:Emit(1)
							end

							local raycastResult2 = workspace:Raycast(
								clone9.Position + createVector(0, 15, 0) + createVector(0, 1, 0),
								createVector(-0, -25, -0),
								raycastParams
							)

							if raycastResult2 then
								clone10.WaterSplash3.CFrame = AlignCFrame(
									CFrame.new(raycastResult2.Position),
									raycastResult2.Normal
								) + raycastResult2.Normal * 0.01
							else
								clone10.WaterSplash3:Destroy()
							end

							task.wait(0.5)

							for _, emitter in pairs(clone10:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								if emitter.Parent.Name == "WaterSplash3" then
									local v7 = emitter
									task.delay(0.25, function()
										v7.Enabled = false
									end)
								else
									emitter.Enabled = false
								end
							end
						end
					end)
					task.wait(0.3)
				end
			end

			for k, _ in pairs(v4) do
				k.Anchored = true
				k.WeldConstraint.Enabled = false
			end

			if flag then
				return
			end

			for k, v6 in pairs(clonesByHumanoidRootPart) do
				print(v5)
				v6.AlignOrientation.Enabled = false
				v6.AlignPosition.Enabled = false
				v6:Destroy()
				k.AssemblyLinearVelocity = createVector(0, 0, 0)
				k.AssemblyAngularVelocity = createVector(0, 0, 0)
				local v7 = k
				local v8 = v6
				task.spawn(function()
					task.wait(0.075)
					task.spawn(function()
						local clone6 = assets.Phase2.WaterSplash:Clone()
						clone6.CFrame = v7.CFrame
						Util.Sound:Play("SharkmanK_Z_Clone_Disappear_0" .. tostring(math.random(1, 6)), clone6.Position)
						Util.SetParentOverrideWithColor(
							clone6,
							folder,
							sharkmanColorOwner,
							"SharkmanKarateFruitVFXColor"
						)
						local ray, v9 = Util.Ray(clone6.Position, createVector(-0, -5, -0))

						if ray then
							clone6.WaterSplash3.WeldConstraint.Enabled = false
							clone6.WaterSplash3.Anchored = true
							clone6.WaterSplash3.Position = v9 + Vector3.new(0, clone6.WaterSplash3.Size.Y / 2, 0)
						else
							clone6.WaterSplash3:Destroy()
						end

						for i, emitter in pairs(clone6:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end

						task.wait(0.3)

						for i, emitter in pairs(clone6:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if ray and emitter.Parent == clone6.WaterSplash3 then
								local v10 = emitter
								task.spawn(function()
									task.wait(0.25)
									v10.Enabled = false
								end)
							else
								emitter.Enabled = false
							end
						end
					end)
					local parent = v7.Parent

					for i, descendant in pairs(parent:GetDescendants()) do
						if descendant:IsA("Motor6D") then
							local v9 = descendant
							task.spawn(function()
								task.wait(0.025)
								v9.Enabled = false
							end)
						elseif descendant:IsA("BasePart") then
							if descendant.Name == "CloneTrail" then
								descendant:Destroy()
							else
								local v9 = descendant
								task.spawn(function()
									TweenService:Create(
										v9,
										TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
										{
											Position = v9.Position + Vector3.new(
												math.random(-1, 1),
												math.random(-1, 1),
												math.random(-1, 1)
											),
											Rotation = Vector3.new(
												math.random(-90, 90) / 10,
												math.random(-90, 90) / 10,
												math.random(-90, 90) / 10
											)
										}
									):Play()
									task.wait(0.05)
									TweenService:Create(v9, TweenInfo.new(0.25), {
										Position = v9.Position + Vector3.new(
											math.random(-1, 1),
											math.random(-1, 1),
											math.random(-1, 1)
										),
										Rotation = Vector3.new(
											math.random(-90, 90) / 10,
											math.random(-90, 90) / 10,
											math.random(-90, 90) / 10
										),
										Size = v8.Size * 0
									}):Play()
									local glowBox = v9:FindFirstChild("GlowBox")

									if glowBox then
										task.spawn(function()
											TweenService:Create(glowBox, TweenInfo.new(0.15), {
												Transparency = 0
											}):Play()
											TweenService:Create(glowBox, TweenInfo.new(0.15), {
												Transparency = 1,
												SurfaceTransparency = 1
											}):Play()
										end)
									end

									task.wait(0.15)
									v9.CanCollide = true
								end)
							end
						else
							descendant:IsA("SelectionBox")
						end
					end

					v7:Destroy()
				end)
			end

			return
		end
	end
end

return SkillUse