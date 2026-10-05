local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local _ = {
	0,
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
	TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(data)
	local cFrame = data.CFrame
	local travelTime = data.TravelTime or 0.2
	local speed = data.Speed or 300
	local color = data.Color or Color3.fromRGB(88, 169, 255)
	local slashColor = data.SlashColor or Color3.fromRGB(224, 378, 510)

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).magnitude > 400 then
		return
	end

	if data.Stage ~= 2 then
		Sound:Play("KiBlastFireShort", cFrame)
		local cFrame2 = cFrame * CFrame.new(0, 0, -5) * CFrame.Angles(1.57, 0, 0)
		local clone = script.release:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame2
		clone.Parent = _WorldOrigin
		Debris:AddItem(clone, 1)

		for _, child in pairs(clone.Attachment:GetChildren()) do
			local lifetime = child.Lifetime
			child.Lifetime = NumberRange.new(lifetime.Min * 0.85, lifetime.Max * 0.85)
			local speed2 = child.Speed
			child.Speed = NumberRange.new(speed2.Min * 1.15, speed2.Max * 1.15)

			if child.Name ~= "Haze" and child.Name ~= "Star" then
				child.Color = ColorSequence.new(color)
			end

			child:Emit(child:GetAttribute("EmitCount"))
		end
	end

	if data.Stage == 1 then
		return
	end

	local cFrame3 = cFrame * CFrame.Angles(-0.1847058823529412, 3.14, 1.57)
	local clone = script.slash:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame3
	clone.Parent = _WorldOrigin
	task.delay(travelTime + 0.1, function()
		clone:Destroy()
	end)
	clone.Decal.Color3 = slashColor
	clone.slash2.Decal.Color3 = slashColor
	local children = clone.Part:GetChildren()

	for _, emitter in pairs(children) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if emitter.Name ~= "White" then
			emitter.Color = ColorSequence.new(color)
		end

		emitter:Emit(5)
	end

	if data.Timestamp then
		local v2 = data.Timestamp - workspace:GetServerTimeNow()

		if travelTime < v2 then
			v2 = travelTime * 0.8
		end

		if v2 > 0.05 then
			local v3 = v2 * 0.8
			travelTime -= v3
			speed /= 1 - v3 / travelTime
		end
	end

	clone.CFrame = cFrame * CFrame.Angles(-0.1847058823529412, 3.14, 1.57) * CFrame.Angles(0, 0, 0.7853981633974483)
	local bodyVelocity = Instance.new("BodyVelocity", clone)
	bodyVelocity.MaxForce = createVector(10000000000, 10000000000, 10000000000)
	bodyVelocity.Velocity = cFrame.LookVector * speed
	local v2 = true
	task.delay(travelTime / 1.05, function()
		local tweenInfo = TweenInfo.new(
			travelTime - travelTime / 1.15,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out
		)
		TweenService:Create(clone.Mesh, tweenInfo, {
			Scale = createVector(0, 0, 0)
		}):Play()
		TweenService:Create(clone.slash2.Mesh, tweenInfo, {
			Scale = createVector(0, 0, 0)
		}):Play()
		task.wait(travelTime - travelTime / 1.05)
		v2 = false

		for _, emitter in pairs(children) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter.Name == "Smoke" then
				emitter:Emit(12)
			end

			emitter.Enabled = false
		end

		local part = clone.Part
		part.Anchored = true
		part.Parent = _WorldOrigin
		Debris:AddItem(part, 0.5)
	end)
end