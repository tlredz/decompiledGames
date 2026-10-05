local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local boatTween = Util.BoatTween
local v = {
	createVector(260.33765, -55.58132, -856.67847),
	createVector(82.5166, 170.83841, -865.0863),
	createVector(-424.46436, 613.7258, -544.81934),
	createVector(-636.1763, 780.7856, 261.167)
}
local v2 = {
	createVector(258.5796, -90.28278, -777.80493),
	createVector(249.96289, -63.87265, -748.1339),
	createVector(237.18896, -2.2647858, -706.53345),
	createVector(221.95801, 63.1351, -656.65015)
}

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function inLerp(p, p2, p3)
	return p + (p2 - p) * (1 - math.cos(p3 * 3.141592653589793 / 2))
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

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function fadeScreen(time, p2)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	debris:AddItem(colorCorrectionEffect, time)
	colorCorrectionEffect.Parent = game:GetService("Lighting")
	local v4 = boatTween:Create(colorCorrectionEffect, {
		Time = time,
		EasingStyle = "Sine",
		EasingDirection = "Out",
		DelayTime = 0,
		RepeatCount = 0,
		Reverses = true,
		StepType = "RenderStepped",
		Goal = p2 ~= 1 and {
			Brightness = 1
		} or {
			TintColor = Color3.fromRGB(0, 0, 0)
		} or {
			Brightness = 1
		}
	})
	v4.Completed:Once(function()
		if colorCorrectionEffect then
			colorCorrectionEffect:Destroy()
		end

		if v4 then
			v4:Destroy()
		end
	end)
	v4:Play()
end

local function cutScene(ID, cFrame, p)
	local currentCamera = workspace.CurrentCamera

	local function canRun()
		return currentCamera and currentCamera.Parent
	end

	local v3 = 0.016666666666666666

	if ID == 1 then
		if p then
			fadeScreen(0.25, 1)
		end

		task.wait(0.25)
		Util.Sound:Play("TrialSounds.BF_Relic_Time_Transport_01", cFrame.Position)
		task.delay(4.5, function()
			Util.Sound:Play("Dragon.Rumble", cFrame.Position, 100, 1)
		end)

		if p then
			task.delay(3.75, function()
				fadeScreen(0.25, 1)
			end)
			local lastTime = os.clock()
			local total = 0

			while currentCamera and currentCamera.Parent do
				local v4 = os.clock() - lastTime

				if not currentCamera or v4 > 4 then
					break
				end

				total += 2
				local v5 = v4 / 4
				local v11 = cubicBezier(0 + 1 * (-(math.cos(3.141592653589793 * v5) - 1) / 2), v[1], v[2], v[3], v[4])
				local v12 = 70 - total / 6 * 1.05 * math.cos(total / 4)
				local v13 = v3 * 60 * 0.1
				local v14 = cFrame * (v11 + Vector3.new(0, 0 + (v12 - 0) * v13, 0))
				local position = cFrame.Position
				local v15 = v4 / 4
				currentCamera.CFrame = CFrame.new(
					v14,
					position + Vector3.new(0, 0 + 200 * (-(math.cos(3.141592653589793 * v15) - 1) / 2), 0)
				)
				v3 = RunService.RenderStepped:Wait()
			end
		end
	elseif ID == 2 then
		if p then
			fadeScreen(0.25, 1)
		end

		task.wait(0.25)
		local v4 = Util.Sound:Play("VolcanoLoop", cFrame.Position, nil, 0.7, 1.5)
		task.delay(6, function()
			if v4 then
				local v5 = boatTween:Create(v4, {
					Time = 5,
					EasingStyle = "Sine",
					EasingDirection = "Out",
					DelayTime = 0,
					RepeatCount = 0,
					Reverses = false,
					StepType = "Heartbeat",
					Goal = {
						Volume = 0
					}
				})
				v5.Completed:Once(function()
					if v4 then
						v4:Destroy()
					end

					if v5 then
						v5:Destroy()
					end
				end)
				v5:Play()
			end
		end)
		local play = Util.Sound:Play("Rumble", cFrame.Position, nil, 0.4, 2)
		play.RollOffMinDistance = 250

		if p then
			task.delay(3, function()
				fadeScreen(1, 1)
			end)
			local lastTime = os.clock()
			local total = 0

			while currentCamera and currentCamera.Parent do
				local v5 = os.clock() - lastTime

				if not currentCamera or v5 > 4 then
					break
				end

				total += 3
				local v6 = v5 / 4
				local v12 = cubicBezier(
					0 + 1 * (-(math.cos(3.141592653589793 * v6) - 1) / 2),
					v2[1],
					v2[2],
					v2[3],
					v2[4]
				)
				local v13 = 15 - total / 6 * 1.01 * math.cos(total / 4)
				local v14 = v3 * 60 * 0.1
				local v15 = cFrame * (v12 + Vector3.new(0, 0 + (v13 - 0) * v14, 0))
				local position = cFrame.Position
				local v16 = v5 / 4
				currentCamera.CFrame = CFrame.new(
					v15,
					position + Vector3.new(0, 0 + 500 * (-(math.cos(3.141592653589793 * v16) - 1) / 2), 0)
				)
				v3 = RunService.RenderStepped:Wait()
			end
		end
	end
end

return function(data)
	local cFrame = data.CFrame
	local lockRange = data.LockRange
	local globalRange = data.GlobalRange or 1000
	local ID = data.ID or 1
	local magnitude = (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude

	if globalRange < magnitude then
		return
	end

	cutScene(ID, cFrame, magnitude <= lockRange)
end