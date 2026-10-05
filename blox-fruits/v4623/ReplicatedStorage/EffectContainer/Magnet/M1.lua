local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local repel = FX:WaitForChild("Magnet"):WaitForChild("Passive"):WaitForChild("Repel")
local attract = FX:WaitForChild("Magnet"):WaitForChild("Passive"):WaitForChild("Attract")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
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

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyAfter(clone, duration)
	task.delay(duration, function()
		clone:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClawSlash(cFrame, instance, p, p2)
	task.spawn(function()
		local v = repel

		if instance:GetAttribute("Mode") == "Attract" then
			v = attract
		end

		local clone = v.Phase1.SlashModel:Clone()
		clone.PrimaryPart.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, instance, p2, "MagnetFruitVFXColor")
		task.spawn(function()
			task.spawn(function()
				for i = 100 * p, 150 * p, 5 * p do
					clone:ScaleTo(i / 100)
					task.wait()
				end
			end)
			task.wait(0.1)

			for _, beam in pairs(clone:GetDescendants()) do
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

			for _ = 1, 3 do
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

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local function PlayArmAnimation(instance, value: string, p: string, p2: number)
	local magnetArms = instance:FindFirstChild("MagnetArms")

	if not magnetArms then
		warn("Magnet Arms Folder missing!")
	elseif p == "Both" then
		for i = 1, 2 do
			local v = i == 1 and "Right" or "Left"
			local child = magnetArms:FindFirstChild("Floating" .. v .. "Arm")

			if not child then
				continue
			end

			local v2 = Util.Anims:Get(child, value .. "_" .. v)

			if not v2 then
				continue
			end

			if string.find(value, "Idle") then
				v2.Priority = Enum.AnimationPriority.Idle
			end

			v2:Play()
		end
	else
		local child = magnetArms:FindFirstChild("Floating" .. p .. "Arm")
		local v = child and Util.Anims:Get(child, value)

		if v then
			v:Play()

			if p2 then
				v:AdjustSpeed(p2)
			end
		end
	end
end

return function(data)
	local origin = data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 600 then
		return
	end

	local v = repel
	local stage = data.Stage
	local player = data.Player
	local root = data.Root
	local currentTier = data.CurrentTier
	local slam = data.Slam
	local magnetModeProxy = root.Parent:FindFirstChild("MagnetModeProxy")

	if not magnetModeProxy then
		return
	end

	if magnetModeProxy.Value == "Attract" then
		v = attract
	end

	local tieredPrefix = data.TieredPrefix
	local folder = Instance.new("Folder")
	folder:SetAttribute("Mode", magnetModeProxy.Value)
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 5)
	local part = Instance.new("Part")
	part.Name = "FXAnchor"
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.CanCollide = false
	part.CastShadow = false
	part.Massless = true
	part.Anchored = false
	part.CanTouch = false
	part.CanQuery = false
	part.CFrame = root.CFrame
	local RunService = game:GetService("RunService")
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		part.CFrame = root.CFrame
	end)
	task.delay(5, renderSteppedConnection.Disconnect, renderSteppedConnection)
	part.Parent = folder
	local magnetArmFunctions = root.Parent:FindFirstChild("MagnetArmFunctions")

	if magnetArmFunctions then
		local folder2 = Instance.new("Folder")
		folder2.Name = "HoldingSkill"
		folder2:SetAttribute("Duration", 1.5)
		folder2.Parent = magnetArmFunctions
	end

	local _ = root.CFrame
	local parent = root.Parent
	local v2 = tieredPrefix .. "R"
	local magnetArms = parent:FindFirstChild("MagnetArms")

	if magnetArms then
		local floatingRightArm = magnetArms:FindFirstChild("FloatingRightArm")
		local v3 = floatingRightArm and Util.Anims:Get(floatingRightArm, v2)

		if v3 then
			v3:Play()
		end
	else
		warn("Magnet Arms Folder missing!")
	end

	local parent2 = root.Parent
	local v3 = tieredPrefix .. "L"
	local magnetArms2 = parent2:FindFirstChild("MagnetArms")

	if magnetArms2 then
		local floatingLeftArm = magnetArms2:FindFirstChild("FloatingLeftArm")
		local v4 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, v3)

		if v4 then
			v4:Play()
		end
	else
		warn("Magnet Arms Folder missing!")
	end

	local v4 = 1
	local v5 = nil

	if currentTier == 1 then
		v5 = "One"
	elseif currentTier == 2 then
		v4 = 1.15
		v5 = "Two"
	elseif currentTier == 3 then
		v4 = 1.5
		v5 = "Three"
	end

	local v6 = v4 * (data.Scale or 1)
	local v7

	if slam then
		local v8 = currentTier == 3 and "Slam_NoDebris" or "Slam"
		local ray = Util.Ray
		local position = root.Position
		local v9 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local v10, _, _ = ray(position, createVector(-0, -15, -0), v9)
		v7 = v10 and currentTier == 3 and "Slam_Debris" or v8
	else
		v7 = "Swipe"
	end

	Util.Sound:Play("Magnet_Untransformed_M1_Tier" .. v5 .. "_" .. v7 .. "_0" .. tostring(stage), root)

	if stage == 1 then
		task.spawn(function()
			task.wait(0.1)
			local v8 = root.CFrame * CFrame.new(0, v6 * 3, v6 * -1) * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(
				0,
				0,
				0.6981317007977318
			)
			local cFrame = v8 * CFrame.Angles(1.0471975511965976, 0, 0) * CFrame.Angles(1.7453292519943295, 0, 0)
			task.spawn(function()
				local clone = v.Phase1.SpinTrail:Clone()
				clone.CFrame = cFrame
				clone.Anchored = false
				clone.CanCollide = false
				clone.CanTouch = false
				clone.CanQuery = false
				clone.Massless = true
				Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
				local motor6D = Instance.new("Motor6D")
				motor6D.Part0 = part
				motor6D.Part1 = clone
				motor6D.C0 = part.CFrame:ToObjectSpace(clone.CFrame)
				motor6D.Parent = clone
				local v10 = 0.1 * math.random() + 0.075

				for _ = 1, 3 do
					local tween = TweenService:Create(
						motor6D,
						TweenInfo.new(v10 / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							C0 = motor6D.C0 * CFrame.Angles(-1.2217304763960306, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end

				local tween = TweenService:Create(
					motor6D,
					TweenInfo.new(v10 / 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C0 = motor6D.C0 * CFrame.Angles(-0.4072434921320102, 0, 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end)
			ClawSlash(cFrame, folder, v6, player) -- equivalent call inferred; original call site unknown
			local clone = v.Phase1.HitImpactModel:Clone()
			clone:PivotTo(v8 * CFrame.new(0, 0, v6 * -12))
			Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
			clone:ScaleTo(v6)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v14 = emitter
				task.spawn(function()
					if v14:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v14:GetAttribute("EmitDelay"))
					end

					v14:Emit(v14:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		end)
	elseif stage == 2 then
		task.spawn(function()
			task.wait(0.1)
			local v8 = root.CFrame * CFrame.new(0, v6 * 3, v6 * -1) * CFrame.Angles(0, 0, -1.0471975511965976)
			local cFrame = v8 * CFrame.Angles(1.0471975511965976, 0, 0) * CFrame.Angles(1.7453292519943295, 0, 0)
			task.spawn(function()
				local clone = v.Phase1.SpinTrail:Clone()
				clone.CFrame = cFrame
				clone.Anchored = false
				clone.CanCollide = false
				clone.CanTouch = false
				clone.CanQuery = false
				clone.Massless = true
				Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
				local motor6D = Instance.new("Motor6D")
				motor6D.Part0 = part
				motor6D.Part1 = clone
				motor6D.C0 = part.CFrame:ToObjectSpace(clone.CFrame)
				motor6D.Parent = clone
				local v10 = 0.1 * math.random() + 0.075

				for _ = 1, 3 do
					local tween = TweenService:Create(
						motor6D,
						TweenInfo.new(v10 / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							C0 = motor6D.C0 * CFrame.Angles(-1.2217304763960306, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end

				local tween = TweenService:Create(
					motor6D,
					TweenInfo.new(v10 / 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C0 = motor6D.C0 * CFrame.Angles(-0.4072434921320102, 0, 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end)
			ClawSlash(cFrame, folder, v6, player) -- equivalent call inferred; original call site unknown
			local clone = v.Phase1.HitImpactModel:Clone()
			clone:PivotTo(v8 * CFrame.new(0, 0, v6 * -12))
			Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
			clone:ScaleTo(v6)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v14 = emitter
				task.spawn(function()
					if v14:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v14:GetAttribute("EmitDelay"))
					end

					v14:Emit(v14:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		end)
	elseif stage == 3 then
		if slam then
			task.spawn(function()
				task.wait(0.1)
				local v8 = root.CFrame * CFrame.new(0, v6 * 3, v6 * 0) * CFrame.Angles(0, 0, -0)
				local cFrame = v8 * CFrame.Angles(1.0471975511965976, 0, 0) * CFrame.Angles(1.7453292519943295, 0, 0)
				task.spawn(function()
					local clone = v.Phase1.SpinTrail:Clone()
					clone.CFrame = cFrame
					clone.Anchored = false
					clone.CanCollide = false
					clone.Massless = true
					Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
					local motor6D = Instance.new("Motor6D")
					motor6D.Part0 = part
					motor6D.Part1 = clone
					motor6D.C0 = part.CFrame:ToObjectSpace(clone.CFrame)
					motor6D.Parent = clone
					local v10 = 0.1 * math.random() + 0.075

					for _ = 1, 3 do
						local tween = TweenService:Create(
							motor6D,
							TweenInfo.new(v10 / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								C0 = motor6D.C0 * CFrame.Angles(-1.2217304763960306, 0, 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end

					local tween = TweenService:Create(
						motor6D,
						TweenInfo.new(v10 / 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							C0 = motor6D.C0 * CFrame.Angles(-0.4072434921320102, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end)
				ClawSlash(cFrame, folder, v6, player) -- equivalent call inferred; original call site unknown
				local clone = v.Phase1.HitImpactModel:Clone()
				clone:PivotTo(v8 * CFrame.new(0, 0, v6 * -12))
				Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
				clone:ScaleTo(v6)

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v14 = emitter
					task.spawn(function()
						if v14:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v14:GetAttribute("EmitDelay"))
						end

						v14:Emit(v14:GetAttribute("EmitCount"))
					end)
				end

				DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
				local clone2 = v.Phase1.GroundCrack1:Clone()
				clone2.CFrame = v8 * CFrame.new(0, -4.75, v6 * -12)
				Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v14 = emitter
					task.spawn(function()
						if v14:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v14:GetAttribute("EmitDelay"))
						end

						v14:Emit(v14:GetAttribute("EmitCount"))
					end)
				end

				DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
			end)
		else
			task.spawn(function()
				task.wait(0.1)
				local v8 = root.CFrame * CFrame.new(0, v6 * 3, v6 * -5) * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(
					0,
					0,
					0.17453292519943295
				)
				local cFrame = v8 * CFrame.Angles(1.3962634015954636, 0, 0) * CFrame.Angles(1.7453292519943295, 0, 0)
				task.spawn(function()
					local clone = v.Phase1.SpinTrail:Clone()
					clone.CFrame = cFrame
					clone.Anchored = false
					clone.CanCollide = false
					clone.CanTouch = false
					clone.CanQuery = false
					clone.Massless = true
					Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
					local motor6D = Instance.new("Motor6D")
					motor6D.Part0 = part
					motor6D.Part1 = clone
					motor6D.C0 = part.CFrame:ToObjectSpace(clone.CFrame)
					motor6D.Parent = clone
					local v10 = 0.1 * math.random() + 0.075

					for _ = 1, 3 do
						local tween = TweenService:Create(
							motor6D,
							TweenInfo.new(v10 / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								C0 = motor6D.C0 * CFrame.Angles(-1.2217304763960306, 0, 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end

					local tween = TweenService:Create(
						motor6D,
						TweenInfo.new(v10 / 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							C0 = motor6D.C0 * CFrame.Angles(-0.4072434921320102, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end)
				ClawSlash(cFrame, folder, v6, player) -- equivalent call inferred; original call site unknown
				local clone = v.Phase1.HitImpactModel:Clone()
				clone:PivotTo(v8 * CFrame.new(0, 0, v6 * -12))
				Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
				clone:ScaleTo(v6)

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v14 = emitter
					task.spawn(function()
						if v14:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v14:GetAttribute("EmitDelay"))
						end

						v14:Emit(v14:GetAttribute("EmitCount"))
					end)
				end

				DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			end)
		end
	elseif stage == 4 then
		if slam then
			task.spawn(function()
				task.wait(0.1)
				local v8 = root.CFrame * CFrame.new(0, v6 * 3, v6 * -1) * CFrame.Angles(0, 0, -0)
				local cFrame = v8 * CFrame.Angles(1.0471975511965976, 0, 0) * CFrame.Angles(1.7453292519943295, 0, 0)
				task.spawn(function()
					local clone = v.Phase1.SpinTrail:Clone()
					clone.CFrame = cFrame
					clone.Anchored = false
					clone.CanCollide = false
					clone.CanTouch = false
					clone.CanQuery = false
					clone.Massless = true
					Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
					local motor6D = Instance.new("Motor6D")
					motor6D.Part0 = part
					motor6D.Part1 = clone
					motor6D.C0 = part.CFrame:ToObjectSpace(clone.CFrame)
					motor6D.Parent = clone
					local v10 = 0.1 * math.random() + 0.075

					for _ = 1, 3 do
						local tween = TweenService:Create(
							motor6D,
							TweenInfo.new(v10 / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								C0 = motor6D.C0 * CFrame.Angles(-1.2217304763960306, 0, 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end

					local tween = TweenService:Create(
						motor6D,
						TweenInfo.new(v10 / 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							C0 = motor6D.C0 * CFrame.Angles(-0.4072434921320102, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end)
				ClawSlash(cFrame, folder, v6, player) -- equivalent call inferred; original call site unknown
				local clone = v.Phase1.HitImpactModel:Clone()
				clone:PivotTo(v8 * CFrame.new(0, 0, v6 * -12))
				Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
				clone:ScaleTo(v6)

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v14 = emitter
					task.spawn(function()
						if v14:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v14:GetAttribute("EmitDelay"))
						end

						v14:Emit(v14:GetAttribute("EmitCount"))
					end)
				end

				DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
				local clone2 = v.Phase1.GroundCrack2:Clone()
				clone2.CFrame = v8 * CFrame.new(0, -4.75, v6 * -12)
				Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v14 = emitter
					task.spawn(function()
						if v14:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v14:GetAttribute("EmitDelay"))
						end

						v14:Emit(v14:GetAttribute("EmitCount"))
					end)
				end

				DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
			end)
		else
			task.spawn(function()
				task.wait(0.1)
				local v8 = root.CFrame * CFrame.new(v6 * -2, v6 * 5, v6 * -3) * CFrame.Angles(0, 0, 3.141592653589793) * CFrame.Angles(
					0,
					0,
					0.6981317007977318
				)
				local cFrame = v8 * CFrame.Angles(1.0471975511965976, 0, 0) * CFrame.Angles(1.7453292519943295, 0, 0)
				task.spawn(function()
					local clone = v.Phase1.SpinTrail:Clone()
					clone.CFrame = cFrame
					clone.Anchored = false
					clone.CanCollide = false
					clone.Massless = true
					Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
					local motor6D = Instance.new("Motor6D")
					motor6D.Part0 = part
					motor6D.Part1 = clone
					motor6D.C0 = part.CFrame:ToObjectSpace(clone.CFrame)
					motor6D.Parent = clone
					local v10 = 0.1 * math.random() + 0.075

					for _ = 1, 3 do
						local tween = TweenService:Create(
							motor6D,
							TweenInfo.new(v10 / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								C0 = motor6D.C0 * CFrame.Angles(-1.2217304763960306, 0, 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end

					local tween = TweenService:Create(
						motor6D,
						TweenInfo.new(v10 / 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							C0 = motor6D.C0 * CFrame.Angles(-0.4072434921320102, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end)
				ClawSlash(cFrame, folder, v6, player) -- equivalent call inferred; original call site unknown
				local clone = v.Phase1.HitImpactModel:Clone()
				clone:PivotTo(v8 * CFrame.new(0, 0, v6 * -12))
				Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
				clone:ScaleTo(v6)

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v14 = emitter
					task.spawn(function()
						if v14:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v14:GetAttribute("EmitDelay"))
						end

						v14:Emit(v14:GetAttribute("EmitCount"))
					end)
				end

				DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			end)
		end
	elseif stage == 5 and slam then
		task.spawn(function()
			task.wait(0.1)
			local v8 = root.CFrame * CFrame.new(0, v6 * 3, v6 * -1)
			local v9 = v8 * CFrame.Angles(0, 0, -0)
			local cFrame2 = v9 * CFrame.Angles(1.3962634015954636, 0, 0) * CFrame.Angles(1.7453292519943295, 0, 0)
			task.spawn(function()
				local clone = v.Phase1.SpinTrail:Clone()
				clone.CFrame = cFrame2
				clone.Anchored = false
				clone.CanCollide = false
				clone.CanTouch = false
				clone.CanQuery = false
				clone.Massless = true
				Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
				local motor6D = Instance.new("Motor6D")
				motor6D.Part0 = part
				motor6D.Part1 = clone
				motor6D.C0 = part.CFrame:ToObjectSpace(clone.CFrame)
				motor6D.Parent = clone
				local v11 = 0.1 * math.random() + 0.075

				for _ = 1, 3 do
					local tween = TweenService:Create(
						motor6D,
						TweenInfo.new(v11 / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							C0 = motor6D.C0 * CFrame.Angles(-1.2217304763960306, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end

				local tween = TweenService:Create(
					motor6D,
					TweenInfo.new(v11 / 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						C0 = motor6D.C0 * CFrame.Angles(-0.4072434921320102, 0, 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end)
			ClawSlash(cFrame2, folder, v6, player) -- equivalent call inferred; original call site unknown
			local clone = v.Phase1.HitImpactModel:Clone()
			clone:PivotTo(v9 * CFrame.new(0, 0, v6 * -12))
			Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
			clone:ScaleTo(v6)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v15 = emitter
				task.spawn(function()
					if v15:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v15:GetAttribute("EmitDelay"))
					end

					v15:Emit(v15:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			local clone2 = v.Phase1.GroundCrack3:Clone()
			clone2.CFrame = v9 * CFrame.new(0, -4.75, v6 * -12)
			Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v15 = emitter
				task.spawn(function()
					if v15:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v15:GetAttribute("EmitDelay"))
					end

					v15:Emit(v15:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
			local raycastParams = RaycastParams.new()
			raycastParams.IgnoreWater = false
			raycastParams.FilterDescendantsInstances = {
				workspace._WorldOrigin,
				workspace.Characters,
				workspace.Enemies
			}

			local function RockCrater(p, p2, data2)
				task.spawn(function()
					local rockType = data2.RockType
					local radius = data2.Radius
					local size = data2.Size
					local duration = data2.Duration
					local amount = data2.Amount
					local v15 = AlignCFrame(CFrame.new(p.Position), p.Normal) + p.Normal * 0.01
					local v16 = {}

					for _ = 1, amount do
						local clone3 = rockType:Clone()
						rocks:ApplyCollision(clone3, nil, true)
						Util.SetParentOverrideWithColor(clone3, p2, player, "MagnetFruitVFXColor")
						DestroyAfter(clone3, 7) -- equivalent call inferred; original call site unknown
						table.insert(v16, clone3)
					end

					task.spawn(function()
						task.wait(duration * 3)

						for _, v17 in pairs(v16) do
							v17:Destroy()
						end

						v16 = nil
					end)
					local v17 = 360 / #v16
					local total = 0

					for _, v18 in pairs(v16) do
						total += v17
						v18.CFrame = v15 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
						v18.CFrame = CFrame.new(v18.Position, p.Position + createVector(0, 5, 0)) * CFrame.new(
							0,
							math.random(-5, 5) / 3,
							math.random(-350, 450) / 100
						)
						Ray.new(v18.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
						local raycastParams2 = RaycastParams.new()
						raycastParams2.FilterDescendantsInstances = raycastParams.FilterDescendantsInstances
						raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
						local raycastResult = workspace:Raycast(
							v18.Position + createVector(0, 1, 0),
							createVector(-0, -71.42857, -0),
							raycastParams2
						)

						if raycastResult then
							local v19 = (v18.Position - p.Position).Magnitude / 50
							local v20 = size * math.random(20, 40) / 10
							local v21 = size * math.random(10, 30) / 10
							local v22 = size * math.random(30, 50) / 10
							v18.Size = Vector3.new(v20 / 2 + v20 * v19, v21 / 2 + v21 * v19, v22 / 2 + v22 * v19)
							v18.Position = raycastResult.Position + Vector3.new(0, -v18.Size.Y / 2, 0)
							v18.CFrame = CFrame.new(v18.Position, p.Position) * CFrame.new(
								0,
								math.random(-5, 5) / 10,
								math.random(-25, 25) / 5
							)
							v18.CFrame = CFrame.new(v18.Position, v15.Position) * CFrame.Angles(
								math.rad(-math.random(10, 15) / 1 - (15 + 15 * v19)),
								0,
								0
							) * CFrame.Angles(0, 0, (math.rad((math.random(-25, 25)))))
							v18.Material = raycastResult.Instance.Material
							v18.Color = raycastResult.Instance.Color
						else
							v18:Destroy()
							v16[v18] = nil
						end

						TweenService:Create(v18, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Position = v18.Position + Vector3.new(0, v18.Size.Y / 1.75, 0)
						}):Play()
						local v19 = v18
						local v20 = v18
						task.spawn(function()
							task.wait(duration + math.random(10, 35) / 100)
							local tween = TweenService:Create(
								v19,
								TweenInfo.new(
									0.5,
									Enum.EasingStyle.Back,
									Enum.EasingDirection.In,
									0,
									false,
									math.random(10, 35) / 100
								),
								{
									Position = v19.Position + Vector3.new(
										math.random(-1, 1),
										-v19.Size.Y * math.random(20, 25) / 10,
										math.random(-1, 1)
									)
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v19:Destroy()
							v16[v19] = nil
						end)
					end
				end)
			end

			local function FlyRock(cFrame, raycastResult, folder2)
				local clone3 = v.Phase1.Rock:Clone()
				rocks:ApplyCollision(clone3, nil, true)
				clone3.CFrame = cFrame
				clone3.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
				clone3.Size *= math.random(3, 6) / 7
				clone3.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
				clone3.Material = raycastResult.Instance.Material
				clone3.Color = raycastResult.Instance.Color
				clone3.CanCollide = false
				Util.SetParentOverrideWithColor(clone3, folder2, player, "MagnetFruitVFXColor")
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(70000000000, 70000000000, 70000000000)
				bodyVelocity.P = 5000
				bodyVelocity.Parent = clone3
				local vector2 = Vector3.new(math.random(-30, 30) * 1.5, 0, math.random(-30, 30) * 1.5)
				local vector3 = Vector3.new(0, math.random(150, 200) / 7, 0)
				local v15 = math.random(50, 250) * 0.5
				bodyVelocity.Velocity = CFrame.new(clone3.Position, clone3.Position + vector2 + vector3).LookVector * v15
				task.delay(1 * math.random() + 2.5, function()
					TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
						Size = createVector(0, 0, 0)
					}):Play()
				end)
				task.delay(0.025 * math.random() + 0.025, function()
					bodyVelocity:Destroy()
					task.wait(0.1)
					clone3.CanCollide = true
				end)
			end

			local v15 = v8 * CFrame.new(0, 0, -13.5)
			local raycastResult = workspace:Raycast(
				v15.Position + createVector(0, 1, 0),
				createVector(-0, -15, -0),
				raycastParams
			)

			if raycastResult then
				local v16 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
				local v17 = {
					Radius = 17.5,
					Size = 2,
					Duration = 0.75,
					Amount = 20,
					RockType = v.Phase1.CraterRock
				}
				local v18 = folder
				task.spawn(function()
					local rockType = v17.RockType
					local radius = v17.Radius
					local size = v17.Size
					local duration = v17.Duration
					local amount = v17.Amount
					local v19 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
					local v20 = {}

					for _ = 1, amount do
						local clone3 = rockType:Clone()
						rocks:ApplyCollision(clone3, nil, true)
						Util.SetParentOverrideWithColor(clone3, v18, player, "MagnetFruitVFXColor")
						DestroyAfter(clone3, 7) -- equivalent call inferred; original call site unknown
						table.insert(v20, clone3)
					end

					task.spawn(function()
						task.wait(duration * 3)

						for _, v21 in pairs(v20) do
							v21:Destroy()
						end

						v20 = nil
					end)
					local v21 = 360 / #v20
					local total = 0

					for _, v22 in pairs(v20) do
						total += v21
						v22.CFrame = v19 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
						v22.CFrame = CFrame.new(v22.Position, raycastResult.Position + createVector(0, 5, 0)) * CFrame.new(
							0,
							math.random(-5, 5) / 3,
							math.random(-350, 450) / 100
						)
						Ray.new(v22.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
						local raycastParams2 = RaycastParams.new()
						raycastParams2.FilterDescendantsInstances = raycastParams.FilterDescendantsInstances
						raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
						local raycastResult2 = workspace:Raycast(
							v22.Position + createVector(0, 1, 0),
							createVector(-0, -71.42857, -0),
							raycastParams2
						)

						if raycastResult2 then
							local v23 = (v22.Position - raycastResult.Position).Magnitude / 50
							local v24 = size * math.random(20, 40) / 10
							local v25 = size * math.random(10, 30) / 10
							local v26 = size * math.random(30, 50) / 10
							v22.Size = Vector3.new(v24 / 2 + v24 * v23, v25 / 2 + v25 * v23, v26 / 2 + v26 * v23)
							v22.Position = raycastResult2.Position + Vector3.new(0, -v22.Size.Y / 2, 0)
							v22.CFrame = CFrame.new(v22.Position, raycastResult.Position) * CFrame.new(
								0,
								math.random(-5, 5) / 10,
								math.random(-25, 25) / 5
							)
							v22.CFrame = CFrame.new(v22.Position, v19.Position) * CFrame.Angles(
								math.rad(-math.random(10, 15) / 1 - (15 + 15 * v23)),
								0,
								0
							) * CFrame.Angles(0, 0, (math.rad((math.random(-25, 25)))))
							v22.Material = raycastResult2.Instance.Material
							v22.Color = raycastResult2.Instance.Color
						else
							v22:Destroy()
							v20[v22] = nil
						end

						TweenService:Create(v22, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Position = v22.Position + Vector3.new(0, v22.Size.Y / 1.75, 0)
						}):Play()
						local v23 = v22
						local v24 = v22
						task.spawn(function()
							task.wait(duration + math.random(10, 35) / 100)
							local tween = TweenService:Create(
								v23,
								TweenInfo.new(
									0.5,
									Enum.EasingStyle.Back,
									Enum.EasingDirection.In,
									0,
									false,
									math.random(10, 35) / 100
								),
								{
									Position = v23.Position + Vector3.new(
										math.random(-1, 1),
										-v23.Size.Y * math.random(20, 25) / 10,
										math.random(-1, 1)
									)
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v23:Destroy()
							v20[v23] = nil
						end)
					end
				end)
				task.spawn(function()
					for i = 1, 10 do
						task.spawn(function()
							FlyRock(
								v16 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
									0,
									0,
									-math.random(125, 150) / 7
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
				task.spawn(function() end)
			end
		end)
	end
end