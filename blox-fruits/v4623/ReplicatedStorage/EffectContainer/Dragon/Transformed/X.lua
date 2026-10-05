local createVector = vector.create

local function alignCF(data, p, p2)
	local p3 = data.p
	local unit = data.LookVector:Cross(p).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(p).Unit.Unit

	if not p2 then
		return CFrame.fromMatrix(p3, unit2, p, unit3)
	end

	local clone = workspace.IDK:Clone()
	clone.Color = Color3.new(0, 1, 0)
	local clone2 = clone:Clone()
	clone2.Color = Color3.new(1, 1, 0)
	local clone3 = clone:Clone()
	clone3.Color = Color3.new(1, 0, 0)
	clone.CFrame = CFrame.new(p3, p3 + unit2)
	clone2.CFrame = CFrame.new(p3, p3 + p)
	clone3.CFrame = CFrame.new(p3, p3 + unit3)
	local _WorldOrigin = workspace._WorldOrigin
	local _WorldOrigin2 = workspace._WorldOrigin
	local _WorldOrigin3 = workspace._WorldOrigin
	clone.Parent = _WorldOrigin
	clone2.Parent = _WorldOrigin2
	clone3.Parent = _WorldOrigin3
	return CFrame.fromMatrix(p3, unit2, p, unit3)
end

