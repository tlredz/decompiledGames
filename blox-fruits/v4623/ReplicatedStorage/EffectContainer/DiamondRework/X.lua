local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local X = FX:WaitForChild("Diamond").X
local _WorldOrigin = workspace._WorldOrigin
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Enemies, workspace.Characters }

local function ParticleState(folder, enabled, p)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if p and effect:GetAttribute("Color") == true then
			effect.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled

			if enabled == false and effect:IsA("ParticleEmitter") then
				effect.LockedToPart = false
			end
		end
	end
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(data)
	local WAIT_INTERVAL = 5
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local player = data.Player
	local crystalCount = data.CrystalCount
	local fireRate = data.FireRate
	local crystalFireTime = data.CrystalFireTime
	local crystalSpeed = data.CrystalSpeed
	local crystalLifeTime = data.CrystalLifeTime
	local crystalSpread = data.CrystalSpread
	local attachTime = data.AttachTime

	local function FireCrystal(cFrame, folder)
		local clone = X.Crystal:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "DiamondFruitVFXColor")
		local raycastResult = nil
		local lastTime = os.clock()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			raycastResult = workspace:Raycast(
				clone.Position,
				clone.CFrame.LookVector * dt * crystalSpeed,
				raycastParams
			)

			if not raycastResult and not (crystalLifeTime <= os.clock() - lastTime) then
				clone.CFrame *= CFrame.new(0, 0, -dt * crystalSpeed)
				return
			end

			heartbeatConnection:Disconnect()
			clone.Position = raycastResult and raycastResult.Position or clone.Position
			ParticleState(clone, false)

			if raycastResult then
				local weldConstraint = Instance.new("WeldConstraint")
				clone.Anchored = false
				weldConstraint.Part1 = clone
				weldConstraint.Part0 = raycastResult.Instance
				Util.SetParentOverrideWithColor(weldConstraint, clone, player, "DiamondFruitVFXColor")
				task.wait(attachTime)
			end

			local clone2 = X.Explosion:Clone()
			clone2.CFrame = clone.CFrame
			Util.SetParentOverrideWithColor(clone2, folder, player, "DiamondFruitVFXColor")
			ParticleState(clone2)
			sound:Play("DIAMOND_Shard_Storm_SmallExplosion_0" .. tostring(math.random(1, 8)), clone2.Position)
			clone.Transparency = 1
		end)
	end

	local stage = data.Stage

	if stage == 1 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DiamondFruitVFXColor")
		local tool = data.Tool
		local mousePos = data.MousePos or tool and tool:FindFirstChild("MousePos")
		local holding = data.Holding or tool and tool:FindFirstChild("Holding")

		if not (mousePos and holding) then
			folder:Destroy()
			return
		end

		local lastTime = os.clock()
		local HRP = data.HRP
		local clone = X.Shots:Clone()
		clone.Weld.Part0 = HRP
		Util.SetParentOverrideWithColor(clone, folder, player, "DiamondFruitVFXColor")
		local halfFireRate = fireRate / 2
		os.clock()
		local lastTime2 = os.clock()
		local v2 = sound:Play("DIAMOND_Shard_Storm_Fire_01", origin)

		while true do
			local v3 = os.clock() - lastTime

			if 1 / halfFireRate <= v3 then
				lastTime = os.clock()

				for _ = 1, 2 do
					task.spawn(function()
						local v4 = CFrame.lookAt(HRP.Position, mousePos.Value) * CFrame.new(0, 0, -3)
						local v5 = crystalSpeed * crystalLifeTime
						local raycastResult = workspace:Raycast(v4.Position, v4.LookVector * v5, raycastParams)
						local position = raycastResult and raycastResult.Position or (v4 * CFrame.new(0, 0, -v5)).Position
						local magnitude = (position - v4.Position).Magnitude
						local v6 = magnitude / (crystalSpeed * crystalLifeTime) * 80
						local position2 = v4.Position
						local position3 = v4.Position
						local v7 = position3 + (position - position3) * 0.3 + Vector3.new(
							random:NextNumber(-v6, v6),
							random:NextNumber(0, v6),
							random:NextNumber(-v6, v6)
						)
						local position4 = v4.Position
						local v8 = position4 + (position - position4) * 0.6 + Vector3.new(
							random:NextNumber(-v6, v6),
							random:NextNumber(0, v6),
							random:NextNumber(-v6, v6)
						)
						local clone2 = X.Crystal:Clone()
						clone2.Position = position2
						Util.SetParentOverrideWithColor(clone2, folder, player, "DiamondFruitVFXColor")
						local v9 = magnitude / crystalSpeed
						local lastTime3 = tick()
						local v10 = position2
						local raycastResult2 = nil

						while tick() - lastTime3 < v9 do
							local v11 = (tick() - lastTime3) / v9
							local v12 = position2 + (v7 - position2) * v11
							local v13 = v7 + (v8 - v7) * v11
							local v14 = v8 + (position - v8) * v11
							local v15 = v12 + (v13 - v12) * v11
							local v16 = v13 + (v14 - v13) * v11
							raycastResult2 = workspace:Raycast(v10, v15 + (v16 - v15) * v11 - v10, raycastParams)

							if raycastResult2 then
								break
							end

							if v10 ~= v15 + (v16 - v15) * v11 then
								clone2.CFrame = CFrame.lookAt(v15 + (v16 - v15) * v11, v10)
							end

							v10 = v15 + (v16 - v15) * v11
							task.wait()
						end

						local v11 = position2 + (v7 - position2) * 1
						local v12 = v7 + (v8 - v7) * 1
						local v13 = v8 + (position - v8) * 1
						local v14 = v11 + (v12 - v11) * 1
						local v15 = v12 + (v13 - v12) * 1

						if v10 ~= v14 + (v15 - v14) * 1 then
							clone2.CFrame = CFrame.lookAt(v14 + (v15 - v14) * 1, v10)
						end

						if raycastResult2 or raycastResult then
							task.wait(attachTime)
						end

						for _, effect in pairs(clone2:GetDescendants()) do
							if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
								continue
							end

							effect.Enabled = false

							if effect:IsA("ParticleEmitter") then
								effect.LockedToPart = false
							end
						end

						clone2.Transparency = 1
						local clone3 = X.Explosion:Clone()
						clone3.Position = clone2.Position
						Util.SetParentOverrideWithColor(clone3, folder, player, "DiamondFruitVFXColor")
						ParticleState(clone3)
						sound:Play(
							"DIAMOND_Shard_Storm_SmallExplosion_0" .. tostring(math.random(1, 8)),
							clone3.Position
						)
					end)
				end
			end

			task.wait()

			if not (crystalFireTime <= os.clock() - lastTime2 or not holding.Value) then
				continue
			end

			for _, effect in pairs(clone:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
					continue
				end

				effect.Enabled = false

				if effect:IsA("ParticleEmitter") then
					effect.LockedToPart = false
				end
			end

			if v2 then
				sound:FadeOut(v2, 0.2)
			end

			task.wait(WAIT_INTERVAL)
			folder:Destroy()
			return
		end
	elseif stage == 2 then
		local tool = data.Tool
		local mousePos = data.MousePos or tool and tool:FindFirstChild("MousePos")

		if not mousePos then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DiamondFruitVFXColor")
		local HRP = data.HRP
		local v = CFrame.lookAt(HRP.Position, mousePos.Value) * CFrame.new(0, 0, -3)
		local clone = X.Shots:Clone()
		clone.Weld.Part0 = HRP
		Util.SetParentOverrideWithColor(clone, folder, player, "DiamondFruitVFXColor")
		sound:Play("DIAMOND_Shard_Storm_Blast_01", origin)
		ParticleState(clone)

		for _, effect in pairs(clone:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
				continue
			end

			effect.Enabled = false

			if effect:IsA("ParticleEmitter") then
				effect.LockedToPart = false
			end
		end

		for _ = 1, crystalCount do
			FireCrystal(
				v * CFrame.Angles(
					math.rad((random:NextNumber(-crystalSpread / 2, crystalSpread / 2))),
					math.rad((random:NextNumber(-crystalSpread / 2, crystalSpread / 2))),
					0
				),
				folder
			)
		end

		task.wait(WAIT_INTERVAL)
		folder:Destroy()
	elseif stage == 3 then
		local folder = Instance.new("Folder")
		folder.Name = "DiamondXHitEffect"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DiamondFruitVFXColor")

		for _ = 1, math.random(5, 12) do
			local clone = X.Hit:Clone()
			clone.CFrame = data.HitCFrame
			Util.SetParentOverrideWithColor(clone, folder, player, "DiamondFruitVFXColor")
			ParticleState(clone)
			task.wait()
		end

		task.wait(WAIT_INTERVAL)
		folder:Destroy()
	end
end