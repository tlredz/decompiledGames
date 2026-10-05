game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
require(game.ReplicatedStorage.Util.Debris)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, eff)
	local clone = eff:Clone()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

for _, child in pairs(script.eff:GetChildren()) do
	child:SetAttribute("EmitCount", (math.ceil(child:GetAttribute("EmitCount") * 0.75)))
end

local v = 0
return function(instance)
	local duration = instance.Duration or 1
	local colorSequence = instance.ColorSequence or ColorSequence.new(
		Color3.fromRGB(255, 146, 57),
		Color3.fromRGB(252, 93, 34)
	)
	local v2 = instance.Size[1] or 20
	local v3 = instance.Size[2] or 50
	local cFrame = instance.CFrame
	local value = colorSequence.Keypoints[1].Value
	local value2 = colorSequence.Keypoints[2].Value
	local magnitude = (workspace.CurrentCamera.CFrame.Position - cFrame.p).magnitude

	if 500 + v2 * 2 + v3 * 2 < magnitude then
		return
	end

	local v4 = v2 + (v3 - v2) * 0.75
	local v5 = math.max(0.25, (10 - v) / 4)
	local effect = createEffect(cFrame, script.eff) -- equivalent call inferred; original call site unknown
	v += 1
	task.delay(1.5 + duration, function()
		effect:Destroy()
		v -= 1
	end)

	for _, child in pairs(effect:GetChildren()) do
		ScaleParticle({
			Emitter = child,
			Scale = v4 / 16,
			Time = 0,
			EasingStyle = Enum.EasingStyle.Exponential,
			EasingDirection = Enum.EasingDirection.Out
		})

		if child:FindFirstChild("ReColor") and value then
			child.Color = ColorSequence.new(value)
		elseif child:FindFirstChild("ReColor2") and value2 then
			child.Color = ColorSequence.new(value2)
		end

		child:Emit((math.ceil(child:GetAttribute("EmitCount") * 0.5 * v5)))
	end
end