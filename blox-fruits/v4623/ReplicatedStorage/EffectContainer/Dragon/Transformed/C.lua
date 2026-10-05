local createVector = vector.create
local v = {}

local function ScaleParticle(clone, p)
	if not v[clone] then
		v[clone] = { clone.Size.Keypoints, clone.Speed }
	end

	local numberSequenceKeypoints = {}

	for _, v2 in next, v[clone][1], nil do
		local v3 = v2.Value * p
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(v2.Time, v3, v3 < v2.Envelope and v3 or v2.Envelope)
		)
	end

	clone.Speed = NumberRange.new(v[clone][2].Min * p, v[clone][2].Max * p)
	return NumberSequence.new(numberSequenceKeypoints)
end

local function CalculateBrightness(data)
	return (math.sqrt(data.R ^ 2 * 0.241 + data.G ^ 2 * 0.691 + data.B ^ 2 * 0.068))
end

local _WorldOrigin = workspace._WorldOrigin
local Effect = require(game.ReplicatedStorage.Effect)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local dragonTransformedShockwave = Effect.new("Dragon.Transformed.Shockwave")
local dragonTransformedElectricityAura = Effect.new("Dragon.Transformed.ElectricityAura")
local Orb = require(game.ReplicatedStorage.Util.Particles.Orb)
local FX = require(game.ReplicatedStorage.FX)
local FX2 = FX:WaitForChild("Dragon").FX
local ring_Exhale = FX:WaitForChild("Dragon").FX.Ring_Exhale
local currentCamera = workspace.CurrentCamera
return function(data)
	local v2 = {
		CFrame = data.CFrame or CFrame.new()
	}
	local radius = data.Radius or 10

	if (v2.CFrame.p - currentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	local checkDestroy = data.CheckDestroy or {
		Parent = _WorldOrigin
	}
	local fadeIn = data.FadeIn or 1
	local fadeOut = data.FadeOut or fadeIn
	local lifetime = data.Lifetime or 1
	local color = data.Color or { Color3.new(0.6862745098039216, 0, 0), Color3.new(1, 0.3333333333333333, 0) }
	local attachment = Instance.new("Attachment")
	attachment.CFrame = v2.CFrame
	attachment.Parent = workspace.Terrain
	local clone = FX2.Twinkle:Clone()
	clone.Size = ScaleParticle(clone, radius * 0.5)
	clone.Parent = attachment
	local clone2 = ring_Exhale:Clone()
	clone2.Color = ColorSequence.new(color[1], color[2])
	clone2.Lifetime = NumberRange.new(fadeIn * 0.5, fadeIn * 0.5)
	clone2.Size = ScaleParticle(clone2, radius)
	clone2.Parent = attachment
	local clone3 = FX2.Blobs_Inhale:Clone()
	clone3.Rate += math.clamp(radius ^ 0.65, 0, 360)
	clone3.Size = ScaleParticle(clone3, radius * 0.5)
	clone3.Color = ColorSequence.new(color[2], color[1])
	clone3.Lifetime = NumberRange.new(fadeIn * 0.5, fadeIn * 0.75)
	clone3.LightEmission = 0.75
	local clone4 = FX2.Ring_Inhale:Clone()
	clone4.Lifetime = NumberRange.new(fadeIn)
	clone4.Size = ScaleParticle(clone4, radius * 0.5)
	clone4.LightEmission = 0.75
	clone4.Color = ColorSequence.new(color[1], color[2])
	local clone5 = FX2.Glow:Clone()
	clone5.Size = ScaleParticle(clone5, radius * 2)
	clone5.Color = clone4.Color
	clone5.Lifetime = clone4.Lifetime
	clone3.Parent = attachment
	clone4.Parent = attachment
	clone5.Parent = attachment
	clone3.Enabled = true
	clone4:Emit(1)
	clone5:Emit(1)
	dragonTransformedElectricityAura:replicate({
		CFrame = v2.CFrame,
		Color = ColorSequence.new(color[1], color[2]),
		Radius = { radius, 0 },
		Duration = fadeIn * 0.3,
		Lifetime = fadeIn,
		Transparency = { 0.25, 1 },
		FrameSpawn = 8
	})
	local v3 = Sound:Play("Dragon.Snarl", v2.CFrame.p, radius * 15)
	Sound:Play("Dragon.Implode", v2.CFrame.p, radius * 10, 0.75 / (fadeIn * 0.5 + fadeIn * 0.7))
	local v4 = Sound:Play("Dragon.Zap_Looped", v2.CFrame.p, radius * 10, 0.75)
	wait(fadeIn * 0.5)
	clone3.Enabled = false
	Sound:FadeOut(v4, 0.5)
	wait(fadeIn * 0.7)
	Sound:FadeOut(v3, 0.75)
	local p = currentCamera.CFrame.p
	local v5 = 1 - (v2.CFrame.p - p).Magnitude / (10 * radius)

	if v5 > 0 then
		Effect.new("ShakeCam"):replicate({
			5 * v5,
			10 * v5,
			0,
			3 * fadeIn,
			createVector(0.25, 0.25, 0.25),
			createVector(4, 1, 1)
		})
	end

	Sound:Play("Dragon.Twinkle", v2.CFrame.p, 10 * radius)
	clone:Emit(1)
	wait(fadeIn * 0.2)
	clone2:Emit(1)
	local v6 = Sound:Play("Dragon.Explosion", v2.CFrame.p, radius * 15)
	local v7 = Sound:Play("Dragon.AuraLoop", v2.CFrame.p, radius * 15, 1)
	dragonTransformedShockwave:replicate({
		CFrame = v2.CFrame,
		Offset = CFrame.new(0, radius * 0.1, 0),
		Size = createVector(0.9, 0.25, 0.9),
		Scale = radius * 4,
		Color = { color[1], Color3.new(1, 1, 1) },
		Duration = fadeIn * 0.7
	})
	Orb.new({
		CheckDestroy = checkDestroy,
		CFrame = v2.CFrame,
		Scale = radius,
		Color = color,
		FadeIn = fadeIn * 0.5,
		Lifetime = lifetime,
		FadeOut = fadeOut,
		OnDestroy = function()
			Sound:FadeOut(v7, 0.5)
			Sound:FadeOut(v6, 0.5)
		end,
		Callback = function()
			attachment:Destroy()
		end
	})
end