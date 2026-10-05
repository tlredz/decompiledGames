local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local kabucha_Z = FX:WaitForChild("Kabucha").Kabucha_Z
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Rock2 = require(ReplicatedStorage.Util.Rock2)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

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

for _, child in pairs(kabucha_Z:GetChildren()) do
	if child:IsA("BasePart") then
		Util.ResizeModel(child, 1.5, child.Position)
	elseif child:IsA("Model") then
		child:ScaleTo(1.5)
	end
end

return function(data)
	local origin = data.origin
	local _ = data.dir

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	if data.stage == 1 then
		local tool = data.tool
		local holding = data.holding or tool and tool:FindFirstChild("Holding")
		local hrp = data.hrp
		local holdKey = data.holdKey

		if not holdKey then
			if typeof(data.player) == "Instance" and data.player:IsA("Player") then
				holdKey = tostring(data.player.UserId)
			else
				holdKey = tostring(hrp)
			end
		end

		local folder = Instance.new("Folder")
		folder.Name = "KabuchaZHoldEffect_" .. holdKey
		folder.Parent = _WorldOrigin
		local clone = kabucha_Z.PlayerChargeup:Clone()
		clone.Position = hrp.Position + createVector(0, -3, 0)
		clone.Parent = folder
		local clone2 = kabucha_Z.BirdApear:Clone()
		clone2.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
		clone2.Parent = folder
		TweenService:Create(clone2.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0
		}):Play()

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone3 = kabucha_Z.FireBird:Clone()
		clone3.CFrame = hrp.CFrame * CFrame.new(0, 3, -7)
		clone3.Parent = folder
		local now = tick()
		local player = data.player
		local Players = game:GetService("Players")
		local clone4

		if player == Players.LocalPlayer then
			clone4 = kabucha_Z.Screen:Clone()
			clone4.Parent = folder
			RunService:BindToRenderStep(
				"Flame Camera Effect" .. tostring(now),
				Enum.RenderPriority.Camera.Value,
				function()
					clone4.CFrame = workspace.CurrentCamera.CFrame
				end
			)
		else
			clone4 = nil
		end

		local v = sound:Play("BF_WPN_Kabucha_BlazingPhoenix_Hold_01_V2", hrp)

		while (tool or holding) and holding and holding.Value do
			task.wait()

			if clone3 then
				clone3.CFrame = hrp.CFrame * CFrame.new(0, 3, -7)
			end
		end

		if v then
			sound:FadeOut(v, 1)
		end

		task.spawn(function()
			if clone4 then
				local folder2 = clone4

				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(0.6)
				RunService:UnbindFromRenderStep("Flame Camera Effect" .. tostring(now))
				clone4:Destroy()
			end
		end)
		Util.Debris:AddItem(folder, 15)
	elseif data.stage == 2 then
		local holdKey = data.holdKey

		if not holdKey then
			if typeof(data.player) == "Instance" and data.player:IsA("Player") then
				holdKey = tostring(data.player.UserId)
			else
				holdKey = tostring(data.hrp)
			end
		end

		local parent = _WorldOrigin:FindFirstChild("KabuchaZHoldEffect_" .. holdKey)
		local projectileSpeed = data.projectileSpeed
		local fireBird

		if parent then
			parent.Name = "BizarreZEffect"
			fireBird = parent.FireBird
			fireBird.CFrame = data.startCFrame
			local playerChargeup = parent.PlayerChargeup
			TweenService:Create(playerChargeup.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Range = 0
			}):Play()

			for _, emitter in pairs(playerChargeup:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		else
			parent = Instance.new("Folder")
			parent.Name = "BizarreZEffect"
			parent.Parent = _WorldOrigin
			fireBird = kabucha_Z.Projectile:Clone()
			fireBird.CFrame = data.startCFrame
			fireBird.Parent = parent
		end

		for _, emitter in pairs(fireBird:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		sound:Play("BF_WPN_Kabucha_BlazingPhoenix_Activate_01_V2", fireBird)
		sound:Play("BF_WPN_Kabucha_BlazingPhoenix_Fire_01_V2", fireBird.Position)
		local clone = kabucha_Z.BirdShoot:Clone()
		clone.CFrame = data.startCFrame
		clone.Parent = parent
		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Range = 0
		}):Play()

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		workspace:Raycast(fireBird.Position, createVector(0, -10, 0), raycastParams)
		workspace:Raycast(fireBird.Position, fireBird.CFrame.RightVector * 20, raycastParams)
		workspace:Raycast(fireBird.Position, fireBird.CFrame.RightVector * -20, raycastParams)
		local lastTime = tick()
		local duration = data.duration or 2
		local clone2 = nil
		local clone3 = nil
		local position = nil
		local v2 = false
		local v3 = false

		while tick() - lastTime < duration and data.follow:IsDescendantOf(workspace._WorldOrigin) do
			local v4 = task.wait()

			if not data.follow or data.follow:GetAttribute("Destroying") then
				break
			end

			fireBird.CFrame *= CFrame.new(0, 0, -projectileSpeed * v4)
			local raycastResult = workspace:Raycast(fireBird.Position, createVector(0, -10, 0), raycastParams)

			if raycastResult then
				if position then
					if (raycastResult.Position - position).Magnitude >= 18 and (raycastResult.Position - position).Magnitude <= 25 then
						local clone4 = kabucha_Z.FloorFire:Clone()
						clone4.CFrame = CFrame.lookAt((raycastResult.Position + position) / 2, raycastResult.Position)
						clone4.Size = Vector3.new(36, 0.1, (raycastResult.Position - position).Magnitude)
						clone4.Parent = parent
						task.delay(2, function()
							local folder = clone4

							for i, emitter in pairs(folder:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							TweenService:Create(clone4.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
								Brightness = 0
							}):Play()
						end)
						position = raycastResult.Position
					elseif (raycastResult.Position - position).Magnitude >= 25 then
						position = raycastResult.Position
					end
				else
					position = raycastResult.Position
				end
			end

			local raycastResult2 = workspace:Raycast(fireBird.Position, fireBird.CFrame.RightVector * 20, raycastParams)
			local raycastResult3 = workspace:Raycast(
				fireBird.Position,
				fireBird.CFrame.RightVector * -20,
				raycastParams
			)

			if raycastResult3 then
				if v2 == false then
					if not clone3 then
						clone3 = kabucha_Z.Trails:Clone()
						clone3.Parent = parent
					end

					v2 = true

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end

				clone3.CFrame = CFrame.lookAt(raycastResult3.Position, raycastResult3.Position + raycastResult3.Normal)
			elseif v2 == true then
				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				v2 = false
			end

			if raycastResult2 then
				if v3 == false then
					if not clone2 then
						clone2 = kabucha_Z.Trails:Clone()
						clone2.Parent = parent
					end

					v3 = true

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end

				clone2.CFrame = CFrame.lookAt(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal)
			elseif v3 == true then
				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				v3 = false
			end
		end

		for _, emitter in pairs(fireBird:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		if fireBird:FindFirstChild("PointLight") then
			TweenService:Create(fireBird.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Brightness = 0
			}):Play()
		end

		if clone2 then
			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		if clone3 then
			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		task.wait(4)
		parent:Destroy()
	elseif data.stage == 3 then
		local folder = Instance.new("Folder")
		folder.Name = "KabuchaZExplosion"
		folder.Parent = _WorldOrigin
		local targetPosition = data.targetPosition
		local clone = kabucha_Z.BirdImpact:Clone()
		clone.CFrame = CFrame.lookAt(targetPosition, targetPosition + data.nor)
		clone.Parent = folder
		TweenService:Create(clone.BigPointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Brightness = 0
		}):Play()
		task.spawn(function()
			for _ = 1, 5 do
				task.spawn(function()
					local clone2 = kabucha_Z.Beams:Clone()
					clone2.CFrame = CFrame.lookAt(targetPosition, targetPosition + data.nor) * CFrame.new(
						0,
						0,
						-random:NextNumber(5, 15)
					) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586))
					clone2.Parent = folder
					local number = random:NextNumber(25, 40)
					clone2.MainSlash.Width0 = number
					clone2.MainSlash.Width1 = number
					local number2 = random:NextNumber(20, 30)
					clone2.MainSlash.CurveSize0 = number2 * 1.3636363636363635
					clone2.MainSlash.CurveSize1 = -number2 * 1.3636363636363635
					clone2.A.Position = Vector3.new(-number2, 0, 0)
					clone2.B.Position = Vector3.new(number2, 0, 0)
					local number3 = random:NextNumber(0.1, 0.3)
					TweenService:Create(
						clone2,
						TweenInfo.new(number3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							CFrame = clone2.CFrame * CFrame.Angles(0, 0, 2.827433388230814)
						}
					):Play()
					TweenService:Create(clone2.MainSlash, TweenInfo.new(number3, Enum.EasingStyle.Linear), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end)
				task.wait(random:NextNumber(0.02, 0.1))
			end
		end)
		task.spawn(function()
			sound:Play("BF_WPN_Kabucha_Z_Boom_01_V2", targetPosition)

			for _ = 1, 3 do
				task.spawn(function()
					local clone2 = kabucha_Z.PostExplosionFire:Clone()
					local position = targetPosition
					local v2 = targetPosition + data.nor * random:NextNumber(30, 65) + Vector3.new(
						random:NextNumber(-50, 50),
						random:NextNumber(-50, 50),
						random:NextNumber(-50, 50)
					)
					local v3 = targetPosition + data.nor * random:NextNumber(30, 65) + Vector3.new(
						random:NextNumber(-50, 50),
						random:NextNumber(-50, 50),
						random:NextNumber(-50, 50)
					)
					local position2 = targetPosition
					clone2.Position = position
					clone2.Parent = folder
					local lastTime = tick()

					while tick() - lastTime < 0.3 do
						local v5 = (tick() - lastTime) / 0.3
						local v6 = position + (v2 - position) * v5
						local v7 = v2 + (v3 - v2) * v5
						local v8 = v3 + (position2 - v3) * v5
						local v9 = v6 + (v7 - v6) * v5
						clone2.Position = v9 + (v7 + (v8 - v7) * v5 - v9) * v5
						task.wait()
					end

					clone2.Position = position2

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					clone2.PointLight:Destroy()
				end)
			end

			local clone2 = kabucha_Z.PostExplosionFire:Clone()
			local position3 = targetPosition
			local v2 = targetPosition + data.nor * random:NextNumber(30, 65) + Vector3.new(
				random:NextNumber(-50, 50),
				random:NextNumber(-50, 50),
				random:NextNumber(-50, 50)
			)
			local v3 = targetPosition + data.nor * random:NextNumber(30, 65) + Vector3.new(
				random:NextNumber(-50, 50),
				random:NextNumber(-50, 50),
				random:NextNumber(-50, 50)
			)
			local position4 = targetPosition
			clone2.Position = position3
			clone2.Parent = folder
			local lastTime = tick()

			while tick() - lastTime < 0.3 do
				local v5 = (tick() - lastTime) / 0.3
				local v6 = position3 + (v2 - position3) * v5
				local v7 = v2 + (v3 - v2) * v5
				local v8 = v3 + (position4 - v3) * v5
				local v9 = v6 + (v7 - v6) * v5
				clone2.Position = v9 + (v7 + (v8 - v7) * v5 - v9) * v5
				task.wait()
			end

			clone2.Position = position4

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone2.PointLight:Destroy()
			local clone3 = kabucha_Z.Explode:Clone()
			clone3.CFrame = clone.CFrame
			clone3.Parent = folder

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			if (currentCamera.CFrame.Position - clone3.Position).Magnitude <= 90 then
				local clone4 = kabucha_Z.ColorCorrection:Clone()
				clone4.Parent = game:GetService("Lighting")
				TweenService:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					TintColor = Color3.new(1, 1, 1),
					Brightness = 0
				}):Play()
				Effect.new("ShakeCam"):play({
					20,
					10,
					0.1,
					0.3
				})
				task.delay(0.3, clone4.Destroy, clone4)
			end

			task.wait(1.1)
			TweenService:Create(clone3.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Brightness = 0
			}):Play()

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Range = 0
			}):Play()
			local folder2 = clone

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			if data.wasHit then
				local clone4 = kabucha_Z.Volcanoe:Clone()
				clone4.CFrame = CFrame.lookAt(targetPosition + data.nor * 0.123, targetPosition + data.nor)
				clone4.Parent = folder

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				task.spawn(function()
					local v5 = targetPosition + createVector(0, 1, 0)

					for i = 1, 18 do
						local v7 = CFrame.new(v5, v5 + data.nor * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
							0,
							math.rad(i * 20),
							0
						) * CFrame.new(0, 0, -28)
						local ray, v8, v9 = Util.Ray(
							v7.Position,
							v7.upVector.Unit * -30,
							{ workspace.Characters, workspace.Enemies },
							false
						)

						if not ray then
							continue
						end

						local v10 = Rock2.new({
							FadeIn = { 0.1, 0.3 },
							Lifetime = math.random(25, 30) / 10,
							FadeOut = { 0.4, 0.5 },
							Size = Vector3.new(math.random(3, 4), 2, math.random(3, 4)),
							Scale = { 1.2, 3 }
						})
						v10:Spawn(CFrame.new(v8, v8 + v9) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
							0,
							0,
							0
						))

						if not (math.random(1, 100) <= 25) then
							continue
						end

						v10.Type = "Flying"
						v10:Eject({
							Velocity = v7.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v10.Part.CFrame.lookVector * math.random(
								10,
								20
							),
							RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
						})
					end
				end)
			end

			if (currentCamera.CFrame.Position - clone3.Position).Magnitude <= 100 then
				Effect.new("ShakeCam"):play({
					30,
					13,
					0.25,
					0.5
				})
			end

			task.wait(5)
			folder:Destroy()
		end)
	end
end