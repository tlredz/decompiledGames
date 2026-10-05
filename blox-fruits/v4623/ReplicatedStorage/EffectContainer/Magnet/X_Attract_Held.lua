local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local x_Attract_Held = FX:WaitForChild("Magnet"):WaitForChild("X_Attract_Held")
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local v = {
	ScrapModelA = "ArcsteelScrapModelA",
	ScrapModelA2 = "ArcsteelScrapModelB"
}

local function hasCrimsonGoldSkin(player)
	if typeof(player) ~= "Instance" then
		return false
	end

	local magnetFruitVFXColor = player:FindFirstChild("MagnetFruitVFXColor")

	if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
		return true
	end

	local character = player.Character
	local primaryPart = character and character.PrimaryPart

	if primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" then
		return true
	end

	return false
end

local function resolveScrap(childName: string, flag: boolean)
	if not flag then
		return scraps:FindFirstChild(childName)
	end

	local v2 = v[childName]
	local child = v2 and scraps:FindFirstChild(v2)

	if child then
		return child
	end

	return scraps:FindFirstChild(childName)
end

local _WorldOrigin = workspace._WorldOrigin

local function RecolorMagnetColor(instance, p)
	if typeof(instance) == "Instance" and instance.Parent then
		return WrapColor3Constructor(p, instance, "MagnetFruitVFXColor")
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v2 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v2 = math.max(v2, emitter.Lifetime.Max)
			end
		end

		task.wait(v2)
		folder:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function QuadBezier(position, p, p2, p3)
	return position:Lerp(p, p3):Lerp(p:Lerp(p2, p3), p3)
end

local function ArcFly(clone, startCFrame, targetPosition, p)
	local position = startCFrame.Position
	local v2 = math.clamp((position - targetPosition).Magnitude * 0.6, 15, 75)
	local v3 = (position + targetPosition) / 2 + Vector3.new(0, v2, 0)
	local lastTime = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v4 = (os.clock() - lastTime) / p

		if v4 >= 1 then
			clone:PivotTo(CFrame.lookAt(targetPosition, targetPosition + (targetPosition - position).Unit))
			heartbeatConnection:Disconnect()
		else
			local quadBezier = QuadBezier(position, v3, targetPosition, v4) -- equivalent call inferred; original call site unknown
			local unit = (targetPosition - quadBezier).Unit
			clone:PivotTo(CFrame.lookAt(quadBezier, quadBezier + unit))
		end
	end)
end

local function AlignCFrame(data, normal)
	local v2 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v2).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v2).Unit
	return CFrame.fromMatrix(p, unit2, v2, unit3)
end

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(...)
	local v2 = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 25)
	local curveSize2 = math.random(5, 25)
	v2.CurveSize0 = curveSize
	v2.CurveSize1 = curveSize2
	v2.MinRadius = 3
	v2.MaxRadius = 13
	v2.Frequency = 0.5
	v2.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v2.MinThicknessMultiplier = 0.2
	v2.MaxThicknessMultiplier = maxThicknessMultiplier
	v2.MinTransparency = 0
	v2.MaxTransparency = 1
	v2.PulseSpeed = 10
	v2.PulseLength = 1000000
	v2.FadeLength = 0.2
	v2.ContractFrom = 0.5
	v2.Color = Color3.new(1, 0.380392, 0.380392)
	v2.ColorOffsetSpeed = 3
	return v2
end

