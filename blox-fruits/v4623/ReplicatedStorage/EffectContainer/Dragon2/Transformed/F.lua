local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local F = FX:WaitForChild("Dragon2").Transformed.F
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max + emitter:GetAttribute("EmitDelay"))
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function viewerIsClose(position, p, doCameraFX)
	local character = localPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= p then
			doCameraFX()
		end
	end
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

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function TornadoSlash(p, data, p2)
	local multiplier = data.Multiplier
	local multiplier2 = data.Multiplier2
	local mutliplier2Time = data.Mutliplier2Time
	local beamOutTime = data.BeamOutTime
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local slashType = data.SlashType
	local slashCFrame = data.SlashCFrame
	local slashSpeed = data.SlashSpeed
	local slashSpeed2 = data.SlashSpeed2
	local spinIterations = data.SpinIterations
	local clone = slashType:Clone()
	clone.CFrame = slashCFrame
	Util.SetParentOverrideWithColor(clone, p, p2, "DragonFruitVFXColor")

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= multiplier
			descendant.CurveSize1 *= multiplier
			descendant.Width0 *= multiplier
			descendant.Width1 *= multiplier
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * multiplier,
				descendant.Position.Y * multiplier,
				descendant.Position.Z * multiplier
			)
		end
	end

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.Enabled = true
			local v = descendant
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						CurveSize0 = v.CurveSize0 * multiplier2,
						CurveSize1 = v.CurveSize1 * multiplier2,
						Width0 = v.Width0 * multiplier2,
						Width1 = v.Width1 * multiplier2
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				tween:Play()
			end)
		elseif descendant:IsA("Attachment") then
			TweenService:Create(
				descendant,
				TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(
						descendant.Position.X * multiplier2,
						descendant.Position.Y * multiplier2,
						descendant.Position.Z * multiplier2
					)
				}
			):Play()
		end
	end

	for _ = 1, spinIterations do
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(slashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = clone.CFrame * slashAngle
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v = beam
		task.spawn(function()
			local tween = TweenService:Create(
				v,
				TweenInfo.new(beamOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = 0
				}
			)
			tween:Play()
			tween.Completed:Wait()
			v:Destroy()
		end)
	end

	TweenService:Create(clone, TweenInfo.new(slashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * slashAngle2
	}):Play()
end

local function Dash(part, p2, data, instance, instance2, p3)
	local v = data.Position + createVector(0, 0.012345, 0)
	local cframe = CFrame.new(instance.Position, v)
	local _ = (cframe.Position - v).Magnitude
	local speed = data.Speed
	task.spawn(function()
		local flag = false
		local cFrame = cframe
		local lastTime = os.clock()
		local v2 = workspace:GetServerTimeNow() - data.Timestamp
		local v3 = 0.016666666666666666
		local halfSpeed = speed / 2
		local v5 = halfSpeed / (1 - v2)

		if v5 < 0.03333333333333333 then
			return
		end

		instance.Anchored = true
		instance.CFrame = cframe
		local identity = CFrame.identity

		while true do
			if instance:GetAttribute("DragonSpiralingUp") and not flag then
				flag = true
				v = instance:GetAttribute("DragonSpiralingUp") + createVector(0, 0.012345, 0)
				cFrame = instance.CFrame
				lastTime = os.clock()
				v5 = halfSpeed
			end

			local v6 = (os.clock() - lastTime) / v5

			if not (flag and v6 > 1.5) then
				local v7 = math.min(1, v6)
				local v8 = cFrame.p * createVector(1, 0, 1)
				local v9

				if flag then
					local v10 = (1 - math.cos(3.141592653589793 * v7)) * 0.5
					v9 = v8:Lerp(v * createVector(1, 0, 1), v10)
				else
					v9 = v8:Lerp(v * createVector(1, 0, 1), v7)
				end

				local v10 = cFrame.p * createVector(0, 1, 0)
				local v11

				if flag then
					local v12 = v7 ^ 2
					v11 = v10:Lerp(v * createVector(0, 1, 0), v12)
				else
					v11 = v10:Lerp(v * createVector(0, 1, 0), v7)
				end

				if flag then
					local lerped = instance.CFrame:Lerp(CFrame.lookAt(cFrame.Position, v), v3 * 10)
					identity = lerped - lerped.Position
				else
					identity = cFrame - cFrame.Position
				end

				instance.CFrame = identity + v9 + v11

				if not (v7 >= 1) or not (instance2.Value >= 2) and instance2:IsDescendantOf(workspace) then
					v3 = RunService.PreSimulation:Wait()
					continue
				end
			end

			instance.CFrame = CFrame.new(v) * identity

			if instance2.Value ~= 3 then
				instance.Anchored = false
				break
			end

			local v7 = instance
			local v8 = v
			local cFrame2 = instance.CFrame
			local lastTime2 = os.clock()

			while os.clock() - lastTime2 < 0.15 do
				local v9 = (os.clock() - lastTime2) / 0.15
				v7.CFrame = CFrame.lookAt(createVector(0, 0, 0), cFrame2.LookVector):Lerp(
					CFrame.lookAt(createVector(0, 0, 0), cFrame2.LookVector * createVector(1, 0, 1)),
					v9
				) + v8
				RunService.PreSimulation:Wait()
			end

			v7.CFrame = CFrame.lookAt(createVector(0, 0, 0), cFrame2.LookVector * createVector(1, 0, 1)) + v8
			break
		end
	end)
	local clone = F.Phase1.StartImpact:Clone()
	clone.CFrame = cframe
	Util.SetParentOverrideWithColor(clone, p2, p3, "DragonFruitVFXColor")
	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

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

	local clone2 = F.Phase1.Dash:Clone()
	clone2.CFrame = cframe
	Util.SetParentOverrideWithColor(clone2, p2, p3, "DragonFruitVFXColor")
	clone2.Weld.Part0 = part
	clone2.Anchored = false
	local emittersByEmitter = {}

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emittersByEmitter[emitter] = emitter
	end

	task.spawn(function()
		local lastTime = tick()

		while true do
			for _, v2 in pairs(emittersByEmitter) do
				v2:Emit(1)
			end

			task.wait(0.01)
			local v2 = tick() - lastTime

			if not (speed * 0.9 <= v2 or instance2.Value >= 2) then
				continue
			end

			emittersByEmitter = nil

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			clone2.Weld.Enabled = false
			clone2.Anchored = true
			break
		end
	end)
	task.spawn(function()
		local lastTime = tick()
		local v2 = {}

		for i = 1, 5 do
			local clone3 = F.Phase1.SpinTrail:Clone()
			clone3.CFrame = part.CFrame
			Util.SetParentOverrideWithColor(clone3, p2, p3, "DragonFruitVFXColor")
			clone3.Anchored = false
			clone3.Weld.Part1 = part

			for _, effect in pairs(clone3:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			clone3.SpinTrail2.WeldConstraint.Enabled = false
			clone3.SpinTrail2.CFrame = clone3.CFrame * CFrame.new(
				math.random(-70, -50) * 1.7,
				math.random(-15, 15),
				math.random(10, 25)
			)
			clone3.SpinTrail2.WeldConstraint.Enabled = true
			clone3.Weld.C0 = clone3.Weld.C0 * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
			local v3 = math.random(1, 3)

			if v3 == 1 then
				clone3.Trail.Color = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(248, 87, 23), p3, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(255, 33, 33), p3, "DragonFruitVFXColor")
				)
			elseif v3 == 2 then
				clone3.Trail.Color = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(189, 42, 22), p3, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(255, 62, 23), p3, "DragonFruitVFXColor")
				)
			elseif v3 == 3 then
				clone3.Trail.Color = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(156, 28, 30), p3, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(53, 8, 5), p3, "DragonFruitVFXColor")
				)
			end

			if i == 5 then
				clone3.Trail.Color = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(88, 31, 11), p3, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(30, 6, 7), p3, "DragonFruitVFXColor")
				)
			elseif i == 4 then
				clone3.Trail.Color = ColorSequence.new(
					Util.WrapColor3Constructor(Color3.fromRGB(143, 70, 21), p3, "DragonFruitVFXColor"),
					Util.WrapColor3Constructor(Color3.fromRGB(4, 0, 0), p3, "DragonFruitVFXColor")
				)
			end

			local v4 = math.random(7, 15) * 1.5
			clone3.SpinTrail2.Attach0.Position = Vector3.new(v4, 0, 0)
			clone3.SpinTrail2.Attach1.Position = Vector3.new(-v4, 0, 0)
			clone3.Trail.Lifetime = math.random(15, 30) / 100
			v2[clone3] = math.random(10, 15)
		end

		while true do
			for k, v3 in pairs(v2) do
				k.Weld.C0 = k.Weld.C0 * CFrame.Angles(0, 0, (math.rad(v3)))
			end

			RunService.Heartbeat:Wait()
			local v3 = tick() - lastTime

			if not (speed * 0.9 <= v3 or instance2.Value >= 2) then
				continue
			end

			for folder, _ in pairs(v2) do
				for _, effect in pairs(folder:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					elseif effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end

			break
		end
	end)
