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
	TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
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

	if humanoid == nil or root == nil or (root.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	if isImpact then
		local ballSmall = clientPart:FindFirstChild("BallSmall")

		if ballSmall == nil then
			return
		end

		ballSmall.WeldConstraint:Destroy()
		ballSmall.Anchored = true
		ballSmall.Position = impactPos
		Util.Sound:Play("BeadSpawn", impactPos)

		for _, descendant in pairs(ballSmall:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
				descendant.Enabled = false
			elseif descendant:IsA("PointLight") or descendant:IsA("Sound") then
				descendant:Destroy()
			end
		end

		local unit = (ballSmall.Position - root.Position).Unit
		local raycastResult = Workspace:Raycast(ballSmall.Position - unit * 4, unit * 40, raycastParams)

		if not raycastResult or math.abs((unit:Dot(raycastResult.Normal))) < 0.2 then
			raycastResult = Workspace:Raycast(
				ballSmall.Position + createVector(0, 4, 0),
				createVector(-0, -14, -0),
				raycastParams
			)
		end

		if raycastResult then
			local effect = createEffect(
				CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0),
				fireFist.Scar
			) -- equivalent call inferred; original call site unknown
			effect.Size *= 0.5

			for _, child in ipairs(effect:GetChildren()) do
				TweenService:Create(child, v[1], {
					Transparency = 1
				}):Play()
			end

			destroyAfter(effect, 0.91)
		end

		local effect = createEffect(ballSmall.CFrame, fireFist.Explosion) -- equivalent call inferred; original call site unknown
		destroyAfter(effect, 1.5)

		for _, emitter in ipairs(effect:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			scaleParticle({
				Emitter = emitter,
				Scale = 0.45,
				Time = 0
			})
			emitter:Emit((math.ceil((emitter:GetAttribute("EmitCount") or 1) / 2.5)))
		end
	else
		local effect = createEffect(clientPart.CFrame * CFrame.Angles(1.57, 0, 0), fireFist.BallSmall) -- equivalent call inferred; original call site unknown
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = effect
		weldConstraint.Part1 = clientPart
		weldConstraint.Parent = effect
		effect.Parent = clientPart
		Util.Sound:Play("BeadBoom", clientPart.Position)
		destroyAfter(effect, fliesFor + 1)
		task.delay(fliesFor, function()
			for _, effect2 in ipairs(effect:GetDescendants()) do
				if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Beam") or effect2:IsA("Trail")) then
					continue
				end

				effect2.Enabled = false
			end
		end)
	end
end