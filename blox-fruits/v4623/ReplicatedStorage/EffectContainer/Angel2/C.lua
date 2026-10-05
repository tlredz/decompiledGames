local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local angelC = FX:WaitForChild("Angel2").AngelC
local Util = require(game.ReplicatedStorage.Util)
local cameraShaker = Util.CameraShaker
local _WorldOrigin = workspace._WorldOrigin
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

-- equivalent calls inferred from this helper; original call sites unknown
local function viewerIsClose(position, p, fn)
	local character = localPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= p then
			fn()
		end
	end
end

local function TornadoSlash(folder, data, _)
	local multiplier = data.Multiplier
	local multiplier2 = data.Multiplier2
	local multiplier2Time = data.Multiplier2Time
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
					TweenInfo.new(multiplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
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
				TweenInfo.new(multiplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
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

local function HoldTornadoSlash(parent, data)
	local multiplier = data.Multiplier
	local _ = data.Multiplier2
	local _ = data.Multiplier2Time
	local _ = data.BeamOutTime
	local _ = data.SlashAngle
	local _ = data.SlashAngle2
	local slashType = data.SlashType
	local slashCFrame = data.SlashCFrame
	local _ = data.SlashSpeed
	local _ = data.SlashSpeed2
	local _ = data.SpinIterations
	local clone = slashType:Clone()
	clone.CFrame = slashCFrame
	clone.Parent = parent

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

	return clone
end

local function SphereSpin(boolValue, tweensByTween, clone, clone2, folder, numberValue, folder2)
	local cFrame = clone.CFrame
	local v = {
		Multiplier = 0.5,
		Multiplier2 = 12,
		Multiplier2Time = 1.5,
		BeamOutTime = 0.5,
		SlashAngle = CFrame.Angles(0, 2.9670597283903604, 0),
		SlashAngle2 = CFrame.Angles(0, 2.9670597283903604, 0),
		SlashType = angelC.Phase1.BeamSlash,
		SlashCFrame = cFrame,
		SlashSpeed = 0.07,
		SlashSpeed2 = 0.75,
		SpinIterations = 10
	}
	local folder3 = HoldTornadoSlash(folder2, v)
	folder3.Parent = folder2

	for _, descendant in pairs(folder3:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.Enabled = true
			local v2 = descendant
			local multiplier2Time = v.Multiplier2Time
			task.spawn(function()
				local tween = TweenService:Create(
					v2,
					TweenInfo.new(multiplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						CurveSize0 = v2.CurveSize0 * v.Multiplier2,
						CurveSize1 = v2.CurveSize1 * v.Multiplier2,
						Width0 = v2.Width0 * v.Multiplier2,
						Width1 = v2.Width1 * v.Multiplier2
					}
				)
				v2.Width0 = 0
				v2.Width1 = 0
				tween:Play()
				tweensByTween[tween] = tween
			end)
		elseif descendant:IsA("Attachment") then
			local multiplier2Time = v.Multiplier2Time
			local tween = TweenService:Create(
				descendant,
				TweenInfo.new(multiplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					Position = Vector3.new(
						descendant.Position.X * v.Multiplier2,
						descendant.Position.Y * v.Multiplier2,
						descendant.Position.Z * v.Multiplier2
					)
				}
			)
			tween:Play()
			tweensByTween[tween] = tween
		end
	end

	local lastTime = nil

	while true do
		if lastTime == nil or tick() - lastTime >= 0.25 then
			lastTime = tick()
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.Angles(0, 0.17453292519943295, 0)
				}
			)
			tween:Play()
			local tween2 = TweenService:Create(
				clone2,
				TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone2.CFrame * CFrame.Angles(0, 0.6108652381980153, 0)
				}
			)
			tween2:Play()
			local tween3 = TweenService:Create(
				folder3,
				TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = folder3.CFrame * v.SlashAngle
				}
			)
			tween3:Play()
			tweensByTween[tween2] = tween2
			tweensByTween[tween] = tween
			tweensByTween[tween3] = tween3
		end

		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local mainSize = emitter:GetAttribute("MainSize")
			emitter.Size = NumberSequence.new(mainSize * numberValue.Value)
		end

		RunService.Heartbeat:Wait()

		if boolValue.Value ~= false then
			continue
		end

		for _, beam in pairs(folder3:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local v2 = beam
			local beamOutTime = v.BeamOutTime
			task.spawn(function()
				local tween = TweenService:Create(
					v2,
					TweenInfo.new(beamOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
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

		TweenService:Create(folder3, TweenInfo.new(v.SlashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = folder3.CFrame * v.SlashAngle2
		}):Play()
		break
	end
end

local _ = {
	Head = true,
	UpperTorso = true,
	LowerTorso = true,
	RightUpperArm = true,
	RightLowerArm = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	RightHand = true,
	LeftHand = true,
	RightFoot = true,
	LeftFoot = true
}

local function InsideDomain(cframe, folder, victims, parent)
	local clone = angelC.Phase2.MainDomainSphereCellShade:Clone()
	clone.Size = createVector(480, 480, 480)
	clone.CFrame = cframe
	clone.Parent = folder
	local clone2 = angelC.Phase2.MainDomainSphere:Clone()
	clone2.Size = clone.Size
	clone2.CFrame = cframe
	clone2.Parent = folder
	task.spawn(function()
		clone.Transparency = 0
		TweenService:Create(clone2, TweenInfo.new(0.05), {
			Transparency = clone2.Transparency
		})
		clone2.Transparency = 0
		local v = {}
		local fn

		for _, item in pairs(victims) do
			local humanoidRootPart = item[1]:FindFirstChild("HumanoidRootPart")
			local lowerTorso = item[1]:FindFirstChild("LowerTorso")

			if not lowerTorso then
				continue
			end

			local root = lowerTorso:FindFirstChild("Root")

			if not (root and humanoidRootPart) then
				continue
			end

			local v2 = humanoidRootPart == game.Players.LocalPlayer.Character.HumanoidRootPart

			if v2 then
				workspace.CurrentCamera.CameraSubject = item[1].Head
				workspace.CurrentCamera.CameraType = Enum.CameraType.Track
				local v3 = item

				fn = function()
					workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
					workspace.CurrentCamera.CameraSubject = v3[1].Humanoid
				end
			end

			local v3 = v2 and { false, root } or {
				humanoidRootPart,
				false,
				CFrame.new(item[2]) * (humanoidRootPart.CFrame - humanoidRootPart.Position) + createVector(0, 15000, 0)
			}
			table.insert(v, v3)
		end

		local v2 = parent
		local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart")
		local lowerTorso = v2:FindFirstChild("LowerTorso")

		if lowerTorso then
			local root = lowerTorso:FindFirstChild("Root")

			if root and humanoidRootPart then
				local v3 = humanoidRootPart == game.Players.LocalPlayer.Character.HumanoidRootPart and { false, root } or {
					humanoidRootPart,
					false,
					humanoidRootPart.CFrame + createVector(0, 15000, 0)
				}
				table.insert(v, v3)
			end
		end

		local part

		if parent == game.Players.LocalPlayer.Character then
			part = Instance.new("Part", workspace)
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.Transparency = 1
			part.CFrame = cframe + createVector(0, 35, 0)
			workspace.CurrentCamera.CameraSubject = parent.Head
			workspace.CurrentCamera.CameraType = Enum.CameraType.Track
		end

		task.spawn(function()
			local lastTime = os.clock()

			while os.clock() - lastTime < 2.4 and v do
				for _, v3 in pairs(v) do
					if not v3[2] or v3[2].Transform.Y > 7500 then
						continue
					end

					v3[2].Transform += createVector(0, 15000, 0)
				end

				RunService.PreSimulation:Wait()
			end
		end)
		local lastTime = os.clock()

		while os.clock() - lastTime < 2.4 do
			for _, v3 in pairs(v) do
				if not v3[1] then
					continue
				end

				v3[1].Anchored = true
				v3[1].Velocity = createVector(0, 0, 0)
				v3[1].CFrame = v3[3]
			end

			RunService.Stepped:Wait()
		end

		if part then
			part:Destroy()
		end

		if parent == game.Players.LocalPlayer.Character then
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			workspace.CurrentCamera.CameraSubject = parent.Humanoid
		end

		if fn then
			fn()
		end

		task.spawn(function()
			for _, v3 in pairs(v) do
				if not v3[1] then
					continue
				end

				v3[1].Anchored = false
				v3[1].CFrame = v3[3] - createVector(0, 15000, 0)
				v3[1].Velocity += createVector(0, 1, 0)
			end

			v = nil
		end)
		task.wait(0.15)
		TweenService:Create(clone, TweenInfo.new(0.15), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.15), {
			Transparency = 1
		}):Play()
	end)
end

local function GroundReflection(cFrame, parent, p)
	local clone = angelC.Phase2.BorderClouds:Clone()
	clone.CFrame = cFrame
	clone.Parent = parent

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		task.spawn(function()
			v.Enabled = true
			task.wait(0.7999999999999999)
			v.Enabled = false
		end)
	end

	local clone2 = angelC.Phase2.Ripple:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = parent

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter
		task.spawn(function()
			if v.Parent == clone2.Attachment then
				v:Emit(1)
				return
			end

			v.Enabled = true
			task.wait(1.44)
			v.Enabled = false
		end)
	end

	local v = cFrame - createVector(0, 15000, 0)
	local v2 = v * CFrame.new(0, 0, -160)
	local raycastResult = workspace:Raycast(
		v2.Position + createVector(0, 1, 0),
		CFrame.new(v2.Position).UpVector * -10,
		p
	)

	if raycastResult then
		local v3 = CFrame.new(raycastResult.Position + createVector(0, 0.5, 0)) + createVector(0, 15000, 0)
		local cframe = CFrame.new(v3.Position, v3.Position + v.LookVector)
		local clone3 = angelC.Phase2.Moon:Clone()
		clone3.CFrame = cframe
		clone3.Parent = parent

		for _, descendant in pairs(clone3:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				local v4 = descendant
				task.spawn(function()
					if v4.Parent == clone3.MoonClouds then
						v4:Emit(v4:GetAttribute("EmitCount"))
						return
					end

					v4.Enabled = true
					task.wait(1.7999999999999998)
					v4.Enabled = false
				end)
			elseif descendant:IsA("Attachment") then
				local v4 = descendant
				task.spawn(function()
					local tween = TweenService:Create(
						v4,
						TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{
							Position = v4.Position
						}
					)
					v4.Position = createVector(0, 0, 0)
					tween:Play()
				end)
			end
		end
	end

	local raycastResult2 = workspace:Raycast(
		v.Position + createVector(0, 1, 0),
		CFrame.new(v.Position).UpVector * -10,
		p
	)

	if raycastResult2 then
		local clone3 = angelC.Phase2.CloudReflection:Clone()
		clone3.CFrame = CFrame.new(raycastResult2.Position + createVector(0, 15000, 0))
		clone3.Parent = parent

		for _, emitter in pairs(clone3:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				local v4 = v3:GetAttribute("MainSize") * 5
				v3.Size = NumberSequence.new(v4 * 12 / 2.45)
				v3.Enabled = true
				task.wait(1.7999999999999998)
				v3.Enabled = false
			end)
		end

		local clone4 = angelC.Phase2.GroundCrack:Clone()
		clone4.CFrame = CFrame.new(raycastResult2.Position + createVector(0, 15000, 0))
		clone4.Parent = parent

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				local v4 = v3:GetAttribute("EmitDelay") == 0

				if v3.Lifetime.Min >= 2 then
					v3.TimeScale = 0
					v3.Transparency = NumberSequence.new(0)
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		task.spawn(function()
			task.wait(2.4)
			clone4:Destroy()
			local clone5 = angelC.Phase2.GroundCrack:Clone()
			clone5.CFrame = CFrame.new(raycastResult2.Position)
			clone5.Parent = parent

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				task.spawn(function()
					local v4 = v3:GetAttribute("EmitDelay") == 0
					v3:Emit(v3:GetAttribute("EmitCount"))
				end)
			end
		end)
	end
end

local function DomainTrails(cFrame, parent)
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

	local function BorderTrails(clone, position)
		local position2 = clone.Position
		local magnitude = (position2 - position).Magnitude
		clone.CFrame = CFrame.new(position2, position)
		local v = (position2 - position) / 2
		local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
		local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
		local v2 = math.random(20, 30)
		local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(v2 / 2, v2), math.random(-v2, v2))
		local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(v2 / 2, v2), math.random(-v2, v2))
		local v5 = math.random(30, 90) / 100
		local lastTime = tick()
		local v6 = magnitude / v5 / 60

		while tick() - lastTime < v6 do
			local v7 = (tick() - lastTime) / v6
			local v8 = cubicBezier(v7, position2, v3, v4, position)
			clone.CFrame = clone.CFrame:Lerp(CFrame.new(v8, position), v7)
			RunService.Heartbeat:Wait()
		end
	end

	local v = 480 / (math.random(30, 37) / 10)

	for _ = 1, 15 do
		task.spawn(function()
			local clone = angelC.Phase2.BorderTrail:Clone()
			clone.CFrame = cFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
				0,
				math.random(-5, 35) / 2,
				-v
			)
			clone.Parent = parent

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			BorderTrails(
				clone,
				CFrame.new(clone.Position) * CFrame.new(
					math.random(-5, 5) * 3,
					math.random(5, 50),
					math.random(-5, 5) * 3
				).Position
			)

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
	end

	local function ShootingStarsTrails(clone, position)
		local v2 = math.random(4, 8) / 10
		local v3 = math.random(0, 25) / 10
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(v2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, v3),
			{
				Position = position
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	local v2 = 480 / (math.random(30, 37) / 10)

	for _ = 1, 15 do
		task.spawn(function()
			local clone = angelC.Phase2.StarTrail:Clone()
			clone.CFrame = cFrame * CFrame.new(-math.random(v2 / 4, v2 * 2), v2, math.random(-v2, v2))
			clone.Parent = parent

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			ShootingStarsTrails(
				clone,
				CFrame.new(clone.Position) * CFrame.new(200, -math.random(v2, v2 * 2.5), 0).Position
			)

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
	end
end

local function DomainHitEffects(cframe, folder, scale, raycastParams2)
	local v = 40 * scale
	local clone = angelC.Phase2.SphereAreaImpact:Clone()
	clone.CFrame = cframe
	clone.Size = Vector3.new(v, v, v)
	clone.Parent = folder

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
			task.wait(0.025)
			TweenService:Create(v2, TweenInfo.new(0.15), {
				TimeScale = 0.025
			}):Play()
			task.wait(2.125)
			TweenService:Create(v2, TweenInfo.new(0.25), {
				TimeScale = 1
			}):Play()
		end)
	end

	local clone2 = angelC.Phase2.SphereAreaStars:Clone()
	clone2.CFrame = cframe
	clone2.Size = createVector(480, 480, 480)
	clone2.Parent = folder

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			v2.Enabled = true
			task.wait(2.1)
			v2.Enabled = false
		end)
	end

	if UserSettings().GameSettings.SavedQualityLevel ~= Enum.SavedQualitySetting.QualityLevel1 and UserSettings().GameSettings.SavedQualityLevel ~= Enum.SavedQualitySetting.QualityLevel2 then
		GroundReflection(cframe, folder, raycastParams2)
		local clone3 = angelC.Phase2.BeamClouds:Clone()
		clone3.CFrame = cframe * CFrame.new(0, -3, 0)
		clone3.Parent = folder
		local tweenInfo = TweenInfo.new(25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local v2 = 4.75 / 2

		for _, descendant in pairs(clone3:GetDescendants()) do
			if descendant:IsA("Beam") then
				local v3

				if descendant.Parent == clone3.BeamClouds2 or descendant.Parent.Parent == clone3.BeamClouds2 then
					descendant.ZOffset += 0.01
					v3 = 1.1
				elseif descendant.Parent == clone3.BeamClouds3 or descendant.Parent.Parent == clone3.BeamClouds3 then
					descendant.ZOffset += 0.02
					v3 = 1.2
				else
					v3 = 1
				end

				descendant.Enabled = true
				descendant.CurveSize0 = descendant.CurveSize0 * v2 / v3 * 12
				descendant.CurveSize1 = descendant.CurveSize1 * v2 / v3 * 12
				descendant.Width0 = descendant.Width0 * v2 / v3 * 12
				descendant.Width1 = descendant.Width1 * v2 / v3 * 12
				descendant.LightEmission = 0.75
				local v4 = descendant
				task.spawn(function()
					v4.Transparency = NumberSequence.new(1)

					for i = 10, 0, -1 do
						v4.Transparency = NumberSequence.new(i / 10, i / 10)
						task.wait(0.025)
					end

					task.wait(1.4999999999999998)
					task.wait(math.random(10, 250) / 1000)

					for i = 1, 10 do
						v4.Transparency = NumberSequence.new(i / 10, i / 10)
						task.wait(0.025)
					end
				end)
			elseif descendant:IsA("Attachment") then
				local v3 = (descendant.Parent == clone3.BeamClouds2 or descendant.Parent.Parent == clone3.BeamClouds2) and 1.1 or (descendant.Parent == clone3.BeamClouds3 or descendant.Parent.Parent == clone3.BeamClouds3) and 1.2 or 1
				descendant.Position = Vector3.new(
					descendant.Position.X * v2 / v3 * 12,
					descendant.Position.Y * v2 / v3 * 12,
					descendant.Position.Z * v2 / v3 * 12
				)
			elseif descendant:IsA("Weld") then
				descendant.C0 = descendant.Part0.CFrame:ToObjectSpace(descendant.Part1.CFrame) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				TweenService:Create(descendant, tweenInfo, {
					C0 = descendant.Part0.CFrame:ToObjectSpace(descendant.Part1.CFrame) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					)
				}):Play()
			end
		end

		TweenService:Create(clone3, tweenInfo, {
			CFrame = clone3.CFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		}):Play()
	end

	DomainTrails(cframe, folder)
end

local v = {
	Head = true,
	UpperTorso = true,
	LowerTorso = true,
	RightUpperArm = true,
	RightLowerArm = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	RightHand = true,
	LeftHand = true,
	RightFoot = true,
	LeftFoot = true,
	HumanoidRootPart = true
}

local function CloneBody(p, parent, p2, p3, now)
	local cframe = CFrame.new(p2, p3)

	local function BodyPartTweens(folder)
		local cFrame = folder.HumanoidRootPart.CFrame

		for _, part in pairs(folder:GetDescendants()) do
			if not (part:IsA("BasePart") or part:IsA("MeshPart")) then
				continue
			end

			if part.Name == "HumanoidRootPart" then
				part:Destroy()
			else
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(207, 168, 106)
				local v2 = part
				task.spawn(function()
					local tween = TweenService:Create(
						v2,
						TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					)
					v2.Transparency = 1
					tween:Play()
					tween.Completed:Wait()
					task.wait(1.5999999999999999)
					TweenService:Create(v2, TweenInfo.new(0.05, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
				part:ClearAllChildren()
			end
		end

		local clone_2 = angelC.Phase2.Highlight:Clone()
		clone_2.Parent = folder
		local clone = angelC.Phase2.CloneAura:Clone()
		clone.CFrame = cFrame
		clone.Parent = parent

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		local clone2 = angelC.Phase2.CloneChain:Clone()
		local magnitude = (p2 - p3).Magnitude
		clone2.Size = Vector3.new(0.001, 0.001, magnitude)
		clone2.CFrame = CFrame.new(p2, p3) * CFrame.new(0, 0, -magnitude / 2)
		clone2.Parent = parent
		clone2.Attach0.Position = Vector3.new(0, 0, magnitude / 2)
		clone2.Attach1.Position = Vector3.new(0, 0, -magnitude / 2)
		local tweenInfo = TweenInfo.new(0.48, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tween = TweenService:Create(clone2.Attach1, tweenInfo, {
			Position = clone2.Attach1.Position
		})
		clone2.Attach1.Position = clone2.Attach0.Position
		tween:Play()
		local v2 = tick() - now
		task.wait(2.4 - v2 - 0.5)
		local clone3 = angelC.Phase2.CloneOutImpact:Clone()
		clone3.CFrame = cFrame
		clone3.Parent = parent

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		clone:Destroy()
		clone2:Destroy()
	end

	task.spawn(function()
		for _ = 1, 1 do
			local model = Instance.new("Model")

			for _, child in pairs(p.Parent:GetChildren()) do
				if not v[child.Name] then
					continue
				end

				local clone = child:Clone()
				clone:ClearAllChildren()
				clone.Parent = model
			end

			model.PrimaryPart = model.HumanoidRootPart
			model.Parent = parent
			Util.Debris:AddItem(model, 5)
			model:SetPrimaryPartCFrame(cframe * CFrame.new(0, 0, 25))
			task.spawn(function()
				BodyPartTweens(model)
			end)
		end
	end)
end

local function ThrowBolt(p, parent, p2, now)
	local clone = angelC.Phase2.ThunderBolt:Clone()
	clone.CFrame = CFrame.new(p, p2)
	clone.Parent = parent

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			v2.Enabled = true
			task.wait(0.025)
			TweenService:Create(v2, TweenInfo.new(0.15), {
				TimeScale = 0.001
			}):Play()
			task.wait(2.125)
			TweenService:Create(v2, TweenInfo.new(0.175), {
				TimeScale = 1
			}):Play()
		end)
	end

	TweenService:Create(clone, TweenInfo.new(30, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		CFrame = clone.CFrame * CFrame.new(0, 0, -10)
	}):Play()
	local clone2 = angelC.Phase2.ThunderBoltStartImpact:Clone()
	clone2.CFrame = clone.CFrame
	clone2.Parent = parent

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
			task.wait(0.075)
			TweenService:Create(v2, TweenInfo.new(0.15), {
				TimeScale = 0.001
			}):Play()
			task.wait(2.175)
			TweenService:Create(v2, TweenInfo.new(0.175), {
				TimeScale = 1
			}):Play()
		end)
	end

	local v2 = tick() - now
	task.wait(2.4 - v2 - 0.3)
	local magnitude = (p - p2).Magnitude
	local tween = TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		CFrame = clone.CFrame * CFrame.new(0, 0, -magnitude)
	})
	tween:Play()
	tween.Completed:Wait()

	for _, effect in pairs(clone:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = false
		end
	end

	local clone3 = angelC.Phase2.HitExplosion:Clone()
	clone3.CFrame = clone.CFrame
	clone3.Parent = parent

	for _, emitter in pairs(clone3:GetDescendants()) do
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
end

local function PlayerTpInDomain(cframe, folder, _)
	local lastTime = tick()
	local clone = angelC.Phase2.RapidSlashStartImpact:Clone()
	clone.CFrame = cframe
	clone.Parent = folder

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local clone2 = angelC.Phase2.RapidSlashes:Clone()
	clone2.CFrame = cframe
	clone2.Parent = folder

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay") / 2)
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)
	end

	local clone3 = angelC.Phase2.RapidSlashes2:Clone()
	clone3.CFrame = cframe
	clone3.Parent = folder

	for _, emitter in pairs(clone3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay") / 2)
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)
	end

	local clone4 = angelC.Phase2.RapidSlashes3:Clone()
	clone4.CFrame = cframe
	clone4.Parent = folder

	for _, emitter in pairs(clone4:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			v2.Enabled = true
			local v3 = tick() - lastTime
			task.wait(0.2823529411764706 - v3 - 0.4)
			v2.Enabled = false
		end)
	end

	task.spawn(function()
		task.wait(0.2)
		local clone5 = angelC.Phase2.RapidSlashStartImpact2:Clone()
		clone5.CFrame = cframe
		clone5.Parent = folder

		for _, emitter in pairs(clone5:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end)
end

local function DashTeleportEnemy(victims, cframe, _, folder)
	local now = tick()

	for _, item in pairs(victims) do
		local v2 = item[1]
		local v3 = item[2] + createVector(0, 15000, 0)
		local humanoidRootPart = v2.HumanoidRootPart
		local cframe2 = CFrame.new(v3, cframe.Position)
		local clone = angelC.Phase2.DashHitImpact:Clone()
		clone.CFrame = cframe2
		clone.Parent = folder

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				local v4 = descendant
				task.spawn(function()
					if v4:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v4:GetAttribute("EmitDelay"))
					end

					v4:Emit(v4:GetAttribute("EmitCount"))

					if v4:GetAttribute("Slow") then
						task.wait(0.025)
						TweenService:Create(v4, TweenInfo.new(0.15), {
							TimeScale = 0.001
						}):Play()
						task.wait(2.125)
						TweenService:Create(v4, TweenInfo.new(0.175), {
							TimeScale = 1
						}):Play()
					end
				end)
			elseif descendant:IsA("PointLight") then
				local v4 = descendant
				task.spawn(function()
					v4.Enabled = true
					task.wait(2.16)
					v4.Enabled = false
				end)
			end
		end

		task.spawn(function()
			local v7 = cframe2 * CFrame.new(
				math.random(-50, 50) * 1.25,
				math.random(0, 50),
				math.random(-50, 50) * 1.25
			).Position
			local v8 = v3
			task.spawn(function()
				CloneBody(humanoidRootPart, folder, v7, v8, now)
			end)
			ThrowBolt(v7, folder, v8, now)
		end)
		task.wait(0.1)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function EndScreenEffect(cframe, X, _)
	local position = cframe.Position
	local v2 = 40 * X
	local character = localPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= v2 then
			local currentCamera = workspace.CurrentCamera
			task.spawn(function()
				task.wait(2.4)
				task.spawn(function()
					cameraShaker:ShakeOnce(20, 10, 0.15, 0.2)
					local clone = angelC.Phase2.ScreenColor1:Clone()
					clone.Parent = currentCamera
					local tween = TweenService:Create(clone, TweenInfo.new(0.05), {
						Brightness = clone.Brightness,
						Contrast = clone.Contrast,
						Saturation = clone.Saturation,
						TintColor = clone.TintColor
					})
					clone.Brightness = 0
					clone.Contrast = 0
					clone.Saturation = 0
					clone.TintColor = Color3.fromRGB(255, 255, 255)
					tween:Play()
					tween.Completed:Wait()
					local tween2 = TweenService:Create(clone, TweenInfo.new(0.1), {
						TintColor = Color3.fromRGB(255, 255, 255),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					})
					tween2:Play()
					tween2.Completed:Wait()
					clone:Destroy()
				end)
				task.spawn(function()
					local clone = angelC.Phase2.Bloom:Clone()
					clone.Parent = game.Lighting
					local tween = TweenService:Create(clone, TweenInfo.new(0.1), {
						Size = 70,
						Threshold = 0.25
					})
					tween:Play()
					tween.Completed:Wait()
					task.wait(0.1)
					local tween2 = TweenService:Create(clone, TweenInfo.new(0.25), {
						Size = 24,
						Threshold = 2
					})
					tween2:Play()
					tween2.Completed:Wait()
					clone:Destroy()
				end)
			end)
		end
	end
end

return function(data)
	local root = data.Root

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1500 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin

	if data.Victims then
		local cframe = CFrame.new(root.Position + createVector(0, 15000, 0))

		for _, victim in pairs(data.Victims) do
			if victim[1] == game.Players.LocalPlayer.Character then
				Util.Sound:Play("DivArt_C_Release_01", nil, nil, 1.2)
			end
		end

		local scale = data.Scale
		InsideDomain(cframe, folder, data.Victims, root.Parent)
		DomainHitEffects(cframe, folder, scale, raycastParams)
		DashTeleportEnemy(data.Victims, cframe, root, folder)
		task.delay(2.1, function()
			PlayerTpInDomain(cframe, folder, root)
		end)
		Util.Debris:AddItem(folder, 7)
	else
		local v2 = Util.Sound:Play("DivArt_C_Hold_01", root)
		local v3 = Util.Sound:Play("DivArt_C_Activate_Held_02", root)

		if data.Holding.Value then
			data.Holding.Changed:Once(function()
				Util.Sound:FadeOut(v2, 0.4)
				Util.Sound:FadeOut(v3, 0.4)
			end)
		else
			Util.Sound:FadeOut(v2, 0.4)
			Util.Sound:FadeOut(v3, 0.4)
		end

		local cframe = CFrame.new(root.Position)
		local clone = angelC.Phase1.StartAura:Clone()
		clone.CFrame = cframe
		clone.Parent = folder
		clone.Weld.Part0 = root.Parent.UpperTorso
		local v4 = false

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = false
			end
		end

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("Part") then
				continue
			end

			local v5 = part.Name == "2" and 0.1 or part.Name == "3" and 0.15 or 0

			for _, effect in pairs(part:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
					continue
				end

				local v6 = effect
				task.spawn(function()
					task.wait(v5)

					if not v4 then
						v6.Enabled = true
					end
				end)
			end

			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, v5),
				{
					Size = part.Size
				}
			)
			part.Size = Vector3.new(part.Size.X, part.Size.Y, 0)
			tween:Play()
		end

		local clone2 = angelC.Phase1.StartImpact:Clone()
		clone2.CFrame = cframe
		clone2.Parent = folder

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.05)
		local clone3 = angelC.Phase1.MainSphere:Clone()
		clone3.CFrame = cframe
		clone3.Parent = folder
		local clone4 = angelC.Phase1.SphereBeams:Clone()
		clone4.CFrame = cframe
		clone4.Parent = folder
		local clone5 = angelC.Phase1.SphereAuras:Clone()
		clone5.CFrame = cframe
		clone5.Parent = folder
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 5
		clone3.Mesh.Scale = Vector3.new(clone3.Mesh.Scale.X * 5, clone3.Mesh.Scale.Y * 5, clone3.Mesh.Scale.Z * 5)
		local tweensByTween = {}

		for _, descendant in pairs(clone4:GetDescendants()) do
			if descendant:IsA("Beam") then
				descendant.CurveSize0 *= 5
				descendant.CurveSize1 *= 5
				descendant.Width0 *= 5
				descendant.Width1 *= 5
			elseif descendant:IsA("Attachment") then
				descendant.Position = Vector3.new(
					descendant.Position.X * 5,
					descendant.Position.Y * 5,
					descendant.Position.Z * 5
				)
			end
		end

		local tween = TweenService:Create(clone3.Mesh, tweenInfo, {
			Scale = Vector3.new(clone3.Mesh.Scale.X * 5, clone3.Mesh.Scale.Y * 5, clone3.Mesh.Scale.Z * 5)
		})
		tween:Play()
		tweensByTween[tween] = tween
		local tween2 = TweenService:Create(numberValue, tweenInfo, {
			Value = numberValue.Value * 5
		})
		tween2:Play()
		tweensByTween[tween2] = tween2

		for _, descendant in pairs(clone4:GetDescendants()) do
			if descendant:IsA("Beam") then
				local tween3 = TweenService:Create(descendant, tweenInfo, {
					CurveSize0 = descendant.CurveSize0 * 5,
					CurveSize1 = descendant.CurveSize1 * 5,
					Width0 = descendant.Width0 * 5,
					Width1 = descendant.Width1 * 5
				})
				tween3:Play()
				tweensByTween[tween3] = tween3
			elseif descendant:IsA("Attachment") then
				local tween3 = TweenService:Create(descendant, tweenInfo, {
					Position = Vector3.new(
						descendant.Position.X * 5,
						descendant.Position.Y * 5,
						descendant.Position.Z * 5
					)
				})
				tween3:Play()
				tweensByTween[tween3] = tween3
			end
		end

		for _, descendant in pairs(clone5:GetDescendants()) do
			if descendant:IsA("Attachment") then
				descendant.Position = Vector3.new(
					descendant.Position.X * 5,
					descendant.Position.Y * 5,
					descendant.Position.Z * 5
				)
				local tween3 = TweenService:Create(descendant, tweenInfo, {
					Position = Vector3.new(
						descendant.Position.X * 5,
						descendant.Position.Y * 5,
						descendant.Position.Z * 5
					)
				})
				tween3:Play()
				tweensByTween[tween3] = tween3
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
				descendant:Emit(1)
			end
		end

		local clone6 = angelC.Phase1.SphereAura2:Clone()
		clone6.CFrame = cframe
		clone6.Parent = folder

		for _, descendant in pairs(clone6:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Size = Vector3.new(descendant.Size.X * 5, descendant.Size.Y * 5, descendant.Size.Z * 5)
				descendant.Weld.C0 = descendant.Weld.Part0.CFrame:ToObjectSpace(descendant.Weld.Part1.CFrame) * CFrame.new(
					0,
					(descendant.Position.Y - clone6.Position.Y) * 2.5,
					0
				)
				local tween3 = TweenService:Create(descendant, tweenInfo, {
					Size = Vector3.new(descendant.Size.X * 5, descendant.Size.Y * 5, descendant.Size.Z * 5)
				})
				tween3:Play()
				tweensByTween[tween3] = tween3
				local tween4 = TweenService:Create(descendant.Weld, tweenInfo, {
					C0 = descendant.Weld.Part0.CFrame:ToObjectSpace(descendant.Weld.Part1.CFrame) * CFrame.new(
						0,
						(descendant.Position.Y - clone6.Position.Y) * 5,
						0
					)
				})
				tween4:Play()
				tweensByTween[tween4] = tween4
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
				descendant:Emit(1)
			end
		end

		local boolValue = Instance.new("BoolValue")
		boolValue.Value = true
		task.spawn(function()
			SphereSpin(boolValue, tweensByTween, clone4, clone6, clone5, numberValue, folder)
		end)
		task.spawn(function()
			task.wait(1)

			if not v4 then
				local clone7 = angelC.Phase1.StartAura2:Clone()
				clone7.CFrame = cframe
				clone7.Parent = clone

				for _, emitter in pairs(clone7:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				local clone8 = angelC.Phase1.MaxHoldImpact:Clone()
				clone8.CFrame = cframe
				clone8.Parent = folder

				for _, emitter in pairs(clone8:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end
		end)

		repeat
			RunService.Heartbeat:Wait()
		until not (data.Holding and data.Holding.Value and data.Holding:IsDescendantOf(workspace))

		v4 = true

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = false
			end
		end

		TweenService:Create(clone6, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone6.CFrame * CFrame.Angles(0, 1.7453292519943295, 0)
		}):Play()

		for _, v5 in pairs(tweensByTween) do
			v5:Pause()
		end

		local X = clone3.Mesh.Scale.X
		local lastTime = tick()
		local atLeastOneVictim = root:WaitForChild("atLeastOneVictim", 2)
		local value = atLeastOneVictim and atLeastOneVictim.Value or false
		local v5 = 2.4 - (tick() - lastTime)

		local function fn()
			local currentCamera = workspace.CurrentCamera
			task.spawn(function()
				cameraShaker:ShakeOnce(10, 7, 0.15, 0.2)
				local clone7 = angelC.Phase2.ScreenColor1:Clone()
				clone7.Parent = currentCamera
				local tween3 = TweenService:Create(clone7, TweenInfo.new(0.025), {
					Brightness = clone7.Brightness,
					Contrast = clone7.Contrast,
					Saturation = clone7.Saturation,
					TintColor = clone7.TintColor
				})
				clone7.Brightness = 0
				clone7.Contrast = 0
				clone7.Saturation = 0
				clone7.TintColor = Color3.fromRGB(255, 255, 255)
				tween3:Play()
				tween3.Completed:Wait()
				local tween4 = TweenService:Create(clone7, TweenInfo.new(0.05), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tween4:Play()
				tween4.Completed:Wait()
				clone7:Destroy()
			end)
			task.spawn(function()
				local clone7 = angelC.Phase2.Bloom:Clone()
				clone7.Parent = game.Lighting
				local tween3 = TweenService:Create(clone7, TweenInfo.new(0.05), {
					Size = 30,
					Threshold = 0.25
				})
				tween3:Play()
				tween3.Completed:Wait()
				task.wait(0.05)
				local tween4 = TweenService:Create(clone7, TweenInfo.new(0.15), {
					Size = 24,
					Threshold = 2
				})
				tween4:Play()
				tween4.Completed:Wait()
				clone7:Destroy()
			end)
		end

		viewerIsClose(cframe.Position, 40 * X, fn) -- equivalent call inferred; original call site unknown

		if value then
			task.spawn(function()
				local clone7 = angelC.Phase2.TimeOrb:Clone()
				clone7.Parent = folder
				clone7.Weld.Part0 = root.Parent.RightHand
				local descendantsByDescendant = {}

				for _, descendant in pairs(clone7:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") then
						descendant.Enabled = true
					elseif descendant:IsA("Attachment") and descendant.Name == "Attachment3" then
						descendantsByDescendant[descendant] = descendant
					end
				end

				local v7 = v5 - 0.5 - 0.35
				local lastTime2 = tick()
				local lastTime3 = nil

				while true do
					if lastTime3 == nil or tick() - lastTime3 >= 0.25 then
						lastTime3 = tick()

						for _, v8 in pairs(descendantsByDescendant) do
							TweenService:Create(
								v8,
								TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = v8.CFrame * CFrame.Angles(math.rad((math.random(10, 90))), 0, 0)
								}
							):Play()
						end
					end

					RunService.Heartbeat:Wait()

					if not (v7 <= tick() - lastTime2) then
						continue
					end

					local clone8 = angelC.Phase2.TimeOrbBreakBeforeImpact:Clone()
					clone8.CFrame = clone7.CFrame
					clone8.Weld.Part0 = clone7
					clone8.Parent = folder

					for _, emitter in pairs(clone8:GetDescendants()) do
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

					local function fn2()
						local currentCamera = workspace.CurrentCamera
						task.spawn(function()
							task.wait(0.35)
							cameraShaker:ShakeOnce(10, 7, 0.15, 0.3)
							local clone9 = angelC.Phase2.ScreenColor1:Clone()
							clone9.Parent = currentCamera
							local tween3 = TweenService:Create(clone9, TweenInfo.new(0.025), {
								Brightness = clone9.Brightness,
								Contrast = clone9.Contrast,
								Saturation = clone9.Saturation,
								TintColor = clone9.TintColor
							})
							clone9.Brightness = 0
							clone9.Contrast = 0
							clone9.Saturation = 0
							clone9.TintColor = Color3.fromRGB(255, 255, 255)
							tween3:Play()
							tween3.Completed:Wait()
							local tween4 = TweenService:Create(clone9, TweenInfo.new(0.05), {
								TintColor = Color3.fromRGB(255, 255, 255),
								Brightness = 0,
								Contrast = 0,
								Saturation = 0
							})
							tween4:Play()
							tween4.Completed:Wait()
							clone9:Destroy()
						end)
						task.spawn(function()
							task.wait(0.15)
							local clone9 = angelC.Phase2.Bloom:Clone()
							clone9.Parent = game.Lighting
							local tween3 = TweenService:Create(clone9, TweenInfo.new(0.15), {
								Size = 30,
								Threshold = 0.25
							})
							tween3:Play()
							tween3.Completed:Wait()
							task.wait(0.55)
							local tween4 = TweenService:Create(clone9, TweenInfo.new(0.15), {
								Size = 24,
								Threshold = 2
							})
							tween4:Play()
							tween4.Completed:Wait()
							clone9:Destroy()
						end)
						task.delay(0.35, function()
							task.spawn(function()
								local clone9 = angelC.Phase2.EndCameraFocus:Clone()
								clone9.Parent = folder
								local renderSteppedConnection = RunService.RenderStepped:Connect(function()
									clone9.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(
										1.5707963267948966,
										0,
										0
									)
								end)

								for _, emitter in pairs(clone9:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									emitter.TimeScale *= 0.6
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end

								task.wait(5)
								renderSteppedConnection:Disconnect()
								clone9:Destroy()
							end)
						end)
					end

					viewerIsClose(cframe.Position, 40 * X, fn2) -- equivalent call inferred; original call site unknown
					task.wait(0.35)

					for _, emitter in pairs(clone7:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Destroy()
						end
					end

					clone8:Destroy()
					local clone9 = angelC.Phase2.TimeOrbBreakImpact:Clone()
					clone9.CFrame = clone7.CFrame
					clone9.Parent = folder

					for _, emitter in pairs(clone9:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					break
				end
			end)
			boolValue.Value = false
			clone3:Destroy()

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in pairs(clone6:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, beam in pairs(clone4:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local v7 = beam
				task.spawn(function()
					local tween3 = TweenService:Create(
						v7,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween3:Play()
					tween3.Completed:Wait()
					v7:Destroy()
				end)
			end

			task.spawn(function()
				TornadoSlash(folder, {
					Multiplier = 1,
					Multiplier2 = 9,
					Multiplier2Time = 1,
					BeamOutTime = 0.5,
					SlashAngle = CFrame.Angles(0, 2.9670597283903604, 0),
					SlashAngle2 = CFrame.Angles(0, 2.9670597283903604, 0),
					SlashType = angelC.Phase2.BeamSlash2,
					SlashCFrame = cframe,
					SlashSpeed = 0.07,
					SlashSpeed2 = 0.35,
					SpinIterations = 5
				})
			end)
			EndScreenEffect(cframe, X) -- equivalent call inferred; original call site unknown
			task.wait(v5)
			PlayerTpInDomain(cframe, folder, root)
		else
			task.wait(0.2)
			boolValue.Value = false

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in pairs(clone6:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, beam in pairs(clone4:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local v7 = beam
				task.spawn(function()
					local tween3 = TweenService:Create(
						v7,
						TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween3:Play()
					tween3.Completed:Wait()
					v7:Destroy()
				end)
			end

			clone3:Destroy()
		end

		Util.Debris:AddItem(folder, 7)
	end
end