local createVector = vector.create
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local F = FX:WaitForChild("Dragon2").F
local Util = require(game.ReplicatedStorage.Util)
local Effect = require(game.ReplicatedStorage.Effect)
local _WorldOrigin = workspace._WorldOrigin
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local rock2 = Util.Rock2

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

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).Magnitude <= p2 then
			callback()
		end
	end
end

local function AlignCFrame(data, p)
	local v = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p2, unit2, v, unit3)
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

local function TornadoSlash(folder, data, player)
	local multiplier = data.Multiplier
	local multiplier2 = data.Multiplier2
	local mutliplier2Time = data.Mutliplier2Time
	local beamOutTime = data.BeamOutTime
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local slashType = data.SlashType
	local slashCFrame = data.SlashCFrame
	local slashSpeed = data.SlashSpeed
	local slashSpeed2 = data.SlashSpeed2
	local spinIterations = data.SpinIterations
	local clone = slashType:Clone()
	clone.CFrame = slashCFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")

	for _, descendant in pairs(clone:GetDescendants()) do
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

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.Enabled = true
			local v = descendant
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						CurveSize0 = v.CurveSize0 * multiplier2,
						CurveSize1 = v.CurveSize1 * multiplier2,
						Width0 = v.Width0 * multiplier2,
						Width1 = v.Width1 * multiplier2
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				tween:Play()
			end)
		elseif descendant:IsA("Attachment") then
			TweenService:Create(
				descendant,
				TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(
						descendant.Position.X * multiplier2,
						descendant.Position.Y * multiplier2,
						descendant.Position.Z * multiplier2
					)
				}
			):Play()
		end
	end

	for _ = 1, spinIterations do
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(slashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * slashAngle
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v = beam
		task.spawn(function()
			local tween = TweenService:Create(
				v,
				TweenInfo.new(beamOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = 0
				}
			)
			tween:Play()
			tween.Completed:Wait()
			v:Destroy()
		end)
	end

	TweenService:Create(clone, TweenInfo.new(slashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * slashAngle2
	}):Play()
end

local function Dash(root, folder, p, player)
	local cFrame = root.CFrame
	local clone = F.Phase1.StartImpact:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

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

	local clone2 = F.Phase1.Dash:Clone()
	clone2.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
	clone2.Weld.Part0 = root
	local emittersByEmitter = {}

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emittersByEmitter[emitter] = emitter
	end

	task.spawn(function()
		local lastTime = tick()

		while true do
			for _, v in pairs(emittersByEmitter) do
				v:Emit(1)
			end

			task.wait(0.05)
			local v = tick() - lastTime

			if not (p * 0.95 <= v or root:GetAttribute("StopDragonFDash") == true) then
				continue
			end

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			clone2.Weld.Enabled = false
			clone2.Anchored = true
			break
		end
	end)
	return clone2
end

local function mockRootPart(_, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Size = createVector(2, 2, 1)
	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	Util.Debris:AddItem(part, 7)
	return part
end

local function ScreenHitEffect(folder, duration, player)
	local currentCamera = workspace.CurrentCamera
	local clone = F.Extra.CameraFocus:Clone()
	clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3)
	Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3)
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = false
		local v = emitter
		task.spawn(function()
			for i = 1, 5 do
				v:Emit(i % 2 == 0 and 1 or 2)
				task.wait(0.05)
			end
		end)
	end

	task.wait(duration)
	task.spawn(function()
		task.wait(0.5)
		renderSteppedConnection:Disconnect()
		clone:Destroy()
	end)
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, _WorldOrigin }
return function(data)
	local root = data.Root
	local player = data.Player

	if (workspace.CurrentCamera.CFrame.p - root.Position).Magnitude > 900 then
		return
	end

	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DragonFruitVFXColor")
	Util.Debris:AddItem(folder, 15)
	local cFrame = root.CFrame

	if data.Stage == -1 then
		ScreenHitEffect(folder, 0.5, player)
	elseif data.Stage == 0 then
		if root == game.Players.LocalPlayer.Character.HumanoidRootPart then
			task.spawn(function()
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						FieldOfView = 60
					}
				):Play()
			end)
		end

		task.spawn(function()
			local clone = F.Phase0.StartImpact:Clone()
			clone.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

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

			task.wait(0.1)

			if root.Parent:FindFirstChild("DragonHybrid") then
				local clone2 = F.Phase0.StartImpactH:Clone()
				clone2.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end
		end)
	elseif data.Stage == 1 then
		local lastTime = tick()

		while tick() - lastTime < 0.4 and not ((root.Position - data.Look.Position).Magnitude > 1) do
			task.wait()
		end

		Util.Sound:Play("BF_V3_Untransformed_F_Takeoff_04", root)
		local position = data.Look.Position
		local ray, v, v2 = Util.Ray(
			position,
			CFrame.new(position).UpVector.Unit * -15,
			{ workspace.Characters, workspace.Enemies }
		)

		if ray then
			local clone = F.Jump:Clone()
			Util.Debris:AddItem(clone, 3)
			clone.CFrame = CFrame.new(v + v2 * 0.1, v + v2 * 10) * CFrame.Angles(-1.5707963267948966, 0, 0)
			Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player, "DragonFruitVFXColor")

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone2 = F.Explosion:Clone()
			Util.Debris:AddItem(clone2, 3)
			clone2.CFrame = CFrame.new(v + v2 * 0.1, v + v2 * 10) * CFrame.Angles(-1.5707963267948966, 0, 0)
			Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player, "DragonFruitVFXColor")
			task.delay(0.6, function()
				clone2.FireRise.Enabled = false
			end)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local v3 = v + createVector(0, 1, 0)

			for i = 1, 10 do
				local v5 = CFrame.new(v3, v3 + v2 * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.rad(i * 36),
					0
				) * CFrame.new(0, 0, -14)
				local ray2, v6, v7 = Util.Ray(
					v5.Position,
					v5.upVector.Unit * -30,
					{ workspace.Characters, workspace.Enemies },
					false
				)

				if not ray2 then
					continue
				end

				if math.random(1, 100) <= 33 then
					local clone3 = F.ExplosionTrail:Clone()
					clone3.Color = ray2.Color:Lerp(
						Util.WrapColor3Constructor(Color3.new(), player, "DragonFruitVFXColor"),
						0.6666666666666666
					)
					clone3.Material = ray2.Material
					clone3.Size = Vector3.new(math.random(3, 4), 2, math.random(3, 4)) * (math.random() + 1)
					clone3.Velocity = (v5.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v5.lookVector * math.random(
						10,
						20
					)) * 0.75 + (data.Look.LookVector + Random.new():NextUnitVector() * 0.2) * math.random(30, 60) * 1.5
					clone3.RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
					clone3.Position = v5.Position:Lerp(v6, 0.5) + createVector(0, 1, 0) * clone3.Size.Magnitude * 1.333

					if data.Hybrid then
						clone3.Velocity *= 1.1
						clone3.Zaps1.Enabled = true
						local v8 = clone3
						task.delay((1 + math.random() * 0.75) * 0.75 * 0.666, function()
							v8.Zaps1.Enabled = false
						end)
					end

					Util.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")
					clone3.Color = ray2.Color:Lerp(Color3.new(), 0.6666666666666666)
					rocks:ApplyCollision(clone3, nil, true)
					local folder2 = clone3
					task.spawn(function()
						task.wait((1 + math.random() * 0.75) * 0.75)

						for i2, emitter in pairs(folder2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						TweenService:Create(folder2, TweenInfo.new(0.5), {
							Size = createVector(0.01, 0.01, 0.01)
						}):Play()
						task.wait(0.5)
						folder2.Transparency = 1
						folder2.Anchored = true
					end)
				else
					rock2.new({
						FadeIn = { 0.05, 0.1 },
						Lifetime = 1.1 * math.random(10, 15) / 10,
						FadeOut = { 0.25, 0.35 },
						Size = Vector3.new(math.random(3, 4), 2, math.random(3, 4)),
						Scale = { 0.75, 1.5 }
					}):Spawn(CFrame.new(v6, v6 + v7) * CFrame.Angles(-1.5707963267948966, 0, 0), 0.6666666666666666)
				end
			end
		end

		if player == game.Players.LocalPlayer then
			task.spawn(function()
				local currentCamera = workspace.CurrentCamera
				TweenService:Create(
					currentCamera,
					TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						FieldOfView = 100
					}
				):Play()
				local clone = F.Phase1.CameraFocus:Clone()
				Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
				local renderSteppedConnection = RunService.RenderStepped:Connect(function()
					clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3)
				end)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.wait(0.35)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				TweenService:Create(currentCamera, TweenInfo.new(0.5), {
					FieldOfView = 70
				}):Play()
				task.wait(0.5)
				renderSteppedConnection:Disconnect()
				clone:Destroy()
			end)
		end

		Dash(root, folder, 0.2, player)
		task.spawn(function()
			local slashCFrame = cFrame * CFrame.new(0, 0, -5)
			TornadoSlash(folder, {
				Multiplier = 0.5,
				Multiplier2 = 2.5,
				Mutliplier2Time = 0.2,
				BeamOutTime = 0.2,
				SlashAngle = CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, 2.6179938779914944),
				SlashAngle2 = CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, 2.6179938779914944),
				SlashType = F.Phase1.BeamSlash,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.05,
				SlashSpeed2 = 0.5,
				SpinIterations = 1
			}, player)
		end)
		task.spawn(function()
			local slashCFrame = cFrame * CFrame.new(0, 0, -10)
			TornadoSlash(folder, {
				Multiplier = 0.25,
				Multiplier2 = 7,
				Mutliplier2Time = 0.15,
				BeamOutTime = 0.15,
				SlashAngle = CFrame.new(0, 0, 1) * CFrame.Angles(0, 0, 2.6179938779914944),
				SlashAngle2 = CFrame.new(0, 0, 2.5) * CFrame.Angles(0, 0, 0.8726646259971648),
				SlashType = F.Phase1.BeamSlash,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.1,
				SlashSpeed2 = 0.35,
				SpinIterations = 1
			}, player)
		end)

		for i = 1, 3 do
			local v3 = nil
			local v4 = nil
			local v5 = nil
			local v6 = nil
			local v7 = nil
			local v8 = nil
			local v9 = nil
			local width = nil
			local width2 = nil
			local cFrame2 = nil
			local v13 = nil
			local clone = F.Phase1.RingBeam:Clone()
			clone.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")

			if i == 1 then
				cFrame2 = cFrame * CFrame.new(0, 0, 0)
				clone.CFrame = cFrame * CFrame.new(0, 0, -25)
				v3 = 0.75
				v13 = 0.5
				width = 25
				v6 = 0.05
				v4 = 2.5
				width2 = 15
				v9 = 0.2
				v7 = 0.25
				v5 = 1.15
				v8 = 0.25
			elseif i == 2 then
				cFrame2 = cFrame * CFrame.new(0, 0, -20)
				clone.CFrame = cFrame * CFrame.new(0, 0, -50)
				v3 = 0.6
				v13 = 0.15
				width = 25
				v6 = 0.1
				v4 = 2.75
				width2 = 10
				v9 = 0.1
				v7 = 0.15
				v5 = 1.15
				v8 = 0.15
			elseif i == 3 then
				cFrame2 = cFrame * CFrame.new(0, 0, -40)
				clone.CFrame = cFrame * CFrame.new(0, 0, -70)
				v3 = 0.25
				v13 = 0
				width = 15
				v6 = 0.15
				v4 = 5.15
				width2 = 7
				v9 = 0.15
				v7 = 0.1
				v5 = 1.15
				v8 = 0.1
			end

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= v3
					descendant.CurveSize1 *= v3
					descendant.Transparency = NumberSequence.new(v13, v13)
					descendant.Width0 = width
					descendant.Width1 = width
					local v14 = descendant
					task.spawn(function()
						TweenService:Create(v14, TweenInfo.new(v6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							CurveSize0 = v14.CurveSize0 * v4,
							CurveSize1 = v14.CurveSize1 * v4,
							Width0 = width2,
							Width1 = width2
						}):Play()
						task.wait(v9)
						TweenService:Create(v14, TweenInfo.new(v7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
							CurveSize0 = v14.CurveSize0 * v5,
							CurveSize1 = v14.CurveSize1 * v5,
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * v3,
						descendant.Position.Y * v3,
						descendant.Position.Z * v3
					)
					local v14 = descendant
					task.spawn(function()
						TweenService:Create(v14, TweenInfo.new(v6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Position = Vector3.new(v14.Position.X * v4, v14.Position.Y * v4, v14.Position.Z * v4)
						}):Play()
						task.wait(v9)
						TweenService:Create(v14, TweenInfo.new(v7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
							Position = Vector3.new(v14.Position.X * v5, v14.Position.Y * v5, v14.Position.Z * v5)
						}):Play()
					end)
				end
			end

			TweenService:Create(clone, TweenInfo.new(v8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				CFrame = cFrame2
			}):Play()
		end
	else
		local iterations = data.Iterations or 10
		local part = Instance.new("Part")
		part.Name = "Mock" .. part.Name
		part.Size = createVector(2, 2, 1)
		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 1
		part.CFrame = cFrame
		part.Parent = _WorldOrigin
		Util.Debris:AddItem(part, 7)
		part.CFrame = cFrame * CFrame.new(0, 0, 5)
		local clone = F.AlignMover:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
		local alignOrientation = clone.AlignOrientation
		alignOrientation.Enabled = true
		alignOrientation.CFrame = part.CFrame
		local alignPosition = clone.AlignPosition
		alignPosition.Enabled = true
		alignPosition.Responsiveness = 125
		alignPosition.Position = part.Position
		clone.Weld.Part0 = part
		clone.Weld.Part1 = clone
		local play = Util.Sound:Play("Untransformed_Dragon_F_Punches_01_v7", root)
		play.TimePosition = 0.4
		local clone2 = F.Phase2.DashImpact:Clone()
		Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
		local clone3 = F.Phase2.HitImpact:Clone()

		if not data.Hybrid then
			clone3.Attachment3:Destroy()
		end

		Util.SetParentOverrideWithColor(clone3, folder, player, "DragonFruitVFXColor")

		local function Curve(position, p, p2)
			local position2 = part.Position
			local magnitude = (position2 - position).Magnitude
			alignOrientation.CFrame = CFrame.new(position2, position)
			local v = (position2 - position) / 2
			local cframe = CFrame.new(CFrame.new(position2) * (v / -1.5))
			local cframe2 = CFrame.new(CFrame.new(position) * (v / 1.5))
			local v2 = cframe * CFrame.new(math.random(-p, p), math.random(0, p / 2), math.random(-p, p)).Position
			local v3 = cframe2 * CFrame.new(math.random(-p, p), math.random(0, p / 2), 0).Position
			local lastTime = tick()
			local v4 = magnitude / p2 / 60

			while tick() - lastTime < v4 and data.Caught and data.Caught:IsDescendantOf(workspace) do
				local v5 = (tick() - lastTime) / v4
				local v6 = cubicBezier(v5, position2, v2, v3, position)
				alignPosition.Position = alignOrientation.CFrame:Lerp(CFrame.new(v6, position), v5).Position
				RunService.Heartbeat:Wait()
			end
		end

		local v = true
		local clone4

		if root == game.Players.LocalPlayer.Character.HumanoidRootPart then
			clone4 = F.ScreenColorDX:Clone()
			Util.SetParentOverrideWithColor(clone4, game.Lighting, player, "DragonFruitVFXColor")
			TweenService:Create(clone4, TweenInfo.new(0.6), {
				Brightness = -0.015,
				Contrast = 0.15,
				Saturation = 0.15,
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(231, 185, 159),
					player,
					"DragonFruitVFXColor"
				)
			}):Play()
		else
			clone4 = nil
		end

		task.spawn(function()
			local clone5 = F.Extra.ImpactLine2:Clone()
			Util.SetParentOverrideWithColor(clone5, folder, player, "DragonFruitVFXColor")
			local clone6 = F.Extra.HitImpact:Clone()
			Util.SetParentOverrideWithColor(clone6, folder, player, "DragonFruitVFXColor")
			clone6.CFrame = root.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
			clone6.WeldConstraint.Part1 = root
			clone6.Anchored = false

			for _, emitter in pairs(clone6:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.LockedToPart = true
				end
			end

			clone6.Particle_4.LockedToPart = false
			clone6.Particle_5.LockedToPart = false
			clone6.Particle_6.LockedToPart = false

			while true do
				local clone7 = F.Extra.ImpactLine:Clone()
				Util.SetParentOverrideWithColor(clone7, folder, player, "DragonFruitVFXColor")
				clone7.CFrame = root.CFrame * CFrame.new(0, 0, -1.1) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
				clone7.CFrame *= CFrame.new(0, 0, 65.71428571428571)
				clone7.WeldConstraint.Part1 = root
				clone7.Anchored = false

				for _, emitter in pairs(clone7:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter:Emit(emitter:GetAttribute("EmitCount") / math.random(1, 2))
					emitter.LockedToPart = true
				end

				task.spawn(function()
					for _ = 1, math.random(1, 2) do
						clone5.Size = Vector3.new(3, 10 + math.random(0, 5), 3)
						clone5.CFrame = root.CFrame * CFrame.new(0, 0, -30) * CFrame.Angles(
							math.rad(math.random(-180, 180) / 2.5),
							math.rad(math.random(-180, 180) / 2),
							(math.rad((math.random(-180, 180))))
						)
						clone5.CFrame *= CFrame.new(0, 0, -math.random(30, 60))
						clone5.Orientation = Vector3.new(0, clone5.Orientation.Y, 0)

						for _, emitter in pairs(clone5:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") and emitter.Parent ~= clone5.Attachment then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						local v2 = math.random(1, #clone5.Attachment:GetChildren())
						local v3 = clone5.Attachment["Particle_" .. v2]
						v3:Emit(v3:GetAttribute("EmitCount"))
						task.wait(0.015)
					end
				end)
				clone6.WeldConstraint.Enabled = false
				clone6.CFrame = root.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				clone6.WeldConstraint.Enabled = true

				for _, emitter in pairs(clone6:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") / math.random(1, 2))
					end
				end

				task.wait(0.05)

				if v == true then
					continue
				end

				clone6.WeldConstraint.Enabled = false
				clone6.CFrame = root.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				clone6.Anchored = true
				task.wait(0.06666666666666667)

				for _, emitter in pairs(clone6:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.LockedToPart = false
					emitter:Emit(emitter:GetAttribute("EmitCount") * 1.5)
				end

				break
			end
		end)
		local v2 = false

		for _, victimPlayer in pairs(data.VictimPlayers) do
			if game.Players.LocalPlayer ~= victimPlayer then
				continue
			end

			v2 = true
			break
		end

		if player == game.Players.LocalPlayer or v2 then
			task.spawn(function()
				ScreenHitEffect(folder, 0.5, player)
			end)
		end

		root:SetAttribute("StopDragonFDash", true)
		task.delay(0.5, function()
			root:SetAttribute("StopDragonFDash", nil)
		end)

		for _ = 1, iterations do
			for i = 1, 3 do
				if i == 1 then
					local position = part.Position
					Curve(
						CFrame.new(root.CFrame * createVector(0, 0, -40), position) * CFrame.Angles(
							0,
							math.rad((math.random(-90, 90))),
							0
						) * CFrame.new(0, 0, 100).Position,
						100,
						17
					)
				elseif i == 2 then
					local position = part.Position
					Curve(
						CFrame.new(root.CFrame * createVector(0, 0, -40), position) * CFrame.Angles(
							0,
							math.rad((math.random(-90, 90))),
							0
						) * CFrame.new(0, 0, 50).Position,
						150,
						17
					)
				elseif i == 3 then
					local position = part.Position
					local position2 = root.CFrame * createVector(0, 0, -40)
					local _ = (position - position2).Magnitude
					Curve(position2, 10, 10)
					alignPosition.Position = position2
				end
			end

			if data.Caught and data.Caught:IsDescendantOf(workspace) then
				task.wait(0.015)
			else
				break
			end
		end

		if clone4 then
			local tween = TweenService:Create(clone4, TweenInfo.new(0.1), {
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 255, 255),
					player,
					"DragonFruitVFXColor"
				),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			})
			tween:Play()
			task.spawn(function()
				tween.Completed:Wait()
				clone4:Destroy()
			end)
		end

		if root == game.Players.LocalPlayer.Character.HumanoidRootPart then
			Effect.new("ColorCorrection"):replicate({
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 255, 255),
					player,
					"DragonFruitVFXColor"
				),
				Brightness = -1,
				Saturation = -1,
				Contrast = 6,
				FadeIn = 0,
				FadeOut = 0.22000000000000003,
				Lifetime = 0.11000000000000001
			})
		end

		v = false
		task.wait(0.1)
		alignOrientation.Enabled = false
		alignPosition.Enabled = false
		clone:Destroy()
	end
end