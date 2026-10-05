local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local boatTween = Util.BoatTween
local _ = Util.Luno.Misc
local cframe = CFrame.new(
	101.700684,
	5.97896576,
	-43.4383545,
	-0.398774534,
	0.147730261,
	0.905071616,
	-0,
	0.986939251,
	-0.161093086,
	-0.91704905,
	-0.0642398223,
	-0.393566191
)
local cframe2 = CFrame.new(
	130.775391,
	6.19074249,
	-80.4295654,
	-0.568045616,
	0.0171871185,
	0.822817683,
	4.65661287e-10,
	0.999782026,
	-0.0208835695,
	-0.822997093,
	-0.01186282,
	-0.567921758
)
local cframe3 = CFrame.new(
	0.0827636719,
	9.1610527,
	0.060546875,
	0.936666191,
	0,
	0.350223392,
	0,
	1,
	0,
	-0.350223392,
	0,
	0.936666191
)
local cframe4 = CFrame.new(
	0.750488281,
	0.937057495,
	-0.780639648,
	0.936666191,
	0.350223392,
	0,
	0,
	0,
	-1,
	-0.350223392,
	0.936666191,
	0
)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function inLerp(p, magnitude, p2)
	return p + (magnitude - p) * (1 - math.cos(p2 * 3.141592653589793 / 2))
end

local function outLerpCubic(p, p2, p3)
	return p + (p2 - p) * (1 - math.pow(1 - p3, 3))
end

local function inOutLerp(p, p2, p3)
	return p + (p2 - p) * (-(math.cos(3.141592653589793 * p3) - 1) / 2)
end

local function inOutLerpQuint(p, p2, p3)
	return p + (p2 - p) * (p3 < 0.5 and 16 * p3 * p3 * p3 * p3 * p3 or 1 - math.pow(-2 * p3 + 2, 5) / 2)
end

local function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function fadeScreen(time)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	debris:AddItem(colorCorrectionEffect, time)
	colorCorrectionEffect.Parent = game:GetService("Lighting")
	local v = boatTween:Create(colorCorrectionEffect, {
		Time = time,
		EasingStyle = "Sine",
		EasingDirection = "Out",
		DelayTime = 0,
		RepeatCount = 0,
		Reverses = true,
		StepType = "RenderStepped",
		Goal = {
			TintColor = Color3.fromRGB(0, 0, 0)
		}
	})
	v.Completed:Connect(function()
		if colorCorrectionEffect then
			colorCorrectionEffect:Destroy()
		end

		if v then
			v:Destroy()
		end
	end)
	v:Play()
end

