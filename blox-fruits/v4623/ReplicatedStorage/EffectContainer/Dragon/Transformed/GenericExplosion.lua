local createVector = vector.create
local v = {}

local function ScaleParticle(state, p)
	if not v[state] then
		v[state] = { state.Size.Keypoints, state.Speed }
	end

	local numberSequenceKeypoints = {}

	for _, v2 in next, v[state][1], nil do
		local v3 = v2.Value * p
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(v2.Time, v3, v3 < v2.Envelope and v3 or v2.Envelope)
		)
	end

	state.Speed = NumberRange.new(v[state][2].Min * p, v[state][2].Max * p)
	return NumberSequence.new(numberSequenceKeypoints)
end

local function CalculateBrightness(data)
	return (math.sqrt(data.R ^ 2 * 0.241 + data.G ^ 2 * 0.691 + data.B ^ 2 * 0.068))
end

game:GetService("TweenService")
game:GetService("RunService")
require(game.ReplicatedStorage.Util.Tween)
local Effect = require(game.ReplicatedStorage.Effect)
local _ = workspace._WorldOrigin
local SpikyFlare = require(game.ReplicatedStorage.Util.Particles.SpikyFlare)
local Flames = require(game.ReplicatedStorage.Util.Particles.Flames)
local Smoke = require(game.ReplicatedStorage.Util.Particles.Smoke)
require(game.ReplicatedStorage.Util.Rock)
require(game.ReplicatedStorage.Util.Particles.Rock)
require(game.ReplicatedStorage.Util.Particles.Dust)
local GroundSmash = require(script.GroundSmash)
local Shockwave = require(script.Parent.Shockwave)
local FX = require(game.ReplicatedStorage.FX)
local _ = FX:WaitForChild("Dragon").FX
local _ = FX:WaitForChild("Dragon").Assets.Shockwave
local Sound = require(game.ReplicatedStorage.Util.Sound)
local currentCamera = workspace.CurrentCamera
return function(data)
	local cFrame = data.CFrame or CFrame.new()
	local color = data.Color or { Color3.new(1, 0, 0), Color3.new(1, 0.5, 0) }
	local radius = data.Radius or 10
	local segments = data.Segments or 10
	local fadeIn = data.FadeIn or 0.5
	local fadeOut = data.FadeOut or 0.5
	local lifetime = data.Lifetime or 1
	local scale = 6.283185307179586 * (1 / segments) * radius
	local magnitude = (currentCamera.CFrame.p - cFrame.p).Magnitude

	if scale * 5 + radius * 10 < magnitude then
		return
	end

	local v3 = Sound:Play("Dragon.GroundExplosion", cFrame.p, radius * 5, 1 * Random.new():NextNumber(1, 1.5))
	local p = currentCamera.CFrame.p
	local v4 = 1 - (cFrame.p - p).Magnitude / (15 * scale)

	if v4 > 0 then
		Effect.new("ShakeCam"):replicate({
			5 * v4,
			10 * v4,
			0,
			2.25 * fadeIn,
			createVector(0.3, 0.3, 0.3),
			createVector(1, 1, 4)
		})
	end

	local attachment = Instance.new("Attachment")
	attachment.CFrame = cFrame * CFrame.new(0, radius / 4, 0)
	attachment.Parent = workspace.Terrain
	local new = Flames.new
	local v6 = {
		Sustain = true,
		Rate = 360,
		Drag = 10,
		Distance = 2 * radius,
		Scale = scale,
		LightEmission = 0,
		Lifetime = 0,
		LifetimeInfluence = 0,
		Acceleration = 0,
		SpreadAngle = 0,
		CFrame = 0
	}
	local v7 = color[2]
	v6.LightEmission = 2 * math.sqrt(v7.R ^ 2 * 0.241 + v7.G ^ 2 * 0.691 + v7.B ^ 2 * 0.068)
	v6.Lifetime = lifetime
	v6.LifetimeInfluence = { 0.75, 1.25 }
	v6.Acceleration = cFrame.UpVector * 1 * radius
	v6.SpreadAngle = Vector2.new(0, 180)
	v6.CFrame = cFrame
	local arc = new("Arc", v6)
	arc:SetColor({ color[2], color[2] })
	Shockwave({
		CFrame = cFrame,
		Offset = CFrame.new(0, scale * radius * 0.1, 0),
		Size = createVector(0.55, 1.25, 0.55),
		Scale = scale * radius * 0.95 / 2,
		Color = { color[2], Color3.new(1, 1, 1) },
		Duration = lifetime
	})
	Shockwave({
		CFrame = cFrame,
		Offset = CFrame.new(0, scale * radius * 0.1, 0),
		Size = createVector(0.65, 0.25, 0.65),
		Scale = scale * radius * 1.125 / 2,
		Color = { color[1], Color3.new(1, 1, 1) },
		Duration = lifetime * 0.75
	})

	if data.Debris then
		coroutine.resume(coroutine.create(function()
			GroundSmash({
				CFrame = cFrame,
				Scale = radius * 1.5,
				Duration = lifetime * 2
			})
		end))
	end

	if data.Smoke then
		for i = 1, 1 do
			local _ = 6.283185307179586 * i / 1
			Smoke.new({
				Smoke = true,
				InnerColor = color[1],
				OuterColor = color[2],
				CFrame = cFrame,
				Scale = radius * 1.75 * Random.new():NextNumber(1.25, 1.75),
				Duration = { 2.25 * (fadeIn + fadeOut), (fadeIn + fadeOut) * 3 }
			})
		end
	end

	arc:Emit()

	for i = 1, segments do
		local v8 = 6.283185307179586 * (i / segments)
		SpikyFlare.new({
			InnerColor = color[1],
			OuterColor = color[2],
			AngleInfluence = { Vector3.new(), createVector(-1.2083049, 0, 0) },
			PulseSpeed = 1 + Random.new():NextNumber(0.5, 1),
			FadeIn = fadeIn,
			FadeOut = fadeOut,
			Lifetime = lifetime,
			CFrame = cFrame * CFrame.Angles(0, v8, 0) * CFrame.new(0, 0, -radius * 0.75),
			Scale = { scale * 1.5, radius * 3 }
		})
	end

	wait(fadeIn * 0.75 + lifetime)

	for _, v8 in next, {}, nil do
		v8.Enabled = false
	end

	arc:Destroy()
	wait(fadeOut + fadeIn * 0.25)
	Sound:FadeOut(v3, 0.5)
	attachment:Destroy()
end