local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Dragonheart").Z.Assets
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Util = require(game.ReplicatedStorage.Util)
local _ = Util.CameraShaker

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteEmitAfterDuration(folder)
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

local function cubicBezier(p, position, p2, p3, position2)
	local v = position + (p2 - position) * p
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (position2 - p3) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function TrailCurve(clone, position, position2, p, p2, p3, cframe, _, folder, folder2)
	local magnitude = (position - position2).Magnitude
	clone.CFrame = CFrame.new(position, position2)
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	math.random(20, 30)
	local v2 = CFrame.new(position3, position3 + cframe.LookVector) * p2.Position
	local v3 = CFrame.new(position4, position4 + cframe.LookVector) * p3.Position
	local lastTime = tick()
	local v4 = magnitude / p / 60
	local v5 = (magnitude / p + p) / 60
	local now = tick()

	while tick() - lastTime < v4 do
		local v6 = (tick() - lastTime) / v4
		local v7 = cubicBezier(v6, position, v2, v3, position2)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v7, position2), v6)
		cubicBezier((tick() - lastTime) / v5, position, v2, v3, position2)

		if now - tick() <= 0 then
			now = tick() + 0.1
			task.spawn(function()
				local cFrame = clone.CFrame
				folder2.CFrame = cFrame

				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local v9 = math.random(90, 110) / 100
				Util.Sound:Play("DragonHeart.DragonHeartZExplosion", cFrame.Position, nil, v9)
				task.wait(0.7)
				folder.CFrame = cFrame

				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local v10 = math.random(90, 110) / 100
				Util.Sound:Play("DragonHeart.DragonHeartZExplosion", cFrame.Position, nil, v10)
			end)
		end

		RunService.Heartbeat:Wait()
	end
end

for _, child in pairs(assets:GetChildren()) do
	for _, child2 in pairs(child:GetChildren()) do
		Util.ResizeModel(child2, 0.666, child2.Position)
	end
end

