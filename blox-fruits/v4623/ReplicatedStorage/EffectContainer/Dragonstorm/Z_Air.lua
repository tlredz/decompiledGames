local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local z_Air = FX:WaitForChild("Dragonstorm").Z_Air
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local random = Random.new()

local function ParticleState(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil then
			if effect:IsA("ParticleEmitter") then
				effect:Emit(effect:GetAttribute("EmitCount"))
			end
		else
			effect.Enabled = enabled
		end
	end
end

Util.ResizeModel(z_Air.Start, 0.5)
Util.ResizeModel(z_Air.Charge, 0.4)
Util.ResizeModel(z_Air.Fire1, 0.4)
Util.ResizeModel(z_Air.Fire2, 0.4)
Util.ResizeModel(z_Air.Pillar, 0.2)
Util.ResizeModel(z_Air.StartShot, 0.7)
Util.ResizeModel(z_Air.Flame, 0.7)
return function(data)
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1000 then
		return
	end

	if data.Stage == 1 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		folder.Parent = _WorldOrigin
		local holding = data.Holding
		local HRP = data.HRP
		local clone = z_Air.Start:Clone()
		clone.CFrame = HRP.CFrame
		clone.Parent = folder
		ParticleState(clone)
		sound:Play("DragonStorm_Z_Air_ChargeStart_01", clone.Position)
		local clone2 = z_Air.Charge:Clone()
		clone2.Size = createVector(6.6666665, 6.6666665, 6.6666665)
		clone2.Position = HRP.Position
		clone2.Parent = folder
		local clone3 = z_Air.Fire1:Clone()
		clone3.Size /= 1.5
		clone3.Weld.Part0 = HRP
		clone3.Parent = folder
		local clone4 = nil
		local v = false
		local clone5 = nil
		local v2 = nil
		task.spawn(function()
			task.wait(0.6)

			if not v then
				clone3.Attachment.ParticleEmitter.Enabled = true
			end

			task.wait(0.2)

			if not v then
				clone4 = z_Air.Fire2:Clone()
				clone3.Size /= 1.5
				clone4.Weld.Part0 = HRP
				clone4.Parent = folder
				clone5 = z_Air.Pillar:Clone()
				clone5.Position = HRP.Position
				clone5.Parent = folder
				sound:Play("DragonStorm_Z_Air_Charge_MaxPowerIndicator_0", clone5.Position)
				v2 = sound:Play("DragonStorm_X_Charge_Loop_01", HRP)
				TweenService:Create(v2, TweenInfo.new(0.2), {
					Volume = 1
				}):Play()
			end
		end)

		repeat
			task.wait()
		until not (holding and holding.Value)

		v = true

		if v2 then
			sound:FadeOut(v2, 0.2)
		end

		clone3:Destroy()

		if clone4 then
			for _, effect in clone4.LeftEnabled:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			for _, effect in clone4.RightEnable:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			ParticleState(clone4.Right)
			ParticleState(clone4.Left)
			ParticleState(clone4.Attachment)
		end

		for _, effect in clone2:GetDescendants() do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		if clone5 then
			for _, effect in clone5:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end

		task.wait(4)
		folder:Destroy()
	else
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		folder.Parent = _WorldOrigin
		local HRP = data.HRP
		local clone = z_Air.Flame:Clone()
		clone.Weld.Part0 = HRP
		clone.Parent = folder

		if data.Dragons > 6 then
			sound:Play("DragonStorm_Z_Air_Fire_12Heads_01", HRP)
		else
			sound:Play("DragonStorm_Z_Air_Fire_6Heads_01", HRP)
		end

		for i = 1, data.Dragons do
			local v = i
			task.spawn(function()
				local v2 = data.DragonData[v]

				if not v2 then
					warn("Data does not exist for Dragon Head!")
					return
				end

				local clone2 = z_Air.StartShot:Clone()
				clone2.CFrame = HRP.CFrame * CFrame.new(0, 0, -3)
				clone2.Parent = folder
				ParticleState(clone2)
				local player = data.player
				local Players = game:GetService("Players")

				if player == Players.LocalPlayer then
					Effect.new("ShakeCam"):play({
						6,
						10,
						0.05,
						0.2
					})
				end

				local clone3 = z_Air.Dragon:Clone()
				local rootPart = clone3.RootPart
				rootPart.CFrame = clone.CFrame
				clone3.Parent = folder
				local position = v2.Lerps[1]
				local lerp = v2.Lerps[2]
				local position2 = v2.Lerps[3]
				local lerp2 = v2.Lerps[4]
				local dragonSpeed = v2.DragonSpeed
				local v3 = (position - lerp).Magnitude + (lerp - position2).Magnitude + (position2 - lerp2).Magnitude
				local v4 = position
				local v5 = nil
				local v6 = v2.TargetRoot

				if not v2.TargetRoot then
					if v2.ForceExplode then
						v6 = Instance.new("Part")
						v6.Size = createVector(2, 2, 2)
						v6.Position = v2.ForceExplode
						v6.Anchored = true
						v6.CanCollide = false
						v6.Transparency = 1
						v6.Parent = folder
					else
						clone3:Destroy()
						clone2:Destroy()
						return
					end
				end

				local v7 = clone3:GetScale() * 0.7
				local lastTime = tick()

				while tick() - lastTime < v2.Displacement + 0.18000000000000002 do
					local v8 = (tick() - lastTime) / (v2.Displacement + 0.18000000000000002)
					local v9 = position
					local v10 = v9 + (lerp - v9) * v8
					local v11 = lerp
					local v12 = v11 + (position2 - v11) * v8
					local v13 = position2
					local v14 = v13 + (lerp2 - v13) * v8
					local v15 = v10 + (v12 - v10) * v8
					v5 = v15 + (v12 + (v14 - v12) * v8 - v15) * v8
					rootPart.CFrame = CFrame.lookAt(v5, v4) * CFrame.Angles(0, 3.141592653589793, 0)
					RunService.Heartbeat:Wait()
					v4 = v5
				end

				clone3:ScaleTo(v7)
				local v8 = false
				local stateProxy = v2.StateProxy

				if not stateProxy then
					warn("StateProxy does not exist for Dragon Head!")
					return
				end

				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					if not (v6 and rootPart) then
						rootPart.CFrame *= CFrame.new(0, 0, -dt * dragonSpeed)
						return
					end

					heartbeatConnection:Disconnect()
					position = rootPart.Position
					lerp = rootPart.Position + rootPart.CFrame.LookVector * v2.LookVector
					position2 = v6.Position
					local v9 = ((position - lerp).Magnitude + (lerp - position2).Magnitude) / dragonSpeed
					local lastTime2 = os.clock()

					while os.clock() - lastTime2 < v9 do
						local v10 = (os.clock() - lastTime2) / v9

						if v8 == false then
							if stateProxy:GetAttribute("Active") then
								position2 = stateProxy.Value
								local clone4 = z_Air.Target:Clone()
								clone4.Position = position2
								clone4.Parent = folder
								ParticleState(clone4)
								v8 = true
							else
								position2 = v6.Position
								local v11 = (position - lerp).Magnitude + (lerp - position2).Magnitude
							end
						end

						local v11 = position
						local v12 = v11 + (lerp - v11) * v10
						local v13 = lerp
						v5 = v12 + (v13 + (position2 - v13) * v10 - v12) * v10

						if v4 ~= v5 then
							rootPart.CFrame = CFrame.lookAt(v5, v4) * CFrame.Angles(0, 3.141592653589793, 0)
						end

						v4 = v5
						task.wait()
					end

					rootPart.Position = position2

					for i2, effect in clone3:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					for i2, part in clone3:GetChildren() do
						if part:IsA("BasePart") then
							TweenService:Create(
								part,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end
					end

					local clone4 = z_Air.DragonExplode:Clone()
					clone4.Position = rootPart.Position + Vector3.new(
						random:NextNumber(-3, 3),
						random:NextNumber(-3, 3),
						random:NextNumber(-3, 3)
					)
					clone4.Parent = folder
					sound:Play("DragonStorm_Z_Air_Explosion_0" .. tostring(math.random(1, 6)), clone4.Position)

					for i2 = 1, random:NextInteger(4, 7) do
						local clone5 = z_Air.DragonCrackle:Clone()
						clone5.Position = clone4.Position
						clone5.Parent = folder
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Velocity = Vector3.new(
							random:NextNumber(-1, 1),
							random:NextNumber(-1, 1),
							random:NextNumber(-1, 1)
						) * random:NextNumber(150, 270)
						bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
						bodyVelocity.Parent = clone5
						local number = random:NextNumber(0.1, 0.3)
						TweenService:Create(
							bodyVelocity,
							TweenInfo.new(number, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Velocity = bodyVelocity.Velocity * random:NextNumber(0.2, 0.4)
							}
						):Play()
						local folder2 = clone5
						task.delay(number, function()
							bodyVelocity:Destroy()
							task.wait(random:NextNumber(0.3, 0.5))

							for i3, effect in folder2:GetDescendants() do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end)
					end

					ParticleState(clone4)
				end)
				task.wait(random:NextNumber(0.5, 0.9))

				if v8 == false then
					heartbeatConnection:Disconnect()

					for i2, effect in clone3:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					for i2, part in clone3:GetChildren() do
						if part:IsA("BasePart") then
							part.Transparency = 1
						end
					end
				end
			end)
			task.wait(data.FireRate)
		end

		for _, effect in clone:GetDescendants() do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		task.wait(5)
		folder:Destroy()
	end
end