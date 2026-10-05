local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local X = FX:WaitForChild("EasternDragon").X
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }
task.spawn(function()
	table.insert(raycastParams.FilterDescendantsInstances, Workspace.Map:WaitForChild("WaterBase-Plane", 9999))
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function cameraShakeAt(position: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 100) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
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

local DashFlipbook = require(script:WaitForChild("DashFlipbook"))
return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	local TIME_UNTIL_IMPACT = data.TIME_UNTIL_IMPACT

	local function Scale(clone, p)
		local position = data.originCF.Position

		if clone.ClassName ~= "Model" then
			local model = Instance.new("Model")
			Util.SetParentOverrideWithColor(model, clone.Parent, player, "DragonFruitVFXColor")
			Util.SetParentOverrideWithColor(clone, model, player, "DragonFruitVFXColor")
			clone = model
		end

		clone:ScaleTo(p)
		local v = position + (clone:GetPivot().Position - position) * p
		clone:PivotTo(clone:GetPivot().Rotation + v)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DeleteImpactAfterDuration(folder)
		task.spawn(function()
			local v = 0

			for _, emitter in ipairs(folder:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					v = math.max(v, emitter.Lifetime.Max)
				end
			end

			task.wait(v)
			folder:Destroy()
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function viewerIsClose(position, p, fn)
		local character = localPlayer.Character

		if character ~= nil then
			local rootPart = character:FindFirstChildOfClass("Humanoid").RootPart

			if rootPart and (rootPart.Position - position).Magnitude <= p then
				fn()
			end
		end
	end

	local function AlignCFrame(data2, normal)
		local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
		local p = data2.p
		local unit = data2.LookVector:Cross(v).Unit
		local unit2 = (unit.Magnitude > 0.001 and unit or data2.RightVector).Unit
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

	local function TailWhip(model, clone, data2)
		local multiplier = data2.Multiplier
		local slashAngle = data2.SlashAngle
		local slashAngle2 = data2.SlashAngle2
		local yPosition = data2.YPosition
		local slashType = data2.SlashType
		local slashIterations = data2.SlashIterations
		local slashSpinAngle = data2.SlashSpinAngle
		local slashFinalSpinAngle = data2.SlashFinalSpinAngle
		local slashEndSpeed = data2.SlashEndSpeed
		local clone2 = slashType:Clone()
		Scale(clone2, 2)
		clone2.CFrame = clone.CFrame
		clone2.Anchored = false
		clone2.Weld.Part0 = clone
		clone2.Weld.C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * CFrame.new(0, yPosition, 0) * slashAngle * slashAngle2
		Util.SetParentOverrideWithColor(clone2, model, player, "DragonFruitVFXColor")
		destroyAfter(clone2, 7)

		for _, descendant in ipairs(clone2:GetDescendants()) do
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

		for _, descendant in ipairs(clone2:GetDescendants()) do
			if descendant:IsA("Beam") then
				descendant.Enabled = true
				local startDelay = descendant:GetAttribute("StartDelay")
				local v = descendant
				local v2 = descendant:GetAttribute("EndDelay")
				task.spawn(function()
					local tween = TweenService:Create(
						v,
						TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Width0 = v.Width0 * 1.5,
							Width1 = v.Width1 * 1.5,
							CurveSize0 = v.CurveSize0 * 1.5,
							CurveSize1 = v.CurveSize1 * 1.5
						}
					)
					v.Width0 = 0
					v.Width1 = 0
					task.wait(startDelay)
					tween:Play()
				end)
			elseif descendant:IsA("Attachment") then
				TweenService:Create(descendant, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = Vector3.new(
						descendant.Position.X * 1.5,
						descendant.Position.Y * 1.5,
						descendant.Position.Z * 1.5
					)
				}):Play()
			end
		end

		for _ = 1, slashIterations do
			local tween = TweenService:Create(
				clone2.Weld,
				TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					C0 = clone2.Weld.Part0.CFrame:ToObjectSpace(clone2.Weld.Part1.CFrame) * CFrame.Angles(
						0,
						math.rad(slashSpinAngle),
						0
					)
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end

		clone2.Weld.Enabled = false
		clone2.Anchored = true
		TweenService:Create(clone2, TweenInfo.new(slashEndSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.Angles(0, math.rad(slashFinalSpinAngle), 0)
		}):Play()

		for _, effect in ipairs(clone2:GetDescendants()) do
			if effect:IsA("Beam") then
				local v = effect
				task.spawn(function()
					local endDelay = v:GetAttribute("EndDelay")
					local tween = TweenService:Create(
						v,
						TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v:Destroy()
				end)
			elseif effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			end
		end
	end

	local v = X

	local function FlyRock(cFrame, p, p2)
		local clone = v.Phase4.Rock:Clone()
		clone.CFrame = cFrame
		clone.Size += Vector3.new(0, math.random(0, 2), 0)
		clone.Size *= math.random(2, 3)
		clone.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
		clone.Material = p.Instance.Material
		clone.Color = p.Instance.Color
		clone.CanCollide = false
		Util.SetParentOverrideWithColor(clone, p2, player, "DragonFruitVFXColor")
		clone.Color = p.Instance.Color
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
		bodyVelocity.P = 3000
		Util.SetParentOverrideWithColor(bodyVelocity, clone, player, "DragonFruitVFXColor")
		local vector2 = Vector3.new(math.random(-30, 30) * 2, 0, math.random(-30, 30) * 2)
		local vector3 = Vector3.new(0, math.random(150, 200) / 1.5, 0)
		local v2 = math.random(120, 250) * 1.35
		bodyVelocity.Velocity = CFrame.new(clone.Position, clone.Position + vector2 + vector3).LookVector * v2
		task.delay(1 * math.random() + 2.5, function()
			TweenService:Create(
				clone,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
				{
					Size = createVector(0, 0, 0)
				}
			):Play()
		end)
		task.delay(0.025 * math.random() + 0.05, function()
			bodyVelocity:Destroy()
			task.wait(0.1)
			clone.CanCollide = true
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function GroundBurn(clone, p, p2, _)
		task.spawn(function()
			local v2 = data.RAYCAST_DOWN_BY * 50 / 70
			local lastTime = tick()
			local clone2 = v.Phase2.GroundBurn:Clone()
			Scale(clone2, 2)
			Util.SetParentOverrideWithColor(clone2, p, player, "DragonFruitVFXColor")
			destroyAfter(clone2, 7)
			local lastTime2 = tick()
			local v3 = time()
			local v4 = false

			while true do
				local cFrame = clone.CFrame
				local raycastResult = Workspace:Raycast(
					cFrame.Position + createVector(0, 1, 0),
					createVector(0, 1, 0) * -v2,
					raycastParams
				)

				if raycastResult and raycastResult.Instance and raycastResult.Instance.Name ~= "WaterBase-Plane" then
					clone2.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + cFrame.LookVector)

					if v4 == false then
						v4 = true

						for _, emitter in ipairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end
					end

					if tick() - lastTime >= 0.1 then
						lastTime = tick()
						local v5 = raycastResult
						task.spawn(function()
							FlyRock(
								clone2.CFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
									0,
									0,
									-math.random(100, 150)
								),
								v5,
								p
							)
						end)
					end
				elseif v4 == true then
					v4 = false

					for _, emitter in ipairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				task.wait(0.15)

				if not (p2 <= tick() - lastTime2 or time() - v3 > 10) then
					continue
				end

				task.wait(1.5)

				for _, emitter in ipairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				break
			end
		end)
	end

	local function Tornado(cFrame, model, TIME_SPIRALLING, _)
		local clone = v.Phase2.TornadoMain:Clone()
		Scale(clone, 2)
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, model, player, "DragonFruitVFXColor")
		destroyAfter(clone, 7)
		local clone2 = v.Phase2.Tornado:Clone()
		Scale(clone2, 2)
		clone2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone2, model, player, "DragonFruitVFXColor")
		destroyAfter(clone2, 7)
		clone2.Anchored = false
		clone2.Weld.Part0 = clone
		local clone3 = v.Phase2.Tornado2:Clone()
		Scale(clone3, 2)
		clone3.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone3, model, player, "DragonFruitVFXColor")
		destroyAfter(clone3, 7)
		clone3.Anchored = false
		clone3.Weld.Part0 = clone
		local clone4 = v.Phase2.Tornado3:Clone()
		Scale(clone4, 2)
		clone4.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone4, model, player, "DragonFruitVFXColor")
		destroyAfter(clone4, 7)
		clone4.Anchored = false
		clone4.Weld.Part0 = clone
		local clone5 = v.Phase2.Tornado4:Clone()
		Scale(clone5, 2)
		clone5.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone5, model, player, "DragonFruitVFXColor")
		destroyAfter(clone5, 7)
		clone5.Anchored = false
		clone5.Weld.Part0 = clone
		local v2 = {}

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			v2[emitter] = emitter
		end

		local v3 = {}
		local v4 = {}

		for _, folder in ipairs(clone3:GetChildren()) do
			local v5 = 1
			local v6 = 0

			if folder.Name == "SpinA" then
				v5 = 2.25
				v6 = 0
			elseif folder.Name == "SpinB" then
				v5 = 2.5
				v6 = 0.1
			elseif folder.Name == "SpinC" then
				v5 = 2.75
				v6 = 0.15
			elseif folder.Name == "SpinD" then
				v5 = 2
				v6 = 0.2
			elseif folder.Name == "SpinE" then
				v5 = 3
				v6 = 0.25
			elseif folder.Name == "SpinF" then
				v5 = 3.35
				v6 = 0.3
			elseif folder.Name == "SpinG" then
				v5 = 3.5
				v6 = 0.35
			end

			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant:IsA("Beam") then
					v3[descendant] = descendant
					local curveSize0 = descendant.CurveSize0
					local curveSize1 = descendant.CurveSize1
					local width0 = descendant.Width0
					local width1 = descendant.Width1
					descendant.CurveSize0 *= v5
					descendant.CurveSize1 *= v5
					descendant.Width0 = descendant.Width0 * v5 / 1.5
					descendant.Width1 = descendant.Width1 * v5 / 1.5
					descendant.Enabled = false
					local v7 = descendant
					task.spawn(function()
						task.wait(v6 * 1.5)
						v7.Enabled = true
						local v12 = v5

						for i = 1, 5 do
							task.wait(0.5)
							v5 = v12 * math.random(7, 10) / 10
							v7.CurveSize0 = curveSize0 * v5
							v7.CurveSize1 = curveSize1 * v5
							v7.Width0 = width0 * v5 / 1.5
							v7.Width1 = width1 * v5 / 1.5
						end
					end)
				elseif descendant:IsA("Attachment") then
					local v7 = descendant.Position.X * v5
					local v8 = descendant.Position.Y * v5
					descendant.Position = Vector3.new(v7, v8, descendant.Position.Z * v5)
				elseif descendant:IsA("Motor6D") then
					v4[descendant] = descendant
					descendant.C0 = descendant.Part0.CFrame:ToObjectSpace(descendant.Part1.CFrame) * CFrame.Angles(
						0,
						math.rad((math.random(-90, 90))),
						0
					)
					descendant:SetAttribute("Tweening", false)
				end
			end
		end

		local v5 = {}

		for _, folder in ipairs(clone4:GetChildren()) do
			local v6 = 1
			local v7 = 0

			if folder.Name == "SpinA" then
				v6 = 2
				v7 = 0
			elseif folder.Name == "SpinB" then
				v6 = 2.25
				v7 = 0.1
			elseif folder.Name == "SpinC" then
				v6 = 2.5
				v7 = 0.15
			elseif folder.Name == "SpinD" then
				v6 = 2.75
				v7 = 0.2
			elseif folder.Name == "SpinE" then
				v6 = 3
				v7 = 0.25
			elseif folder.Name == "SpinF" then
				v6 = 3.35
				v7 = 0.3
			elseif folder.Name == "SpinG" then
				v6 = 3.7
				v7 = 0.35
			end

			local v8 = v6 * 1.5

			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant:IsA("Beam") then
					v3[descendant] = descendant
					descendant.CurveSize0 *= v8
					descendant.CurveSize1 *= v8
					descendant.Width0 *= v8
					descendant.Width1 *= v8
					descendant.Enabled = false
					local v9 = descendant
					task.spawn(function()
						task.wait(v7)
						v9.Enabled = true
					end)
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * v8,
						descendant.Position.Y * v8,
						descendant.Position.Z * v8
					)
				elseif descendant:IsA("Motor6D") then
					v5[descendant] = descendant
					descendant.C0 = descendant.Part0.CFrame:ToObjectSpace(descendant.Part1.CFrame) * CFrame.Angles(
						0,
						math.rad((math.random(-90, 90))),
						0
					)
					descendant:SetAttribute("Tweening", false)
				end
			end
		end

		local descendantsByDescendant = {}
		local descendantsByDescendant2 = {}

		for _, part in ipairs(clone5:GetChildren()) do
			local v6 = 1
			local v7 = 0

			if part.Name == "SpinA" then
				v6 = 2
				v7 = 0
			elseif part.Name == "SpinB" then
				v6 = 2.25
				v7 = 0.1
			elseif part.Name == "SpinC" then
				v6 = 2.5
				v7 = 0.15
			elseif part.Name == "SpinD" then
				v6 = 2.75
				v7 = 0.2
			elseif part.Name == "SpinE" then
				v6 = 3
				v7 = 0.25
			elseif part.Name == "SpinF" then
				v6 = 3.35
				v7 = 0.3
			elseif part.Name == "SpinG" then
				v6 = 3.7
				v7 = 0.35
			end

			local v8 = v6 * 0.9

			if part:IsA("BasePart") then
				part.Size = Vector3.new(part.Size.X * v8, part.Size.Y * v8, part.Size.Z * v8)
			end

			for _, descendant in ipairs(part:GetDescendants()) do
				if descendant:IsA("Motor6D") then
					descendantsByDescendant[descendant] = descendant
					descendant.C0 = descendant.Part0.CFrame:ToObjectSpace(descendant.Part1.CFrame) * CFrame.Angles(
						0,
						math.rad((math.random(-90, 90))),
						0
					)
					descendant:SetAttribute("Tweening", false)
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
					descendantsByDescendant2[descendant] = descendant
					local v9 = descendant
					task.spawn(function()
						task.wait(v7)
						v9.Enabled = true
					end)
				end
			end
		end

		GroundBurn(clone, model, 1.5) -- equivalent call inferred; original call site unknown
		local cFrame2 = clone.CFrame
		local lastTime = tick()
		local v7 = time()

		while true do
			local v8 = tick() - lastTime

			if TIME_SPIRALLING <= v8 then
				break
			end

			local _ = math.min(v8, 1) / 1
			clone.CFrame = cFrame2 * CFrame.Angles(0, v8 * 3.141592653589793 * 2 * 3.666, 0)

			for _, v9 in pairs(v3) do
				if v9:GetAttribute("Tweening") then
					continue
				end

				local v10 = v9
				task.spawn(function()
					v10:SetAttribute("Tweening", true)
					math.random(50, 120)
					local v11 = math.random(15, 30) / 50
					local width = v10.Width0 * math.random(10, 25) / 10
					local width2 = v10.Width1 * math.random(10, 25) / 10
					local tween = TweenService:Create(
						v10,
						TweenInfo.new(v11, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
						{
							Width0 = width,
							Width1 = width2
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v10:SetAttribute("Tweening", false)
				end)
			end

			task.wait()

			if TIME_SPIRALLING <= tick() - lastTime or time() - v7 > 10 then
				break
			end
		end

		for _, v8 in pairs(v3) do
			local tween = TweenService:Create(
				v8,
				TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Width0 = 0,
					Width1 = 0
				}
			)
			tween:Play()
			local v10 = v8
			task.spawn(function()
				tween.Completed:Wait()
				v10:Destroy()
				v3[v10] = nil
			end)
		end

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, v8 in pairs(descendantsByDescendant) do
			local v9 = v8
			task.spawn(function()
				local v10 = math.random(150, 170)
				TweenService:Create(v9, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					C0 = v9.Part0.CFrame:ToObjectSpace(v9.Part1.CFrame) * CFrame.Angles(0, math.rad(v10), 0)
				}):Play()
			end)
		end

		for _, v8 in pairs(descendantsByDescendant2) do
			local v9 = v8
			task.spawn(function()
				task.wait(math.random(0, 25) / 100)
				v9.Enabled = false
			end)
		end
	end

	local function TornadoSlash(p, data2)
		local multiplier = data2.Multiplier
		local multiplier2 = data2.Multiplier2
		local mutliplier2Time = data2.Mutliplier2Time
		local beamOutTime = data2.BeamOutTime
		local slashAngle = data2.SlashAngle
		local slashAngle2 = data2.SlashAngle2
		local slashType = data2.SlashType
		local slashCFrame = data2.SlashCFrame
		local slashSpeed = data2.SlashSpeed
		local slashSpeed2 = data2.SlashSpeed2
		local spinIterations = data2.SpinIterations
		local clone = slashType:Clone()
		Scale(clone, 2)
		clone.CFrame = slashCFrame
		Util.SetParentOverrideWithColor(clone, p, player, "DragonFruitVFXColor")
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
				local v2 = descendant
				task.spawn(function()
					local tween = TweenService:Create(
						v2,
						TweenInfo.new(mutliplier2Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							CurveSize0 = v2.CurveSize0 * multiplier2,
							CurveSize1 = v2.CurveSize1 * multiplier2,
							Width0 = v2.Width0 * multiplier2,
							Width1 = v2.Width1 * multiplier2
						}
					)
					v2.Width0 = 0
					v2.Width1 = 0
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

			local v2 = beam
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

		TweenService:Create(clone, TweenInfo.new(slashSpeed2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * slashAngle2
		}):Play()
	end

	local function Dash(_, part, _, p, data2)
		local range = data2.Range
		local speed = data2.Speed
		local responsiveness = data2.Responsiveness
		local cframe = CFrame.new(hrp.Position)
		local _, v2 = Workspace:FindPartOnRayWithIgnoreList(
			Ray.new(cframe.Position, CFrame.new(cframe.Position).UpVector * range),
			raycastParams.FilterDescendantsInstances
		)
		local _ = (cframe.Position - v2).Magnitude
		local clone = v.Phase3.StartImpact:Clone()
		clone.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0)
		Util.SetParentOverrideWithColor(clone, p, player, "DragonFruitVFXColor")
		destroyAfter(clone, 7)

		for _, emitter in ipairs(clone:GetDescendants()) do
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

		local clone2 = v.Phase3.Dash:Clone()
		Scale(clone2, 2)
		clone2.CFrame = cframe
		Util.SetParentOverrideWithColor(clone2, p, player, "DragonFruitVFXColor")
		destroyAfter(clone2, 7)
		clone2.Anchored = false
		clone2.Weld.Part0 = part
		local emittersByEmitter = {}

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emittersByEmitter[emitter] = emitter
		end

		task.spawn(function()
			local lastTime = tick()
			local v3 = time()

			repeat
				for _, v4 in pairs(emittersByEmitter) do
					v4:Emit(1)
				end

				task.wait(0.01)
				local v4 = tick() - lastTime
			until speed * 0.98 <= v4 or time() - v3 > 10
		end)

		local function DashTrail(clone3, position)
			local position2 = clone3.Position
			local magnitude = (position2 - position).Magnitude
			clone3.CFrame = CFrame.new(position2, position)
			local v3 = (position2 - position) / 2
			local position3 = CFrame.new(CFrame.new(position2) * (v3 / -1.5)).Position
			local position4 = CFrame.new(CFrame.new(position) * (v3 / 1.5)).Position
			local v4 = math.random(20, 30) * 2.5
			local v5 = position3 + Vector3.new(math.random(-v4, v4), math.random(-2, 2), math.random(-v4, v4))
			local v6 = position4 + Vector3.new(math.random(-v4, v4), math.random(-2, 2), math.random(-v4, v4))
			local v7 = math.random(25, 70) / 5
			local lastTime = tick()
			local v8 = magnitude / v7 / 60
			local v9 = time()

			while tick() - lastTime < v8 and not (time() - v9 > 10) do
				local v10 = (tick() - lastTime) / v8
				local v11 = cubicBezier(v10, position2, v5, v6, position)
				clone3.CFrame = clone3.CFrame:Lerp(CFrame.new(v11, position), v10)
				task.wait()
			end
		end

		task.spawn(function()
			for _ = 1, 5 do
				task.spawn(function()
					local clone3 = v.Phase3.DashTrail:Clone()
					clone3.CFrame = cframe * CFrame.new(math.random(-5, 5), math.random(-5, 5) / 2, math.random(-5, 5))
					Util.SetParentOverrideWithColor(clone3, p, player, "DragonFruitVFXColor")
					destroyAfter(clone3, 7)

					for _, effect in ipairs(clone3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					DashTrail(
						clone3,
						CFrame.new(v2, cframe.Position) * CFrame.new(
							math.random(-5, 5),
							math.random(-5, 5) / 2,
							math.random(-7, -5)
						).Position
					)

					for _, effect in ipairs(clone3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
			end
		end)
		task.spawn(function()
			local lastTime = tick()

			for _ = 1, 3 do
				task.spawn(function()
					local clone3 = v.Phase3.SmallTrail:Clone()
					clone3.CFrame = clone2.CFrame
					Util.SetParentOverrideWithColor(clone3, p, player, "DragonFruitVFXColor")
					destroyAfter(clone3, 7)
					clone3.Anchored = false
					clone3.Weld.Part0 = clone2
					clone3.Weld.C0 = clone3.Weld.Part0.CFrame:ToObjectSpace(clone3.Weld.Part1.CFrame) * CFrame.Angles(
						0,
						0,
						(math.rad((math.random(-180, 180))))
					)

					for _, effect in ipairs(clone3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = true
						elseif effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					local v3 = time()

					repeat
						clone3.Weld.C0 = clone3.Weld.Part0.CFrame:ToObjectSpace(clone3.Weld.Part1.CFrame) * CFrame.Angles(
							0,
							0,
							(math.rad((math.random(15, 30))))
						)
						task.wait()
						local v4 = tick() - lastTime
					until speed * 2 * 0.7 <= v4 or time() - v3 > 10

					for _, effect in ipairs(clone3:GetDescendants()) do
						if effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						elseif effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
			end
		end)
		local clone3 = v.Phase3.AlignMover:Clone()
		clone3.CFrame = cframe
		Util.SetParentOverrideWithColor(clone3, p, player, "DragonFruitVFXColor")
		destroyAfter(clone3, 7)
		clone3.Anchored = false
		clone3.Weld.Part0 = part
		local alignOrientation = clone3.AlignOrientation
		alignOrientation.Enabled = false
		alignOrientation.CFrame = part.CFrame
		local alignPosition = clone3.AlignPosition
		alignPosition.Enabled = false
		alignPosition.Responsiveness = responsiveness
		alignPosition.Position = cframe * CFrame.new(0, range, 0).Position
		task.wait(TIME_UNTIL_IMPACT * 1 / 1.7)
		clone.CFrame *= CFrame.Angles(-1.5707963267948966, 0, 0)
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in ipairs(clone:GetDescendants()) do
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

		alignPosition.Position = cframe * CFrame.new(0, 0, 0).Position
		task.wait(TIME_UNTIL_IMPACT * 0.7 / 1.7)

		for _, effect in ipairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		clone2.Weld.Enabled = false
		clone2.Anchored = true
		return clone3
	end

	local function StartDash(originCF, model, _, _, _)
		task.spawn(function()
			local slashCFrame = originCF * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 0, 5)
			TornadoSlash(model, {
				Multiplier = 0.5,
				Multiplier2 = 2.25,
				Mutliplier2Time = 0.175,
				BeamOutTime = 0.175,
				SlashAngle = CFrame.new(0, 0, -10) * CFrame.Angles(0, 0, -0.4363323129985824),
				SlashAngle2 = CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, -1.7453292519943295),
				SlashType = v.Phase3.BeamSlash,
				SlashCFrame = slashCFrame,
				SlashSpeed = 0.025,
				SlashSpeed2 = 0.125,
				SpinIterations = 5
			})
		end)
		task.spawn(function()
			local lastTime = tick()
			local v2 = time()

			repeat
				local clone = v.Phase3.DashTornado:Clone()
				clone.CFrame = CFrame.new(hrp.Position) * CFrame.new(0, 5, 0) * CFrame.Angles(
					1.5707963267948966,
					0,
					(math.rad((math.random(-90, 90))))
				)
				Util.SetParentOverrideWithColor(clone, model, player, "DragonFruitVFXColor")
				destroyAfter(clone, 7)
				local v3 = math.random(35, 55) / 10

				for _, descendant in ipairs(clone:GetDescendants()) do
					if descendant:IsA("Beam") then
						descendant.CurveSize0 *= v3
						descendant.CurveSize1 *= v3
						descendant.Width0 *= math.clamp(v3 / 2, 2, 3)
						descendant.Width1 *= math.clamp(v3 / 2, 2, 3)
						local width0 = descendant.Width0
						local width1 = descendant.Width1
						descendant.Width0 = 0
						descendant.Width1 = 0
						local v4 = descendant
						task.spawn(function()
							local tween = TweenService:Create(
								v4,
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
								v4,
								TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween2:Play()
							tween2.Completed:Wait()
							v4:Destroy()
						end)
					elseif descendant:IsA("Attachment") then
						descendant.Position = Vector3.new(
							descendant.Position.X * v3,
							descendant.Position.Y * v3,
							descendant.Position.Z * v3
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
			until tick() - lastTime >= 0.42 or time() - v2 > 10
		end)
		local cFrame = CFrame.new(hrp.Position) * CFrame.Angles(-1.5707963267948966, 0, 0)
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
		heartbeatLoopFor2(4, function()
			part.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(-1.5707963267948966, 0, 0) * inverse
		end)
		task.spawn(function()
			local clone = v.Phase3.Effect:Clone()
			clone.CFrame = part.CFrame
			clone.Anchored = false
			clone.Weld.Part0 = part
			Util.SetParentOverrideWithColor(clone, model, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)
			task.spawn(function()
				task.wait(0.6)
				task.wait(0.1)
				clone.Weld.C0 = CFrame.Angles(-1.5707963267948966, 0, 0)
			end)
			DashFlipbook.Dash(part, model, TIME_UNTIL_IMPACT, clone, data.impactPosition, 2, player)
		end)
		Dash(Humanoid, part, aPlayer, model, {
			Range = 170,
			Speed = 0.6,
			Responsiveness = 50
		}):Destroy()
	end

	local function Explosion(originCF, model, _)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function RockCrater(raycastResult, p, data2)
			task.spawn(function()
				local rockType = data2.RockType
				local radius = data2.Radius
				local size = data2.Size
				local duration = data2.Duration
				local amount = data2.Amount
				local v2 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05
				local v3 = {}

				for _ = 1, amount do
					local clone = rockType:Clone()
					Util.SetParentOverrideWithColor(clone, p, player, "DragonFruitVFXColor")
					destroyAfter(clone, 7)
					table.insert(v3, clone)
				end

				task.spawn(function()
					task.wait(duration * 2)

					for _, v4 in pairs(v3) do
						v4:Destroy()
					end

					v3 = nil
				end)
				local v4 = 360 / #v3
				local total = 0

				for _, v5 in pairs(v3) do
					total += v4
					v5.CFrame = v2 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)

					if math.random(1, 5) < 2 then
						v5.CFrame = CFrame.new(v5.Position, raycastResult.Position) * CFrame.new(0, 0, 100)
					end

					v5.CFrame = CFrame.new(v5.Position, raycastResult.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 3,
						math.random(-50, 200)
					)
					local part, v6 = Workspace:FindPartOnRayWithIgnoreList(
						Ray.new(
							v5.Position + createVector(0, 1, 0),
							createVector(-0, -20, -0) * data.RAYCAST_DOWN_BY / 70
						),
						raycastParams.FilterDescendantsInstances
					)

					if part then
						local v7 = (v5.Position - raycastResult.Position).Magnitude / 300
						local v8 = size * math.random(15, 30) / 10
						local v9 = size * math.random(5, 20) / 10
						local v10 = size * math.random(30, 50) / 10
						v5.Size = Vector3.new(v8 * v7, v9 * v7, v10 * v7)
						v5.Position = v6 + Vector3.new(0, -v5.Size.Y * math.random(5, 6) / 15, 0)
						v5.CFrame = CFrame.new(v5.Position, raycastResult.Position) * CFrame.new(
							0,
							math.random(-5, 5) / 3,
							math.random(-25, 25)
						)
						v5.CFrame = CFrame.new(
							v5.Position,
							v2.Position + Vector3.new(0, math.random(-55, -45) / 100 + v5.Size.Y / 200, 0)
						) * CFrame.Angles(math.rad(-math.random(10, 15) / 2 - 45 * v7), 0, 0) * CFrame.Angles(
							0,
							0,
							(math.rad((math.random(-5, 5))))
						)
						v5.Material = part.Material
						v5.Color = part.Color
					else
						v5:Destroy()
						v3[v5] = nil
					end

					TweenService:Create(
						v5,
						TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
						{
							Position = v5.Position + Vector3.new(0, v5.Size.Y * math.random(3, 5) / 10, 0)
						}
					):Play()
					local v7 = v5
					local v8 = v5
					task.spawn(function()
						wait(duration + math.random(10, 50) / 100)
						local tween = TweenService:Create(
							v7,
							TweenInfo.new(
								0.5,
								Enum.EasingStyle.Back,
								Enum.EasingDirection.In,
								0,
								false,
								math.random(10, 35) / 100
							),
							{
								Position = v7.Position + Vector3.new(
									math.random(-1, 1),
									-v7.Size.Y * math.random(20, 25) / 10,
									math.random(-1, 1)
								)
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v7:Destroy()
						v3[v7] = nil
					end)
				end
			end)
		end

		local function FlyRock2(cFrame, raycastResult, p)
			local clone = v.Phase4.Rock:Clone()
			clone.CFrame = cFrame
			clone.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
			clone.Size *= math.random(3, 6)
			clone.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
			clone.Material = raycastResult.Instance.Material
			clone.Color = raycastResult.Instance.Color
			clone.CanCollide = false
			Util.SetParentOverrideWithColor(clone, p, player, "DragonFruitVFXColor")
			clone.Color = raycastResult.Instance.Color
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
			bodyVelocity.P = 3000
			Util.SetParentOverrideWithColor(bodyVelocity, clone, player, "DragonFruitVFXColor")
			local vector2 = Vector3.new(math.random(-30, 30) * 2, 0, math.random(-30, 30) * 2)
			local vector3 = Vector3.new(0, math.random(150, 200) / 1.5, 0)
			local v2 = math.random(50, 250) * 1.5
			bodyVelocity.Velocity = CFrame.new(clone.Position, clone.Position + vector2 + vector3).LookVector * v2
			task.delay(1 * math.random() + 2.5, function()
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
					{
						Size = createVector(0, 0, 0)
					}
				)
				tween.Completed:Connect(function()
					clone.Anchored = true
				end)
				tween:Play()
			end)
			task.delay(0.075 * math.random() + 0.05, function()
				bodyVelocity:Destroy()
				task.wait(0.1)
				clone.CanCollide = true
			end)
		end

		task.spawn(function()
			local position = originCF.Position
			local character = localPlayer.Character

			if character ~= nil then
				local rootPart = character:FindFirstChildOfClass("Humanoid").RootPart

				if rootPart and (rootPart.Position - position).Magnitude <= 400 then
					cameraShakeAt(originCF.Position, 400, 7, 7, 0.15, 0.25) -- equivalent call inferred; original call site unknown
				end
			end

			if player == localPlayer then
				Util.CameraShaker:ShakeOnce(15, 15, 0.2, 1.6)
			end

			local clone = v.Phase4.Explosion:Clone()
			Scale(clone, 2)
			clone.CFrame = originCF
			Util.SetParentOverrideWithColor(clone, model, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)
			NumberRange.new(math.random(-90, 90))

			for _, emitter in ipairs(clone:GetDescendants()) do
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

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		end)
		local v2 = data.RAYCAST_DOWN_BY * 50 / 70
		local raycastResult = Workspace:Raycast(
			originCF.Position + createVector(0, 1, 0),
			createVector(0, 1, 0) * -v2,
			raycastParams
		)

		if not raycastResult or not raycastResult.Instance or raycastResult.Instance.Name == "WaterBase-Plane" then
			return
		end

		local cFrame2 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.05
		RockCrater(raycastResult, model, {
			Radius = 150,
			Size = 24,
			Duration = 3.5,
			Amount = 25,
			RockType = v.CraterRock
		}) -- equivalent call inferred; original call site unknown
		task.spawn(function()
			for i = 1, 50 do
				if math.random() < 0.75 then
					task.spawn(function()
						FlyRock2(
							cFrame2 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
								0,
								0,
								-math.random(125, 150) * 1.5
							),
							raycastResult,
							model
						)
					end)
				end

				if i % 2 == 0 then
					task.wait(0.001 * math.random())
				end
			end
		end)
		task.spawn(function()
			local clone = v.Phase4.GroundImpact:Clone()
			Scale(clone, 2)
			clone.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone, model, player, "DragonFruitVFXColor")
			destroyAfter(clone, 7)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter
				task.spawn(function()
					if v5:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v5:GetAttribute("EmitDelay"))
					end

					v5:Emit(v5:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			local clone2 = v.Phase4.GroundExplosion:Clone()
			Scale(clone2, 2)
			clone2.CFrame = originCF
			Util.SetParentOverrideWithColor(clone2, model, player, "DragonFruitVFXColor")
			destroyAfter(clone2, 7)

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter
				task.spawn(function()
					if v5:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v5:GetAttribute("EmitDelay"))
					end

					v5:Emit(v5:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
			local clone3 = v.Phase4.GroundExplosion2:Clone()
			Scale(clone3, 2)
			clone3.CFrame = originCF * CFrame.Angles(-1.5707963267948966, 0, 0)
			Util.SetParentOverrideWithColor(clone3, model, player, "DragonFruitVFXColor")
			destroyAfter(clone3, 7)

			for _, emitter in ipairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter
				task.spawn(function()
					if v5:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v5:GetAttribute("EmitDelay"))
					end

					v5:Emit(v5:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
		end)
		local position = originCF.Position
		local character = localPlayer.Character

		if character ~= nil then
			local rootPart = character:FindFirstChildOfClass("Humanoid").RootPart

			if rootPart and (rootPart.Position - position).Magnitude <= 400 then
				task.spawn(function()
					local clone = v.Phase4.CameraAura:Clone()
					clone.CFrame = originCF
					Util.SetParentOverrideWithColor(clone, model, player, "DragonFruitVFXColor")
					clone.Particle_1.Enabled = true
					clone.Particle_2.Enabled = true
					task.delay(0.5, function()
						clone.Particle_1.Enabled = false
						clone.Particle_2.Enabled = false
					end)
					local v5 = 1.5 + tick()

					repeat
						clone.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.p, originCF.Position) * CFrame.new(
							0,
							0,
							-7
						)
						RunService.RenderStepped:Wait()
					until v5 - tick() <= 0

					clone:Destroy()
				end)
			end
		end

		return raycastResult, cFrame2
	end

	local model = Instance.new("Model")
	model.Name = "DragonXVisuals"
	Util.SetParentOverrideWithColor(model, _WorldOrigin, player, "DragonFruitVFXColor")
	destroyAfter(model, 15)
	local originCF = data.originCF
	local v2 = raycastParams
	local clone = v.Phase1.TailSpin:Clone()
	Scale(clone, 2)
	clone.CFrame = originCF
	Util.SetParentOverrideWithColor(clone, model, player, "DragonFruitVFXColor")
	destroyAfter(clone, 7)
	sound:Play("BF_V3_Transformed_X_SpiralUp_NoExplosion_01", originCF.Position)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	task.spawn(function()
		task.wait(0.15)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	local currentCamera2 = Workspace.CurrentCamera
	local position = originCF.Position
	local character = localPlayer.Character

	if character ~= nil then
		local rootPart = character:FindFirstChildOfClass("Humanoid").RootPart

		if rootPart and (rootPart.Position - position).Magnitude <= 140 and data.player ~= localPlayer then
			task.spawn(function()
				local clone2 = v.Phase2.CameraFocus:Clone()
				Util.SetParentOverrideWithColor(clone2, model, player, "DragonFruitVFXColor")
				local renderSteppedConnection = RunService.RenderStepped:Connect(function()
					clone2.CFrame = currentCamera2.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
				end)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.wait(data.TIME_SPIRALLING)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.wait(1)
				renderSteppedConnection:Disconnect()
				clone2:Destroy()
			end)
		end
	end

	task.spawn(function()
		task.wait(data.TIME_SPIRALLING)

		local function fn()
			local screenColorEDX = v.Phase1.ScreenColorEDX
			local v3 = game.Lighting:FindFirstChild("ScreenColorEDX")

			if v3 then
				v3:SetAttribute("UsedTimes", v3:GetAttribute("UsedTimes") + 1)
			else
				v3 = Instance.new("ColorCorrectionEffect")
			end

			Util.SetParentOverrideWithColor(v3, game.Lighting, player, "DragonFruitVFXColor")
			local usedTimes = v3:GetAttribute("UsedTimes")
			local tween = TweenService:Create(v3, TweenInfo.new(0.35), {
				Brightness = screenColorEDX.Brightness,
				Contrast = screenColorEDX.Contrast,
				Saturation = screenColorEDX.Saturation,
				TintColor = screenColorEDX.TintColor
			})
			tween:Play()
			local clone2 = v.Phase3.CameraFocus:Clone()
			Util.SetParentOverrideWithColor(clone2, model, player, "DragonFruitVFXColor")
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				clone2.CFrame = currentCamera2.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 0)
			end)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(0.6)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.spawn(function()
				if v3:GetAttribute("UsedTimes") == usedTimes then
					tween = TweenService:Create(v3, TweenInfo.new(0.5), {
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
			local bloomEffect = Instance.new("BloomEffect")
			Util.SetParentOverrideWithColor(bloomEffect, game.Lighting, player, "DragonFruitVFXColor")
			bloomEffect.Size += 10
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
			task.wait(1)
			renderSteppedConnection:Disconnect()
			clone2:Destroy()
		end

		viewerIsClose(originCF.Position, 150, fn) -- equivalent call inferred; original call site unknown
	end)
	local clone2 = v.Phase1.StartImpact:Clone()
	Scale(clone2, 2)
	clone2.CFrame = originCF
	Util.SetParentOverrideWithColor(clone2, model, player, "DragonFruitVFXColor")
	destroyAfter(clone2, 7)

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

	task.spawn(function()
		TailWhip(model, clone2, {
			Multiplier = 3,
			SlashAngle = CFrame.Angles(0, math.rad((math.random(-170, -150))), 0),
			SlashAngle2 = CFrame.Angles(math.rad(math.random(1, 5) / 100), 0, 0),
			YPosition = 5,
			SlashType = v.Phase1.TailWhipSlash,
			SlashIterations = 3,
			SlashSpinAngle = 50,
			SlashFinalSpinAngle = 70,
			SlashEndSpeed = 0.25
		})
	end)
	task.spawn(function()
		task.wait(0.15)
		TailWhip(model, clone2, {
			Multiplier = 3.5,
			SlashAngle = CFrame.new(0, 10, 0) * CFrame.Angles(0, 2.6179938779914944, 0),
			SlashAngle2 = CFrame.Angles(0.08726646259971647, 0, 0),
			YPosition = 15,
			SlashType = v.Phase1.SmallTailWhipSlash,
			SlashIterations = 10,
			SlashSpinAngle = 120,
			SlashFinalSpinAngle = 150,
			SlashEndSpeed = 0.125
		})
	end)
	local clone3 = v.Phase1.StartImpact2:Clone()
	Scale(clone3, 2)
	clone3.CFrame = originCF
	Util.SetParentOverrideWithColor(clone3, model, player, "DragonFruitVFXColor")
	destroyAfter(clone3, 7)

	for _, emitter in ipairs(clone3:GetDescendants()) do
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

	local TIME_SPIRALLING = data.TIME_SPIRALLING

	for _ = 1, 3 do
		task.spawn(function()
			task.wait(math.random(0, 25) / 100)
			local clone4 = v.Phase2.SpinTrail:Clone()
			Scale(clone4, 2)
			clone4.CFrame = originCF * CFrame.new(0, math.random(0, 50), 0) * CFrame.Angles(
				math.rad(math.random(-25, 25) / 2),
				math.rad((math.random(-180, 180))),
				(math.rad(math.random(-25, 25) / 2))
			)
			Util.SetParentOverrideWithColor(clone4, model, player, "DragonFruitVFXColor")
			destroyAfter(clone4, 7)

			for _, effect in ipairs(clone4:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			clone4.Trail.Lifetime = math.random(15, 30) / 100
			local weld = clone4.Weld
			local v3 = tick() + TIME_SPIRALLING * 0.85
			local v4 = time()

			repeat
				local v5 = math.random(100, 170)
				local tween = TweenService:Create(
					clone4,
					TweenInfo.new(0.16666666666666666, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone4.CFrame * CFrame.Angles(0, math.rad(v5), 0) * CFrame.Angles(
							math.rad(math.random(-25, 25) / 3),
							0,
							(math.rad(math.random(-25, 25) / 3))
						)
					}
				)
				tween:Play()
				TweenService:Create(weld, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					C0 = CFrame.new(0, 0, -math.random(85, 105))
				}):Play()
				tween.Completed:Wait()
			until v3 - tick() <= 0 or time() - v4 > 10

			TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = clone4.CFrame * CFrame.Angles(0, 2.6179938779914944, 0) * CFrame.Angles(
					math.rad(math.random(-25, 25) / 3),
					0,
					(math.rad(math.random(-25, 25) / 3))
				)
			}):Play()
			TweenService:Create(weld, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				C0 = CFrame.new(0, 0, -math.random(50))
			}):Play()
		end)
	end

	task.spawn(function()
		local clone4 = v.Phase2.AirPull:Clone()
		Scale(clone4, 2)
		clone4.CFrame = originCF * CFrame.new(0, 30, 0) * CFrame.Angles(0, 0, -1.5707963267948966)
		Util.SetParentOverrideWithColor(clone4, model, player, "DragonFruitVFXColor")
		destroyAfter(clone4, 7)

		for _, emitter in ipairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.wait(TIME_SPIRALLING)

		for _, emitter in ipairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	local clone4 = v.Phase1.TornadoStartImpact:Clone()
	Scale(clone4, 2)
	clone4.CFrame = originCF * CFrame.new(0, 3, 0)
	Util.SetParentOverrideWithColor(clone4, model, player, "DragonFruitVFXColor")
	destroyAfter(clone4, 7)

	for _, emitter in ipairs(clone4:GetDescendants()) do
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

	local cFrame3 = originCF
	task.spawn(function()
		Tornado(cFrame3, model, TIME_SPIRALLING, v2)
	end)
	task.wait(TIME_SPIRALLING)
	sound:Play("EasternHeavenlyDragonFruitInfernalRelease", hrp)
	StartDash(originCF, model, Humanoid, HumanoidRootPart, Player)
	local v4 = data.RAYCAST_DOWN_BY * 50 / 70
	local v5, v6, v7 = Util.RayMap(originCF.Position + createVector(0, 1, 0), createVector(0, 1, 0) * -v4)
	local v8 = not v5 and createVector(0, 1, 0) or v7
	originCF = CFrame.new(v6 + v8 * 3, v6 + v8 * 100) * CFrame.Angles(-1.5707963267948966, 0, 0)
	sound:Play("BF_V3_Transformed_X_ArialExplosionFlame_02", originCF.Position)
	local v9, cFrame4 = Explosion(originCF, model, v2)
	local position3 = originCF.Position
	local character2 = localPlayer.Character

	if character2 ~= nil then
		local rootPart = character2:FindFirstChildOfClass("Humanoid").RootPart

		if rootPart and (rootPart.Position - position3).Magnitude <= 150 then
			task.spawn(function()
				local screenColorEDX2 = v.Phase4.ScreenColorEDX2
				local v11 = game.Lighting:FindFirstChild("ScreenColorEDX2")

				if v11 then
					v11:SetAttribute("UsedTimes", v11:GetAttribute("UsedTimes") + 1)
				else
					v11 = Instance.new("ColorCorrectionEffect")
				end

				Util.SetParentOverrideWithColor(v11, game.Lighting, player, "DragonFruitVFXColor")
				local usedTimes = v11:GetAttribute("UsedTimes")
				local tween = TweenService:Create(v11, TweenInfo.new(0.05), {
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
				local v12 = TweenService:Create(bloomEffect, TweenInfo.new(0.25), {
					Size = 54
				}):Play()
				task.delay(0.25, function()
					v12 = TweenService:Create(bloomEffect, TweenInfo.new(0.25), {
						Size = 0
					}):Play()
					task.wait(0.25)
					bloomEffect:Destroy()
				end)
				task.spawn(function()
					if v11:GetAttribute("UsedTimes") == usedTimes then
						tween = TweenService:Create(v11, TweenInfo.new(0.15), {
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

						if v11:GetAttribute("UsedTimes") == usedTimes then
							v11:Destroy()
						end
					end
				end)
			end)
		end
	end

	if v9 then
		task.spawn(function()
			local clone5 = v.Phase4.GroundBurn:Clone()
			clone5.CFrame = cFrame4
			Util.SetParentOverrideWithColor(clone5, model, player, "DragonFruitVFXColor")
			destroyAfter(clone5, 7)

			for _, emitter in ipairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.wait(2.5)

			for _, emitter in ipairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)

		for _ = 1, 3 do
			local clone5 = v.Extra.SlashModel:Clone()
			local primaryPart = clone5.PrimaryPart
			primaryPart.CFrame = originCF * CFrame.new(0, math.random(25, 50) * 1.5, 0) * CFrame.Angles(
				math.rad(math.random(-90, 90) / 10),
				math.rad((math.random(-90, 90))),
				(math.rad(math.random(-90, 90) / 10))
			)
			Util.SetParentOverrideWithColor(clone5, model, player, "DragonFruitVFXColor")
			local folder = clone5
			task.spawn(function()
				task.spawn(function()
					for i = 100, 200, 7 do
						folder:ScaleTo(i / 100)
						task.wait()
					end

					for i = 200, 250, 5 do
						folder:ScaleTo(i / 100)
						task.wait(0.0015)
					end
				end)
				local v12 = 0.15 * math.random() + 0.3

				for i, beam in pairs(folder:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local tween = TweenService:Create(
						beam,
						TweenInfo.new(v12, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween:Play()
					local v14 = beam
					task.spawn(function()
						tween.Completed:Wait()
						v14:Destroy()
					end)
				end
			end)
			task.spawn(function()
				local v13 = math.random(40, 70)
				local v14 = 0.15 * math.random() + 0.15

				for i = 1, 12 do
					local tween = TweenService:Create(
						clone5.PrimaryPart,
						TweenInfo.new(v14 / 12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = clone5.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v13), 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end

				local tween = TweenService:Create(
					clone5.PrimaryPart,
					TweenInfo.new(v14, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone5.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v13 * 2), 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end)
		end

		task.spawn(function()
			for _ = 1, 3 do
				local clone5 = v.Extra.SlashModel:Clone()
				clone5.PrimaryPart.CFrame = cFrame4 * CFrame.new(0, math.random(35, 50) * 1.5, 0) * CFrame.Angles(
					math.rad(math.random(-90, 90) / 100),
					math.rad((math.random(-90, 90))),
					(math.rad(math.random(-90, 90) / 100))
				)
				Util.SetParentOverrideWithColor(clone5, model, player, "DragonFruitVFXColor")
				local folder = clone5
				task.spawn(function()
					task.spawn(function()
						for i = 100, 150, 5 do
							folder:ScaleTo(i / 100)
							task.wait()
						end

						for i = 150, 200, 5 do
							folder:ScaleTo(i / 100)
							task.wait(0.0015)
						end
					end)
					local v11 = 0.15 * math.random() + 0.25

					for i, beam in pairs(folder:GetDescendants()) do
						if not beam:IsA("Beam") then
							continue
						end

						local tween = TweenService:Create(
							beam,
							TweenInfo.new(v11, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						local v13 = beam
						task.spawn(function()
							tween.Completed:Wait()
							v13:Destroy()
						end)
					end
				end)
				task.spawn(function()
					local v12 = math.random(40, 70) / 1.5
					local v13 = math.random(7, 10)
					local v14 = 0.15 * math.random() + 0.15

					for i = 1, v13 do
						local tween = TweenService:Create(
							clone5.PrimaryPart,
							TweenInfo.new(v14 / v13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = clone5.PrimaryPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(
									0,
									math.rad(-v12),
									0
								)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end

					local tween = TweenService:Create(
						clone5.PrimaryPart,
						TweenInfo.new(v14, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone5.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-v12 * 2), 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end)
			end
		end)
		task.spawn(function()
			for _ = 1, 10 do
				task.spawn(function()
					local clone5 = v.Extra.SmallTrail:Clone()
					clone5.CFrame = cFrame4 * CFrame.new(0, 15, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						(math.rad(math.random(-180, 180) / 15))
					) * CFrame.Angles(math.rad((math.random(5, 50))), 0, 0)
					Util.SetParentOverrideWithColor(clone5, model, player, "DragonFruitVFXColor")
					clone5.CFrame *= CFrame.new(0, 0, -100)
					clone5.Anchored = false

					for _, effect in pairs(clone5:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
					bodyVelocity.P = 3000
					Util.SetParentOverrideWithColor(bodyVelocity, clone5, player, "DragonFruitVFXColor")
					local v11 = math.random(100, 250)
					task.delay(math.random(10, 20) / 100, function()
						bodyVelocity:Destroy()
						task.wait(0.35)
						clone5.CanCollide = true
					end)
					bodyVelocity.Velocity = clone5.CFrame.LookVector * v11
					task.wait(1.5)

					for _, effect in pairs(clone5:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
			end
		end)
		task.spawn(function()
			for _ = 1, 10 do
				task.spawn(function()
					local v11 = math.random(70, 100) * 3
					local clone5 = v.Extra.GroundLavaCrack:Clone()
					clone5.CFrame = cFrame4 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
					clone5.CFrame *= CFrame.new(50, 0, 0)
					Util.SetParentOverrideWithColor(clone5, model, player, "DragonFruitVFXColor")

					for _, effect in pairs(clone5:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					local tween = TweenService:Create(
						clone5,
						TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone5.CFrame * CFrame.new(v11, 0, 0)
						}
					)
					tween:Play()
					task.spawn(function()
						local v12 = 0.3 + math.random(5, 25) / 100

						for _ = 1, 5 do
							local clone6 = v.Extra.SideFlameModel:Clone()
							clone6:ScaleTo(v12)
							local primaryPart = clone6.PrimaryPart
							primaryPart.CFrame = clone5.CFrame
							Util.SetParentOverrideWithColor(clone6, model, player, "DragonFruitVFXColor")

							for _, emitter in pairs(primaryPart:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								emitter.Enabled = true
								local v13 = emitter
								task.delay(0.55, function()
									v13.Enabled = false
								end)
							end

							v12 += 0.1
							task.wait(0.06999999999999999)
						end
					end)
					tween.Completed:Wait()

					for _, effect in pairs(clone5:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
			end
		end)
		task.spawn(function()
			local function FlyRock2(cFrame, p, model2)
				local clone5 = v.Phase4.Rock:Clone()
				clone5.CFrame = cFrame
				clone5.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
				clone5.Size *= math.random(1, 3)
				clone5.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
				clone5.Material = p.Instance.Material
				clone5.Color = p.Instance.Color
				clone5.CanCollide = false
				rocks:ApplyCollision(clone5, nil, true)
				Util.SetParentOverrideWithColor(clone5, model2, player, "DragonFruitVFXColor")
				clone5.Color = p.Instance.Color
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(700000000, 700000000, 700000000)
				bodyVelocity.P = 3000
				Util.SetParentOverrideWithColor(bodyVelocity, clone5, player, "DragonFruitVFXColor")
				local vector2 = Vector3.new(math.random(-30, 30) * 2, 0, math.random(-30, 30) * 2)
				local vector3 = Vector3.new(0, math.random(150, 200) / 1.5, 0)
				local v11 = math.random(50, 100)
				bodyVelocity.Velocity = CFrame.new(clone5.Position, clone5.Position + vector2 + vector3).LookVector * v11
				task.delay(1 * math.random() + 3.5, function()
					local tween = TweenService:Create(
						clone5,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
						{
							Size = createVector(0, 0, 0)
						}
					)
					tween.Completed:Connect(function()
						clone5.Anchored = true
					end)
					tween:Play()
				end)
				task.delay(0.075 * math.random() + 0.025, function()
					bodyVelocity:Destroy()
					task.wait(0.1)
					clone5.CanCollide = true
				end)
			end

			local total = 36

			for _ = 1, 10 do
				task.spawn(function()
					local v11 = math.random(50, 100) * 3
					local clone5 = v.Extra.GroundCrackTrail:Clone()
					clone5.CFrame = cFrame4 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, -100)
					Util.SetParentOverrideWithColor(clone5, model, player, "DragonFruitVFXColor")
					local v12 = clone5.CFrame * CFrame.new(0, 0, -v11)
					local v13 = math.random(25, 50)

					for _ = 1, 10 do
						local cFrame = CFrame.new(clone5.Position, v12.Position) * CFrame.new(
							math.random(-v13, v13),
							0,
							-v11 / 10
						)
						local tween = TweenService:Create(
							clone5,
							TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = cFrame
							}
						)
						tween:Play()
						tween.Completed:Wait()
						local part, _ = Workspace:FindPartOnRayWithIgnoreList(
							Ray.new(clone5.Position + createVector(0, 1, 0), createVector(-0, -50, -0)),
							v2.FilterDescendantsInstances
						)

						if not part or part.Name == "WaterBase-Plane" then
							break
						end

						if not (math.random() < 0.5) then
							continue
						end

						local cFrame2 = cFrame
						task.spawn(function()
							FlyRock2(
								cFrame2 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
									0,
									0,
									-math.random(125, 150) / 100
								),
								v9,
								model
							)
						end)
					end

					for _, effect in pairs(clone5:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
				total += 36
			end
		end)
		local clone5 = v.Extra.Pillar:Clone()
		clone5.CFrame = cFrame4
		Util.SetParentOverrideWithColor(clone5, model, player, "DragonFruitVFXColor")
		local v11 = {}

		for _, emitter in pairs(clone5:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			v11[emitter] = tick() + 2.5 / emitter.Rate
		end

		local v12 = 0.35 + tick()

		while true do
			for k, v13 in pairs(v11) do
				if not (v13 - tick() <= 0) then
					continue
				end

				v11[k] = tick() + 2.5 / k.Rate
				k:Emit(k:GetAttribute("EmitCount") / 2)
			end

			task.wait()

			if not (v12 - tick() <= 0) then
				continue
			end

			for k, _ in pairs(v11) do
				k.Enabled = false
			end

			break
		end
	end
end