end

local function RingBeam(p, p2, p3, p4)
	local _ = p * CFrame.new(0, 0, -150)
	local clone

	if p3 then
		clone = F.Phase3.RingBeamModel:Clone()
	else
		clone = F.Phase1.RingBeamModel:Clone()
	end

	local v = TweenService
	local cFrame = p * CFrame.new(0, 0, -150)
	clone.PrimaryPart.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, p2, p4, "DragonFruitVFXColor")
	local v3 = {}

	for _, beam in pairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v4 = beam
		task.spawn(function()
			local v5 = v:Create(v4, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
				Width0 = v4.Width0 * 7,
				Width1 = v4.Width1 * 7
			})
			v5:Play()
			v5.Completed:Wait()
			local v6

			if p3 then
				v6 = v:Create(v4, TweenInfo.new(0.075, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
					Width0 = v4.Width0 * 15,
					Width1 = v4.Width1 * 15
				})
			else
				v6 = v:Create(v4, TweenInfo.new(0.075, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
					Width0 = v4.Width0 * 2,
					Width1 = v4.Width1 * 2
				})
			end

			v6:Play()
			v6.Completed:Wait()
			v:Create(v4, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0), {
				Width0 = v4.Width0 * 0,
				Width1 = v4.Width1 * 0
			}):Play()
		end)
		v3[beam] = beam
	end

	task.spawn(function()
		local v4 = v:Create(clone.PrimaryPart, TweenInfo.new(0.07, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 50)
		})
		v4:Play()
		v4.Completed:Wait()
		v:Create(clone.PrimaryPart, TweenInfo.new(0.05, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, 25)
		}):Play()
	end)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0.0001
	Util.SetParentOverrideWithColor(numberValue, clone, p4, "DragonFruitVFXColor")
	v:Create(numberValue, TweenInfo.new(0.35), {
		Value = 0.1
	}):Play()
	task.spawn(function()
		clone:ScaleTo(1)
		task.wait(numberValue.Value)
		clone:ScaleTo(2.5)
		task.wait(numberValue.Value)
		clone:ScaleTo(4)
		task.wait(numberValue.Value)

		for i = 50, 200, 5 do
			clone:ScaleTo(i / 10)
			task.wait(numberValue.Value)
		end
	end)