local function Explosion(cframe, folder, raycastParams)
	local function Scale(instance, p)
		local position = cframe.Position

		if instance.ClassName ~= "Model" then
			local model = Instance.new("Model")
			model.Parent = instance.Parent
			instance.Parent = model
			instance = model
		end

		instance:ScaleTo(p)
		local v2 = position + (instance:GetPivot().Position - position) * p
		instance:PivotTo(instance:GetPivot().Rotation + v2)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DestroyAfter(clone, duration)
		task.delay(duration, function()
			clone:Destroy()
		end)
	end

	local function RockCrater(p, parent, data)
		task.spawn(function()
			local rockType = data.RockType
			local radius = data.Radius
			local size = data.Size
			local duration = data.Duration
			local amount = data.Amount
			local v2 = AlignCFrame(CFrame.new(p.Position), p.Normal) + p.Normal * 0.01
			local v3 = {}

			for _ = 1, amount do
				local clone = rockType:Clone()
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = parent
				DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
				table.insert(v3, clone)
			end

			task.spawn(function()
				task.wait(duration * 3)

				for _, v4 in pairs(v3) do
					v4:Destroy()
				end

				v3 = nil
			end)
			local v4 = 360 / #v3
			local total = 0

			for _, v5 in pairs(v3) do
				total += v4
				v5.CFrame = v2 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
				v5.CFrame = CFrame.new(v5.Position, p.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-150, 250) / 7
				)
				local ray = Ray.new(v5.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local part, v6 = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)

				if part then
					local v7 = (v5.Position - p.Position).Magnitude / 200
					local v8 = size * math.random(20, 40) / 10
					local v9 = size * math.random(10, 30) / 10
					local v10 = size * math.random(30, 50) / 10
					v5.Size = Vector3.new(v8 * v7, v9 * v7, v10 * v7)
					v5.Position = v6 + Vector3.new(0, -v5.Size.Y * math.random(5, 6) / 15, 0)
					v5.CFrame = CFrame.new(v5.Position, p.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 3,
						math.random(-25, 25) / 2
					)
					v5.CFrame = CFrame.new(
						v5.Position,
						v2.Position + Vector3.new(0, math.random(-55, -45) / 100 + v5.Size.Y / 200, 0)
					) * CFrame.Angles(math.rad(-math.random(10, 15) / 1 - 60 * v7), 0, 0) * CFrame.Angles(
						0,
						0,
						(math.rad((math.random(-5, 5))))
					)
					v5.Material = part.Material
					v5.Color = part.Color
				else
					v5:Destroy()
					v3[v5] = nil
				end

				TweenService:Create(v5, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v5.Position + Vector3.new(0, v5.Size.Y * math.random(3, 5) / 10, 0)
				}):Play()
				local v7 = v5
				local v8 = v5
				task.spawn(function()
					task.wait(duration + math.random(10, 35) / 100)
					local tween = TweenService:Create(
						v7,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Back,
							Enum.EasingDirection.In,
							0,
							false,
							math.random(10, 35) / 100
						),
						{
							Position = v7.Position + Vector3.new(
								math.random(-1, 1),
								-v7.Size.Y * math.random(20, 25) / 10,
								math.random(-1, 1)
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v7:Destroy()
					v3[v7] = nil
				end)
			end
		end)
	end

	local function FlyRock(cFrame, raycastResult, parent)
		local clone = x_Attract_Held.Rock:Clone()
		rocks:ApplyCollision(clone, nil, true)
		clone.CFrame = cFrame
		clone.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
		clone.Size *= math.random(3, 6) / 3
		clone.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
		clone.Material = raycastResult.Instance.Material
		clone.Color = raycastResult.Instance.Color
		clone.CanCollide = false
		clone.Parent = parent
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(70000000000, 70000000000, 70000000000)
		bodyVelocity.P = 5000
		bodyVelocity.Parent = clone
		local vector2 = Vector3.new(math.random(-30, 30) * 2, 0, math.random(-30, 30) * 2)
		local vector3 = Vector3.new(0, math.random(150, 200) / 1.5, 0)
		local v2 = math.random(50, 250) * 1.25
		bodyVelocity.Velocity = CFrame.new(clone.Position, clone.Position + vector2 + vector3).LookVector * v2
		task.delay(1 * math.random() + 2.5, function()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				Size = createVector(0, 0, 0)
			}):Play()
		end)
		task.delay(0.025 * math.random() + 0.025, function()
			bodyVelocity:Destroy()
			task.wait(0.1)
			clone.CanCollide = true
		end)
	end

	local raycastResult = workspace:Raycast(
		cframe.Position + createVector(0, 1, 0),
		createVector(-0, -25, -0),
		raycastParams
	)

	if not raycastResult then
		return
	end

	local v2 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
	local v3 = {
		Radius = 74.25,
		Size = 14.850000000000001,
		Duration = 0.7,
		Amount = 25,
		RockType = x_Attract_Held.CraterRock
	}
	task.spawn(function()
		local rockType = v3.RockType
		local radius = v3.Radius
		local size = v3.Size
		local duration = v3.Duration
		local amount = v3.Amount
		local v4 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		local v5 = {}

		for _ = 1, amount do
			local clone = rockType:Clone()
			rocks:ApplyCollision(clone, nil, true)
			clone.Parent = folder
			DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
			table.insert(v5, clone)
		end

		task.spawn(function()
			task.wait(duration * 3)

			for _, v6 in pairs(v5) do
				v6:Destroy()
			end

			v5 = nil
		end)
		local v6 = 360 / #v5
		local total = 0

		for _, v7 in pairs(v5) do
			total += v6
			v7.CFrame = v4 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
			v7.CFrame = CFrame.new(v7.Position, raycastResult.Position) * CFrame.new(
				0,
				math.random(-5, 5) / 3,
				math.random(-150, 250) / 7
			)
			local ray = Ray.new(v7.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
			local part, v8 = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)

			if part then
				local v9 = (v7.Position - raycastResult.Position).Magnitude / 200
				local v10 = size * math.random(20, 40) / 10
				local v11 = size * math.random(10, 30) / 10
				local v12 = size * math.random(30, 50) / 10
				v7.Size = Vector3.new(v10 * v9, v11 * v9, v12 * v9)
				v7.Position = v8 + Vector3.new(0, -v7.Size.Y * math.random(5, 6) / 15, 0)
				v7.CFrame = CFrame.new(v7.Position, raycastResult.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-25, 25) / 2
				)
				v7.CFrame = CFrame.new(
					v7.Position,
					v4.Position + Vector3.new(0, math.random(-55, -45) / 100 + v7.Size.Y / 200, 0)
				) * CFrame.Angles(math.rad(-math.random(10, 15) / 1 - 60 * v9), 0, 0) * CFrame.Angles(
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

			TweenService:Create(v7, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = v7.Position + Vector3.new(0, v7.Size.Y * math.random(3, 5) / 10, 0)
			}):Play()
			local v9 = v7
			local v10 = v7
			task.spawn(function()
				task.wait(duration + math.random(10, 35) / 100)
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
	task.spawn(function()
		for i = 1, 20 do
			task.spawn(function()
				FlyRock(
					v2 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
						0,
						0,
						-math.random(125, 175) / 1.5
					),
					raycastResult,
					folder
				)
			end)

			if i % 2 == 0 then
				task.wait(0.001 * math.random())
			end
		end
	end)
	return raycastResult
end

