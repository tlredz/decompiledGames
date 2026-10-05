local createVector = vector.create
local _ = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local boats = workspace:FindFirstChild("Boats")
local map = workspace:FindFirstChild("Map")
local player = nil
local FX = require(game.ReplicatedStorage.FX)
local F = FX:WaitForChild("Dino").Transformed.F
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")

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

local function GroundRocks(p, parent, _, p2)
	for _ = 1, 5 do
		task.spawn(function()
			local clone = F.Rock:Clone()
			clone.Position = p.Position + Vector3.new(
				math.random(-25, 25) * 1.5,
				math.random(1, 15),
				math.random(-25, 25) * 1.5
			)
			clone.Size = Vector3.new(math.random(5, 9), math.random(3, 5), math.random(5, 9))
			clone.Material = p2.Material
			clone.Color = p2.Color
			rocks:ApplyCollision(clone, nil, true)
			clone.Parent = parent
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			bodyVelocity.P = 3000
			Util.SetParentOverrideWithColor(bodyVelocity, clone, player, "TRexFruitVFXColor")
			bodyVelocity.Velocity = CFrame.new(
				clone.Position,
				(CFrame.new(clone.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
					0,
					0,
					-30
				)).Position + Vector3.new(math.random(-10, 10) / 5, math.random(80, 250), math.random(-10, 10) / 5)
			).LookVector * math.random(100, 130) * 4
			task.delay(0.075, function()
				bodyVelocity:Destroy()
			end)
			clone.Attachment0.Orientation = Vector3.new(
				math.random(-90, 90),
				math.random(-90, 90),
				math.random(-90, 90)
			)
			local v = math.random(60, 120)
			local v2 = math.random(60, 120)
			local v3 = math.random(60, 120)
			local v4 = v / 10
			local v5 = v2 / 10
			local v6 = v3 / 10

			for _ = 1, 6 do
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
			end

			clone.AlignOrientation:Destroy()
			task.wait(3 + math.random(10, 200) / 1000)
			local tween = TweenService:Create(clone, TweenInfo.new(0.25), {
				Size = createVector(0.1, 0.1, 0.1)
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end)
	end

	task.wait(0.5)

	for _ = 1, 7 do
		task.spawn(function()
			local clone = F.Rock:Clone()
			clone.Position = p.Position + Vector3.new(
				math.random(-25, 25) * 1.5,
				math.random(1, 15),
				math.random(-25, 25) * 1.5
			)
			clone.Size = Vector3.new(math.random(8, 15), math.random(5, 8), math.random(8, 15))
			clone.Material = p2.Material
			clone.Color = p2.Color
			rocks:ApplyCollision(clone, nil, true)
			clone.Parent = parent
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			bodyVelocity.P = 7000
			Util.SetParentOverrideWithColor(bodyVelocity, clone, player, "TRexFruitVFXColor")
			bodyVelocity.Velocity = CFrame.new(
				clone.Position,
				(CFrame.new(clone.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
					0,
					0,
					-30
				)).Position + Vector3.new(math.random(-10, 10) / 5, math.random(400, 500), math.random(-10, 10) / 5)
			).LookVector * math.random(100, 130) * 9
			task.delay(0.1, function()
				bodyVelocity:Destroy()
			end)
			clone.Attachment0.Orientation = Vector3.new(
				math.random(-90, 90),
				math.random(-90, 90),
				math.random(-90, 90)
			)
			local v = math.random(60, 120)
			local v2 = math.random(60, 120)
			local v3 = math.random(60, 120)
			local v4 = v / 10
			local v5 = v2 / 10
			local v6 = v3 / 10

			for _ = 1, 6 do
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
			end

			clone.AlignOrientation:Destroy()
			task.wait(3 + math.random(10, 200) / 1000)
			local tween = TweenService:Create(clone, TweenInfo.new(0.25), {
				Size = createVector(0.1, 0.1, 0.1)
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end)
	end
end

Util.ResizeModel(F.Dash, 1.75, F.Dash.Position)
return function(data)
	player = data.player
	local root = data.Root
	local startCF = data.StartCF
	local mousePos = data.MousePos

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1200 then
		return
	end

	local v = (mousePos - startCF.p) * createVector(1, 0, 1)
	local folder = Instance.new("Folder", _WorldOrigin)
	Util.Debris:AddItem(folder, 7)
	local clone = F.StartImpact:Clone()
	clone.CFrame = startCF
	Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")
	Util.Sound:Play("Dinosaur Roar", root, nil, 1, 1)

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

	local clone2 = F.Dash:Clone()
	clone2.CFrame = startCF
	Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")
	clone2.Weld.Part0 = root

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local position = startCF.Position
	local hit = data.RayData1.Hit
	local pos = data.RayData1.Pos
	local norm = data.RayData1.Norm
	local _ = (position - pos).Magnitude
	local v2 = math.clamp(pos.Y - position.Y, 0.15, 175)
	local pos2

	if hit == nil then
		local _ = data.RayData2.Hit
		pos2 = data.RayData2.Pos
		norm = data.RayData2.Norm
		local _ = (pos - pos2).Magnitude
		v2 += math.clamp(math.abs(pos2.Y - position.Y) / 2, 75, 1000)
	else
		pos2 = pos
	end

	local v3 = (pos2 - position).Magnitude / 2 + v2
	local magnitude = (position - pos2).Magnitude
	local v4 = (position - pos2) / 2
	local position2 = CFrame.new(CFrame.new(position) * (v4 / -1.5)).Position
	local position3 = CFrame.new(CFrame.new(pos2) * (v4 / 1.5)).Position
	local v5 = position2 + Vector3.new(0, v3, 0)
	local v6 = position3 + Vector3.new(0, v3 / 1.2, 0)
	local v7 = 0.2 + 0.8 * (magnitude / 4.5) / 60
	local v8 = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and root == game.Players.LocalPlayer.Character.HumanoidRootPart
	local v9, v10

	if v8 then
		v9 = Util.BodyMover.new(root.Parent):Create("BodyPosition", {
			Duration = v7 + 0.1,
			Position = root.Position
		})
		v10 = Util.BodyMover.new(root.Parent):Create("BodyGyro", {
			Duration = v7 + 0.1,
			CFrame = root.CFrame
		})
	else
		v10 = nil
		v9 = nil
	end

	local waterHeightAtVector = _G.getWaterHeightAtVector(position)
	local lastTime = tick()
	local flag = false

	while tick() - lastTime < v7 do
		local v11 = (tick() - lastTime) / v7
		local v12 = cubicBezier(v11, position, v5, v6, pos2)
		root.CFrame = root.CFrame:Lerp(CFrame.new(v12, pos2), v11)

		if v8 then
			v10:Set(root.CFrame)
			v9:Set(root.Position)
		end

		if root.Position.Y < waterHeightAtVector then
			flag = true
			break
		else
			RunService.Heartbeat:Wait()
		end
	end

	pcall(function()
		v9:Destroy()
		v10:Destroy()
	end)

	if flag then
		root.CFrame = CFrame.new(root.Position, root.Position + root.CFrame.LookVector * createVector(1, 0, 1))
	else
		root.CFrame = CFrame.new(pos2, pos2 + v) + norm * data.Height
	end

	local cframe = CFrame.new(root.Position, root.Position + startCF.LookVector * createVector(1, 0, 1))
	local clone3 = F.StompImpact:Clone()
	clone3.CFrame = cframe
	Util.SetParentOverrideWithColor(clone3, folder, player, "TRexFruitVFXColor")

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v11 = emitter
		task.spawn(function()
			if v11:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v11:GetAttribute("EmitDelay"))
			end

			v11:Emit(v11:GetAttribute("EmitCount"))
		end)
	end

	local ray = Util.Ray
	local v11 = pos2 + createVector(0, 1, 0)
	local v12 = { workspace.Characters, workspace.Enemies }
	local v13, v14, v15 = ray(v11, createVector(-0, -10, -0), v12, false)

	if not v13 then
		v13, v14, v15 = Util.Ray(pos2 - v, v * 10, { workspace.Characters, workspace.Enemies }, false)
	end

	if v13 then
		local cFrame = CFrame.new(v14, v14 + v15) * CFrame.Angles(-1.5707963267948966, 0, 0)
		Util.Sound:Play("Transformed- Gigantic Leap Explosion_2", cFrame.Position, nil, 1, 1)
		Util.Sound:Play("Gigantic Leap- Explosion", cFrame.Position, nil, 1, 1.5)

		if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 150 then
			Util.CameraShaker:ShakeOnce(20, 15, 0.01, 1)
		end

		local v18

		if boats and boats:IsA("Folder") and map and map:IsA("Model") then
			v18 = v13:IsDescendantOf(boats) and true or false
		else
			v18 = v13:IsDescendantOf(map) and v13.Parent.Name == "Tree" and true or false
		end

		if not v18 then
			local clone4 = F.Crater:Clone()
			clone4:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 2.5, 0) * CFrame.Angles(
				0,
				math.rad((math.random(-180, 180))),
				0
			))

			for _, child in pairs(clone4:GetChildren()) do
				child.Material = v13.Material
				child.Color = v13.Color
			end

			clone4.Parent = folder
			task.delay(4, function()
				local primaryPartCFrame = clone4:GetPrimaryPartCFrame()
				local lastTime2 = tick()

				while tick() - lastTime2 < 0.75 do
					local v19 = (tick() - lastTime2) / 0.75
					clone4:SetPrimaryPartCFrame(primaryPartCFrame * CFrame.new(0, -16 * v19, 0))
					task.wait()
				end

				clone4:Destroy()
			end)
			local clone5 = F.StompGroundImpact:Clone()
			Util.Debris:AddItem(clone5, 20)
			clone5.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone5, folder, player, "TRexFruitVFXColor")

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v19 = emitter
				task.spawn(function()
					if v19:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v19:GetAttribute("EmitDelay"))
					end

					v19:Emit(v19:GetAttribute("EmitCount"))
				end)
			end

			local clone6 = F.GroundCrack:Clone()
			Util.Debris:AddItem(clone6, 20)
			clone6.CFrame = cFrame * CFrame.new(0, 0.1, 0) * CFrame.Angles(3.141592653589793, 0, 0)
			Util.SetParentOverrideWithColor(clone6, folder, player, "TRexFruitVFXColor")

			for _, emitter in pairs(clone6:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.spawn(function()
				task.wait(0.1)
				local clone7 = F.LavaExplosion:Clone()
				clone7.CFrame = clone4.PrimaryPart.CFrame
				Util.SetParentOverrideWithColor(clone7, folder, player, "TRexFruitVFXColor")

				for _, descendant in pairs(clone7:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") then
						if descendant:IsDescendantOf(clone7.LavaStart) then
							local v19 = descendant
							task.spawn(function()
								task.wait(math.random(1, 10) / 100)
								v19.Enabled = true
								task.wait(0.5)
								v19.Enabled = false
							end)
						else
							local v19 = descendant
							task.spawn(function()
								task.wait(0.5)

								if v19:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v19:GetAttribute("EmitDelay"))
								end

								v19:Emit(v19:GetAttribute("EmitCount"))
							end)
						end
					elseif descendant:IsA("PointLight") then
						local tween = TweenService:Create(
							descendant,
							TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1),
							{
								Brightness = descendant.Brightness
							}
						)
						descendant.Brightness = 0
						tween:Play()
						local v19 = descendant
						task.spawn(function()
							task.wait(0.3)
							tween = TweenService:Create(
								v19,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Brightness = 0
								}
							)
							tween:Play()
						end)
					end
				end
			end)
			task.delay(0.5, function()
				if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 150 then
					Util.CameraShaker:ShakeOnce(27.5, 22.5, 0.01, 1)
				end
			end)
			local random = Random.new(data.Seed)

			for _ = 1, 10 do
				task.spawn(function()
					local integer = random:NextInteger(35, 70)
					local integer2 = random:NextInteger(-180, 180)
					local clone7 = F.GroundLavaCrack:Clone()
					clone7.CFrame = cFrame * CFrame.Angles(0, math.rad(integer2), 0)
					clone7.CFrame *= CFrame.new(30, 0, 0)
					Util.SetParentOverrideWithColor(clone7, folder, player, "TRexFruitVFXColor")

					for _, effect in pairs(clone7:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					local tween = TweenService:Create(
						clone7,
						TweenInfo.new(0.3333333333333333, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone7.CFrame * CFrame.new(integer, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()

					for _, effect in pairs(clone7:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					local clone8 = F.GroundLavaCrackExplosion:Clone()
					clone8.CFrame = clone7.CFrame
					Util.SetParentOverrideWithColor(clone8, folder, player, "TRexFruitVFXColor")
					Util.Sound:Play(
						"Reptilian Scales- Meteor Explode",
						clone8.Position,
						nil,
						1 + math.random(-15, 15) / 100,
						1
					)

					for _, emitter in pairs(clone8:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end
				end)
			end
		end
	end

	task.spawn(function()
		clone2.Weld.Enabled = false
		clone2.Anchored = true

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end
	end)
end