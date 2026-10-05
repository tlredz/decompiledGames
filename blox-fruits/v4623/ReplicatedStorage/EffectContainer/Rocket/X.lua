local createVector = vector.create
local _ = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local FX = require(game.ReplicatedStorage.FX)
local phase1 = FX:WaitForChild("Rocket").X.Phase1
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)

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
	local v2 = math.random(20, 30) * 2
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-v2, v2) / 2, math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-v2, v2) / 2, math.random(-v2, v2))
	local lastTime = tick()
	local v5 = magnitude / p / 60
	local clone2 = phase1.Rocket:Clone()
	clone2.CFrame = clone.CFrame * CFrame.new(0, 0, -3)
	clone2.Size *= 1.8
	clone2.Parent = workspace._WorldOrigin

	while tick() - lastTime < v5 do
		local v6 = (tick() - lastTime) / v5
		local v7 = cubicBezier(v6, position, v3, v4, position2)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v7, position2), v6)
		clone2.CFrame = clone.CFrame * CFrame.new(0, 0, -3)
		RunService.Heartbeat:Wait()
	end

	clone2:Destroy()
end

return function(p)
	local position0 = p.Position0
	local _ = p.Position1

	if (position0.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	Util.Sound:Play("Mera_FireFlies_Launch", position0)
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = false
	raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
	local cFrame = position0 * CFrame.Angles(-1.2217304763960306, 0, 0)
	local clone = phase1.StartImpact:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	DeleteImpactAfterDuration(clone)

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
			task.delay(v2.Lifetime.Max + 0.1, function()
				v2:Clear()
			end)
		end)
	end

	local clone2 = phase1.Projectile:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = folder

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local position1 = p.Position1
	local clone3 = phase1.StartImpact2:Clone()
	clone3.CFrame = position1
	clone3.Parent = folder

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	TrailCurve(clone2, cFrame.Position, position1.Position, 6)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if (clone2.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude < 60 then
		Util.CameraShaker:ShakeOnce(8, 8, 0.15, 0.6)
	end

	Util.Sound:Play("GenericExplosion", clone2.CFrame, 20)
	local clone4 = phase1.Explosion:Clone()
	clone4.CFrame = clone2.CFrame
	clone4.Parent = folder
	DeleteImpactAfterDuration(clone4)

	for _, emitter in pairs(clone4:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		coroutine.wrap(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)()
	end

	local clone5 = phase1.GroundImpact:Clone()
	clone5.CFrame = position1
	clone5.Parent = folder
	DeleteImpactAfterDuration(clone5)

	for _, emitter in pairs(clone5:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.delay(2, function()
		folder:Destroy()
	end)
end