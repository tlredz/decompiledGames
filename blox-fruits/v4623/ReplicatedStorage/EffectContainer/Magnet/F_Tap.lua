local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local Global = require(ReplicatedStorage.Global)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local F = FX:WaitForChild("Magnet"):WaitForChild("F")
local f_Held = FX:WaitForChild("Magnet"):WaitForChild("F_Held")
local jetpack = FX:WaitForChild("Magnet"):WaitForChild("Jetpack")
local jetpackArcsteel = FX:WaitForChild("Magnet"):WaitForChild("JetpackArcsteel")
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local v = {
	ScrapModelA = "ArcsteelScrapModelA",
	ScrapModelA2 = "ArcsteelScrapModelB"
}

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

local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local _WorldOrigin = workspace._WorldOrigin

local function RecolorMagnetColor(instance, p)
	if typeof(instance) == "Instance" and instance.Parent then
		return WrapColor3Constructor(p, instance, "MagnetFruitVFXColor")
	end

	return p
end

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

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function QuadBezier(p, p2, p3, p4)
	return (1 - p4) ^ 2 * p + 2 * (1 - p4) * p4 * p2 + p4 ^ 2 * p3
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (p4 - p3) * p
	local v4 = p4 + (p5 - p4) * p
	local v5 = v2 + (v3 - v2) * p
	return v5 + (v3 + (v4 - v3) * p - v5) * p
end

local function TrailCurve(clone, startCFrame, position, position2, cframe, cframe2, p)
	local magnitude = (position - position2).Magnitude
	local v2 = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v2 / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v2 / 1.5)).Position
	math.random(20, 30)
	local v3 = CFrame.new(position3, position3 + startCFrame.LookVector) * cframe.Position
	local v4 = CFrame.new(position4, position4 + startCFrame.LookVector) * cframe2.Position
	local lastTime = tick()
	local v5 = magnitude / p / 60
	local _ = (magnitude / p + p) / 60

	while tick() - lastTime < v5 do
		local v6 = (tick() - lastTime) / v5
		local v7 = cubicBezier(v6, position, v3, v4, position2)
		clone.CFrame = CFrame.new(clone.CFrame:Lerp(CFrame.new(v7, position2), v6).Position)
		RunService.Heartbeat:Wait()
	end
end

local function AlignCFrame(data, p)
	local v2 = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v2).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v2).Unit
	return CFrame.fromMatrix(p2, unit2, v2, unit3)
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

