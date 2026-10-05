local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local v = math.ceil((5 + Config.strikeWarningSeconds + Config.maxStrikesPerWave * Config.strikeStaggerSeconds) / Config.strikeIntervalSeconds) * Config.maxStrikesPerWave

local function setEmission(folder, flag: boolean, flag2: boolean)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = flag and descendant:GetAttribute("LightningOriginallyEnabled") == true

			if flag2 then
				descendant:Clear()
			end
		elseif descendant:IsA("PointLight") then
			descendant.Enabled = flag and descendant:GetAttribute("LightningOriginallyEnabled") == true
		end
	end
end

local function cloneAsset(instance)
	local clone = instance:Clone()
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
			descendant:SetAttribute("LightningOriginallyEnabled", descendant.Enabled)
		end
	end

	return clone
end

local function createEffect(ligtning)
	local folder = Instance.new("Folder")
	folder.Name = "LightningStrike"
	local asset = cloneAsset(ligtning.Cloud)
	local cloudGlow = ligtning:FindFirstChild("CloudGlow")
	local hitParticles = ligtning:FindFirstChild("HitParticles")
	local glow

	if cloudGlow then
		glow = cloneAsset(cloudGlow)
	end

	local hit

	if hitParticles then
		hit = cloneAsset(hitParticles)
	end

	asset.Parent = folder

	if glow then
		glow.Parent = folder
	end

	if hit then
		hit.Parent = folder
	end

	local attachments = {}
	local beams = {}

	for i = 1, 15 do
		local attachment = Instance.new("Attachment")
		attachment.Parent = asset
		attachments[i] = attachment

		if not (i > 1) then
			continue
		end

		local beam = Instance.new("Beam")
		beam.Attachment0 = attachments[i - 1]
		beam.Attachment1 = attachment
		beam.Transparency = NumberSequence.new(0)
		beam.LightInfluence = 0
		beam.LightEmission = 1
		beam.FaceCamera = true
		beam.Enabled = false
		beam.Parent = asset
		beams[i - 1] = beam
	end

	local part = Instance.new("Part")
	part.Name = "LightningSoundOrigin"
	part.Size = createVector(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Parent = folder
	local lightningSound = ligtning:FindFirstChild("LightningSound")
	local clone

	if lightningSound then
		clone = lightningSound:Clone()
	end

	if clone then
		clone.RollOffMode = Enum.RollOffMode.Linear
		clone.RollOffMinDistance = 10
		clone.RollOffMaxDistance = 200
		clone.Parent = part
	end

	return {
		root = folder,
		cloud = asset,
		glow = glow,
		hit = hit,
		soundPart = part,
		sound = clone,
		attachments = attachments,
		beams = beams,
		impactAt = 0,
		cloudTransparency = asset.Transparency,
		segments = 0,
		active = false,
		impacted = false,
		glowStopped = false,
		hitStopped = false,
		boltStopped = false,
		cloudStopped = false,
		hitCleared = false
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function release(state)
	if state.sound then
		state.sound:Stop()
	end

	setEmission(state.root, false, true)

	for _, beam in state.beams do
		beam.Enabled = false
	end

	state.root.Parent = nil
	state.active = false
end

return {
	create = function(parent)
		local v2 = {}
		local random = Random.new()
		local ligtning = ReplicatedStorage:FindFirstChild("Ligtning")
		local v3

		if ligtning == nil then
			v3 = false
		else
			v3 = ligtning:FindFirstChild("Cloud") ~= nil
		end

		return {
			strike = function(data, p: number)
				local currentCamera = Workspace.CurrentCamera
				local position = (data.cframe * CFrame.new(0, data.size.Y / 2, 0)).Position

				if not v3 or data.impactAt + 1.5 <= p or currentCamera and (currentCamera.CFrame.Position - position).Magnitude > Config.visualDistanceStuds then
					return
				end

				local v4 = nil

				for _, v6 in v2 do
					if v6.active then
						continue
					end

					v4 = v6
					break
				end

				if not v4 and #v2 < v then
					v4 = createEffect(ligtning)
					table.insert(v2, v4)
				end

				if v4 then
					release(v4) -- equivalent call inferred; original call site unknown
					v4.active = true
					v4.impacted = false
					v4.glowStopped = false
					v4.hitStopped = false
					v4.boltStopped = false
					v4.cloudStopped = false
					v4.hitCleared = false
					v4.cloud.Transparency = v4.cloudTransparency
					v4.impactAt = data.impactAt
					v4.segments = random:NextInteger(data.isSuper and 10 or 7, data.isSuper and 15 or 11)
					local v6 = position + createVector(0, 35, 0)
					v4.cloud.CFrame = CFrame.new(v6)

					if v4.glow then
						v4.glow.CFrame = CFrame.new(v6)
					end

					if v4.hit then
						v4.hit.Position = position
					end

					v4.soundPart.Position = position

					if v4.sound then
						v4.sound.Volume = data.isSuper and 1 or 0.6
					end

					local number = random:NextNumber(0.5, 1.3)

					for i = 1, v4.segments do
						local attachment = v4.attachments[i]
						local vector2

						if i == 1 then
							vector2 = createVector(0, 0, 0)
						elseif i == v4.segments then
							vector2 = position - v6
						else
							vector2 = Vector3.new(
								random:NextNumber(-4, 4),
								-(i - 1) * 35 / v4.segments + random:NextNumber(-3, 3),
								random:NextNumber(-4, 4)
							)
						end

						attachment.Position = vector2

						if not (i > 1) then
							continue
						end

						local beam = v4.beams[i - 1]
						beam.Color = ColorSequence.new(data.color)
						beam.Brightness = data.isSuper and 8 or 5
						beam.Width0 = number
						number = math.clamp(number + random:NextNumber(-0.4, 0.2), 0.1, 1)
						beam.Width1 = number
					end

					for _, descendant in v4.cloud:GetDescendants() do
						if descendant:IsA("ParticleEmitter") then
							descendant.Enabled = descendant:GetAttribute("LightningOriginallyEnabled") == true
						elseif descendant:IsA("PointLight") then
							descendant.Enabled = descendant:GetAttribute("LightningOriginallyEnabled") == true
						end
					end

					v4.root.Parent = parent
				end
			end,
			update = function(p: number)
				for _, v4 in v2 do
					if not v4.active then
						continue
					end

					local v5 = p - v4.impactAt

					if v5 >= 5 then
						release(v4) -- equivalent call inferred; original call site unknown
					else
						if v5 >= 0 and not v4.impacted then
							v4.impacted = true

							for _, descendant in v4.cloud:GetDescendants() do
								if descendant:IsA("ParticleEmitter") then
									descendant.Enabled = false
								elseif descendant:IsA("PointLight") then
									descendant.Enabled = false
								end
							end

							if v4.glow then
								for _, descendant in v4.glow:GetDescendants() do
									if descendant:IsA("ParticleEmitter") then
										descendant.Enabled = descendant:GetAttribute("LightningOriginallyEnabled") == true
									elseif descendant:IsA("PointLight") then
										descendant.Enabled = descendant:GetAttribute("LightningOriginallyEnabled") == true
									end
								end
							end

							if v4.hit then
								for _, descendant in v4.hit:GetDescendants() do
									if descendant:IsA("ParticleEmitter") then
										descendant.Enabled = descendant:GetAttribute("LightningOriginallyEnabled") == true
									elseif descendant:IsA("PointLight") then
										descendant.Enabled = descendant:GetAttribute("LightningOriginallyEnabled") == true
									end
								end
							end

							for k, beam in v4.beams do
								beam.Enabled = k < v4.segments
							end

							if v4.sound then
								v4.sound:Play()
							end
						end

						if v5 >= 0.2 and not v4.glowStopped then
							v4.glowStopped = true

							if v4.glow then
								for _, descendant in v4.glow:GetDescendants() do
									if descendant:IsA("ParticleEmitter") then
										descendant.Enabled = false
									elseif descendant:IsA("PointLight") then
										descendant.Enabled = false
									end
								end
							end
						end

						if v5 >= 0.3 and not v4.hitStopped then
							v4.hitStopped = true

							if v4.hit then
								for _, descendant in v4.hit:GetDescendants() do
									if descendant:IsA("ParticleEmitter") then
										descendant.Enabled = false
									elseif descendant:IsA("PointLight") then
										descendant.Enabled = false
									end
								end
							end
						end

						if v5 >= 1.5 and not v4.boltStopped then
							v4.boltStopped = true

							for _, beam in v4.beams do
								beam.Enabled = false
							end

							if v4.glow then
								setEmission(v4.glow, false, true)
							end
						end

						if 3 - Config.strikeWarningSeconds <= v5 and not v4.cloudStopped then
							v4.cloudStopped = true
							v4.cloud.Transparency = 1
							setEmission(v4.cloud, false, true)
						end

						if v5 >= 3 and not v4.hitCleared then
							v4.hitCleared = true

							if v4.hit then
								setEmission(v4.hit, false, true)
							end
						end
					end
				end
			end,
			destroy = function()
				for _, v4 in v2 do
					release(v4) -- equivalent call inferred; original call site unknown
					v4.root:Destroy()
				end

				table.clear(v2)
			end
		}
	end
}