local RunService = game:GetService("RunService")
local map = workspace:WaitForChild("Map")
local Effect = require(game.ReplicatedStorage.Effect)
local RayCastWhitelist = require(game.ReplicatedStorage.Util.RayCastWhitelist)
local SpikyFlare = require(game.ReplicatedStorage.Util.Particles.SpikyFlare)
local Rock = require(game.ReplicatedStorage.Util.Particles.Rock)
local Dust = require(game.ReplicatedStorage.Util.Particles.Dust)
local Rock2 = require(game.ReplicatedStorage.Util.Rock)
require(game.ReplicatedStorage.Util.Particles.Flames)
local Projectile = require(script.Projectile)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local currentCamera = workspace.CurrentCamera
return function(data)
	local part = data.Part
	local scale = data.Scale or 3
	local distance = scale * 4
	local hitboxSize = data.HitboxSize or createVector(0.5, 2, 1)
	local renderFidelity = 500 + scale * 50
	local v3 = Projectile.new({
		Scale = 2 * scale,
		HitboxSize = hitboxSize,
		CFrame = part.CFrame * CFrame.Angles(0, 3.141592653589793, 0),
		Color = { Color3.new(1, 0.3333333333333333, 0), Color3.new(0.6666666666666666, 0, 0) },
		FadeIn = 0.1,
		FadeOut = 0.1
	})
	Effect.new("Dragon.Transformed.GroundTrail"):replicate({
		RenderFidelity = renderFidelity,
		HitboxSize = hitboxSize,
		Anchor = part,
		FadeIn = 0.4,
		Lifetime = 0.5,
		FadeOut = 0.5,
		Width = scale * 0.4,
		Color = Color3.new(1, 0.5, 0)
	})
	local trail = Dust.new("Trail", {
		EmitterSize = createVector(1, 1, 1) * scale,
		Drag = 2.5,
		Distance = distance * 2.5,
		Size = NumberSequence.new(0.25, 1),
		Scale = scale * 1.5,
		Lifetime = 1,
		SpreadAngle = Vector2.new(45, 45),
		Anchor = part
	})
	local trail2 = Rock.new("Trail", {
		EmitterSize = createVector(1, 0, 1) * scale / 2,
		Rate = 25,
		Drag = 5,
		Distance = distance,
		Scale = scale / 4,
		Lifetime = 1,
		SpreadAngle = Vector2.new(15, 30),
		SpeedInfluence = { 0.5, 1.25 },
		HeightInfluence = { distance, -distance / 2 },
		Anchor = part
	})
	Sound:Play("Dragon.Slash", part.CFrame.p, scale * 8, 1.75)
	Sound:Play("Explosions.ShortExplosion3", part.CFrame.p, scale * 8, 2)
	local position = part.Position
	local v4 = position
	local v5 = nil

	while true do
		local now = tick()
		v5 = v5 or now

		if now - v5 > 10 or not part.Parent then
			break
		end

		local position2 = part.Position
		local cFrame = part.CFrame
		local magnitude = (v4 - position2).Magnitude

		if (currentCamera.CFrame.p - part.CFrame.p).Magnitude < renderFidelity then
			local v6, v7, v8 = RayCastWhitelist(position2, -cFrame.UpVector * scale * hitboxSize.Y * 1.05, { map })

			if v6 then
				if magnitude > 5 then
					trail:Emit()
					trail2:Emit()
				end

				local cframe = CFrame.new(Vector3.new(), part.CFrame.LookVector)
				local v9 = v8 or createVector(0, 1, 0)
				local p = cframe.p
				local unit = cframe.LookVector:Cross(v9).Unit
				local unit2 = (unit.Magnitude > 0.001 and unit or cframe.RightVector).Unit
				local unit3 = unit2:Cross(v9).Unit.Unit
				local v10 = CFrame.fromMatrix(p, unit2, v9, unit3) + v7
				local magnitude2 = (position2 - position).Magnitude
				local magnitude3 = (position2 - v4).Magnitude

				if scale * 3 < magnitude2 then
					for i = -1, 1, 2 do
						local v11 = v10 * Vector3.new(i * scale * Random.new():NextNumber(0.75, 1.25), 0, 0) - v10.p

						if Random.new():NextNumber(0, 1) > 0.25 then
							local ground = Rock2.new("Ground", {
								Scale = { scale / 2 * 2, scale * 2 },
								FadeIn = 0.5,
								FadeOut = 0.5,
								Lifetime = { 0.6, 0.75 }
							})
							ground:Spawn(v10)
							ground:TweenShift(v11, 0.5)
						end

						if not Random.new():NextNumber(0, 1) then
							continue
						end

						local flying = Rock2.new("Flying", {
							Scale = { scale / 3, scale / 2 },
							FadeIn = 0.25,
							FadeOut = 0.25,
							Lifetime = { 0.25, 0.5 }
						})
						flying:Spawn(v10 * CFrame.new(i * scale, 0, 0))
						flying:Eject({
							RotVelocity = Vector3.new(
								math.random() * 2 * 3.141592653589793,
								math.random() * 2 * 3.141592653589793,
								math.random() * 2 * 3.141592653589793
							) * 2,
							Velocity = (v10 * CFrame.Angles(0, 0, -i * 3.141592653589793 / 6)).UpVector * createVector(
								1,
								0.1,
								0
							) * Random.new():NextNumber(10, 30) * (scale / 2) + createVector(0, 1, 0) * Random.new():NextNumber(
								30,
								60
							) * math.clamp(scale / 2, 1, 5)
						})
					end

					position = position2
				end

				if scale * 4 < magnitude3 then
					for i = -1, 1, 2 do
						SpikyFlare.new({
							InnerColor = Color3.new(0.6666666666666666, 0, 0),
							OuterColor = Color3.new(1, 0.3333333333333333, 0),
							AngleInfluence = { Vector3.new(), (Vector3.new(0, 0, -i * 3.141592653589793 / 5)) },
							PulseSpeed = 1 + Random.new():NextNumber(0.5, 1),
							FadeIn = 0.25,
							FadeOut = 0.25,
							Lifetime = { 0.3, 0.6 },
							CFrame = v10 * CFrame.new(i * scale / 2, 0, 0) * CFrame.Angles(0.2617993877991494, 0, 0),
							Scale = { 4 * scale, scale * Random.new():NextNumber(3, 6) }
						})
						SpikyFlare.new({
							InnerColor = Color3.new(0.6666666666666666, 0, 0),
							OuterColor = Color3.new(1, 0.3333333333333333, 0),
							AngleInfluence = { Vector3.new(), (Vector3.new(0, 0, -i * 3.141592653589793 / 3)) },
							PulseSpeed = 1 + Random.new():NextNumber(0.5, 1),
							FadeIn = 0.25,
							FadeOut = 0.25,
							Lifetime = { 0.3, 0.6 },
							CFrame = v10 * CFrame.new(i * scale / 2, 0, 0) * CFrame.Angles(0.7853981633974483, 0, 0),
							Scale = { 2 * scale, scale * Random.new():NextNumber(3, 4) }
						})
					end

					v4 = position2
				end
			else
				trail:Stop()
				trail2:Stop()
			end
		else
			trail:Stop()
			trail2:Stop()
		end

		v3:SetCFrame(part.CFrame * CFrame.new(0, 0, scale))
		local _ = part.Position
		RunService.RenderStepped:Wait()
	end

	v3:Destroy()
	trail:Destroy()
	trail2:Destroy()
end