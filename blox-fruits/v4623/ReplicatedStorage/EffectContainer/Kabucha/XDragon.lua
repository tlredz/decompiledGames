local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local kabucha_X = FX:WaitForChild("Kabucha").Kabucha_X
workspace:WaitForChild("_WorldOrigin")
local random = Random.new()

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }

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

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

for _, child in pairs(kabucha_X:GetChildren()) do
	if child:IsA("BasePart") then
		Util.ResizeModel(child, 1.33, child.Position)
	elseif child:IsA("Model") then
		child:ScaleTo(1.33)
	end
end

return function(data)
	local origin = data.origin
	local _ = data.dir

	if (currentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	if data.stage == 1 then
		local hrp = data.hrp
		local tool = data.tool
		local holding = data.holding or tool and tool:FindFirstChild("Holding")
		local folder = Instance.new("Folder")
		folder.Name = "KabuchaXHold"
		folder.Parent = workspace
		local clone = kabucha_X.WindUp:Clone()
		clone.Position = hrp.Position + createVector(0, -3, 0)
		clone.Parent = folder
		local now = tick()
		local player = data.player
		local Players = game:GetService("Players")
		local clone2

		if player == Players.LocalPlayer then
			clone2 = kabucha_X.Screen:Clone()
			clone2.Weld.Part1 = clone2.Effects
			clone2.Parent = folder
			RunService:BindToRenderStep(
				"Wind Camera Effect" .. tostring(now),
				Enum.RenderPriority.Camera.Value,
				function()
					clone2.CFrame = workspace.CurrentCamera.CFrame
				end
			)
		else
			clone2 = nil
		end

		local v = sound:Play("BF_WPN_DragonTempest_Hold_01_V2", hrp)

		repeat
			task.wait()
		until not holding or holding.Value == false

		if v then
			sound:FadeOut(v, 1)
		end

		if clone2 then
			TweenService:Create(clone2, TweenInfo.new(0.1), {
				Transparency = 1
			}):Play()
			local folder2 = clone2

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			RunService:UnbindFromRenderStep("Wind Camera Effect" .. tostring(now))
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(2)
		folder:Destroy()
	elseif data.stage == 2 then
		local projectileSpeed = data.projectileSpeed
		local projectileTime = data.projectileTime
		local folder = Instance.new("Folder")
		folder.Name = "KabuchaXDragon"
		folder.Parent = workspace
		local startCFrame = data.startCFrame
		Util.Sound:Play("Kabucha.XFire", startCFrame)
		local clone = kabucha_X.StartPart:Clone()
		clone.CFrame = startCFrame * CFrame.new(0, 0, -1)
		clone.Parent = folder
		local clone2 = kabucha_X.CircleDeform:Clone()
		clone2.CFrame = clone.CFrame
		clone2.Parent = folder
		local v = { "CircleDeform", "Deform", "DeformWind" }
		local Players = game:GetService("Players")
		local heartbeatConnection

		if Players.LocalPlayer.Character then
			local function isInsideBrick(position, instance)
				local pointToObjectSpace = instance.CFrame:PointToObjectSpace(position)
				local halfSize = instance.Size / 2
				local v3

				if math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Y) <= halfSize.Y then
					v3 = math.abs(pointToObjectSpace.Z) <= halfSize.Z
				else
					v3 = false
				end

				if v3 then
					return true, 0
				end

				local v4 = halfSize * 1.3
				local v5

				if math.abs(pointToObjectSpace.X) <= v4.X and math.abs(pointToObjectSpace.Y) <= v4.Y then
					v5 = math.abs(pointToObjectSpace.Z) <= v4.Z
				else
					v5 = false
				end

				if v5 then
					return
						false,
						(math.max(
							(math.abs(pointToObjectSpace.X) - halfSize.X) / (v4.X - halfSize.X),
							(math.abs(pointToObjectSpace.Y) - halfSize.Y) / (v4.Y - halfSize.Y),
							(math.abs(pointToObjectSpace.Z) - halfSize.Z) / (v4.Z - halfSize.Z)
						))
				end

				return false, 1
			end

			heartbeatConnection = RunService.Heartbeat:Connect(function(_)
				for _, childName in pairs(v) do
					if not folder:FindFirstChild(childName) then
						continue
					end

					local v2 = folder[childName]

					if not v2:GetAttribute("InitialTransparency") then
						v2:SetAttribute("InitialTransparency", v2.Transparency)
					end

					local insideBrick, v3 = isInsideBrick(currentCamera.CFrame.Position, v2)

					if insideBrick then
						v2.Material = Enum.Material.SmoothPlastic
					else
						v2.Material = Enum.Material.Glass
						v2.Transparency = 1 + (v2:GetAttribute("InitialTransparency") - 1) * v3
					end
				end
			end)
		end

		TweenService:Create(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = createVector(150, 150, 150),
			Transparency = 1
		}):Play()
		task.delay(0.1, clone2.Destroy, clone2)
		local clone3 = kabucha_X.Shoot:Clone()
		clone3.CFrame = startCFrame
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		sound:Play("BF_WPN_DragonTempest_Release_01_V2", clone3.Position)
		local clone4 = kabucha_X.Head:Clone()
		clone4.CFrame = startCFrame
		clone4.Parent = folder
		local clone5 = kabucha_X.DragonModel:Clone()
		clone5:PivotTo(clone4.CFrame * CFrame.new(0, -3, 0))
		clone5.Parent = folder
		task.delay(0.1, function()
			local folder2 = clone5

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
		task.wait(0.1)
		sound:Play("BF_WPN_DragonTempest_Activate_01_V2", clone4)
		local position = startCFrame.Position
		local lookVector = startCFrame.LookVector
		local rightVector = startCFrame.RightVector
		local upVector = startCFrame.UpVector
		local v2 = clone4.Position - position
		local lastTime = os.clock()
		local heartbeatConnection2 = nil
		heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
			clone4.CFrame *= CFrame.new(0, 0, -projectileSpeed * dt)
			clone5:PivotTo(clone4.CFrame * CFrame.new(0, -3, 0))
			v2 = clone4.Position - position

			if projectileTime <= os.clock() - lastTime then
				heartbeatConnection2:Disconnect()

				for _, part in clone5:GetChildren() do
					if part:IsA("BasePart") then
						TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Transparency = 1
						}):Play()
					end
				end

				local folder2 = clone4

				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.delay(0.3, function()
					local folder3 = clone5

					for _, emitter in pairs(folder3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
			end
		end)
		local v3 = projectileSpeed * projectileTime
		local v4 = 40 / projectileSpeed
		os.clock()
		local clone6 = kabucha_X.Deform:Clone()
		clone6.CFrame = clone4.CFrame
		clone6.Size = createVector(22.61, 22.61, 0)
		clone6.Parent = folder
		TweenService:Create(clone6, TweenInfo.new(projectileTime, Enum.EasingStyle.Linear), {
			Size = Vector3.new(22.61, 22.61, v3),
			CFrame = clone6.CFrame * CFrame.new(0, 0, -v3 / 2)
		}):Play()
		local clone7 = kabucha_X.White:Clone()
		clone7.CFrame = clone4.CFrame
		clone7.Size = createVector(22.61, 22.61, 0)
		clone7.Parent = folder
		TweenService:Create(clone7, TweenInfo.new(projectileTime, Enum.EasingStyle.Linear), {
			Size = Vector3.new(22.61, 22.61, v3),
			CFrame = clone7.CFrame * CFrame.new(0, 0, -v3 / 2)
		}):Play()
		TweenService:Create(clone7.B, TweenInfo.new(projectileTime, Enum.EasingStyle.Linear), {
			Position = Vector3.new(0, 0, -v3 / 2)
		}):Play()
		TweenService:Create(clone7.A, TweenInfo.new(projectileTime, Enum.EasingStyle.Linear), {
			Position = Vector3.new(0, 0, v3 / 2)
		}):Play()
		local lastTime2 = os.clock()
		local lastTime3 = os.clock()
		local clones = {}
		local v5 = 0

		while os.clock() - lastTime <= projectileTime do
			local clone8 = kabucha_X.Wind:Clone()
			clone8.CFrame = clone4.CFrame
			clone8.Size = createVector(18.62, 18.62, 0)
			clone8.Parent = folder
			table.insert(clones, clone8)
			TweenService:Create(clone8, TweenInfo.new(v4, Enum.EasingStyle.Linear), {
				Size = createVector(15.96, 15.96, 23),
				CFrame = clone8.CFrame * CFrame.new(0, 0, -9)
			}):Play()

			if os.clock() - lastTime2 >= random:NextNumber(0.05, 0.09) then
				task.spawn(function()
					local clone9 = kabucha_X.MeshWind:Clone()
					clone9.CFrame = startCFrame * CFrame.Angles(
						1.5707963267948966,
						random:NextNumber(0, 6.283185307179586),
						0
					)
					local v6 = random:NextNumber(15, 18) * 1.33
					clone9.Size = Vector3.new(v6, 0, v6)
					clone9.Parent = folder
					local v7 = v3 / projectileSpeed * random:NextNumber(0.05, 0.2)
					TweenService:Create(clone9, TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = Vector3.new(v6, v2.Magnitude, v6),
						CFrame = startCFrame * CFrame.new(0, 0, -v2.Magnitude / 2) * CFrame.Angles(
							1.5707963267948966,
							random:NextNumber(0, 6.283185307179586),
							0
						),
						Transparency = 1
					}):Play()
					task.wait(v7)
					clone9:Destroy()
				end)
			end

			if os.clock() - lastTime3 >= random:NextNumber(0.02, 0.05) then
				task.spawn(function()
					local clone9 = kabucha_X.Trail:Clone()
					local number = random:NextNumber(0, 360)
					local number2 = random:NextNumber(180, 360)
					local number3 = random:NextNumber(90, 200)
					local v6 = random:NextNumber(8, 12) * 1.33
					local number4 = random:NextNumber(0, v2.Magnitude)
					clone9.CFrame = startCFrame * CFrame.new(
						math.sin((math.rad(number))) * v6,
						math.cos((math.rad(number))) * v6,
						-number4
					)
					clone9.Parent = folder
					local lastTime4 = os.clock()
					local heartbeatConnection3 = nil
					heartbeatConnection3 = RunService.Heartbeat:Connect(function(dt)
						number4 += number3 * dt
						number += number2 * dt
						clone9.CFrame = startCFrame * CFrame.new(
							math.sin((math.rad(number))) * v6,
							math.cos((math.rad(number))) * v6,
							-number4
						)

						if os.clock() - lastTime4 >= random:NextNumber(1, 2) then
							heartbeatConnection3:Disconnect()
							local folder2 = clone9

							for _, emitter in pairs(folder2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							task.wait(3)
							clone9:Destroy()
						end
					end)
				end)
			end

			if v5 <= os.clock() - lastTime3 then
				lastTime3 = os.clock()
				local total = 0
				v5 = random:NextNumber(0.1, 0.3)
				local clone9 = nil
				local clone10 = nil
				local raycastResult = nil
				local raycastResult2 = nil
				local v6 = false
				local v7 = false
				local heartbeatConnection3 = nil
				heartbeatConnection3 = RunService.Heartbeat:Connect(function(dt)
					raycastResult = workspace:Raycast(
						position + lookVector * total + rightVector * 7 * 1.33 + upVector * 4 * 1.33,
						upVector * -8 * 1.33,
						raycastParams
					)
					raycastResult2 = workspace:Raycast(
						position + lookVector * total + rightVector * -7 * 1.33 + upVector * 4 * 1.33,
						upVector * -8 * 1.33,
						raycastParams
					)
					total += dt * projectileSpeed * random:NextNumber(1, 3)

					if raycastResult then
						if not clone9 then
							clone9 = kabucha_X.FloorTrail:Clone()
						end

						clone9.CFrame = CFrame.lookAt(raycastResult.Position, position)

						if clone9.Parent ~= folder then
							clone9.Parent = folder
						end

						if v6 == false then
							clone9.Trail.Enabled = true
							local folder2 = clone9

							for _, emitter in pairs(folder2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							v6 = true
						end
					elseif v6 == true then
						clone9.Trail.Enabled = false
						local folder2 = clone9

						for _, emitter in pairs(folder2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						v6 = false
					end

					if raycastResult2 then
						if not clone10 then
							clone10 = kabucha_X.FloorTrail:Clone()
						end

						clone10.CFrame = CFrame.lookAt(raycastResult2.Position, position)

						if clone10.Parent ~= folder then
							clone10.Parent = folder
						end

						if v7 == false then
							clone10.Trail.Enabled = true
							local folder2 = clone10

							for _, emitter in pairs(folder2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							v7 = true
						end
					elseif v7 == true then
						clone10.Trail.Enabled = false
						local folder2 = clone10

						for _, emitter in pairs(folder2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						v7 = false
					end

					if total >= (clone4.Position - position).Magnitude then
						heartbeatConnection3:Disconnect()

						if clone9 then
							clone9.Trail.Enabled = true
							local folder2 = clone9

							for _, emitter in pairs(folder2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							task.delay(0.3, clone9.Destroy, clone9)
						end

						if clone10 then
							local folder2 = clone10

							for _, emitter in pairs(folder2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							task.delay(0.3, clone10.Destroy, clone10)
						end
					end
				end)
			end

			task.wait(v4)
		end

		for _, folder2 in clones do
			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		TweenService:Create(clone6, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone7, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone7.Beam, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Brightness = 0,
			LightEmission = 1
		}):Play()
		task.wait(0.3)
		clone6:Destroy()
		clone7:Destroy()

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		task.wait(5)
		folder:Destroy()
	end
end