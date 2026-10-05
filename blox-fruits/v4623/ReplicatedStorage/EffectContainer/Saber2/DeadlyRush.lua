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
local deadlyRush = FX:WaitForChild("Saber").DeadlyRush
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	destroyAfter(clone, 7)
	return clone
end

local _ = Util.CraterModule
local scaleParticle = Util.ScaleParticle

for _, emitter in pairs(deadlyRush.Start:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") and emitter.Orientation == Enum.ParticleOrientation.VelocityParallel then
		scaleParticle({
			Emitter = emitter,
			Scale = 2,
			Time = 0
		})
	end
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame

	if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	if player == game.Players.LocalPlayer then
		local position = cFrame.Position
		local v = 8
		local v2 = 14
		local v3 = 0.2
		local v4 = 0.7

		if (999 or 300) > (Workspace.CurrentCamera.CFrame.Position - position).Magnitude then
			Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
		end
	end

	local _ = data.originCFrame
	local targetCFrame = data.targetCFrame
	local _ = { TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true) }
	local cFrame2 = hrp.CFrame
	local clone = deadlyRush.Start:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame2
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 7)
	local descendants = clone:GetDescendants()
	clone.Massless = true
	clone.Weld.Part0 = hrp
	clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.new(0, 0, -7)
	local v2 = 0

	for _, emitter in ipairs(descendants) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emitter:Emit(1)
		v2 = math.max(v2, emitter.Lifetime.Max)
	end

	destroyAfter(clone, v2 + 0.5)
	Util.Sound:Play("SaberLightning")
	wait()
	TweenService:Create(hrp, TweenInfo.new(0.125), {
		CFrame = targetCFrame
	}):Play()
	task.wait(0.125)
	clone.Weld:Destroy()
	clone.Anchored = true

	for _, emitter in ipairs(descendants) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end