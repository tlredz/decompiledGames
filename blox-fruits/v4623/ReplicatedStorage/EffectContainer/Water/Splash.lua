local createVector = vector.create
local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local tweenModel = Util.TweenModel
local particleScaler = Util.ParticleScaler
local currentCamera = workspace.CurrentCamera
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 1
	local duration = data.Duration or data.TimeInfluence or 1
	local magnitude = (currentCamera.CFrame.p - cFrame.p).Magnitude

	if 1000 + 4 * scale < magnitude then
		return
	end

	local clone = script.WaterSplash:Clone()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Util.Sound:Play("Other.WaterSplash", cFrame.p, 4 * scale, 1 / (duration * 0.75), data.Volume)
	local v = 0

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		v = math.max(v, emitter.Lifetime.Max)
		particleScaler.Particle(emitter, scale, true)
		emitter.Lifetime = particleScaler.NumberRange(emitter.Lifetime, duration)
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	Util.Debris:AddItem(clone, v + 0.1)
	local random = Random.new()
	tweenModel(script.WindRing, {
		Scale = scale,
		Size = createVector(0.65, 2, 0.65),
		CFrame = cFrame * CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0),
		Transparency = 0.5
	}, {
		Size = createVector(1.125, 0.15, 1.125),
		CFrame = CFrame.Angles(0, -3.14, 0) * CFrame.new(0, 0, 0),
		Transparency = 1,
		Tween = TweenInfo.new(1.6 * duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	})
	tweenModel(script.WindRings, {
		Scale = scale,
		Size = createVector(1.25, 1, 1.25),
		CFrame = cFrame * CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0),
		Transparency = 0.125,
		{
			ElectroRumbleAfterWind2 = {
				Transparency = 0
			}
		}
	}, {
		CFrame = CFrame.Angles(0, 3.14, 0),
		Transparency = 1,
		Tween = TweenInfo.new(0.8 * duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
		{
			ElectroRumbleAfterWind = {
				Size = createVector(0.75, 1.25, 0.75),
				CFrame = CFrame.Angles(0, -3.14, 0) * CFrame.new(0, 2.5 * scale, 0),
				Tween = TweenInfo.new(1 * duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			},
			ElectroRumbleAfterWind2 = {
				Size = createVector(1, 1.5, 1)
			}
		}
	})
end