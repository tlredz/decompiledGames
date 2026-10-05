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
	TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

local function iceSpike(originCF, cframe, i)
	local effect = createEffect(originCF * cframe * CFrame.Angles(0, 3.14, 0), iceStomp["Spike" .. i]) -- equivalent call inferred; original call site unknown
	local size = effect.Size
	effect.Size = Vector3.new()
	local Y = effect.Position.Y
	effect.Position = Vector3.new(effect.Position.X, Y - cframe.Position.Y * 2, effect.Position.Z)
	TweenService:Create(effect, v[1], {
		Size = size,
		Position = Vector3.new(effect.Position.X, Y, effect.Position.Z)
	}):Play()

	for _, child in ipairs(effect:GetChildren()) do
		if child.Name == "Smoke" then
			scaleParticle({
				Emitter = child,
				Scale = size.Y / 14,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Sine,
				EasingDirection = Enum.EasingDirection.Out
			})
		elseif child.Name == "Crescents" then
			scaleParticle({
				Emitter = child,
				Scale = i,
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

		task.wait(2)
		TweenService:Create(effect, v[2], {
			Position = Vector3.new(effect.Position.X, Y - cframe.Position.Y * 2, effect.Position.Z),
			Transparency = 1
		}):Play()
		destroyAfter(effect, 0.5)
	end)
end

return function(p)
	local char = p.char
	local originCF = p.originCF

	if char:FindFirstChildOfClass("Humanoid") == nil or (originCF.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	task.wait(0.05)
	local effect = createEffect(originCF * CFrame.new(1, -4, 1.25), iceStomp.FootSpike) -- equivalent call inferred; original call site unknown
	destroyAfter(effect, 2)
	local size = effect.Size
	effect.Size = Vector3.new()
	TweenService:Create(effect, v[1], {
		Size = size,
		CFrame = effect.CFrame * CFrame.new(0, 2, 0)
	}):Play()
	task.delay(0.15, function()
		effect.Material = Enum.Material.Ice
		task.wait(1.5)
		TweenService:Create(effect, v[2], {
			CFrame = effect.CFrame * CFrame.new(0, -2, 0),
			Transparency = 1
		}):Play()
	end)
	Util.Sound:Play("Ice_stomp", originCF.Position)

	for i = 1, 2 do
		local effect2 = createEffect(
			originCF * CFrame.Angles(0, 3.14, 0) * CFrame.new(0, -3.2, 16),
			iceStomp["Floor" .. i]
		) -- equivalent call inferred; original call site unknown
		local size2 = effect2.Size
		effect2.Size = Vector3.new()
		local v4, v5

		if i == 2 then
			effect2.CFrame *= CFrame.new(0, -0.25, 31)
			v4 = 3
			v5 = 5
		else
			v4 = 1
			v5 = 2
		end

		TweenService:Create(effect2, v[1], {
			Size = size2
		}):Play()
		task.delay(0.1, function()
			for i2 = v4, v5 do
				if i2 == 1 then
					iceSpike(originCF, CFrame.new(0, 1.5, -7.5), 1)
				elseif i2 == 2 then
					iceSpike(originCF, CFrame.new(0, 5, -20), 2)
				elseif i2 == 3 then
					iceSpike(originCF, CFrame.new(0, 8, -31), 3)
				elseif i2 == 4 then
					iceSpike(originCF, CFrame.new(-1, 8, -44), 4)
				else
					iceSpike(originCF, CFrame.new(0, 11.5, -61), i2)
				end
			end

			task.wait(0.1)
			effect2.Material = Enum.Material.Ice
			task.wait(2.1)
			TweenService:Create(effect2, v[2], {
				Size = Vector3.new()
			}):Play()
			destroyAfter(effect2, 0.5)
		end)
		task.wait(0.05)
	end
end