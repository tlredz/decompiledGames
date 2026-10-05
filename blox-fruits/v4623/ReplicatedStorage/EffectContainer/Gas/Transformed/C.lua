local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Gas").Transformed.C.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
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

local function SpawnMinion(cFrame, folder, clones, root, boolValue)
	local function TrailCurve(clone, position, position2, p, _, _)
		local magnitude = (position - position2).Magnitude
		clone.CFrame = CFrame.new(position, position2)
		local v = (position - position2) / 2
		local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
		local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
		local v2 = math.random(20, 30) / 2
		local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-2, 2), math.random(-v2, v2))
		local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-2, 2), math.random(-v2, v2))
		local lastTime = tick()
		local v5 = magnitude / p / 60

		while tick() - lastTime < v5 and boolValue.Value ~= false and boolValue:IsDescendantOf(workspace) do
			local v6 = (tick() - lastTime) / v5
			local v7 = cubicBezier(v6, position, v3, v4, position2)
			clone.CFrame = clone.CFrame:Lerp(CFrame.new(v7, position2), v6)
			RunService.Heartbeat:Wait()
		end

		local v6 = cubicBezier(0.999, position, v3, v4, position2)
		clone.CFrame = CFrame.new(v6, position2)
	end

	local v = math.random(45, 50)
	local clone = assets.Phase1.GasTrail:Clone()
	task.delay(10, clone.Destroy, clone)
	clone.CFrame = cFrame
	clone.Parent = folder
	local _ = cFrame * CFrame.new(0, v, 0).Position
	local v2 = #clones <= 7 and 6 or 3

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	local v3 = #clones % 2 == 0 and 1 or -1
	local v4 = v * 1.5 * 2 * (#clones / 21 - 0.5)
	local v5 = 10 + math.random(0, v) + (#clones * 1.5 - 21)
	local v6 = v * (1 + math.random()) * (#clones / 21 - 0.5)

	if v4 > 0 then
		v4 += 20
	end

	if v6 > 0 then
		v6 += 20
	end

	if v4 < 0 then
		v4 -= 20
	end

	if v6 < 0 then
		v6 -= 20
	end

	if v4 == 0 or v6 == 0 then
		v5 = v
	end

	local v7 = root.CFrame * CFrame.new(0, v5, 0).Position + cFrame.LookVector * v6 + cFrame.RightVector * v3 * v4
	local clone2 = script.Assets.Phase1.Minion:Clone()
	table.insert(clones, clone2)
	TrailCurve(clone, cFrame.Position, v7, v2)

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	clone2.CFrame = CFrame.new(clone.Position, clone.Position + cFrame.LookVector)
	clone2.Parent = folder
	Util.Sound:Play("BF_GASFRUIT_TNSFM_SmogDemons_Spawn_0" .. tostring(math.random(1, 7)), clone2, 12)
	local clone3 = assets.Phase1.MinionStartImpact:Clone()
	clone3.CFrame = clone2.CFrame
	clone3.Parent = folder

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v8 = emitter
		task.spawn(function()
			if v8:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v8:GetAttribute("EmitDelay"))
			end

			v8:Emit(v8:GetAttribute("EmitCount"))
		end)
	end

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.spawn(function()
		local clone4 = assets.Phase1.OrbitPart:Clone()
		clone4.Parent = clone2
		local attachment0 = clone4.Attachment0
		attachment0.Parent = clone2
		clone4.AlignPosition.Enabled = true
		local _ = root.Position - clone2.Position
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = v4
		local numberValue2 = Instance.new("NumberValue")
		numberValue2.Value = v5
		local numberValue3 = Instance.new("NumberValue")
		numberValue3.Value = v6
		local responsiveness = math.random(10, 30)
		clone4.AlignPosition.Responsiveness = responsiveness
		clone4.AlignOrientation.Responsiveness = math.random(10, 30)
		clone2.Anchored = false
		local _ = math.random(3, 12) / 10
		local lastTime = tick()
		os.clock()

		while true do
			clone4.Position = root.Position
			attachment0.CFrame = CFrame.new(
				attachment0.Position,
				attachment0.Position + root.CFrame:Inverse().LookVector
			)
			clone4.AlignPosition.Position = root.CFrame * CFrame.new(
				0,
				numberValue2.Value + math.cos((tick() - lastTime) * 0.5) * 8,
				math.sin((tick() - lastTime) * 1.5) * 16
			).Position + root.CFrame.LookVector * numberValue3.Value + root.CFrame.RightVector * v3 * numberValue.Value

			if not (boolValue.Value and boolValue:IsDescendantOf(workspace)) then
				break
			end

			RunService.Heartbeat:Wait()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AddBurn(burn, folder, duration, reference)
	task.spawn(function()
		local clone = assets.Phase2.Burn:Clone()
		clone.CFrame = burn.CFrame
		clone.Anchored = false
		clone.Weld.Part0 = burn
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local destroyingConnection = nil

		if reference then
			destroyingConnection = reference.Destroying:Connect(function()
				destroyingConnection:Disconnect()

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end

		task.wait(duration)

		if destroyingConnection then
			destroyingConnection:Disconnect()
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
end

Util.ResizeModel(assets.Phase2.Explosion, 1.5)
Util.ResizeModel(assets.Phase2.GroundGas, 1.5)
Util.ResizeModel(assets.Phase2.GasDomain, 1.5)

local function GasDomain(raycastParams, p, folder)
	task.spawn(function()
		local raycastResult = workspace:Raycast(
			p.Position + createVector(0, 1, 0),
			CFrame.new(p.Position).UpVector * -25,
			raycastParams
		)

		if raycastResult then
			local clone = assets.Phase2.GroundGas:Clone()
			clone.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.1
			clone.Parent = folder

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = false
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			DeleteImpactAfterDuration(clone)
			task.wait(0.5)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end
	end)
	task.spawn(function()
		local clone = assets.Phase2.GasDomain:Clone()
		clone.CFrame = p * CFrame.new(0, clone.Size.Y / 2, 0)
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.wait(0.25)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CameraBlur(folder, duration)
	task.spawn(function()
		local currentCamera = workspace.CurrentCamera
		task.spawn(function()
			local clone = assets.Phase3.Blur:Clone()
			local tween = TweenService:Create(clone, TweenInfo.new(0.15), {
				Size = clone.Size
			})
			clone.Size = 0
			clone.Parent = workspace.CurrentCamera
			tween:Play()
			task.wait(duration)
			local tween2 = TweenService:Create(clone, TweenInfo.new(0.25), {
				Size = 0
			})
			tween2:Play()
			tween2.Completed:Wait()
			clone:Destroy()
		end)
		local clone = assets.Phase3.CameraFocus:Clone()
		clone.Parent = folder
		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
		end)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.wait(duration)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(0.5)
		renderSteppedConnection:Disconnect()
		clone:Destroy()
	end)
end

return function(data)
	if data.Burn then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, data.Duration + 3)
		AddBurn(data.Burn, folder, data.Duration, data.Reference) -- equivalent call inferred; original call site unknown
		CameraBlur(folder, data.Duration) -- equivalent call inferred; original call site unknown
	else
		local root = data.Root
		local holding = data.Holding
		local endPositions = data.EndPositions
		local folder = Instance.new("Folder")
		task.delay((data.Duration or 0) + 40, folder.Destroy, folder)
		folder.Parent = _WorldOrigin
		local cFrame = root.CFrame

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 1100 then
			return
		end

		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder
		local v = Util.Sound:Play("BF_GASFRUIT_TSFM_SmogDemons_Idle_01", root, 8)

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

		local boolValue = Instance.new("BoolValue", folder)
		boolValue.Value = true
		local v2 = {}

		for _ = 1, data.Minions.Value do
			task.spawn(function()
				SpawnMinion(cFrame, folder, v2, root, boolValue)
			end)
		end

		local changedConnection = data.Minions.Changed:Connect(function()
			local cFrame2 = root.CFrame
			task.spawn(function()
				SpawnMinion(cFrame2, folder, v2, root, boolValue)
			end)
		end)
		tick()

		repeat
			RunService.Heartbeat:Wait()
		until not holding:IsDescendantOf(workspace) or holding.Value == false

		while endPositions:GetChildren()[1] == nil and endPositions:IsDescendantOf(workspace) do
			task.wait()
		end

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		boolValue.Value = false
		changedConnection:Disconnect()

		if endPositions:GetChildren()[1] == nil then
			folder:Destroy()
			return
		end

		task.wait()
		task.wait()

		local function MinionCurve(p, position, position2, _, p2)
			local _ = (position - position2).Magnitude
			p.CFrame = CFrame.new(position, position2)
			local v3 = (position - position2) / 2
			local position3 = CFrame.new(CFrame.new(position) * (v3 / -1.5)).Position
			local position4 = CFrame.new(CFrame.new(position2) * (v3 / 1.5)).Position
			local v4 = math.random(20, 30)
			local v5 = position3 + Vector3.new(math.random(-v4, v4), math.random(-2, v4), math.random(-v4, v4))
			local v6 = position4 + Vector3.new(math.random(-v4, v4), math.random(-2, v4), math.random(-v4, v4))
			local lastTime = tick()

			while tick() - lastTime < p2 do
				local v7 = (tick() - lastTime) / p2
				local v8 = cubicBezier(v7, position, v5, v6, position2)
				p.CFrame = p.CFrame:Lerp(CFrame.new(v8, position2), v7)
				RunService.Heartbeat:Wait()
			end

			p.CFrame = CFrame.new(position2)
		end

		for k, v4 in pairs(v2) do
			local total = 0

			while not endPositions:GetChildren()[k] do
				total += task.wait()

				if total > 3 then
					break
				end
			end

			if total > 3 then
				Util.Debris:AddItem(folder, 1)
				break
			else
				local part = v4
				local v6 = endPositions:GetChildren()[k].Value
				task.spawn(function()
					local part2 = part
					Util.Sound:Play(
						"BF_GASFRUIT_TSFM_SmogDemons_Launch_0" .. tostring(math.random(1, 6)),
						part2.Position,
						8
					)
					local clone2 = assets.Phase2.MinionGasTrail:Clone()
					clone2.CFrame = part2.CFrame
					clone2.Parent = folder
					clone2.Weld.Part0 = part2

					for i, effect in pairs(clone2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					MinionCurve(
						part2,
						part2.Position,
						v6 + Vector3.new(math.random(-10, 10) * 2, 0, math.random(-10, 10) * 2),
						8.333,
						(root.Position - v6).Magnitude / 500
					)

					for i, effect in pairs(clone2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					clone2.Anchored = true
					local cFrame2 = part2.CFrame * CFrame.new(
						math.random(-15, 15),
						math.random(-5, 5) / 2,
						math.random(-15, 15)
					)
					task.spawn(function()
						if (workspace.CurrentCamera.CFrame.Position - cFrame2.Position).Magnitude > 110 then
							return
						end

						Util.CameraShaker:ShakeOnce(3, 3, 0.05, 0.3)
						local screenColorGC = assets.Phase2.ScreenColorGC
						local v9 = game.Lighting:FindFirstChild("ScreenColorGZ")

						if v9 then
							v9:SetAttribute("UsedTimes", v9:GetAttribute("UsedTimes") + 1)
						else
							v9 = Instance.new("ColorCorrectionEffect")
							v9.Name = "ScreenColorGZ"
							v9:SetAttribute("UsedTimes", 0)
						end

						v9.Parent = game.Lighting
						local usedTimes = v9:GetAttribute("UsedTimes")
						local tween = TweenService:Create(v9, TweenInfo.new(0.05), {
							Brightness = screenColorGC.Brightness,
							Contrast = screenColorGC.Contrast,
							Saturation = screenColorGC.Saturation,
							TintColor = screenColorGC.TintColor:Lerp(Color3.new(1, 1, 1), 0.66)
						})
						tween:Play()
						task.wait(0.05)

						if v9:GetAttribute("UsedTimes") == usedTimes then
							task.spawn(function()
								tween = TweenService:Create(v9, TweenInfo.new(0.1), {
									TintColor = Color3.fromRGB(120, 163, 255):Lerp(Color3.new(1, 1, 1), 0.66)
								})
								tween:Play()
								task.wait(0.1)

								if v9:GetAttribute("UsedTimes") == usedTimes then
									tween = TweenService:Create(v9, TweenInfo.new(0.2), {
										TintColor = Color3.fromRGB(255, 255, 255),
										Brightness = 0,
										Contrast = 0,
										Saturation = 0
									})
									tween:Play()
									tween.Completed:Wait()

									if v9:GetAttribute("UsedTimes") == usedTimes then
										v9:Destroy()
									end
								end
							end)
						end
					end)
					local clone3 = assets.Phase2.Explosion:Clone()
					clone3.CFrame = cFrame2
					clone3.Parent = folder
					Util.Sound:Play(
						"BF_GASFRUIT_TSFM_SmogDemons_Explode_0" .. tostring(math.random(1, 4)),
						clone3.Position,
						12
					)
					DeleteImpactAfterDuration(clone3)

					for i, emitter in pairs(clone3:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v9 = emitter
						task.spawn(function()
							if v9:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v9:GetAttribute("EmitDelay"))
							end

							v9:Emit(v9:GetAttribute("EmitCount"))

							if v9:GetAttribute("Funky") then
								task.spawn(function()
									for i2 = 1, 15 do
										v9.Acceleration = Vector3.new(
											math.random(-100, 100),
											math.random(-50, 100),
											math.random(-100, 100)
										)
										task.wait(math.random(10, 20) / 200)
									end

									v9.Acceleration = Vector3.new(
										math.random(-5, 5),
										math.random(-5, 5),
										math.random(-5, 5)
									)
								end)
							end
						end)
					end

					local raycastParams = RaycastParams.new()
					raycastParams.IgnoreWater = false
					raycastParams.FilterDescendantsInstances = { localPlayer.Character, folder, _WorldOrigin }
					GasDomain(raycastParams, cFrame2, folder)
					part2:Destroy()
				end)
			end
		end

		Util.Debris:AddItem(folder, 7)
	end
end