local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local gasSkillZ = FX:WaitForChild("Gas").Z.GasSkillZ
local _WorldOrigin = workspace._WorldOrigin

local function DeleteImpactAfterDuration(folder)
	local v = 0

	for i, emitter in pairs(folder:GetDescendants()) do
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

local function TrailCurve(clone, cFrame, position, position2, cframe, cframe2, p, p2)
	local magnitude = (position - position2).Magnitude
	clone.CFrame = CFrame.new(position, position2)
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	local v2 = CFrame.new(position3, position3 + cFrame.LookVector) * cframe.Position
	local v3 = CFrame.new(position4, position4 + cFrame.LookVector) * cframe2.Position
	local lastTime = tick()
	local v4 = math.max(p2 and 0 or 0.3, magnitude / p / 60)

	while tick() - lastTime < v4 do
		local v5 = (tick() - lastTime) / v4
		local v6 = cubicBezier(v5, position, v2, v3, position2)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v6, position2), v5)
		RunService.Heartbeat:Wait()
	end
end

local function TornadoSlash(folder, data)
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
	clone.Parent = folder

	for i, descendant in pairs(clone:GetDescendants()) do
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

	for i, descendant in pairs(clone:GetDescendants()) do
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

	for i = 1, spinIterations do
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

	for i, beam in pairs(clone:GetDescendants()) do
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

local function TornadoSlashLoop(parent, data, p, part)
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
	local clone = slashType:Clone()
	clone.CFrame = slashCFrame
	clone.Anchored = false
	clone.Weld.Part0 = part
	clone.Parent = parent

	for i, descendant in pairs(clone:GetDescendants()) do
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

	for i, descendant in pairs(clone:GetDescendants()) do
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

	repeat
		local tween = TweenService:Create(
			clone.Weld,
			TweenInfo.new(slashSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * slashAngle
			}
		)
		tween:Play()
		tween.Completed:Wait()
	until p.Value == false

	for i, beam in pairs(clone:GetDescendants()) do
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

	TweenService:Create(clone.Weld, TweenInfo.new(slashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * slashAngle2
	}):Play()
end

