local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsConfig = require(ReplicatedStorage.EventsConfig)
local lightning = EventsConfig.Lightning
local color = Color3.fromRGB(table.unpack(lightning.LightningColor))
return {
	strike = function(position: Vector3, options)
		local v = options or {}
		task.spawn(function()
			local child = ReplicatedStorage:FindFirstChild(lightning.LightningFolder)

			if child then
				local height = v.height or lightning.LightningHeight
				local v2 = position + Vector3.new(0, height, 0)
				local boltLife = v.boltLife or lightning.LightningBoltLife
				local cloudLife = v.cloudLife or lightning.LightningCloudLife
				local color2 = v.color or color
				local brightness = v.brightness or lightning.LightningBrightness
				local v3 = v.segments and v.segments[1] or lightning.LightningSegments[1]
				local v4 = v.segments and v.segments[2] or lightning.LightningSegments[2]
				local cloud = child:FindFirstChild("Cloud")

				if cloud then
					local clone = cloud:Clone()
					clone.CFrame = CFrame.new(v2)
					clone.Parent = workspace
					Debris:AddItem(clone, cloudLife)
					task.wait(0.7)
					local cloudGlow = child:FindFirstChild("CloudGlow")

					if cloudGlow then
						local clone2 = cloudGlow:Clone()
						clone2.CFrame = CFrame.new(v2)
						clone2.Parent = workspace
						task.delay(0.2, function()
							local attachment = clone2:FindFirstChild("Attachment")
							local glowParticles = attachment and attachment:FindFirstChild("GlowParticles")

							if glowParticles then
								glowParticles.Enabled = false
							end
						end)
						Debris:AddItem(clone2, 1.5)
					end

					local v5 = math.random(v3, v4)
					local v6 = height / v5
					local number = Random.new():NextNumber(0.5, 1.3)
					local v7 = {}

					for i = 1, v5 do
						local attachment = Instance.new("Attachment")
						Debris:AddItem(attachment, boltLife)
						table.insert(v7, attachment)
						local vector2

						if i == 1 then
							vector2 = createVector(0, 0, 0)
						elseif i == v5 then
							vector2 = position - v2
						else
							local number2 = Random.new():NextNumber(-4, 4)
							local number3 = Random.new():NextNumber(-3, 3)
							local number4 = Random.new():NextNumber(-4, 4)
							vector2 = Vector3.new(number2, -(i - 1) * v6 + number3, number4)
						end

						attachment.Position = vector2
						attachment.Parent = clone

						if not (i > 1) then
							continue
						end

						local beam = Instance.new("Beam")
						Debris:AddItem(beam, boltLife)
						beam.Parent = clone
						beam.Attachment0 = v7[i - 1]
						beam.Attachment1 = attachment
						beam.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, color2),
							ColorSequenceKeypoint.new(1, color2)
						})
						beam.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 0)
						})
						beam.LightInfluence = 0
						beam.Brightness = brightness
						beam.LightEmission = 5
						beam.FaceCamera = true
						beam.Width0 = number
						number = math.clamp(number + Random.new():NextNumber(-0.4, 0.2), 0.1, 1)
						beam.Width1 = number
					end

					local hitParticles = child:FindFirstChild("HitParticles")

					if hitParticles then
						local clone2 = hitParticles:Clone()
						clone2.Position = position
						clone2.Parent = workspace
						Debris:AddItem(clone2, 3)
						task.delay(0.3, function()
							if clone2.Parent then
								for _, descendant in ipairs(clone2:GetDescendants()) do
									if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
										descendant.Enabled = false
									end
								end
							end
						end)
					end

					local lightningSound = child:FindFirstChild("LightningSound")

					if lightningSound then
						local part = Instance.new("Part")
						part.Size = createVector(1, 1, 1)
						part.Position = position
						part.Anchored = true
						part.CanCollide = false
						part.CanTouch = false
						part.CanQuery = false
						part.Transparency = 1
						part.Parent = workspace.Terrain
						local clone2 = lightningSound:Clone()
						clone2.Volume = v.hitSoundVolume or lightning.LightningSoundVolume
						clone2.RollOffMode = Enum.RollOffMode.Linear
						clone2.RollOffMinDistance = 10
						clone2.RollOffMaxDistance = 200
						clone2.Parent = part
						clone2:Play()
						Debris:AddItem(part, 5)
					end

					local cloudParticles = clone:FindFirstChild("CloudParticles")

					if cloudParticles then
						cloudParticles.Enabled = false
					end

					if v.onImpact then
						v.onImpact()
					end

					return
				end
			end

			if v.onImpact then
				v.onImpact()
			end
		end)
	end
}