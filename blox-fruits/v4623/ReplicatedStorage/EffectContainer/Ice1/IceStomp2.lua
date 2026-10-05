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
local iceStomp = FX:WaitForChild("IceEffects").IceStomp
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
	TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	return clone
end

local function iceSpike(originCF, cframe, i, p)
	local effect = createEffect(
		originCF * cframe * CFrame.Angles(0, 3.14, 0),
		iceStomp["Spike" .. math.min(5, (math.ceil(0.5 + i / 2)))]
	) -- equivalent call inferred; original call site unknown
	local v3 = 1 + (p - 1) / 3
	local v4 = effect.Size * v3
	effect.Size = Vector3.new()
	local Y = effect.Position.Y
	effect.Position = Vector3.new(effect.Position.X, Y - cframe.Position.Y * 2, effect.Position.Z)
	effect.Parent = _WorldOrigin
	TweenService:Create(effect, v[1], {
		Size = v4 * createVector(1, 2, 1),
		Position = Vector3.new(effect.Position.X, Y, effect.Position.Z)
	}):Play()

	for _, child in ipairs(effect:GetChildren()) do
		if child.Name == "Smoke" then
			scaleParticle({
				Emitter = child,
				Scale = v4.Y / 14 + v3 * 0.1,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Sine,
				EasingDirection = Enum.EasingDirection.Out
			})
		elseif child.Name == "Crescents" then
			scaleParticle({
				Emitter = child,
				Scale = i * v3,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Sine,
				EasingDirection = Enum.EasingDirection.Out
			})
		end

		child:Emit(child:GetAttribute("EmitCount"))
	end

	task.delay(0.15, function()
		effect.Material = Enum.Material.Ice

		for _, child in ipairs(effect:GetChildren()) do
			child.LockedToPart = false
		end

		task.wait(5.5)
		TweenService:Create(effect, v[2], {
			Position = Vector3.new(effect.Position.X, Y - cframe.Position.Y * 2, effect.Position.Z),
			Size = effect.Size * createVector(1.2, 0.8, 1.2),
			Transparency = 1
		}):Play()
		destroyAfter(effect, 2)
	end)
end

return function(p)
	local originCF = p.originCF

	if (originCF.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1300 then
		return
	end

	task.wait(0.05)
	Util.Sound:Play("IceSummon", originCF.Position)

	for i = 1, 4 do
		local effect = createEffect(
			originCF * CFrame.Angles(0, 3.14, 0) * CFrame.new(0, -3.2, 16),
			iceStomp["Floor" .. math.min(math.ceil(i / 3), 2)]
		) -- equivalent call inferred; original call site unknown
		local v3 = effect.Size * ((i - 1) / 3 + 0.5) * 1.25
		local vector2 = Vector3.new(v3.X, 1 + math.random() * 0.1, v3.Z)
		effect.Size = Vector3.new()
		effect.CFrame *= CFrame.new(0, 0.15, vector2.Z / 1.5 - 15)
		effect.Parent = _WorldOrigin
		local v4 = (i - 1) * 2 + 1
		local v5 = v4 + 1
		TweenService:Create(effect, v[1], {
			Size = vector2
		}):Play()
		local v6 = i
		task.delay(0.1, function()
			for i2 = v4, v5 do
				local v8 = i2 * 16
				iceSpike(originCF, CFrame.new(0, v8 * 0.1, -v8 + 9), i2, v6)
			end

			task.wait(0.1)
			effect.Material = Enum.Material.Ice
			task.wait(5.5)
			TweenService:Create(effect, v[3], {
				Size = effect.Size * createVector(0, 1, 0)
			}):Play()
			destroyAfter(effect, 1.5)
		end)
		task.wait()
	end
end