local function getArmAnim(instance, p: string, p2: string)
	local magnetArms = instance:FindFirstChild("MagnetArms")

	if not magnetArms then
		warn("Magnet Arms Folder missing!")
		return
	end

	local child = magnetArms:FindFirstChild("Floating" .. p2 .. "Arm")
	local v2 = child and Util.Anims:Get(child, p)
	return v2 or nil
end

return function(data)
	local origin = data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		return
	end

	if stage == 2 then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 10)
		local root = data.Root
		local position = root.Position
		local raycastParams = RaycastParams.new()
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local startCFrame = data.StartCFrame
		Util.Sound:Play("Magnet_Untransformed_X_Held_Release_01", startCFrame.Position)
		local clone = x_Attract_Held.Phase1.StartImpact:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, folder, data.Player, "MagnetFruitVFXColor")
		local magnetArms = root.Parent:FindFirstChild("MagnetArms")
		local v2

		if magnetArms then
			local floatingLeftArm = magnetArms:FindFirstChild("FloatingLeftArm")
			v2 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Untr_ X Held End L") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		local magnetArms2 = root.Parent:FindFirstChild("MagnetArms")
		local v3

		if magnetArms2 then
			local floatingRightArm = magnetArms2:FindFirstChild("FloatingRightArm")
			v3 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Untr_ X Held End R") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v2 and v3 then
			v2.Looped = false
			v3.Looped = false
			v2:Play()
			v3:Play()
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 0.85, lifetime.Max * 0.85)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		local clone2 = hasCrimsonGoldSkin(data.Player) and x_Attract_Held.Phase1.ArcsteelMagnetModel:Clone() or x_Attract_Held.Phase1.MagnetModel:Clone()
		clone2:PivotTo(startCFrame)
		Util.SetParentOverrideWithColor(clone2, folder, data.Player, "MagnetFruitVFXColor")
		local _ = clone2.Highlight
		local aura = clone2.Aura

		for _, effect in pairs(aura:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		local maxRange = data.MaxRange
		local targetPosition = data.TargetPosition
		local v4 = math.clamp(math.clamp((position - targetPosition).Magnitude, 6, maxRange) / maxRange, 0, 1) ^ 0.8 * 0.24999999999999997 + 0.1
		ArcFly(clone2, startCFrame, targetPosition, v4)
		local v5 = {}
		local v6 = false
		task.spawn(function()
			local now = tick()
			local primaryPart = clone2.PrimaryPart

			repeat
				if now - tick() <= 0 then
					now = tick() + 0.1

					for i = 1, 3 do
						local v7 = i
						task.spawn(function()
							if v7 == 1 then
								local v8 = primaryPart.Position + Vector3.new(
									math.random(-25, 25),
									0,
									math.random(-25, 25)
								)
								local raycastResult = workspace:Raycast(
									v8 + createVector(0, 1, 0),
									createVector(-0, -100, -0),
									raycastParams
								)

								if raycastResult then
									for i2 = 1, math.random(1, 2) do
										task.spawn(function()
											local clone3 = script.Part:Clone()
											clone3.CFrame = CFrame.new(primaryPart.Position, raycastResult.Position)
											Util.SetParentOverrideWithColor(
												clone3,
												folder,
												data.Player,
												"MagnetFruitVFXColor"
											)
											clone3.Anchored = false
											clone3.Weld.Part1 = primaryPart
											clone3.Massless = true
											clone3.Weld.C0 = CFrame.new(
												math.random(-5, 5),
												math.random(-5, 5) / 3,
												math.random(-5, 5) / 5
											)
											clone3.Attach1:SetAttribute("Pos", raycastResult.Position)
											local shafiBolt = ShafiBolt(
												clone3.Attach0,
												clone3.Attach1,
												math.random(8, 12) * 1.25,
												0.75,
												folder
											)
											local player = data.Player
											local color = Color3.fromRGB(34, 45, 255)

											if typeof(player) == "Instance" and player.Parent then
												color = WrapColor3Constructor(color, player, "MagnetFruitVFXColor")
											end

											shafiBolt.Color = color
											shafiBolt.CurveSize0 = math.random(-25, 25)
											shafiBolt.CurveSize0 = math.random(-25, 25)
											v5[clone3.Attach1] = shafiBolt
											task.wait(0.05 * math.random() + 0.1)

											if v5[clone3.Attach1] == nil then
												return
											end

											v5[clone3.Attach1] = nil
											shafiBolt:Destroy()
										end)
									end
								end
							else
								local v8 = primaryPart.Position + Vector3.new(
									math.random(-25, 25) * 2,
									math.random(-50, -25) / 2,
									math.random(-25, 25)
								)

								for i2 = 1, math.random(1, 2) do
									task.spawn(function()
										local clone3 = script.Part:Clone()
										clone3.CFrame = CFrame.new(primaryPart.Position, v8)
										Util.SetParentOverrideWithColor(
											clone3,
											folder,
											data.Player,
											"MagnetFruitVFXColor"
										)
										clone3.Anchored = false
										clone3.Weld.Part1 = primaryPart
										clone3.Massless = true
										clone3.Weld.C0 = CFrame.new(
											math.random(-5, 5),
											math.random(-5, 5) / 3,
											math.random(-5, 5) / 5
										)
										clone3.Attach1:SetAttribute("Pos", v8)
										local shafiBolt = ShafiBolt(
											clone3.Attach0,
											clone3.Attach1,
											math.random(8, 12) * 1.25,
											0.75,
											folder
										)
										local player = data.Player
										local color = Color3.fromRGB(69, 69, 255)

										if typeof(player) == "Instance" and player.Parent then
											color = WrapColor3Constructor(color, player, "MagnetFruitVFXColor")
										end

										shafiBolt.Color = color
										shafiBolt.CurveSize0 = math.random(-25, 25)
										shafiBolt.CurveSize0 = math.random(-25, 25)
										v5[clone3.Attach1] = shafiBolt
										task.wait(0.1 * math.random() + 0.1)

										if v5[clone3.Attach1] == nil then
											return
										end

										v5[clone3.Attach1] = nil
										shafiBolt:Destroy()
									end)
								end
							end
						end)
					end
				end

				for k, _ in pairs(v5) do
					local pos = k:GetAttribute("Pos")

					if k:GetAttribute("Dontmove") == nil then
						k.WorldPosition = CFrame.new(pos, primaryPart.Position) * createVector(0, 0, -5)
					else
						k.WorldPosition = pos
						print("??")
					end
				end

				task.wait()
			until v6 == true
		end)
		task.wait(v4)
		v6 = true

		for _, effect in pairs(aura:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local v7 = 5
		local position2 = clone2.PrimaryPart.Position
		local raycastResult = workspace:Raycast(
			position2 + createVector(0, 3, 0),
			CFrame.new(position2).UpVector * -22.5,
			raycastParams
		)
		local v8 = 17.625
		local v9 = false
		local v10

		if raycastResult then
			targetPosition = raycastResult.Position
			print((clone2.PrimaryPart.Position - targetPosition).Magnitude)
			print("HIT")
			v10 = v8 - (clone2.PrimaryPart.Position - targetPosition).Magnitude
			v9 = true
			v7 = 3
		else
			v10 = v8 / 2
		end

		local cFrame = clone2.PrimaryPart.CFrame
		local lookVector = cFrame.LookVector
		local unit = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
		local cframe = CFrame.lookAt(cFrame.Position, cFrame.Position + unit, createVector(0, 1, 0))
		TweenService:Create(clone2.PrimaryPart, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = cframe * CFrame.new(0, v10, 0)
		}):Play()
		Util.Sound:Play("Magnet_Untransformed_X_Held_Charge_And_Explode_01", cframe.Position)
		local clone3 = x_Attract_Held.Phase2.MagnetAuraModel:Clone()
		local primaryPart = clone3.PrimaryPart
		primaryPart.CFrame = cframe
		Util.SetParentOverrideWithColor(clone3, folder, data.Player, "MagnetFruitVFXColor")

		for _, emitter in pairs(primaryPart:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local clone4

		if v9 == true then
			local clone5 = x_Attract_Held.Phase2.GroundCrack:Clone()
			clone5.CFrame = CFrame.new(targetPosition + createVector(0, 1.5, 0))
			Util.SetParentOverrideWithColor(clone5, folder, data.Player, "MagnetFruitVFXColor")

			if (workspace.CurrentCamera.CFrame.p - targetPosition).Magnitude < 120 then
				Util.CameraShaker:ShakeOnce(5, 3, 0.2, 0.6)
			end

			DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 0.85, lifetime.Max * 0.85)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			clone4 = x_Attract_Held.Phase2.GroundAuraModel:Clone()
			clone4:PivotTo(CFrame.new(targetPosition + createVector(0, 1.5, 0)))
			Util.SetParentOverrideWithColor(clone4, folder, data.Player, "MagnetFruitVFXColor")
		else
			clone4 = nil
		end

		task.spawn(function()
			for i = 450, 150, -3 do
				if not (clone3 and clone3.Parent) then
					break
				end

				clone3:ScaleTo(i / 100)

				if v9 == true and clone4 ~= nil then
					clone4:ScaleTo(i / 100)
				end

				task.wait(0)
			end
		end)
		task.spawn(function()
			local lastTime = tick()
			local now = tick()
			tick()

			while tick() - lastTime < 1.5 and clone2 and clone2.Parent do
				clone2:PivotTo(clone2:GetPivot() + Vector3.new(
					math.noise(os.clock() * 35, 0, 0),
					math.noise(0, os.clock() * 35, 0),
					math.noise(0, 0, os.clock() * 35)
				) * 10)

				if v9 == true and now - tick() <= 0 then
					now = tick() + 0.1

					for _ = 1, math.random(1, 3) do
						task.spawn(function()
							local clone5 = x_Attract_Held.Rock:Clone()
							rocks:ApplyCollision(clone5, nil, true)
							local cFrame2 = cframe * CFrame.new(0, -3, 0) * CFrame.new(
								math.random(-50, 50) * 2,
								0,
								math.random(-50, 50) * 2
							)
							clone5.CFrame = cFrame2
							clone5.Anchored = true
							clone5.CanCollide = false
							clone5.Material = raycastResult.Instance.Material
							clone5.Color = raycastResult.Instance.Color
							clone5.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
							clone5.Size *= math.random(3, 6) / 2
							Util.SetParentOverrideWithColor(clone5, folder, data.Player, "MagnetFruitVFXColor")
							local tween = TweenService:Create(
								clone5,
								TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									CFrame = cFrame2 * CFrame.new(0, math.random(5, 50), 0)
								}
							)
							local cframe2 = CFrame.new(clone2:GetPivot().Position)
							local tween2 = TweenService:Create(
								clone5,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									CFrame = cframe2,
									Size = createVector(0, 0, 0)
								}
							)
							local tween3 = TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Linear), {
								Orientation = clone5.Orientation + Vector3.new(
									math.random(-360, 360),
									math.random(-360, 360),
									math.random(-360, 360)
								)
							})
							tween:Play()
							tween3:Play()
							task.delay(0.15, function()
								tween2:Play()
								task.wait(0.35)
								clone5:Destroy()
							end)
						end)
					end

					task.spawn(function()
						local scrapModelA

						if hasCrimsonGoldSkin(data.Player) then
							local scrapModelA2 = v.ScrapModelA
							scrapModelA = scrapModelA2 and scraps:FindFirstChild(scrapModelA2)

							if not scrapModelA then
								scrapModelA = scraps:FindFirstChild("ScrapModelA")
							end
						else
							scrapModelA = scraps:FindFirstChild("ScrapModelA")
						end

						scrapModelA:ScaleTo(3.75)
						local children = scrapModelA:GetChildren()
						local v12 = {}

						for _ = 1, math.random(1, 2) do
							local clone5 = children[math.random(1, #children)]:Clone()
							local cFrame2 = cframe * CFrame.new(0, -3, 0) * CFrame.new(
								math.random(-50, 50) * 2,
								0,
								math.random(-50, 50) * 2
							)
							clone5.CFrame = cFrame2
							clone5.Anchored = true
							clone5.CanCollide = false
							Util.SetParentOverrideWithColor(clone5, folder, data.Player, "MagnetFruitVFXColor")
							v12[clone5] = clone5
							local tween = TweenService:Create(
								clone5,
								TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									CFrame = cFrame2 * CFrame.new(0, math.random(5, 50), 0)
								}
							)
							local cframe2 = CFrame.new(clone2:GetPivot().Position)
							local tween2 = TweenService:Create(
								clone5,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									CFrame = cframe2,
									Size = createVector(0, 0, 0)
								}
							)
							local tween3 = TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Linear), {
								Orientation = clone5.Orientation + Vector3.new(
									math.random(-360, 360),
									math.random(-360, 360),
									math.random(-360, 360)
								)
							})
							tween:Play()
							tween3:Play()
							task.delay(0.15, function()
								tween2:Play()
								task.wait(0.35)
								clone5:Destroy()
							end)
						end
					end)
				end

				task.wait()
			end
		end)
		task.delay(1.425, function()
			local clone5 = x_Attract_Held.Phase3.ExStartImpact:Clone()
			clone5.CFrame = cframe
			Util.SetParentOverrideWithColor(clone5, folder, data.Player, "MagnetFruitVFXColor")
			DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
		task.spawn(function()
			local scrapModelA2

			if hasCrimsonGoldSkin(data.Player) then
				local scrapModelA22 = v.ScrapModelA2
				scrapModelA2 = scrapModelA22 and scraps:FindFirstChild(scrapModelA22)

				if not scrapModelA2 then
					scrapModelA2 = scraps:FindFirstChild("ScrapModelA2")
				end
			else
				scrapModelA2 = scraps:FindFirstChild("ScrapModelA2")
			end

			local scrapModelA3 = scraps.ScrapModelA3
			scrapModelA2:ScaleTo(7)
			scrapModelA3:ScaleTo(1)
			local clones = {}

			local function CreateScrapPrisonSphere(cframe2, folder2)
				for i = 1, 40 do
					local v11 = i
					task.spawn(function()
						local v12

						if v11 % 10 == 0 then
							v12 = scrapModelA3
						else
							v12 = scrapModelA2

							if math.random(1, 7) == 1 then
								v12 = scrapModelA3
							end
						end

						local children = v12:GetChildren()

						if #children == 0 then
							return
						end

						local clone5 = children[math.random(1, #children)]:Clone()
						Util.SetParentOverrideWithColor(clone5, folder2, data.Player, "MagnetFruitVFXColor")
						table.insert(clones, clone5)
						local v13 = 1 - v11 / 39 * 2
						local v14 = math.sqrt(1 - v13 * v13)
						local v15 = 2.399963229728653 * v11
						local v16 = Vector3.new(math.cos(v15) * v14, v13, math.sin(v15) * v14) * 20
						local v17 = cframe2.Position + v16
						local cframe3 = CFrame.lookAt(v17, cframe2.Position)
						local v18 = cframe2.Position + Vector3.new(
							math.random(-60, 60) * 3,
							math.random(-60, 60),
							math.random(-60, 60) * 3
						)
						clone5:PivotTo(CFrame.new(v18, cframe2.Position))
						local unit2 = (cframe2.Position - v18).Unit
						clone5:PivotTo(CFrame.lookAt(v18, v18 + unit2))
						TweenService:Create(
							clone5,
							TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								CFrame = CFrame.lookAt(v17, v18 + unit2)
							}
						):Play()
						task.spawn(function()
							task.wait(0.3)
							TweenService:Create(
								clone5,
								TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									CFrame = cframe3
								}
							):Play()
						end)
					end)
					task.wait(0.0205)
				end
			end

			task.spawn(function()
				CreateScrapPrisonSphere(CFrame.new(targetPosition + createVector(0, 10, 0)), folder)
			end)
			task.wait(1.85)
			local position3 = CFrame.new(targetPosition + createVector(0, 10, 0)).Position

			for _, v11 in ipairs(clones) do
				if not (v11 and v11.Parent) then
					continue
				end

				v11.Anchored = false
				v11.CanCollide = true
				v11.AssemblyLinearVelocity = (v11.Position - position3).Unit * math.random(90, 160) + Vector3.new(
					math.random(-25, 25),
					math.random(15, 60),
					math.random(-25, 25)
				)
				v11.AssemblyAngularVelocity = Vector3.new(
					math.random(-20, 20),
					math.random(-20, 20),
					math.random(-20, 20)
				)
				local v12 = v11
				task.delay(0.5 + math.random() * 0.5, function()
					TweenService:Create(v12, TweenInfo.new(0.25), {
						Size = createVector(0, 0, 0)
					}):Play()

					if v12:GetAttribute("ROD") then
						for i, child in pairs(v12:GetChildren()) do
							TweenService:Create(child, TweenInfo.new(0.25), {
								Size = createVector(0, 0, 0)
							}):Play()
						end
					end
				end)
			end
		end)
		task.spawn(function()
			local v11 = tick() + 1.5
			tick()
			tick()
			local clone5 = x_Attract_Held.Phase2.Shockwave:Clone()
			clone5.CFrame = CFrame.new(targetPosition + createVector(0, 1, 0))
			Util.SetParentOverrideWithColor(clone5, folder, data.Player, "MagnetFruitVFXColor")
			local emittersByEmitter = {}

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emittersByEmitter[emitter] = emitter
				end
			end

			repeat
				task.spawn(function()
					local clone6 = x_Attract_Held.Phase2.SpinSlash:Clone()
					clone6:PivotTo(CFrame.new(targetPosition + createVector(0, 1, 0)))
					Util.SetParentOverrideWithColor(clone6, folder, data.Player, "MagnetFruitVFXColor")
					local model = clone6.Model
					local model2 = clone6.Model2

					for i = 1, 3 do
						local v12 = i * 1.05 + 10
						local v13 = 1
						local clone7

						if i == 1 then
							clone7 = model:Clone()
						else
							clone7 = model2:Clone()
							v13 = 1.5
						end

						clone7:ScaleTo(v12 / (v13 / 1.25))

						for _, beam in pairs(clone7:GetDescendants()) do
							if beam:IsA("Beam") then
								beam.Enabled = true
							end
						end

						local primaryPart2 = clone7.PrimaryPart
						local v14 = clone6.PrimaryPart.CFrame * CFrame.new(0, v12, 0) * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)

						if i == 1 then
							v14 = clone6.PrimaryPart.CFrame * CFrame.new(0, v12, 0) * CFrame.Angles(
								0,
								math.rad((math.random(-180, 180))),
								0
							)
						end

						local angularVelocity = primaryPart2.AngularVelocity
						primaryPart2.Anchored = false
						primaryPart2.AlignPosition.Position = primaryPart2.Position + Vector3.new(
							math.random(-10, 10) / 10,
							0,
							math.random(-10, 10) / 10
						)
						angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15), 0)
						clone7:PivotTo(v14)
						Util.SetParentOverrideWithColor(clone7, clone6, data.Player, "MagnetFruitVFXColor")
						clone7:GetScale()
						task.spawn(function()
							task.spawn(function()
								local Y = clone7.Slash.Position.Y
								TweenService:Create(
									angularVelocity,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
											math.random(-5, 5) / 2,
											math.random(5, 15),
											math.random(-5, 5) / 2
										)
									}
								):Play()
							end)
							task.wait(0.1 * math.random() + 0.1 / v13)

							for i2, effect in pairs(clone7:GetDescendants()) do
								if effect:IsA("Beam") then
									TweenService:Create(
										effect,
										TweenInfo.new(0.15 / v13 + math.random() * 0.15 / v13),
										{
											Width0 = 0,
											Width1 = 0
										}
									):Play()
									local v16 = effect
									task.delay(1, function()
										v16:Destroy()
									end)
								elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end

							task.wait(1)
							angularVelocity.Enabled = false
						end)
					end

					model:Destroy()
					task.spawn(function()
						local v12 = clone6:GetScale() * 1.5
						local v13 = v12 * 2.25

						for i = v12 * 100, v13 * 100, 5 do
							clone6:ScaleTo(i / 100)
							task.wait(0.005)
						end
					end)
				end)

				for _, emitter in pairs(emittersByEmitter) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") * 1.5)
					end
				end

				task.spawn(function()
					for i = 1, 10 do
						local v12 = i
						task.spawn(function()
							local clone6 = script.Part:Clone()
							local cFrame2 = CFrame.new(targetPosition) * CFrame.new(0, 15 + math.random(0, 10), 0) * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							)
							clone6.CFrame = cFrame2
							Util.SetParentOverrideWithColor(clone6, folder, data.Player, "MagnetFruitVFXColor")
							clone6.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, 70 * math.random(12, 20) / 10).Position
							local shafiBolt = ShafiBolt(
								clone6.Attach0,
								clone6.Attach1,
								math.random(8, 12) * 1.25,
								0.75,
								folder
							)
							shafiBolt.Frequency = math.random(5, 10) * 2
							shafiBolt.MaxRadius = 12
							shafiBolt.AnimationSpeed = math.random(20, 50) / 10
							local player = data.Player
							local color = Color3.fromRGB(58, 61, 255)

							if typeof(player) == "Instance" and player.Parent then
								color = WrapColor3Constructor(color, player, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color

							if v12 % 2 == 0 then
								local player2 = data.Player
								local color2 = Color3.fromRGB(88, 73, 255)

								if typeof(player2) == "Instance" and player2.Parent then
									color2 = WrapColor3Constructor(color2, player2, "MagnetFruitVFXColor")
								end

								shafiBolt.Color = color2
								shafiBolt.Thickness = 1
							end

							task.spawn(function()
								task.wait(0.05 + math.random() * 0.115)
								shafiBolt:Destroy()
							end)
						end)
					end
				end)
				task.wait(0.125)
			until v11 - tick() <= 0
		end)
		task.wait(1.5)

		for _, emitter in pairs(primaryPart:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		if clone4 ~= nil then
			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		clone2:Destroy()
		targetPosition += createVector(0, 10, 0)
		local v11 = tick() + 0.275

		for i = 1, 10 do
			local v12 = i
			task.spawn(function()
				task.wait(math.random() * 0.225)
				local clone5 = x_Attract_Held.Phase3.Ray:Clone()
				clone5:ScaleTo(math.random(40, 80) / 10)
				local crackBeam = clone5.CrackBeam
				local v13 = 1 - v12 / 9 * 2
				local v14 = math.sqrt(1 - v13 * v13)
				local v15 = 2.399963229728653 * v12
				local unit2 = Vector3.new(math.cos(v15) * v14, v13, math.sin(v15) * v14).Unit
				local v16 = targetPosition + unit2 * 15
				crackBeam.CFrame = CFrame.lookAt(v16, targetPosition) * CFrame.new(0, 0, -math.random(15, 25))
				Util.SetParentOverrideWithColor(clone5, folder, data.Player, "MagnetFruitVFXColor")
				local v17 = math.random(35, 75)
				local attach1 = crackBeam.Attach1
				local v18 = math.random(10, 25) / 100
				attach1.Position = createVector(0, 0, 0)
				TweenService:Create(attach1, TweenInfo.new(v18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = Vector3.new(0, 0, -v17)
				}):Play()
				task.delay(v11 - tick(), function()
					clone5:Destroy()
				end)
			end)
		end

		task.wait(0.25)
		local clone5 = x_Attract_Held.Phase3.ExplosionFinalModel:Clone()
		clone5:ScaleTo(2.75)
		local primaryPart2 = clone5.PrimaryPart
		primaryPart2.CFrame = cframe
		Util.SetParentOverrideWithColor(clone5, folder, data.Player, "MagnetFruitVFXColor")

		if (workspace.CurrentCamera.CFrame.p - cframe.Position).Magnitude < 150 then
			Util.CameraShaker:ShakeOnce(10, 8, 0.2, 0.6)
		end

		DeleteImpactAfterDuration(primaryPart2) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(primaryPart2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v12 = emitter
			task.spawn(function()
				if v12:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v12:GetAttribute("EmitDelay"))
				end

				local lifetime = v12.Lifetime
				v12.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
				v12:Emit(v12:GetAttribute("EmitCount") * 1.25)
			end)
		end

		task.spawn(function()
			for i = 1, v7 do
				local v12 = 12
				local v13 = 0.15
				local v14 = 10
				local cFrame2 = CFrame.new(cframe.Position) * CFrame.new(0, 10, 0)

				if i == 2 then
					v13 = 0.1
					v14 = 25
					v12 = 9
				elseif i == 3 then
					v13 = 0.085
					v14 = 50
					v12 = 5
				elseif i == 4 then
					v13 = 0.1
					v14 = -25
					v12 = 9
				elseif i == 5 then
					v13 = 0.085
					v14 = -50
					v12 = 5
				end

				local clone6 = x_Attract_Held.Phase2.StartBeam:Clone()
				clone6.CFrame = cFrame2
				Util.SetParentOverrideWithColor(clone6, folder, data.Player, "MagnetFruitVFXColor")
				TweenService:Create(clone6, TweenInfo.new(v13, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone6.CFrame * CFrame.new(0, v14, 0)
				}):Play()

				for _, descendant in pairs(clone6:GetDescendants()) do
					if descendant:IsA("Beam") then
						local v16 = descendant
						task.spawn(function()
							TweenService:Create(
								v16,
								TweenInfo.new(v13 / 2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									CurveSize0 = v16.CurveSize0 * v12,
									CurveSize1 = v16.CurveSize1 * v12,
									Width0 = v16.Width0,
									Width1 = v16.Width1
								}
							):Play()
							task.wait(v13 / 2)
							local tween = TweenService:Create(
								v16,
								TweenInfo.new(v13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v16:Destroy()
						end)
					elseif descendant:IsA("Attachment") then
						local tweenInfo = TweenInfo.new(v13 / 2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
						local v18 = descendant.Position.X * v12
						local v19 = descendant.Position.Y * v12
						TweenService:Create(descendant, tweenInfo, {
							Position = Vector3.new(v18, v19, descendant.Position.Z * v12)
						}):Play()
					end
				end

				task.wait(0.0025)
			end
		end)
		task.spawn(function()
			for i = 1, v7 do
				local v12 = i
				task.spawn(function()
					local v13 = 10
					local clone6 = x_Attract_Held.Phase3.SpinSlash:Clone()
					clone6:PivotTo(cframe * CFrame.new(0, 10, 0))
					Util.SetParentOverrideWithColor(clone6, folder, data.Player, "MagnetFruitVFXColor")

					if v12 == 2 then
						clone6:PivotTo(cframe * CFrame.new(0, 25, 0))
						v13 = 8
					elseif v12 == 3 then
						clone6:PivotTo(cframe * CFrame.new(0, 50, 0))
						v13 = 5
					elseif v12 == 4 then
						clone6:PivotTo(cframe * CFrame.new(0, -25, 0))
						v13 = 8
					elseif v12 == 5 then
						clone6:PivotTo(cframe * CFrame.new(0, -50, 0))
						v13 = 5
					end

					local model = clone6.Model

					for i2 = 1, 3 do
						local v14 = v13 + i2 * 1.05
						local clone7 = model:Clone()
						clone7:ScaleTo(v14)
						local primaryPart3 = clone7.PrimaryPart
						local v15 = clone6.PrimaryPart.CFrame * CFrame.new(0, v14, 0) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						)
						local angularVelocity = primaryPart3.AngularVelocity
						primaryPart3.Anchored = false
						primaryPart3.AlignPosition.Position = primaryPart3.Position + Vector3.new(
							math.random(-10, 10) / 10,
							0,
							math.random(-10, 10) / 10
						)
						angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15), 0)
						clone7:PivotTo(v15)
						Util.SetParentOverrideWithColor(clone7, clone6, data.Player, "MagnetFruitVFXColor")
						clone7:GetScale()
						local folder2 = clone7
						task.spawn(function()
							task.spawn(function()
								local Y = folder2.Slash.Position.Y
								TweenService:Create(
									angularVelocity,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
											math.random(-5, 5) / 2,
											math.random(5, 15),
											math.random(-5, 5) / 2
										)
									}
								):Play()
							end)
							task.wait(0.1 * math.random() + 0.1)

							for i3, effect in pairs(folder2:GetDescendants()) do
								if effect:IsA("Beam") then
									TweenService:Create(effect, TweenInfo.new(0.15 + math.random() * 0.15), {
										Width0 = 0,
										Width1 = 0
									}):Play()
									local v17 = effect
									task.delay(1, function()
										v17:Destroy()
									end)
								elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end

							task.wait(1)
							angularVelocity.Enabled = false
						end)
					end

					model:Destroy()
					task.spawn(function()
						local scale = clone6:GetScale()
						local v14 = scale * 1.5

						for i2 = scale * 100, v14 * 100, 3 do
							clone6:ScaleTo(i2 / 100)
							task.wait(0.005)
						end
					end)
				end)
			end
		end)
		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams2.IgnoreWater = false
		raycastParams2.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		Explosion(cframe, folder, raycastParams2)
		task.spawn(function()
			local clone6 = x_Attract_Held.Phase3.Sphere:Clone()
			clone6.Size = createVector(62.5, 62.5, 62.5)
			clone6.CFrame = CFrame.new(
				cframe.Position + createVector(0, 15, 0),
				workspace.CurrentCamera.CFrame.Position
			) * CFrame.Angles(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
			Util.SetParentOverrideWithColor(clone6, folder, data.Player, "MagnetFruitVFXColor")
			task.spawn(function()
				TweenService:Create(clone6, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = clone6.Size * 3.7
				}):Play()

				for _, decal in pairs(clone6:GetDescendants()) do
					if not decal:IsA("Decal") then
						continue
					end

					decal.Transparency = 0.5
					TweenService:Create(decal, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
						Transparency = 1
					}):Play()
				end
			end)
			task.spawn(function()
				local clone7 = x_Attract_Held.Phase3.Sphere1:Clone()
				clone7.Size = createVector(62.5, 62.5, 62.5)
				clone7.CFrame = CFrame.new(
					cframe.Position + createVector(0, 15, 0),
					workspace.CurrentCamera.CFrame.Position
				) * CFrame.Angles(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
				Util.SetParentOverrideWithColor(clone7, folder, data.Player, "MagnetFruitVFXColor")
				task.spawn(function()
					TweenService:Create(clone7, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = clone7.Size * 3.7
					}):Play()

					for _, decal in pairs(clone7:GetDescendants()) do
						if not decal:IsA("Decal") then
							continue
						end

						decal.Transparency = 0.5
						TweenService:Create(
							decal,
							TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
							{
								Transparency = 1,
								StudsPerTileU = math.random(15, 20) * 2,
								StudsPerTileV = math.random(15, 20) * 2
							}
						):Play()
					end
				end)
			end)
			task.spawn(function()
				for i = 1, 10 do
					local v12 = i
					task.spawn(function()
						local clone7 = script.Part:Clone()
						local cFrame2 = CFrame.new(cframe.Position) * CFrame.new(0, 15 + math.random(0, 10), 0) * CFrame.Angles(
							math.rad(math.random(-180, 180) / 10),
							math.rad((math.random(-180, 180))),
							(math.rad(math.random(-180, 180) / 10))
						) * CFrame.new(0, 0, -105)
						clone7.CFrame = cFrame2
						Util.SetParentOverrideWithColor(clone7, folder, data.Player, "MagnetFruitVFXColor")
						clone7.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, 210).Position
						local shafiBolt = ShafiBolt(
							clone7.Attach0,
							clone7.Attach1,
							math.random(8, 12) * 1.25,
							0.75,
							folder
						)
						shafiBolt.CurveSize0 = -90
						shafiBolt.CurveSize1 = 90
						shafiBolt.Frequency = math.random(5, 10) * 2
						shafiBolt.MaxRadius = 12
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						local player = data.Player
						local color = Color3.fromRGB(58, 61, 255)

						if typeof(player) == "Instance" and player.Parent then
							color = WrapColor3Constructor(color, player, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v12 % 2 == 0 then
							local player2 = data.Player
							local color2 = Color3.fromRGB(88, 73, 255)

							if typeof(player2) == "Instance" and player2.Parent then
								color2 = WrapColor3Constructor(color2, player2, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color2
							shafiBolt.Thickness = 1
						end

						task.spawn(function()
							task.wait(0.2 + math.random() * 0.2)
							shafiBolt:Destroy()
						end)
					end)
				end
			end)
		end)
	end
end