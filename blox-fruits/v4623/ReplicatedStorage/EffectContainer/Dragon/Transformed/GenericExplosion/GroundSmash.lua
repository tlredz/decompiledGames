local Dust = require(game.ReplicatedStorage.Util.Particles.Dust)
local Rock = require(game.ReplicatedStorage.Util.Rock)
local Rock2 = require(game.ReplicatedStorage.Util.Particles.Rock)
game:GetService("TweenService")

local function func(data)
	local cFrame = data.CFrame or CFrame.new()
	local scale = data.Scale or 1
	local duration = data.Duration or 1
	local magnitude = (workspace.CurrentCamera.CFrame.p - cFrame.p).Magnitude

	if 100 + scale * 5 < magnitude then
		return
	end

	local arc = Dust.new("Arc", {
		Drag = 10,
		Distance = scale * 3,
		SpeedInfluence = { 0.75, 1 },
		LifetimeInfluence = { 0.7, 1.1 },
		Size = NumberSequence.new(1, 0.7),
		Scale = scale,
		Acceleration = cFrame.UpVector * 10,
		Lifetime = duration,
		SpreadAngle = Vector2.new(180, 360),
		CFrame = cFrame
	})
	local arc2 = Rock2.new("Arc", {
		Drag = 10,
		Distance = 3 * scale,
		SpeedInfluence = { 0.75, 1 },
		LifetimeInfluence = { 0.75, 1.25 },
		Scale = scale * 0.09,
		HeightInfluence = { scale * 1.5, -scale },
		Lifetime = duration * 0.6,
		SpreadAngle = Vector2.new(0, 180),
		CFrame = cFrame
	})
	arc:Emit()
	arc2:Emit()
	local v = math.clamp(scale * 0.1, 4, 10)
	local grounds = {}

	for _ = 1, v do
		table.insert(grounds, Rock.new("Ground", {
			Scale = { scale * 0.25, scale * 0.4 },
			FadeIn = 0.2,
			FadeOut = 0.2,
			Lifetime = { duration, duration * 2 }
		}))
	end

	for k, v2 in pairs(grounds) do
		local v3 = 6.283185307179586 * (k / v)
		v2:Spawn(cFrame * CFrame.Angles(0, v3, 0) * CFrame.new(0, 0, -scale / 6))
	end

	for _, v2 in pairs(grounds) do
		v2:TweenShift(v2.CFrame.LookVector * scale / 3.5 * Random.new():NextNumber(1, 1.25), duration * 0.5)
	end

	for i = 1, 3 do
		local flying = Rock.new("Flying", {
			Scale = { scale * 0.15, scale * 0.3 },
			FadeIn = 0.1,
			FadeOut = 0.1,
			Lifetime = { duration * 0.5, duration * 1 },
			Unattached = true
		})
		flying:Spawn(cFrame)
		flying:Eject({
			RotVelocity = Vector3.new(
				math.random() * 2 * 3.141592653589793,
				math.random() * 2 * 3.141592653589793,
				math.random() * 2 * 3.141592653589793
			) * 2,
			Velocity = math.clamp(scale * 6 / 70, 0, 2.25) * (cFrame.UpVector.Unit * math.random(70, 110) + (cFrame * CFrame.Angles(
				0,
				i / 6 * 3.141592653589793 * 2 + 1.5707963267948966 * math.random(),
				0
			)).LookVector * math.random(20, 45))
		})
	end
end

return func