local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local z_Attract_Held = FX:WaitForChild("Magnet"):WaitForChild("Z_Attract_Held")
FX:WaitForChild("Magnet"):WaitForChild("Scraps")

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

local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
CustomCollisions.new("Rocks")
local _WorldOrigin = workspace._WorldOrigin

local function RecolorMagnetColor(p, p2)
	return WrapColor3Constructor(p2, p, "MagnetFruitVFXColor")
end

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

-- equivalent calls inferred from this helper; original call sites unknown
local function QuadBezier(p, p2, p3, p4)
	return p:Lerp(p2, p4):Lerp(p2:Lerp(p3, p4), p4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FlyCurve(primaryPart, cFrame, cFrame2, vector2, p, _)
	local position = cFrame.Position
	local position2 = cFrame2.Position
	local v = (position + position2) / 2 + vector2
	local lastTime = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v2 = (os.clock() - lastTime) / p

		if v2 >= 1 then
			primaryPart.CFrame = cFrame2
			heartbeatConnection:Disconnect()
		else
			local quadBezier = QuadBezier(position, v, position2, v2) -- equivalent call inferred; original call site unknown
			primaryPart.CFrame = CFrame.new(quadBezier)
		end
	end)
end

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(...)
	local v = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 25)
	local curveSize2 = math.random(5, 25)
	v.CurveSize0 = curveSize
	v.CurveSize1 = curveSize2
	v.MinRadius = 3
	v.MaxRadius = 13
	v.Frequency = 0.5
	v.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 10
	v.PulseLength = 1000000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Color3.new(1, 0.380392, 0.380392)
	v.ColorOffsetSpeed = 3
	return v
end

local function getArmAnim(instance, p: string, p2: string)
	local magnetArms = instance:FindFirstChild("MagnetArms")

	if not magnetArms then
		warn("Magnet Arms Folder missing!")
		return
	end

	local child = magnetArms:FindFirstChild("Floating" .. p2 .. "Arm")
	local v = child and Util.Anims:Get(child, p)
	return v or nil
end