local function fireEmission(cFrame, value, p, p2)
	local v = value or 5
	local clone = script.MedTrail:Clone()
	debris:AddItem(clone, v + 1)
	clone.CFrame = cFrame
	Util.Sound:Play("KitsuneZSpawnEmber", clone, nil, 0.6 + math.random(-20, 20) / 100, 1)
	local v2 = { clone.Azurefire, clone.Brightfire, clone.Darkfire }
	local wisps = clone.Wisps
	local trail = clone.Trail
	clone.Parent = _WorldOrigin
	trail.Enabled = true
	local lastTime = os.clock()
	task.spawn(function()
		local lastTime2 = os.clock()
		local v3 = 0.016666666666666666
		local total = 1

		while os.clock() - lastTime < v do
			local _ = (os.clock() - lastTime) / v
			clone.CFrame = clone.CFrame * CFrame.new(0, 0, -p2 * v3 * 60) * CFrame.Angles(
				math.rad(p * math.cos(total / 5 + math.random(-15, 15) / 10)) * v3 * 60,
				0,
				0
			)

			if os.clock() - lastTime2 > 0.025 then
				for _, v4 in ipairs(v2) do
					v4:Emit(2)
				end

				wisps:Emit(1)
				lastTime2 = os.clock()
			end

			total += v3 * 1 * 60
			v3 = RunService.RenderStepped:Wait()
		end

		if clone then
			task.wait(1)

			if clone then
				clone:Destroy()
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shrineFloorVisuals(p)
	task.spawn(function()
		local clone = script.ShrineFloor:Clone()
		debris:AddItem(clone, 10)
		clone.CFrame = p * cframe4
		clone.Parent = _WorldOrigin
		Util.Sound:Play("KitsuneCLargeBullet", clone.Position, nil, 0.8, 1)
		Util.Sound:Play("GenericBeamFire", clone.Position, nil, 0.3, 0.6)
		local play = Util.Sound:Play("KitsuneZFireworkExplosion", clone.Position, nil, 0.3, 4)
		play.RollOffMinDistance = 50
		local descendants = clone:GetDescendants()

		for i = 1, 20 do
			for _, instance in ipairs(descendants) do
				if instance:IsA("ParticleEmitter") then
					instance:Emit(instance:GetAttribute("EmitCount"))
				elseif instance:IsA("PointLight") and i == 20 then
					instance.Enabled = true
					local v = boatTween:Create(instance, {
						Time = 1,
						EasingStyle = "Sine",
						EasingDirection = "Out",
						DelayTime = 0,
						RepeatCount = 0,
						Reverses = false,
						StepType = "Heartbeat",
						Goal = {
							Brightness = 0.5,
							Range = 0
						}
					})
					local v2 = instance
					v.Completed:Connect(function()
						if v2 then
							v2:Destroy()
						end

						if v then
							v:Destroy()
						end
					end)
					v:Play()
				end
			end

			task.wait(0.15)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shrineEruption(p)
	task.spawn(function()
		local clone = script.ActivationModel:Clone()
		debris:AddItem(clone, 15)
		clone:PivotTo(p * cframe3)
		local coreBeams = clone.CoreBeams
		local rotateBeams = clone.RotateBeams
		local skyBurst = clone.SkyBurst
		coreBeams.TopAttach.WorldPosition = skyBurst.Position
		rotateBeams.TopAttachA.WorldPosition = skyBurst.Position
		rotateBeams.TopAttachB.WorldPosition = skyBurst.Position
		clone.Parent = _WorldOrigin

		for _, v in ipairs({ coreBeams.TopAttach, rotateBeams.TopAttachA, rotateBeams.TopAttachB }) do
			local v2 = boatTween:Create(v, {
				Time = 3.5,
				EasingStyle = "Linear",
				EasingDirection = "Out",
				DelayTime = 0,
				RepeatCount = 0,
				Reverses = false,
				StepType = "Heartbeat",
				Goal = {
					WorldPosition = skyBurst.Position
				}
			})
			v2.Completed:Connect(function()
				if v2 then
					v2:Destroy()
				end
			end)
			v2:Play()
		end

		local cFrame = p * cframe3
		local magnitude = (skyBurst.Position - cFrame.Position).Magnitude
		local clone2 = script.LargeStreak:Clone()
		debris:AddItem(clone2, 8)
		clone2.CFrame = cFrame
		clone2.Parent = _WorldOrigin
		clone2.Trail.Enabled = true
		local children = clone2:GetChildren()
		local lastTime = os.clock()
		local lastTime2 = os.clock()
		local position = clone2.Position
		local v2 = 0.016666666666666666
		local total = 0

		while os.clock() - lastTime < 3.5 do
			local v3 = os.clock() - lastTime
			local v4 = v2 * 60
			rotateBeams.BaseAttachA.Orientation += Vector3.new(0, v4 * 10, 0)
			rotateBeams.BaseAttachB.Orientation += Vector3.new(0, v4 * 10, 0)
			rotateBeams.TopAttachA.Orientation += Vector3.new(0, v4 * 10, 0)
			rotateBeams.TopAttachB.Orientation += Vector3.new(0, v4 * 10, 0)
			total += v2 * 3.141592653589793
			local v5 = 50 + -40 * (1 - math.cos(v3 / 3.5 * 3.141592653589793 / 2))
			local v6 = math.cos(total)
			local v7 = math.cos(v5) * v5
			local v8 = v3 / 3.5
			local v9 = v6 * (0 + (v7 - 0) * v8)
			local v11 = inLerp(0, magnitude, v3 / 3.5) -- equivalent call inferred; original call site unknown
			local v12 = math.sin(total)
			local v13 = math.cos(v5) * v5
			local v14 = v3 / 3.5
			clone2.CFrame = cFrame * CFrame.new(v9, v11, v12 * (0 + (v13 - 0) * v14))
			clone2.CFrame = CFrame.new(clone2.Position, position) * CFrame.Angles(0, 0.7853981633974483, 0)
			position = clone2.Position

			if os.clock() - lastTime2 > 0.05 then
				for _, emitter in ipairs(children) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
					end
				end

				lastTime2 = os.clock()
			end

			v2 = RunService.Heartbeat:Wait()
		end

		local play = Util.Sound:Play("KitsuneZTransformedMiniExplosion", skyBurst.Position, nil, 0.2, 4)
		play.RollOffMinDistance = 50
		local play_2 = Util.Sound:Play("KitsuneM1Finisher", skyBurst.Position, nil, 1, 3)
		play_2.RollOffMinDistance = 50
		Util.Sound:Play("LightBoom", skyBurst.Position, nil, 0.8, 1)
		local play_3 = Util.Sound:Play("KitsuneZFireworkExplosion", skyBurst.Position, nil, 0.3, 4)
		play_3.RollOffMinDistance = 50
		task.spawn(function()
			local descendants = skyBurst:GetDescendants()

			for _, emitter in ipairs(descendants) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local lastTime3 = os.clock()
			local now = os.clock() - 0.25

			while os.clock() - lastTime3 <= 5 do
				if os.clock() - now > 0.25 then
					skyBurst.StarAttach.Star:Emit(1)
					skyBurst.StarAttach.StarBack:Emit(1)
					skyBurst.Explosion.Lines:Emit(math.random(5, 10))
					skyBurst.Explosion.Clouds:Emit(2)
					now = os.clock()
				end

				RunService.Heartbeat:Wait()
			end
		end)

		for i = 1, math.random(20, 30) do
			if i < 12 and i > 6 then
				fireEmission(
					CFrame.new(skyBurst.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
						math.rad((math.random(-20, 20))),
						math.rad((math.random(-20, 20))),
						(math.rad((math.random(-20, 20))))
					),
					math.random(3, 30) / 10,
					math.random(4, 7),
					math.random(40, 60) / 10
				)
			end

			fireEmission(
				CFrame.new(skyBurst.Position) * CFrame.Angles(
					math.rad((math.random(-30, 5))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-30, 5))))
				),
				math.random(3, 30) / 10,
				math.random(4, 7),
				math.random(40, 60) / 10
			)
			task.wait(math.random(1, 2) / 10)
		end

		local v3 = {
			coreBeams.Beam,
			coreBeams.Beam2,
			rotateBeams.BeamCurveA,
			rotateBeams.BeamCurveA2,
			rotateBeams.BeamCurveB,
			rotateBeams.BeamCurveB2
		}

		for _, v4 in ipairs(v3) do
			local v5 = boatTween:Create(v4, {
				Time = 1,
				EasingStyle = "Sine",
				EasingDirection = "Out",
				DelayTime = 0,
				RepeatCount = 0,
				Reverses = false,
				StepType = "Heartbeat",
				Goal = {
					Width0 = 0,
					Width1 = 0
				}
			})
			v5.Completed:Connect(function()
				if v5 then
					v5:Destroy()
				end
			end)
			v5:Play()
		end
	end)