local function DashTrail(instance, position)
	local position2 = instance.Position
	local magnitude = (position2 - position).Magnitude
	instance.CFrame = CFrame.new(position2, position)
	local v2 = (position2 - position) / 2
	local position3 = CFrame.new(CFrame.new(position2) * (v2 / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v2 / 1.5)).Position
	local v3 = math.random(20, 30)
	local v4 = position3 + Vector3.new(math.random(-v3, v3), math.random(-2, 2), math.random(-v3, v3))
	local v5 = position4 + Vector3.new(math.random(-v3, v3), math.random(-2, 2), math.random(-v3, v3))
	local v6 = math.random(25, 30) / 5
	local lastTime = tick()
	local v7 = magnitude / v6 / 60

	while tick() - lastTime < v7 do
		local v8 = (tick() - lastTime) / v7
		local v9 = cubicBezier(v8, position2, v4, v5, position)
		instance.CFrame = instance.CFrame:Lerp(CFrame.new(v9, position), v8)
		RunService.Heartbeat:Wait()
	end
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
	local player = data.Player

	if stage == 1 then
		local holding = data.Holding
		local folder = Instance.new("Folder")
		folder.Name = "MagnetFJetpack_" .. player.Name
		folder.Parent = _WorldOrigin
		local root = data.Root
		local _ = root.Position
		local currentTier = root.Parent:FindFirstChild("MagnetArmFunctions"):GetAttribute("CurrentTier") or 1
		local crimsonGoldSkin = hasCrimsonGoldSkin(player)
		local v2

		if crimsonGoldSkin then
			v2 = jetpackArcsteel
		else
			v2 = jetpack
		end

		local clone = v2:Clone()
		clone.Name = "Jetpack"
		clone.PrimaryPart.CFrame = root.CFrame

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")

		if currentTier == 1 then
			Util.Sound:Play("Magnet_Untransformed_F_JetpackAssemble_Small_01", root)
		elseif currentTier == 2 then
			Util.Sound:Play("Magnet_Untransformed_F_JetpackAssemble_Medium_01", root)
		elseif currentTier == 3 then
			Util.Sound:Play("Magnet_Untransformed_F_JetpackAssemble_Large_01", root)
		end

		local v3 = Util.Anims:Get(clone, "UnTr_ Jetpack Assemble")
		v3.Looped = false
		v3:Play()
		v3:AdjustSpeed(2)
		clone.PrimaryPart.Anchored = false
		clone.PrimaryPart.Weld.Part1 = root.Parent.UpperTorso

		if crimsonGoldSkin then
			clone.PrimaryPart.Weld.C0 *= CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, -0.66, -2.85)
		end

		task.delay(0.7, function()
			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter:IsDescendantOf(clone.STRONG) then
					task.delay(0.15, function() end)
				else
					emitter.Enabled = true
					task.delay(0.15, function() end)
				end
			end
		end)

		repeat
			task.wait()
		until not (holding and holding.Value)

		Util.Debris:AddItem(folder, 20)
	elseif stage == 2 then
		local child = workspace._WorldOrigin:FindFirstChild("MagnetFJetpack_" .. player.Name)

		if not child then
			return
		end

		child.Name = "Destroying"
		local root = data.Root
		local _ = root.Position
		local startCFrame = data.StartCFrame
		local jetpack2 = child.Jetpack
		local magnetArmFunctions = root.Parent:FindFirstChild("MagnetArmFunctions")

		if magnetArmFunctions then
			local folder = Instance.new("Folder")
			folder.Name = "HoldingSkill"
			folder:SetAttribute("HardSnap", true)
			folder.Parent = magnetArmFunctions
			Util.Debris:AddItem(folder, data.DashSpeed + 0.25 + 0.2)
		end

		local magnetArms = root.Parent:FindFirstChild("MagnetArms")
		local v2

		if magnetArms then
			local floatingRightArm = magnetArms:FindFirstChild("FloatingRightArm")
			v2 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Untr_Magnet F Dash R") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		local magnetArms2 = root.Parent:FindFirstChild("MagnetArms")
		local v3

		if magnetArms2 then
			local floatingLeftArm = magnetArms2:FindFirstChild("FloatingLeftArm")
			v3 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Untr_Magnet F Dash L") or nil
		else
			warn("Magnet Arms Folder missing!")
		end

		if v2 and v3 then
			v2.Priority = Enum.AnimationPriority.Action3
			v2.Looped = false
			v2:Play()
			v3.Priority = Enum.AnimationPriority.Action3
			v3.Looped = false
			v3:Play()
		end

		root.Anchored = true
		TweenService:Create(root, TweenInfo.new(0.25), {
			CFrame = root.CFrame * CFrame.new(0, 5, 0)
		}):Play()
		Util.Sound:Play("Magnet_Untransformed_F_Tap_Release_Dash_V2_01", root)

		for _, emitter in pairs(jetpack2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") or emitter:IsDescendantOf(jetpack2.STRONG) then
				continue
			end

			emitter.Enabled = true
		end

		task.wait(0.25)
		root.CFrame = startCFrame * CFrame.new(0, 5, 0)
		local dashDist = data.DashDist
		task.spawn(function()
			local clone = F.Phase1.SpinSlash:Clone()
			clone:PivotTo(startCFrame)
			Util.SetParentOverrideWithColor(clone, child, player, "MagnetFruitVFXColor")
			local model2 = clone.Model2
			local v4 = -35

			for i = 1, 5 do
				local clone2 = model2:Clone()
				local v6

				if i == 1 then
					v6 = 1.15
				else
					v6 = 1.15

					if i == 2 then
						v6 = 1.25
						v4 = -50
					elseif i == 3 then
						v6 = 1.35
						v4 = -75
					elseif i == 4 then
						v6 = 1.45
						v4 = -65
					elseif i == 5 then
						v6 = 1.1
						v4 = -35
					end
				end

				clone2:ScaleTo((i * 1.05 + 5) / v6)

				for _, beam in pairs(clone2:GetDescendants()) do
					if beam:IsA("Beam") then
						beam.Enabled = true
					end
				end

				local primaryPart = clone2.PrimaryPart
				local v7 = clone.PrimaryPart.CFrame * CFrame.new(0, 0, v4 * 0.567 * i) * CFrame.Angles(
					math.rad(math.random(-180, 180) / 100),
					math.rad(math.random(-180, 180) / 100),
					(math.rad((math.random(-180, 180))))
				)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.Position
				angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
				clone2:PivotTo(v7)
				local v8 = i
				task.spawn(function()
					task.wait(v8 * 0.025)
					Util.SetParentOverrideWithColor(clone2, clone, player, "MagnetFruitVFXColor")
				end)
				clone2:GetScale()
				task.spawn(function()
					TweenService:Create(
						angularVelocity,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
								math.random(-5, 5) / 5,
								math.random(-5, 5) / 5,
								math.random(5, 10)
							)
						}
					):Play()
					task.wait(0.15 * math.random() + 0.15 / v6)

					for i2, effect in pairs(clone2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.15 / v6 + math.random() * 0.15 / v6), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v10 = effect
							task.delay(1, function()
								v10:Destroy()
							end)
						elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					task.wait(1)
					angularVelocity.Enabled = false
				end)
			end

			task.spawn(function()
				local v5 = clone:GetScale() * 0.5
				local v6 = v5 * 1.15

				for i = v5 * 100, v6 * 100, 10 do
					clone:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
		task.spawn(function()
			local clone = F.Phase1.SpinSlash2:Clone()
			clone:PivotTo(startCFrame * CFrame.new(0, 0, -10))
			Util.SetParentOverrideWithColor(clone, child, player, "MagnetFruitVFXColor")
			local model = clone.Model
			local v4 = -35

			for i = 1, 5 do
				local clone2 = model:Clone()
				local v6

				if i == 1 then
					v6 = 1.15
				else
					v6 = 1.15

					if i == 2 then
						v6 = 1.25
						v4 = -50
					elseif i == 3 then
						v6 = 1.35
						v4 = -75
					elseif i == 4 then
						v6 = 1.45
						v4 = -65
					elseif i == 5 then
						v6 = 1.1
						v4 = -35
					end
				end

				clone2:ScaleTo((i * 1.05 + 3) / v6)

				for _, beam in pairs(clone2:GetDescendants()) do
					if beam:IsA("Beam") then
						beam.Enabled = true
					end
				end

				local primaryPart = clone2.PrimaryPart
				local v7 = clone.PrimaryPart.CFrame * CFrame.new(0, 0, v4 * 0.567 * i) * CFrame.Angles(
					math.rad(math.random(-180, 180) / 100),
					math.rad(math.random(-180, 180) / 100),
					(math.rad((math.random(-180, 180))))
				)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.Position
				angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
				clone2:PivotTo(v7)
				local v8 = i
				task.spawn(function()
					task.wait(v8 * 0.025)
					Util.SetParentOverrideWithColor(clone2, clone, player, "MagnetFruitVFXColor")
				end)
				clone2:GetScale()
				task.spawn(function()
					TweenService:Create(
						angularVelocity,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
								math.random(-5, 5) / 5,
								math.random(-5, 5) / 5,
								math.random(5, 10)
							)
						}
					):Play()
					task.wait(0.15 * math.random() + 0.15 / v6)

					for i2, effect in pairs(clone2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.15 / v6 + math.random() * 0.15 / v6), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v10 = effect
							task.delay(1, function()
								v10:Destroy()
							end)
						elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					task.wait(1)
					angularVelocity.Enabled = false
				end)
			end

			task.spawn(function()
				local v5 = clone:GetScale() * 0.5
				local v6 = v5 * 1.25

				for i = v5 * 100, v6 * 100, 10 do
					clone:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
		local clone = F.Phase1.DashAura:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, child, player, "MagnetFruitVFXColor")
		clone.Anchored = false
		clone.Weld.Part1 = root

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local dashSpeed = data.DashSpeed
		TweenService:Create(root, TweenInfo.new(dashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = root.CFrame * CFrame.new(0, -5, -dashDist)
		}):Play()
		local v4 = tick() + dashSpeed
		local now = tick()
		local v5 = {}

		while true do
			if now - tick() <= 0 then
				now = tick() + 0.01

				for i = 1, math.random(1, 2) do
					local v6 = i
					task.spawn(function()
						local worldPosition = root.Position + Vector3.new(
							math.random(-25, 25) / 2,
							-10,
							math.random(-25, 25) / 2
						)
						local clone2 = script.Part:Clone()
						clone2.CFrame = CFrame.new(root.Position, worldPosition)
						Util.SetParentOverrideWithColor(clone2, child, player, "MagnetFruitVFXColor")
						clone2.Anchored = false
						clone2.Weld.Part1 = root
						clone2.Massless = true
						clone2.Weld.C1 = CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-0, 0)) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							-1.5707963267948966
						)
						clone2.Attach1.WorldPosition = worldPosition
						clone2.Attach1:SetAttribute("Pos", worldPosition)
						clone2.Attach0.Orientation = Vector3.new(
							math.random(-180, 180),
							math.random(-180, 180),
							math.random(-180, 180)
						)
						local shafiBolt = ShafiBolt(
							clone2.Attach0,
							clone2.Attach1,
							math.random(15, 20) / 2,
							0.25 + math.random() * 0.25,
							child,
							math.random(-15, 5) * 1.25,
							math.random(-5, 15) * 1.25
						)

						if v6 == 1 then
							local player2 = data.Player
							local color = Color3.fromRGB(25, 48, 255)

							if typeof(player2) == "Instance" and player2.Parent then
								color = WrapColor3Constructor(color, player2, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color
						else
							local player2 = data.Player
							local color = Color3.fromRGB(71, 58, 255)

							if typeof(player2) == "Instance" and player2.Parent then
								color = WrapColor3Constructor(color, player2, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color
						end

						v5[clone2.Attach1] = shafiBolt
						task.wait(0.215 * math.random() + 0.15)
						v5[clone2.Attach1] = nil
						shafiBolt:Destroy()
					end)
				end
			end

			for k, _ in pairs(v5) do
				local pos = k:GetAttribute("Pos")
				k.WorldPosition = CFrame.new(pos, root.Position).Position
			end

			task.wait()

			if not (v4 - tick() <= 0) then
				continue
			end

			for k, _ in pairs(v5) do
				k.Parent.Weld.Enabled = false
				k.Parent.Anchored = true
			end

			root.Anchored = false

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone.Weld.Enabled = false
			clone.Anchored = true
			task.wait(0.05)

			if data.HitTarget then
				local cFrame = startCFrame * CFrame.new(0, 0, -dashDist)
				local clone2 = F.Phase2.ExStartImpact:Clone()
				clone2.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone2, child, player, "MagnetFruitVFXColor")
				Util.Sound:Play("Magnet_Untransformed_F_On_Hit_Effect_01", root.Position)
				local magnetArms3 = root.Parent:FindFirstChild("MagnetArms")
				local v7

				if magnetArms3 then
					local floatingRightArm = magnetArms3:FindFirstChild("FloatingRightArm")
					v7 = floatingRightArm and Util.Anims:Get(floatingRightArm, "Untr_Magnet F Dash R Hit") or nil
				else
					warn("Magnet Arms Folder missing!")
				end

				local magnetArms4 = root.Parent:FindFirstChild("MagnetArms")
				local v8

				if magnetArms4 then
					local floatingLeftArm = magnetArms4:FindFirstChild("FloatingLeftArm")
					v8 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "Untr_Magnet F Dash L Hit") or nil
				else
					warn("Magnet Arms Folder missing!")
				end

				if v7 and v8 then
					v7.Priority = Enum.AnimationPriority.Action4
					v7.Looped = false
					v7:Play()
					v8.Priority = Enum.AnimationPriority.Action4
					v8.Looped = false
					v8:Play()
				end

				local v9 = Util.Anims:Get(root.Parent, "Untr_Magnet R15 Magnet F Dash Hit")
				v9.Priority = Enum.AnimationPriority.Action3
				v9.Looped = false
				v9:Play()
				DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				for _ = 1, 13 do
					local cFrame2 = cFrame
					task.spawn(function()
						local clone3 = F.Phase2.Trail:Clone()
						clone3.CFrame = cFrame2
						Util.SetParentOverrideWithColor(clone3, child, player, "MagnetFruitVFXColor")
						clone3.CFrame = clone3.CFrame * CFrame.Angles(
							math.rad(math.random(-180, 180) / 5),
							math.rad(math.random(-180, 180) / 100),
							(math.rad(math.random(-180, 180) / 5))
						) * CFrame.new(0, 0, math.random(40, 70))

						for i, effect in pairs(clone3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = true
							end
						end

						TrailCurve(
							clone3,
							startCFrame,
							clone3.Position,
							cFrame2.Position,
							CFrame.new(math.random(-50, 50) / 1, math.random(-50, 50) / 2, math.random(-50, 50) / 1),
							CFrame.new(math.random(-50, 50) / 1, math.random(-50, 50) / 2, math.random(-50, 50) / 1),
							math.random(25, 30) / 7,
							true
						)

						for i, effect in pairs(clone3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
				end

				task.wait(0.1)
				task.wait(0.15)
				task.spawn(function()
					local clone3 = F.Phase2.ImpactTrail:Clone()
					clone3.CFrame = cFrame * CFrame.new(0, 5, 5)
					Util.SetParentOverrideWithColor(clone3, child, player, "MagnetFruitVFXColor")

					for i, effect in pairs(clone3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					TweenService:Create(
						clone3,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = cFrame * CFrame.new(0, 5, -125)
						}
					):Play()
					task.wait(0.15)

					for i, effect in pairs(clone3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
				local clone3 = F.Phase2.Explosion:Clone()
				clone3.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone3, child, player, "MagnetFruitVFXColor")

				if (workspace.CurrentCamera.CFrame.p - cFrame.Position).Magnitude < 75 then
					Util.CameraShaker:ShakeOnce(7, 6, 0.1, 0.4)
				end

				DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone3:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v11 = emitter
					task.spawn(function()
						if v11:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v11:GetAttribute("EmitDelay"))
						end

						local lifetime = v11.Lifetime
						v11.Lifetime = NumberRange.new(lifetime.Min * 2, lifetime.Max * 2)
						v11:Emit(v11:GetAttribute("EmitCount"))
					end)
				end

				local cFrame3 = cFrame
				task.spawn(function()
					local clone4 = F.Phase1.SpinSlash:Clone()
					clone4:PivotTo(cFrame3 * CFrame.new(0, 0, 25))
					Util.SetParentOverrideWithColor(clone4, child, player, "MagnetFruitVFXColor")
					local model2 = clone4.Model2
					local v12 = -35

					for i = 1, 3 do
						local clone5 = model2:Clone()
						local v14

						if i == 1 then
							v14 = 1.15
						else
							v14 = 1.15

							if i == 2 then
								v14 = 0.85
								v12 = -50
							elseif i == 3 then
								v14 = 1.35
								v12 = -60
							end
						end

						clone5:ScaleTo((i * 1.05 + 5) / v14)

						for i2, beam in pairs(clone5:GetDescendants()) do
							if beam:IsA("Beam") then
								beam.Enabled = true
							end
						end

						local primaryPart = clone5.PrimaryPart
						local v15 = clone4.PrimaryPart.CFrame * CFrame.new(0, 0, v12 * 0.567 * i) * CFrame.Angles(
							math.rad(math.random(-180, 180) / 100),
							math.rad(math.random(-180, 180) / 100),
							(math.rad((math.random(-180, 180))))
						)
						local angularVelocity = primaryPart.AngularVelocity
						primaryPart.Anchored = false
						primaryPart.AlignPosition.Position = primaryPart.Position
						angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
						clone5:PivotTo(v15)
						local v16 = i
						task.spawn(function()
							task.wait(v16 * 0.025)
							Util.SetParentOverrideWithColor(clone5, clone4, player, "MagnetFruitVFXColor")
						end)
						clone5:GetScale()
						task.spawn(function()
							TweenService:Create(
								angularVelocity,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
										math.random(-5, 5) / 5,
										math.random(-5, 5) / 5,
										math.random(5, 10)
									)
								}
							):Play()
							task.wait(0.05 * math.random() + 0.1 / v14)

							for i2, effect in pairs(clone5:GetDescendants()) do
								if effect:IsA("Beam") then
									TweenService:Create(
										effect,
										TweenInfo.new(0.15 / v14 + math.random() * 0.15 / v14),
										{
											Width0 = 0,
											Width1 = 0
										}
									):Play()
									local v18 = effect
									task.delay(1, function()
										v18:Destroy()
									end)
								elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end

							task.wait(1)
							angularVelocity.Enabled = false
						end)
					end

					task.spawn(function()
						local v13 = clone4:GetScale() * 0.5
						local v14 = v13 * 1.35

						for i = v13 * 100, v14 * 100, 10 do
							clone4:ScaleTo(i / 100)
							task.wait(0.005)
						end
					end)
				end)
				task.wait(0.05)
				local clone4 = F.Phase1.EndImpact:Clone()
				clone4.CFrame = root.CFrame
				Util.SetParentOverrideWithColor(clone4, child, player, "MagnetFruitVFXColor")
				DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				Util.Sound:Play("Magnet_Untransformed_F_JetpackDisassemble_01", root)
			end

			jetpack2:Destroy()
			return
		end
	elseif stage == 3 then
		local child = workspace._WorldOrigin:FindFirstChild("MagnetFJetpack_" .. player.Name)

		if not child then
			return
		end

		child.Name = "Destroying"
		local proxy = data.Proxy

		if not proxy then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "MagnetFJetpack2_" .. player.Name
		folder.Parent = workspace._WorldOrigin
		local root = data.Root
		local magnetArmFunctions = root.Parent:FindFirstChild("MagnetArmFunctions")
		local currentTier = magnetArmFunctions:GetAttribute("CurrentTier") or 1
		local jetpack2 = child.Jetpack
		jetpack2.Parent = folder
		local v2 = Util.Anims:Get(jetpack2, "UnTr_ jetpack Looped Fly")
		v2.Priority = Enum.AnimationPriority.Action
		v2.Looped = true
		v2:Play()
		local folder2 = Instance.new("Folder")
		folder2.Name = "HoldingSkill"
		folder2:SetAttribute("HardSnap", true)
		folder2.Parent = data.MagnetProxy
		local _ = root.Position
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local cFrame = root.CFrame
		local clone = F.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		local v3 = nil

		local function swapIdleSound(currentTier2)
			if v3 then
				Util.Sound:FadeOut(v3, 0.3)
			end

			local v4 = currentTier2 == 1 and "Magnet_Untransformed_F_Held_Jetpack_Idle_Loop_Small_01" or currentTier2 == 2 and "Magnet_Untransformed_F_Held_Jetpack_Idle_Loop_Medium_01" or "Magnet_Untransformed_F_Held_Jetpack_Idle_Loop_Large_01"
			v3 = Util.Sound:Play(v4, root)

			if v3 then
				TweenService:Create(v3, TweenInfo.new(1), {
					Volume = 1
				}):Play()
			end
		end

		if currentTier == 1 then
			Util.Sound:Play("Magnet_Untransformed_F_Held_JetpackActivateLaunchUp_Small_01", root)
		elseif currentTier == 2 then
			Util.Sound:Play("Magnet_Untransformed_F_Held_JetpackActivateLaunchUp_Medium_01", root)
		else
			Util.Sound:Play("Magnet_Untransformed_F_Held_JetpackActivateLaunchUp_Large_01", root)
		end

		swapIdleSound(currentTier)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if data.Player ~= game.Players.LocalPlayer then
			task.spawn(function()
				local v4 = {}

				local function playArmAnims(p)
					for _, v5 in pairs(v4) do
						if not v5 then
							continue
						end

						local v6 = v5
						pcall(function()
							v6:Stop(0.3)
						end)
					end

					table.clear(v4)
					local magnetArms = root.Parent:FindFirstChild("MagnetArms")

					if not magnetArms then
						return
					end

					for _, v5 in pairs({ "Left", "Right" }) do
						local v6 = v5 == "Left" and "L" or "R"
						local child2 = magnetArms:FindFirstChild("Floating" .. v5 .. "Arm")

						if not child2 then
							continue
						end

						local v7 = Util.Anims:Get(child2, p .. " " .. v6)

						if not v7 then
							continue
						end

						v7.Priority = Enum.AnimationPriority.Movement
						v7.Looped = true
						v7:Play(0.2)
						table.insert(v4, v7)
					end
				end

				local v5 = nil

				while true do
					task.wait()
					local assemblyLinearVelocity = root.AssemblyLinearVelocity
					local vectorToObjectSpace = root.CFrame:VectorToObjectSpace(assemblyLinearVelocity)
					local v6

					if vectorToObjectSpace.Y > 5 then
						v6 = "Upward"
					elseif vectorToObjectSpace.Y < -5 then
						v6 = "Downward"
					elseif vectorToObjectSpace.Z < -5 then
						v6 = "Forward"
					elseif vectorToObjectSpace.Z > 5 then
						v6 = "Backward"
					elseif vectorToObjectSpace.X < -5 then
						v6 = "Left"
					elseif vectorToObjectSpace.X > 5 then
						v6 = "Right"
					else
						v6 = "Neutral"
					end

					if v6 ~= v5 then
						playArmAnims("UnTr_ Magnet F " .. v6)
						v5 = v6
					end

					if proxy:IsDescendantOf(root) then
						continue
					end

					for _, v7 in pairs(v4) do
						if not v7 then
							continue
						end

						local v8 = v7
						pcall(function()
							v8:Stop(0.3)
						end)
					end

					break
				end
			end)
		end

		local v4 = {}
		local folder3 = Instance.new("Folder")
		folder3.Name = "AuraContainer"
		folder3.Parent = folder
		local flag = false

		local function makeProxyPartAtBone(child2, _, cframe: CFrame?)
			local cFrame2 = cframe or CFrame.new()
			local part = Instance.new("Part")
			part.CastShadow = false
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			part.Anchored = false
			part.Locked = true
			part.Size = createVector(2, 0.2, 2)
			part.Name = "ProxyPart_" .. child2.Name
			local attachment = Instance.new("Attachment")
			attachment.CFrame = cFrame2
			attachment.Parent = part
			local rigidConstraint = Instance.new("RigidConstraint")
			rigidConstraint.Attachment0 = child2
			rigidConstraint.Attachment1 = attachment
			rigidConstraint.Parent = part
			part.Transparency = 1
			part.Parent = folder3
			return part
		end

		local function pinToBone(parent, bone)
			if not (parent and bone) then
				return
			end

			parent.Anchored = false
			parent.Massless = true
			parent.CanCollide = false
			local cFrame2

			if bone:IsA("Bone") then
				cFrame2 = bone.TransformedWorldCFrame
			else
				cFrame2 = bone.WorldCFrame
			end

			parent.CFrame = cFrame2
			local attachment = Instance.new("Attachment")
			attachment.Parent = parent
			local rigidConstraint = Instance.new("RigidConstraint")
			rigidConstraint.Attachment0 = bone
			rigidConstraint.Attachment1 = attachment
			rigidConstraint.Parent = parent
		end

		local function trackBone(parent, p2, magnetArms, childName: string)
			if not (parent and p2) then
				return
			end

			local part = Instance.new("Part")
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Massless = true
			part.Size = createVector(1, 1, 1)
			part.CFrame = p2.WorldCFrame
			part.Parent = folder3
			local attachment = Instance.new("Attachment")
			attachment.Parent = part
			pinToBone(parent, attachment)
			local child2 = nil
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if part.Parent and p2.Parent then
					if not (child2 and child2.Parent) then
						child2 = magnetArms:FindFirstChild(childName)
					end

					if child2 then
						part.CFrame = CFrame.new(child2.Value) * p2.WorldCFrame.Rotation * CFrame.new(0, 1.5, 0)
					else
						part.CFrame = p2.WorldCFrame
					end
				else
					part:Destroy()
					renderSteppedConnection:Disconnect()
				end
			end)
		end

		local function rebuildArmAuras()
			local magnetArms = root.Parent:FindFirstChild("MagnetArms")

			if not magnetArms then
				return
			end

			folder3:ClearAllChildren()
			local crimsonGoldSkin = hasCrimsonGoldSkin(player)
			local clonesByClone = {}

			for i = 1, 2 do
				local floatingRightArm

				if i == 2 then
					floatingRightArm = magnetArms:FindFirstChild("FloatingRightArm")
				else
					floatingRightArm = magnetArms:FindFirstChild("FloatingLeftArm")
				end

				if not floatingRightArm then
					continue
				end

				local child2 = floatingRightArm:FindFirstChild(i == 2 and "Engine.R" or "Engine.L", true)

				if not child2 then
					continue
				end

				local proxyPartAtBone = makeProxyPartAtBone(child2)
				local clone2

				if currentTier == 1 then
					clone2 = f_Held.Phase3.Tier1Aura:Clone()
				elseif currentTier == 2 then
					clone2 = f_Held.Phase3.Tier2Aura:Clone()
				else
					clone2 = f_Held.Phase3.Tier3Aura:Clone()
					local clone3

					if crimsonGoldSkin then
						clone3 = f_Held.Phase3.Tier3AuraSideArcsteel:Clone()
						clone3.Name = "Tier3AuraSide"
						Util.SetParentOverrideWithColor(clone3, clone2, player, "MagnetFruitVFXColor")
						local v5 = i == 2 and "Right" or "Left"
						local jetR = floatingRightArm:FindFirstChild("Jet.R", true)
						local jetL = floatingRightArm:FindFirstChild("Jet.L", true)
						local topJet = floatingRightArm:FindFirstChild("TopJet", true)
						trackBone(clone3:FindFirstChild("Aura1"), jetR, magnetArms, v5 .. "Jet.RJetDrift")
						trackBone(clone3:FindFirstChild("Aura2"), jetL, magnetArms, v5 .. "Jet.LJetDrift")
						pinToBone(clone3:FindFirstChild("Aura3"), topJet)
					else
						clone3 = f_Held.Phase3.Tier3AuraSide:Clone()
						clone3.CFrame = cFrame
						Util.SetParentOverrideWithColor(clone3, clone2, player, "MagnetFruitVFXColor")
						local child3 = floatingRightArm:FindFirstChild(i == 2 and "Arm.R" or "Arm.L", true)
						local part

						if child3 then
							part = makeProxyPartAtBone(child3)
						end

						clone3.Anchored = false
						clone3.Massless = true

						if part then
							clone3.Weld.Part0 = part
						end
					end

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end

				clone2.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone2, folder3, player, "MagnetFruitVFXColor")
				clone2.Anchored = false
				clone2.Massless = true
				clone2.Weld.Part0 = proxyPartAtBone
				clonesByClone[clone2] = clone2

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					if emitter:IsDescendantOf(clone2.BigAura) then
						emitter.Enabled = false
					else
						emitter.Enabled = true
					end
				end
			end

			table.clear(v4)

			for k, v5 in pairs(clonesByClone) do
				v4[k] = v5
			end
		end

		rebuildArmAuras()
		local currentTierChangedConnection = magnetArmFunctions:GetAttributeChangedSignal("CurrentTier"):Connect(function()
			local currentTier2 = magnetArmFunctions:GetAttribute("CurrentTier") or 1

			if currentTier2 == currentTier then
				return
			end

			currentTier = currentTier2
			swapIdleSound(currentTier)
			folder3:ClearAllChildren()
			table.clear(v4)
			local v5 = tick() + 3

			while tick() < v5 do
				local magnetArms = root.Parent:FindFirstChild("MagnetArms")

				if magnetArms then
					local floatingLeftArm = magnetArms:FindFirstChild("FloatingLeftArm")
					local floatingRightArm = magnetArms:FindFirstChild("FloatingRightArm")

					if floatingLeftArm and floatingRightArm and floatingLeftArm:FindFirstChild("Engine.L", true) and floatingRightArm:FindFirstChild(
						"Engine.R",
						true
					) then
						break
					end
				end

				task.wait()
			end

			if flag then
				return
			end

			rebuildArmAuras()
		end)
		local flag2 = true
		local v5 = false
		task.spawn(function()
			local v6 = nil

			while flag2 do
				task.wait()
				local assemblyLinearVelocity = root.AssemblyLinearVelocity
				local vectorToObjectSpace = root.CFrame:VectorToObjectSpace(assemblyLinearVelocity)
				local v7

				if vectorToObjectSpace.Y > 5 then
					v7 = "Upward"
				elseif vectorToObjectSpace.Y < -5 then
					v7 = "Downward"
				elseif vectorToObjectSpace.Z < -5 then
					v7 = "Forward"
				elseif vectorToObjectSpace.Z > 5 then
					v7 = "Backward"
				elseif vectorToObjectSpace.X < -5 then
					v7 = "Left"
				elseif vectorToObjectSpace.X > 5 then
					v7 = "Right"
				else
					v7 = "Neutral"
				end

				if v7 ~= v6 then
					v6 = v7
				end

				if v6 == "Forward" or v6 == "Downward" or v6 == "Upward" then
					if v5 == false then
						v5 = true

						for _, folder4 in pairs(v4) do
							for _, emitter in pairs(folder4:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end
						end
					end
				elseif v5 == true then
					v5 = false

					for _, folder4 in pairs(v4) do
						for _, emitter in pairs(folder4:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if emitter:IsDescendantOf(folder4.BigAura) then
								emitter.Enabled = false
							else
								emitter.Enabled = true
							end
						end
					end
				end
			end
		end)
		task.spawn(function()
			local position = cFrame.Position

			local function spawnPebble(raycastResult)
				local v6 = raycastResult.Position + Vector3.new(math.random(-15, 15) * 2, 0, math.random(-15, 15) * 2)
				local v7 = position
				position = v6
				local clone2 = f_Held.Phase3.Rock:Clone()
				rocks:ApplyCollision(clone2, nil, true)
				local v8 = 1.72 + math.random() * 3.0100000000000007
				clone2.Size = Vector3.new(v8, v8 * math.random(8, 14) / 20, v8)
				clone2.Material = raycastResult.Instance.Material
				clone2.Color = raycastResult.Instance.Color
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.CFrame = CFrame.new(v6 - Vector3.new(0, clone2.Size.Y, 0)) * CFrame.Angles(
					math.rad((math.random(-20, 20))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-20, 20))))
				)
				Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
				local v9 = clone2.CFrame - clone2.CFrame.Position
				local vector2 = Vector3.new(v6.X - v7.X, 0, v6.Z - v7.Z)

				if vector2.Magnitude < 0.1 then
					vector2 = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
				end

				local unit = vector2.Unit
				local v10 = 25 + math.random() * 25
				local v11 = 20 + math.random() * 40
				local position2 = clone2.CFrame.Position
				local v12 = v6 + unit * v11 + Vector3.new(0, clone2.Size.Y / 2, 0)
				local v13 = v6 + unit * (v11 * 0.5) + Vector3.new(0, v10, 0)
				local v14 = 0.1 + math.random() * 0.07499999999999998 + (0.1 + math.random() * 0.19999999999999998)
				local lastTime = tick()
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					local v15 = (tick() - lastTime) / v14

					if v15 >= 1 then
						heartbeatConnection:Disconnect()
						clone2.CanCollide = true
						clone2.Anchored = false
						task.delay(0.1, function()
							if not (clone2 and clone2.Parent) then
								return
							end

							TweenService:Create(
								clone2,
								TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = createVector(0, 0, 0)
								}
							):Play()
							local Debris = game:GetService("Debris")
							Debris:AddItem(clone2, 0.35)
						end)
						v15 = 1
					end

					local quadBezier = QuadBezier(position2, v13, v12, v15 ^ 1.6)
					clone2.CFrame = CFrame.new(quadBezier) * v9
				end)
			end

			for _, emitter in pairs(jetpack2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") or emitter:IsDescendantOf(jetpack2.STRONG) then
					continue
				end

				emitter.Enabled = true
			end

			local _ = Util.Spring
			local v6 = false
			local v7 = 20
			local clone2

			if currentTier == 1 then
				clone2 = f_Held.Phase2.GroundGas:Clone()
			elseif currentTier == 2 then
				clone2 = f_Held.Phase3.GroundGas:Clone()
				v7 = 30
			else
				clone2 = f_Held.Phase3.GroundGasBig:Clone()
				v7 = 42.5
			end

			clone2.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local now = tick()
			local now2 = tick()
			local raycastResult = nil

			while true do
				task.wait()

				if now - tick() <= 0 then
					now = tick() + 0.1
					local cFrame2 = root.CFrame
					raycastResult = workspace:Raycast(
						cFrame2.Position + createVector(0, 1, 0),
						CFrame.new(cFrame2.Position).UpVector * -v7,
						raycastParams
					)

					if raycastResult == nil then
						if v6 == true then
							v6 = false

							for _, emitter in pairs(clone2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end
					elseif raycastResult then
						local waterHeightAtVector = Global.getWaterHeightAtVector(raycastResult.Position)
						local v8 = raycastResult.Position.Y <= waterHeightAtVector

						if v8 then
							local X = raycastResult.Position.X
							local vector2 = Vector3.new(X, waterHeightAtVector + 4, raycastResult.Position.Z)
							clone2.CFrame = AlignCFrame(CFrame.new(vector2), createVector(0, 1, 0))
						else
							clone2.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
						end

						if v6 == false then
							v6 = true

							for _, emitter in pairs(clone2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end
						end

						if currentTier == 3 then
							if not v8 then
								for _ = 1, math.random(1, 2) do
									task.spawn(function()
										spawnPebble(raycastResult)
									end)
								end
							end

							if now2 - tick() <= 0 then
								now2 = tick() + 0.225
								local cFrame3 = clone2.CFrame
								task.spawn(function()
									local clone3 = f_Held.Phase3.SpinSlash:Clone()
									clone3:PivotTo(cFrame3 * CFrame.new(0, 7, 0))
									Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
									local model = clone3.Model

									for i = 1, 3 do
										local v10 = i * 1.05 + 2.15
										local clone4 = model:Clone()
										clone4:ScaleTo(v10 + 1.75)
										local primaryPart = clone4.PrimaryPart
										local v11 = clone3.PrimaryPart.CFrame * CFrame.new(0, v10, 0) * CFrame.Angles(
											0,
											math.rad((math.random(-180, 180))),
											0
										)
										local angularVelocity = primaryPart.AngularVelocity
										primaryPart.Anchored = false
										primaryPart.AlignPosition.Position = primaryPart.Position + Vector3.new(
											math.random(-10, 10) / 10,
											0,
											math.random(-10, 10) / 10
										)
										angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15), 0)
										clone4:PivotTo(v11)
										Util.SetParentOverrideWithColor(clone4, clone3, player, "MagnetFruitVFXColor")
										clone4:GetScale()
										local folder4 = clone4
										task.spawn(function()
											task.spawn(function()
												local Y = folder4.Slash.Position.Y
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
											task.wait(0.1 * math.random() + 0.135)

											for i2, effect in pairs(folder4:GetDescendants()) do
												if effect:IsA("Beam") then
													TweenService:Create(
														effect,
														TweenInfo.new(0.15 + math.random() * 0.15),
														{
															Width0 = 0,
															Width1 = 0
														}
													):Play()
													local v13 = effect
													task.delay(1, function()
														v13:Destroy()
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
									Util.Debris:AddItem(clone3, 2)
									task.spawn(function()
										local scale = clone3:GetScale()
										local v10 = scale * 1.5

										for i = scale * 100, v10 * 100, 7 do
											clone3:ScaleTo(i / 100)
											task.wait(0.005)
										end
									end)
								end)
							end
						end
					elseif v6 == true then
						v6 = false

						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end
				end

				if proxy:IsDescendantOf(root) then
					continue
				end

				local v8 = root:FindFirstChild("MagnetJetpackIgnoreStage") and true or false
				flag2 = false
				flag = true

				if currentTierChangedConnection then
					currentTierChangedConnection:Disconnect()
				end

				if v2 then
					v2:Stop()
				end

				if v3 then
					Util.Sound:FadeOut(v3, 0.3)
				end

				for _, folder4 in pairs(v4) do
					for _, emitter in pairs(folder4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				Util.Debris:AddItem(folder, 5)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				if folder2 then
					folder2:Destroy()
				end

				if v8 then
					break
				end

				for _, emitter in pairs(jetpack2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(2)
				local clone3 = F.Phase1.StartImpact:Clone()
				clone3.CFrame = root.CFrame
				Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
				DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				Util.Sound:Play("Magnet_Untransformed_F_JetpackDisassemble_01", root)
				jetpack2:Destroy()
				break
			end
		end)
	elseif stage == 4 then
		local proxy = data.Proxy

		if not proxy then
			return
		end

		local flyUpDur = data.FlyUpDur or 0.5
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		local child = workspace._WorldOrigin:FindFirstChild("MagnetFJetpack2_" .. player.Name)
		local cframe

		if hasCrimsonGoldSkin(player) then
			cframe = CFrame.Angles(0, 3.141592653589793, 0)
		else
			cframe = CFrame.new()
		end

		local jetpack2

		if child then
			child.Name = "Destroying"

			if child:FindFirstChild("Jetpack") then
				jetpack2 = child:FindFirstChild("Jetpack")
				local weld = jetpack2:FindFirstChild("Weld", true)

				if weld then
					weld:Destroy()
				end
			else
				local v2

				if hasCrimsonGoldSkin(player) then
					v2 = jetpackArcsteel
				else
					v2 = jetpack
				end

				jetpack2 = v2:Clone()
				jetpack2.Name = "Jetpack"
			end
		else
			local v2

			if hasCrimsonGoldSkin(player) then
				v2 = jetpackArcsteel
			else
				v2 = jetpack
			end

			jetpack2 = v2:Clone()
			jetpack2.Name = "Jetpack"
		end

		jetpack2.PrimaryPart.Anchored = true
		jetpack2.PrimaryPart.CFrame = proxy.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * cframe
		Util.SetParentOverrideWithColor(jetpack2, folder, player, "MagnetFruitVFXColor")
		Util.Sound:Play("Magnet_Untransformed_F_Jetpack_Tap_Release_01", proxy.CFrame.Position)

		for _, emitter in pairs(jetpack2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local clone = F.Phase2.ShootImpact:Clone()
		clone.CFrame = data.Root.CFrame * CFrame.new(0, 0, -1)
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone2 = F.Phase3.MainProjectile:Clone()
		clone2.PrimaryPart.CFrame = jetpack2.PrimaryPart.CFrame
		Util.SetParentOverrideWithColor(clone2, jetpack2, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		clone2.PrimaryPart.Massless = true
		clone2.PrimaryPart.Anchored = false
		clone2.PrimaryPart.Weld.Part1 = jetpack2.PrimaryPart
		local value = nil
		local endPos = nil
		local value2 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function readHit(hitTarget)
			if hitTarget.Name == "HitTarget" and hitTarget:IsA("ObjectValue") then
				value = hitTarget.Value
				endPos = hitTarget:GetAttribute("EndPos")
			elseif hitTarget.Name == "MissExplode" and hitTarget:IsA("Vector3Value") then
				value2 = hitTarget.Value
			end
		end

		local childAddedConnection = proxy.ChildAdded:Connect(readHit)
		local hitTarget = proxy:FindFirstChild("HitTarget")

		if hitTarget then
			readHit(hitTarget) -- equivalent call inferred; original call site unknown
		end

		while proxy.Parent and not (value or value2) do
			jetpack2.PrimaryPart.CFrame = proxy.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * cframe
			task.wait()
		end

		if childAddedConnection then
			childAddedConnection:Disconnect()
		end

		if value and value.Parent then
			local position = value.CFrame.Position
			local v2 = endPos or position + createVector(0, 75, 0)
			local random = Random.new(data.Seed or 0)
			local number = random:NextNumber(2.5, 4.5)
			local number2 = random:NextNumber(8, 14)
			local number3 = random:NextNumber(0, 6.283185307179586)
			local v3 = random:NextInteger(0, 1) == 0 and 1 or -1
			local number4 = random:NextNumber(5, 10)
			local number5 = random:NextNumber(4, 8)
			local number6 = random:NextNumber(4, 8)
			local number7 = random:NextNumber(4, 8)
			local number8 = random:NextNumber(0, 6.283)
			local number9 = random:NextNumber(0, 6.283)
			local number10 = random:NextNumber(0, 6.283)

			local function pathPos(p)
				local v4 = math.sin(3.141592653589793 * p)
				local lerped = position:Lerp(v2, p)
				local v5 = number3 + v3 * p * number * 3.141592653589793 * 2
				local v6 = (createVector(1, 0, 0) * math.cos(v5) + createVector(0, 0, 1) * math.sin(v5)) * (number2 * v4)
				local v7 = Vector3.new(
					math.sin(p * number5 + number8),
					math.sin(p * number6 + number9) * 0.6,
					(math.sin(p * number7 + number10))
				) * (number4 * v4)
				return lerped + v6 + v7
			end

			local lastTime = tick()
			local v4 = Util.Sound:Play("Magnet_Untransformed_F_Tap_JetpackCapture_SpinUpward_Loop_01", value)

			while tick() - lastTime < flyUpDur and value.Parent do
				local v5 = tick() - lastTime
				local v6 = pathPos(math.min(v5 / flyUpDur, 1))
				local cFrame2 = CFrame.new(v6) * CFrame.Angles(
					math.sin(v5 * 13 + number8) * 0.7,
					math.sin(v5 * 7 + number9) * 1.2,
					math.sin(v5 * 17 + number10) * 0.8
				)
				value.CFrame = cFrame2
				jetpack2.PrimaryPart.CFrame = cFrame2 * CFrame.new(0, 0, 1.75) * CFrame.Angles(
					v5 * 11 * v3,
					v5 * 16,
					v5 * 23 * v3
				)
				task.wait()
			end

			if v4 then
				Util.Sound:FadeOut(v4, 0.2)
			end

			if value.Parent then
				value.CFrame = CFrame.new(v2)
				jetpack2.PrimaryPart.CFrame = CFrame.new(v2) * CFrame.new(0, 0, 1.75)
			end

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

			scrapModelA:ScaleTo(1)
			local children = scrapModelA:GetChildren()
			local clone3 = F.Phase3.Explosion:Clone()
			clone3.CFrame = CFrame.new(endPos)
			Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")

			if (workspace.CurrentCamera.CFrame.p - endPos).Magnitude < 150 then
				Util.CameraShaker:ShakeOnce(10, 8, 0.2, 0.6)
			end

			Util.Sound:Play("Magnet_Untransformed_F_Tap_JetpackCapture_AirExplosion_02", endPos)

			for _, emitter in pairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 1.35, lifetime.Max * 1.35)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
			local clone4 = F.Phase3.StarImpact:Clone()
			clone4.CFrame = CFrame.new(endPos)
			Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")

			for _, emitter in pairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 1.15, lifetime.Max * 1.15)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
				emitter.Enabled = true
				local v5 = emitter
				task.delay(0.75, function()
					v5.Enabled = false
				end)
			end

			task.delay(1.5, function()
				DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown
			end)
			local cFrame = clone3.CFrame
			task.spawn(function()
				for _ = 1, 10 do
					task.spawn(function()
						local clone5 = children[math.random(1, #children)]:Clone()
						local v5 = cFrame.Position + Vector3.new(
							math.random(-5, 5),
							math.random(-5, 5),
							math.random(-5, 5)
						)
						clone5.CFrame = CFrame.new(v5)
						clone5.Anchored = false
						clone5.CanCollide = false
						clone5.Size = clone5.Size * math.random(10, 15) / 10
						Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
						task.delay(0.15, function()
							clone5.CanCollide = true
						end)
						clone5.AssemblyLinearVelocity = (v5 - cFrame.Position).Unit * (math.random(120, 220) / 3) + Vector3.new(
							math.random(-25, 25),
							math.random(30, 80),
							math.random(-25, 25)
						)
						clone5.AssemblyAngularVelocity = Vector3.new(
							math.random(-20, 20),
							math.random(-20, 20),
							math.random(-20, 20)
						)
						task.delay(1 + math.random() * 0.5, function()
							TweenService:Create(clone5, TweenInfo.new(0.5), {
								Size = createVector(0, 0, 0)
							}):Play()
							task.wait(0.5)
							clone5:Destroy()
						end)
					end)
				end
			end)
			task.spawn(function()
				for i = 1, 10 do
					local v5 = i
					task.spawn(function()
						local v6 = math.random(50, 70)
						local clone5 = script.Part:Clone()
						local cFrame2 = CFrame.new(cFrame.Position) * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)
						clone5.CFrame = cFrame2
						Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
						clone5.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, v6).Position
						local shafiBolt = ShafiBolt(
							clone5.Attach0,
							clone5.Attach1,
							math.random(8, 12) * 1.25,
							0.75,
							folder
						)
						shafiBolt.CurveSize0 = math.random(-5, 5)
						shafiBolt.CurveSize1 = math.random(-5, 5)
						shafiBolt.Frequency = math.random(5, 10) * 2
						shafiBolt.MaxRadius = 12
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						local player2 = data.Player
						local color = Color3.fromRGB(28, 28, 255)

						if typeof(player2) == "Instance" and player2.Parent then
							color = WrapColor3Constructor(color, player2, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v5 % 2 == 0 then
							local player3 = data.Player
							local color2 = Color3.fromRGB(255, 64, 150)

							if typeof(player3) == "Instance" and player3.Parent then
								color2 = WrapColor3Constructor(color2, player3, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color2
							shafiBolt.Thickness = 1
						end

						task.spawn(function()
							task.wait(0.115 + math.random() * 0.07)
							shafiBolt:Destroy()
						end)
					end)
				end
			end)
			jetpack2:Destroy()
		elseif value2 then
			for _, emitter in pairs(jetpack2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

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

			scrapModelA:ScaleTo(1)
			local children = scrapModelA:GetChildren()
			local clone3 = F.Phase3.Explosion:Clone()
			clone3.CFrame = CFrame.new(value2)
			Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")

			if (workspace.CurrentCamera.CFrame.p - value2).Magnitude < 150 then
				Util.CameraShaker:ShakeOnce(10, 8, 0.2, 0.6)
			end

			Util.Sound:Play("Magnet_Untransformed_F_Tap_JetpackCapture_AirExplosion_02", value2)

			for _, emitter in pairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 1.35, lifetime.Max * 1.35)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
			local clone4 = F.Phase3.StarImpact:Clone()
			clone4.CFrame = CFrame.new(value2)
			Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")

			for _, emitter in pairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 1.15, lifetime.Max * 1.15)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
				emitter.Enabled = true
				local v2 = emitter
				task.delay(0.75, function()
					v2.Enabled = false
				end)
			end

			task.delay(1.5, function()
				DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown
			end)
			local cFrame = clone3.CFrame
			task.spawn(function()
				for _ = 1, 10 do
					task.spawn(function()
						local clone5 = children[math.random(1, #children)]:Clone()
						local v2 = cFrame.Position + Vector3.new(
							math.random(-5, 5),
							math.random(-5, 5),
							math.random(-5, 5)
						)
						clone5.CFrame = CFrame.new(v2)
						clone5.Anchored = false
						clone5.CanCollide = false
						clone5.Size = clone5.Size * math.random(10, 15) / 10
						Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
						task.delay(0.15, function()
							clone5.CanCollide = true
						end)
						clone5.AssemblyLinearVelocity = (v2 - cFrame.Position).Unit * (math.random(120, 220) / 3) + Vector3.new(
							math.random(-25, 25),
							math.random(30, 80),
							math.random(-25, 25)
						)
						clone5.AssemblyAngularVelocity = Vector3.new(
							math.random(-20, 20),
							math.random(-20, 20),
							math.random(-20, 20)
						)
						task.delay(1 + math.random() * 0.5, function()
							TweenService:Create(clone5, TweenInfo.new(0.5), {
								Size = createVector(0, 0, 0)
							}):Play()
							task.wait(0.5)
							clone5:Destroy()
						end)
					end)
				end
			end)
			task.spawn(function()
				for i = 1, 10 do
					local v2 = i
					task.spawn(function()
						local v3 = math.random(50, 70)
						local clone5 = script.Part:Clone()
						local cFrame2 = CFrame.new(cFrame.Position) * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)
						clone5.CFrame = cFrame2
						Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
						clone5.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, v3).Position
						local shafiBolt = ShafiBolt(
							clone5.Attach0,
							clone5.Attach1,
							math.random(8, 12) * 1.25,
							0.75,
							folder
						)
						shafiBolt.CurveSize0 = math.random(-5, 5)
						shafiBolt.CurveSize1 = math.random(-5, 5)
						shafiBolt.Frequency = math.random(5, 10) * 2
						shafiBolt.MaxRadius = 12
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						local player2 = data.Player
						local color = Color3.fromRGB(28, 28, 255)

						if typeof(player2) == "Instance" and player2.Parent then
							color = WrapColor3Constructor(color, player2, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v2 % 2 == 0 then
							local player3 = data.Player
							local color2 = Color3.fromRGB(255, 64, 150)

							if typeof(player3) == "Instance" and player3.Parent then
								color2 = WrapColor3Constructor(color2, player3, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color2
							shafiBolt.Thickness = 1
						end

						task.spawn(function()
							task.wait(0.115 + math.random() * 0.07)
							shafiBolt:Destroy()
						end)
					end)
				end
			end)
			jetpack2:Destroy()
		else
			for _, emitter in pairs(jetpack2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local clone3 = F.Phase1.StartImpact:Clone()
			clone3.CFrame = jetpack2.PrimaryPart.CFrame
			Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
			DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Util.Sound:Play("Magnet_Untransformed_F_JetpackDisassemble_01", clone3.Position)
			jetpack2:Destroy()
		end

		Util.Debris:AddItem(folder, 5)
	end
end