local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local scaleParticle = Util.ScaleParticle
local debris = Util.Debris
local v = {
	TweenInfo.new(0.2, Enum.EasingStyle.Sine),
	TweenInfo.new(1.4, Enum.EasingStyle.Linear),
	TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, puddle, p, _)
	local clone = puddle:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

return function(p, scale, p3, value)
	local v2 = value or 0.75
	local cframe = CFrame.new(p + createVector(0, 5, 0))
	local ray, v3, v4 = Util.Ray(
		cframe.Position,
		CFrame.new(p + createVector(0, 5, 0)).UpVector.Unit * -10,
		{ workspace.Characters, workspace.Enemies },
		false
	)

	if not ray then
		return
	end

	local effect = createEffect(
		CFrame.new(v3, v3 + v4 * 10) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			math.random(-10, 10) / 10 * 3.141592653589793,
			0
		),
		script.puddle
	) -- equivalent call inferred; original call site unknown
	debris:AddItem(effect, 1.25 + v2)
	effect.Size *= scale
	effect.CFrame *= CFrame.Angles(0, Random.new():NextNumber(-3.14, 3.14), 0)

	if p3 ~= false then
		scaleParticle({
			Emitter = effect.Smoke,
			Scale = scale,
			Time = 0.05,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out
		})
		effect.Smoke:Emit(20)
	end

	TweenService:Create(effect, v[1], {
		Size = Vector3.new(effect.Size.X * 3, effect.Size.Y, effect.Size.Z * 3)
	}):Play()
	task.delay(0.15, function()
		TweenService:Create(effect, TweenInfo.new(0.6499999999999999 + v2, Enum.EasingStyle.Linear), {
			Size = Vector3.new(effect.Size.X * 1.35, effect.Size.Y, effect.Size.Z * 1.35),
			CFrame = effect.CFrame * CFrame.Angles(0, 1.0471975511965976, 0)
		}):Play()
		task.wait(v2)
		TweenService:Create(effect, v[3], {
			Size = Vector3.new()
		}):Play()
	end)
end