end

local function cutScene(cFrame, p)
	local currentCamera = workspace.CurrentCamera

	local function canRun()
		return currentCamera and currentCamera.Parent
	end

	if p then
		fadeScreen(0.25)
	end

	task.wait(0.25)
	shrineFloorVisuals(cFrame) -- equivalent call inferred; original call site unknown
	shrineEruption(cFrame) -- equivalent call inferred; original call site unknown

	if p then
		task.delay(1.75, function()
			fadeScreen(0.25)
		end)
		local lastTime = os.clock()

		while currentCamera and currentCamera.Parent do
			local v = os.clock() - lastTime

			if not currentCamera or v > 2 then
				break
			end

			local v2 = cFrame * cframe
			local v3 = v / 2
			local v4 = v2 * CFrame.Angles(math.rad(0 + 28 * (-(math.cos(3.141592653589793 * v3) - 1) / 2)), 0, 0)
			local v5 = v / 2
			currentCamera.CFrame = v4 * CFrame.new(0, 0, 0 + -20 * (-(math.cos(3.141592653589793 * v5) - 1) / 2))
			RunService.RenderStepped:Wait()
		end

		task.delay(5, function()
			fadeScreen(1)
		end)
		local lastTime2 = os.clock()

		while currentCamera and currentCamera.Parent do
			local v = os.clock() - lastTime2

			if not currentCamera or v > 4 then
				break
			end

			local v2 = cFrame * cframe2
			local v3 = v / 6
			local v4 = v2 * CFrame.Angles(math.rad(0 + -10 * (-(math.cos(3.141592653589793 * v3) - 1) / 2)), 0, 0)
			local v5 = 0 + 600 * (1 - math.pow(1 - v / 4, 3))
			local v6 = v / 4
			currentCamera.CFrame = v4 * CFrame.new(0, v5, 0 + 200 * (-(math.cos(3.141592653589793 * v6) - 1) / 2))

			if v > 2 then
				currentCamera.FieldOfView = 70 + 20 * (1 - math.pow(1 - (v - 2) / 4, 3))
			end

			RunService.RenderStepped:Wait()
		end

		while currentCamera and currentCamera.Parent do
			local v = os.clock() - lastTime2

			if not currentCamera or v - 4 > 2 then
				break
			end

			local v2 = cFrame * cframe2
			local v3 = v / 6
			currentCamera.CFrame = v2 * CFrame.Angles(
				math.rad(0 + -10 * (-(math.cos(3.141592653589793 * v3) - 1) / 2)),
				0,
				0
			) * CFrame.new(0, 600, 200)
			currentCamera.FieldOfView = 70 + 20 * (1 - math.pow(1 - (v - 2) / 4, 3))
			RunService.RenderStepped:Wait()
		end

		currentCamera.FieldOfView = 70
	end
end

return function(data)
	local cFrame = data.CFrame
	local lockRange = data.LockRange
	local globalRange = data.GlobalRange or 1000
	local magnitude = (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude

	if globalRange < magnitude then
		return
	end

	cutScene(cFrame, magnitude <= lockRange)
end