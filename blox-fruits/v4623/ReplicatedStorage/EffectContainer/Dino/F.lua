local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local boats = workspace:FindFirstChild("Boats")
local map = workspace:FindFirstChild("Map")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local debris = Util.Debris
local sound = Util.Sound
local _ = Util.PartCache
local player = nil
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local _ = Util.CameraShaker
local FX = require(game.ReplicatedStorage.FX)
local F = FX:WaitForChild("Dino").F

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

local function GroundRocks(p, _WorldOrigin2, _, p2)
	for _ = 1, 5 do
		task.spawn(function()
			local clone = F.Rock:Clone()
			debris:AddItem(clone, 10)
			clone.Position = p.Position + Vector3.new(
				math.random(-25, 25) * 1.5,
				math.random(1, 15),
				math.random(-25, 25) * 1.5
			)
			clone.Size = Vector3.new(math.random(5, 9), math.random(3, 5), math.random(5, 9))
			clone.Material = p2.Material
			clone.Color = p2.Color
			clone.Parent = _WorldOrigin2
			rocks:ApplyCollision(clone, nil, true)
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
			).LookVector * math.random(100, 130) * 0.75
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
			task.wait(2.5 + math.random(10, 200) / 1000)
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

return function(player2)
	player = player2.player
	local ID = player2.ID

	if ID == 1 then
		local character = player2.Character
		local holdValue = player2.HoldValue

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid then
				local v = sound:Play("Gigantic Leap- Charge", humanoidRootPart, nil, 1, 1)
				v.Looped = true
				local diedConnection = nil
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
					diedConnection = nil
				end)
				tick()

				local function running()
					return diedConnection and holdValue and holdValue.Value == true
				end

				local clone = F.HoldAura:Clone()
				clone.CFrame = humanoidRootPart.CFrame
				Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player, "TRexFruitVFXColor")
				clone.Weld.Part0 = humanoidRootPart

				while diedConnection and holdValue and holdValue.Value == true and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and humanoid and character do
					task.wait(0.05)
				end

				Util.Debris:AddItem(clone, 1)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				if diedConnection then
					diedConnection:Disconnect()
					diedConnection = nil
				end

				if v then
					v:Destroy()
				end
			end
		end
	elseif ID == 2 then
		local root = player2.Root
		local startCF = player2.StartCF
		local mousePos = player2.MousePos

		if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
			return
		end

		local v = (mousePos - startCF.p) * createVector(1, 0, 1)
		local clone = F.StartImpact:Clone()
		debris:AddItem(clone, 5)
		clone.CFrame = startCF
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "TRexFruitVFXColor")
		local v2 = sound:Play("Gigantic Leap- Release", root, nil, 1, 1)
		v2.Looped = true
		sound:Play("DinoDash3", root, nil, 1 + math.random(-15, 15) / 100, 1)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		local clone2 = F.Dash:Clone()
		debris:AddItem(clone2, 8)
		clone2.CFrame = startCF
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "TRexFruitVFXColor")
		clone2.Weld.Part0 = root

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local position = startCF.Position
		local hit = player2.RayData1.Hit
		local pos = player2.RayData1.Pos
		local _ = (position - pos).Magnitude
		local v3 = math.clamp(pos.Y - position.Y, 15, 125)
		local pos2

		if hit == nil then
			pos2 = player2.RayData2.Pos
			local _ = (pos - pos2).Magnitude
			v3 += math.clamp(math.abs(pos2.Y - position.Y) / 2, 75, 1000)
		else
			pos2 = pos
		end

		local v4 = (pos2 - position).Magnitude / 2 + v3
		local magnitude = (position - pos2).Magnitude
		local v5 = (position - pos2) / 2
		local position2 = CFrame.new(CFrame.new(position) * (v5 / -1.5)).Position
		local position3 = CFrame.new(CFrame.new(pos2) * (v5 / 1.5)).Position
		local v6 = position2 + Vector3.new(0, v4, 0)
		local v7 = position3 + Vector3.new(0, v4 / 1.2, 0)
		local v8 = 0.2 + 0.8 * (magnitude / 4.5) / 60
		local v9 = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and root == game.Players.LocalPlayer.Character.HumanoidRootPart
		local v10, v11

		if v9 then
			v10 = Util.BodyMover.new(root.Parent):Create("BodyPosition", {
				Duration = v8 + 0.1,
				Position = root.Position
			})
			v11 = Util.BodyMover.new(root.Parent):Create("BodyGyro", {
				Duration = v8 + 0.1,
				CFrame = root.CFrame
			})
		end

		local lastTime = tick()

		while root.Parent and tick() - lastTime < v8 do
			local v12 = (tick() - lastTime) / v8
			local v13 = cubicBezier(v12, position, v6, v7, pos2)
			local cframe = player2.EndCF.Rotation + v13

			if ((pos2 - v13) * createVector(1, 0, 1)).Magnitude > 0.001 then
				cframe = CFrame.new(v13, pos2)
			end

			local lerped = root.CFrame:Lerp(cframe, v12)
			root.CFrame = lerped + createVector(0, 1, 0) * math.max(
				0,
				_G.getWaterHeightAtVector(lerped.Position) - lerped.Y
			)

			if v9 then
				v11:Set(root.CFrame)
				v10:Set(root.Position)
			end

			RunService.Heartbeat:Wait()
		end

		if v9 then
			v10:Destroy()
			v11:Destroy()
		end

		if not root.Parent then
			return
		end

		root.CFrame = player2.EndCF
		local cframe = CFrame.new(root.Position)
		local clone3 = F.StompImpact:Clone()
		debris:AddItem(clone3, 5)
		clone3.CFrame = cframe
		Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "TRexFruitVFXColor")

		for _, emitter in ipairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v12 = emitter
			task.spawn(function()
				if v12:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v12:GetAttribute("EmitDelay"))
				end

				v12:Emit(v12:GetAttribute("EmitCount"))
			end)
		end

		local ray = Util.Ray
		local v12 = pos2 + createVector(0, 1, 0)
		local v13 = { workspace.Characters, workspace.Enemies }
		local v14, v15, v16 = ray(v12, createVector(-0, -10, -0), v13, false)

		if not v14 then
			v14, v15, v16 = Util.Ray(pos2 - v, v * 10, { workspace.Characters, workspace.Enemies }, false)
		end

		if v2 then
			v2:Destroy()
		end

		if v14 then
			local cFrame = CFrame.new(v15, v15 + v16) * CFrame.Angles(-1.5707963267948966, 0, 0)
			sound:Play("Gigantic Leap- Explosion", cFrame.Position, nil, 1, 1.5)
			sound:Play("Transformed- Gigantic Leap Explosion_2", cFrame.Position, nil, 1, 1)

			if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 100 then
				Util.CameraShaker:ShakeOnce(17.5, 12.5, 0.01, 1)
			end

			local v19

			if boats and boats:IsA("Folder") and map and map:IsA("Model") then
				v19 = v14:IsDescendantOf(boats) and true or false
			else
				v19 = v14:IsDescendantOf(map) and v14.Parent.Name == "Tree" and true or false
			end

			if not v19 then
				local clone4 = F.Crater:Clone()
				debris:AddItem(clone4, 8)
				clone4:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 2.5, 0) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				))

				for _, child in ipairs(clone4:GetChildren()) do
					child.Material = v14.Material
					child.Color = v14.Color
				end

				clone4.Parent = _WorldOrigin
				local clone5 = F.StompGroundImpact:Clone()
				debris:AddItem(clone5, 5)
				clone5.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "TRexFruitVFXColor")

				for _, emitter in ipairs(clone5:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v20 = emitter
					task.spawn(function()
						if v20:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v20:GetAttribute("EmitDelay"))
						end

						v20:Emit(v20:GetAttribute("EmitCount"))
					end)
				end

				local clone6 = F.GroundCrack:Clone()
				debris:AddItem(clone6, 5)
				clone6.CFrame = cFrame * CFrame.new(0, 0.1, 0) * CFrame.Angles(3.141592653589793, 0, 0)
				Util.SetParentOverrideWithColor(clone6, _WorldOrigin, player, "TRexFruitVFXColor")

				for _, emitter in ipairs(clone6:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				GroundRocks(cFrame, _WorldOrigin, v15, v14)
				task.delay(4, function()
					local primaryPartCFrame = clone4:GetPrimaryPartCFrame()
					local lastTime2 = tick()

					while tick() - lastTime2 < 0.75 do
						local v20 = (tick() - lastTime2) / 0.75
						clone4:SetPrimaryPartCFrame(primaryPartCFrame * CFrame.new(0, -10 * v20, 0))
						task.wait()
					end

					clone4:Destroy()
				end)
			end
		end

		task.spawn(function()
			if clone2:FindFirstChild("Weld") then
				clone2.Weld.Enabled = false
				clone2.Anchored = true
			end

			for _, effect in ipairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
	end
end