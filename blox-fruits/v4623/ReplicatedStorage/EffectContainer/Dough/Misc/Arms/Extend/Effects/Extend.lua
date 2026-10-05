local createVector = vector.create
local currentCamera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local dough = FX:WaitForChild("Dough")
local origin = dough.Misc.Arms.Extend.Effects.Extend.Origin
local cframe = CFrame.new(0, 999999, 0)
local v = {}

local function Return(p)
	v[p] = task.delay(5, function()
		p.Parent = nil
	end)
	p.CFrame = cframe
end

local function Grab()
	local v2, v3 = next(v)

	if not v2 then
		return origin:Clone()
	end

	task.cancel(v3)
	v[v2] = nil
	return v2
end

local misc = Util.Misc
local tweenModel = Util.TweenModel
local rock2 = Util.Rock2

-- equivalent calls inferred from this helper; original call sites unknown
local function neofy(data, p)
	local v2 = Vector3.new(data.R, data.G, data.B) * (p and 1 + (p - 1) / 10 or 1)
	return Color3.new(math.min(1.96, v2.X), math.min(1.96, v2.Y), (math.min(1.96, v2.Z)))
end

local memoize = Util.Memoize(function(instance)
	local emitters = {}

	for _, emitter in pairs(instance:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			table.insert(emitters, emitter)
		end
	end

	return emitters
end)
local memoize2 = Util.Memoize(function(data)
	return {
		Size = data.Size.Keypoints,
		Speed = data.Speed,
		Acceleration = data.Acceleration,
		Lifetime = data.Lifetime,
		Drag = data.Drag,
		Transparency = data.Transparency
	}
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function round(p, p2)
	local v2, v3 = math.modf(p / p2)
	return (tonumber(string.format("%.3f", p2 * (v2 + (v3 > 0.5 and 1 or 0)))))
end

local function playParticles(p, p2, p3, fastMode, ...)
	local v2 = 0

	for _, v3 in pairs({ ... }) do
		for _, v4 in pairs(memoize(v3)) do
			v2 = math.max(v2, v4.Lifetime.Max)
			local emit = v4:GetAttribute("Emit") or v4:GetAttribute("EmitCount")
			local emitDelay = v4:GetAttribute("EmitDelay")
			local enable = v4:GetAttribute("Enable")
			local v5 = math.min(1, p3)
			misc.ScaleParticle(v4, p2, memoize2(v4))

			if v4:GetAttribute("LengthInfluenced") then
				v4.Rate *= v5
				v4.Speed = NumberRange.new(v4.Speed.Min * p3, v4.Speed.Max * p3)
				v4.Lifetime = NumberRange.new(v4.Lifetime.Min * v5, v4.Lifetime.Max * v5)
				v4.Acceleration *= p3
			end

			if p then
				v4.Color = ColorSequence.new(p)
			end

			v4.Enabled = false
			local v7 = v4

			local function fn()
				if emit then
					v7:Emit(emit * v5 * (fastMode and 0.25 or 1))
				end

				if enable then
					v7.Enabled = true

					if typeof(enable) == "number" then
						task.delay(enable * v5, function()
							v7.Enabled = false
						end)
					end
				end
			end

			if emitDelay and emitDelay > 0 then
				task.delay(emitDelay * v5, fn)
			else
				fn()
			end
		end
	end

	return v2
end

local now = 0
return function(data)
	local random = Random.new()
	local cFrame = data.CFrame
	local v2 = round(data.Width, 0.01) -- equivalent call inferred; original call site unknown
	local v3 = round(data.Length, 0.01) -- equivalent call inferred; original call site unknown
	local color = data.Color or data.Buso

	if typeof(color) ~= "Color3" then
		color = nil
	end

	local v4 = round(data.Duration, 0.01) -- equivalent call inferred; original call site unknown
	local v5 = math.min(2, (math.max(0.5, v3 / 107)))
	local v6 = math.min(1, v5)
	local v7 = v3 / 107
	local v8 = 200 + 4 * v2 * 3
	local magnitude = (currentCamera.CFrame.p - cFrame.p).Magnitude
	local v9 = {
		["3"] = 1.633,
		["2"] = 1.633,
		[""] = 1.766
	}

	if v8 < magnitude then
		if v8 * 2 < magnitude then
			return
		end
	else
		local v10 = magnitude / v8
		Effect.new("ShakeCam"):replicate({
			PosInfluence = createVector(1, 1, 1),
			RotInfluence = createVector(1, 0, 1),
			Magnitude = 5,
			Roughness = 4,
			FadeIn = 0,
			FadeOut = v4 / 2,
			Power = 1 - v10 * 0.5
		})
	end

	local v10 = data.Buso and "3" or math.random(2) == 1 and "2" or ""

	if not data.LimitSound or tick() - now > 0.1 then
		Util.Sound:Play("Dough.DoughPunch" .. v10, cFrame, nil, v9[v10] / (v4 * 2))
		now = tick()
	end

	local clone, v11 = next(v)

	if clone then
		task.cancel(v11)
		v[clone] = nil
	else
		clone = origin:Clone()
	end

	clone.Size = createVector(5, 5, 0) * v2
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local v12 = 0

	for _, v13 in pairs(memoize(clone)) do
		if not v13 then
			continue
		end

		v12 = math.max(v12, v13.Lifetime.Max)
		v13.Enabled = false
		local v14 = memoize2(v13)
		misc.ScaleParticle(v13, v2, v14)
		local v15 = v14.Speed.Min / v14.Speed.Max
		local v16 = math.min(v14.Lifetime.Max, v4)
		local velocity = misc.CalculateVelocity(v3, v16, v14.Drag)
		local enable = v13:GetAttribute("Enable")
		local emit = v13:GetAttribute("Emit") or v13:GetAttribute("EmitCount")
		v13.Transparency = Util.Misc.ScaleKeypoints(v14.Transparency.Keypoints, 2 - 107 / v3)
		v13.Lifetime = NumberRange.new(v16 * v15, v16)
		v13.Speed = NumberRange.new(velocity * v15, velocity)

		if emit then
			v13:Emit(emit * v5 * (data.FastMode and 0.25 or 1))

			if v4 < (not enable and 1e999 or enable + v16 or 1e999) / 2 then
				continue
			end
		end

		if not enable then
			continue
		end

		v13.Enabled = true

		if typeof(enable) ~= "number" then
			continue
		end

		local v17 = math.min(v4, enable)
		local v18 = v13
		task.delay(v17 * v5, function()
			v18.Enabled = false
			v18:Clear()
		end)
	end

	local v13 = math.max(v12, playParticles(nil, v2, v5, data.FastMode, clone.Attachment))
	local color2 = neofy(color or Color3.new(1, 1, 1)) -- equivalent call inferred; original call site unknown
	local color3 = neofy((Color3.new(1, 1, 1))) -- equivalent call inferred; original call site unknown

	if not data.FastMode then
		if v5 < 1.125 then
			for i = 1, 3 do
				tweenModel(dough.Models.DualWind, {
					Color = color3,
					CFrame = cFrame * CFrame.new(0, 0, -(i - 1) * v2 * 4 - 5) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						random:NextNumber(-3.141592653589793, 3.141592653589793),
						0
					),
					Size = createVector(0.4, 2, 0.4),
					Scale = 4 * v2 * 0.75 * (4.5 - i) / 4,
					Transparency = 0.75
				}, {
					Tween = TweenInfo.new(v4 * 0.5 + (4 - i) * 0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					CFrame = CFrame.new(0, 0, -2.5) * CFrame.Angles(0, (i / 3 + 1) * 1.57, 0),
					Size = Vector3.new(0.5, (i - 1) * 0.3 + 0.1, 0.5),
					Scale = 4 * v2 * 1.5 * (3 - (i - 1)) / 3,
					Transparency = 1
				})
			end
		end

		tweenModel(dough.Models.WindRing, {
			Color = color3,
			CFrame = cFrame * CFrame.new(0, 0, v6 * -5) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				0
			),
			Size = createVector(2, 0, 2),
			Scale = 4 * v2 / 4,
			Transparency = 0.75
		}, {
			Tween = TweenInfo.new(v4 * 1.35 * v5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
			CFrame = CFrame.new(0, v6 * 10, 0) * CFrame.Angles(0, 3.14, 0),
			Size = Vector3.new(0.4, v6 * 5, 0.4),
			Scale = 4 * v2 / 2,
			Transparency = 1
		})
		tweenModel(dough.Models.WindRing, {
			Color = color2,
			CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				0
			),
			Size = createVector(2, 0, 2),
			Scale = 4 * v2 / 4,
			Transparency = 0.75
		}, {
			Tween = TweenInfo.new(v4 * v5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			CFrame = CFrame.new(0, v6 * -30, 0) * CFrame.Angles(0, -3.14, 0),
			Size = Vector3.new(0.5, v6 * 2, 0.5),
			Scale = 4 * v2 / 2,
			Transparency = 1
		})
		tweenModel(dough.Models.WindRings, {
			Color = color2,
			CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				0
			),
			Size = Vector3.new(3, v6 * 2.5, 3),
			Scale = 4 * v2 / 4
		}, {
			Tween = TweenInfo.new(v4 * 1.125 * v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			Color = color3,
			CFrame = CFrame.new(0, v6 * -50, 0) * CFrame.Angles(0, -3.14, 0),
			Size = Vector3.new(0.75, v6 * 5, 0.75),
			Scale = 4 * v2 / 2,
			Transparency = 1
		})
		tweenModel(dough.Models.WindRings, {
			Color = color2,
			CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				0
			),
			Size = Vector3.new(4, v6 * 1, 4),
			Scale = 4 * v2 / 4
		}, {
			Tween = TweenInfo.new(v4 * v5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			Color = color3,
			CFrame = CFrame.new(0, v6 * -50, 0) * CFrame.Angles(0, 3.14, 0),
			Size = Vector3.new(1, v6 * 4, 1),
			Scale = 4 * v2 / 2,
			Transparency = 1
		})
		local spike = dough.Models.Spike
		local v17 = {
			CFrame = cFrame * CFrame.new(0, 0, v5 * -30) * CFrame.Angles(
				0,
				0,
				random:NextNumber(-3.141592653589793, 3.141592653589793)
			),
			Size = Vector3.new(1.25, 1.25, v6 * 2),
			Scale = 4 * v2 * 1,
			Transparency = 0.25
		}

		if math.random(1, 2) == 1 then
			color3 = Color3.new() or color3
		end

		v17[1] = {
	Spoke = {
		Color = color3
	},
	Spoke2 = {
		Color = math.random(1, 2) == 1 and color or Color3.new()
	},
	Spoke3 = {
		Color = math.random(1, 2) == 1 and color or Color3.new()
	}
}
		tweenModel(spike, v17, {
			Tween = TweenInfo.new(v4 * 0.95 * v5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
			Scale = 4 * v2,
			Transparency = 1,
			Size = Vector3.new(1.25, 1.25, v6 * 1.5),
			{
				Spoke = {
					CFrame = CFrame.new(0, 0, v5 * 45) * CFrame.new(4 * v2 / 8, -4 * v2 / 2, 0)
				},
				Spoke2 = {
					CFrame = CFrame.new(0, 0, v5 * 45) * CFrame.new(-4 * v2 / 4, 4 * v2 / 2, 0)
				},
				Spoke3 = {
					CFrame = CFrame.new(0, 0, v5 * 45) * CFrame.new(4 * v2 / 2, 0, 0)
				}
			}
		})
		local rayCastWhitelist, v20, v21 = Util.RayCastWhitelist(
			cFrame * createVector(0, 0, 0),
			-cFrame.UpVector * 4 * v2 * 2,
			{ workspace:FindFirstChild("Map") }
		)

		if rayCastWhitelist then
			local alignCFrame = misc.AlignCFrame(CFrame.new(Vector3.new(), cFrame.LookVector) + v20, v21)
			local v22 = 4 * v2
			local v23 = math.floor(v3 / v22)
			task.delay(0, function()
				for i = 0, v23 do
					local v24 = v22 * i

					for i2 = -1, 1, 2 do
						if math.random(2) == 1 then
							continue
						end

						local v25 = rock2.new({
							Type = "Ground",
							FadeOut = { v4 / 2, v4 },
							FadeIn = { v4 / 2, v4 },
							Lifetime = { v4 / 2, v4 * 2 },
							Size = Vector3.new(
								random:NextNumber(0.5, 1.5),
								random:NextNumber(0.5, 1.5),
								random:NextNumber(0.5, 1.5)
							),
							Scale = { v2 / 4 * 4, v2 / 2 * 4 }
						})

						if random:NextInteger(1, 8) % 4 == 0 then
							v25.Type = "Flying"
							v25:Spawn(cFrame * CFrame.new(0, -4 * v2 * 0.5, 0) * CFrame.new(0, 0, -v24))
							v25:Eject({
								Velocity = Util.Misc.Physics.Velocity(
									Vector3.new(),
									(i2 * cFrame.RightVector * random:NextNumber(1, 3) + cFrame.UpVector * random:NextNumber(
										0.5,
										2
									) + cFrame.LookVector * random:NextNumber(1.5, 3)) * random:NextNumber(
										v2 * 2,
										v2 * 4
									) * 4,
									Vector3.new(0, -workspace.Gravity * 0.35, 0),
									0.5 + random:NextNumber(0, 1)
								),
								AngularVelocity = Vector3.new(
									random:NextNumber(-1, 1),
									random:NextNumber(-1, 1),
									random:NextNumber(-1, 1)
								) * 3.141592653589793 * (1 / v25.Scale)
							})
						else
							v25:Spawn(cFrame * CFrame.new(0, -4 * v2 * 0.5, 0) * CFrame.new(0, 0, -v24))
							v25:TweenShift(i2 * cFrame.RightVector * v2 * 4, v4 / 2)
						end
					end
				end
			end)
			clone.Dust.WorldCFrame = alignCFrame
			v13 = math.max(v13, playParticles(rayCastWhitelist.Color, v2, v7, data.FastMode, clone.Dust))
			local v24 = math.clamp(math.floor(4 * v7), 0, 4)

			if v7 < 0.07476635514018691 then
				return
			end

			for i = 1, v24 do
				if i > 1 then
					local v25, v26
					rayCastWhitelist, v25, v26 = Util.RayCastWhitelist(
						cFrame * Vector3.new(0, 0, (i - 1) * -25 * v5),
						-cFrame.UpVector * 4 * v2 * 2,
						{ workspace:FindFirstChild("Map") }
					)

					if rayCastWhitelist then
						alignCFrame = misc.AlignCFrame(CFrame.new(Vector3.new(), cFrame.LookVector) + v25, v26)
					end
				end

				if rayCastWhitelist then
					tweenModel(dough.Models.SidesShockwave, {
						CFrame = alignCFrame,
						Scale = 0,
						{
							Left = {
								CFrame = CFrame.new(-4 * v2, 0, 4 * v2)
							},
							Right = {
								CFrame = CFrame.new(4 * v2, 0, 4 * v2)
							}
						}
					}, {
						Tween = TweenInfo.new(v4 / v24 + v5 * 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						Scale = 4 * v2,
						Size = createVector(1, 1, 1),
						Transparency = 1,
						{
							Left = {
								CFrame = CFrame.new(-4 * v2 * 1.5, 0, -4 * v2 * 2 * v5) * CFrame.Angles(
									0,
									0,
									0.5235987755982988
								)
							},
							Right = {
								CFrame = CFrame.new(4 * v2 * 1.5, 0, -4 * v2 * 2 * v5) * CFrame.Angles(
									0,
									0,
									-0.5235987755982988
								)
							}
						}
					})
				end

				task.wait(v4 / (v24 + 2))
			end
		end
	end

	task.delay(v13, Return, clone)
end