end

local function StartDash(cFrame, position, folder, part, root, proxy, timestamp, player)
	local v = {
		Range = 320,
		Timestamp = timestamp,
		Speed = 0.8,
		Position = position
	}
	task.spawn(function()
		local slashCFrame = cFrame * CFrame.new(0, 0, 5)
		TornadoSlash(folder, {
			Multiplier = 0.5,
			Multiplier2 = 2.25,
			Mutliplier2Time = 0.175,
			BeamOutTime = 0.175,
			SlashAngle = CFrame.new(0, 0, -10) * CFrame.Angles(0, 0, -0.4363323129985824),
			SlashAngle2 = CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, -1.7453292519943295),
			SlashType = F.Phase1.BeamSlash,
			SlashCFrame = slashCFrame,
			SlashSpeed = 0.025,
			SlashSpeed2 = 0.125,
			SpinIterations = 5
		}, player)
	end)
	task.spawn(function()
		local slashCFrame = cFrame * CFrame.new(0, 0, 0)
		TornadoSlash(folder, {
			Multiplier = 0.75,
			Multiplier2 = 2,
			Mutliplier2Time = 0.175,
			BeamOutTime = 0.275,
			SlashAngle = CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, 0.6108652381980153),
			SlashAngle2 = CFrame.new(0, 0, -2.5) * CFrame.Angles(0, 0, 1.7453292519943295),
			SlashType = F.Phase1.BeamSlash,
			SlashCFrame = slashCFrame,
			SlashSpeed = 0.035,
			SlashSpeed2 = 0.15,
			SpinIterations = 3
		}, player)
	end)
	task.spawn(function()
		local lastTime = tick()
		local now = tick()

		repeat
			if now - tick() <= 0 and tick() - lastTime < 0.6000000000000001 then
				now = tick() + 0.075
				task.spawn(function()
					RingBeam(part.CFrame * CFrame.new(0, 0, -25), folder, nil, player)
				end)
			end

			local clone = F.Phase1.DashTornado:Clone()
			clone.CFrame = part.CFrame * CFrame.new(0, 0, math.random(-10, 30)) * CFrame.Angles(
				0,
				0,
				(math.rad((math.random(-90, 90))))
			)
			Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
			local v2 = math.random(20, 30) / 10

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= v2
					descendant.CurveSize1 *= v2
					descendant.Width0 *= math.clamp(v2 / 2, 2, 3)
					descendant.Width1 *= math.clamp(v2 / 2, 2, 3)
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
						task.wait(0.075)
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
						descendant.Position.X * v2,
						descendant.Position.Y * v2,
						descendant.Position.Z * v2
					)
				end
			end

			task.spawn(function()
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CFrame = clone.CFrame * CFrame.Angles(0, 0, 2.6179938779914944)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					CFrame = clone.CFrame * CFrame.Angles(0, 0, 1.3089969389957472)
				}):Play()
			end)
			task.wait(math.random(10, 20) / 300)
		until tick() - lastTime >= 0.7200000000000001 or proxy.Value >= 2
	end)
	task.spawn(function()
		Dash(part, folder, v, root, proxy, player)
	end)
end

local function BasicSlash(folder)
	task.spawn(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local startDelay = beam:GetAttribute("StartDelay")
			local v = beam
			local v2 = beam:GetAttribute("EndDelay")
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0,
						Width1 = v.Width1
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
				task.wait(v2)
				task.wait(0.12)
				task.wait(0.12)
				task.wait(0.035)
				local tween2 = TweenService:Create(
					v,
					TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v:Destroy()
			end)
		end
	end)
	local tween = TweenService:Create(
		folder.Weld,
		TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
				-1.8325957145940461,
				0,
				0
			)
		}
	)
	tween:Play()
	tween.Completed:Wait()
	local tween2 = TweenService:Create(
		folder.Weld,
		TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
				-2.9670597283903604,
				0,
				0
			)
		}
	)
	tween2:Play()
	tween2.Completed:Wait()
	local tween3 = TweenService:Create(
		folder.Weld,
		TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
				-0.8726646259971648,
				0,
				0
			)
		}
	)
	tween3:Play()
	tween3.Completed:Wait()
	folder.Weld.Enabled = false
	folder.Anchored = true
	TweenService:Create(folder, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = folder.CFrame * CFrame.Angles(-2.181661564992912, 0, 0)
	}):Play()
