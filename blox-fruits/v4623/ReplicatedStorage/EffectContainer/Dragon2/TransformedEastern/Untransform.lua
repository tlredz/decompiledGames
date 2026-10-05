local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 100) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
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
	part.Parent = _WorldOrigin
	destroyAfter(part, 14)
	return part
end

function createTrailingCylinders(_, p)
	local result = {}

	for i = 1, 15 do
		local part = Instance.new("Part")
		part.Name = "DragonTrailingCylinderPart_" .. tostring(i)
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Size = createVector(38.6246, 22.4, 22.4)
		part.Color = Util.WrapColor3Constructor(Color3.new(0, 1, 0), p, "DragonFruitVFXColor")
		part.Transparency = 1
		part.CastShadow = false
		Util.SetParentOverrideWithColor(part, _WorldOrigin, p, "DragonFruitVFXColor")
		destroyAfter(part, 4)
		table.insert(result, part)
	end

	return result
end

function updateTrailingCylinders(list, p)
	local inverse = CFrame.lookAt(createVector(0, 0, 0), createVector(1, 0, 0)):Inverse()
	local v = {
		"Head",
		"S1",
		"S2",
		"S3",
		"S4",
		"S5",
		"S6",
		"S7",
		"S8",
		"S9",
		"S10",
		"S11",
		"S12",
		"S13",
		"S14",
		"S15",
		"S16",
		"S17",
		"S18",
		"S19",
		"S20",
		"S21",
		"S22",
		"S23",
		"S24",
		"S25",
		"S26",
		"S27",
		"S28",
		"S29"
	}
	local count = #v
	local v2 = math.floor(count / 15)
	local children = {}

	for i, childName in ipairs(v) do
		local child = p.RootPart:FindFirstChild(childName)
		assert(child ~= nil, "Bone within eastern dragon model wasn't found: " .. childName)
		children[i] = child
	end

	local worldPositions = { children[1].WorldPosition }

	for i = 2, count do
		if i % v2 == 0 then
			table.insert(worldPositions, children[i].WorldPosition)
		end
	end

	local v3 = worldPositions[1]

	for i = 1, 15 do
		local v4 = worldPositions[i + 1]
		local v5 = math.clamp((v4 - v3).Magnitude, 19.312300333333333, 57.936901000000006)
		list[i].Size = Vector3.new(v5, 22.400000000000002, 22.400000000000002)
		list[i].CFrame = CFrame.lookAt(v3 * 0.5 + v4 * 0.5, v4) * inverse
		v3 = v4
	end
end

