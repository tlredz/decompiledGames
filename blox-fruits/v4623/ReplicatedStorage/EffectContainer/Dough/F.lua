local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local rock2 = Util.Rock2
local Effect2 = require(ReplicatedStorage.EffectContainer.Dough.Util.Wheel.Effect)
local doughExplosionsDripScatter = Effect.new("Dough.Explosions.DripScatter")
local doughMiscDebrisTrail = Effect.new("Dough.Misc.Debris.Trail")
local doughMiscDebrisHeatMark = Effect.new("Dough.Misc.Debris.HeatMark")
local doughShockwaves2 = Effect.new("Dough.Shockwaves.2")
local part = Instance.new("Part")
part.CastShadow = false
part.Transparency = 1
part.TopSurface = 0
part.BottomSurface = 0
part.Anchored = true
part.CanCollide = false
part.Massless = false
part.CanTouch = false
part.CanQuery = false
part.Size = createVector(1, 1, 1)
part.CFrame = CFrame.identity

local function createAttachment()
	return part:Clone()
end

local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local attachment = Instance.new("Attachment")
local cframe = CFrame.new(0, 999999, 0)
local v = {}

local function Return(attachment2, instance)
	v[attachment2][instance] = task.delay(5, function()
		instance.Parent = nil
	end)

	if instance:IsA("Attachment") then
		instance.Parent = workspace.Terrain
	else
		instance.Parent = _WorldOrigin
	end

	if instance.ClassName == "Model" then
		instance:SetPrimaryPartCFrame(cframe)
	elseif instance:IsA("BasePart") or instance:IsA("Attachment") then
		instance.CFrame = cframe
	end
end

local function Grab(attachment2)
	v[attachment2] = v[attachment2] or {}
	local v2 = v[attachment2]
	local v3, v4 = next(v2)

	if not v3 then
		return attachment2:Clone()
	end

	task.cancel(v4)
	v2[v3] = nil
	return v3
end

