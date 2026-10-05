local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local bizarreRifleX = FX:WaitForChild("BizarreRifle").BizarreRifleX
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local random = Random.new()

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

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

Util.ResizeModel(bizarreRifleX.Activate, 0.75, bizarreRifleX.Activate.Position)
return function(data)
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Activate(folder, p)
		local clone = bizarreRifleX.Activate:Clone()
		clone.CFrame = data.hrp.CFrame * CFrame.new(0, 1, -4)
		clone.Parent = folder
		local folder2 = clone["Activate" .. p]

		for _, emitter in pairs(folder2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	local maxRange = data.maxRange
	local minRange = data.minRange
	local hrp = data.hrp
	local rightMin = data.rightMin
	local rightMax = data.rightMax
	local tool = data.tool
	local holding = data.holding or tool and tool:FindFirstChild("Holding")

	if not (holding and holding.Value) then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "EffectsFolder"
	folder.Parent = _WorldOrigin
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Map }
	local clone = bizarreRifleX.Activate:Clone()
	clone.CFrame = data.hrp.CFrame * CFrame.new(0, 1, -4)
	clone.Parent = folder
	local folder2 = clone["Activate" .. 1]
	local v = minRange
	local v2 = 15
	local v3 = 1

	for _, emitter in pairs(folder2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local lastTime = tick()
	local lastTime2 = tick()
	local player = data.player
	local Players = game:GetService("Players")
	local clone2

	if player == Players.LocalPlayer then
		clone2 = bizarreRifleX.ColorCorrection:Clone()
		clone2.Parent = game:GetService("Lighting")
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			TintColor = Color3.fromRGB(190, 207, 255)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(1.35, Enum.EasingStyle.Linear), {
			Saturation = 0.25,
			Brightness = -0.1
		}):Play()
	else
		clone2 = nil
	end

	local v4 = sound:Play("BF_WPN_BizarreRifle_DimensionalSurge_01_V2", hrp.Position)
	local lastTime3 = tick()

	while holding and holding.Value do
		task.wait()

		if tick() - lastTime3 > 0.05 then
			lastTime3 = tick()

			if data.player == game.Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(2, 1.5, 0.05, 0.15)
			end
		end

		if tick() - lastTime >= 0.02 then
			task.spawn(function()
				lastTime = tick()
				local cFrame = hrp.CFrame * CFrame.new(
					random:NextNumber(-v2, v2),
					random:NextNumber(-10, 10),
					-random:NextNumber(7, 16)
				)
				local clone3 = bizarreRifleX.Bezier:Clone()
				local v6 = hrp.CFrame * createVector(0, 1, -4)
				local position2 = hrp.CFrame * createVector(0, 1, -4) + Vector3.new(
					random:NextNumber(-20, 20),
					random:NextNumber(-20, 20),
					random:NextNumber(-20, 20)
				)
				local v8 = cFrame.Position + Vector3.new(
					random:NextNumber(-20, 20),
					random:NextNumber(-20, 20),
					random:NextNumber(-20, 20)
				)
				local position = cFrame.Position
				clone3.Position = position2
				clone3.Parent = folder
				local lastTime4 = tick()

				while tick() - lastTime4 < 0.11538461538461536 do
					local v9 = (tick() - lastTime4) / 0.11538461538461536
					local v10 = v6 + (position2 - v6) * v9
					local v11 = position2 + (v8 - position2) * v9
					local v12 = v8 + (position - v8) * v9
					local v13 = v10 + (v11 - v10) * v9
					clone3.Position = v13 + (v11 + (v12 - v11) * v9 - v13) * v9
					task.wait()
				end

				clone3.Position = position
				local clone4 = bizarreRifleX.PortalOpen:Clone()
				clone4.CFrame = cFrame
				clone4.Parent = folder

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				local clone5 = bizarreRifleX.BeamPart1:Clone()
				local clone6 = bizarreRifleX.BeamPart2:Clone()

				for _, beam in pairs(clone5:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local v9 = string.sub(beam.Parent.Name, 1, 1)
					beam.Attachment0 = beam.Parent
					beam.Attachment1 = clone6[v9 .. 2]
				end

				clone5.CFrame = cFrame
				clone6.CFrame = clone5.CFrame
				clone5.Parent = folder
				clone6.Parent = folder
				local clone7 = bizarreRifleX.BeamParticles:Clone()
				clone7.CFrame = cFrame
				clone7.Parent = folder
				TweenService:Create(clone7, TweenInfo.new(0.17, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Size = clone7.Size + Vector3.new(0, 0, v),
					CFrame = cFrame * CFrame.new(0, 0, -v / 2)
				}):Play()
				TweenService:Create(clone6, TweenInfo.new(0.17, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = clone5.CFrame * CFrame.new(0, 0, -v)
				}):Play()
				task.wait(0.05)

				for _, beam in pairs(clone5:GetDescendants()) do
					if beam:IsA("Beam") then
						TweenService:Create(
							beam,
							TweenInfo.new(0.09, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0,
								CurveSize0 = 0,
								CurveSize1 = 0
							}
						):Play()
					end
				end

				local raycastResult = workspace:Raycast(cFrame.Position, cFrame.LookVector * v, raycastParams)

				if raycastResult then
					local clone8 = bizarreRifleX.WallHit:Clone()
					clone8.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
					clone8.Parent = folder

					for _, emitter in pairs(clone8:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					local clone9 = bizarreRifleX.FloorFire:Clone()
					clone9.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
					clone9.Parent = folder
					task.delay(0.3, function()
						local folder3 = clone9

						for _, emitter in pairs(folder3:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end)
				end

				for _, emitter in pairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, emitter in pairs(clone7:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(0.2)
				clone5:Destroy()
			end)
		end

		if tick() - lastTime2 >= 0.5 and v3 == 1 then
			v3 = 2
			v = (minRange + maxRange) / 2
			v2 = (rightMax + rightMin) / 2
			Activate(folder, 2) -- equivalent call inferred; original call site unknown
		elseif tick() - lastTime2 >= 1 and v3 == 2 then
			v3 = 3
			v = maxRange
			Activate(folder, 3) -- equivalent call inferred; original call site unknown
		end

		if tick() - lastTime2 >= 1.5 then
			break
		end
	end

	if v4 then
		sound:FadeOut(v4, 0.2)
	end

	task.wait(0.15)
	Activate(folder, v3 == 1 and 2 or 3) -- equivalent call inferred; original call site unknown
	task.spawn(function()
		local cFrame = hrp.CFrame * CFrame.new(0, 0, -12)
		local v7 = v * 1.2
		local clone3 = bizarreRifleX.PortalOpen:Clone()
		clone3.CFrame = cFrame
		clone3.Parent = folder

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone4 = bizarreRifleX.BeamPart1:Clone()
		local clone5 = bizarreRifleX.BeamPart2:Clone()

		for _, beam in pairs(clone4:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local v8 = string.sub(beam.Parent.Name, 1, 1)
			beam.Attachment0 = beam.Parent
			beam.Attachment1 = clone5[v8 .. 2]
		end

		clone4.CFrame = cFrame
		clone5.CFrame = clone4.CFrame
		clone4.Parent = folder
		clone5.Parent = folder
		local clone6 = bizarreRifleX.BeamParticles:Clone()
		Util.ResizeModel(clone6, 2, clone6.Position)
		clone6.CFrame = cFrame
		clone6.Parent = folder
		sound:Play("BizarreRifle.XFire", origin, nil, 1)
		TweenService:Create(clone6, TweenInfo.new(0.34, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = clone6.Size + Vector3.new(0, 0, v7),
			CFrame = cFrame * CFrame.new(0, 0, -v7 / 2)
		}):Play()
		TweenService:Create(clone5, TweenInfo.new(0.34, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone4.CFrame * CFrame.new(0, 0, -v7)
		}):Play()
		task.wait(0.1)

		for _, beam in pairs(clone4:GetDescendants()) do
			if beam:IsA("Beam") then
				TweenService:Create(beam, TweenInfo.new(0.18, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0,
					CurveSize0 = 0,
					CurveSize1 = 0
				}):Play()
			end
		end

		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.LookVector * v7, raycastParams)

		if raycastResult then
			local clone7 = bizarreRifleX.WallHit:Clone()
			clone7.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
			clone7.Parent = folder

			for _, emitter in pairs(clone7:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone8 = bizarreRifleX.FloorFire:Clone()
			clone8.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
			clone8.Parent = folder
			task.delay(0.6, function()
				local folder3 = clone8

				for _, emitter in pairs(folder3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end

		for _, emitter in pairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(clone6:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(0.4)
		clone4:Destroy()
	end)

	if data.player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(12, 8, 0.05, 0.5)
	end

	if clone2 then
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			TintColor = Color3.new(1, 1, 1),
			Saturation = 0,
			Brightness = 0
		}):Play()
		task.delay(0.35, function()
			clone2:Destroy()
		end)
	end

	task.wait(4)
	folder:Destroy()
end