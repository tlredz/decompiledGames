local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local debris = Util.Debris
local _ = Util.Sound
local _ = Util.PartCache
local cameraShaker = Util.CameraShaker
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local xTransformed = FX:WaitForChild("Kitsune").XTransformed
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://15534949470"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://15534951522"
local animation3 = Instance.new("Animation")
animation3.AnimationId = "rbxassetid://15534953905"
local animation_2 = Instance.new("Animation")
animation_2.AnimationId = "rbxassetid://15534955782"

-- equivalent calls inferred from this helper; original call sites unknown
local function projectAontoB(vector2, p)
	local unit = p.Unit
	return vector2:Dot(unit) * unit
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closestPointOnLine(position, position2, p)
	return position2 + projectAontoB(position - position2, p)
end

local function projectOntoPlaneY(p, data, data2)
	local X = data2.X
	local Y = data2.Y
	local Z = data2.Z
	local X2 = data.X
	local Y2 = data.Y
	local Z2 = data.Z
	local v = -(X * X2 + Y * Y2 + Z * Z2)
	local X3 = p.X
	local Z3 = p.Z
	return (Vector3.new(X3, -(X * X3 + Z * Z3 + v) / Y, Z3))
end

local function DeleteImpactAfterDuration(folder)
	local v = 0

	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local max = emitter.Lifetime.Max
		v = math.max(v, max)
	end

	task.spawn(function()
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

local function ExplosionFlameRocks(p, p2, p3)
	for _ = 1, 10 do
		local clone = xTransformed.Phase4.ExplosionTrail:Clone()
		debris:AddItem(clone, 10)
		clone.Position = p.Position + Vector3.new(
			math.random(-25, 25) * 2,
			math.random(1, 15),
			math.random(-25, 25) * 2
		)
		Util.SetParentOverrideWithColor(clone, p2, p3, "KitsuneFruitVFXColor")
		clone.Anchored = false
		clone.CanCollide = true
		rocks:ApplyCollision(clone, nil, true)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
		bodyVelocity.P = 1600
		Util.SetParentOverrideWithColor(bodyVelocity, clone, p3, "KitsuneFruitVFXColor")
		bodyVelocity.Velocity = CFrame.new(
			clone.Position,
			(CFrame.new(clone.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
				0,
				0,
				-30
			)).Position + Vector3.new(math.random(-10, 10) / 5, math.random(80, 250), math.random(-10, 10) / 5)
		).LookVector * math.random(50, 225) * 1.15
		debris:AddItem(bodyVelocity, 0.1)

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
			elseif effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		local folder = clone
		coroutine.wrap(function()
			task.wait(1)
			folder.Particle_6.Enabled = false
			task.wait(0.25)

			for i, effect in pairs(folder:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				elseif effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			debris:AddItem(folder, 5)
		end)()
	end
end

local function GroundRocks(cframe, _WorldOrigin2, _, p, player)
	task.spawn(function()
		ExplosionFlameRocks(cframe, _WorldOrigin2, player)
	end)

	for _ = 1, 15 do
		task.spawn(function()
			local clone = xTransformed.Phase3.Rock:Clone()
			debris:AddItem(clone, 10)
			clone.Position = cframe.Position + Vector3.new(
				math.random(-25, 25) * 2,
				math.random(1, 15),
				math.random(-25, 25) * 2
			)
			clone.Size = Vector3.new(math.random(3, 5) * 2.5, math.random(3, 5), math.random(3, 5) * 2.5)
			clone.Material = p.Material
			clone.Color = p.Color
			local color = clone.Color
			Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "KitsuneFruitVFXColor")
			clone.Color = color
			task.spawn(function()
				task.wait(5.25 + math.random(10, 50) / 100)
				Util.Sound:Play("V Attacks- Rock flames ", clone)
				local clone2 = xTransformed.Phase3.RockBurn:Clone()
				debris:AddItem(clone2, 5)
				clone2.Position = clone.Position
				clone2.Size = clone.Size
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin2, player, "KitsuneFruitVFXColor")

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				TweenService:Create(
					clone,
					TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				task.wait(0.4)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				clone.Transparency = 1
			end)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			bodyVelocity.P = 3000
			Util.SetParentOverrideWithColor(bodyVelocity, clone, player, "KitsuneFruitVFXColor")
			bodyVelocity.Velocity = CFrame.new(
				clone.Position,
				(CFrame.new(clone.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
					0,
					0,
					-30
				)).Position + Vector3.new(math.random(-10, 10) / 5, math.random(80, 250), math.random(-10, 10) / 5)
			).LookVector * math.random(70, 100) * 2.25
			debris:AddItem(bodyVelocity, 0.175)
			clone.Attachment0.Orientation = createVector(0, 0, 0)
			rocks:ApplyCollision(clone, nil, true)
			local v = math.random(-100, 100)
			local v2 = math.random(-100, 100)
			local v3 = math.random(-100, 100)
			local v4 = v / 10
			local v5 = v2 / 10
			local v6 = v3 / 10
			task.spawn(function()
				task.wait(0.05)
				local particle_3

				if math.random(1, 2) == 1 then
					clone.Particle_3.Enabled = true
					particle_3 = clone.Particle_3
				else
					clone.Particle_2.Enabled = true
					particle_3 = clone.Particle_2
				end

				for i = 1, 6 do
					v = math.clamp(v - v4, 0, 120)
					v2 = math.clamp(v2 - v5, 0, 120)
					v3 = math.clamp(v3 - v6, 0, 120)
					local tween = TweenService:Create(
						clone.Attachment0,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone.Attachment0.CFrame * CFrame.Angles(math.rad(v), math.rad(v2), (math.rad(v3)))
						}
					)
					tween:Play()
					tween.Completed:Wait()
					tween:Destroy()

					if i == 6 then
						for _, emitter in pairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					elseif i == 4 then
						particle_3.Enabled = false
					end
				end

				clone.AlignOrientation:Destroy()
			end)
			debris:AddItem(clone, 10)
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RockCrater(_, position, p, p2, data, p3)
	task.spawn(function()
		local radius = data.Radius
		local size = data.Size
		local duration = data.Duration
		local amount = data.Amount
		local currentRock = data.CurrentRock
		local cframe = AlignCFrame(CFrame.new(position), p) + p * 0.01
		local v = {}

		for _ = 1, amount do
			local v2 = size * math.random(15, 20) / 10
			local v3 = size * math.random(10, 20) / 10
			local v4 = size * math.random(10, 30) / 10
			local clone = currentRock:Clone()
			debris:AddItem(clone, duration * 2 + 5)
			clone.Size = Vector3.new(v2, v3, v4) + Vector3.new(
				0,
				math.random(-v3 / 3, v3 / 3),
				math.random(-v4 / 3, v4 / 3)
			)
			local color = clone.Color
			Util.SetParentOverrideWithColor(clone, p2, p3, "KitsuneFruitVFXColor")
			clone.Color = color
			table.insert(v, clone)
		end

		task.spawn(function()
			task.wait(duration * 2)

			for _, v2 in pairs(v) do
				v2:Destroy()
			end

			v = nil
		end)

		local function GetXAndYPosition(p4, p5)
			return math.cos(p4) * p5, math.sin(p4) * p5
		end

		for k, v2 in pairs(v) do
			local v3 = k * (6.283185307179586 / #v)
			local v4 = math.cos(v3) * radius
			local v5 = math.sin(v3) * radius
			local _ = cframe:ToObjectSpace(v2.CFrame).Y
			local position2 = (cframe * CFrame.new(v4, 0, v5)).Position
			v2.CFrame = CFrame.new(position2 + createVector(0, 0.1, 0), cframe.Position)

			if math.random(1, 5) < 2 then
				v2.CFrame = CFrame.new(v2.Position, cframe.Position) * CFrame.new(
					0,
					0,
					v2.Size.Z * math.random(5, 15) / 10
				)
			end

			local ray = Util.Ray
			local v6 = v2.Position + createVector(0, 1, 0)
			local v7 = { workspace.Characters, workspace.Enemies }
			local v8, v9, _ = ray(v6, createVector(-0, -20, -0), v7, false)

			if v8 then
				v2.Position = v9 + Vector3.new(0, -v2.Size.Y * math.random(5, 6) / 10, 0)
				v2.CFrame = CFrame.new(
					v2.Position,
					cframe.Position + Vector3.new(0, math.random(-55, -45) + v2.Size.Y / 2, 0)
				) * CFrame.Angles(0, 0, (math.rad((math.random(-5, 5)))))
				v2.Material = v8.Material
				v2.Color = v8.Color
			else
				v2:Destroy()
				v[v2] = nil
			end

			TweenService:Create(v2, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
				Position = v2.Position + Vector3.new(0, v2.Size.Y * math.random(3, 5) / 10, 0)
			}):Play()
			local v10 = v2
			local v11 = v2
			task.spawn(function()
				wait(duration)
				local tween = TweenService:Create(
					v10,
					TweenInfo.new(
						0.5,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.In,
						0,
						false,
						math.random(10, 35) / 100
					),
					{
						Position = v10.Position + Vector3.new(
							math.random(-1, 1),
							-v10.Size.Y * math.random(20, 25) / 10,
							math.random(-1, 1)
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v10:Destroy()
				v[v10] = nil
			end)
		end
	end)
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, position, p2, p3, position2)
	local v = position + (p2 - position) * p
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (position2 - p3) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TornadoSpin(cFrame, humanoidRootPart, cframe, fallDuration, player)
	task.spawn(function()
		local clone = xTransformed.Phase2.Tornado2:Clone()
		debris:AddItem(clone, fallDuration + 2)
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "KitsuneFruitVFXColor")
		clone.Weld.Part0 = humanoidRootPart
		clone.Weld.C1 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * cframe
		local clone2 = xTransformed.Phase2.RiseAura3:Clone()
		debris:AddItem(clone2, 10)
		clone2.CFrame = humanoidRootPart.CFrame
		clone2.Anchored = false
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "KitsuneFruitVFXColor")
		clone2.Weld.Part0 = humanoidRootPart
		clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * cframe

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		local descendantsByDescendant = {}
		local motor6DsByMotor6D = {}

		for _, motor6D in pairs(clone:GetChildren()) do
			local v = 1

			if not motor6D:IsA("Motor6D") then
				if motor6D.Name == "SpinA" then
					v = 2
				elseif motor6D.Name == "SpinB" then
					v = 1.75
				elseif motor6D.Name == "SpinC" then
					v = 1.25
				else
					v = v
				end
			end

			if motor6D:IsA("Motor6D") and motor6D.Name ~= "Weld" then
				motor6DsByMotor6D[motor6D] = motor6D
				motor6D.C0 = motor6D.Part0.CFrame:ToObjectSpace(motor6D.Part1.CFrame) * CFrame.Angles(
					0,
					math.rad((math.random(-90, 90))),
					0
				)
			end

			motor6D:SetAttribute("Tweening", false)

			for _, descendant in pairs(motor6D:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendantsByDescendant[descendant] = descendant
					descendant.CurveSize0 *= v
					descendant.CurveSize1 *= v
					descendant.Width0 *= v * 2
					descendant.Width1 *= v * 2
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * v,
						descendant.Position.Y * v,
						descendant.Position.Z * v
					)
				end
			end
		end

		local lastTime = tick()

		while tick() - lastTime <= fallDuration and humanoidRootPart and humanoidRootPart.Parent ~= nil do
			if lastTime == nil or tick() - lastTime >= 0.05 then
				for _, v in pairs(motor6DsByMotor6D) do
					if v:GetAttribute("Tweening") ~= false then
						continue
					end

					local v2 = v
					task.spawn(function()
						v2:SetAttribute("Tweening", true)
						local v3 = math.random(150, 170)
						local v4 = math.random(5, 15) / 200
						local tween = TweenService:Create(
							v2,
							TweenInfo.new(v4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								C0 = v2.Part0.CFrame:ToObjectSpace(v2.Part1.CFrame) * CFrame.Angles(0, math.rad(v3), 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v2:SetAttribute("Tweening", false)
					end)
				end
			end

			RunService.Heartbeat:Wait()
		end

		for _, v in pairs(descendantsByDescendant) do
			TweenService:Create(v, TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		task.delay(0.5, function()
			if clone then
				clone:Destroy()
			end

			if clone2 then
				clone2:Destroy()
			end
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FlameRise(p, p2, p3)
	task.spawn(function()
		local function TrailCurve(clone, cFrame, position, position2)
			local magnitude = (position - position2).Magnitude
			clone.CFrame = CFrame.new(position, position2)
			local v = (position - position2) / 2
			local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
			local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
			CFrame.new(math.random(-50, 50), math.random(-50, 50) / 2, math.random(-50, 50))
			CFrame.new(math.random(-50, 50), math.random(-50, 50) / 2, math.random(-50, 50))
			local cframe = CFrame.new(0, -30, -25)
			local cframe2 = CFrame.new(0, -10, -50)
			local v2 = CFrame.new(position3, position3 + cFrame.LookVector) * cframe.Position
			local v3 = CFrame.new(position4, position4 + cFrame.LookVector) * cframe2.Position
			local speed = clone:GetAttribute("Speed")
			local lastTime = tick()
			local v4 = magnitude / speed / 60
			local _ = (magnitude / speed + speed) / 60

			while tick() - lastTime < v4 do
				local v5 = (tick() - lastTime) / v4
				local v6 = cubicBezier(v5, position, v2, v3, position2)
				clone.CFrame = clone.CFrame:Lerp(CFrame.new(v6, position2), v5)
				RunService.Heartbeat:Wait()
			end
		end

		for _ = 1, 10 do
			task.spawn(function()
				local clone = xTransformed.Phase3.Trail:Clone()
				debris:AddItem(clone, 5)
				clone.CFrame = p * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
				clone.CFrame *= CFrame.new(0, 0, -5)
				clone.Trail.Lifetime = math.random(25, 30) / 100
				Util.SetParentOverrideWithColor(clone, p2, p3, "KitsuneFruitVFXColor")
				clone:SetAttribute("Speed", math.random(25, 35) / 10)
				local position = clone.Position
				local v = clone.CFrame * CFrame.new(0, math.random(35, 50), -math.random(25, 50) / 2).Position

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				TrailCurve(clone, clone.CFrame, position, v)

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end)
		end
	end)
end

local function FloorBurn(_, cframe, p, _, p2, p3, duration, p4)
	task.spawn(function()
		local function TrailCurve(instance, cframe2, position, position2)
			local magnitude = (position - position2).Magnitude
			instance.CFrame = CFrame.new(position, position2)
			local v = (position - position2) / 2
			local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
			local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
			CFrame.new(math.random(-50, 50), math.random(-50, 50) / 2, math.random(-50, 50))
			CFrame.new(math.random(-50, 50), math.random(-50, 50) / 2, math.random(-50, 50))
			local cframe3 = CFrame.new(0, 50, 0)
			local cframe4 = CFrame.new(0, 30, 0)
			local v2 = CFrame.new(position3, position3 + cframe2.LookVector) * cframe3.Position
			local v3 = CFrame.new(position4, position4 + cframe2.LookVector) * cframe4.Position
			local speed = instance:GetAttribute("Speed")
			local lastTime = tick()
			local v4 = magnitude / speed / 60
			local _ = (magnitude / speed + speed) / 60

			while tick() - lastTime < v4 do
				local v5 = (tick() - lastTime) / v4
				local v6 = cubicBezier(v5, position, v2, v3, position2)
				instance.CFrame = instance.CFrame:Lerp(CFrame.new(v6, position2), v5)
				RunService.Heartbeat:Wait()
			end
		end

		task.wait(0.15)
		local clone = xTransformed.Phase4.GroundFlame:Clone()
		debris:AddItem(clone, 5)
		local v = AlignCFrame(CFrame.new(p2, p2 + cframe.LookVector), p3) + p3 * 0.01
		local orientation, v2, v3 = cframe:ToOrientation()
		math.deg(orientation)
		math.deg(v2)
		math.deg(v3)
		clone:SetPrimaryPartCFrame(v)
		Util.SetParentOverrideWithColor(clone, p, p4, "KitsuneFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter.Parent.Name == "KitsuneLogo" then
				Util.EmitFix(emitter, 1)
			else
				local v4 = emitter
				task.spawn(function()
					v4.Enabled = true
					task.wait(duration)
					v4.Enabled = false
				end)
			end
		end

		for _, child in pairs(clone:GetChildren()) do
			if child == clone.PrimaryPart then
				continue
			end

			local ray = Util.Ray
			local v4 = child.Position + createVector(0, 1, 0)
			local v5 = { workspace.Characters, workspace.Enemies }
			local v6, _, _ = ray(v4, createVector(-0, -15, -0), v5, false)

			if v6 then
				local position = clone.PrimaryPart.Position
				local position2 = child.Position
				local cFrame = child.CFrame
				child:SetAttribute("Speed", math.random(25, 35) / 25)
				local v7 = child
				task.spawn(function()
					TrailCurve(v7, CFrame.new(v7.Position), position, position2)
					v7.CFrame = cFrame
				end)
			else
				child:Destroy()
			end
		end

		task.wait(0.15)
		local tails = xTransformed.Phase4.Tails

		for _ = 1, 9 do
			local clone2 = tails["Tail" .. math.random(1, #tails:GetChildren())]:Clone()
			debris:AddItem(clone2, 10)
			clone2.CFrame = v * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
				0,
				0,
				-math.random(36.666666666666664, 55)
			)
			local ray = Util.Ray
			local v5 = clone2.Position + createVector(0, 1, 0)
			local v6 = { workspace.Characters, workspace.Enemies }
			local v7, _, _ = ray(v5, createVector(-0, -15, -0), v6, false)

			if v7 then
				Util.SetParentOverrideWithColor(clone2, p, p4, "KitsuneFruitVFXColor")
				local v8 = math.random(2, 7) / 10
				local textureSpeed = math.random(10, 15) / 10
				local textureLength = math.random(5, 12) / 10
				local descendantsByDescendant = {}

				for _, descendant in pairs(clone2:GetDescendants()) do
					if descendant:IsA("Beam") then
						descendant.CurveSize0 *= v8
						descendant.CurveSize1 *= v8
						descendant.Width0 *= v8
						descendant.Width1 *= v8
						descendant.TextureSpeed = textureSpeed
						descendant.TextureLength = textureLength
						descendantsByDescendant[descendant] = descendant
					elseif descendant:IsA("Attachment") then
						descendant.Position = Vector3.new(
							descendant.Position.X * v8,
							descendant.Position.Y * v8,
							descendant.Position.Z * v8
						)
					end
				end

				local _ = clone2.Attach_0A
				local attach_1A = clone2.Attach_1A
				local curveSize = math.random(-15, 25)
				local curveSize2 = math.random(-15, 25)
				task.spawn(function()
					for i = 1, 5 do
						curveSize = 0
						curveSize2 = math.random(-15, 15)
						local v14 = 0.25 * math.random(20, 50) / 10

						for k, v15 in pairs(descendantsByDescendant) do
							TweenService:Create(
								v15,
								TweenInfo.new(v14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CurveSize0 = curveSize,
									CurveSize1 = curveSize2
								}
							):Play()
						end

						task.wait(v14)
					end
				end)
				local tween = TweenService:Create(
					attach_1A,
					TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Position = attach_1A.Position
					}
				)
				attach_1A.Position = Vector3.new(math.random(-10, 10), math.random(0, 5), math.random(-10, 10))
				tween:Play()
				local v14 = descendantsByDescendant
				task.spawn(function()
					task.wait(duration * 0.5)

					for k, v15 in pairs(v14) do
						TweenService:Create(v15, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end
				end)
			else
				clone2:Destroy()
			end
		end

		local function GroundRocks2(cFrame, p5, _, p6)
			for _ = 1, 5 do
				task.spawn(function()
					local clone2 = xTransformed.Phase4.Rock2:Clone()
					debris:AddItem(clone2, 10)
					clone2.Position = cFrame.Position + Vector3.new(
						math.random(-15, 15),
						math.random(1, 15),
						math.random(-15, 15)
					)
					clone2.Size = Vector3.new(math.random(3, 5), math.random(3, 5), math.random(3, 5))
					clone2.Material = p6.Material
					clone2.Color = p6.Color
					Util.SetParentOverrideWithColor(clone2, p5, p4, "KitsuneFruitVFXColor")
					rocks:ApplyCollision(clone2, nil, true)
					task.spawn(function()
						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end

						task.wait(1.5 + math.random(10, 50) / 100)

						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						TweenService:Create(
							clone2,
							TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
							{
								Size = createVector(0, 0, 0)
							}
						):Play()
					end)
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
					bodyVelocity.P = 3000
					Util.SetParentOverrideWithColor(bodyVelocity, clone2, p4, "KitsuneFruitVFXColor")
					bodyVelocity.Velocity = CFrame.new(
						clone2.Position,
						(CFrame.new(clone2.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
							0,
							0,
							-30
						)).Position + Vector3.new(
							math.random(-10, 10) / 5,
							math.random(80, 250),
							math.random(-10, 10) / 5
						)
					).LookVector * math.random(70, 100)
					debris:AddItem(bodyVelocity, 0.1)
					clone2.Attachment0.Orientation = createVector(0, 0, 0)
					local v4 = math.random(-100, 100)
					local v5 = math.random(-100, 100)
					local v6 = math.random(-100, 100)
					local v7 = v4 / 10
					local v8 = v5 / 10
					local v9 = v6 / 10
					task.spawn(function()
						task.wait(0.05)

						for i = 1, 6 do
							v4 = math.clamp(v4 - v7, 0, 120)
							v5 = math.clamp(v5 - v8, 0, 120)
							v6 = math.clamp(v6 - v9, 0, 120)
							local tween = TweenService:Create(
								clone2.Attachment0,
								TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone2.Attachment0.CFrame * CFrame.Angles(
										math.rad(v4),
										math.rad(v5),
										(math.rad(v6))
									)
								}
							)
							tween:Play()
							tween.Completed:Wait()
							tween:Destroy()

							if i ~= 6 then
								continue
							end

							for _, emitter in pairs(clone2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end

						clone2.AlignOrientation:Destroy()
					end)
					debris:AddItem(clone2, 10)
				end)
			end
		end

		local tails3 = xTransformed.Phase4.Tails3

		local function SmallTails()
			for _ = 1, _G.FastMode and 2 or 5 do
				task.spawn(function()
					task.wait(math.random(0, 100) / 100)
					local v4 = math.random(150, 170) / 20
					v *= CFrame.Angles(0, 1.2217304763960306, 0)
					local v5 = math.random(1, 3)
					local clone2 = tails3["Tail" .. v5]:Clone()
					debris:AddItem(clone2, 10)
					clone2:SetPrimaryPartCFrame(v * CFrame.new(0, 7, -70))
					clone2:ScaleTo(v4)

					for _, part in pairs(clone2:GetDescendants()) do
						if not part:IsA("MeshPart") then
							continue
						end

						local v6 = part
						task.spawn(function()
							local tween = TweenService:Create(
								v6,
								TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false),
								{
									Transparency = v6.Transparency
								}
							)
							v6.Transparency = 1
							task.wait(0.1)
							tween:Play()
						end)
					end

					local _ = 5 * v4
					local radius = 2 * v4
					local v7 = 5 * v4
					local cFrame = clone2.PrimaryPart.CFrame
					local ray = Util.Ray
					local v8 = cFrame.Position + createVector(0, 1, 0)
					local v9 = { workspace.Characters, workspace.Enemies }
					local v10, v11, v12 = ray(v8, createVector(-0, -50, -0), v9, false)

					if v10 then
						Util.SetParentOverrideWithColor(clone2, p, p4, "KitsuneFruitVFXColor")
						task.spawn(function()
							task.wait(0.15)
							GroundRocks2(clone2.PrimaryPart.CFrame, p, v11, v10)
							RockCrater(nil, v11, v12, p, {
								Radius = radius,
								Size = 5,
								Duration = 3,
								Amount = 10,
								CurrentRock = xTransformed.Phase4.CraterRock
							}, p4) -- equivalent call inferred; original call site unknown
						end)
						local track = nil

						if v5 == 1 then
							track = clone2.AnimationController.Animator:LoadAnimation(animation)
						elseif v5 == 2 then
							track = clone2.AnimationController.Animator:LoadAnimation(animation3)
						elseif v5 == 3 then
							track = clone2.AnimationController.Animator:LoadAnimation(animation2)
						end

						track:Play()
						track:AdjustSpeed(0.5)
						task.spawn(function()
							local clone3 = xTransformed.Phase4.TailFlameSmall:Clone()
							debris:AddItem(clone3, 10)
							clone3.Size = Vector3.new(clone3.Size.X * v4 / 5.5, 1, clone3.Size.Z * v4 / 5.5)
							clone3.CFrame = cFrame * CFrame.new(0, -6, 0)
							Util.SetParentOverrideWithColor(clone3, p, p4, "KitsuneFruitVFXColor")

							for _, emitter in pairs(clone3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							task.wait(2.55)

							for _, part in pairs(clone2:GetDescendants()) do
								if part:IsA("MeshPart") then
									TweenService:Create(part, TweenInfo.new(0.25), {
										Transparency = 1
									}):Play()
								end
							end

							local clone4 = xTransformed.Phase4.TailEnd:Clone()
							debris:AddItem(clone4, 10)
							clone4.Size = Vector3.new(radius * 1.5, v7 * 1.5, radius * 1.5)
							clone4.CFrame = cFrame
							Util.SetParentOverrideWithColor(clone4, p, p4, "KitsuneFruitVFXColor")

							for _, emitter in pairs(clone4:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							task.wait(0.30000000000000004)

							for _, emitter in pairs(clone4:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							for _, emitter in pairs(clone3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
					else
						clone2:Destroy()
					end
				end)
			end
		end

		local function BigRandomTails()
			for _ = 1, _G.FastMode and 1 or 4 do
				task.spawn(function()
					task.wait(math.random(0, 100) / 100)
					local v4 = math.random(120, 180) / 10
					local v5 = math.random(125, 135)
					local v6 = 5 * v4
					local v7 = 2 * v4
					local v8 = 5 * v4
					local v9 = math.random(1, 3)
					local clone2 = tails3["Tail" .. v9]:Clone()
					debris:AddItem(clone2, 10)
					clone2:SetPrimaryPartCFrame(v * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
						0,
						v6 / 5.25,
						-v5
					))
					clone2:ScaleTo(v4)

					for _, part in pairs(clone2:GetDescendants()) do
						if not part:IsA("MeshPart") then
							continue
						end

						local v10 = part
						task.spawn(function()
							local tween = TweenService:Create(
								v10,
								TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false),
								{
									Transparency = v10.Transparency
								}
							)
							v10.Transparency = 1
							task.wait(0.1)
							tween:Play()
						end)
					end

					local cFrame = clone2.PrimaryPart.CFrame * CFrame.Angles(0, -3.141592653589793, 0) * CFrame.new(
						0,
						0,
						5
					)
					local ray = Util.Ray
					local v11 = cFrame.Position + createVector(0, 1, 0)
					local v12 = { workspace.Characters, workspace.Enemies }
					local v13, v14, v15 = ray(v11, createVector(-0, -50, -0), v12, false)

					if v13 then
						Util.SetParentOverrideWithColor(clone2, p, p4, "KitsuneFruitVFXColor")
						task.spawn(function()
							task.wait(0.15)
							GroundRocks2(clone2.PrimaryPart.CFrame, p, v14, v13)
							RockCrater(nil, v14, v15, p, {
								Radius = v7 * 0.85,
								Size = 5,
								Duration = 3,
								Amount = 10,
								CurrentRock = xTransformed.Phase4.CraterRock
							}, p4) -- equivalent call inferred; original call site unknown
						end)
						local track = nil

						if v9 == 1 then
							track = clone2.AnimationController.Animator:LoadAnimation(animation)
						elseif v9 == 2 then
							track = clone2.AnimationController.Animator:LoadAnimation(animation3)
						elseif v9 == 3 then
							track = clone2.AnimationController.Animator:LoadAnimation(animation2)
						end

						track:Play()
						track:AdjustSpeed(0.5)
						task.spawn(function()
							local clone3 = xTransformed.Phase4.TailFlame:Clone()
							debris:AddItem(clone3, 10)
							clone3.Size = Vector3.new(clone3.Size.X * v4 / 5.5, 1, clone3.Size.Z * v4 / 5.5)
							clone3.CFrame = cFrame * CFrame.new(0, -v6 / 5.25 + 1, 0)
							Util.SetParentOverrideWithColor(clone3, p, p4, "KitsuneFruitVFXColor")

							for _, emitter in pairs(clone3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							task.wait(2.55)

							for _, part in pairs(clone2:GetDescendants()) do
								if part:IsA("MeshPart") then
									TweenService:Create(part, TweenInfo.new(0.25), {
										Transparency = 1
									}):Play()
								end
							end

							local clone4 = xTransformed.Phase4.TailEnd:Clone()
							debris:AddItem(clone4, 10)
							clone4.Size = Vector3.new(v7 * 1.5, v8 * 1.5, v7 * 1.5)
							clone4.CFrame = cFrame
							Util.SetParentOverrideWithColor(clone4, p, p4, "KitsuneFruitVFXColor")

							for _, emitter in pairs(clone4:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							task.wait(0.30000000000000004)

							for _, emitter in pairs(clone4:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							for _, emitter in pairs(clone3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
					else
						clone2:Destroy()
					end
				end)
			end
		end

		SmallTails()
		BigRandomTails()
	end)
end

local v = {}
return function(player)
	local player2 = player.player
	local ID = player.ID

	if ID == 1 then
		return
	end

	if ID == 2 then
		local character = player.Character
		local lookCF = player.LookCF
		local distance = player.Distance
		local duration = player.Duration

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid then
				if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
					return
				end

				local folder = Instance.new("Folder")
				folder.Name = "_KitsuDashStart"
				Util.SetParentOverrideWithColor(folder, character, player2, "KitsuneFruitVFXColor")
				debris:AddItem(folder, 2)
				local v2 = distance * 1 / 3
				local v3 = distance * 1 / 3
				local v4 = duration / 3
				local position = lookCF.Position
				local position2 = lookCF.Position
				local random = Random.new()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {
					workspace._WorldOrigin,
					workspace.Characters,
					workspace.Enemies
				}
				local v5 = nil
				local v6 = -1
				local v7 = 0

				for i = 1, 3 do
					local lookVector = humanoidRootPart.CFrame.LookVector

					if v5 == nil or not (time() - v7 < 1.25) then
						v6 *= -1
						position = position2
					else
						position = closestPointOnLine(position2, position, v5)
					end

					local v8 = closestPointOnLine(position2, position, lookVector) -- equivalent call inferred; original call site unknown
					local rightVector = CFrame.lookAt(createVector(0, 0, 0), lookVector).RightVector
					local number = random:NextNumber(13.333333333333334, 13.333333333333334)
					local number2 = random:NextNumber(v2, v3)

					if i == 1 then
						number2 *= 0.5
					elseif i == 3 then
						number2 *= 0.5
						number = 0
					end

					local v9 = v8 + lookVector * number2 + rightVector * number * v6

					if i == 3 then
						v9 = lookCF * Vector3.new(0, 0, -distance)
					end

					local vector2 = v9 * createVector(1, 0, 1) + position2 * createVector(0, 1, 0)
					local raycastResult = workspace:Raycast(position2, vector2 - position2, raycastParams)

					if raycastResult ~= nil and math.abs(raycastResult.Normal.Y) > 0.1 then
						local position3 = raycastResult.Position
						local normal = raycastResult.Normal
						local X = normal.X
						local Y = normal.Y
						local Z = normal.Z
						local X2 = position3.X
						local Y2 = position3.Y
						local Z2 = position3.Z
						local v10 = -(X * X2 + Y * Y2 + Z * Z2)
						local X3 = vector2.X
						local Z3 = vector2.Z
						vector2 = Vector3.new(X3, -(X * X3 + Z * Z3 + v10) / Y, Z3)
					end

					local tween = TweenService:Create(
						humanoidRootPart,
						TweenInfo.new(v4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = CFrame.new(vector2, vector2 + lookCF.LookVector)
						}
					)
					tween:Play()
					v[tween] = humanoidRootPart
					task.delay(0.3, function()
						v[tween] = nil
					end)
					Effect.new("Kitsune.ZigzagDash"):replicate({
						hrp = humanoidRootPart,
						originPos = position2,
						goalPos = vector2,
						index = i,
						player = player2
					})
					v6 *= -1
					v7 = time()
					task.wait(v4)
					v5 = lookVector
					position2 = vector2
				end
			end
		end
	elseif ID == 3 then
		local character = player.Character

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid then
				if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1500 then
					return
				end

				local riseCF = player.RiseCF
				local fallCF = player.FallCF
				local riseDistance = player.RiseDistance
				local fallDistance = player.FallDistance
				local riseDuration = player.RiseDuration
				local fallDuration = player.FallDuration
				local timestamp = player.Timestamp
				local grounded = player.Grounded
				local v2 = math.max(0, workspace:GetServerTimeNow() - timestamp - 0.05)
				local v3

				if grounded then
					if riseDuration < v2 then
						v3 = 0
						fallDuration = math.max(0.001, fallDuration - math.max(0, v2 - v3))
					else
						v3 = math.max(0.001, riseDuration - v2)
					end
				else
					fallDuration = math.max(0.001, fallDuration - v2)
					v3 = 0
				end

				local _ = riseDistance / v3
				local _ = fallDistance / fallDuration

				local function unweldAndModel(folder, p)
					local model = Instance.new("Model")
					debris:AddItem(model, p)
					model.Name = folder.Name
					local clone = folder:Clone()
					Util.SetParentOverrideWithColor(clone, model, player2, "KitsuneFruitVFXColor")
					model.PrimaryPart = clone

					for _, part in pairs(folder:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Anchored = true
						end
					end

					return model
				end

				local clone = xTransformed.Phase2.StartImpact2:Clone()
				debris:AddItem(clone, 10)
				clone.CFrame = humanoidRootPart.CFrame
				Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "KitsuneFruitVFXColor")
				DeleteImpactAfterDuration(clone)

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v4 = emitter
					task.spawn(function()
						if v4:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v4:GetAttribute("EmitDelay"))
						end

						Util.EmitFix(v4, v4:GetAttribute("EmitCount"))
					end)
				end

				local folder = unweldAndModel(xTransformed.Phase2.RiseAura, v3 + fallDuration + 5)
				local folder2 = unweldAndModel(xTransformed.Phase2.RiseAura2, v3 + fallDuration + 5)
				folder:PivotTo(riseCF)
				folder2:PivotTo(riseCF * CFrame.new(0, 5, -2.5))
				Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "KitsuneFruitVFXColor")
				Util.SetParentOverrideWithColor(folder2, _WorldOrigin, player2, "KitsuneFruitVFXColor")
				Util.Sound:Play("KitsuneXTransformedMultiDash", folder.PrimaryPart or humanoidRootPart, nil, 1, 1.5)

				for k, v4 in pairs(v) do
					if v4 == humanoidRootPart then
						k:Cancel()
					end
				end

				humanoidRootPart.CFrame = riseCF
				local v4 = Util.BodyMover.new(character):Create("BodyGyro", {
					CFrame = riseCF,
					Duration = v3 + fallDuration + 0.5
				})
				local v5 = Util.BodyMover.new(character):Create("BodyPosition", {
					Position = humanoidRootPart.Position,
					Duration = v3 + fallDuration + 0.5
				})

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				local total = 0

				if grounded then
					local lastTime = tick()
					local v6 = 0.016666666666666666

					for _ = 1, 60 * v3 do
						if v3 < tick() - lastTime then
							break
						end

						local v7 = (tick() - lastTime) / v3
						local cFrame = riseCF * CFrame.new(0, 0, -riseDistance * v7)
						v5:Set(cFrame.p)
						humanoidRootPart.CFrame = cFrame
						total += v6 * 60 * 30

						if folder and folder2 then
							folder:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(0, 0, (math.rad(total))))
							folder2:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 5, -2.5))
						end

						v6 = RunService.Heartbeat:Wait()
					end
				end

				local cFrame2 = riseCF * CFrame.new(0, 0, -riseDistance)
				v5:Set(cFrame2.p)
				humanoidRootPart.CFrame = cFrame2
				local lastTime = tick()

				while tick() - lastTime < 0.2 do
					v4:Set(humanoidRootPart.CFrame:Lerp(fallCF, (tick() - lastTime) / 0.4))
					task.wait()
				end

				v4:Set(fallCF)

				if v4 then
					v4:Set(fallCF)
				end

				local clone2 = xTransformed.Phase2.StartImpact3:Clone()
				clone2.CFrame = CFrame.new(humanoidRootPart.Position) * (fallCF - fallCF.Position)
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "KitsuneFruitVFXColor")
				DeleteImpactAfterDuration(clone2)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v7 = emitter
					task.spawn(function()
						if v7:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v7:GetAttribute("EmitDelay"))
						end

						Util.EmitFix(v7, v7:GetAttribute("EmitCount"))
					end)
				end

				if fallDuration > 0.05 then
					fallDuration -= 0.03333333333333333
				end

				local v7 = true
				task.delay(fallDuration, function()
					v7 = false
				end)
				TornadoSpin(
					CFrame.new(humanoidRootPart.Position) * (fallCF - fallCF.Position),
					humanoidRootPart,
					CFrame.Angles(-1.0471975511965976, 0, 0),
					fallDuration,
					player2
				) -- equivalent call inferred; original call site unknown
				local lastTime2 = tick()
				local v9 = 0.016666666666666666

				for _ = 1, 60 * fallDuration do
					if fallDuration < tick() - lastTime2 then
						break
					end

					local v10 = (tick() - lastTime2) / fallDuration
					humanoidRootPart.CFrame = fallCF * CFrame.new(
						0,
						0,
						-(fallDistance + humanoidRootPart.Size.Y * 2) * v10
					)
					v4:Set(humanoidRootPart.CFrame)
					v5:Set(humanoidRootPart.Position)
					total += v9 * 60 * 30

					if folder and folder2 then
						folder:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(0, 0, (math.rad(total))))
						folder2:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 5, -2.5))
					end

					v9 = RunService.Heartbeat:Wait()
				end

				v5:Destroy()
				local ray = Util.Ray
				local v10 = fallCF * Vector3.new(0, 0, -(fallDistance - 0.1))
				local v11 = { workspace.Characters, workspace.Enemies }
				local v12, v13, v14 = ray(v10, createVector(-0, -10, -0), v11)

				if not v12 then
					v12, v13, v14 = Util.Ray(
						fallCF * Vector3.new(0, 0, -(fallDistance - 0.1)),
						fallCF.LookVector * 10,
						{ workspace.Characters, workspace.Enemies }
					)
				end

				if v12 then
					humanoidRootPart.CFrame = CFrame.new(v13 + v14 * humanoidRootPart.Size.Y * 2) * Util.Misc.AlignCFrame(
						humanoidRootPart.CFrame - humanoidRootPart.CFrame.p,
						createVector(0, 1, 0)
					)
					v4:Set(humanoidRootPart.CFrame)
				end

				Util.BodyMover.new(character):Create("BodyVelocity", {
					Velocity = fallCF.LookVector * -250 + createVector(0, 100, 0),
					Duration = 0.2
				})

				if v4 then
					task.delay(0.2, function()
						v4:Destroy()
					end)
				end

				for _, effect in pairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end
		end
	else
		local cFrame = ID == 4 and player.CFrame

		if cFrame then
			if (cFrame.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
				return
			end

			Util.Sound:Play("KitsuneXTransformedExplosion", cFrame.Position, nil, 1, 2)
			Util.Sound:Play("Z Attacks- Firework explosion", cFrame.Position, nil, 0.5, 1.5)
			local v2 = Util.Sound:Play("X Attacks- Tail Ambience", cFrame.Position, nil, math.random(90, 110) / 100, 2)
			v2.Looped = true
			task.spawn(function()
				for i = 1, 360 do
					if not v2 then
						break
					end

					if i > 180 then
						v2.Volume = 2 + -2 * (i / 360)
					else
						v2.Volume = 2
					end

					task.wait()
				end

				if v2 then
					v2:Destroy()
				end
			end)
			local position = cFrame.Position
			local character = game.Players.LocalPlayer.Character

			if character ~= nil then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= 200 then
					task.spawn(function()
						task.spawn(function()
							local clone = xTransformed.Phase3.Bloom:Clone()
							debris:AddItem(clone, 5)
							Util.SetParentOverrideWithColor(clone, game.Lighting, player2, "KitsuneFruitVFXColor")
							local tween = TweenService:Create(clone, TweenInfo.new(0.1), {
								Size = 50,
								Threshold = 1.25
							})
							tween:Play()
							tween.Completed:Wait()
							local tween2 = TweenService:Create(clone, TweenInfo.new(0.35), {
								Size = 24,
								Threshold = 2
							})
							tween2:Play()
							tween2.Completed:Wait()
							clone:Destroy()
						end)
						cameraShaker:ShakeOnce(10, 7, 0.3, 0.25)
						local clone = xTransformed.Phase3.ScreenColor:Clone()
						debris:AddItem(clone, 5)
						Util.SetParentOverrideWithColor(clone, game.Lighting, player2, "KitsuneFruitVFXColor")
						local tween = TweenService:Create(clone, TweenInfo.new(0.05), {
							Brightness = clone.Brightness,
							Contrast = clone.Contrast,
							Saturation = clone.Saturation,
							TintColor = clone.TintColor
						})
						clone.Brightness = 0
						clone.Contrast = 0
						clone.Saturation = 0
						clone.TintColor = Util.WrapColor3Constructor(
							Color3.fromRGB(255, 255, 255),
							player2,
							"KitsuneFruitVFXColor"
						)
						tween:Play()
						task.wait(0.1)
						local tween2 = TweenService:Create(clone, TweenInfo.new(0.125), {
							TintColor = Util.WrapColor3Constructor(
								Color3.fromRGB(255, 255, 255),
								player2,
								"KitsuneFruitVFXColor"
							),
							Brightness = 0,
							Contrast = 0,
							Saturation = 0
						})
						tween2:Play()
						tween2.Completed:Wait()
						clone:Destroy()
					end)
				end
			end

			task.spawn(function()
				local clone = xTransformed.Phase3.GroundImpact:Clone()
				debris:AddItem(clone, 10)
				clone.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "KitsuneFruitVFXColor")
				DeleteImpactAfterDuration(clone)

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v3 = emitter
					task.spawn(function()
						if v3:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v3:GetAttribute("EmitDelay"))
						end

						Util.EmitFix(v3, v3:GetAttribute("EmitCount"))
					end)
				end

				local ray = Util.Ray
				local v3 = cFrame.Position + createVector(0, 1, 0)
				local v4 = { workspace.Characters, workspace.Enemies }
				local v5, v6, v7 = ray(v3, createVector(-0, -15, -0), v4, false)

				if v5 then
					local character2 = game.Players.LocalPlayer.Character

					if character2 ~= nil then
						local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart and (humanoidRootPart.Position - v6).Magnitude <= 200 then
							cameraShaker:ShakeOnce(35, 15, 0.1, 0.35)
						end
					end

					local clone2 = xTransformed.Phase3.GroundImpact2:Clone()
					debris:AddItem(clone2, 10)
					clone2.CFrame = AlignCFrame(CFrame.new(v6), v7) + v7 * 0.01
					Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player2, "KitsuneFruitVFXColor")
					DeleteImpactAfterDuration(clone2)

					for _, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v8 = emitter
						task.spawn(function()
							if v8:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v8:GetAttribute("EmitDelay"))
							end

							Util.EmitFix(v8, v8:GetAttribute("EmitCount"))
						end)
					end

					local clone3 = xTransformed.Phase3.GroundImpact5:Clone()
					debris:AddItem(clone3, 10)
					clone3.CFrame = AlignCFrame(CFrame.new(v6), v7) + v7 * 0.01
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player2, "KitsuneFruitVFXColor")
					DeleteImpactAfterDuration(clone3)

					for _, emitter in pairs(clone3:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v8 = emitter
						task.spawn(function()
							if v8:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v8:GetAttribute("EmitDelay"))
							end

							Util.EmitFix(v8, v8:GetAttribute("EmitCount"))
						end)
					end

					GroundRocks(CFrame.new(v6), _WorldOrigin, v6, v5, player2)
					FlameRise(cFrame, _WorldOrigin, player2) -- equivalent call inferred; original call site unknown
					local cframe = cFrame * CFrame.Angles(-0.8726646259971648, 0, 0)
					local _ = cFrame.Position
					local v11 = _WorldOrigin
					local v12 = player2
					local v13 = 5
					task.spawn(function()
						local function TrailCurve(instance, cframe2, position2, position3)
							local magnitude = (position2 - position3).Magnitude
							instance.CFrame = CFrame.new(position2, position3)
							local v14 = (position2 - position3) / 2
							local position4 = CFrame.new(CFrame.new(position2) * (v14 / -1.5)).Position
							local position5 = CFrame.new(CFrame.new(position3) * (v14 / 1.5)).Position
							CFrame.new(math.random(-50, 50), math.random(-50, 50) / 2, math.random(-50, 50))
							CFrame.new(math.random(-50, 50), math.random(-50, 50) / 2, math.random(-50, 50))
							local cframe3 = CFrame.new(0, 50, 0)
							local cframe4 = CFrame.new(0, 30, 0)
							local v15 = CFrame.new(position4, position4 + cframe2.LookVector) * cframe3.Position
							local v16 = CFrame.new(position5, position5 + cframe2.LookVector) * cframe4.Position
							local speed = instance:GetAttribute("Speed")
							local lastTime = tick()
							local v17 = magnitude / speed / 60
							local _ = (magnitude / speed + speed) / 60

							while tick() - lastTime < v17 do
								local v18 = (tick() - lastTime) / v17
								local v19 = cubicBezier(v18, position2, v15, v16, position3)
								instance.CFrame = instance.CFrame:Lerp(CFrame.new(v19, position3), v18)
								RunService.Heartbeat:Wait()
							end
						end

						task.wait(0.15)
						local clone4 = xTransformed.Phase4.GroundFlame:Clone()
						debris:AddItem(clone4, 5)
						local v14 = AlignCFrame(CFrame.new(v6, v6 + cframe.LookVector), v7) + v7 * 0.01
						local orientation, v15, v16 = cframe:ToOrientation()
						math.deg(orientation)
						math.deg(v15)
						math.deg(v16)
						clone4:SetPrimaryPartCFrame(v14)
						Util.SetParentOverrideWithColor(clone4, v11, v12, "KitsuneFruitVFXColor")

						for _, emitter in pairs(clone4:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if emitter.Parent.Name == "KitsuneLogo" then
								Util.EmitFix(emitter, 1)
							else
								local v17 = emitter
								task.spawn(function()
									v17.Enabled = true
									task.wait(v13)
									v17.Enabled = false
								end)
							end
						end

						for _, child in pairs(clone4:GetChildren()) do
							if child == clone4.PrimaryPart then
								continue
							end

							local ray2 = Util.Ray
							local v17 = child.Position + createVector(0, 1, 0)
							local v18 = { workspace.Characters, workspace.Enemies }
							local v19, _, _ = ray2(v17, createVector(-0, -15, -0), v18, false)

							if v19 then
								local position2 = clone4.PrimaryPart.Position
								local position3 = child.Position
								local cFrame2 = child.CFrame
								child:SetAttribute("Speed", math.random(25, 35) / 25)
								local v20 = child
								task.spawn(function()
									TrailCurve(v20, CFrame.new(v20.Position), position2, position3)
									v20.CFrame = cFrame2
								end)
							else
								child:Destroy()
							end
						end

						task.wait(0.15)
						local tails = xTransformed.Phase4.Tails

						for _ = 1, 9 do
							local clone5 = tails["Tail" .. math.random(1, #tails:GetChildren())]:Clone()
							debris:AddItem(clone5, 10)
							clone5.CFrame = v14 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
								0,
								0,
								-math.random(36.666666666666664, 55)
							)
							local ray2 = Util.Ray
							local v18 = clone5.Position + createVector(0, 1, 0)
							local v19 = { workspace.Characters, workspace.Enemies }
							local v20, _, _ = ray2(v18, createVector(-0, -15, -0), v19, false)

							if v20 then
								Util.SetParentOverrideWithColor(clone5, v11, v12, "KitsuneFruitVFXColor")
								local v21 = math.random(2, 7) / 10
								local textureSpeed = math.random(10, 15) / 10
								local textureLength = math.random(5, 12) / 10
								local descendantsByDescendant = {}

								for _, descendant in pairs(clone5:GetDescendants()) do
									if descendant:IsA("Beam") then
										descendant.CurveSize0 *= v21
										descendant.CurveSize1 *= v21
										descendant.Width0 *= v21
										descendant.Width1 *= v21
										descendant.TextureSpeed = textureSpeed
										descendant.TextureLength = textureLength
										descendantsByDescendant[descendant] = descendant
									elseif descendant:IsA("Attachment") then
										descendant.Position = Vector3.new(
											descendant.Position.X * v21,
											descendant.Position.Y * v21,
											descendant.Position.Z * v21
										)
									end
								end

								local _ = clone5.Attach_0A
								local attach_1A = clone5.Attach_1A
								local curveSize = math.random(-15, 25)
								local curveSize2 = math.random(-15, 25)
								task.spawn(function()
									for i = 1, 5 do
										curveSize = 0
										curveSize2 = math.random(-15, 15)
										local v27 = 0.25 * math.random(20, 50) / 10

										for k, v28 in pairs(descendantsByDescendant) do
											TweenService:Create(
												v28,
												TweenInfo.new(v27, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
												{
													CurveSize0 = curveSize,
													CurveSize1 = curveSize2
												}
											):Play()
										end

										task.wait(v27)
									end
								end)
								local tween = TweenService:Create(
									attach_1A,
									TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{
										Position = attach_1A.Position
									}
								)
								attach_1A.Position = Vector3.new(
									math.random(-10, 10),
									math.random(0, 5),
									math.random(-10, 10)
								)
								tween:Play()
								local v27 = descendantsByDescendant
								task.spawn(function()
									task.wait(v13 * 0.5)

									for k, v28 in pairs(v27) do
										TweenService:Create(
											v28,
											TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Width0 = 0,
												Width1 = 0
											}
										):Play()
									end
								end)
							else
								clone5:Destroy()
							end
						end

						local function GroundRocks2(cFrame2, p, _, p2)
							for _ = 1, 5 do
								task.spawn(function()
									local clone5 = xTransformed.Phase4.Rock2:Clone()
									debris:AddItem(clone5, 10)
									clone5.Position = cFrame2.Position + Vector3.new(
										math.random(-15, 15),
										math.random(1, 15),
										math.random(-15, 15)
									)
									clone5.Size = Vector3.new(math.random(3, 5), math.random(3, 5), math.random(3, 5))
									clone5.Material = p2.Material
									clone5.Color = p2.Color
									Util.SetParentOverrideWithColor(clone5, p, v12, "KitsuneFruitVFXColor")
									rocks:ApplyCollision(clone5, nil, true)
									task.spawn(function()
										for _, emitter in pairs(clone5:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") then
												emitter.Enabled = true
											end
										end

										task.wait(1.5 + math.random(10, 50) / 100)

										for _, emitter in pairs(clone5:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") then
												emitter.Enabled = false
											end
										end

										TweenService:Create(
											clone5,
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
									end)
									local bodyVelocity = Instance.new("BodyVelocity")
									bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
									bodyVelocity.P = 3000
									Util.SetParentOverrideWithColor(bodyVelocity, clone5, v12, "KitsuneFruitVFXColor")
									bodyVelocity.Velocity = CFrame.new(
										clone5.Position,
										(CFrame.new(clone5.Position) * CFrame.Angles(
											0,
											math.rad((math.random(-180, 180))),
											0
										) * CFrame.new(0, 0, -30)).Position + Vector3.new(
											math.random(-10, 10) / 5,
											math.random(80, 250),
											math.random(-10, 10) / 5
										)
									).LookVector * math.random(70, 100)
									debris:AddItem(bodyVelocity, 0.1)
									clone5.Attachment0.Orientation = createVector(0, 0, 0)
									local v17 = math.random(-100, 100)
									local v18 = math.random(-100, 100)
									local v19 = math.random(-100, 100)
									local v20 = v17 / 10
									local v21 = v18 / 10
									local v22 = v19 / 10
									task.spawn(function()
										task.wait(0.05)

										for i = 1, 6 do
											v17 = math.clamp(v17 - v20, 0, 120)
											v18 = math.clamp(v18 - v21, 0, 120)
											v19 = math.clamp(v19 - v22, 0, 120)
											local tween = TweenService:Create(
												clone5.Attachment0,
												TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
												{
													CFrame = clone5.Attachment0.CFrame * CFrame.Angles(
														math.rad(v17),
														math.rad(v18),
														(math.rad(v19))
													)
												}
											)
											tween:Play()
											tween.Completed:Wait()
											tween:Destroy()

											if i ~= 6 then
												continue
											end

											for _, emitter in pairs(clone5:GetDescendants()) do
												if emitter:IsA("ParticleEmitter") then
													emitter.Enabled = false
												end
											end
										end

										clone5.AlignOrientation:Destroy()
									end)
									debris:AddItem(clone5, 10)
								end)
							end
						end

						local tails3 = xTransformed.Phase4.Tails3

						local function SmallTails()
							for _ = 1, _G.FastMode and 2 or 5 do
								task.spawn(function()
									task.wait(math.random(0, 100) / 100)
									local v17 = math.random(150, 170) / 20
									v14 *= CFrame.Angles(0, 1.2217304763960306, 0)
									local v18 = math.random(1, 3)
									local clone5 = tails3["Tail" .. v18]:Clone()
									debris:AddItem(clone5, 10)
									clone5:SetPrimaryPartCFrame(v14 * CFrame.new(0, 7, -70))
									clone5:ScaleTo(v17)

									for _, part in pairs(clone5:GetDescendants()) do
										if not part:IsA("MeshPart") then
											continue
										end

										local v19 = part
										task.spawn(function()
											local tween = TweenService:Create(
												v19,
												TweenInfo.new(
													0.15,
													Enum.EasingStyle.Linear,
													Enum.EasingDirection.Out,
													0,
													false
												),
												{
													Transparency = v19.Transparency
												}
											)
											v19.Transparency = 1
											task.wait(0.1)
											tween:Play()
										end)
									end

									local _ = 5 * v17
									local radius = 2 * v17
									local v20 = 5 * v17
									local cFrame2 = clone5.PrimaryPart.CFrame
									local ray2 = Util.Ray
									local v21 = cFrame2.Position + createVector(0, 1, 0)
									local v22 = { workspace.Characters, workspace.Enemies }
									local v23, v24, v25 = ray2(v21, createVector(-0, -50, -0), v22, false)

									if v23 then
										Util.SetParentOverrideWithColor(clone5, v11, v12, "KitsuneFruitVFXColor")
										task.spawn(function()
											task.wait(0.15)
											GroundRocks2(clone5.PrimaryPart.CFrame, v11, v24, v23)
											RockCrater(nil, v24, v25, v11, {
												Radius = radius,
												Size = 5,
												Duration = 3,
												Amount = 10,
												CurrentRock = xTransformed.Phase4.CraterRock
											}, v12) -- equivalent call inferred; original call site unknown
										end)
										local track = nil

										if v18 == 1 then
											track = clone5.AnimationController.Animator:LoadAnimation(animation)
										elseif v18 == 2 then
											track = clone5.AnimationController.Animator:LoadAnimation(animation3)
										elseif v18 == 3 then
											track = clone5.AnimationController.Animator:LoadAnimation(animation2)
										end

										track:Play()
										track:AdjustSpeed(0.5)
										task.spawn(function()
											local clone6 = xTransformed.Phase4.TailFlameSmall:Clone()
											debris:AddItem(clone6, 10)
											clone6.Size = Vector3.new(
												clone6.Size.X * v17 / 5.5,
												1,
												clone6.Size.Z * v17 / 5.5
											)
											clone6.CFrame = cFrame2 * CFrame.new(0, -6, 0)
											Util.SetParentOverrideWithColor(clone6, v11, v12, "KitsuneFruitVFXColor")

											for _, emitter in pairs(clone6:GetDescendants()) do
												if emitter:IsA("ParticleEmitter") then
													emitter.Enabled = true
												end
											end

											task.wait(2.55)

											for _, part in pairs(clone5:GetDescendants()) do
												if part:IsA("MeshPart") then
													TweenService:Create(part, TweenInfo.new(0.25), {
														Transparency = 1
													}):Play()
												end
											end

											local clone7 = xTransformed.Phase4.TailEnd:Clone()
											debris:AddItem(clone7, 10)
											clone7.Size = Vector3.new(radius * 1.5, v20 * 1.5, radius * 1.5)
											clone7.CFrame = cFrame2
											Util.SetParentOverrideWithColor(clone7, v11, v12, "KitsuneFruitVFXColor")

											for _, emitter in pairs(clone7:GetDescendants()) do
												if emitter:IsA("ParticleEmitter") then
													emitter.Enabled = true
												end
											end

											task.wait(0.30000000000000004)

											for _, emitter in pairs(clone7:GetDescendants()) do
												if emitter:IsA("ParticleEmitter") then
													emitter.Enabled = false
												end
											end

											for _, emitter in pairs(clone6:GetDescendants()) do
												if emitter:IsA("ParticleEmitter") then
													emitter.Enabled = false
												end
											end
										end)
									else
										clone5:Destroy()
									end
								end)
							end
						end

						local function BigRandomTails()
							for _ = 1, _G.FastMode and 1 or 4 do
								task.spawn(function()
									task.wait(math.random(0, 100) / 100)
									local v17 = math.random(120, 180) / 10
									local v18 = math.random(125, 135)
									local v19 = 5 * v17
									local v20 = 2 * v17
									local v21 = 5 * v17
									local v22 = math.random(1, 3)
									local clone5 = tails3["Tail" .. v22]:Clone()
									debris:AddItem(clone5, 10)
									clone5:SetPrimaryPartCFrame(v14 * CFrame.Angles(
										0,
										math.rad((math.random(-180, 180))),
										0
									) * CFrame.new(0, v19 / 5.25, -v18))
									clone5:ScaleTo(v17)

									for _, part in pairs(clone5:GetDescendants()) do
										if not part:IsA("MeshPart") then
											continue
										end

										local v23 = part
										task.spawn(function()
											local tween = TweenService:Create(
												v23,
												TweenInfo.new(
													0.15,
													Enum.EasingStyle.Linear,
													Enum.EasingDirection.Out,
													0,
													false
												),
												{
													Transparency = v23.Transparency
												}
											)
											v23.Transparency = 1
											task.wait(0.1)
											tween:Play()
										end)
									end

									local cFrame2 = clone5.PrimaryPart.CFrame * CFrame.Angles(0, -3.141592653589793, 0) * CFrame.new(
										0,
										0,
										5
									)
									local ray2 = Util.Ray
									local v24 = cFrame2.Position + createVector(0, 1, 0)
									local v25 = { workspace.Characters, workspace.Enemies }
									local v26, v27, v28 = ray2(v24, createVector(-0, -50, -0), v25, false)

									if v26 then
										Util.SetParentOverrideWithColor(clone5, v11, v12, "KitsuneFruitVFXColor")
										task.spawn(function()
											task.wait(0.15)
											GroundRocks2(clone5.PrimaryPart.CFrame, v11, v27, v26)
											RockCrater(nil, v27, v28, v11, {
												Radius = v20 * 0.85,
												Size = 5,
												Duration = 3,
												Amount = 10,
												CurrentRock = xTransformed.Phase4.CraterRock
											}, v12) -- equivalent call inferred; original call site unknown
										end)
										local track = nil

										if v22 == 1 then
											track = clone5.AnimationController.Animator:LoadAnimation(animation)
										elseif v22 == 2 then
											track = clone5.AnimationController.Animator:LoadAnimation(animation3)
										elseif v22 == 3 then
											track = clone5.AnimationController.Animator:LoadAnimation(animation2)
										end

										track:Play()
										track:AdjustSpeed(0.5)
										task.spawn(function()
											local clone6 = xTransformed.Phase4.TailFlame:Clone()
											debris:AddItem(clone6, 10)
											clone6.Size = Vector3.new(
												clone6.Size.X * v17 / 5.5,
												1,
												clone6.Size.Z * v17 / 5.5
											)
											clone6.CFrame = cFrame2 * CFrame.new(0, -v19 / 5.25 + 1, 0)
											Util.SetParentOverrideWithColor(clone6, v11, v12, "KitsuneFruitVFXColor")

											for _, emitter in pairs(clone6:GetDescendants()) do
												if emitter:IsA("ParticleEmitter") then
													emitter.Enabled = true
												end
											end

											task.wait(2.55)

											for _, part in pairs(clone5:GetDescendants()) do
												if part:IsA("MeshPart") then
													TweenService:Create(part, TweenInfo.new(0.25), {
														Transparency = 1
													}):Play()
												end
											end

											local clone7 = xTransformed.Phase4.TailEnd:Clone()
											debris:AddItem(clone7, 10)
											clone7.Size = Vector3.new(v20 * 1.5, v21 * 1.5, v20 * 1.5)
											clone7.CFrame = cFrame2
											Util.SetParentOverrideWithColor(clone7, v11, v12, "KitsuneFruitVFXColor")

											for _, emitter in pairs(clone7:GetDescendants()) do
												if emitter:IsA("ParticleEmitter") then
													emitter.Enabled = true
												end
											end

											task.wait(0.30000000000000004)

											for _, emitter in pairs(clone7:GetDescendants()) do
												if emitter:IsA("ParticleEmitter") then
													emitter.Enabled = false
												end
											end

											for _, emitter in pairs(clone6:GetDescendants()) do
												if emitter:IsA("ParticleEmitter") then
													emitter.Enabled = false
												end
											end
										end)
									else
										clone5:Destroy()
									end
								end)
							end
						end

						SmallTails()
						BigRandomTails()
					end)
					RockCrater(nil, v6, v7, _WorldOrigin, {
						Radius = 50,
						Size = 7,
						Duration = 5,
						Amount = 20,
						CurrentRock = xTransformed.Phase4.CraterRock
					}, player2) -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end
end