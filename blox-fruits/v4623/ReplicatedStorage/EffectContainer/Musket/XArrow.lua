local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local musket_X = FX:WaitForChild("Musket").Musket_X
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function ParticleState(folder, enabled, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end
	end
end

local random = Random.new()

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

return function(player)
	local origin = player.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	if player.stage == 1 then
		local tool = player.tool
		local holding = player.holding or tool and tool:FindFirstChild("Holding")

		if not (holding and holding.Value) then
			return
		end

		local hrp = player.hrp
		local folder = Instance.new("Folder")
		folder.Name = "MusketArrowHoldEffect_" .. hrp.Parent.Name
		folder.Parent = _WorldOrigin
		local attachment = player.attachment or Util.GetEquippedAttachment(player.Character, player.Attachment)
		local clone = musket_X.ArrowModel:Clone()
		local fireArrow = clone.FireArrow
		clone:ScaleTo(0.3)
		local v

		if attachment then
			v = attachment.WorldCFrame
		else
			v = hrp.CFrame
		end

		fireArrow.CFrame = v * CFrame.new(0, 0, -5)
		clone.Parent = folder
		local v2 = sound:Play("BF_WPN_Musket_X_Hold_01", fireArrow)

		while (tool or holding) and holding and holding.Value and hrp and fireArrow and folder do
			local v3

			if attachment then
				v3 = attachment.WorldCFrame
			else
				v3 = hrp.CFrame
			end

			fireArrow.CFrame = v3 * CFrame.new(0, 0, -5)
			task.wait()
		end

		if v2 then
			sound:FadeOut(v2, 0.2)
		end

		Util.Debris:AddItem(folder, 3)
	elseif player.stage == 2 then
		local arrowSpeed = player.arrowSpeed
		local _ = player.arrowLifetime
		local parent = _WorldOrigin:FindFirstChild("MusketArrowHoldEffect_" .. player.id)
		local arrowModel

		if parent then
			parent.Name = "MusketArrowEffect"
			arrowModel = parent.ArrowModel
		else
			parent = Instance.new("Folder")
			parent.Name = "MusketArrowEffect"
			parent.Parent = _WorldOrigin
			arrowModel = musket_X.ArrowModel:Clone()
			arrowModel.Parent = parent
		end

		Util.Debris:AddItem(parent, 10)
		local fireArrow = arrowModel.FireArrow
		arrowModel:ScaleTo(1)
		fireArrow.CFrame = CFrame.lookAt(player.origin, player.targetPos) * CFrame.new(0, 0, -5)
		local clone = musket_X.Start:Clone()
		clone.CFrame = player.startCFrame
		clone.Parent = parent

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		Util.Sound:Play("BF_WPN_Musket_X_Fire_0" .. tostring(math.random(1, 2)), clone.Position)

		if player.hrp == game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			Effect.new("ShakeCam"):play({
				8,
				12,
				0.05,
				0.2
			})
		end

		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Brightness = 0,
			Range = 0
		}):Play()
		local lastTime = tick()

		while tick() - lastTime < player.arrowDuration do
			local v2 = task.wait()
			fireArrow.CFrame *= CFrame.new(0, 0, -arrowSpeed * v2)
		end

		local clone2 = musket_X.ArrowBreak:Clone()
		clone2.CFrame = fireArrow.CFrame * CFrame.new(0, 0, -6)
		clone2.Parent = parent

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		for _, emitter in pairs(fireArrow:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, beam in fireArrow:GetDescendants() do
			if beam:IsA("Beam") then
				beam:Destroy()
			end
		end

		TweenService:Create(clone2.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()
		task.wait(3)
		parent:Destroy()
	elseif player.stage == 3 then
		local windupTime = player.windupTime
		local folder = Instance.new("Folder")
		folder.Name = "MusketExplosionEffect"
		folder.Parent = _WorldOrigin
		local clone = musket_X.MainWindup:Clone()
		clone.Position = player.origin
		clone.Parent = folder
		local clone2 = musket_X.WindUpExplosion:Clone()
		clone2.Position = player.origin
		clone2.Parent = folder

		if player.hitPos then
			task.spawn(function()
				for _ = 1, 5 do
					task.spawn(function()
						local clone3 = musket_X.Beams:Clone()
						clone3.CFrame = CFrame.lookAt(clone2.Position, clone2.Position + player.normal) * CFrame.new(
							0,
							0,
							-random:NextNumber(5, 15)
						) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586))
						clone3.Parent = folder
						local number = random:NextNumber(10, 20)
						clone3.Beam.Width0 = number
						clone3.Beam.Width1 = number
						local number2 = random:NextNumber(10, 20)
						clone3.Beam.CurveSize0 = number2 * 1.3636363636363635
						clone3.Beam.CurveSize1 = -number2 * 1.3636363636363635
						clone3.A.Position = Vector3.new(-number2, 0, 0)
						clone3.B.Position = Vector3.new(number2, 0, 0)
						local number3 = random:NextNumber(0.1, 0.3)
						TweenService:Create(
							clone3,
							TweenInfo.new(number3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
							{
								CFrame = clone3.CFrame * CFrame.Angles(0, 0, 2.827433388230814)
							}
						):Play()
						TweenService:Create(clone3.Beam, TweenInfo.new(number3, Enum.EasingStyle.Linear), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
					task.wait(random:NextNumber(0.015, 0.03))
				end
			end)
		end

		task.wait(windupTime)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0,
			Brightness = 0
		}):Play()
		local clone3 = musket_X.Explode:Clone()
		clone3.CFrame = clone.CFrame
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		Util.Sound:Play("BF_WPN_Musket_X_Explosion_0" .. tostring(math.random(1, 2)), clone3.Position)

		if (currentCamera.CFrame.Position - clone3.Position).Magnitude <= 90 then
			local clone4 = musket_X.ColorCorrection:Clone()
			clone4.Parent = game:GetService("Lighting")
			TweenService:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				TintColor = Color3.new(1, 1, 1),
				Brightness = 0
			}):Play()
			Effect.new("ShakeCam"):play({
				20,
				10,
				0.1,
				0.5
			})
			task.delay(0.3, clone4.Destroy, clone4)
		end

		TweenService:Create(clone3.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Brightness = 0,
			Range = 0
		}):Play()

		if player.hitPos then
			local clone4 = musket_X.FloorFire:Clone()
			clone4.CFrame = CFrame.lookAt(clone.Position, clone.Position + player.normal)
			clone4.Parent = folder
			task.spawn(function()
				local lastTime = os.clock()
				local lastTime2 = os.clock()

				while true do
					if os.clock() - lastTime2 >= random:NextNumber(0.015, 0.02) then
						lastTime2 = os.clock()
						local clone5 = musket_X.FireTrailWindup:Clone()
						local v = clone4.Position + Vector3.new(
							random:NextNumber(-20, 20),
							0,
							random:NextNumber(-20, 20)
						)
						local number = random:NextNumber(0, 360)
						local number2 = random:NextNumber(800, 1400)
						local number3 = random:NextNumber(80, 120)
						local total = 0
						local number4 = random:NextNumber(2, 7)
						local v2 = math.sin((math.rad(number))) * number4
						local v3 = math.cos((math.rad(number))) * number4
						clone5.Position = v + Vector3.new(v2, total, v3)
						clone5.Parent = folder
						local heartbeatConnection = nil
						local v4 = os.clock()
						local v5 = random:NextNumber(0.15, 0.3)
						heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
							if v5 <= os.clock() - v4 then
								heartbeatConnection:Disconnect()
								local folder2 = clone5

								for i, emitter in pairs(folder2:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end

								task.wait(3)
								clone5:Destroy()
							end

							number += number2 * dt
							total += number3 * dt
							clone5.Position = v + Vector3.new(
								math.sin((math.rad(number))) * number4,
								total,
								math.cos((math.rad(number))) * number4
							)
						end)
					end

					task.wait()

					if not (os.clock() - lastTime >= 0.2) then
						continue
					end

					task.wait(2.8)
					local folder2 = clone4

					for _, emitter in pairs(folder2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					break
				end
			end)
		end

		task.wait(5)
		folder:Destroy()
	end
end