return function(data)
	local origin = data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local root = data.Root
	local _ = root.CFrame
	local mousePos = data.MousePos
	local holding = data.Holding
	local proxy = data.Proxy

	if not proxy then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 10)
	local value = mousePos.Value
	local startCFrame = data.StartCFrame
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
	local leftHand = data.Player.Character.LeftHand
	local clone = z_Attract_Held.Phase0A.Aura:Clone()
	clone.CFrame = startCFrame
	Util.SetParentOverrideWithColor(clone, folder, data.Player, "MagnetFruitVFXColor")
	local magnetArms = root.Parent:FindFirstChild("MagnetArms")
	local v

	if magnetArms then
		local floatingLeftArm = magnetArms:FindFirstChild("FloatingLeftArm")
		v = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Magnet NEW Z Hold Arm Loop L") or nil
	else
		warn("Magnet Arms Folder missing!")
	end

	local magnetArms2 = root.Parent:FindFirstChild("MagnetArms")
	local v2

	if magnetArms2 then
		local floatingRightArm = magnetArms2:FindFirstChild("FloatingRightArm")
		v2 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Magnet NEW Z Hold Arm Loop R") or nil
	else
		warn("Magnet Arms Folder missing!")
	end

	v.Looped = true
	v2.Looped = true
	v.Priority = Enum.AnimationPriority.Action2
	v2.Priority = Enum.AnimationPriority.Action2
	local magnetArms3 = root.Parent:FindFirstChild("MagnetArms")
	local v3

	if magnetArms3 then
		local floatingRightArm = magnetArms3:FindFirstChild("FloatingRightArm")
		v3 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Magnet NEW Z Hold Arm Start R") or nil
	else
		warn("Magnet Arms Folder missing!")
	end

	if v3 then
		v3.Priority = Enum.AnimationPriority.Action3
		v3.Looped = false
		v3:Play()
	end

	local magnetArms4 = root.Parent:FindFirstChild("MagnetArms")
	local v4

	if magnetArms4 then
		local floatingLeftArm = magnetArms4:FindFirstChild("FloatingLeftArm")
		v4 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Magnet NEW Z Hold Arm Start L") or nil
	else
		warn("Magnet Arms Folder missing!")
	end

	if v4 then
		v4.Priority = Enum.AnimationPriority.Action3
		v4.Looped = false
		v4:Play()
	end

	v:Play()
	v2:Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local smallTrail = z_Attract_Held.Phase0A.SmallTrail
	local flag = true
	local v5 = {}
	task.spawn(function()
		for _ = 1, 10 do
			local clone2 = smallTrail:Clone()
			clone2.Anchored = true
			clone2.CanCollide = false
			clone2.CFrame = startCFrame * CFrame.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
			Util.SetParentOverrideWithColor(clone2, folder, data.Player, "MagnetFruitVFXColor")
			table.insert(v5, {
				part = clone2,
				xOffset = math.random(-50, 50),
				yOffset = math.random(-25, 25),
				forwardDist = math.random(3, 12),
				zigTimer = math.random(8, 20) / 100,
				elapsed = math.random() * 0.2
			})
			task.wait(0.1)
		end
	end)
	task.spawn(function()
		while flag do
			local lookVector = root.CFrame.LookVector
			local rightVector = root.CFrame.RightVector
			local upVector = root.CFrame.UpVector

			for _, v6 in ipairs(v5) do
				if not (v6.part and v6.part.Parent) then
					continue
				end

				local v7 = root.Position + lookVector * v6.forwardDist + rightVector * v6.xOffset + upVector * v6.yOffset
				v6.part.CFrame = CFrame.new(v6.part.CFrame.Position:Lerp(v7, 0.15))
				v6.elapsed += 0.03

				if not (v6.elapsed >= v6.zigTimer) then
					continue
				end

				v6.elapsed = 0
				v6.zigTimer = math.random(5, 25) / 300
				v6.xOffset = math.random(-30, 30) / 2
				v6.yOffset = math.random(-15, 15) / 2
				v6.forwardDist = math.random(-1, 12)
			end

			task.wait(0.03)
		end

		for _, v6 in ipairs(v5) do
			if v6.part and v6.part.Parent then
				v6.part:Destroy()
			end
		end
	end)
	local v6 = {}
	local v7 = {}
	local v8 = nil
	local v9 = math.clamp((startCFrame.Position - value).Magnitude, 1, 100)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function GetMainEndPos()
		local value2 = mousePos.Value
		math.clamp((startCFrame.Position - value2).Magnitude, 1, 100)
		local _ = (value2 - startCFrame.Position).Unit
		return proxy.Value
	end

	local mainEndPos = GetMainEndPos() -- equivalent call inferred; original call site unknown
	local flag2 = true
	task.spawn(function()
		while flag2 do
			local v11 = RunService.Heartbeat:Wait()
			local mainEndPos2 = GetMainEndPos() -- equivalent call inferred; original call site unknown
			local v13 = mainEndPos2 - mainEndPos
			local magnitude = v13.Magnitude
			local v14 = 150 * v11

			if magnitude <= v14 then
				mainEndPos = mainEndPos2
			else
				mainEndPos += v13.Unit * v14
			end
		end
	end)
	local v11 = false
	local v12 = {}
	task.spawn(function()
		task.spawn(function()
			for i = 1, 3 do
				local clone2 = nil
				local yOff = nil
				local v14 = nil

				if i == 1 then
					local v15

					if hasCrimsonGoldSkin(data.Player) then
						v15 = z_Attract_Held.Phase1.ArcsteelCogA
					else
						v15 = z_Attract_Held.Phase1.CogA
					end

					clone2 = v15:Clone()
					v14 = 7
					yOff = 25
				elseif i == 2 then
					clone2 = z_Attract_Held.Phase1.CogB:Clone()
					v14 = 10
					yOff = 22.5
				elseif i == 3 then
					local v15

					if hasCrimsonGoldSkin(data.Player) then
						v15 = z_Attract_Held.Phase1.ArcsteelCogC
					else
						v15 = z_Attract_Held.Phase1.CogC
					end

					clone2 = v15:Clone()
					v14 = 5
					yOff = 20
				end

				Util.SetParentOverrideWithColor(clone2, folder, data.Player, "MagnetFruitVFXColor")
				Vector3.new(math.random(-35, 35), math.random(-3, 5), math.random(-6, 6))
				clone2.CFrame = startCFrame * CFrame.new(math.random(-2, 2), math.random(-3, 3), math.random(-3, 0)) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
				local vector2 = Vector3.new(math.random(-15, 15) * 2, math.random(-10, 15), math.random(-15, 15))
				local ring

				if hasCrimsonGoldSkin(data.Player) and i ~= 2 then
					ring = clone2.Ring
				else
					ring = clone2
				end

				local size = ring.Size
				TweenService:Create(ring, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Size = size * v14 / 2
				}):Play()
				local cFrame = clone2.CFrame
				local cFrame2 = CFrame.new(mainEndPos) * CFrame.new(0, yOff, 0)
				local position = cFrame.Position
				local position2 = cFrame2.Position
				local v17 = (position + position2) / 2 + vector2
				local heartbeatConnection = nil
				local v19 = os.clock()
				local v20 = 0.5
				local v21 = clone2
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					local v26 = (os.clock() - v19) / v20

					if v26 >= 1 then
						v21.CFrame = cFrame2
						heartbeatConnection:Disconnect()
					else
						local quadBezier = QuadBezier(position, v17, position2, v26) -- equivalent call inferred; original call site unknown
						v21.CFrame = CFrame.new(quadBezier)
					end
				end)
				local v28 = i
				task.delay(0.5, function()
					if not (clone2 and clone2.Parent) then
						return
					end

					TweenService:Create(ring, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = size * v14
					}):Play()
					local v29 = v28 % 2 == 1 and 1 or -1
					table.insert(v12, {
						cog = clone2,
						axis = createVector(0, 1, 0),
						speed = 2.443460952792061 * v29,
						YOff = yOff
					})
				end)
				task.wait(0.1)
			end
		end)
		RunService.Heartbeat:Connect(function(dt)
			if v11 == true then
				for i = #v12, 1, -1 do
					v12[i].cog:Destroy()
				end
			else
				for i = #v12, 1, -1 do
					local v13 = v12[i]
					local cog = v13.cog

					if cog and cog.Parent then
						local cframe = CFrame.fromAxisAngle(v13.axis, v13.speed * dt)
						cog.CFrame *= cframe
						local v14 = mainEndPos + Vector3.new(0, v13.YOff, 0)
						local lerped = cog.CFrame.Position:Lerp(v14, 0.1)
						cog.CFrame = CFrame.new(lerped) * (cog.CFrame - cog.CFrame.Position)
					else
						table.remove(v12, i)
					end
				end
			end
		end)
	end)

	local function CreateCube(p)
		local v13

		if hasCrimsonGoldSkin(data.Player) then
			v13 = z_Attract_Held.Phase1.ArcsteelCube
		else
			v13 = z_Attract_Held.Phase1.Cube
		end

		local clone2 = v13:Clone()
		local primaryPart = clone2.PrimaryPart
		primaryPart.CFrame = startCFrame * CFrame.new(0, 0, -3)
		Util.SetParentOverrideWithColor(clone2, folder, data.Player, "MagnetFruitVFXColor")

		if p <= 10 then
			clone2:ScaleTo(math.random(10, 20) / 10)
			local clone3 = z_Attract_Held.Phase1.AuraModel:Clone()
			clone3.PrimaryPart.Anchored = false
			clone3.PrimaryPart.Weld.Part1 = primaryPart
			Util.SetParentOverrideWithColor(clone3, primaryPart, data.Player, "MagnetFruitVFXColor")
			clone3:ScaleTo(clone2:GetScale() / 10)

			for _, effect in pairs(clone3:GetDescendants()) do
				if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
					effect.Enabled = true
				end
			end
		elseif p == 20 then
			v8 = clone2
			clone2:ScaleTo(2)
			local clone3 = z_Attract_Held.Phase1.AuraModel:Clone()
			clone3.PrimaryPart.Anchored = false
			clone3.PrimaryPart.Weld.Part1 = primaryPart
			Util.SetParentOverrideWithColor(clone3, primaryPart, data.Player, "MagnetFruitVFXColor")
			clone3:ScaleTo(v8:GetScale() / 20)

			for _, effect in pairs(clone3:GetDescendants()) do
				if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
					effect.Enabled = true
				end
			end

			local primaryPart2 = nil
			task.spawn(function()
				for i = 20, 50 do
					v8:ScaleTo(i / 10)
					task.wait(0.005)
				end

				for _, effect in pairs(clone3:GetDescendants()) do
					if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					end
				end

				local clone4 = z_Attract_Held.Phase1.BigAuraModel:Clone()
				primaryPart2 = clone4.PrimaryPart
				primaryPart2.Anchored = false
				primaryPart2.Weld.Part1 = primaryPart
				Util.SetParentOverrideWithColor(clone4, primaryPart, data.Player, "MagnetFruitVFXColor")

				for _, emitter in pairs(primaryPart2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.spawn(function()
					for i = 35, 100 do
						clone4:ScaleTo(i / 100)
						task.wait(0.01)
					end
				end)
			end)
			task.spawn(function()
				local now = tick()
				local v14 = 0.5235987755982988

				while v8 and v8.Parent and not v11 do
					local now2 = tick()
					local v15 = now2 - now
					v14 = math.min(v14 + 14.660765716752369 * v15, 31.41592653589793)
					local cframe = CFrame.fromAxisAngle(createVector(0, 1, 0), v14 * v15)
					local pivot = v8:GetPivot()
					local v16 = mainEndPos + createVector(0, 37.5, 0)
					local lerped = pivot.Position:Lerp(v16, 0.08)
					v8:PivotTo(CFrame.new(lerped) * (pivot - pivot.Position) * cframe)
					RunService.Heartbeat:Wait()
					now = now2
				end

				for _, emitter in pairs(primaryPart2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local clone4 = z_Attract_Held.Phase3.BeamImpact:Clone()
				clone4.CFrame = primaryPart.CFrame * CFrame.new(0, 0, -primaryPart.Size.Z / 2)
				Util.SetParentOverrideWithColor(clone4, folder, data.Player, "MagnetFruitVFXColor")

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
		else
			clone2:ScaleTo(math.random(5, 10) / 10)
		end

		local v14 = math.random(20, 35) / 100
		local vector2 = Vector3.new(math.random(-35, 35), math.random(-3, 5), math.random(-6, 6))
		primaryPart.CFrame = startCFrame * CFrame.new(math.random(-2, 2), math.random(-3, 3), math.random(-3, 0))
		local v15 = v9 + math.random(-6, 6)
		local v16 = startCFrame * CFrame.new(vector2) * CFrame.new(0, 30, -v15)
		local vector3 = Vector3.new(math.random(-15, 15), math.random(-10, 15), math.random(-15, 15))
		local v17 = v14 + math.random() * 0.1

		if p == 20 then
			local cframe = CFrame.new(mainEndPos + createVector(0, 37.5, 0), mainEndPos)
			FlyCurve(primaryPart, primaryPart.CFrame, cframe, vector3, v17) -- equivalent call inferred; original call site unknown
		else
			FlyCurve(primaryPart, primaryPart.CFrame, v16, vector3, v17) -- equivalent call inferred; original call site unknown
		end

		task.wait(v17)

		if p <= 10 then
			v6[primaryPart] = tick()
		elseif p ~= 20 then
			v7[primaryPart] = tick()
		end
	end

	local v13 = tick() + 2
	local v14 = tick() + 1
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Position = proxy.Value
	part.Parent = folder
	Util.Debris:AddItem(part, 10)
	Util.Sound:Play("Magnet_Untransformed_Z_Held_Release_01", part)
	local v15 = Util.Sound:Play("Magnet_Untransformed_Z_Held_FiringLasers_Loop_01", part)
	local v16 = false
	task.spawn(function()
		while true do
			task.wait()

			if v16 or not part then
				break
			end

			part.Position = proxy.Value
		end

		if v15 then
			Util.Sound:FadeOut(v15, 0.2)
		end
	end)
	task.delay(0.5, function()
		if not v16 and v15 then
			TweenService:Create(v15, TweenInfo.new(0.4), {
				Volume = 1
			}):Play()
		end
	end)
	task.spawn(function()
		while not (v13 - tick() <= 0) and (holding and holding.Value or not (v14 <= tick())) do
			clone.CFrame = CFrame.new(leftHand.Position, leftHand.Position + root.CFrame.LookVector) * CFrame.new(
				0,
				0,
				-1
			)

			for k, v17 in pairs(v6) do
				if not (v17 - tick() <= 0) then
					continue
				end

				local v18 = math.random(25, 40) / 100
				v6[k] = tick() + v18
				TweenService:Create(k, TweenInfo.new(v18 * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(mainEndPos) * CFrame.new(
						math.random(-35, 35),
						math.random(-35, 25),
						math.random(-35, 35)
					) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.Angles(
						-0.8726646259971648,
						0,
						0
					)
				}):Play()
				local part2 = k
				task.delay(v18 * 0.5, function()
					if part2:GetAttribute("OVER") == true then
						return
					end

					local clone2 = z_Attract_Held.Phase2.Ray:Clone()
					clone2:ScaleTo(part2.Parent:GetScale())
					Util.SetParentOverrideWithColor(clone2, folder, data.Player, "MagnetFruitVFXColor")
					TweenService:Create(
						part2,
						TweenInfo.new(v18 * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = CFrame.new(part2.Position) * CFrame.Angles(
								0,
								math.rad((math.random(-180, 180))),
								0
							) * CFrame.Angles(math.rad(-math.random(30, 60)), 0, (math.rad((math.random(-180, 180)))))
						}
					):Play()
					local startImpact = clone2.StartImpact
					startImpact.CFrame = part2.CFrame * CFrame.new(0, 0, -part2.Size.Z / 2)

					for i, emitter in pairs(startImpact:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					local position = startImpact.Position
					local v21 = startImpact.CFrame.LookVector * 100
					local raycastResult = workspace:Raycast(position, v21, raycastParams)
					local position2

					if raycastResult then
						position2 = raycastResult.Position
					else
						position2 = position + v21
					end

					local magnitude = (position - position2).Magnitude
					local beamPart = clone2.BeamPart
					beamPart.CFrame = part2.CFrame * CFrame.new(0, 0, -0)
					beamPart.Anchored = false
					beamPart.Massless = true
					beamPart.Weld.Part1 = part2
					local attach1 = beamPart.Attach1
					attach1.Position = createVector(0, 0, -0)
					local v22 = magnitude / 100 * (math.random(20, 30) / 100)
					TweenService:Create(
						attach1,
						TweenInfo.new(v18 * 0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(0, 0, -magnitude)
						}
					):Play()
					task.delay(v18 * 0.1, function()
						local groundCrack = clone2.GroundCrack
						groundCrack.CFrame = CFrame.new(position2)

						for i, emitter in pairs(groundCrack:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						local v23 = tick() + v18 * 0.5

						while true do
							local position3 = part2.Position
							local v24 = part2.CFrame.LookVector * 100
							local raycastResult2 = workspace:Raycast(position3, v24, raycastParams)
							local v25

							if raycastResult2 then
								v25 = raycastResult2.Position
							else
								v25 = position3 + v24
							end

							groundCrack.CFrame = CFrame.new(v25)

							for i, emitter in pairs(groundCrack:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount") / 5)
								end
							end

							task.wait(0.025)

							if not (v23 - tick() <= 0.1) then
								continue
							end

							for i, beam in pairs(beamPart:GetDescendants()) do
								if beam:IsA("Beam") then
									TweenService:Create(
										beam,
										TweenInfo.new(v18 * 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Width0 = 0,
											Width1 = 0
										}
									):Play()
								end
							end

							beamPart.Weld.Enabled = false
							beamPart.Anchored = true
							local magnitude2 = (position - position2).Magnitude
							local beamAura = clone2.BeamAura
							beamAura.Size = Vector3.new(1, 1, magnitude2)
							beamAura.CFrame = part2.CFrame * CFrame.new(0, 0, -magnitude2 / 2)

							for i, emitter in pairs(beamAura:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end

							break
						end
					end)

					for i, beam in pairs(beamPart:GetDescendants()) do
						if not beam:IsA("Beam") then
							continue
						end

						local width0 = beam.Width0
						local tween = TweenService:Create(
							beam,
							TweenInfo.new(v18 * 0.05, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{
								Width0 = width0 * 1.5,
								Width1 = width0 * 1.5
							}
						)
						beam.Width0 = 0
						beam.Width1 = 0
						tween:Play()
					end
				end)
			end

			for k, _ in pairs(v7) do
				if not (v7[k] - tick() <= 0) then
					continue
				end

				local v17 = math.random(15, 25) / 100
				v7[k] = tick() + v17
				TweenService:Create(k, TweenInfo.new(v17 * 0.65, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(mainEndPos) * CFrame.new(
						math.random(-35, 35),
						math.random(-35, 25),
						math.random(-35, 35)
					) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.Angles(
						-0.8726646259971648,
						0,
						0
					)
				}):Play()
				local part2 = k
				task.delay(v17 * 0.7, function()
					if part2:GetAttribute("OVER") == true then
						return
					end

					local clone2 = z_Attract_Held.Phase2.Ray:Clone()
					clone2:ScaleTo(part2.Parent:GetScale())
					Util.SetParentOverrideWithColor(clone2, folder, data.Player, "MagnetFruitVFXColor")
					local startImpact = clone2.StartImpact
					startImpact.CFrame = part2.CFrame * CFrame.new(0, 0, -part2.Size.Z / 2)

					for i, emitter in pairs(startImpact:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					local position = startImpact.Position
					local v20 = startImpact.CFrame.LookVector * 100
					local raycastResult = workspace:Raycast(position, v20, raycastParams)
					local v21

					if raycastResult then
						v21 = raycastResult.Position
					else
						v21 = position + v20
					end

					local magnitude = (position - v21).Magnitude
					local beamAura = clone2.BeamAura
					beamAura.Size = Vector3.new(1, 1, magnitude)
					beamAura.CFrame = part2.CFrame * CFrame.new(0, 0, -magnitude / 2)

					for i, emitter in pairs(beamAura:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					local beamPart = clone2.BeamPart
					beamPart.CFrame = part2.CFrame * CFrame.new(0, 0, -0)
					beamPart.Anchored = false
					beamPart.Massless = true
					beamPart.Weld.Part1 = part2
					local attach1 = beamPart.Attach1
					attach1.Position = createVector(0, 0, -0)
					local v22 = magnitude / 100 * (math.random(20, 30) / 100)
					TweenService:Create(
						attach1,
						TweenInfo.new(v17 * 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(0, 0, -magnitude)
						}
					):Play()

					for i, beam in pairs(beamPart:GetDescendants()) do
						if not beam:IsA("Beam") then
							continue
						end

						local width0 = beam.Width0
						local tween = TweenService:Create(
							beam,
							TweenInfo.new(v17 * 0.1 / 2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{
								Width0 = width0 * 2.5,
								Width1 = width0 * 2.5
							}
						)
						beam.Width0 = 0
						beam.Width1 = 0
						tween:Play()
						local v23 = beam
						task.spawn(function()
							tween.Completed:Wait()
							tween = TweenService:Create(
								v23,
								TweenInfo.new(v17 * 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween:Play()
						end)
					end

					for i = 1, math.random(1, 2) do
						local v23 = i
						task.spawn(function()
							local clone3 = script.Part:Clone()
							local cFrame = part2.CFrame
							clone3.CFrame = cFrame
							Util.SetParentOverrideWithColor(clone3, folder, data.Player, "MagnetFruitVFXColor")
							clone3.Attach1.WorldPosition = cFrame * CFrame.new(0, 0, -magnitude).Position
							local shafiBolt = ShafiBolt(
								clone3.Attach0,
								clone3.Attach1,
								math.random(8, 12),
								0.25,
								folder
							)
							shafiBolt.CurveSize0 = -math.random(5, 10)
							shafiBolt.CurveSize1 = math.random(5, 10)
							shafiBolt.Frequency = math.random(5, 10) / 2
							shafiBolt.MaxRadius = 3.3333333333333335
							shafiBolt.AnimationSpeed = math.random(20, 50) / 10
							local player = data.Player
							shafiBolt.Color = WrapColor3Constructor(
								Color3.fromRGB(26, 60, 255),
								player,
								"MagnetFruitVFXColor"
							)

							if v23 % 2 == 0 then
								local player2 = data.Player
								shafiBolt.Color = WrapColor3Constructor(
									Color3.fromRGB(48, 79, 255),
									player2,
									"MagnetFruitVFXColor"
								)
								shafiBolt.Thickness = 0.2333333333333333
							end

							task.spawn(function()
								task.wait(0.065 + math.random() * 0.1)
								shafiBolt:Destroy()
							end)
						end)
					end
				end)
			end

			task.wait()
		end

		v16 = true
		flag2 = false

		for k, _ in pairs(v7) do
			for _, part2 in pairs(k:GetChildren()) do
				if part2:IsA("MeshPart") then
					TweenService:Create(part2, TweenInfo.new(0.15), {
						Size = createVector(0, 0, 0)
					}):Play()
				end
			end

			TweenService:Create(k, TweenInfo.new(0.15), {
				Size = createVector(0, 0, 0)
			}):Play()
		end
	end)

	for i = 1, 20 do
		local v17 = i
		task.spawn(function()
			task.wait(0.05 + math.random() * 0.3)
			CreateCube(v17)
		end)
		task.wait()
	end

	local v17 = nil
	local v18 = {}

	local function StartRingSpin(p, p2, p3, p4, p5, p6)
		local v19 = p5
		local v20 = 1.7453292519943295 * p6
		local v21 = math.random() * 100

		if v18[p] then
			v18[p]:Disconnect()
		end

		local lastTime = tick()
		local v22 = v17 - tick()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if not (p and p.Parent) then
				heartbeatConnection:Disconnect()
			elseif v22 <= tick() - lastTime then
				heartbeatConnection:Disconnect()
				v18[p] = nil
			else
				v19 += v20 * dt
				v21 += dt * 25
				local vector2 = Vector3.new(math.cos(v19) * p3, p4, math.sin(v19) * p3)
				local v24 = Vector3.new(math.noise(v21, 0, 0), math.noise(0, v21, 0), math.noise(0, 0, v21)) * 1.125
				local v25 = p2 + vector2 + v24
				p.CFrame = CFrame.lookAt(v25, p2)
			end
		end)
		v18[p] = heartbeatConnection
	end

	local function FlyToRingBezier(p, cFrame, cFrame2, p2)
		local position = cFrame.Position
		local position2 = cFrame2.Position
		local v19 = math.random(18, 30)
		local vector2 = Vector3.new(math.random(-20, 20), math.random(-5, 5), math.random(-20, 20))
		local v20 = (position + position2) / 2 + Vector3.new(0, v19, 0) + vector2
		local lastTime = os.clock()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			local v21 = (os.clock() - lastTime) / p2

			if v21 >= 1 then
				p.CFrame = cFrame2
				heartbeatConnection:Disconnect()
			else
				local quadBezier = QuadBezier(position, v20, position2, v21) -- equivalent call inferred; original call site unknown
				local unit = (position2 - quadBezier).Unit
				p.CFrame = CFrame.lookAt(quadBezier, quadBezier + unit)
			end
		end)
	end

	local function FormRing(items, p)
		local v19 = {}

		for k, _ in pairs(items) do
			if k and k.Parent then
				table.insert(v19, k)
			end
		end

		local count = #v19

		if count < 2 then
			return
		end

		local v20 = math.ceil(count / 2)
		local v21 = 0.15 + math.random() * 0.25

		for i, part2 in ipairs(v19) do
			local v23 = i <= v20
			local v24 = v23 and 7 or 15
			local v25 = v23 and 15 or 20
			local v26 = (v23 and i or i - v20) / (v23 and v20 or count - v20) * 3.141592653589793 * 2
			local v27 = p + Vector3.new(math.cos(v26) * v24, v25, math.sin(v26) * v24)
			local cFrame = CFrame.lookAt(v27, p) * CFrame.Angles(-1.5707963267948966, 0, 0)
			part2:SetAttribute("OVER", true)
			local v29 = part2
			task.spawn(function()
				local auraModel = v29:FindFirstChild("AuraModel")

				if auraModel then
					for i2, effect in pairs(auraModel:GetDescendants()) do
						if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						end
					end
				end
			end)
			local clone2 = z_Attract_Held.Phase2.AuraModel:Clone()
			clone2:ScaleTo(part2.Parent:GetScale())
			clone2.PrimaryPart.CFrame = part2.CFrame
			Util.SetParentOverrideWithColor(clone2, part2, data.Player, "MagnetFruitVFXColor")
			clone2.PrimaryPart.Anchored = false
			clone2.PrimaryPart.Weld.Part1 = part2
			FlyToRingBezier(part2, part2.CFrame, cFrame, v21)
			local parent = part2
			local folder2 = clone2
			task.delay(v21, function()
				if not (parent and parent.Parent) then
					return
				end

				local highlight = folder2.Highlight
				highlight.Parent = parent
				TweenService:Create(highlight, TweenInfo.new(0.65, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					FillTransparency = 0.75,
					OutlineTransparency = 0.75
				}):Play()

				for i2, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				StartRingSpin(parent, p, v24, v25, v26, v23 and 1 or -1)
			end)
		end
	end

	repeat
		task.wait()
	until v16 == true

	v17 = tick() + 0.65
	FormRing(v6, mainEndPos)
	local magnetArms5 = root.Parent:FindFirstChild("MagnetArms")
	local v19

	if magnetArms5 then
		local floatingRightArm = magnetArms5:FindFirstChild("FloatingRightArm")
		v19 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Magnet NEW Z Hold Arm End R") or nil
	else
		warn("Magnet Arms Folder missing!")
	end

	if v19 then
		v19.Priority = Enum.AnimationPriority.Action4
		v19.Looped = false
		v19:Play()
	end

	local magnetArms6 = root.Parent:FindFirstChild("MagnetArms")
	local v20

	if magnetArms6 then
		local floatingLeftArm = magnetArms6:FindFirstChild("FloatingLeftArm")
		v20 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Magnet NEW Z Hold Arm End L") or nil
	else
		warn("Magnet Arms Folder missing!")
	end

	if v20 then
		v20.Priority = Enum.AnimationPriority.Action4
		v20.Looped = false
		v20:Play()
	end

	if v then
		v:Stop()
	end

	if v2 then
		v2:Stop()
	end

	local function BurstVelocity(items, _)
		for k, _ in pairs(items) do
			if k and k.Parent then
				k:Destroy()
			end
		end
	end

	flag = false

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Util.Sound:Play("Magnet_Untransformed_Z_Held_LetGo_WindUp_01", v8.PrimaryPart)
	task.delay(0.1, function()
		local clone2 = z_Attract_Held.Phase0A.HeldEndImpact:Clone()
		clone2.CFrame = root.CFrame * CFrame.new(0, 0, -3)
		Util.SetParentOverrideWithColor(clone2, folder, data.Player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)
	task.wait(0.65)
	BurstVelocity(v6, mainEndPos)
	v11 = true
	task.spawn(function()
		for i = 1, 3 do
			local v21 = 2.5
			local v22 = 0.125
			local v23 = -15

			if i == 2 then
				v22 = 0.175
				v23 = 15
				v21 = 5
			elseif i == 3 then
				v22 = 0.15
				v23 = 7
				v21 = 3.5
			end

			local v25 = CFrame.new(mainEndPos) * CFrame.new(0, 25, 0) * CFrame.new(0, -(i * 5), 0)
			local clone2 = z_Attract_Held.Phase2.StartBeam:Clone()
			clone2.CFrame = v25 * CFrame.new(0, -10, 0)
			Util.SetParentOverrideWithColor(clone2, folder, data.Player, "MagnetFruitVFXColor")
			TweenService:Create(clone2, TweenInfo.new(v22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(0, v23, 0)
			}):Play()

			for _, descendant in pairs(clone2:GetDescendants()) do
				if descendant:IsA("Beam") then
					local v26 = descendant
					task.spawn(function()
						TweenService:Create(
							v26,
							TweenInfo.new(v22 / 2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								CurveSize0 = v26.CurveSize0 * v21,
								CurveSize1 = v26.CurveSize1 * v21,
								Width0 = v26.Width0,
								Width1 = v26.Width1
							}
						):Play()
						task.wait(v22 / 2)
						local tween = TweenService:Create(
							v26,
							TweenInfo.new(v22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v26:Destroy()
					end)
				elseif descendant:IsA("Attachment") then
					local tweenInfo = TweenInfo.new(v22 / 2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					local v28 = descendant.Position.X * v21
					local v29 = descendant.Position.Y * v21
					TweenService:Create(descendant, tweenInfo, {
						Position = Vector3.new(v28, v29, descendant.Position.Z * v21)
					}):Play()
				end
			end

			task.wait(0.025)
		end
	end)
	task.spawn(function()
		local primaryPart = v8.PrimaryPart
		local clone2 = z_Attract_Held.Phase3.RayFinal:Clone()
		clone2:ScaleTo(v8:GetScale() + 1.5)
		Util.SetParentOverrideWithColor(clone2, folder, data.Player, "MagnetFruitVFXColor")
		local startImpact = clone2.StartImpact
		startImpact.CFrame = primaryPart.CFrame * CFrame.new(0, 0, -primaryPart.Size.Z / 2)

		for _, emitter in pairs(startImpact:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local position = startImpact.Position
		local v21 = startImpact.CFrame.LookVector * 125
		local raycastResult = workspace:Raycast(position, v21, raycastParams)
		local position2

		if raycastResult then
			position2 = raycastResult.Position
		else
			position2 = position + v21
		end

		Util.Sound:Play("Magnet_Untransformed_Z_Held_Explode_01", position2)

		if (workspace.CurrentCamera.CFrame.p - position2).Magnitude < 120 then
			Util.CameraShaker:ShakeOnce(8, 6, 0.2, 0.6)
		end

		local magnitude = (position - position2).Magnitude
		local beamAura = clone2.BeamAura
		beamAura.Size = Vector3.new(1, 1, magnitude)
		beamAura.CFrame = primaryPart.CFrame * CFrame.new(0, 0, -magnitude / 2)

		for _, emitter in pairs(beamAura:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local beamPart = clone2.BeamPart
		beamPart.CFrame = primaryPart.CFrame * CFrame.new(0, 0, -0)
		beamPart.Anchored = false
		beamPart.Massless = true
		beamPart.Weld.Part1 = primaryPart
		local attach1 = beamPart.Attach1
		attach1.Position = createVector(0, 0, -0)
		local _ = magnitude / 125 * (math.random(20, 30) / 100)
		TweenService:Create(attach1, TweenInfo.new(0.0625, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Position = Vector3.new(0, 0, -(magnitude + 10))
		}):Play()

		for _, beam in pairs(beamPart:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local width0 = beam.Width0
			local tween = TweenService:Create(
				beam,
				TweenInfo.new(0.0625, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					Width0 = width0 * 5,
					Width1 = width0 * 5
				}
			)
			beam.Width0 = 0
			beam.Width1 = 0
			tween:Play()
			local v22 = beam
			task.spawn(function()
				tween.Completed:Wait()
				tween = TweenService:Create(
					v22,
					TweenInfo.new(0.375, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
			end)
		end

		local groundCrack = clone2.GroundCrack
		groundCrack.CFrame = CFrame.new(position2)

		for _, emitter in pairs(groundCrack:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 1.2, lifetime.Max * 1.2)
			emitter:Emit(emitter:GetAttribute("EmitCount") * 1.5)
		end

		for i = 1, 5 do
			local v22 = i
			task.spawn(function()
				task.wait(math.random() * 0.1)
				local clone3 = script.Part:Clone()
				local cFrame = primaryPart.CFrame
				clone3.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone3, folder, data.Player, "MagnetFruitVFXColor")
				clone3.Attach1.WorldPosition = cFrame * CFrame.new(0, 0, -magnitude).Position
				local shafiBolt = ShafiBolt(clone3.Attach0, clone3.Attach1, math.random(8, 12), 0.75, folder)
				shafiBolt.CurveSize0 = math.random(-25, 25)
				shafiBolt.CurveSize1 = math.random(-25, 25)
				shafiBolt.Frequency = math.random(5, 10) * 2
				shafiBolt.MaxRadius = 7.5
				shafiBolt.AnimationSpeed = math.random(20, 50) / 5
				local player = data.Player
				shafiBolt.Color = WrapColor3Constructor(Color3.fromRGB(26, 60, 255), player, "MagnetFruitVFXColor")

				if v22 % 2 == 0 then
					local player2 = data.Player
					shafiBolt.Color = WrapColor3Constructor(Color3.fromRGB(48, 79, 255), player2, "MagnetFruitVFXColor")
					shafiBolt.Thickness = 1.0499999999999998
				end

				task.spawn(function()
					task.wait(0.1 + math.random() * 0.15)
					shafiBolt:Destroy()
				end)
			end)
		end

		task.spawn(function()
			for i = 1, 10 do
				local v22 = i
				task.spawn(function()
					task.wait(0.1 + math.random() * 0.1)
					local clone3 = script.Part:Clone()
					local cFrame = CFrame.new(groundCrack.Position) * CFrame.new(0, math.random(0, 10), 0) * CFrame.Angles(
						math.rad(math.random(-180, 180) / 10),
						math.rad((math.random(-180, 180))),
						(math.rad(math.random(-180, 180) / 10))
					) * CFrame.new(0, 0, -70)
					clone3.CFrame = cFrame
					Util.SetParentOverrideWithColor(clone3, folder, data.Player, "MagnetFruitVFXColor")
					clone3.Attach1.WorldPosition = cFrame * CFrame.new(0, 0, 140).Position
					local shafiBolt = ShafiBolt(clone3.Attach0, clone3.Attach1, math.random(8, 12) * 1.25, 0.75, folder)
					shafiBolt.CurveSize0 = -60
					shafiBolt.CurveSize1 = 60
					shafiBolt.Frequency = math.random(5, 10) * 2
					shafiBolt.MaxRadius = 12
					shafiBolt.AnimationSpeed = math.random(20, 50) / 10
					local player = data.Player
					shafiBolt.Color = WrapColor3Constructor(Color3.fromRGB(28, 28, 255), player, "MagnetFruitVFXColor")

					if v22 % 2 == 0 then
						local player2 = data.Player
						shafiBolt.Color = WrapColor3Constructor(
							Color3.fromRGB(45, 30, 255),
							player2,
							"MagnetFruitVFXColor"
						)
						shafiBolt.Thickness = 1
					end

					task.spawn(function()
						task.wait(0.1 + math.random() * 0.15)
						shafiBolt:Destroy()
					end)
				end)
			end
		end)
		task.spawn(function()
			local clone3 = z_Attract_Held.Phase3.SpinSlash:Clone()
			clone3:PivotTo(CFrame.new(position2))
			Util.SetParentOverrideWithColor(clone3, folder, data.Player, "MagnetFruitVFXColor")
			local model = clone3.Model

			for i = 1, 5 do
				local v22 = math.random(50, 85) / 100
				local clone4 = model:Clone()
				clone4:ScaleTo(i * 0.35 + 3)
				local primaryPart2 = clone4.PrimaryPart
				local v24 = clone3.PrimaryPart.CFrame * CFrame.Angles(
					math.rad(math.random(-180, 180) / 1),
					math.rad((math.random(-180, 180))),
					(math.rad(math.random(-180, 180) / 1))
				)
				local angularVelocity = primaryPart2.AngularVelocity
				primaryPart2.Anchored = false
				primaryPart2.AlignPosition.Position = primaryPart2.Position + createVector(0, 5, 0)
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 2, 0)
				clone4:PivotTo(v24)
				Util.SetParentOverrideWithColor(clone4, clone3, data.Player, "MagnetFruitVFXColor")
				primaryPart2.AlignPosition.Enabled = true
				angularVelocity.Enabled = true
				clone4:GetScale()
				local folder2 = clone4
				task.spawn(function()
					task.spawn(function()
						TweenService:Create(
							angularVelocity,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
									math.random(-15, 15) / 10,
									math.random(5, 15),
									math.random(-15, 15) / 10
								)
							}
						):Play()
						task.wait(v22 / 2)
						primaryPart2.AlignPosition.Position = position2 + createVector(0, 5, 0)
					end)
					task.wait(0.035 * math.random() + 0.15)

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.35 + math.random() * 0.125), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v28 = effect
							task.delay(1, function()
								v28:Destroy()
							end)
						elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					task.wait(1)
					angularVelocity.Enabled = false
					task.wait(3)
					angularVelocity:Destroy()
				end)
			end

			model:Destroy()
			task.spawn(function()
				local scale = clone3:GetScale()
				local v22 = scale * 0.01

				for i = scale * 100, v22 * 100, -13 do
					clone3:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
		task.spawn(function()
			for _ = 1, 10 do
				task.spawn(function()
					local v22 = math.random(45, 50) / 150
					local clone3 = z_Attract_Held.Phase3.TrailModel:Clone()
					clone3.Start.CFrame = CFrame.new(position2) * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					Util.SetParentOverrideWithColor(clone3, folder, data.Player, "MagnetFruitVFXColor")
					clone3:ScaleTo(math.random(10, 13) / 10)
					local start = clone3.Start
					local trail = clone3.Trail
					local cframe = CFrame.new(0, 0, -math.random(100, 150) * 0.75)
					TweenService:Create(trail.Weld, TweenInfo.new(v22 / 5), {
						C1 = cframe
					}):Play()
					TweenService:Create(start, TweenInfo.new(v22), {
						CFrame = CFrame.new(position2) * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)
					}):Play()
					trail.Weld.C1 = CFrame.new(0, 0, 0)
					task.delay(v22 / 2, function()
						TweenService:Create(trail.Weld, TweenInfo.new(v22), {
							C1 = CFrame.new(0, 0, 0)
						}):Play()
						start.AlignPosition.Position = position2
					end)
					trail.Trail1.Lifetime = math.random(50, 200) / 1500
					local angularVelocity = start.AngularVelocity
					start.Anchored = false
					start.AlignPosition.Position = start.Position
					TweenService:Create(angularVelocity, TweenInfo.new(0.15), {
						AngularVelocity = Vector3.new(
							math.random(-20, 25) * 2,
							math.random(-20, 25) * 2,
							math.random(-20, 25) * 2
						)
					}):Play()

					for _, effect in pairs(clone3:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
							continue
						end

						effect.Enabled = true
						local v23 = effect
						task.delay(v22 + v22 / 5, function()
							v23.Enabled = false
						end)
					end

					task.wait(v22)
					angularVelocity.Enabled = false
					task.wait(v22)
					clone3:Destroy()
				end)
			end
		end)
		primaryPart:Destroy()
	end)
end