return function(player)
	local player2 = player.player
	local hrp = player.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 2000 then
		return
	end

	local untransform = FX:WaitForChild("EasternDragon").Untransform

	local function quadBezier(p, p2, p3, p4)
		return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
	end

	local function lerp(p, p2, p3)
		return p + (p2 - p) * p3
	end

	local function cubicBezier(p, position, p2, p3, p4)
		local v = position + (p2 - position) * p
		local v2 = p2 + (p3 - p2) * p
		local v3 = p3 + (p4 - p3) * p
		local v4 = v + (v2 - v) * p
		return v4 + (v2 + (v3 - v2) * p - v4) * p
	end

	local function RandomTrails(hrp2, folder)
		task.spawn(function()
			local trails = untransform.Phase1.Trails
			local count = #trails:GetChildren()

			for _ = 1, 10 do
				task.spawn(function()
					local cFrame = hrp2.CFrame * CFrame.new(
						math.random(-25, 25) * 3,
						math.random(0, 25) * 3,
						math.random(-25, 25) * 3
					)
					local position4 = hrp2.CFrame.Position + Vector3.new(
						math.random(-5, 5),
						math.random(-5, 5) / 2,
						math.random(-5, 5)
					)
					local v3 = math.random(50, 70) / 10
					local v4 = math.random(1, count)
					local clone = trails["Trail" .. tostring(v4)]:Clone()
					clone.CFrame = cFrame
					Util.SetParentOverrideWithColor(clone, folder, player2, "DragonFruitVFXColor")
					destroyAfter(clone, 7)
					local position = clone.Position
					local magnitude = (position - position4).Magnitude
					clone.CFrame = CFrame.new(position, position4)
					local v5 = (position - position4) / 2
					local position2 = CFrame.new(CFrame.new(position) * (v5 / -1.5)).Position
					local position3 = CFrame.new(CFrame.new(position4) * (v5 / 1.5)).Position
					local v6 = position2 + Vector3.new(
						math.random(-magnitude, magnitude),
						math.random(-magnitude / 2, magnitude),
						math.random(-magnitude, magnitude)
					)
					local v7 = position3 + Vector3.new(
						math.random(-magnitude, magnitude),
						math.random(-magnitude / 2, magnitude),
						math.random(-magnitude, magnitude)
					)
					local lastTime = tick()
					local v8 = magnitude / v3 / 60
					local v9 = time()

					while tick() - lastTime < v8 and not (time() - v9 > 10) do
						local v10 = (tick() - lastTime) / v8
						local v11 = cubicBezier(v10, position, v6, v7, position4)
						clone.CFrame = clone.CFrame:Lerp(CFrame.new(v11, position4), v10)
						task.wait()
					end

					TweenService:Create(clone, TweenInfo.new(0.1), {
						Position = position4
					}):Play()

					for _, emitter in ipairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
			end
		end)
		task.spawn(function()
			task.wait(0.1)
			local trails2 = untransform.Phase1.Trails2
			local count = #trails2:GetChildren()

			for _ = 1, 10 do
				task.spawn(function()
					local cFrame = hrp2.CFrame
					local position4 = hrp2.CFrame * CFrame.new(
						math.random(-25, 25) * 3.25,
						math.random(-5, 25) * 3,
						math.random(-25, 25) * 3.25
					).Position
					local v2 = math.random(25, 35) / 10
					local v3 = math.random(1, count)
					local clone = trails2["Trail" .. tostring(v3)]:Clone()
					clone.CFrame = cFrame
					Util.SetParentOverrideWithColor(clone, folder, player2, "DragonFruitVFXColor")
					destroyAfter(clone, 7)
					local position = clone.Position
					local magnitude = (position - position4).Magnitude
					clone.CFrame = CFrame.new(position, position4)
					local v4 = (position - position4) / 2
					local position2 = CFrame.new(CFrame.new(position) * (v4 / -1.5)).Position
					local position3 = CFrame.new(CFrame.new(position4) * (v4 / 1.5)).Position
					local v5 = position2 + Vector3.new(
						math.random(-magnitude, magnitude),
						math.random(-magnitude / 2, magnitude),
						math.random(-magnitude, magnitude)
					)
					local v6 = position3 + Vector3.new(
						math.random(-magnitude, magnitude),
						math.random(-magnitude / 2, magnitude),
						math.random(-magnitude, magnitude)
					)
					local lastTime = tick()
					local v7 = magnitude / v2 / 60
					local v8 = time()

					while tick() - lastTime < v7 and not (time() - v8 > 10) do
						local v9 = (tick() - lastTime) / v7
						local v10 = cubicBezier(v9, position, v5, v6, position4)
						clone.CFrame = clone.CFrame:Lerp(CFrame.new(v10, position4), v9)
						task.wait()
					end

					TweenService:Create(clone, TweenInfo.new(0.1), {
						Position = position4
					}):Play()

					for _, emitter in ipairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
			end
		end)
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
		Util.SetParentOverrideWithColor(clone, folder, player2, "DragonFruitVFXColor")
		destroyAfter(clone, 7)

		for _, descendant in ipairs(clone:GetDescendants()) do
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

		for _, descendant in ipairs(clone:GetDescendants()) do
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

		for _, beam in ipairs(clone:GetDescendants()) do
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

	local _ = player.Character
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "DragonFruitVFXColor")
	destroyAfter(folder, 15)
	local cFrame2 = CFrame.lookAt(createVector(0, 0, 0), hrp.CFrame.LookVector * createVector(1, 0.01, 1)) + hrp.CFrame.Position
	local easternDragon = player.easternDragon

	if easternDragon == nil or easternDragon.Parent == nil then
		return
	end

	destroyAfter(easternDragon, 7)
	sound:Play("BF_V3_Untransform_01", hrp)
	task.spawn(function()
		local clone = untransform.Phase1.StartAura:Clone()
		clone.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone, folder, player2, "DragonFruitVFXColor")
		destroyAfter(clone, 7)
		local emittersByEmitter = {}

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emittersByEmitter[emitter] = emitter
		end

		RandomTrails(hrp, folder)
		local v2 = 0.15 + tick()
		local v3 = time()

		while true do
			for _, v4 in pairs(emittersByEmitter) do
				v4:Emit(1)
			end

			task.wait(0.05)

			if not (v2 - tick() <= 0 or time() - v3 > 10) then
				continue
			end

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(0.05)
			local clone2 = untransform.Phase1.Explosion:Clone()
			clone2.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone2, folder, player2, "DragonFruitVFXColor")
			destroyAfter(clone2, 7)

			for _, emitter in ipairs(clone2:GetDescendants()) do
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

			task.spawn(function()
				local slashCFrame = cFrame2 * CFrame.new(0, 5, 0)
				TornadoSlash(folder, {
					Multiplier = 0.5,
					Multiplier2 = 7,
					Mutliplier2Time = 0.25,
					BeamOutTime = 0.35,
					SlashAngle = CFrame.new(0, 1, 0) * CFrame.Angles(
						math.rad(math.random(-90, 90) / 10),
						2.6179938779914944,
						math.rad((math.random(-90, 90))) / 10
					),
					SlashAngle2 = CFrame.new(0, 2, 0) * CFrame.Angles(
						math.rad(math.random(-90, 90) / 10),
						2.6179938779914944,
						(math.rad(math.random(-90, 90) / 10))
					),
					SlashType = untransform.Phase1.BeamSlash,
					SlashCFrame = slashCFrame,
					SlashSpeed = 0.05,
					SlashSpeed2 = 1,
					SpinIterations = 2
				})
			end)
			task.spawn(function()
				local slashCFrame = cFrame2 * CFrame.new(0, 10, 0)
				TornadoSlash(folder, {
					Multiplier = 1,
					Multiplier2 = 3,
					Mutliplier2Time = 0.35,
					BeamOutTime = 0.15,
					SlashAngle = CFrame.new(0, 1, 0) * CFrame.Angles(0, 2.6179938779914944, -2.6179938779914944),
					SlashAngle2 = CFrame.new(0, 1, 0) * CFrame.Angles(0, 0.8726646259971648, 0),
					SlashType = untransform.Phase1.BeamSlash,
					SlashCFrame = slashCFrame,
					SlashSpeed = 0.1,
					SlashSpeed2 = 0.35,
					SpinIterations = 1
				})
			end)
			task.spawn(function()
				local slashCFrame = cFrame2 * CFrame.new(0, 10, 0)
				TornadoSlash(folder, {
					Multiplier = 1.5,
					Multiplier2 = 3,
					Mutliplier2Time = 0.35,
					BeamOutTime = 0.15,
					SlashAngle = CFrame.new(0, 1, 0) * CFrame.Angles(
						2.6179938779914944,
						2.6179938779914944,
						2.6179938779914944
					),
					SlashAngle2 = CFrame.new(0, 1, 0) * CFrame.Angles(0, 0.8726646259971648, 2.6179938779914944),
					SlashType = untransform.Phase1.BeamSlash,
					SlashCFrame = slashCFrame,
					SlashSpeed = 0.1,
					SlashSpeed2 = 0.35,
					SpinIterations = 1
				})
			end)
			break
		end
	end)
	task.wait(0.1)

	if easternDragon.Name == "Rig" then
		return
	end

	local trailingCylinders = createTrailingCylinders(parent, player2)
	updateTrailingCylinders(trailingCylinders, easternDragon)

	for _, trailingCylinder in ipairs(trailingCylinders) do
		local clone = FX:WaitForChild("EasternDragon")["3DSpecs"]:Clone()
		Util.SetParentOverrideWithColor(clone, trailingCylinder, player2, "DragonFruitVFXColor")
		clone:Emit(clone:GetAttribute("EmitCount"))
	end

	destroyAfter(easternDragon, 0.001)
end