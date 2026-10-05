local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local Global = require(ReplicatedStorage.Global)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local flight = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("Flight")

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

local _WorldOrigin = workspace._WorldOrigin

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

-- equivalent calls inferred from this helper; original call sites unknown
local function QuadBezier(p, p2, p3, p4)
	return p:Lerp(p2, p4):Lerp(p2:Lerp(p3, p4), p4)
end

local function clampPitch(unit, lookVector, p)
	local v = math.sin((math.rad(p)))

	if unit.Y <= v and unit.Y >= -v then
		return unit
	end

	local vector2 = Vector3.new(unit.X, 0, unit.Z)

	if vector2.Magnitude < 0.0001 then
		local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
		vector2 = vector3.Magnitude < 0.0001 and createVector(0, 0, -1) or vector3
	end

	local unit2 = vector2.Unit
	local v2 = math.clamp(unit.Y, -v, v)
	return (unit2 * math.sqrt((math.max(1 - v2 * v2, 0))) + Vector3.new(0, v2, 0)).Unit
end

local function makeProxyPartAtBone(attachment, folder, _, cframe: CFrame?)
	local cFrame = cframe or CFrame.new()
	local part = Instance.new("Part")
	part.CastShadow = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	part.Locked = true
	part.Size = createVector(2, 0.2, 2)
	part.Name = "ProxyPart_" .. attachment.Name
	local attachment2 = Instance.new("Attachment")
	attachment2.CFrame = cFrame
	attachment2.Parent = part
	local rigidConstraint = Instance.new("RigidConstraint")
	rigidConstraint.Attachment0 = attachment
	rigidConstraint.Attachment1 = attachment2
	rigidConstraint.Parent = part
	part.Transparency = 1
	part.Parent = folder
	return part, attachment2
end

