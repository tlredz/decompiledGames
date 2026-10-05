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
	local root = data.Root or data.Anchor
	local duration = data.Duration
	local indicator = data.Indicator
	local random = Random.new()
	local color = data.Color
	local effects = data.Effects or {
		Rocks = true,
		Particles = {
			Rocks = true,
			Dust = true,
			Misc = true
		},
		FireMark = true
	}
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

	if 150 + 3 * scale * 10 < magnitude then
		return
	end

	local clone = dough.Misc.Debris.Trail_OG.Debris:Clone()
	clone.CFrame = CFrame.new(root.Position)
	clone.Size *= scale * 1.1
	local v2 = 0
	local v3 = {}
	local v4 = 0

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			local max = descendant.Lifetime.Max
			v2 = math.max(v2, max)
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
			local lifetime = descendant.Lifetime
			v4 = math.max(v4, lifetime)
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
	distributedLoop:add(function(p, _)
		if root:IsDescendantOf(workspace) and not (indicator and indicator:GetAttribute("Destroyed")) and not (root:GetAttribute("Destroyed") or duration and duration < p) then
			local position = root.Position
			local cframe = CFrame.new()
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
					if indicator and indicator:GetAttribute("Power") then
						descendant.Size = misc.ScaleKeypoints(v3[descendant].Size, scale * 1.5)
						descendant.SpreadAngle = v3[descendant].SpreadAngle * 1.5
						descendant.Speed = NumberRange.new(
							v3[descendant].Speed.Min * scale * 1.25,
							v3[descendant].Speed.Max * scale * 1.5
						)
					end

					if v5 then
						descendant.Color = ColorSequence.new(v5.Color)
					end

					local v10 = descendant.Name:find("Dust") and "Dust" or descendant.Name:find("Rocks") and "Rocks" or "Misc"
					local particle = effects.Particles[v10]
					descendant.Enabled = v5 and particle and true or false
				elseif descendant:IsA("Trail") then
					local v10 = not v5 and 1 or 1 - v9 or 1
					descendant.WidthScale = misc.ScaleKeypoints(
						v3[descendant].WidthScale,
						scale * math.clamp(v10 / 2 / 0.5, 0.125, 0.5)
					)
					descendant.MaxLength = v3[descendant].MaxLength * (duration or 1)
					descendant.Lifetime = v3[descendant].Lifetime * (duration or 1)
					descendant.Enabled = effects.FireMark and true or false
				elseif descendant:IsA("Attachment") then
					local v10 = not v5 and 1 or 1 - v9 or 1
					descendant.Position = descendant:GetAttribute("Position") * scale * 1.25 * math.clamp(
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
						if math.random(2) == 1 then
							continue
						end

						local v10 = scale
						local v11 = v2 / 2 + random:NextNumber(0.5, 1)

						if indicator and indicator:GetAttribute("Power") then
							v10 *= 1.5
							v11 *= 1.5
						end

						local v12 = cframe * CFrame.new(i * v10 * random:NextNumber(0.5, 2) * (1 - v9), 0, 0)
						local v13 = v10 * random:NextNumber(2, 4) * math.clamp((1 - v9) * 1, 0.35, 1)
						local v14 = rock2.new({
							Type = "Ground",
							FadeOut = { v11 / 5, v11 / 3 },
							FadeIn = { v11 / 5, v11 / 3 },
							Lifetime = { v11 / 5, v11 / 3 },
							Size = Vector3.new(
								random:NextNumber(0.5, 1.5),
								random:NextNumber(0.5, 1.5),
								random:NextNumber(0.5, 1.5)
							),
							Scale = { v13 / 4, v13 / 2 }
						})

						if random:NextInteger(1, 8) % 4 == 0 then
							v14.Type = "Flying"
							v14:Spawn(v12)
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
						else
							v14:Spawn(v12)
							v14:TweenShift(
								i * v12.RightVector * v13 / random:NextNumber(2, 4),
								v11 / random:NextNumber(2, 4)
							)
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
end