end

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

for _, model in pairs(F.Phase1:GetChildren()) do
	if not model:IsA("Model") then
		Util.ResizeModel(model, 2.5, model.Position)
	end
end

local function mockRootPart(_, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = workspace._WorldOrigin
	return part
end

return function(data)
	local player = data.player
	local root = data.Root
	local stage = data.Stage
	math.max(0, workspace:GetServerTimeNow() - data.Timestamp)

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 2000 then
		if stage == 3 then
			root.Anchored = false
		end
	else
		local cFrame = root.CFrame
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DragonFruitVFXColor")
		Util.Debris:AddItem(folder, 7)

		if stage == 1 then
			local position = data.Position
			local proxy = data.Proxy
			local cFrame2 = root.CFrame
			local part = Instance.new("Part")
			part.Name = "Mock" .. part.Name
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Transparency = 1
			part.CFrame = cFrame2
			part.Parent = workspace._WorldOrigin
			task.spawn(function()
				local cframe = CFrame.new(0, 0, -50)

				while proxy.Value < 2 and proxy:IsDescendantOf(workspace) do
					part.CFrame = root.CFrame * cframe
					RunService.RenderStepped:Wait()
				end

				task.delay(5, function()
					part:Destroy()
				end)
			end)
			Util.Sound:Play("BF_WD_Western_F_Dash_01", root)
			StartDash(cFrame, position, folder, part, root, proxy, data.Timestamp, player)
			task.spawn(function()
				local DashFlipbook = require(script.DashFlipbook)
				DashFlipbook.Dash(part, folder, proxy, player)
			end)
		elseif stage == 2 then
			local cframe = CFrame.Angles(0, 0, 0.08726646259971647)
			CFrame.Angles(-1.7453292519943295, 0, 0)
			local cFrame2 = cFrame * cframe
			local _ = cFrame * CFrame.new(0, 0, -25) * cframe
			Util.Sound:Play("BF_WD_Western_F_Hit_01", root)
			task.wait(0.3)
			local clone = F.Phase2.StartImpact:Clone()
			clone.CFrame = cFrame2 * CFrame.new(0, 0, -5)
			Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					task.wait(0.075)

					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					v2:Emit(v2:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			task.spawn(function()
				local clone2 = F.Phase2.SlashModel:Clone()
				clone2.PrimaryPart.CFrame = cFrame2
				Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
				clone2.PrimaryPart.CFrame = clone2.PrimaryPart.CFrame * CFrame.Angles(-2.6179938779914944, 0, 0)
				task.spawn(function()
					task.spawn(function()
						for i = 100, 135, 5 do
							clone2:ScaleTo(i / 100)
							task.wait()
						end
					end)
					task.wait(0.25)

					for _, beam in pairs(clone2:GetDescendants()) do
						if not beam:IsA("Beam") then
							continue
						end

						local endDelay = beam:GetAttribute("EndDelay")
						local tween = TweenService:Create(
							beam,
							TweenInfo.new(endDelay, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						local v3 = beam
						task.spawn(function()
							tween.Completed:Wait()
							v3:Destroy()
						end)
					end
				end)
				task.spawn(function()
					local v2 = 0.1 * math.random() + 0.2

					for _ = 1, 7 do
						local tween = TweenService:Create(
							clone2.PrimaryPart,
							TweenInfo.new(v2 / 7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = clone2.PrimaryPart.CFrame * CFrame.Angles(-0.8726646259971648, 0, 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end

					local tween = TweenService:Create(
						clone2.PrimaryPart,
						TweenInfo.new(v2 * 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone2.PrimaryPart.CFrame * CFrame.Angles(-0.6981317007977318, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end)
			end)
			local position = cFrame2.Position
			local character = localPlayer.Character

			if character ~= nil then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= 250 then
					Util.CameraShaker:ShakeOnce(10, 7, 0.15, 0.75)
				end
			end
		elseif stage == 3 then
			if data.Stop then
				root.Anchored = false
				return
			end

			local position = data.Position
			local v = data.Duration - (workspace:GetServerTimeNow() - data.Timestamp)

			if data.Normal then
				position += data.Normal * data.Height
			end

			local cframe = CFrame.new(root.Position, position - createVector(0, 0.012345, 0))
			local magnitude = (cframe.Position - position).Magnitude
			local clone = F.Phase3.FallAura:Clone()
			clone.CFrame = CFrame.new(root.CFrame.Position, position)
			Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
			local v2 = true
			task.spawn(function()
				if magnitude > 0.01 then
					root.Anchored = true
					local lastTime = os.clock()

					while os.clock() - lastTime < v do
						local v3 = os.clock() - lastTime
						local v4 = v3 / v
						local v5 = math.min(1, v3 / 0.22)
						root.CFrame = cframe * CFrame.new(0, 0, -magnitude * v4 ^ 1.4) * CFrame.Angles(
							(1 - v5) * 3.141592653589793 / 2,
							0,
							0
						)
						RunService.PreSimulation:Wait()
					end

					root.CFrame = cframe * CFrame.new(0, 0, -magnitude)

					if data.Normal then
						root.CFrame = Util.Misc.AlignCFrame(
							CFrame.lookAt(createVector(0, 0, 0), cframe.LookVector * createVector(1, 0, 1)) + position,
							data.Normal
						)
					end
				else
					root.CFrame = CFrame.new(position) * (root.CFrame - root.Position)

					if data.Normal then
						root.CFrame = Util.Misc.AlignCFrame(
							CFrame.lookAt(createVector(0, 0, 0), root.CFrame.LookVector * createVector(1, 0, 1)) + position,
							data.Normal
						)
					end
				end

				v2 = false
				root.Anchored = false

				local function Explosion(cframe2, folder2, _)
					local destroyAfter = Util.DestroyAfter
					local raycastParams2 = RaycastParams.new()
					raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams2.FilterDescendantsInstances = {
						workspace._WorldOrigin,
						workspace.Characters,
						workspace.Enemies
					}

					-- equivalent calls inferred from this helper; original call sites unknown
					local function cameraShakeAt(position2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
						local v3 = value2 or 8
						local v4 = value3 or 14
						local v5 = value4 or 0.2
						local v6 = value5 or 0.7

						if (value or 100) > (workspace.CurrentCamera.CFrame.Position - position2).Magnitude then
							Util.CameraShaker:ShakeOnce(v3, v4, v5, v6)
						end
					end

					local function Scale(clone2, p)
						local position2 = cframe2.Position

						if clone2.ClassName ~= "Model" then
							local model = Instance.new("Model")
							Util.SetParentOverrideWithColor(model, clone2.Parent, player, "DragonFruitVFXColor")
							Util.SetParentOverrideWithColor(clone2, model, player, "DragonFruitVFXColor")
							clone2 = model
						end

						clone2:ScaleTo(p)
						local v3 = position2 + (clone2:GetPivot().Position - position2) * p
						clone2:PivotTo(clone2:GetPivot().Rotation + v3)
					end

					local function RockCrater(p, p2, data2)
						task.spawn(function()
							local rockType = data2.RockType
							local radius = data2.Radius
							local size = data2.Size
							local duration = data2.Duration
							local amount = data2.Amount
							local cframe3 = AlignCFrame(CFrame.new(p.Position), p.Normal) + p.Normal * 0.05
							local v3 = {}

							for _ = 1, amount do
								local v4 = size * math.random(15, 20) / 10
								local v5 = size * math.random(10, 20) / 10
								local v6 = size * math.random(10, 30) / 10
								local clone2 = rockType:Clone()
								clone2.Size = Vector3.new(v4, v5, v6) + Vector3.new(
									0,
									math.random(-v5 / 3, v5 / 3),
									math.random(-v6 / 3, v6 / 3)
								)
								Util.SetParentOverrideWithColor(clone2, p2, player, "DragonFruitVFXColor")
								destroyAfter(clone2, 7)
								table.insert(v3, clone2)
							end

							task.spawn(function()
								task.wait(duration * 2)

								for _, v4 in pairs(v3) do
									v4:Destroy()
								end

								v3 = nil
							end)

							local function GetXAndYPosition(p3, p4)
								return math.cos(p3) * p4, math.sin(p3) * p4
							end

							for k, v4 in pairs(v3) do
								local v5 = k * (6.283185307179586 / #v3)
								local v6 = math.cos(v5) * radius
								local v7 = math.sin(v5) * radius
								local _ = cframe3:ToObjectSpace(v4.CFrame).Y
								local position2 = (cframe3 * CFrame.new(v6, 0, v7)).Position
								v4.CFrame = CFrame.new(position2 + createVector(0, 0.1, 0), cframe3.Position)

								if math.random(1, 5) < 2 then
									v4.CFrame = CFrame.new(v4.Position, cframe3.Position) * CFrame.new(
										0,
										0,
										v4.Size.Z * math.random(5, 15) / 10
									)
								end

								local ray = Ray.new(v4.Position + createVector(0, 1, 0), createVector(-0, -2000, -0))
								local part, v8 = workspace:FindPartOnRayWithIgnoreList(
									ray,
									raycastParams2.FilterDescendantsInstances
								)

								if part then
									v4.Position = v8 + Vector3.new(0, -v4.Size.Y * math.random(5, 6) / 10, 0)
									v4.CFrame = CFrame.new(
										v4.Position,
										cframe3.Position + Vector3.new(0, math.random(-55, -45) + v4.Size.Y / 2, 0)
									) * CFrame.Angles(0, 0, (math.rad((math.random(-5, 5)))))
									v4.Material = part.Material
									v4.Color = part.Color
								else
									v4:Destroy()
									v3[v4] = nil
								end

								TweenService:Create(
									v4,
									TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
									{
										Position = v4.Position + Vector3.new(0, v4.Size.Y * math.random(3, 5) / 10, 0)
									}
								):Play()
								local v9 = v4
								local v10 = v4
								task.spawn(function()
									wait(duration + math.random(10, 50) / 100)
									local tween = TweenService:Create(
										v9,
										TweenInfo.new(
											0.5,
											Enum.EasingStyle.Back,
											Enum.EasingDirection.In,
											0,
											false,
											math.random(10, 35) / 100
										),
										{
											Position = v9.Position + Vector3.new(
												math.random(-1, 1),
												-v9.Size.Y * math.random(20, 25) / 10,
												math.random(-1, 1)
											)
										}
									)
									tween:Play()
									tween.Completed:Wait()
									v9:Destroy()
									v3[v9] = nil
								end)
							end
						end)
					end

					local function GroundFlyRocks(raycastResult, parent, data2, fn)
						local cframe3 = CFrame.new(raycastResult.Position)
						local material = raycastResult.Material
						local color = raycastResult.Instance.Color
						local rockType = data2.RockType
						local rockAmount = data2.RockAmount
						local rockSize = data2.RockSize
						local positionOffset = data2.PositionOffset
						local rockRotationAmount = data2.RockRotationAmount
						local rockRotationSpeed = data2.RockRotationSpeed
						local rockRotationPower = data2.RockRotationPower
						local duration = data2.Duration

						for _ = 1, rockAmount do
							task.spawn(function()
								local clone2 = rockType:Clone()
								clone2.Position = cframe3.Position + Vector3.new(
									math.random(-positionOffset, positionOffset),
									math.random(1, positionOffset),
									math.random(-positionOffset, positionOffset)
								)
								clone2.Size = Vector3.new(
									math.random(rockSize / 2, rockSize),
									math.random(rockSize / 2, rockSize),
									math.random(rockSize / 2, rockSize)
								)
								clone2.Material = material
								rocks:ApplyCollision(clone2, nil, true)
								clone2.Color = color
								clone2.Parent = parent
								destroyAfter(clone2, 7)
								task.spawn(function()
									for _, emitter in ipairs(clone2:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = true
										end
									end

									task.wait(duration + math.random(10, 50) / 100)

									for _, emitter in ipairs(clone2:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end

									TweenService:Create(
										clone2,
										TweenInfo.new(
											0.2,
											Enum.EasingStyle.Linear,
											Enum.EasingDirection.Out,
											0,
											false,
											0.25
										),
										{
											Size = createVector(0, 0, 0)
										}
									):Play()
								end)
								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
								bodyVelocity.P = 3000
								Util.SetParentOverrideWithColor(bodyVelocity, clone2, player, "DragonFruitVFXColor")
								destroyAfter(bodyVelocity, 7)
								fn(bodyVelocity, clone2)
								clone2.Attachment0.Orientation = createVector(0, 0, 0)
								local v3 = math.random(-rockRotationPower, rockRotationPower)
								local v4 = math.random(-rockRotationPower, rockRotationPower)
								local v5 = math.random(-rockRotationPower, rockRotationPower)
								local v6 = v3 / rockRotationAmount
								local v7 = v4 / rockRotationAmount
								local v8 = v5 / rockRotationAmount
								task.spawn(function()
									task.wait(0.05)

									for i = 1, rockRotationAmount do
										v3 = math.clamp(v3 - v6, 0, rockRotationPower * 1.5)
										v4 = math.clamp(v4 - v7, 0, rockRotationPower * 1.5)
										v5 = math.clamp(v5 - v8, 0, rockRotationPower * 1.5)
										local tween = TweenService:Create(
											clone2.Attachment0,
											TweenInfo.new(
												rockRotationSpeed,
												Enum.EasingStyle.Linear,
												Enum.EasingDirection.Out
											),
											{
												CFrame = clone2.Attachment0.CFrame * CFrame.Angles(
													math.rad(v3),
													math.rad(v4),
													(math.rad(v5))
												)
											}
										)
										tween:Play()
										tween.Completed:Wait()
										tween:Destroy()

										if i ~= rockRotationAmount then
											continue
										end

										for _, emitter in ipairs(clone2:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") then
												emitter.Enabled = false
											end
										end
									end

									clone2.AlignOrientation:Destroy()
								end)
								destroyAfter(clone2, 10)
							end)
						end
					end

					task.spawn(function()
						local position2 = cframe2.Position
						local character = localPlayer.Character

						if character ~= nil then
							local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart and (humanoidRootPart.Position - position2).Magnitude <= 400 then
								cameraShakeAt(cframe2.Position, 400, 7, 7, 0.15, 0.25) -- equivalent call inferred; original call site unknown
							end
						end

						if player == game.Players.LocalPlayer then
							Util.CameraShaker:ShakeOnce(15, 15, 0.2, 1.6)
						end

						local clone2 = F.Phase4.Explosion:Clone()
						Scale(clone2, 2)
						clone2.CFrame = cframe2
						Util.SetParentOverrideWithColor(clone2, folder2, player, "DragonFruitVFXColor")
						destroyAfter(clone2, 7)
						NumberRange.new(math.random(-90, 90))

						for _, emitter in ipairs(clone2:GetDescendants()) do
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

						DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
					end)
					local raycastResult = workspace:Raycast(
						cframe2.Position + createVector(0, 1, 0),
						createVector(-0, -100, -0),
						raycastParams2
					)

					if raycastResult then
						local cFrame2 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05
						local v4 = {
							Radius = 150,
							Size = 24,
							Duration = 3.5,
							Amount = 25,
							RockType = F.CraterRock
						}
						local v5 = {
							RockAmount = 10,
							RockSize = 20,
							PositionOffset = 250,
							RockRotationAmount = 5,
							RockRotationSpeed = 0.15,
							RockRotationPower = 100,
							Duration = 1.5,
							RockType = F.FlyRock
						}
						task.spawn(function()
							local rockType = v4.RockType
							local radius = v4.Radius
							local size = v4.Size
							local duration = v4.Duration
							local amount = v4.Amount
							local cframe3 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05
							local v6 = {}

							for _ = 1, amount do
								local v7 = size * math.random(15, 20) / 10
								local v8 = size * math.random(10, 20) / 10
								local v9 = size * math.random(10, 30) / 10
								local clone2 = rockType:Clone()
								clone2.Size = Vector3.new(v7, v8, v9) + Vector3.new(
									0,
									math.random(-v8 / 3, v8 / 3),
									math.random(-v9 / 3, v9 / 3)
								)
								Util.SetParentOverrideWithColor(clone2, folder2, player, "DragonFruitVFXColor")
								destroyAfter(clone2, 7)
								table.insert(v6, clone2)
							end

							task.spawn(function()
								task.wait(duration * 2)

								for _, v7 in pairs(v6) do
									v7:Destroy()
								end

								v6 = nil
							end)

							local function GetXAndYPosition(p, p2)
								return math.cos(p) * p2, math.sin(p) * p2
							end

							for k, v7 in pairs(v6) do
								local v8 = k * (6.283185307179586 / #v6)
								local v9 = math.cos(v8) * radius
								local v10 = math.sin(v8) * radius
								local _ = cframe3:ToObjectSpace(v7.CFrame).Y
								local position2 = (cframe3 * CFrame.new(v9, 0, v10)).Position
								v7.CFrame = CFrame.new(position2 + createVector(0, 0.1, 0), cframe3.Position)

								if math.random(1, 5) < 2 then
									v7.CFrame = CFrame.new(v7.Position, cframe3.Position) * CFrame.new(
										0,
										0,
										v7.Size.Z * math.random(5, 15) / 10
									)
								end

								local ray = Ray.new(v7.Position + createVector(0, 1, 0), createVector(-0, -2000, -0))
								local part, v11 = workspace:FindPartOnRayWithIgnoreList(
									ray,
									raycastParams2.FilterDescendantsInstances
								)

								if part then
									v7.Position = v11 + Vector3.new(0, -v7.Size.Y * math.random(5, 6) / 10, 0)
									v7.CFrame = CFrame.new(
										v7.Position,
										cframe3.Position + Vector3.new(0, math.random(-55, -45) + v7.Size.Y / 2, 0)
									) * CFrame.Angles(0, 0, (math.rad((math.random(-5, 5)))))
									v7.Material = part.Material
									v7.Color = part.Color
								else
									v7:Destroy()
									v6[v7] = nil
								end

								TweenService:Create(
									v7,
									TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
									{
										Position = v7.Position + Vector3.new(0, v7.Size.Y * math.random(3, 5) / 10, 0)
									}
								):Play()
								local v12 = v7
								local v13 = v7
								task.spawn(function()
									wait(duration + math.random(10, 50) / 100)
									local tween = TweenService:Create(
										v12,
										TweenInfo.new(
											0.5,
											Enum.EasingStyle.Back,
											Enum.EasingDirection.In,
											0,
											false,
											math.random(10, 35) / 100
										),
										{
											Position = v12.Position + Vector3.new(
												math.random(-1, 1),
												-v12.Size.Y * math.random(20, 25) / 10,
												math.random(-1, 1)
											)
										}
									)
									tween:Play()
									tween.Completed:Wait()
									v12:Destroy()
									v6[v12] = nil
								end)
							end
						end)
						GroundFlyRocks(raycastResult, folder2, v5, function(p, p2)
							local v6 = math.random(150, 180) * 2
							destroyAfter(p, math.random(10, 20) / 150)
							local v7 = v6 / 1.7
							p.Velocity = CFrame.new(
								p2.Position,
								(CFrame.new(p2.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
									0,
									0,
									-30
								)).Position + Vector3.new(
									math.random(-10, 10) / 5,
									math.random(80, 250),
									math.random(-10, 10) / 5
								)
							).LookVector * v7 * 2
						end)
						task.spawn(function()
							local clone2 = F.Phase4.GroundImpact:Clone()
							Scale(clone2, 2)
							clone2.CFrame = cFrame2
							Util.SetParentOverrideWithColor(clone2, folder2, player, "DragonFruitVFXColor")
							destroyAfter(clone2, 7)

							for _, emitter in ipairs(clone2:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v6 = emitter
								task.spawn(function()
									if v6:GetAttribute("EmitDelay") ~= 0 then
										task.wait(v6:GetAttribute("EmitDelay"))
									end

									v6:Emit(v6:GetAttribute("EmitCount"))
								end)
							end

							DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
							local clone3 = F.Phase4.GroundExplosion:Clone()
							Scale(clone3, 2)
							clone3.CFrame = cframe2
							Util.SetParentOverrideWithColor(clone3, folder2, player, "DragonFruitVFXColor")
							destroyAfter(clone3, 7)

							for _, emitter in ipairs(clone3:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v6 = emitter
								task.spawn(function()
									if v6:GetAttribute("EmitDelay") ~= 0 then
										task.wait(v6:GetAttribute("EmitDelay"))
									end

									v6:Emit(v6:GetAttribute("EmitCount"))
								end)
							end

							DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
							local clone4 = F.Phase4.GroundExplosion2:Clone()
							Scale(clone4, 2)
							clone4.CFrame = cframe2 * CFrame.Angles(-1.5707963267948966, 0, 0)
							Util.SetParentOverrideWithColor(clone4, folder2, player, "DragonFruitVFXColor")
							destroyAfter(clone4, 7)

							for _, emitter in ipairs(clone4:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v6 = emitter
								task.spawn(function()
									if v6:GetAttribute("EmitDelay") ~= 0 then
										task.wait(v6:GetAttribute("EmitDelay"))
									end

									v6:Emit(v6:GetAttribute("EmitCount"))
								end)
							end

							DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown
						end)
						local position2 = raycastResult.Position
						local character = localPlayer.Character

						if character ~= nil then
							local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart and (humanoidRootPart.Position - position2).Magnitude <= 190 then
								task.spawn(function()
									local clone2 = F.Phase4.CameraAura:Clone()
									clone2.CFrame = cframe2
									Util.SetParentOverrideWithColor(clone2, folder2, player, "DragonFruitVFXColor")
									clone2.Particle_1.Enabled = true
									clone2.Particle_2.Enabled = true
									task.delay(0.5, function()
										clone2.Particle_1.Enabled = false
										clone2.Particle_2.Enabled = false
									end)
									local v6 = 1.5 + tick()

									repeat
										clone2.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, cframe2.Position) * CFrame.new(
											0,
											0,
											-7
										)
										RunService.RenderStepped:Wait()
									until v6 - tick() <= 0

									clone2:Destroy()
								end)
							end
						end
					end
				end

				cframe = root.CFrame
				Util.Sound:Play("BF_WD_Western_F_Explosion_01", root)
				Explosion(cframe, folder, raycastParams)
				local position2 = cframe.Position
				local character = localPlayer.Character

				if character ~= nil then
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and (humanoidRootPart.Position - position2).Magnitude <= 150 then
						task.spawn(function()
							local screenColorEDX2 = F.Phase4.ScreenColorEDX2
							local v3 = game.Lighting:FindFirstChild("ScreenColorEDX2")

							if v3 then
								v3:SetAttribute("UsedTimes", v3:GetAttribute("UsedTimes") + 1)
							else
								v3 = Instance.new("ColorCorrectionEffect")
							end

							Util.SetParentOverrideWithColor(v3, game.Lighting, player, "DragonFruitVFXColor")
							local usedTimes = v3:GetAttribute("UsedTimes")
							local tween = TweenService:Create(v3, TweenInfo.new(0.05), {
								Brightness = screenColorEDX2.Brightness,
								Contrast = screenColorEDX2.Contrast,
								Saturation = screenColorEDX2.Saturation,
								TintColor = screenColorEDX2.TintColor
							})
							tween:Play()
							local bloomEffect = Instance.new("BloomEffect")
							Util.SetParentOverrideWithColor(bloomEffect, game.Lighting, player, "DragonFruitVFXColor")
							bloomEffect.Size += 10
							task.wait(0.05)
							local v4 = TweenService:Create(bloomEffect, TweenInfo.new(0.25), {
								Size = 54
							}):Play()
							task.delay(0.25, function()
								v4 = TweenService:Create(bloomEffect, TweenInfo.new(0.25), {
									Size = 0
								}):Play()
								task.wait(0.25)
								bloomEffect:Destroy()
							end)
							task.spawn(function()
								if v3:GetAttribute("UsedTimes") == usedTimes then
									tween = TweenService:Create(v3, TweenInfo.new(0.15), {
										TintColor = Util.WrapColor3ConstructorForTintColor(
											Color3.fromRGB(255, 255, 255),
											player,
											"DragonFruitVFXColor"
										),
										Brightness = 0,
										Contrast = 0,
										Saturation = 0
									})
									tween:Play()
									tween.Completed:Wait()

									if v3:GetAttribute("UsedTimes") == usedTimes then
										v3:Destroy()
									end
								end
							end)
						end)
					end
				end
			end)
			local v3 = {}

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				v3[emitter] = tick() + 1 / emitter.Rate
				emitter.Enabled = true
			end

			local clone2 = nil
			local renderSteppedConnection = nil

			local function doCameraFX()
				clone2 = F.Phase3.CameraFocus:Clone()
				Util.SetParentOverrideWithColor(clone2, folder, player, "DragonFruitVFXColor")
				renderSteppedConnection = RunService.RenderStepped:Connect(function()
					clone2.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
				end)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end

			if player == game.Players.LocalPlayer then
				doCameraFX()
			else
				viewerIsClose(root.Position, 400, doCameraFX) -- equivalent call inferred; original call site unknown
			end

			local now = tick()

			while true do
				for k, _ in pairs(v3) do
					k:Emit(1)
				end

				if now - tick() <= 0 then
					now = tick() + 0.1
					task.spawn(function()
						RingBeam(CFrame.new(root.Position, position) * CFrame.new(0, 0, -25), folder, true, player)
					end)
				end

				clone.CFrame = CFrame.new(root.Position, position)
				task.wait(0.01)

				if v2 ~= false then
					continue
				end

				for k, _ in pairs(v3) do
					k.Enabled = false
				end

				if clone2 == nil then
					break
				end

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(1)
				renderSteppedConnection:Disconnect()
				clone2:Destroy()
				break
			end
		end
	end
end