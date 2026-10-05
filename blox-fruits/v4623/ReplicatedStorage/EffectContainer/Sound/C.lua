local createVector = vector.create
local _ = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = workspace._WorldOrigin
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

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

local function AlignCFrame(data, p)
	local v = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p2, unit2, v, unit3)
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

local function TrailCurve(clone, position, position2, p)
	local magnitude = (position - position2).Magnitude
	clone.CFrame = CFrame.new(position, position2)
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	local v2 = math.random(20, 30)
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-v2, v2), math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-v2, v2), math.random(-v2, v2))
	local lastTime = tick()
	local v5 = magnitude / p / 60

	while tick() - lastTime < v5 do
		local v6 = (tick() - lastTime) / v5
		local v7 = cubicBezier(v6, position, v3, v4, position2)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v7, position2), v6)
		RunService.Heartbeat:Wait()
	end
end

local function LaserBeams(soundCSkill, tempo, folder, cFrame, p, clone, laserPoint)
	local v = tempo and 200 or 180
	local clone2 = nil
	local clone3 = nil
	local clone4 = nil
	local clone5, clone6, clone7, clone8, clone9, clone10

	if tempo then
		clone5 = soundCSkill.Phase2.Gold.StartImpact:Clone()
		clone5.CFrame = cFrame
		clone5.Parent = folder
		clone6 = soundCSkill.Phase2.Gold.BeamAfterImpact:Clone()
		clone6.CFrame = cFrame
		clone6.Parent = folder
		clone7 = soundCSkill.Phase2.Gold.HitImpact:Clone()
		clone7.CFrame = cFrame
		clone7.Parent = folder
		clone8 = soundCSkill.Phase2.Gold2.StartImpact:Clone()
		clone8.CFrame = cFrame
		clone8.Parent = folder
		clone9 = soundCSkill.Phase2.Gold2.BeamAfterImpact:Clone()
		clone9.CFrame = cFrame
		clone9.Parent = folder
		clone10 = soundCSkill.Phase2.Gold2.HitImpact:Clone()
		clone10.CFrame = cFrame
		clone10.Parent = folder
	else
		clone5 = soundCSkill.Phase2.Purple.StartImpact:Clone()
		clone5.CFrame = cFrame
		clone5.Parent = folder
		clone6 = soundCSkill.Phase2.Purple.BeamAfterImpact:Clone()
		clone6.CFrame = cFrame
		clone6.Parent = folder
		clone7 = soundCSkill.Phase2.Purple.HitImpact:Clone()
		clone7.CFrame = cFrame
		clone7.Parent = folder
		clone8 = soundCSkill.Phase2.Yellow.StartImpact:Clone()
		clone8.CFrame = cFrame
		clone8.Parent = folder
		clone9 = soundCSkill.Phase2.Yellow.BeamAfterImpact:Clone()
		clone9.CFrame = cFrame
		clone9.Parent = folder
		clone10 = soundCSkill.Phase2.Yellow.HitImpact:Clone()
		clone10.CFrame = cFrame
		clone10.Parent = folder
		clone2 = soundCSkill.Phase2.Red.StartImpact:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = folder
		clone3 = soundCSkill.Phase2.Red.BeamAfterImpact:Clone()
		clone3.CFrame = cFrame
		clone3.Parent = folder
		clone4 = soundCSkill.Phase2.Red.HitImpact:Clone()
		clone4.CFrame = cFrame
		clone4.Parent = folder
	end

	local lastTime = tick()
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0.0333
	TweenService:Create(numberValue, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Value = 0.09
	}):Play()
	local lastTime2 = tick()

	repeat
		clone:SetPrimaryPartCFrame(p * CFrame.Angles(0, (tick() - lastTime) * (0.333 - numberValue.Value) * 100, 0))

		if tick() - lastTime2 >= numberValue.Value then
			lastTime2 = tick()
			Util.Sound:Play("SoundFruitCLaser", p)

			for i = 1, math.clamp((0.1 - numberValue.Value) * 33 + math.random() * 0.5 + 0.25, 1, 3) do
				local v2 = math.random(1, tempo and 2 or 3)
				local clone11 = nil
				local folder2 = nil
				local folder3 = nil
				local folder4 = nil

				if tempo then
					if v2 == 1 then
						clone11 = soundCSkill.Phase2.Gold.DiscoBeam:Clone()
						folder3 = clone6
						folder2 = clone5
						folder4 = clone7
					elseif v2 == 2 then
						clone11 = soundCSkill.Phase2.Gold2.DiscoBeam:Clone()
						folder3 = clone9
						folder2 = clone8
						folder4 = clone10
					end
				elseif v2 == 1 then
					clone11 = soundCSkill.Phase2.Purple.DiscoBeam:Clone()
					folder3 = clone6
					folder2 = clone5
					folder4 = clone7
				elseif v2 == 2 then
					clone11 = soundCSkill.Phase2.Yellow.DiscoBeam:Clone()
					folder3 = clone9
					folder2 = clone8
					folder4 = clone10
				elseif v2 == 3 then
					clone11 = soundCSkill.Phase2.Red.DiscoBeam:Clone()
					folder3 = clone3
					folder2 = clone2
					folder4 = clone4
				end

				if i == 1 and laserPoint and laserPoint.Value and laserPoint.Value.Magnitude > 0.1 then
					clone11.CFrame = CFrame.new(p.p, laserPoint.Value)
					laserPoint.Value = createVector(0, 0, 0)
				else
					clone11.CFrame = p * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
				end

				clone11.CFrame *= CFrame.new(0, 0, -3.5)
				clone11.Parent = folder
				local ray, v3, v4 = Util.Ray(
					clone11.Position,
					clone11.CFrame.LookVector * v,
					{ workspace.Characters, workspace.Enemies }
				)
				local magnitude = (clone11.Position - v3).Magnitude
				local attach1 = clone11.Attach1
				attach1.Position = Vector3.new(0, 0, -magnitude)
				local v5 = magnitude / v * 0.25

				if ray then
					local v6 = v3
					local v7 = v4
					task.delay(v5, function()
						folder4.CFrame = AlignCFrame(CFrame.new(v6), v7) + v7 * 0.01

						for i2, emitter in pairs(folder4:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					end)
				end

				local tween = TweenService:Create(
					attach1,
					TweenInfo.new(v5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Position = attach1.Position
					}
				)
				attach1.Position = createVector(0, 0, 0)
				tween:Play()
				folder2.CFrame = clone11.CFrame

				for _, emitter in pairs(folder2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				folder3.CFrame = clone11.CFrame
				folder3.Size = Vector3.new(0, 0, magnitude)
				folder3.CFrame *= CFrame.new(0, 0, -folder3.Size.Z / 2)

				for _, emitter in pairs(folder3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				for _, beam in pairs(clone11:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local width0 = beam.Width0
					local tween2 = TweenService:Create(
						beam,
						TweenInfo.new(v5 / 2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{
							Width0 = width0 * 2.5,
							Width1 = width0 * 2.5
						}
					)
					beam.Width0 = 0
					beam.Width1 = 0
					tween2:Play()
					local v6 = beam
					task.spawn(function()
						tween2.Completed:Wait()
						tween2 = TweenService:Create(
							v6,
							TweenInfo.new(0.175, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween2:Play()
					end)
				end
			end
		end

		RunService.Heartbeat:Wait()
	until tick() - lastTime >= 3
end

local function FinalExplosion(soundCSkill, tempo, folder, clone, _, finalPosition)
	local count = 0

	repeat
		count += 1
		task.wait(0.03)
	until finalPosition.Value.Magnitude > 0.1 or count >= 100

	if count >= 100 then
		return
	end

	local cframe = CFrame.new(clone.PrimaryPart.Position, finalPosition.Value)
	local _, v = Util.Ray(
		cframe.Position,
		finalPosition.Value - cframe.Position,
		{ workspace.Characters, workspace.Enemies }
	)
	local magnitude = (cframe.Position - v).Magnitude
	local cFrame = cframe * CFrame.new(0, 0, -magnitude)
	local v3 = magnitude / 400 * 0.8
	local clone2 = soundCSkill.Phase3.ProjectileStartImpact:Clone()
	clone2.CFrame = cframe
	clone2.Parent = folder
	Util.Sound:Play("SoundFruit.Fiverr.SymphonicRadianceDiscoBallFire", cframe)
	DeleteImpactAfterDuration(clone2)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = emitter
		task.spawn(function()
			if v4:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v4:GetAttribute("EmitDelay"))
			end

			v4:Emit(v4:GetAttribute("EmitCount"))
		end)
	end

	local v4 = v3 * 40
	local lastTime = tick()

	while tick() - lastTime < v3 do
		local v5 = (tick() - lastTime) / v3
		clone:SetPrimaryPartCFrame(cframe:Lerp(cFrame, v5) * CFrame.new(
			math.sin(v5 * 6) * v4 * (1 - v5),
			math.cos(v5 * 6 + 1.5707963267948966) * v4 * (1 - v5),
			0
		))
		task.wait()
	end

	clone:SetPrimaryPartCFrame(cFrame)
	local v5 = Util.Sound:Play("SoundFruit.Fiverr.SymphonicRadianceDiscoBallExplosion", cFrame)
	task.delay(v5.TimeLength - 0.3, function()
		Util.Sound:FadeOut(v5, 0.3)
	end)
	local clone3 = soundCSkill.Phase3.Explosion:Clone()
	clone3.CFrame = cFrame
	clone3.Parent = folder
	DeleteImpactAfterDuration(clone3)

	for _, emitter in pairs(clone3:GetDescendants()) do
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

	task.spawn(function()
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 1, 0),
			CFrame.new(cFrame.Position).UpVector * -50,
			raycastParams
		)

		if raycastResult then
			local clone4 = soundCSkill.Phase3.GroundExplosion:Clone()
			clone4.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			clone4.Parent = folder
			DeleteImpactAfterDuration(clone4)

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	end)

	for _, child in pairs(clone:GetChildren()) do
		if child:IsA("ParticleEmitter") then
			child.Enabled = false
		elseif child:IsA("BasePart") or child:IsA("MeshPart") then
			child.Transparency = 1
		end
	end

	local clone4 = soundCSkill.Phase3.NotesBeam:Clone()
	clone4.CFrame = CFrame.new(cFrame.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
	clone4.Parent = folder
	local v6 = math.random(40, 50) / 100

	for _, descendant in pairs(clone4:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= 2
			descendant.CurveSize1 *= 2
			descendant.Width0 = descendant.Width0 * 2 * 1.5
			descendant.Width1 = descendant.Width1 * 2 * 1.5
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * 2,
				descendant.Position.Y * 2,
				descendant.Position.Z * 2
			)
		end
	end

	for _, beam in pairs(clone4:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v7 = beam
		task.spawn(function()
			local tweenInfo = TweenInfo.new(v6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			local curveSize0 = v7.CurveSize0
			local curveSize1 = v7.CurveSize1
			local tween = TweenService:Create(v7, tweenInfo, {
				CurveSize0 = curveSize0,
				CurveSize1 = curveSize1
			})
			v7.CurveSize0 = -curveSize0 / 5
			v7.CurveSize1 = -curveSize1 / 5
			tween:Play()
			tween.Completed:Wait()
			TweenService:Create(v7, TweenInfo.new(v6 / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Width0 = 0,
				Width1 = 0
			}):Play()
		end)
	end

	TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		CFrame = clone4.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 0.08726646259971647, 0)
	}):Play()
	task.spawn(function()
		local clone5 = soundCSkill.Phase3.Explosion2:Clone()
		clone5.CFrame = CFrame.new(cFrame.Position) * CFrame.new(0, 5, 0)
		clone5.Parent = folder

		for _, emitter in pairs(clone5:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v7 = emitter
			task.spawn(function()
				v7:Emit(v7:GetAttribute("EmitCount"))
				v7.Enabled = true
				task.wait(0.35)
				v7.Enabled = false
			end)
		end
	end)
	local v7 = { Color3.fromRGB(126, 61, 255), Color3.fromRGB(255, 57, 60), (Color3.fromRGB(255, 164, 74)) }
	local v8 = tempo and { Color3.fromRGB(255, 192, 66), Color3.fromRGB(255, 178, 55), (Color3.fromRGB(255, 172, 71)) } or v7
	local musicTrails = soundCSkill.MusicTrails
	local v9 = {
		"rbxassetid://15027759463",
		"rbxassetid://15027789941",
		"rbxassetid://15027825628",
		"rbxassetid://15027945079",
		"rbxassetid://15028032254"
	}

	for _ = 1, 10 do
		task.spawn(function()
			task.wait(math.random(1, 10) / 200)
			local clone5 = musicTrails.Trail1:Clone()
			clone5.Position = cFrame.Position + Vector3.new(
				math.random(-10, 10),
				math.random(-10, 10),
				math.random(-10, 10)
			)
			clone5.Parent = folder
			local position = clone5.Position
			local v10 = cFrame.Position + Vector3.new(
				math.random(-100, 100) / 2,
				math.random(-25, 100) / 2,
				math.random(-100, 100) / 2
			)
			local _ = (position - v10).Magnitude
			clone5.CFrame = CFrame.new(position, v10)
			local v11 = (position - v10) / 2
			local position2 = CFrame.new(CFrame.new(position) * (v11 / -1.5)).Position
			local position3 = CFrame.new(CFrame.new(v10) * (v11 / 1.5)).Position
			local v12 = math.random(4, 6) * 15
			local v13 = position2 + Vector3.new(math.random(-v12, v12), math.random(1, 2), math.random(-v12, v12))
			local v14 = position3 + Vector3.new(math.random(-v12, v12), math.random(1, 2), math.random(-v12, v12))
			local v15 = math.random(1, 3)
			local v16 = math.random(1, 5)

			for _, effect in pairs(clone5:GetDescendants()) do
				if not (effect:IsA("Trail") or effect:IsA("ParticleEmitter")) then
					continue
				end

				effect.Enabled = true

				if effect.Parent == clone5.Attachment then
					effect.Texture = v9[v16]
					effect:Emit(1)
				else
					effect.Color = ColorSequence.new(v8[v15], v8[v15])
				end
			end

			TrailCurve(clone5, position, v10, math.random(27, 30) / 10)
			local position4 = clone5.Position
			local v18 = clone5.Position + Vector3.new(
				math.random(-100, 100) / 10,
				math.random(-25, 100) / 10,
				math.random(-100, 100) / 10
			)
			local v19 = math.random(4, 6) * 5
			v13 += Vector3.new(math.random(-v19, v19), math.random(1, 2), math.random(-v19, v19))
			v14 += Vector3.new(math.random(-v19, v19), math.random(1, 2), math.random(-v19, v19))
			TrailCurve(clone5, position4, v18, math.random(20, 30) / 50)

			for _, effect in pairs(clone5:GetDescendants()) do
				if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end
		end)
	end

	for _ = 1, 9 do
		task.spawn(function()
			task.wait(math.random(1, 10) / 200)
			local clone5 = musicTrails.Trail1:Clone()
			clone5.Position = cFrame.Position + Vector3.new(
				math.random(-10, 10),
				math.random(-10, 10),
				math.random(-10, 10)
			)
			clone5.Anchored = false
			clone5.Parent = folder
			clone5.Attach0:Destroy()
			clone5.Attach1:Destroy()
			local v10 = math.random(1, 3)
			local v11 = math.random(1, 5)

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true

				if emitter.Parent == clone5.Attachment then
					emitter.Texture = v9[v11]
					emitter:Emit(1)
				else
					emitter.Color = ColorSequence.new(v8[v10], v8[v10])
				end
			end

			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			bodyVelocity.P = 3000
			bodyVelocity.Parent = clone5
			bodyVelocity.Velocity = CFrame.new(
				clone5.Position,
				clone5.Position + Vector3.new(
					math.random(-10, 10) * 15,
					math.random(80, 250),
					math.random(-10, 10) * 15
				)
			).LookVector * 100
			task.delay(0.125, function()
				bodyVelocity:Destroy()
			end)
			task.wait(0.5)
			rocks:ApplyCollision(clone5, nil, true)
			clone5.CanCollide = true
			task.wait(0.5)

			for _, effect in pairs(clone5:GetDescendants()) do
				if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end
		end)
	end
end

return function(data)
	local root = data.Root
	local laserPoint = data.LaserPoint
	local soundCSkill = script.SoundCSkill

	if data.Tempo then
		soundCSkill = script.SoundCSkillV2
	end

	local cFrame = root.CFrame

	if (workspace.CurrentCamera.CFrame.p - cFrame.p).Magnitude > 1200 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 15)
	task.spawn(function()
		local clone = soundCSkill.Phase1.StartSpotLight:Clone()
		clone.CFrame = CFrame.new(cFrame.Position) * CFrame.new(0, 10, 0)
		clone.Parent = folder

		for _ = 1, 5 do
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	local cFrame2 = cFrame + createVector(0, 20, 0)

	for _ = 1, 5 do
		task.spawn(function()
			local clone = soundCSkill.Phase1.SpinTrail:Clone()
			clone.CFrame = cFrame2 * CFrame.Angles(
				math.rad((math.random(-25, 25))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-25, 25))))
			)
			clone.Parent = folder

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
					descendant.Enabled = true
				elseif descendant:IsA("Weld") then
					descendant.C0 = descendant.Part0.CFrame:ToObjectSpace(descendant.Part1.CFrame) * CFrame.new(
						0,
						0,
						-math.random(-15, 30)
					)
					TweenService:Create(
						descendant,
						TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							C0 = CFrame.new(0, 0, 0)
						}
					):Play()
				end
			end

			for _ = 1, 4 do
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone.CFrame * CFrame.Angles(0, 2.9670597283903604, 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end
		end)
	end

	task.spawn(function()
		local clone = soundCSkill.Phase1.Aura1:Clone()
		clone.CFrame = cFrame2
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				v2.Enabled = true
				task.wait(0.25)
				v2.Enabled = false
			end)
		end
	end)
	task.spawn(function()
		local raycastResult = workspace:Raycast(
			cFrame2.Position + createVector(0, 1, 0),
			CFrame.new(cFrame2.Position).UpVector * -25,
			raycastParams
		)

		if raycastResult then
			local clone = soundCSkill.Phase1.Aura2:Clone()
			clone.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			clone.Parent = folder

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	end)
	local v2 = Util.Sound:Play(
		data.Tempo and "SoundFruit.Fiverr.TEMPOSymphonicRadianceDiscoBallSpin" or "SoundFruit.Fiverr.SymphonicRadianceDiscoBallSpin",
		cFrame
	)
	task.wait(0.35)
	local clone = soundCSkill.Phase1.DiscoBall:Clone()
	clone:SetPrimaryPartCFrame(cFrame2)
	clone.Parent = folder

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local tween = TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = part.Size * 5
		})
		part.Size = createVector(0, 0, 0)
		tween:Play()
	end

	local clone2 = soundCSkill.Phase1.StartImpact:Clone()
	clone2.CFrame = cFrame2
	clone2.Parent = folder
	DeleteImpactAfterDuration(clone2)

	for _, emitter in pairs(clone2:GetDescendants()) do
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

	LaserBeams(soundCSkill, data.Tempo, folder, cFrame, cFrame2, clone, laserPoint)
	Util.Sound:FadeOut(v2, 0.25)
	FinalExplosion(soundCSkill, data.Tempo, folder, clone, cFrame, data.FinalPosition)
end