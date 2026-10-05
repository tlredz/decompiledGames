local createVector = vector.create
local RunService = game:GetService("RunService")

local function resolveHost(player)
	local character = player.Character

	if typeof(character) ~= "Instance" or not character:IsA("Model") then
		character = nil
	end

	local root = player.Root

	if typeof(root) == "Instance" and root:IsA("BasePart") then
		return root, character
	end

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			return humanoidRootPart, character
		end
	end

	return nil, character
end

local function buildMotes(color: Color3, p: number)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "Motes"
	particleEmitter.Color = ColorSequence.new(color)
	particleEmitter.LightEmission = 0.85
	particleEmitter.LightInfluence = 0
	particleEmitter.Lifetime = NumberRange.new(0.9, 1.6)
	particleEmitter.Rate = 0
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-45, 45)
	particleEmitter.Speed = NumberRange.new(2, 5)
	particleEmitter.SpreadAngle = Vector2.new(14, 14)
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Acceleration = createVector(0, 3, 0)
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.25, p * 0.3),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.15),
		NumberSequenceKeypoint.new(1, 1)
	})
	return particleEmitter
end

local function buildWisps(color: Color3, p: number)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "Wisps"
	particleEmitter.Color = ColorSequence.new(color)
	particleEmitter.LightEmission = 0.55
	particleEmitter.LightInfluence = 0
	particleEmitter.Lifetime = NumberRange.new(1.6, 2.6)
	particleEmitter.Rate = 0
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-14, 14)
	particleEmitter.Speed = NumberRange.new(0.75, 2.25)
	particleEmitter.SpreadAngle = Vector2.new(26, 26)
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Acceleration = createVector(0, 1.2, 0)
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.4, p * 1.1),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.45, 0.72),
		NumberSequenceKeypoint.new(1, 1)
	})
	return particleEmitter
end

return function(data)
	if not data then
		return
	end

	local host, v = resolveHost(data)

	if not host then
		return
	end

	local v2 = os.clock() + (data.Duration or 4)
	local bossPrimedAura = host:FindFirstChild("BossPrimedAura")

	if bossPrimedAura then
		bossPrimedAura:SetAttribute("Until", data.Remove and 0 or v2)
		return
	end

	if data.Remove then
		return
	end

	local color

	if typeof(data.Color) == "Color3" then
		color = data.Color
	else
		color = Color3.fromRGB(255, 200, 60)
	end

	local cFrame = host.CFrame
	local v3 = host.Size * 2

	if v then
		local success, result, v4 = pcall(function()
			return v:GetBoundingBox()
		end)

		if success and typeof(result) == "CFrame" and typeof(v4) == "Vector3" then
			cFrame = result
			v3 = v4
		end
	end

	local size = v3 * 0.85
	local v5 = math.clamp(math.max(size.X, size.Z) / 4, 0.6, 3)
	local part = Instance.new("Part")
	part.Name = "BossPrimedAura"
	part.Size = size
	part.CFrame = cFrame
	part.Transparency = 1
	part.Massless = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Locked = true
	part:SetAttribute("Until", v2)
	local motes = buildMotes(color, v5)
	motes.Parent = part
	local wisps = buildWisps(color, v5)
	wisps.Parent = part
	part.Parent = host
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = host
	weldConstraint.Part1 = part
	weldConstraint.Parent = part
	task.spawn(function()
		local now = os.clock()

		while part.Parent and host.Parent do
			local now2 = os.clock()
			local attribute = part:GetAttribute("Until")

			if typeof(attribute) ~= "number" or attribute <= now2 then
				break
			end

			local v6 = math.clamp((now2 - now) / 0.6, 0, 1)
			motes.Rate = v6 * 26
			wisps.Rate = v6 * 7
			RunService.Heartbeat:Wait()
		end

		motes.Rate = 0
		wisps.Rate = 0
		task.wait(math.max(motes.Lifetime.Max, wisps.Lifetime.Max) + 0.5)

		if part.Parent then
			part:Destroy()
		end
	end)
end