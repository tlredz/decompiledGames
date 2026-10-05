local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local emitTree = VFX.EmitTree
local t = require(ReplicatedStorage.Packages.t)
local v = {
	{
		Seconds = 0.22,
		Rise = 2.6,
		Squash = 0.92,
		Stretch = 1.12,
		Pitch = -6,
		Roll = 5
	},
	{
		Seconds = 0.18,
		Rise = 1.65,
		Squash = 0.96,
		Stretch = 1.08,
		Pitch = 4,
		Roll = -3
	},
	{
		Seconds = 0.15,
		Rise = 0.9,
		Squash = 0.985,
		Stretch = 1.04,
		Pitch = -2,
		Roll = 1.5
	}
}
local FuseMachineMotion = {}
local easingStyle = Enum.EasingStyle
local easingDirection = Enum.EasingDirection

-- equivalent calls inferred from this helper; original call sites unknown
local function backOut(p: number)
	return TweenService:GetValue(p, easingStyle.Back, easingDirection.Out)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bounceOut(p: number)
	return TweenService:GetValue(p, easingStyle.Bounce, easingDirection.Out)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function quadIn(p: number)
	return TweenService:GetValue(p, easingStyle.Quad, easingDirection.In)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function locateEmitter(instance, instance2)
	return instance2:FindFirstChild("EmitFuse") or instance:FindFirstChild("EmitFuse")
end

local function poseAt(data, p: number, scale: number)
	if p < 0.34 then
		local v3 = backOut(math.min(p / 0.34, 1)) -- equivalent call inferred; original call site unknown
		return data.Rise * v3, data.Pitch * v3, data.Roll * v3, scale + (data.Stretch - scale) * v3
	else
		local v2 = math.max(p - 0.34, 0) / 0.66
		local v3 = 1 - TweenService:GetValue(v2, easingStyle.Bounce, easingDirection.Out)
		local v4

		if v2 < 0.55 then
			local v6 = quadIn(v2 / 0.55) -- equivalent call inferred; original call site unknown
			v4 = data.Stretch + (data.Squash - data.Stretch) * v6
		else
			local v6 = bounceOut((v2 - 0.55) / 0.45) -- equivalent call inferred; original call site unknown
			v4 = data.Squash + (scale - data.Squash) * v6
		end

		return data.Rise * v3, data.Pitch * v3, data.Roll * v3, v4
	end
end

function FuseMachineMotion.Bounce(instance, callback)
	t.strict(t.instanceIsA("Model"))(instance)
	t.strict(t.callback)(callback)
	local pivot = instance:GetPivot()
	local scale = instance:GetScale()

	for _, v2 in ipairs(v) do
		local v3 = 0
		local flag = false

		while v3 < v2.Seconds do
			local v4 = RunService.PreRender:Wait()

			if not callback() then
				flag = true
				break
			end

			v3 = math.min(v3 + v4, v2.Seconds)
			local v5, v6, v7, v8 = poseAt(v2, v3 / v2.Seconds, scale)
			instance:ScaleTo(v8)
			instance:PivotTo(pivot * CFrame.new(0, v5, 0) * CFrame.Angles(math.rad(v6), 0, (math.rad(v7))))
		end

		instance:ScaleTo(scale)
		instance:PivotTo(pivot)

		if flag then
			return false
		end
	end

	return true
end

function FuseMachineMotion.Burst(instance, instance2)
	t.strict(t.instanceIsA("Model"))(instance)
	t.strict(t.instanceIsA("BasePart"))(instance2)
	local v2 = locateEmitter(instance, instance2) -- equivalent call inferred; original call site unknown

	if v2 ~= nil then
		emitTree(v2)
	end
end

function FuseMachineMotion.Run(p, p2, callback)
	t.strict(t.instanceIsA("Model"))(p)
	t.strict(t.instanceIsA("BasePart"))(p2)
	t.strict(t.callback)(callback)
	local bounce = FuseMachineMotion.Bounce(p, callback)

	if bounce then
		FuseMachineMotion.Burst(p, p2)
	end

	return bounce
end

return FuseMachineMotion