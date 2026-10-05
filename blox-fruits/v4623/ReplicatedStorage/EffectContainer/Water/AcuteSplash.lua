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

	local clone = script.BlobSplash:Clone()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Util.Sound:Play("Other.WaterSplash", cFrame.p, 4 * scale, 1.25 / (duration * 0.75))
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
		Size = createVector(0, 2, 0),
		CFrame = cFrame * CFrame.Angles(0, random:NextNumber(-3.141592653589793, 3.141592653589793), 0),
		Transparency = 0.25
	}, {
		Size = createVector(1.25, 0.75, 1.25),
		CFrame = CFrame.Angles(0, 3.14, 0),
		Transparency = 1,
		Tween = TweenInfo.new(0.75 * duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
	})
end