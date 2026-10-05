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
local fireFist = FX:WaitForChild("FlameEffects").FireFist
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
	TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
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
return function(data)
	local char = data.char
	local root = data.root
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local clientPart = data.projectilePart:WaitForChild("clientPart", 0.5)

	if not clientPart then
		warn("no clientPart found")
		return
	end

	local fliesFor = data.fliesFor
	local isImpact = data.isImpact
	local impactPos = data.impactPos

	if humanoid == nil or root == nil or (root.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local doubleSidedHack = fireFist:WaitForChild("DoubleSidedHack")

	if isImpact then
		local ball = clientPart:FindFirstChild("Ball")

		if ball == nil then
			return
		end

		ball.WeldConstraint:Destroy()
		ball.Anchored = true
		ball.Position = impactPos
		Util.Sound:Play("Mera_FireFistExplosion", impactPos)

		if (ball.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 100 then
			Util.CameraShaker:ShakeOnce(11, 10, 0.01, 0.5)
			local clone = fireFist.Blur:Clone()
			clone.Parent = game.Lighting
			TweenService:Create(clone, v[2], {
				Size = 10
			}):Play()
			destroyAfter(clone, 1)
		end

		for _, descendant in pairs(ball:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
				descendant.Enabled = false
			elseif descendant:IsA("PointLight") or descendant:IsA("Sound") then
				descendant:Destroy()
			end
		end

		local unit = (ball.Position - root.Position).Unit
		local raycastResult = Workspace:Raycast(ball.Position - unit * 4, unit * 40, raycastParams)

		if not raycastResult or math.abs((unit:Dot(raycastResult.Normal))) < 0.2 then
			raycastResult = Workspace:Raycast(
				ball.Position + createVector(0, 4, 0),
				createVector(-0, -14, -0),
				raycastParams
			)
		end

		if raycastResult then
			local v2 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			local effect = createEffect(
				v2 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0),
				doubleSidedHack
			) -- equivalent call inferred; original call site unknown
			TweenService:Create(effect, v[3], {
				Transparency = 1,
				CFrame = effect.CFrame * CFrame.new(0, 35, 0),
				Size = Vector3.new(effect.Size.X * 3.5, 0, effect.Size.Z * 3.5)
			}):Play()
			destroyAfter(effect, 1.1)
			local effect2 = createEffect(
				v2 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0),
				fireFist.Shockwave2
			) -- equivalent call inferred; original call site unknown
			TweenService:Create(effect2, v[3], {
				Size = Vector3.new(effect2.Size.X * 4, effect2.Size.Y, effect2.Size.Z * 4),
				Transparency = 1,
				CFrame = effect2.CFrame * CFrame.Angles(0, 3.14, 0)
			}):Play()
			destroyAfter(effect2, 1)
			local effect3 = createEffect(
				v2 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0),
				fireFist.Scar
			) -- equivalent call inferred; original call site unknown
			effect3.Size *= 1.15

			for _, child in ipairs(effect3:GetChildren()) do
				TweenService:Create(child, v[1], {
					Transparency = 1
				}):Play()
			end

			destroyAfter(effect3, 1.26)
		end

		local effect = createEffect(ball.CFrame, fireFist.Explosion) -- equivalent call inferred; original call site unknown
		destroyAfter(effect, 1.5)

		for _, emitter in ipairs(effect:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			scaleParticle({
				Emitter = emitter,
				Scale = 1.5,
				Time = 0.05,
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out
			})
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	else
		local effect = createEffect(clientPart.CFrame * CFrame.Angles(1.57, 0, 0), fireFist.Ball) -- equivalent call inferred; original call site unknown
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = effect
		weldConstraint.Part1 = clientPart
		weldConstraint.Parent = effect
		effect.Parent = clientPart
		Util.Sound:Play("Mera_FireFistExplosion", clientPart.Position)
		destroyAfter(effect, fliesFor + 1)
		task.delay(fliesFor, function()
			for _, effect2 in ipairs(effect:GetDescendants()) do
				if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Beam") or effect2:IsA("Trail")) then
					continue
				end

				effect2.Enabled = false
			end
		end)
		Util.Sound:Play("FireFistBallLoop", effect)
	end
end