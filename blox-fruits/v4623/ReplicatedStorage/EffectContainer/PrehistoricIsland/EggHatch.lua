local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local debris = Util.Debris

local function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function easeOutCubic(p, p2, p3)
	return p + (p2 - p) * (1 - math.pow(1 - p3, 3))
end

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function charInRange(vector2: Vector3, p: number)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local magnitude = (humanoidRootPart.Position - vector2).magnitude

		if magnitude <= p then
			return magnitude
		end
	end

	return false
end

local function qFromToRotation(p, unit)
	local unit2 = p.unit
	local unit3 = unit.unit
	local dot = unit2:Dot(unit3)

	if dot > 0.99999 then
		return CFrame.new()
	end

	if dot < -0.99999 then
		local unit4 = (unit2 + unit3).unit
		return CFrame.fromAxisAngle(unit4, 3.141592653589793)
	end

	local cross = unit2:Cross(unit3)
	local v = math.acos(dot)
	return CFrame.fromAxisAngle(cross, v)
end

local _ = {
	EGG_SHAKE_DUR = 8
}
return function(player)
	local character = player.Character
	local eggCFrame = player.EggCFrame
	local collectDelay = player.CollectDelay or 1.5

	if (workspace.CurrentCamera.CFrame.Position - eggCFrame.Position).Magnitude > 800 then
		return
	end

	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local clone = script.EggModel:Clone()
		local cframe = CFrame.new(eggCFrame.Position)
		clone:PivotTo(cframe)
		clone.Parent = _WorldOrigin
		local descendants = clone:GetDescendants()

		for _, beam in ipairs(descendants) do
			if beam:IsA("Beam") then
				beam.Enabled = false
			end
		end

		local lastTime = os.clock()

		for _, emitter in ipairs(clone.EggCrust.Idle:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		while true do
			local v = os.clock() - lastTime

			if v >= 2.5 then
				break
			end

			local v2 = math.min(v / 2.5, 1)
			local v3 = 2 + 4 * (1 - math.pow(1 - v2, 3))
			local v4 = 2 + 4 * (1 - math.pow(1 - v2, 3))
			local v5 = 10 + -8 * (1 - math.pow(1 - v2, 3))
			local v6 = 0 + 1.5 * (1 - math.pow(1 - v2, 3))
			local v7 = v6 * math.cos(v3 * v + 0.5)
			local v8 = v6 * math.sin(v4 * v + 0.5)
			clone:PivotTo(cframe * CFrame.new(v7, 0, v8) * ((cframe - cframe.Position) * qFromToRotation(
				-Vector3.new(v7, 0, v8) + v5 * Vector3.yAxis.Unit,
				Vector3.yAxis.Unit
			)))
			RunService.Heartbeat:Wait()
		end

		os.clock()

		for _, emitter in ipairs(clone.EggCrust.Idle:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in ipairs(clone.Core.Molten.Exposed:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		if character == game.Players.LocalPlayer.Character and (workspace.CurrentCamera.CFrame.Position - cframe.Position).Magnitude < 400 then
			Util.CameraShaker:ShakeOnce(5, 3, 0.1, 1)
		end

		for _, emitter in ipairs(clone.EggCrust.Burst:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		clone.EggCrust.Transparency = 1
		clone.BrokenBase.Transparency = 1
		clone:PivotTo(cframe)
		local descendants2 = clone:GetDescendants()

		for _, beam in ipairs(descendants2) do
			if beam:IsA("Beam") then
				beam.Enabled = true
			end
		end

		task.wait(0.1)
		local lastTime2 = os.clock()
		local pivot = clone.Core:GetPivot()

		while true do
			local v = os.clock() - lastTime2

			if collectDelay <= v or not (humanoidRootPart and humanoidRootPart.Parent) then
				break
			end

			local position = cframe.Position
			local position2 = cframe.Position
			local v2 = position2 + (humanoidRootPart.Position + createVector(0, 60, 0) - position2) * 0.05
			local position3 = cframe.Position
			local v3 = {
				position,
				v2,
				position3 + (humanoidRootPart.Position + createVector(0, 5, 0) - position3) * 0.5,
				humanoidRootPart.Position
			}
			local v4 = cubicBezier(math.max(0.001, v / collectDelay), unpack(v3))
			clone.Core:PivotTo(CFrame.new(v4) * pivot.Rotation)
			RunService.Heartbeat:Wait()
		end

		clone.Core:Destroy()

		if character and humanoidRootPart then
			local clone2 = script.EggCollectBurst.EggCollect:Clone()
			debris:AddItem(clone2, 3)
			clone2.Parent = humanoidRootPart
			local children = clone2:GetChildren()

			for _, v in ipairs(children) do
				v:Emit(v:GetAttribute("EmitCount"))
			end
		end
	end
end