local memoize = Util.Memoize(function(instance)
	local children = {}

	for _, child in pairs(instance:GetChildren()) do
		table.insert(children, child)
	end

	return children
end)
local memoize2 = Util.Memoize(function(data)
	return {
		Size = data.Size.Keypoints,
		Speed = data.Speed,
		Acceleration = data.Acceleration,
		Lifetime = data.Lifetime
	}
end)
local memoize3 = Util.Memoize(function(parent)
	local v2 = {
		{},
		{}
	}

	for _, v3 in pairs(memoize(dough.F.Particles.Ready)) do
		local clone = v3:Clone()
		clone.Enabled = false
		clone.Parent = parent
		table.insert(v2[1], clone)
		table.insert(v2[2], v3)
	end

	return v2
end)
local memoize4 = Util.Memoize(function(parent)
	local v2 = {
		{},
		{}
	}

	for _, v3 in pairs(memoize(dough.Particles.Buso)) do
		local clone = v3:Clone()
		clone.Enabled = false
		clone.Parent = parent
		table.insert(v2[1], clone)
		table.insert(v2[2], v3)
	end

	return v2
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function round(p, p2)
	local v2, v3 = math.modf(p / p2)
	return (tonumber(string.format("%.3f", p2 * (v2 + (v3 > 0.5 and 1 or 0)))))
end

local function popParticles(instance, value, value2, value3, p)
	local v2 = typeof(instance) == "Instance"
	local v3 = round(value or 1, 0.01) -- equivalent call inferred; original call site unknown
	local fadeOut = round(value2 or 1, 0.01) -- equivalent call inferred; original call site unknown
	local identity = CFrame.identity

	if v2 then
		if instance:IsA("Model") then
			identity = instance:GetModelCFrame()
		elseif instance:IsA("BasePart") then
			identity = instance.CFrame
		elseif instance:IsA("Attachment") then
			identity = instance.WorldCFrame
		end
	elseif typeof(instance) == "CFrame" then
		identity = instance
	elseif typeof(instance) == "Vector3" then
		identity = CFrame.new(instance)
	end

	local terrain = workspace.Terrain

	if v2 then
		if instance:IsA("Model") then
			terrain = instance.PrimaryPart
		elseif instance:IsA("BasePart") then
			terrain = instance
		elseif instance:IsA("Attachment") then
			terrain = instance
		end
	end

	local v5 = 100 + 2.5 * v3
	local magnitude = (currentCamera.CFrame.p - identity.p).Magnitude

	if v5 < magnitude then
		if v5 * 2 < magnitude then
			return 0
		end
	else
		local v6 = magnitude / v5
		Effect.new("ShakeCam"):replicate({
			PosInfluence = createVector(0, 1, 1),
			RotInfluence = createVector(1, 0, 1),
			Magnitude = 2,
			Roughness = 3,
			FadeIn = 0,
			FadeOut = fadeOut,
			Power = 1 - v6 * 0.5
		})
	end

	local grab = Grab(attachment)

	if v2 then
		grab.CFrame = CFrame.identity
	else
		grab.CFrame = instance
	end

	local v7 = memoize3(grab)
	local v8 = memoize4(grab)
	local v9 = 0

	if not p then
		for k, v10 in pairs(v7[1]) do
			local v11 = memoize2(v7[2][k])
			v10.Lifetime = NumberRange.new(v11.Lifetime.Min * fadeOut, v11.Lifetime.Max * fadeOut)
			Util.Misc.ScaleParticle(v10, v3, v11)
			v9 = math.max(v9, v10.Lifetime.Max)
		end
	end

	if value3 then
		local color = typeof(value3) == "Instance" and value3.Color

		if not color then
			if typeof(value3) == "Color3" then
				color = value3
			else
				color = false
			end
		end

		if color then
			for k, v10 in pairs(v8[1]) do
				local v11 = memoize2(v8[2][k])
				v10.EmissionDirection = Enum.NormalId.Back
				v10.Color = ColorSequence.new(color)
				v10.Lifetime = NumberRange.new(v11.Lifetime.Min * fadeOut * 1.5, v11.Lifetime.Max * fadeOut * 1.5)
				v10.SpreadAngle = Vector2.new(1, 1) * 180
				Util.Misc.ScaleParticle(v10, v3 / 2, v11)
				v10.Speed = NumberRange.new(v10.Speed.Min * 2, v10.Speed.Max * 1.5)
				v9 = math.max(v9, v10.Lifetime.Max)
			end
		end
	end

	grab.Parent = terrain

	if not p then
		for _, v10 in pairs(v7[1]) do
			local emitCount = v10:GetAttribute("EmitCount")
			local emitDelay = v10:GetAttribute("EmitDelay")
			-- equivalent calls inferred from this helper; original call sites unknown
			local v12 = v10

			local function fn()
				if emitCount then
					v12:Emit(emitCount)
				end
			end

			if emitDelay and emitDelay > 0 then
				task.delay(emitDelay, fn)
			else
				fn() -- equivalent call inferred; original call site unknown
			end
		end
	end

	if value3 then
		local color = typeof(value3) == "Instance" and value3.Color

		if not color then
			if typeof(value3) == "Color3" then
				color = value3
			else
				color = false
			end
		end

		if color then
			for _, v10 in pairs(v8[1]) do
				v10.Enabled = true
				v10:Emit((v10:GetAttribute("Emit") or 10) / 2 + v3 / 4)
			end

			local v10 = v9 / 2 * 0.5
			v9 += v10
			task.delay(v10, function()
				for _, v11 in pairs(v8[1]) do
					v11.Enabled = false
				end
			end)
		end
	end

	task.delay(v9, function()
		Return(attachment, grab)
	end)
	return v9
end

return function(player)
	local random = Random.new()
	local character = player.Character
	local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	local wheel = player.Wheel or player.RootPart or player.Anchor or player.Root
	local parent = wheel.Parent
	local maxSpeed = parent:GetAttribute("MaxSpeed")
	local scale = player.Scale or 1
	local fadeIn = player.FadeIn or 0.5
	local fadeOut = player.FadeOut or 0.25
	local attachment2 = createAttachment()
	attachment2.Size = wheel.Size
	attachment2.CFrame = wheel.CFrame

	for _, attachment3 in pairs(wheel:GetChildren()) do
		if not attachment3:IsA("Attachment") then
			continue
		end

		local clone = attachment3:Clone()
		clone.Parent = attachment2
	end

	attachment2.Parent = _WorldOrigin
	local size = parent.Size
	local scale2 = math.min(size.X, size.Y, size.Z)
	local v3 = math.max(size.X, size.Y, size.Z)
	local v4 = Effect2.new({
		Root = wheel,
		EffectPart = attachment2,
		UnitSize = size,
		Scale = scale * 0,
		Buso = player.Buso
	})
	local root = nil
	local now = tick()
	local v6 = 0.016666666666666666

	if (currentCamera.CFrame.p - attachment2.CFrame.p).Magnitude < 250 + attachment2.Size.Magnitude * 4 then
		Util.Sound:Play("Dough.DoughAppear", attachment2, nil, 1.466 / (fadeIn * 3))
		Util.Sound:Play("Dough.DoughWheelSpawn", attachment2, nil, 1.7 / (fadeIn * 1.5))
	end

	local v8 = math.max(0, (popParticles(v4.Model.PrimaryPart.CFrame, v3 * 0.75, fadeIn * 2)))
	local v9 = false

	local function fn()
		if not parent:IsDescendantOf(workspace) or not wheel:IsDescendantOf(workspace) or v9 then
			return
		end

		if player.Buso then
			v8 = math.max(v8, (popParticles(attachment2, v3 * 0.75, fadeIn * 2, player.Buso, true)))
		end

		if (currentCamera.CFrame.p - attachment2.CFrame.p).Magnitude < 250 + attachment2.Size.Magnitude * 4 then
			Util.Sound:Play("Dough.DoughWindSwipe", attachment2.Position, nil, 1.9 / (fadeIn * 3))
		end

		local v10 = (currentCamera.CFrame.p - wheel.Position).Magnitude / (v3 * 2 + 150)

		if v10 < 1 then
			Effect.new("ShakeCam"):replicate({
				Preset = "Bump2",
				Power = 2 * (1 - v10)
			})
		end

		local rayMap, v11, v12 = Util.RayMap(wheel.Position, -wheel.CFrame.UpVector * (v3 + scale2))

		if rayMap then
			local cFrame2 = Util.Misc.AlignCFrame(CFrame.new(Vector3.new(), wheel.CFrame.LookVector) + v11, v12) * CFrame.new(
				0,
				0,
				-v3 * 1.5
			) + v12

			if (currentCamera.CFrame.p - attachment2.CFrame.p).Magnitude < 250 + attachment2.Size.Magnitude * 4 then
				Util.Sound:Play("Dough.DoughWheelDrift2", cFrame2.p, nil, 1)
				Util.Sound:Play("Dough.DoughWheelDrift", cFrame2.p, nil, 1.5245 / fadeIn)
			end

			doughMiscDebrisHeatMark:replicate({
				Hit = rayMap,
				CFrame = cFrame2,
				Scale = Vector2.new(scale2 * 1.5, v3 * 3),
				FadeIn = fadeIn / 2,
				Lifetime = fadeIn,
				FadeOut = fadeIn * 2
			})
		end

		for i = 3, 1, -1 do
			local v13 = v3 * 0.5 * (i / 3 * 0.5 + 0.25)
			local cFrame = wheel.CFrame
			doughShockwaves2:replicate({
				CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, v13 * 0.05, 0),
				VectorOffset = cFrame.UpVector * (i * v13 * 0.1),
				Lifetime = i / 3 * 0.025 + 0.075,
				Scale = v13 * 3 * ((5 - i) / 3 * 0.25 + 1.25),
				Speed = (i % 2 == 0 and 1 or -1) * 2 * i / 3,
				Color = { Color3.fromRGB(555, 555, 0), Color3.fromRGB(555, 555, 555) }
			})
			task.wait(0.05)
		end
	end

	task.delay(fadeIn, fn)
	local v10

	if (currentCamera.CFrame.p - attachment2.CFrame.p).Magnitude < 250 + attachment2.Size.Magnitude * 4 then
		v10 = Util.Sound:Play("Dough.DoughWheelLoop", attachment2, nil, 1.255)
	end

	local cFrame = wheel.CFrame
	local p = cFrame.p
	local v11 = nil
	local v12 = nil
	local v13 = nil
	local v14 = nil
	local v15 = 0
	local v16 = nil
	local v17 = 0
	local color = nil
	local v18 = 0
	local v19 = 0

	while wheel:IsDescendantOf(workspace) and parent:IsDescendantOf(workspace) and not wheel:GetAttribute("Destroy") do
		if (currentCamera.CFrame.p - attachment2.CFrame.p).Magnitude < 250 + attachment2.Size.Magnitude * 4 and not v10 then
			v10 = Util.Sound:Play("Dough.DoughWheelLoop", attachment2, nil, 1.255)
		end

		local lastTime = tick()
		local particleRateInfluence = math.min(1, (lastTime - now) / fadeIn)

		if v15 < particleRateInfluence then
			v4:__scale(Util.Tween.point(0, scale, particleRateInfluence))
			v15 = particleRateInfluence
		end

		local position = parent.Position
		local v21 = (position - p) / v6
		local velocity = parent.Velocity
		local magnitude = velocity.Magnitude

		if particleRateInfluence == 1 then
			local _ = magnitude < maxSpeed * 0.75
		end

		local currentTurnSpeed = wheel:GetAttribute("CurrentTurnSpeed") or 0
		local rayMap, v22, v23 = Util.RayMap(cFrame.Position, cFrame.LookVector * v3)

		if not rayMap then
			rayMap, v22, v23 = Util.RayMap(cFrame.Position, -cFrame.UpVector * v3)

			if not rayMap then
				v23 = createVector(0, 1, 0)
			end
		end

		cFrame = Util.Misc.AlignCFrame(wheel.CFrame, v23)
		local v24

		if rayMap then
			v24 = rayMap
		else
			local Y = v22.Y
			v24 = v3 / 2 + -4 <= Y
		end

		local v25

		if rayMap then
			v25 = math.acos((Util.Misc.round((createVector(0, 1, 0)):Dot(v23), 4)))
		else
			v25 = math.acos((Util.Misc.round(wheel.CFrame.LookVector:Dot(v21.Unit), 4)))
		end

		if rayMap then
			local cFrame2 = cFrame - cFrame.p + v22
			local magnitude2 = attachment2.Size.Magnitude

			if v16 ~= rayMap then
				local v27 = math.clamp((v17 - workspace.Gravity * 2) / (workspace.Gravity * 4), 0, 1)

				if v27 > 0 then
					local scale3 = magnitude2 / 1.5 + magnitude2 * 1.5 * v27

					if (currentCamera.CFrame.p - attachment2.CFrame.p).Magnitude < 250 + attachment2.Size.Magnitude * 4 then
						Util.Sound:Play("Dough.DoughPastryRiverSpawn", cFrame2, nil, 2.0492857142857144)
					end

					Effect.new("Dough.Explosions.DripScatter"):replicate({
						CFrame = cFrame2 * CFrame.Angles(1.5707963267948966, 0, 0),
						Spread = Vector2.new(90, 90),
						Scale = scale3 * 0.3,
						Drag = 2,
						Distance = 15 + scale3 * (v27 * 3 + 1),
						Rate = 2 + scale3 / 2,
						Gravity = 0.75,
						Time = 0.4,
						Influence = { 0.5, 1.5 }
					})
					Effect.new("Dough.Misc.Floor"):replicate({
						CFrame = cFrame2,
						Scale = scale3,
						FadeIn = 0.2,
						FadeOut = 0.9,
						Lifetime = 1
					})
				end
			end

			v16 = rayMap
			v17 = 0
		else
			v17 = math.max(v17, (math.abs(velocity.Y)))
		end

		attachment2.CFrame = Util.Misc.AlignCFrame(wheel.CFrame, createVector(0, 1, 0)) * CFrame.Angles(v25, 0, 0)

		if rayMap and color ~= rayMap.Color then
			v4:setColor("All", "Debris", rayMap.Color)
			color = rayMap.Color
		end

		v4.RevolutionsPerSecond = ((1 - math.abs(currentTurnSpeed) / 1) * 1 + 1.5) * particleRateInfluence
		v4.ParticleRateInfluence = particleRateInfluence
		v4.FlameParticleRateInfluence = 1

		if v10 then
			v10.PlaybackSpeed = 1.255 / (1 + 0.5 * v4.RevolutionsPerSecond)
		end

		if math.abs(currentTurnSpeed) > 0.75 then
			local v26 = math.abs(currentTurnSpeed)

			if (currentCamera.CFrame.p - attachment2.CFrame.p).Magnitude < 250 + attachment2.Size.Magnitude * 4 then
				if v11 then
					if v11.TimePosition > 0.75 then
						if v12 then
							if rayMap then
								v12.PlaybackSpeed = v26 * 0.5 + 1.5
							elseif v24 then
								Util.Sound:FadeOut(v12, 0.25)
								Util.Sound:FadeOut(v11, 0.25)
								v11 = nil
								v12 = nil
							else
								v12.PlaybackSpeed = v26 * 0.75 + 0.9
							end
						else
							Util.Sound:FadeOut(v11, v26)

							if rayMap then
								v12 = Util.Sound:Play("Dough.DoughFireLoop", attachment2, nil, v26 * 0.5 + 1.5)
							elseif not v24 then
								v12 = Util.Sound:Play("Dough.DoughWaterLoop", attachment2, nil, v26 * 0.75 + 0.9)
							end
						end
					end
				elseif rayMap then
					v11 = Util.Sound:Play("Dough.DoughFireStart", attachment2, nil, v26 * 0.5 + 1.5)
				elseif not v24 then
					v11 = Util.Sound:Play("Dough.DoughWaterSplash", attachment2, nil, v26 * 0.5 + 1)
				end
			end
		else
			if v11 then
				Util.Sound:FadeOut(v11, 0.25)
				v11 = nil
			end

			if v12 then
				Util.Sound:FadeOut(v12, 0.25)
				v12 = nil
			end
		end

		if math.abs(currentTurnSpeed) > 0.25 then
			local v26 = math.abs(currentTurnSpeed)

			if (currentCamera.CFrame.p - attachment2.CFrame.p).Magnitude < 250 + attachment2.Size.Magnitude * 4 then
				if v13 then
					if v13.TimePosition > 0.25 then
						if v14 then
							v14.PlaybackSpeed = v26 * 0.25 + 0.9
						else
							Util.Sound:FadeOut(v13, v26)
							v14 = Util.Sound:Play("Dough.DoughWheelDriftLoop2", attachment2, nil, v26 * 0.25 + 0.9)
						end
					end
				else
					v13 = Util.Sound:Play("Dough.DoughWheelDrift2", attachment2, nil, v26 + 0.5)
				end
			end
		else
			if v13 then
				Util.Sound:FadeOut(v13, 0.25)
				v13 = nil
			end

			if v14 then
				Util.Sound:FadeOut(v14, 0.25)
				v14 = nil
			end
		end

		if rayMap then
			v4:enable("All", "Water", false)
			v4:lock("All", "Water", false)

			if math.abs(currentTurnSpeed) > 0.75 then
				v4.FlameParticleRateInfluence = math.clamp((math.abs(currentTurnSpeed) - 0.75) / 0.25, 0, 1)

				if currentTurnSpeed > 0 then
					v4:enable("Left", "Flames", false)
					v4:enable("Left", "Debris", false)
					v4:enable("Right", "Flames", true)
				else
					v4:enable("Left", "Flames", true)
					v4:enable("Right", "Debris", true)
					v4:enable("Right", "Flames", false)
				end
			elseif math.abs(currentTurnSpeed) < 0.25 then
				v4:enable("All", "Flames", false)
				v4:enable("All", "Debris", true)
			elseif currentTurnSpeed > 0 then
				v4:enable("All", "Flames", false)
				v4:enable("Left", "Debris", false)
				v4:enable("Right", "Debris", true)
			else
				v4:enable("All", "Flames", false)
				v4:enable("Left", "Debris", true)
				v4:enable("Right", "Debris", false)
			end
		else
			v4:enable("All", "Flames", false)
			v4:enable("All", "Debris", false)

			if v24 then
				v4:enable("All", "Water", false)
				v4:lock("All", "Water", false)
			elseif math.abs(currentTurnSpeed) < 0.5 then
				v4:enable("All", "Water", true)
			elseif currentTurnSpeed > 0 then
				v4:enable("Left", "Water", false)
				v4:enable("Right", "Water", true)
			else
				v4:enable("Left", "Water", true)
				v4:enable("Right", "Water", false)
			end
		end

		v4:enable("Generic", nil, true)

		if particleRateInfluence == 1 then
			if math.abs(currentTurnSpeed) > 0.75 and rayMap then
				if not root or root and not root:IsDescendantOf(workspace) then
					root = createAttachment()
					root.CFrame = attachment2.CFrame
					root.Parent = _WorldOrigin
					doughMiscDebrisTrail:replicate({
						Scale = scale2,
						Root = root,
						Effects = {
							FireMark = true
						}
					})
				end

				root.CFrame = attachment2.CFrame
			elseif root and root:IsDescendantOf(workspace) then
				root:Destroy()
				root = nil
			end
		end

		if particleRateInfluence == 1 then
			local v26 = lastTime - v18

			if v6 * 2 < v26 and rayMap and (currentCamera.CFrame.p - attachment2.CFrame.p).Magnitude < v3 * 4 + 175 then
				if math.abs(currentTurnSpeed) > 0.75 then
					local v27 = math.sign(currentTurnSpeed)
					p = position

					for i = -1, 1, 2 do
						local halfMagnitude = wheel.Size.Magnitude / 2
						local v29 = attachment2.CFrame * CFrame.new(i * wheel.Size.X, -wheel.Size.Y / 2, 0)
						local v30 = halfMagnitude * (2 + random:NextNumber(0, 3))
						local v31 = createVector(-0, -1, -0) * workspace.Gravity * random:NextNumber(0.3, 1)
						local number = random:NextNumber(0.3, 1)
						local v32 = rock2.new({
							Type = "Flying",
							FadeIn = { 0.125, 0.25 },
							FadeOut = { 0.125, 0.25 },
							Lifetime = { 0.125, 0.25 },
							Size = Vector3.new(
								random:NextNumber(0.5, 1.5),
								random:NextNumber(0.25, 1),
								random:NextNumber(0.5, 1.5)
							),
							Scale = { halfMagnitude / 6, halfMagnitude / 4 }
						})
						v32:Spawn(v29)

						if i == v27 then
							v32:Eject({
								Velocity = Util.Misc.Physics.Velocity(
									createVector(0, 0, 0),
									(i * v29.RightVector - v29.LookVector + v29.UpVector * random:NextNumber(0.5, 2)).Unit * v30,
									v31,
									number
								),
								RotVelocity = createVector(6.2831855, 6.2831855, 6.2831855)
							})
						else
							v32:TweenShift(i * v29.RightVector * v30 / 2, 0.25)
						end
					end
				else
					p = position

					for i = -1, 1, 2 do
						local halfMagnitude = wheel.Size.Magnitude / 2
						local v28 = attachment2.CFrame * CFrame.new(i * wheel.Size.X, -wheel.Size.Y / 2, 0)
						local v29 = halfMagnitude * random:NextNumber(0.5, 1.5)
						local v30 = rock2.new({
							FadeIn = { 0.125, 0.25 },
							FadeOut = { 0.125, 0.25 },
							Lifetime = { 0.25, 0.5 },
							Size = Vector3.new(
								random:NextNumber(0.5, 1.5),
								random:NextNumber(0.25, 1),
								random:NextNumber(0.5, 1.5)
							),
							Scale = { halfMagnitude / 5, halfMagnitude / 3 }
						})
						v30:Spawn(v28)

						if random:NextInteger(1, 9) % 3 == 0 then
							local v31 = createVector(-0, -1, -0) * workspace.Gravity * 0.5
							local v32 = 0.5 + random:NextNumber(0.5, 1.5)
							v30.Type = "Flying"
							v30:Eject({
								Velocity = Util.Misc.Physics.Velocity(
									createVector(0, 0, 0),
									(i * v28.RightVector - v28.LookVector).Unit * v29,
									v31,
									v32
								),
								RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
							})
						else
							v30:TweenShift(i * v28.RightVector * v29 / 2, 0.25)
						end
					end
				end

				v18 = lastTime
			else
				p = position
			end
		else
			p = position
		end

		if particleRateInfluence == 1 then
			local v26 = lastTime - v19

			if v6 * 4 < v26 then
				doughExplosionsDripScatter:replicate({
					Rate = 1,
					Scale = v3 * 0.3,
					CFrame = attachment2.CFrame * CFrame.Angles(1.5707963267948966, 0, 0) + v4.Model.PrimaryPart.Velocity * v6,
					Speed = (v4.Model.PrimaryPart.Velocity * createVector(1, 0, 1)).Magnitude * 0.5,
					Distance = v3 * 2,
					Spread = Vector2.new(45, 45),
					Gravity = 0.7,
					Time = 0.5 + random:NextNumber(0.5, 1.5),
					Lifetime = 0.2,
					Influence = { 0.5, 2 }
				})
				v19 = lastTime
			end
		end

		v4:update(v6)
		RunService.RenderStepped:Wait()
		v6 = tick() - lastTime
	end

	v9 = true

	if root and root:IsDescendantOf(workspace) then
		root:Destroy()
	end

	v4:enable("All", "All", false)

	if (currentCamera.CFrame.p - attachment2.CFrame.p).Magnitude < 250 + attachment2.Size.Magnitude * 4 then
		Util.Sound:Play("Dough.DoughWheelDespawn", attachment2, nil, 1.287 / (fadeOut * 2))
	end

	if v10 then
		Util.Sound:FadeOut(v10, fadeOut / 2)
	end

	if v11 then
		Util.Sound:FadeOut(v11, 0.25)
	end

	if v12 then
		Util.Sound:FadeOut(v12, 0.25)
	end

	if v13 then
		Util.Sound:FadeOut(v13, 0.25)
	end

	if v14 then
		Util.Sound:FadeOut(v14, 0.25)
	end

	task.spawn(function()
		local rayMap, _, _ = Util.RayMap(primaryPart.Position, createVector(-0, -1, -0) * v3)

		if rayMap then
			local attachment3 = createAttachment()
			attachment3.CFrame = primaryPart.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			attachment3.Parent = _WorldOrigin
			local v20

			if (currentCamera.CFrame.p - attachment2.CFrame.p).Magnitude < 250 + attachment2.Size.Magnitude * 4 then
				v20 = Util.Sound:Play("Dough.DoughWheelDrift", attachment3, nil, 1.5245 / fadeOut)
			else
				v20 = nil
			end

			doughMiscDebrisTrail:replicate({
				Scale = primaryPart.Size.Magnitude * 0.5,
				Root = attachment3,
				Duration = 1,
				Effects = {
					Rocks = true,
					Particles = {
						Rocks = true,
						Dust = true
					}
				}
			})
			Util.DistributedLoop:add(function(p2, _)
				local v21 = math.min(1, p2 / (fadeOut / 2))
				attachment3.CFrame = primaryPart.CFrame * CFrame.Angles(0, 3.141592653589793, 0)

				if v21 ~= 1 then
					return
				end

				attachment3:SetAttribute("Destroyed", true)

				if v20 then
					Util.Sound:FadeOut(v20, fadeOut / 2)
				end

				Util.Debris:AddItem(attachment3, fadeOut)
				return true
			end)
		end
	end)
	local lastTime = tick()

	while true do
		local v20 = tick() - lastTime
		local v21 = math.min(1, v20 / (fadeOut * 0.33))
		math.min(1, v20 / (fadeOut * 0.33 / 2))
		v4:__scale(Util.Tween.point(scale, 0, v21))

		if v21 == 1 then
			break
		end

		RunService.RenderStepped:Wait()
	end

	v8 = math.max(popParticles(v4.Model.PrimaryPart.CFrame, v3 * 0.25, fadeOut * 0.33 * 2), v8)
	task.wait(fadeOut + v8)
	attachment2:Destroy()
	v4:Destroy()
end