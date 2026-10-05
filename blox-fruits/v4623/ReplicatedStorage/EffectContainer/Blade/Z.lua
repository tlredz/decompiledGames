local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Blade").Z.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local ColorUtil = require(game.ReplicatedStorage.Modules.Util.ColorUtil)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
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

-- equivalent calls inferred from this helper; original call sites unknown
local function SpinSlash(p, p2, p3)
	task.spawn(function()
		local clone = assets.Phase1.DashTornadoModel:Clone()
		task.spawn(function()
			for i = 15, 100, 25 do
				clone:ScaleTo(i / 100)
				RunService.Heartbeat:Wait()
			end

			task.wait(math.random(0, 10) / 100)

			for i = 100, 0, -15 do
				clone:ScaleTo(i / 100)
				RunService.Heartbeat:Wait()
			end
		end)
		local dashTornado = clone.DashTornado
		dashTornado.CFrame = p.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(
			0,
			0,
			(math.rad((math.random(-180, 180))))
		)
		Util.SetParentOverrideWithColor(clone, p2, p3, "BladeFruitVFXColor")
		local v = math.random(15, 20) / 10
		local v2 = math.random(12, 20) / 10

		for _, descendant in dashTornado:GetDescendants() do
			if descendant:IsA("Beam") then
				descendant.CurveSize0 *= v
				descendant.CurveSize1 *= v
				descendant.Width0 *= v2
				descendant.Width1 *= v2
				local width0 = descendant.Width0
				local width1 = descendant.Width1
				descendant.Width0 = 0
				descendant.Width1 = 0
				local v3 = descendant
				task.spawn(function()
					local tween = TweenService:Create(
						v3,
						TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Width0 = width0,
							Width1 = width1
						}
					)
					task.wait(0.025)
					tween:Play()
					task.wait(0.15)
					local tween2 = TweenService:Create(
						v3,
						TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					v3:Destroy()
				end)
			elseif descendant:IsA("Attachment") then
				descendant.Position = Vector3.new(
					descendant.Position.X * v,
					descendant.Position.Y * v,
					descendant.Position.Z * v
				)
			end
		end

		task.spawn(function()
			local tween = TweenService:Create(
				dashTornado,
				TweenInfo.new(0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = dashTornado.CFrame * CFrame.Angles(0, 0, -2.6179938779914944)
				}
			)
			tween:Play()
			tween.Completed:Wait()
			local tween2 = TweenService:Create(
				dashTornado,
				TweenInfo.new(0.07, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = dashTornado.CFrame * CFrame.Angles(0, 0, -1.2217304763960306)
				}
			)
			tween2:Play()
			tween2.Completed:Wait()
			local tween3 = TweenService:Create(
				dashTornado,
				TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = dashTornado.CFrame * CFrame.Angles(0, 0, -1.7453292519943295)
				}
			)
			tween3:Play()
			tween3.Completed:Wait()
			TweenService:Create(dashTornado, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				CFrame = dashTornado.CFrame * CFrame.Angles(0, 0, -1.3089969389957472)
			}):Play()
		end)
	end)
end