local function mockRootPart(p, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.Size = p.Size
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = workspace._WorldOrigin
	return part
end

return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local cFrame = humanoidRootPart.CFrame

	if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1200 then
		return
	end

	if player.Holding then
		local clone = assets.Phase1.HoldAura:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Anchored = false
		clone.WeldConstraint.Part1 = humanoidRootPart
		clone.Parent = workspace._WorldOrigin
		local v = Util.Sound:Play("DragonHeart.DragonHeartZHold", cFrame.Position)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		repeat
			task.wait(0.05)
		until player.Holding.Value == false or not (player.Holding:IsDescendantOf(workspace) and character:IsDescendantOf(workspace))

		Util.Debris:AddItem(clone, 3)

		if v then
			Util.Sound:FadeOut(v, 0.4)
		end

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = false
			end
		end
	else
		local humanoidRootPart2 = character.HumanoidRootPart
		local cFrame2 = character.HumanoidRootPart.CFrame
		local part = Instance.new("Part")
		part.Name = "Mock" .. part.Name
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.Size = humanoidRootPart2.Size
		part.CanQuery = false
		part.Transparency = 1
		part.CFrame = cFrame2
		part.Parent = workspace._WorldOrigin
		part.Anchored = false
		local weldConstraint = Instance.new("WeldConstraint", part)
		weldConstraint.Part0 = part
		weldConstraint.Part1 = humanoidRootPart
		local value = player.TargetPosition.Value
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local cframe = CFrame.new(
			humanoidRootPart.Position,
			(Vector3.new(value.X, humanoidRootPart.Position.Y, value.Z))
		)

		local function ZigZag()
			local v = tick() + 1.5
			local clone = assets.Phase1.StartImpact:Clone()
			clone.CFrame = cframe
			clone.Parent = folder
			local v2 = {}
			task.spawn(function()
				local clone2 = assets.Phase1.Dash:Clone()
				clone2.CFrame = cframe
				clone2.Anchored = false
				clone2.Parent = folder
				clone2.Weld.Part0 = part

				for _, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = true
						v2[effect] = effect
					elseif effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				tick()

				while true do
					for _, v3 in pairs(v2) do
						v3:Emit(1)
					end

					task.wait(0.05)

					if not (player.ButtonDown.Value == false or v - tick() <= 0) then
						continue
					end

					for _, effect in pairs(clone2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						elseif effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					break
				end
			end)
			local v3 = {}
			local v4 = true

			for _ = 1, 5 do
				local clone2 = assets.Phase1.SpinTrail:Clone()
				clone2.CFrame = humanoidRootPart.CFrame
				clone2.Parent = folder
				clone2.Anchored = false
				clone2.Weld.Part1 = part

				for _, trail in pairs(clone2:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					trail.Enabled = true
					trail.Lifetime = math.random(5, 7) / 20
				end

				clone2.SpinTrail2.Motor6D.C0 *= CFrame.new(Vector3.new(
					math.random(-35, 35),
					math.random(-15, 30),
					math.random(-35, 30)
				) * 0.6)
				clone2.Weld.C1 = clone2.Weld.C1 * CFrame.Angles(0.7853981633974483, 0, -0.7853981633974483)
				local v5 = math.random(1, 3)

				if v5 == 1 then
					clone2.Trail.Color = ColorSequence.new(Color3.fromRGB(248, 44, 17), Color3.fromRGB(199, 23, 23))
				elseif v5 == 2 then
					clone2.Trail.Color = ColorSequence.new(Color3.fromRGB(171, 27, 17), Color3.fromRGB(255, 50, 23))
				elseif v5 == 3 then
					clone2.Trail.Color = ColorSequence.new(Color3.fromRGB(244, 93, 33), Color3.fromRGB(255, 40, 25))
				end

				local v6 = math.random(7, 15) / 10
				clone2.SpinTrail2.Attach0.Position = Vector3.new(v6, 0, 0)
				clone2.SpinTrail2.Attach1.Position = Vector3.new(-v6, 0, 0)
				v3[clone2] = 15
			end

			task.spawn(function()
				while true do
					for k, v5 in pairs(v3) do
						k.Weld.C0 = k.Weld.C0 * CFrame.Angles(0, math.rad(v5), 0)
						k.SpinTrail2.Motor6D.C1 = k.SpinTrail2.Motor6D.C1 * CFrame.Angles(
							-0.03490658503988659,
							0.10471975511965978,
							0.05235987755982989
						)
					end

					RunService.Heartbeat:Wait()

					if not (player.ButtonDown.Value == false or v - tick() <= 0) then
						continue
					end

					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = part.CFrame.LookVector * 200
					bodyVelocity.MaxForce = createVector(1, 1, 1) * 1e999
					bodyVelocity.Parent = part
					weldConstraint:Destroy()

					for folder2, _ in pairs(v3) do
						for _, trail in pairs(folder2:GetDescendants()) do
							if trail:IsA("Trail") then
								trail.Enabled = false
							end
						end
					end

					break
				end
			end)
			local clone2 = assets.Phase1.DashTrail:Clone()
			clone2.CFrame = cframe
			clone2.Parent = folder

			for _, trail in pairs(clone2:GetDescendants()) do
				if trail:IsA("Trail") then
					trail.Enabled = true
				end
			end

			local clone3 = assets.Phase1.Dragon:Clone()
			clone3.CFrame = cframe
			clone3.Anchored = false
			clone3.Weld.Part1 = clone2.Trail1
			clone3.Parent = Instance.new("Model", folder)

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local clone4 = assets.Phase1.DashTrailFlame:Clone()
			clone4.CFrame = cframe
			clone4.Anchored = false
			clone4.Weld.Part0 = clone2.Trail1
			clone4.Parent = folder

			for _, emitter in pairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				v2[emitter] = emitter
			end

			task.spawn(function()
				local raycastParams = RaycastParams.new()
				raycastParams.IgnoreWater = false
				raycastParams.FilterDescendantsInstances = {
					workspace._WorldOrigin,
					workspace.Characters,
					workspace.Enemies
				}
				local clone5 = assets.Phase1.GroundBurn:Clone()
				clone5.CFrame = cframe
				clone5.Parent = folder

				for _, emitter in pairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local now = tick()
				local emitters = {}
				local v5 = false

				for _, emitter in pairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						table.insert(emitters, emitter)
					end
				end

				while true do
					local raycastResult = workspace:Raycast(
						clone2.Position + createVector(0, 1, 0),
						createVector(-0, -50, -0),
						raycastParams
					)

					if raycastResult then
						clone5.CFrame = CFrame.new(
							raycastResult.Position + createVector(0, 0.1, 0),
							raycastResult.Position + createVector(0, 0.1, 0) + clone2.CFrame.LookVector
						)

						if v5 == false then
							v5 = true

							for _, v6 in pairs(emitters) do
								v6.Enabled = true
							end
						end

						if now - tick() <= 0 then
							now = 0.05 + tick()

							for _, v6 in pairs(emitters) do
								v6:Emit(v6:GetAttribute("EmitCount"))
							end
						end
					elseif v5 == true then
						v5 = false

						for _, v6 in pairs(emitters) do
							v6.Enabled = false
						end
					end

					task.wait()

					if not (v - tick() <= 0) then
						continue
					end

					for _, emitter in pairs(clone5:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					break
				end
			end)
			local clone5 = assets.Phase2.Explosion:Clone()
			clone5.CFrame = cframe
			clone5.Parent = folder
			local clone6 = assets.Phase2.Explosion2:Clone()
			clone6.CFrame = cframe
			clone6.Parent = folder
			local v5 = {
				[1] = CFrame.new(30, -7, -30),
				[1.2] = CFrame.new(-80, 3, 25),
				[2] = CFrame.new(-25, -5, -25),
				[2.2] = CFrame.new(50, 3, 50),
				[3] = CFrame.new(50, -7, -25),
				[3.2] = CFrame.new(-25, 3, 30),
				[4] = CFrame.new(-50, -5, -50),
				[4.2] = CFrame.new(25, 7, 10),
				[5] = CFrame.new(70, -5, -10),
				[5.2] = CFrame.new(-30, 3, 50),
				[6] = CFrame.new(-70, -7, -10),
				[6.2] = CFrame.new(70, 3, -10)
			}
			local position = clone2.Position
			Util.Sound:Play("DragonHeart.DragonHeartZFire", humanoidRootPart)
			local v6 = 0

			while true do
				local value2 = player.TargetPosition.Value
				cframe = CFrame.new(part.Position, value2) * CFrame.new(0, 4, 0)
				v4 = not v4
				local v7 = math.random(5, 10)

				if v4 == true then
					cframe *= CFrame.Angles(0, math.rad(-v7), 0)
				elseif v4 == false then
					cframe *= CFrame.Angles(0, math.rad(v7), 0)
				end

				clone.CFrame = cframe

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local v8 = v6 + 1
				v6 = v5[v8] == nil and 1 or v8

				-- equivalent calls inferred from this helper; original call sites unknown
				local function nerf(p)
					return CFrame.new(p.Position * 0.4)
				end

				local v9

				if v4 then
					local v10 = cframe
					local cframe2 = CFrame.new(50, 0, -100)
					v9 = v10 * CFrame.new(cframe2.Position * 0.4).Position
				else
					local v10 = cframe
					local cframe2 = CFrame.new(-50, 0, -100)
					v9 = v10 * CFrame.new(cframe2.Position * 0.4).Position
				end

				local v11 = nerf(v5[v6]) -- equivalent call inferred; original call site unknown
				local v13 = nerf(v5[v6 + 0.2]) -- equivalent call inferred; original call site unknown
				TrailCurve(clone2, position, v9, 5, v11, v13, cframe, folder, clone6, clone5)

				if v - tick() <= 0 then
					task.spawn(function()
						for _, trail in pairs(clone2:GetDescendants()) do
							if trail:IsA("Trail") then
								trail.Enabled = false
							end
						end

						TweenService:Create(clone2, TweenInfo.new(1), {
							CFrame = clone2.CFrame * CFrame.new(0, 0, -10)
						}):Play()
						task.spawn(function()
							local clone7 = assets.Phase2.EndFlame:Clone()
							clone7.CFrame = clone3.CFrame * CFrame.new(0, 0, 10)
							clone7.Parent = folder

							for _, emitter in pairs(clone7:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								emitter.Enabled = true
								local v14 = emitter
								task.spawn(function()
									task.wait(1)
									v14.Enabled = false
								end)
							end
						end)

						for _, descendant in pairs(clone3:GetDescendants()) do
							if descendant:IsA("Trail") then
								descendant.Enabled = false
							elseif descendant:IsA("MeshPart") then
								local v14 = descendant
								task.spawn(function()
									task.wait(0.7)
									v14.Transparency = 1
								end)
							elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
								local v14 = descendant
								task.spawn(function()
									task.wait(0.7)
									v14.Enabled = false
								end)
							end
						end

						for _, v14 in pairs(v2) do
							v14.Enabled = false
						end

						task.wait(1)
						DeleteEmitAfterDuration(clone) -- equivalent call inferred; original call site unknown
						DeleteEmitAfterDuration(clone6) -- equivalent call inferred; original call site unknown
					end)
					break
				else
					position = v9
				end
			end
		end

		ZigZag()
		task.wait(3)
		part:Destroy()
	end
end