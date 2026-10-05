local createVector = vector.create
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale
	local v = 250 + scale * 5

	if v < (currentCamera.CFrame.p - cFrame.p).Magnitude then
		return
	end

	local lifetime = data.Lifetime or data.Duration or 1
	local fadeIn = lifetime * 0.15
	local lifetime2 = lifetime * 0.5
	local fadeOut = lifetime * 0.25
	Util.Sound:Play("Dough.DoughGroundSmash", cFrame, nil, 2.5 / (lifetime * 2))
	Util.Sound:Play("Dough.DoughGroundWetHit", cFrame, nil, 1.267 / lifetime)
	task.delay(fadeIn + lifetime2, function()
		Util.Sound:Play("Dough.DoughWindSwipe", cFrame, nil, 1.9 / (fadeOut * 4))
	end)
	Effect.new("Dough.Explosions.Spikywave"):replicate({
		CFrame = cFrame * CFrame.new(0, 0, 0),
		FadeIn = fadeIn,
		Lifetime = lifetime2,
		FadeOut = fadeOut,
		Scale = scale * 1
	})
	Effect.new("Dough.Explosions.CrackedFloor"):replicate({
		CFrame = cFrame,
		Transparency = 0.5,
		FadeIn = (fadeIn + lifetime2) / 2,
		Lifetime = lifetime * 2,
		FadeOut = lifetime,
		Scale = scale * 5
	})
	local v5 = math.min(1, (currentCamera.CFrame.p - cFrame.p).Magnitude / (v / 4))

	if v5 > 0 then
		Effect.new("ShakeCam"):replicate({
			Preset = "Bump",
			Power = 1.25 - v5
		})
		Effect.new("ShakeCam"):replicate({
			Preset = "Bump2",
			Power = 1.25 - v5
		})
		Effect.new("ColorCorrection"):replicate({
			TintColor = Color3.new(1, 1, 1),
			Saturation = Util.Tween.point(-2, 0, v5),
			Brightness = Util.Tween.point(1, 0, v5),
			Contrast = Util.Tween.point(-5, 0, v5),
			FadeIn = fadeIn / 2,
			Lifetime = fadeIn / 2,
			FadeOut = lifetime2 / 2
		})
	end

	Effect.new("Dough.Misc.Hit.Floor"):replicate({
		CFrame = cFrame * CFrame.new(0, 0, 0),
		Duration = lifetime,
		Scale = 1.75 * scale
	})
	Effect.new("Dough.Misc.Debris.Radial"):replicate({
		CFrame = cFrame * CFrame.new(0, 1, 0),
		Scale = scale * 2 * 3,
		Mode = "X",
		Duration = {
			Rocks = 1.5 * (fadeIn + lifetime2) * 1.25,
			Dust = 1.5 * lifetime
		}
	})
	Effect.new("Dough.Misc.Debris.Radial"):replicate({
		CFrame = cFrame * CFrame.new(0, 0, 0),
		Scale = scale * 2 * 3,
		Mode = "Y",
		Duration = {
			Rocks = 1.5 * (fadeIn + lifetime2) * 1.5,
			Dust = 1.5 * lifetime * 1.25
		}
	})
	local random = Random.new()
	local v6 = math.max(scale, 20)

	for i = 1, v6 do
		local v7 = 6.283185307179586 * (i / v6) * random:NextNumber(0.95, 1.05)
		local rock = Util.Rock2.new({
			Scale = { scale / 8, scale / 5 },
			Size = Vector3.new(
				0.75 + random:NextNumber(0.25, 1.25),
				0.5 + random:NextNumber(0.25, 0.5),
				0.75 + random:NextNumber(0.25, 1.25)
			),
			Lifetime = { 1.125 * lifetime * 0.75, 1.125 * lifetime * 1.5 },
			FadeIn = { lifetime * 0.15, lifetime * 0.3 },
			FadeOut = { lifetime * 0.3, lifetime * 0.5 },
			AngleOffset = CFrame.Angles(0.3141592653589793 + 0.7853981633974483 * random:NextNumber(0, 1), 0, 0)
		})
		rock:Spawn(cFrame * CFrame.Angles(0, v7, 0) * CFrame.new(
			0,
			0,
			-scale / 8 - scale / 2 * random:NextNumber(0.3, 1.5)
		))

		if random:NextInteger(2, 8) % 2 == 0 then
			local lookVector = rock.CFrame.LookVector
			local v8 = scale / 2 * random:NextNumber(0.5, 1)
			local v9 = (fadeIn + lifetime2 / 2) * random:NextNumber(0.3, 1)
			rock:TweenShift(lookVector * v8, v9 * random:NextNumber(1, 2))
		else
			local v8 = fadeIn + lifetime2 + random:NextNumber(0, lifetime)
			local unit = ((rock.CFrame.LookVector * random:NextNumber(0.5, 1) * 2 + rock.CFrame.RightVector * random:NextNumber(
				-1,
				1
			) * 2 + rock.CFrame.UpVector * random:NextNumber(0.5, 1) * 1) / 3).Unit
			rock.Type = "Flying"
			rock:TweenShiftScale(-rock.Scale / 2, v8)
			rock:Eject({
				Velocity = Util.Misc.Physics.Velocity(
					Vector3.new(),
					unit * random:NextNumber(scale / 2, scale),
					Vector3.new(0, -workspace.Gravity * random:NextNumber(0.25, 1), 0),
					v8
				),
				AngularVelocity = Vector3.new(
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1)
				) * 2 * 3.141592653589793 * (1 / rock.Scale)
			})
		end

		task.delay(fadeIn + lifetime2 + fadeOut / 2, function()
			local magnitude = (rock.Part.Position - cFrame.p).Magnitude

			if scale * 1 < magnitude then
				return
			end

			local v9 = 0.5 + random:NextNumber(0, lifetime)
			local upVector = rock.CFrame.UpVector
			rock.Type = "Flying"
			rock:TweenShiftScale(-rock.Scale / 2, v9)
			rock:Eject({
				Velocity = Util.Misc.Physics.Velocity(
					Vector3.new(),
					upVector * random:NextNumber(scale / 2, scale / 1.5),
					Vector3.new(0, -workspace.Gravity * random:NextNumber(0.25, 1), 0),
					v9
				),
				AngularVelocity = Vector3.new(
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1)
				) * 2 * 3.141592653589793 * (1 / rock.Scale)
			})
		end)
	end

	task.delay(fadeIn + lifetime2 + fadeOut / 2, function()
		local v7 = math.min(1, (currentCamera.CFrame.p - cFrame.p).Magnitude / (v / 4))

		if v7 > 0 then
			Effect.new("ShakeCam"):replicate({
				Preset = "Bump2",
				Power = 1.25 - v7
			})
		end
	end)

	for i = 1, 3 do
		Effect.new("Dough.Shockwaves.2"):replicate({
			CFrame = cFrame * CFrame.new(0, scale * 0.1, 0),
			VectorOffset = cFrame.UpVector * (i * scale * 0.1),
			Lifetime = (fadeIn + lifetime2) / 2.5,
			Scale = 3 * scale * (i / 3 * 0.25 + 1.25),
			Speed = i % 2 == 0 and 1 or -1,
			Color = Color3.fromRGB(555, 555, 555)
		})
		Util.TweenModel(dough.X.Aerial.Explosion.ThinWind, {
			CFrame = cFrame * CFrame.new(0, scale * 0.1, 0),
			Scale = scale * 1 * (i / 3 * 0.75 + 1),
			Size = createVector(1, 1, 1),
			Transparency = 0.3
		}, {
			Tween = TweenInfo.new((fadeIn + lifetime2) / 2.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
			CFrame = CFrame.new(0, -scale * 0.1, 0),
			Transparency = 1,
			Size = createVector(1, 0.1, 1),
			Scale = scale * 2 * (i / 3 * 0.25 + 1.125)
		})
		task.wait((fadeIn + lifetime2) / 4)
	end
end