require(script.Parent.Modules.CreateBlade)

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
return function(data)
	local root = data.Root
	local player = data.player
	local cFrame = root.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 5)
	local duration = data.Duration
	task.wait(0.1)
	task.spawn(function()
		root.Anchored = true
		local endCFrame = data.EndCFrame
		local magnitude = (endCFrame.p - cFrame.p).Magnitude
		Util.Sound:Play("Slice.CycloneAttack", root)
		local lastTime = os.clock()

		while os.clock() - lastTime < duration do
			local v = (os.clock() - lastTime) / duration
			root.CFrame = endCFrame * CFrame.new(0, 0, magnitude * (1 - v ^ 0.8))
			RunService.PreSimulation:Wait()
		end

		root.CFrame = endCFrame
		root.Anchored = false
	end)
	local clone = assets.Phase1.Spin:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "BladeFruitVFXColor")
	clone.Anchored = false
	clone.WeldConstraint.Part1 = root
	clone.Massless = true
	local emittersByEmitter = {}

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emittersByEmitter[emitter] = emitter
		emitter.Enabled = true
	end

	local v = duration + tick()
	task.spawn(function()
		local clone2 = assets.Phase1.GroundSpark:Clone()
		clone2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "BladeFruitVFXColor")
		local size = clone2.Size

		while true do
			for _, v2 in pairs(emittersByEmitter) do
				v2:Emit(1)
			end

			task.spawn(function()
				for i = 1, 4 do
					local v2 = i
					task.spawn(function()
						local raycastResult = nil
						local vector2 = nil
						local lookVector = root.CFrame.LookVector

						if v2 == 1 then
							raycastResult = workspace:Raycast(
								root.Position + createVector(0, 1, 0),
								createVector(-0, -25, -0),
								raycastParams
							)
							vector2 = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
						elseif v2 == 2 then
							raycastResult = workspace:Raycast(
								root.Position + createVector(0, 1, 0),
								createVector(0, 25, 0),
								raycastParams
							)
							vector2 = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
						elseif v2 == 3 then
							raycastResult = workspace:Raycast(
								root.Position,
								root.CFrame.RightVector * -25,
								raycastParams
							)
						elseif v2 == 4 then
							raycastResult = workspace:Raycast(
								root.Position,
								root.CFrame.RightVector * 25,
								raycastParams
							)
						end

						task.wait(math.random(5, 15) / 100)

						if raycastResult then
							clone2.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05

							if vector2 then
								clone2.CFrame = CFrame.new(clone2.Position, clone2.Position + vector2)
							else
								clone2.CFrame = CFrame.new(clone2.Position, clone2.Position + lookVector) * CFrame.Angles(
									1.5707963267948966,
									1.5707963267948966,
									0
								)
							end

							clone2.Size = size + Vector3.new(math.random(5, 10), 0, math.random(1, 5))

							for i2, emitter in pairs(clone2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end
						end
					end)
				end
			end)
			task.wait(0.07)

			if not (v - tick() <= 0) then
				continue
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
			clone.WeldConstraint.Enabled = false
			clone.Anchored = true
			clone.Trail.Enabled = false

			for _, v2 in pairs(emittersByEmitter) do
				v2.Enabled = false
			end

			emittersByEmitter = nil
			break
		end
	end)
	local v2 = {}

	for _ = 1, 5 do
		local clone2 = assets.Phase1.SpinTrail:Clone()
		clone2.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "BladeFruitVFXColor")
		clone2.Anchored = false
		clone2.Weld.Part1 = root

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		clone2.SpinTrail2.WeldConstraint.Enabled = false
		clone2.SpinTrail2.CFrame = clone2.CFrame * CFrame.new(20 / (math.random(15, 20) / 10), 0, 0)
		clone2.SpinTrail2.WeldConstraint.Enabled = true
		clone2.Weld.C0 = clone2.Weld.C0 * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
		local value = clone2.Trail.Color.Keypoints[1].Value
		local random = Random.new()
		clone2.Trail.Color = ColorSequence.new(
			ColorUtil.tuneBrightness(value, random:NextNumber(-0.3, -0.1)),
			ColorUtil.tuneBrightness(value, random:NextNumber(0.1, 0.3))
		)
		local v3 = math.random(7, 15) / 2
		clone2.SpinTrail2.Attach0.Position = Vector3.new(v3, 0, 0)
		clone2.SpinTrail2.Attach1.Position = Vector3.new(-v3, 0, 0)
		clone2.Trail.Lifetime = math.random(15, 25) / 100
		v2[clone2] = math.random(7, 15)
	end

	task.spawn(function()
		while true do
			for k, v3 in pairs(v2) do
				k.Weld.C0 = k.Weld.C0 * CFrame.Angles(0, 0, (math.rad(v3)))
			end

			SpinSlash(root, folder, player) -- equivalent call inferred; original call site unknown
			RunService.Heartbeat:Wait()

			if not (v - tick() <= 0) then
				continue
			end

			for folder2, _ in pairs(v2) do
				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end

			break
		end
	end)
end