return function(data)
	assert(
		data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position,
		"Origin Vector3 missing in: ",
		script:GetFullName()
	)

	if not (data.Rig and (data.Holding and data.Holding.Value)) then
		return
	end

	local player = data.Player
	local v = hasCrimsonGoldSkin(player) and "Arcsteel " or ""
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	local root = data.Root
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
	local Mouse = player == game.Players.LocalPlayer and require(game.ReplicatedStorage.Mouse) or data.MousePos
	local holding = data.Holding
	local rig = data.Rig
	local cFrame = rig.PrimaryPart.CFrame
	local v2 = root.Size.Y * 0.5 + root.Parent.Humanoid.HipHeight + 10
	local proxyPartAtBone, v3 = makeProxyPartAtBone(rig.PrimaryPart.Torso3, folder)
	local cframe = CFrame.new(0, 24.90000153, 8.900009155)
	local v4

	if hasCrimsonGoldSkin(player) then
		v4 = flight.Phase1.JetpackArcsteel
	else
		v4 = flight.Phase1.Jetpack
	end

	local clone = v4:Clone()
	clone:PivotTo(rig.PrimaryPart.CFrame * cframe)
	Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
	clone.PrimaryPart.Anchored = false

	if hasCrimsonGoldSkin(player) then
	end

	clone.PrimaryPart.Weld.Part0 = proxyPartAtBone

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		elseif descendant:IsA("BasePart") and not hasCrimsonGoldSkin(player) then
			if descendant.Name == "AuraR" then
				local proxyPartAtBone2 = makeProxyPartAtBone(
					clone.PrimaryPart.Controller:FindFirstChild("JetA7", true),
					folder
				)
				descendant.Motor6D.C0 = CFrame.new(0, -0.1, 0) * CFrame.Angles(0, 0, 3.0543261909900767)
				descendant.Motor6D.Part1 = proxyPartAtBone2
			elseif descendant.Name == "AuraL" then
				local proxyPartAtBone2 = makeProxyPartAtBone(
					clone.PrimaryPart.Controller:FindFirstChild("JetB6", true),
					folder
				)
				descendant.Motor6D.C0 = CFrame.new(0, -0.1, 0) * CFrame.Angles(0, 0, -3.0543261909900767)
				descendant.Motor6D.Part1 = proxyPartAtBone2
			end
		end
	end

	Util.Sound:Play("Magnet_Transformed_F_Jetpack_Form_Release_Launch_01", root)
	local v5 = Util.Sound:Play("Magnet_Transformed_F_Standard_Flight_Loop_01", root)
	task.wait()
	local v6 = Util.Anims:Get(rig, v .. "Magnet Transformed Mech F Fly Start")
	v6.Priority = Enum.AnimationPriority.Action4
	v6:Play()
	local v7 = Util.Anims:Get(clone, "Magnet Transformed Jetpack F Fly Start")
	v7.Priority = Enum.AnimationPriority.Action4
	v7:Play()
	task.spawn(function()
		local v8 = tick() + 0.35
		local v9 = root

		repeat
			local clone2 = flight.Phase1.SmallTrail:Clone()
			clone2.CFrame = v9.CFrame * CFrame.Angles(
				math.rad((math.random(-180, 180))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-180, 180))))
			) * CFrame.new(0, 0, -math.random(50, 100))
			Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
			local position = v9.Position
			local position2 = clone2.Position
			local v10 = (position2 + position) / 2 + Vector3.new(
				math.random(-15, 15),
				math.random(10, 25),
				math.random(-15, 15)
			)
			local v11 = math.random(20, 35) / 100
			local heartbeatConnection = nil
			local v12 = tick()
			local unit = Vector3.new(
				math.random(-100, 100) / 100,
				math.random(-100, 100) / 100,
				math.random(-100, 100) / 100
			).Unit
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				local v19 = (tick() - v12) / v11

				if v19 >= 1 then
					clone2.Position = position
					heartbeatConnection:Disconnect()
				else
					local quadBezier = QuadBezier(position2, v10, position, v19) -- equivalent call inferred; original call site unknown
					local v23 = (tick() - v12) * 15
					local v24 = 50 * (1 - v19)
					local v25 = quadBezier + CFrame.fromAxisAngle(unit, v23):VectorToWorldSpace((Vector3.new(v24, 0, 0)))
					clone2.CFrame = CFrame.lookAt(v25, position)
				end
			end)
			task.wait(0.025)
		until v8 - tick() <= 0
	end)
	local clone2 = flight.Phase1.PullAura:Clone()
	clone2.PrimaryPart.CFrame = root.CFrame
	Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.wait(0.6)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local clone3 = flight.Phase1.StartImpact:Clone()
	clone3.CFrame = cFrame * CFrame.new(0, 25, 0)
	Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
	DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
	TweenService:Create(v5, TweenInfo.new(0.5), {
		Volume = 1
	}):Play()

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.spawn(function()
		task.spawn(function()
			local clone4 = flight.Phase1.SpinSlash:Clone()
			clone4:PivotTo(root.CFrame)
			Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
			local model = clone4.Model

			for i = 1, 3 do
				local v8 = i * 0.1 + 1
				local clone5 = model:Clone()
				clone5:ScaleTo(v8)
				local primaryPart = clone5.PrimaryPart
				local v9 = clone4.PrimaryPart.CFrame * CFrame.new(0, 0, v8) * CFrame.Angles(
					0,
					0,
					(math.rad((math.random(-180, 180))))
				)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.CFrame * CFrame.new(0, 0, i * 2 * 5).Position
				angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 15) * 2)

				if i == 3 then
					v9 *= CFrame.new(0, -20, 0)
					primaryPart.AlignPosition.Responsiveness = 25
					primaryPart.AlignPosition.Position = primaryPart.CFrame * CFrame.new(0, 0, 35).Position
				end

				clone5:PivotTo(v9)
				Util.SetParentOverrideWithColor(clone5, clone4, player, "MagnetFruitVFXColor")
				primaryPart.AlignPosition.Enabled = true
				angularVelocity.Enabled = true
				clone5:GetScale()
				local v11 = i
				local folder2 = clone5
				task.spawn(function()
					task.spawn(function()
						TweenService:Create(
							angularVelocity,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
									0,
									0,
									math.random(5, 15)
								)
							}
						):Play()
					end)

					if v11 == 3 then
						task.wait(0.025)
					else
						task.wait(0.035 * math.random() + 0.05)
					end

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.25 + math.random() * 0.15 / i2), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v12 = effect
							task.delay(1, function()
								v12:Destroy()
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
				local scale = clone4:GetScale()
				local v8 = scale * 2.5

				for i = scale * 100, v8 * 100, 10 do
					clone4:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if emitter:IsDescendantOf(clone.STRONG) then
			emitter.Enabled = false
		else
			emitter.Enabled = true
		end
	end

	local v8 = Util.Anims:Get(rig, v .. "Magnet Transformed Mech F Fly Loop")
	v8.Looped = true
	v8:Play()
	local v9 = Util.Anims:Get(clone, "Magnet Transformed Jetpack F Fly Loop")
	v9.Looped = true
	v9:Play()
	local v10 = v8
	local v11 = v9
	local v12 = 120
	local v13 = 75
	local v14 = root.Size.Y * 0.5 + 3
	local v15 = 100
	local v16 = false
	local currentCamera = workspace.CurrentCamera
	local clone4 = flight.Phase1.CameraFocus:Clone()
	clone4.Parent = folder
	local renderSteppedConnection = nil

	local function enterBoost()
		v16 = true
		v5 = Util.Sound:Play("Magnet_Transformed_F_Boost_Flight_Loop_01", root)
		TweenService:Create(v5, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()
		local v17 = Util.Anims:Get(rig, v .. "Magnet Transformed Mech F Boost Loop")
		v17.Priority = Enum.AnimationPriority.Action2
		v17.Looped = true
		v17:Play()
		local v18 = Util.Anims:Get(clone, "Magnet Transformed Jetpack Boost Flight Loop")
		v18.Priority = Enum.AnimationPriority.Action2
		v18.Looped = true
		v18:Play()

		if hasCrimsonGoldSkin(player) then
			v3.CFrame = (CFrame.new(createVector(0.5, 0, 0)) * CFrame.Angles(
				0,
				-0.04363323129985824,
				0.07853981633974483
			)):Inverse()
		end

		v9:Stop()
		v8:Stop()
		v10 = v17
		v11 = v18

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter:IsDescendantOf(clone.STRONG) then
				emitter.Enabled = true
			end
		end

		v15 = v12
		v12 = 185
		v13 = 250
		task.spawn(function()
			task.spawn(function()
				local clone5 = flight.Phase1.SpinSlash:Clone()
				clone5:PivotTo(root.CFrame)
				Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
				local model = clone5.Model

				for i = 1, 3 do
					local v19 = i * 0.1 + 1
					local clone6 = model:Clone()
					clone6:ScaleTo(v19)
					local primaryPart = clone6.PrimaryPart
					local v20 = clone5.PrimaryPart.CFrame * CFrame.new(0, 0, v19) * CFrame.Angles(
						0,
						0,
						(math.rad((math.random(-180, 180))))
					)
					local angularVelocity = primaryPart.AngularVelocity
					primaryPart.Anchored = false
					primaryPart.AlignPosition.Position = primaryPart.CFrame * CFrame.new(0, 0, i * 2 * 5).Position
					angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 15) * 2)

					if i == 3 then
						v20 *= CFrame.new(0, -20, 0)
						primaryPart.AlignPosition.Responsiveness = 25
						primaryPart.AlignPosition.Position = primaryPart.CFrame * CFrame.new(0, 0, 35).Position
					end

					clone6:PivotTo(v20)
					Util.SetParentOverrideWithColor(clone6, clone5, player, "MagnetFruitVFXColor")
					primaryPart.AlignPosition.Enabled = true
					angularVelocity.Enabled = true
					clone6:GetScale()
					local v22 = i
					local folder2 = clone6
					task.spawn(function()
						task.spawn(function()
							TweenService:Create(
								angularVelocity,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
										0,
										0,
										math.random(5, 15)
									)
								}
							):Play()
						end)

						if v22 == 3 then
							task.wait(0.025)
						else
							task.wait(0.035 * math.random() + 0.05)
						end

						for i2, effect in pairs(folder2:GetDescendants()) do
							if effect:IsA("Beam") then
								TweenService:Create(effect, TweenInfo.new(0.25 + math.random() * 0.15 / i2), {
									Width0 = 0,
									Width1 = 0
								}):Play()
								local v23 = effect
								task.delay(1, function()
									v23:Destroy()
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
					local scale = clone5:GetScale()
					local v19 = scale * 2.5

					for i = scale * 100, v19 * 100, 10 do
						clone5:ScaleTo(i / 100)
						task.wait(0.005)
					end
				end)
			end)
		end)

		if player == game.Players.LocalPlayer then
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				clone4.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
			end)

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end

		local clone5 = flight.Phase1.BoostImpact:Clone()
		clone5.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone5:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local BubbleModule = require(script.BubbleModule)
		task.spawn(function()
			BubbleModule.CreateBubble(
				root.CFrame * CFrame.new(0, 3, 0),
				createVector(15, 15, 15),
				7,
				createVector(120, 120, 120),
				0.15,
				folder
			)
		end)
		task.wait(0.25)
	end

	local color = Color3.new(1, 1, 1)
	local clone5 = flight.Phase1.GroundRocks:Clone()
	clone5.Parent = folder
	local groundRocks1 = clone5:FindFirstChild("GroundRocks1", true)
	local emittersByEmitter = {}
	local emittersByEmitter2 = {}
	local v17 = {}
	local v18 = false

	for _, emitter in pairs(clone5:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = false
		emittersByEmitter[emitter] = emitter

		if groundRocks1 and emitter:IsDescendantOf(groundRocks1) then
			emittersByEmitter2[emitter] = emitter
		else
			v17[emitter] = {
				Brightness = emitter.Brightness,
				LightInfluence = emitter.LightInfluence
			}
		end
	end

	local lastTime = tick()
	local flag = false
	local v19 = false
	local success, result = pcall(function()
		while holding:IsDescendantOf(workspace) and holding.Value == true do
			local v20 = RunService.Heartbeat:Wait()
			local v21 = tick() - lastTime

			if player ~= game.Players.LocalPlayer and not (Mouse and Mouse.Value) then
				break
			end

			if not v19 and v21 >= 1.5 and holding.Value == true then
				v19 = true
				local v22 = Util.Anims:Get(rig, v .. "Magnet Transformed Mech F Fly Boost Activate")
				v22.Priority = Enum.AnimationPriority.Action4
				v22:Play()

				if v5 then
					Util.Sound:FadeOut(v5, 0.1)
				end

				Util.Sound:Play("Magnet_Transformed_F_Activate_TierTwo_Flying_01", root)
			end

			if not flag and v21 >= 2 and holding.Value == true then
				flag = true
				task.spawn(enterBoost)
			end

			local v22 = v21 < 0.3
			local v23 = not v22 and 0 or 800 * (1 - (v21 / 0.3) ^ 2) or 0
			local v24 = v22 and 45 or 120
			v15 = math.min(v15 + v13 * v20, v12)
			local v25

			if flag or not (v21 >= 1.5) then
				v25 = 1
			else
				local v26 = math.clamp((v21 - 1.5) / 0.5, 0, 1)
				v25 = 1 - v26 * v26 * (3 - v26 * 2) * 0.7
			end

			local v26 = 0

			if flag then
				local v27 = (v21 - 2) / 0.12

				if v27 < 1 then
					v26 = 800 * (1 - v27 * v27)
				end
			end

			local v27 = (v15 + v23) * v25 + v26
			local position = player == game.Players.LocalPlayer and Mouse.Hit.Position or Mouse.Value
			local position2 = root.Position
			local v28 = position - position2

			if v28.Magnitude > 0.1 then
				local unit = v28.Unit
				local lookVector = root.CFrame.LookVector
				local v29 = math.acos((math.clamp(lookVector:Dot(unit), -1, 1)))
				local v30 = math.rad(v24) * v20
				local v31 = clampPitch(
					lookVector:Lerp(unit, v29 > 0.0001 and math.min(v30 / v29, 1) or 1).Unit,
					lookVector,
					85
				)

				if v31 ~= v31 then
					v31 = lookVector
				end

				local v32 = position2 + v31 * v27 * v20
				root.CFrame = CFrame.new(v32, v32 + v31)
			else
				local v29 = root.CFrame.LookVector * v27 * v20
				root.CFrame += v29
			end

			local position3 = root.Position
			local raycastResult = workspace:Raycast(
				position3 + createVector(0, 10, 0),
				createVector(0, -510, 0),
				raycastParams
			)

			if raycastResult then
				local v29 = raycastResult.Position.Y + v2

				if position3.Y < v29 then
					local v30 = math.max(position3.Y + (v29 - position3.Y) * 0.15, raycastResult.Position.Y + v14)
					local cFrame2 = root.CFrame
					root.CFrame = CFrame.new(position3.X, v30, position3.Z) * (cFrame2 - cFrame2.Position)
				end
			end

			if v16 ~= true then
				continue
			end

			local raycastResult2 = workspace:Raycast(
				root.Position + createVector(0, 1, 0),
				createVector(-0, -50, -0),
				raycastParams
			)

			if raycastResult2 then
				local waterHeightAtVector = Global.getWaterHeightAtVector(raycastResult2.Position)
				local v29 = raycastResult2.Position.Y <= waterHeightAtVector

				if v29 then
					local vector2 = Vector3.new(
						raycastResult2.Position.X,
						waterHeightAtVector + 4,
						raycastResult2.Position.Z
					)
					clone5.CFrame = CFrame.new(vector2, vector2 + root.CFrame.LookVector)
				else
					clone5.CFrame = AlignCFrame(CFrame.new(raycastResult2.Position), raycastResult2.Normal) + raycastResult2.Normal * 0.01
					clone5.CFrame = CFrame.new(clone5.Position, clone5.Position + root.CFrame.LookVector)
				end

				local v30 = v29 and color or raycastResult2.Instance.Color
				v18 = true

				for _, v31 in pairs(emittersByEmitter) do
					v31.Enabled = not v29 or emittersByEmitter2[v31] == nil

					if v31:GetAttribute("Color") then
						v31.Color = ColorSequence.new(v30, v30)
					end

					local v32 = v17[v31]

					if not v32 then
						continue
					end

					if v29 then
						v31.Brightness = 1
						v31.LightInfluence = 1
					else
						v31.Brightness = v32.Brightness
						v31.LightInfluence = v32.LightInfluence
					end
				end
			elseif v18 == true then
				v18 = false

				for _, v29 in pairs(emittersByEmitter) do
					v29.Enabled = false
				end
			end
		end
	end)

	if not success then
		warn("[Magnet Transformed Flight] loop error:", result)
	end

	if v10 then
		v10:Stop()
	end

	if v11 then
		v11:Stop()
	end

	if v5 then
		Util.Sound:FadeOut(v5, 0.2)
	end

	for _, v20 in pairs(emittersByEmitter) do
		v20.Enabled = false
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if clone then
		clone:Destroy()
	end

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if renderSteppedConnection ~= nil then
		renderSteppedConnection:Disconnect()
	end

	root.Anchored = false
	local clone6 = flight.Phase1.Explosion:Clone()
	clone6.CFrame = root.CFrame
	Util.SetParentOverrideWithColor(clone6, folder, player, "MagnetFruitVFXColor")
	Util.Sound:Play("Magnet_Transformed_F_FinishFlight_Jump_01", root.CFrame)

	for _, emitter in pairs(clone6:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 1.35, lifetime.Max * 1.35)
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown
	local v20 = v2 + 15
	local v21

	if workspace:Raycast(root.Position, createVector(0, 1, 0) * -v20, raycastParams) == nil then
		v21 = Util.Anims:Get(rig, v .. "Transformed Magnet Mech Super Jump")
		v21.Priority = Enum.AnimationPriority.Action
		v21.Looped = false
		v21:Play()
	else
		v21 = nil
	end

	task.spawn(function()
		if not v21 then
			return
		end

		local v22 = tick() + 5

		while tick() < v22 do
			if root and root.Parent then
				if root.Parent:FindFirstChild("MagnetLanding") then
					if not v21 then
						break
					end

					v21:Stop()
					break
				else
					local ray = Util.Ray
					local position = root.Position
					local v23 = { workspace.Characters, workspace.Enemies }

					if ray(position, createVector(-0, -50, -0), v23) and root.Velocity.Y < 0 and root.Velocity.Y > -150 then
						if not v21 then
							break
						end

						v21:Stop()
						break
					end
				end
			end

			task.wait()
		end
	end)
	root.Velocity += createVector(0, 250, 0)
	game.Debris:AddItem(folder, 5)
end