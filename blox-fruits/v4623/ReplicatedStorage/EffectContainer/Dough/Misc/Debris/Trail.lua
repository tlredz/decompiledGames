local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
local map = workspace:WaitForChild("Map")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local misc = Util.Misc
local distributedLoop = Util.DistributedLoop
local rayCastWhitelist = Util.RayCastWhitelist
local currentCamera = workspace.CurrentCamera
local rock2 = Util.Rock2
local swapColors = misc.SwapColors
return function(data)
	local isBlue = data.isBlue
	local root = data.Root or data.Anchor
	local duration = data.Duration
	local indicator = data.Indicator
	local random = Random.new()
	local color = data.Color
	local effects = data.Effects or {
		ForceFlyingRocks = false,
		ForceRockSpawn = false,
		Rocks = true,
		Particles = {
			Rocks = true,
			Dust = true,
			Misc = true
		},
		FireMark = true,
		IgnoreParticles = false,
		Fast = false,
		FadeInMod = 1
	}
	local fadeInMod = effects.FadeInMod or 1
	effects.Particles = effects.Particles or {}
	local v

	if root then
		if typeof(root) == "Instance" then
			v = root:IsA("BasePart") or root:IsA("Attachment")
		else
			v = false
		end
	else
		v = root
	end

	assert(v, string.format("Please make sure to set a BasePart for the \"Root\" parameter"))
	local scale = data.Scale or root.Size.Magnitude * 0.1
	local magnitude = (currentCamera.CFrame.p - root.CFrame.p).Magnitude

	if 200 + 4 * scale * 10 < magnitude then
		return
	end

	local clone = dough.Misc.Debris.Trail.Debris:Clone()
	clone.CFrame = CFrame.new(root.Position)
	clone:SetAttribute("Size", clone.Size)
	clone.Size = clone:GetAttribute("Size") * scale * 1.1
	local v2 = 0
	local v3 = {}
	local v4 = 0

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			v2 = math.max(v2, descendant.Lifetime.Max)
			local v5 = {
				Size = descendant.Size.Keypoints,
				Acceleration = descendant.Acceleration,
				Speed = descendant.Speed,
				SpreadAngle = descendant.SpreadAngle
			}
			misc.ScaleParticle(descendant, scale, v5)
			v3[descendant] = v5
			descendant.Enabled = false
		elseif descendant:IsA("Trail") then
			v4 = math.max(v4, descendant.Lifetime)
			local v5 = {
				Lifetime = descendant.Lifetime,
				MaxLength = descendant.MaxLength,
				MinLength = descendant.MinLength,
				WidthScale = descendant.WidthScale,
				Transparency = descendant.Transparency
			}

			if color and descendant.Parent.Name == "FireMark" then
				local value = descendant.Color.Keypoints[1].Value
				descendant.Color = swapColors(descendant, {
					{ value, (misc.CalculateColorByIntensity(color, misc.CalculateIntensity(value))) }
				})
			end

			descendant.WidthScale = misc.ScaleKeypoints(v5.WidthScale, scale)
			descendant.MaxLength = v5.MaxLength * (duration or 1)
			descendant.Lifetime = v5.Lifetime * (duration or 1)
			v3[descendant] = v5
			descendant.Enabled = false
		elseif descendant:IsA("Attachment") then
			descendant:SetAttribute("Position", descendant.Position)
		end
	end

	clone.Parent = _WorldOrigin

	if isBlue == true then
		Util.AdjustObjectDescendantsColors(clone, function(_, _)
			return Color3.new(0, 0.666667, 1)
		end)
	end

	distributedLoop:add(function(p, _)
		if root:IsDescendantOf(workspace) and not (indicator and indicator:GetAttribute("Destroyed")) and not (root:GetAttribute("Destroyed") or (duration or 10) < p) then
			local position = root.Position
			local cframe = CFrame.new()
			local scale2 = scale

			if root:GetAttribute("UpdateScale") then
				scale2 = v3.Scale or root.Size.Magnitude * 0.1
				clone.Size = clone:GetAttribute("Size") * scale2 * 1.1
			end

			local v5, v6, v7 = rayCastWhitelist(
				position + root.CFrame.UpVector * clone.Size.Y * 1.5,
				-root.CFrame.UpVector * clone.Size.Y * 4,
				{ map }
			)
			local v8 = v7 or createVector(0, 1, 0)
			CFrame.new()
			local v9

			if v5 then
				local alignCFrame = misc.AlignCFrame(CFrame.new(Vector3.new(), root.CFrame.LookVector) + v6, v8)
				cframe = alignCFrame + v8 * clone.Size.Y / 4
				v9 = math.abs(((root.Position - alignCFrame.p):Dot(v8))) / (clone.Size.Y * 1.5)
			else
				v9 = 1
			end

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					if not effects.IgnoreParticles then
						if indicator and indicator:GetAttribute("Power") then
							descendant.Size = misc.ScaleKeypoints(v3[descendant].Size, scale2 * 1.5)
							descendant.SpreadAngle = v3[descendant].SpreadAngle * 1.5
							descendant.Speed = NumberRange.new(
								v3[descendant].Speed.Min * scale2 * 1.25,
								v3[descendant].Speed.Max * scale2 * 1.5
							)
						end

						if v5 then
							descendant.Color = ColorSequence.new(v5.Color)
						end

						local v10 = descendant.Name:find("Dust") and "Dust" or descendant.Name:find("Rocks") and "Rocks" or "Misc"
						local particle = effects.Particles[v10]
						descendant.Enabled = v5 and particle and true or false
					end
				elseif descendant:IsA("Trail") then
					local v10 = not v5 and 1 or 1 - v9 or 1
					descendant.WidthScale = misc.ScaleKeypoints(
						v3[descendant].WidthScale,
						scale2 * math.clamp(v10 / 2 / 0.5, 0.125, 0.5)
					)
					descendant.MaxLength = v3[descendant].MaxLength * (duration or 1)
					descendant.Lifetime = v3[descendant].Lifetime * (duration or 1)
					descendant.Enabled = effects.FireMark and true or false
				elseif descendant:IsA("Attachment") then
					local v10 = not v5 and 1 or 1 - v9 or 1
					descendant.Position = descendant:GetAttribute("Position") * scale2 * 1.25 * math.clamp(
						v10 / 2 / 0.5,
						0.125,
						0.5
					)
				end
			end

			if v5 then
				clone.CFrame = cframe

				if effects.Rocks then
					for i = -1, 1, 2 do
						if not (effects.ForceRockSpawn or math.random(2) ~= 1) then
							continue
						end

						local v10 = math.max(duration or 0, v2 / 2) + random:NextNumber(0.5, 1)
						local v11

						if indicator and indicator:GetAttribute("Power") then
							v11 = scale2 * 1.5
							v10 *= 1.5
						else
							v11 = scale2
						end

						if effects.Fast then
							v10 /= 1.666
						end

						local v12 = cframe * CFrame.new(i * v11 * random:NextNumber(0.5, 2) * (1 - v9), 0, 0)
						local v13 = v11 * random:NextNumber(2, 4) * math.clamp((1 - v9) * 1, 0.35, 1)
						local v14 = rock2.new({
							Type = "Ground",
							FadeOut = { v10 / 5, v10 / 3 },
							FadeIn = { v10 / 5 * fadeInMod, v10 / 3 * fadeInMod },
							Lifetime = { v10 / 5, v10 / 3 },
							Size = Vector3.new(
								random:NextNumber(0.5, 1.5),
								random:NextNumber(0.5, 1.5),
								random:NextNumber(0.5, 1.5)
							),
							Scale = { v13 / 4, v13 / 2 }
						})

						if effects.NoFlyingRocks or not effects.ForceFlyingRocks and random:NextInteger(1, 8) % 4 ~= 0 then
							v14:Spawn(v12, effects.Burnt)
							v14:TweenShift(
								i * v12.RightVector * v13 / random:NextNumber(2, 4),
								v10 / random:NextNumber(2, 4) * fadeInMod
							)
						else
							v14.Type = "Flying"
							v14:Spawn(v12, effects.Burnt)
							v14:Eject({
								Velocity = Util.Misc.Physics.Velocity(
									Vector3.new(),
									(i * v12.RightVector * random:NextNumber(1, 3) + v12.UpVector * random:NextNumber(
										0.5,
										2
									) + v12.LookVector * random:NextNumber(1.5, 3)) * random:NextNumber(
										v13 * 2,
										v13 * 4
									),
									Vector3.new(0, -workspace.Gravity * 0.35, 0),
									0.5 + random:NextNumber(0, 1)
								),
								AngularVelocity = Vector3.new(
									random:NextNumber(-1, 1),
									random:NextNumber(-1, 1),
									random:NextNumber(-1, 1)
								) * 3.141592653589793 * (1 / v14.Scale)
							})
						end
					end
				end
			end
		else
			for emitter, _ in pairs(v3) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end

				v3[emitter] = nil
			end

			task.delay(math.max(v2, v4), function()
				clone:Destroy()
			end)
			return true
		end
	end)

	if isBlue == true then
		Util.AdjustObjectDescendantsColors(clone, function(_, _)
			return Color3.new(0, 0.666667, 1)
		end)
	end
end