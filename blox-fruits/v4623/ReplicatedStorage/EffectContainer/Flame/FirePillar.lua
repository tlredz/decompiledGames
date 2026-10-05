local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local firePillar = FX:WaitForChild("FlameEffects").FirePillar
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local TweenService = game:GetService("TweenService")
local scaleParticle = Util.ScaleParticle

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(p, p2)
	return p * p2
end

local v = {
	TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {
	_WorldOrigin,
	Workspace.CurrentCamera,
	Workspace.Characters,
	Workspace.Enemies
}
local rocksModule = Util.RocksModule
return function(data)
	local char = data.char
	local root = data.root
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local scale = data.scale or 1

	if humanoid == nil or root == nil then
		return
	end

	local position = root.Position

	if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 100 * scale then
		Util.CameraShaker:ShakeOnce(19, 14, 0, 2.5)
		local clone = firePillar.Blur:Clone()
		clone.Parent = game.Lighting
		TweenService:Create(clone, v[1], {
			Size = 7
		}):Play()
		task.delay(1, function()
			TweenService:Create(clone, v[2], {
				Size = 0
			}):Play()
			destroyAfter(clone, 0.6)
		end)
	end

	local effect = createEffect(CFrame.new(root.Position) * CFrame.new(0, -1, 0), firePillar.Pillar) -- equivalent call inferred; original call site unknown

	if scale ~= 1 then
		for _, emitter in pairs(effect:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Rate *= 1.4
			scaleParticle({
				Emitter = emitter,
				Time = 0,
				Scale = scale * (({
					Spinny = 1.8,
					Flies = 1.8,
					["Small Spinny"] = 1.8,
					["Energy 2"] = 2.2,
					Lines = 2.2,
					Haze = 1.8
				})[emitter.Name] or 1)
			})
		end
	end

	destroyAfter(effect, 3.5)
	Util.Sound:Play("Mera_FirePillarExplosion" .. (scale > 1 and "2" or ""), root.Position)
	local children = effect.Attachment:GetChildren()

	for _, v3 in ipairs(children) do
		v3:Emit(2)
		v3.Rate *= 0.4
		v3.Enabled = true
	end

	local raycastResult = Workspace:Raycast(
		root.Position - createVector(0, -10, 0),
		createVector(0, -40, 0),
		raycastParams
	)

	if raycastResult then
		local effect2 = createEffect(
			CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0),
			firePillar.Scar
		) -- equivalent call inferred; original call site unknown
		effect2.Size *= Vector3.new(1.15 * scale, 0.35, 1.15 * scale)
		task.delay(1.66 * scale, function()
			for _, child in ipairs(effect2:GetChildren()) do
				TweenService:Create(child, v[3], {
					Transparency = 1
				}):Play()
			end

			destroyAfter(effect2, 1.26)
		end)
	end

	rocksModule.Ground(
		root.Position,
		35 * scale,
		createVector(5, 7.5, 5) * scale,
		{ Workspace.Map },
		math.ceil(12 * scale),
		false,
		2 * scale,
		true
	)

	if scale == 1 then
		task.wait(1)
	else
		task.wait(0.4)
	end

	for _, v3 in ipairs(children) do
		v3.Enabled = false
	end
end