local function GrabbedSmoke(model, duration, folder, boolValue)
	local humanoidRootPart = model.HumanoidRootPart
	task.spawn(function()
		local clone = gasSkillZ.Phase3.GrabOrbitClouds:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = folder
		clone.Weld.Part0 = humanoidRootPart

		for i, child in pairs(clone:GetChildren()) do
			if not child:IsA("BasePart") then
				continue
			end

			if child.Name == "ChainBeamPart1" then
				local part = child
				task.spawn(function()
					local slashCFrame = clone.CFrame * CFrame.Angles(0, 0, 0)
					TornadoSlashLoop(folder, {
						Multiplier = 0.5,
						Multiplier2 = 1,
						Mutliplier2Time = 0.35,
						BeamOutTime = 0.25,
						SlashAngle = CFrame.Angles(0, 1.7453292519943295, 0),
						SlashAngle2 = CFrame.Angles(0, 1.7453292519943295, 0),
						SlashType = gasSkillZ.Extras.BeamSlash2,
						SlashCFrame = slashCFrame,
						SlashSpeed = 0.05,
						SlashSpeed2 = 0.25
					}, boolValue, part)
				end)
			elseif child.Name == "ChainBeamPart2" then
				local part = child
				task.spawn(function()
					local slashCFrame = clone.CFrame * CFrame.Angles(0, 0, 0)
					TornadoSlashLoop(folder, {
						Multiplier = 0.7,
						Multiplier2 = 1,
						Mutliplier2Time = 0.35,
						BeamOutTime = 0.25,
						SlashAngle = CFrame.Angles(0, 1.3089969389957472, 0),
						SlashAngle2 = CFrame.Angles(0, 1.7453292519943295, 0),
						SlashType = gasSkillZ.Extras.BeamSlash2,
						SlashCFrame = slashCFrame,
						SlashSpeed = 0.05,
						SlashSpeed2 = 0.25
					}, boolValue, part)
				end)
			end

			for i2, weld in pairs(child:GetDescendants()) do
				if weld:IsA("Weld") then
					weld:SetAttribute(
						"Rotation",
						CFrame.Angles(
							math.rad(math.random(-90, 90) / 10),
							math.rad(math.random(-90, 90) / 10),
							(math.rad(math.random(-90, 90) / 10))
						)
					)
				elseif child:IsA("ParticleEmitter") then
					child.Enabled = true
				end
			end
		end

		local lastTime = tick()

		while true do
			for i, part in pairs(clone:GetChildren()) do
				if not (part:IsA("BasePart") and part.Name ~= "ChainBeamPart4") then
					continue
				end

				for i2, weld in pairs(part:GetDescendants()) do
					if not weld:IsA("Weld") then
						continue
					end

					local rotation = weld:GetAttribute("Rotation")
					TweenService:Create(weld, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * rotation
					}):Play()
				end
			end

			task.wait(0.25)

			if not (duration <= tick() - lastTime or boolValue.Value == false) then
				continue
			end

			boolValue.Value = false

			for i, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				elseif effect:IsA("Beam") then
					local v2 = effect
					task.spawn(function()
						local tween = TweenService:Create(
							v2,
							TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v2:Destroy()
					end)
				end
			end

			break
		end
	end)
	local clone = gasSkillZ.Phase3.GrabImpact:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	clone.Parent = folder
	DeleteImpactAfterDuration(clone)

	for i, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		task.spawn(function()
			if v:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v:GetAttribute("EmitDelay"))
			end

			v:Emit(v:GetAttribute("EmitCount"))
		end)
	end

	for i = 1, 3 do
		local v = i
		task.spawn(function()
			local v2 = 1
			local v3 = 1
			local cframe = CFrame.new(0, 0, 0)

			if v == 2 then
				cframe = CFrame.new(0, 1.15, 0)
				v3 = 0.45
				v2 = 0.55
			elseif v == 3 then
				cframe = CFrame.new(0, -1.75, 0)
				v3 = 0.6
				v2 = 0.85
			end

			local clone2 = gasSkillZ.Phase3.GrabBeamClouds:Clone()

			for i2, descendant in pairs(clone2:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= v3
					descendant.CurveSize1 *= v3
					descendant.Width0 *= v2
					descendant.Width1 *= v2
					local v4 = descendant
					task.spawn(function()
						local tween = TweenService:Create(v4, TweenInfo.new(1.25), {
							TextureSpeed = math.random(5, 15) / 100
						})
						local textureSpeed = v4.TextureSpeed
						tween:Play()
						task.wait(duration - 0.5)
						TweenService:Create(v4, TweenInfo.new(0.5), {
							TextureSpeed = textureSpeed
						}):Play()
						task.wait(0.5)
						TweenService:Create(v4, TweenInfo.new(0.5), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * v2,
						descendant.Position.Y * v2,
						descendant.Position.Z * v2
					)
				elseif descendant:IsA("BasePart") then
					descendant.Size = Vector3.new(
						descendant.Size.X * v2,
						descendant.Size.Y * v2,
						descendant.Size.Z * v2
					)
				elseif descendant:IsA("ParticleEmitter") then
					local v4 = descendant
					task.spawn(function()
						v4.Enabled = true
						task.wait(duration)
						v4.Enabled = false
					end)
				end
			end

			clone2.CFrame = humanoidRootPart.CFrame
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Parent = folder
			clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * cframe
		end)
	end
end

return function(data)
	local root = data.Root
	local cFrame = data.CFrame or CFrame.new(root.Position, data.EndPosition)
	local v = CFrame.new(data.EndPosition, cFrame.Position - root.CFrame.LookVector * 0.00123) * CFrame.Angles(
		0,
		3.141592653589793,
		0
	)
	local magnitude = (root.Position - v.Position).Magnitude
	local duration = data.Duration

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin

	if data.Stage > 0 then
		Util.Debris:AddItem(folder, 15)
	end

	if data.Stage == 0 then
		local holding = data.Holding
		local clone = gasSkillZ.Phase0.HandAura:Clone()
		clone.CFrame = root.Parent.RightHand.CFrame
		clone.Parent = folder
		clone.WeldConstraint.Part1 = root.Parent.RightHand
		clone.Anchored = false
		clone.Massless = true
		local clone2 = gasSkillZ.Phase0.HandAura:Clone()
		clone2.CFrame = root.Parent.LeftHand.CFrame
		clone2.Parent = folder
		clone2.WeldConstraint.Part1 = root.Parent.LeftHand
		clone2.Anchored = false
		clone2.Massless = true
		local v2 = Util.Sound:Play("BF_GASFRUIT_UNTR_SuffocatingFlames_ChargeLoo", root)

		for k, v3 in pairs({ clone2:GetDescendants(), clone:GetDescendants() }) do
			for k2, emitter in pairs(v3) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		task.wait(0.35)

		for k, v3 in pairs({ clone2:GetDescendants(), clone:GetDescendants() }) do
			for k2, emitter in pairs(v3) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		task.wait(5)
		folder:Destroy()
	elseif data.Stage == 1 then
		task.spawn(function()
			root.Anchored = true
			local lastTime = os.clock()

			while os.clock() - lastTime < duration do
				local v2 = (os.clock() - lastTime) / duration
				root.CFrame = v * CFrame.new(0, 0, magnitude * (1 - v2 ^ 0.5))
				RunService.PreSimulation:Wait()
			end

			root.CFrame = data.EndCFrame
			root.Anchored = false
		end)
		local position = v.Position
		local magnitude2 = (cFrame.Position - position).Magnitude
		local clone = gasSkillZ.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder
		Util.Sound:Play("BF_GASFRUIT_UNTR_SuffocatingFumes_Fire_01", root)
		DeleteImpactAfterDuration(clone)

		for i, emitter in pairs(clone:GetDescendants()) do
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

		task.spawn(function()
			local slashCFrame = cFrame * CFrame.new(0, 0, -5)
			TornadoSlash(folder, {
				Multiplier = 0.75,
				Multiplier2 = 1.35,
				Mutliplier2Time = 0.25,
				BeamOutTime = 0.25,
				SlashAngle = CFrame.Angles(0, 0, -0.8726646259971648),
				SlashAngle2 = CFrame.Angles(0, 0, -1.7453292519943295),
				SlashType = gasSkillZ.Extras.BeamSlash,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.075,
				SlashSpeed2 = 0.75,
				SpinIterations = 3
			})
		end)
		task.spawn(function()
			local slashCFrame = cFrame * CFrame.new(0, 0, -10)
			TornadoSlash(folder, {
				Multiplier = 0.95,
				Multiplier2 = 1.3,
				Mutliplier2Time = 0.35,
				BeamOutTime = 0.25,
				SlashAngle = CFrame.new(0, 0, 7) * CFrame.Angles(0, 0, 1.7453292519943295),
				SlashAngle2 = CFrame.Angles(0, 0, 1.7453292519943295),
				SlashType = gasSkillZ.Extras.BeamSlash,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.05,
				SlashSpeed2 = 0.25,
				SpinIterations = 3
			})
		end)
		local clone2 = gasSkillZ.Phase1.Dash:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = folder
		clone2.Weld.Part0 = root

		for i, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.spawn(function()
			task.wait(duration * 0.85)

			for i, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter.Parent.Name == "LineAttachment" then
					emitter.Enabled = false
				end
			end

			task.wait(duration * 0.15)

			for i, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
		local v2 = true
		task.spawn(function()
			local raycastParams = RaycastParams.new()
			raycastParams.IgnoreWater = false
			raycastParams.FilterDescendantsInstances = {
				workspace._WorldOrigin,
				workspace.Characters,
				workspace.Enemies
			}
			local clone3 = gasSkillZ.Extras.GroundGas:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = folder

			for i, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local v3 = false

			while true do
				local raycastResult = workspace:Raycast(
					root.Position + createVector(0, 1, 0),
					CFrame.new(root.Position).UpVector * -10,
					raycastParams
				)

				if raycastResult then
					clone3.CFrame = CFrame.new(raycastResult.Position + createVector(0, 0.5, 0))

					if v3 == false then
						v3 = true

						for i, emitter in pairs(clone3:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end
					end
				elseif v3 == true then
					v3 = false

					for i, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				task.wait()

				if v2 ~= false then
					continue
				end

				for i, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				break
			end
		end)
		task.wait(duration)
		v2 = false
	elseif data.Stage == 2 then
		root.CFrame = data.CFrame
		local raycastParams = RaycastParams.new()
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

		for i = 1, 2 do
			local v2 = i
			task.spawn(function()
				local clone = gasSkillZ.Phase2.GrabTrailStartImpact:Clone()

				if v2 == 1 then
					clone.CFrame = cFrame * CFrame.new(10, 0, -5)
				elseif v2 == 2 then
					clone.CFrame = cFrame * CFrame.new(-10, 0, -5)
				end

				clone.Parent = folder

				for i2, emitter in pairs(clone:GetDescendants()) do
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

				task.spawn(function()
					local slashCFrame = nil

					if v2 == 1 then
						slashCFrame = cFrame * CFrame.new(10, 0, -5)
					elseif v2 == 2 then
						slashCFrame = cFrame * CFrame.new(-10, 0, -5) * CFrame.Angles(0, 0, 0)
					end

					local v4 = nil
					local v5

					if v2 == 1 then
						v5 = {
							Multiplier = 0.35,
							Multiplier2 = 1.35,
							Mutliplier2Time = 0.25,
							BeamOutTime = 0.25,
							SlashAngle = CFrame.Angles(0, 0, -2.6179938779914944),
							SlashAngle2 = CFrame.Angles(0, 0, -2.9670597283903604),
							SlashType = gasSkillZ.Extras.BeamSlash,
							SlashCFrame = slashCFrame,
							SlashSpeed = 0.125,
							SlashSpeed2 = 0.75,
							SpinIterations = 3
						}
					else
						v5 = v2 == 2 and {
							Multiplier = 0.35,
							Multiplier2 = 1.35,
							Mutliplier2Time = 0.25,
							BeamOutTime = 0.25,
							SlashAngle = CFrame.Angles(0, 0, 2.6179938779914944),
							SlashAngle2 = CFrame.Angles(0, 0, 2.9670597283903604),
							SlashType = gasSkillZ.Extras.BeamSlash,
							SlashCFrame = slashCFrame,
							SlashSpeed = 0.125,
							SlashSpeed2 = 0.75,
							SpinIterations = 3
						} or v4
					end

					TornadoSlash(folder, v5)
				end)
				task.spawn(function()
					local slashCFrame = nil

					if v2 == 1 then
						slashCFrame = cFrame * CFrame.new(10, 0, -10)
					elseif v2 == 2 then
						slashCFrame = cFrame * CFrame.new(-10, 0, -10) * CFrame.Angles(0, 0, 0)
					end

					local v4 = nil
					local v5

					if v2 == 1 then
						v5 = {
							Multiplier = 0.5,
							Multiplier2 = 1.3,
							Mutliplier2Time = 0.35,
							BeamOutTime = 0.25,
							SlashAngle = CFrame.new(0, 0, 3) * CFrame.Angles(0, 0, -1.7453292519943295),
							SlashAngle2 = CFrame.Angles(0, 0, -1.7453292519943295),
							SlashType = gasSkillZ.Extras.BeamSlash,
							SlashCFrame = slashCFrame,
							SlashSpeed = 0.05,
							SlashSpeed2 = 0.25,
							SpinIterations = 3
						}
					else
						v5 = v2 == 2 and {
							Multiplier = 0.5,
							Multiplier2 = 1.3,
							Mutliplier2Time = 0.35,
							BeamOutTime = 0.25,
							SlashAngle = CFrame.new(0, 0, 3) * CFrame.Angles(0, 0, 1.7453292519943295),
							SlashAngle2 = CFrame.Angles(0, 0, 1.7453292519943295),
							SlashType = gasSkillZ.Extras.BeamSlash,
							SlashCFrame = slashCFrame,
							SlashSpeed = 0.05,
							SlashSpeed2 = 0.25,
							SpinIterations = 3
						} or v4
					end

					TornadoSlash(folder, v5)
				end)

				for i2 = 1, 7 do
					task.spawn(function()
						local clone2 = gasSkillZ.Phase2.SmallGrabTrail:Clone()

						if v2 == 1 then
							clone2.CFrame = cFrame * CFrame.new(2.5, 0, 0)
						elseif v2 == 2 then
							clone2.CFrame = cFrame * CFrame.new(-2.5, 0, 0)
						end

						clone2.Parent = folder
						local v3 = math.random(30, 35) / 10
						local v4 = nil

						for i3, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end

						for i3 = 1, 5 do
							local cframe = CFrame.new(
								math.random(-10, 10),
								math.random(-10, 10) / 2,
								math.random(-10, 10)
							)
							local cframe2 = CFrame.new(
								math.random(-10, 10),
								math.random(-10, 10) / 2,
								math.random(-10, 10)
							)

							if v2 == 1 then
								if i3 == 5 then
									v4 = cFrame * CFrame.new(0, 0, -50).Position
								elseif i3 == 1 then
									v4 = cFrame * CFrame.new(5, math.random(-10, 10), -(1 * 10)).Position
								elseif i3 == 2 then
									v4 = cFrame * CFrame.new(10, math.random(-10, 10), -(2 * 10)).Position
								elseif i3 == 3 then
									v4 = cFrame * CFrame.new(15, math.random(-10, 10), -(3 * 10)).Position
								elseif i3 == 4 then
									v4 = cFrame * CFrame.new(10, math.random(-10, 10), -(4 * 10)).Position
								end
							elseif v2 == 2 then
								if i3 == 5 then
									v4 = cFrame * CFrame.new(0, 0, -50).Position
								elseif i3 == 1 then
									v4 = cFrame * CFrame.new(-5, math.random(-10, 10), -(1 * 10)).Position
								elseif i3 == 2 then
									v4 = cFrame * CFrame.new(-10, math.random(-10, 10), -(2 * 10)).Position
								elseif i3 == 3 then
									v4 = cFrame * CFrame.new(-15, math.random(-10, 10), -(3 * 10)).Position
								elseif i3 == 4 then
									v4 = cFrame * CFrame.new(-10, math.random(-10, 10), -(4 * 10)).Position
								end
							end

							if not v4 then
								continue
							end

							local position = clone2.Position
							local v5
							v5, v4 = Util.Ray(position, v4 - position, { workspace.Characters, workspace.Enemies })
							_ = v5
							TrailCurve(clone2, cFrame, position, v4, cframe, cframe2, v3, true)
						end

						for i3, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end)
				end

				local v3 = true
				local clone2 = gasSkillZ.Phase2.GrabTrail:Clone()

				if v2 == 1 then
					clone2.CFrame = cFrame * CFrame.new(2.5, 0, 0)
				elseif v2 == 2 then
					clone2.CFrame = cFrame * CFrame.new(-2.5, 0, 0)
				end

				clone2.Parent = folder
				local position = clone2.Position
				local position2 = v.Position
				local cframe = nil
				local cframe2 = nil

				if v2 == 1 then
					cframe = CFrame.new(25, 0, 5)
					cframe2 = CFrame.new(10, 0, -5)
				elseif v2 == 2 then
					cframe = CFrame.new(-25, 0, 5)
					cframe2 = CFrame.new(-10, 0, -5)
				end

				for i2, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.spawn(function()
					local clone3 = gasSkillZ.Extras.GroundGas:Clone()
					clone3.CFrame = cFrame
					clone3.Parent = folder

					for i2, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					local v4 = false

					while true do
						local raycastResult = workspace:Raycast(
							clone2.Position + createVector(0, 1, 0),
							CFrame.new(clone2.Position).UpVector * -10,
							raycastParams
						)

						if raycastResult then
							clone3.CFrame = CFrame.new(raycastResult.Position + createVector(0, 0.5, 0))

							if v4 == false then
								v4 = true

								for i2, emitter in pairs(clone3:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = true
									end
								end
							end
						elseif v4 == true then
							v4 = false

							for i2, emitter in pairs(clone3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end

						task.wait()

						if v3 ~= false then
							continue
						end

						for i2, emitter in pairs(clone3:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						break
					end
				end)
				TrailCurve(clone2, cFrame, position, position2, cframe, cframe2, 3)
				v3 = false

				for i2, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end
	elseif data.Stage == 3 then
		local duration2 = data.Duration or 3
		local delay = data.Delay or 0.5
		local boolValue = Instance.new("BoolValue")
		boolValue.Value = true
		local model = Instance.new("Model", folder)
		local part = Instance.new("Part")
		part.Name = "HumanoidRootPart"
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 1
		part.CFrame = data.CFrame:Lerp(data.EndCFrame, 0.5)
		part.Parent = model
		GrabbedSmoke(model, duration2, folder, boolValue)
		local humanoidRootPart = model.HumanoidRootPart
		Util.Sound:Play("BF_GASFRUIT_UNTR_SuffocatingFumes_Hit_01", root)
		task.wait(delay)
		task.spawn(function()
			root.Anchored = true
			local endCFrame = data.EndCFrame
			local lastTime = os.clock()

			while os.clock() - lastTime < 0.15 do
				local v2 = (os.clock() - lastTime) / 0.15
				root.CFrame = CFrame.new(data.CFrame.Position:Lerp(data.EndPosition, v2)) * (endCFrame - endCFrame.p)
				RunService.PreSimulation:Wait()
			end

			root.Anchored = false
			root.CFrame = CFrame.new(data.CFrame.Position:Lerp(data.EndPosition, 1)) * (endCFrame - endCFrame.p)
		end)
		local clone = gasSkillZ.Phase3.Dash:Clone()
		clone.CFrame = cFrame
		clone.Parent = folder
		clone.Anchored = false
		clone.Weld.Part0 = root

		for i, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.spawn(function()
			task.wait(0.175)

			for i, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
		task.spawn(function()
			local currentCamera = workspace.CurrentCamera

			if game.Players.LocalPlayer.Character.HumanoidRootPart ~= humanoidRootPart and game.Players.LocalPlayer.Character.HumanoidRootPart ~= root then
				return
			end

			Util.CameraShaker:ShakeOnce(5, 7, 0.75, 0.75)
			local screenColorGZ = gasSkillZ.Phase3.ScreenColorGZ
			local v2 = game.Lighting:FindFirstChild("ScreenColorGZ")

			if v2 then
				v2:SetAttribute("UsedTimes", v2:GetAttribute("UsedTimes") + 1)
			else
				v2 = Instance.new("ColorCorrectionEffect")
			end

			v2.Parent = game.Lighting
			local usedTimes = v2:GetAttribute("UsedTimes")
			local tween = TweenService:Create(v2, TweenInfo.new(0.1), {
				Brightness = screenColorGZ.Brightness,
				Contrast = screenColorGZ.Contrast,
				Saturation = screenColorGZ.Saturation,
				TintColor = screenColorGZ.TintColor
			})
			tween:Play()
			local bloomEffect = Instance.new("BloomEffect")
			bloomEffect.Parent = game.Lighting
			bloomEffect.Size += 10
			local v3 = TweenService:Create(bloomEffect, TweenInfo.new(0.1), {
				Size = 54
			}):Play()
			task.delay(0.1, function()
				v3 = TweenService:Create(bloomEffect, TweenInfo.new(0.25), {
					Size = 0
				}):Play()
				task.wait(0.25)
				bloomEffect:Destroy()
			end)
			task.wait(0.1)
			task.spawn(function()
				tween = TweenService:Create(v2, TweenInfo.new(0.1), {
					Brightness = 0.15,
					Contrast = screenColorGZ.Contrast,
					Saturation = -1,
					TintColor = Color3.fromRGB(214, 198, 255)
				})
				tween:Play()
				task.wait(0.1)

				if v2:GetAttribute("UsedTimes") == usedTimes then
					tween = TweenService:Create(v2, TweenInfo.new(0.15), {
						TintColor = Color3.fromRGB(255, 255, 255),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					})
					tween:Play()
					tween.Completed:Wait()

					if v2:GetAttribute("UsedTimes") == usedTimes then
						v2:Destroy()
					end
				end
			end)
			task.wait(1)
		end)
		local clone2 = gasSkillZ.Phase3.Explosion:Clone()
		clone2.CFrame = CFrame.new(humanoidRootPart.Position)
		clone2.Parent = folder

		for i, emitter in pairs(clone2:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Funky")) then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				for i2 = 1, 10 do
					local clone = v2:Clone()
					clone.Parent = v2.Parent
				end
			end)
		end

		for i, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))

				if v2:GetAttribute("Funky") then
					task.spawn(function()
						for i2 = 1, 25 do
							v2.Acceleration = Vector3.new(
								math.random(-100, 100),
								math.random(-50, 100),
								math.random(-100, 100)
							)
							task.wait(math.random(10, 20) / 200)
						end

						v2.Acceleration = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
					end)
				end
			end)
		end

		boolValue.Value = false
	end
end