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
local iceAge = FX:WaitForChild("IceEffects").IceAge
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
	TweenInfo.new(0.25, Enum.EasingStyle.Linear),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.5, Enum.EasingStyle.Linear),
	TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine),
	TweenInfo.new(0.35, Enum.EasingStyle.Quad)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

local function iceCircle(i, originCF, p, p2, p3)
	local v2 = p * 2.125
	local v3 = p2 * 1.625
	local v4 = 360 / i

	for i2 = 1, i do
		local effect = createEffect(
			originCF * CFrame.Angles(0, math.rad(i2 * v4), 0) * CFrame.new(0, p3, v2) * CFrame.Angles(
				0.7853981633974483,
				math.rad((math.random(-90, 90))),
				(math.rad((math.random(-90, 90))))
			),
			iceAge.Cube
		) -- equivalent call inferred; original call site unknown
		destroyAfter(effect, 4)
		TweenService:Create(effect, v[4], {
			Size = effect.Size * v3 * Random.new():NextNumber(0.5, 1.5),
			Transparency = 0
		}):Play()

		for _, child in ipairs(effect:GetChildren()) do
			if child.Name == "Smoke" then
				scaleParticle({
					Emitter = child,
					Scale = v3 / 4,
					Time = 0
				})
			end

			child:Emit((math.ceil(child:GetAttribute("EmitCount") * 0.4)))
		end

		task.delay(0.5, function()
			effect.Material = Enum.Material.Ice
			task.wait(1.75)

			if i == 25 then
				TweenService:Create(effect, v[3], {
					Transparency = 1,
					Position = effect.Position - Vector3.new(0, -p3 * 15, 0)
				}):Play()
			else
				TweenService:Create(effect, v[3], {
					Transparency = 1,
					Position = effect.Position - Vector3.new(0, -p3 * 5, 0)
				}):Play()
			end
		end)
	end
end

return function(p)
	local char = p.char
	local originCF = p.originCF

	if char:FindFirstChildOfClass("Humanoid") == nil then
		return
	end

	local position = originCF.Position

	if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	local effect = createEffect(originCF * CFrame.new(0, -3.5, 0), iceAge.Floor) -- equivalent call inferred; original call site unknown
	destroyAfter(effect, 5)
	TweenService:Create(effect, v[1], {
		Size = effect.Size * 8.7 * 1.75,
		Transparency = 0
	}):Play()

	if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 125 then
		Util.CameraShaker:ShakeOnce(14, 10, 0, 1.5)
		local clone = iceAge.Blur:Clone()
		clone.Parent = game.Lighting
		TweenService:Create(clone, v[2], {
			Size = 0
		}):Play()
		destroyAfter(clone, 1)
	end

	Util.Sound:Play("Ice_age", originCF.Position)
	local effect2 = createEffect(originCF * CFrame.new(0, -2, 0), iceAge.eff) -- equivalent call inferred; original call site unknown
	destroyAfter(effect2, 2)

	for _, child in ipairs(effect2.Attachment:GetChildren()) do
		child:Emit((math.ceil(child:GetAttribute("EmitCount") * 0.5)))
	end

	task.delay(0.25, function()
		effect.Material = Enum.Material.Ice
		task.wait(2.65)
		TweenService:Create(effect, v[2], {
			Size = Vector3.new(),
			CFrame = effect.CFrame * CFrame.new(0, 1, 0)
		}):Play()
		TweenService:Create(effect, v[3], {
			Transparency = 1
		}):Play()
	end)

	for i = 10, 25, 5 do
		if i == 10 then
			iceCircle(10, originCF, 10, 1.5, -3)
		elseif i == 15 then
			iceCircle(15, originCF, 15, 2.5, -2.5)
		elseif i == 20 then
			iceCircle(20, originCF, 20 + 1, 3, -1.25)
		else
			iceCircle(i, originCF, i + 3.75, 4.25, -0.5)
		end

		task.wait(0.1)
	end
end