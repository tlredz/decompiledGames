local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local StunCore = require(script.Parent.StunCore)
local StunFx = {
	LOOK = {
		Stars = 3,
		StarImage = "rbxassetid://108718968330364",
		StarFlipbook = {
			Grid = 4,
			CellPixels = 256,
			CropOffset = Vector2.new(54, 64),
			CropPixels = 136,
			Fps = 30
		},
		StarColor = Color3.fromRGB(255, 217, 0),
		StarSize = 0.9,
		StarTransparency = 0.55,
		StarBrightness = 3,
		Twinkle = 0.14,
		TwinkleSpeed = 5,
		StarSpin = 180,
		Lift = 0.3,
		Spin = 2.2,
		Bob = 0.12,
		BobSpeed = 3,
		FadeIn = 0.2,
		FadeOut = 0.35,
		MaxDistance = 150,
		MaxActive = 16,
		Burst = {
			Count = 10,
			Texture = "rbxassetid://241876428",
			Color = ColorSequence.new(Color3.fromRGB(255, 244, 214), Color3.fromRGB(255, 220, 140)),
			LightEmission = 0.4,
			Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) }),
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1) }),
			Lifetime = NumberRange.new(0.5, 0.8),
			Speed = NumberRange.new(2, 4),
			SpreadAngle = Vector2.new(40, 40),
			Acceleration = vector.create(0, 2, 0)
		}
	}
}
local LOOK = StunFx.LOOK
local v = {}
local v2 = 0
local renderSteppedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function headOf(instance)
	return instance:FindFirstChild("Head") or instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rootOf(instance)
	return instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
end

-- equivalent calls inferred from this helper; original call sites unknown
local function positionOf(instance)
	if not instance then
		return nil
	end

	if instance:IsA("Attachment") then
		return instance.WorldPosition
	end

	if instance:IsA("BasePart") then
		return instance.Position
	end

	return nil
end

local Y = 0

local function anchorPoint(instance)
	local debuffWindow = instance:FindFirstChild("DebuffWindow")

	if debuffWindow and debuffWindow:IsA("BillboardGui") then
		local v3 = positionOf(debuffWindow.Adornee) -- equivalent call inferred; original call site unknown
		local v4 = v3 or instance.Position
		Y = debuffWindow.StudsOffset.Y
		return v4 + Vector3.new(0, debuffWindow.StudsOffsetWorldSpace.Y + debuffWindow.StudsOffset.Y, 0)
	else
		local v3 = positionOf(instance:FindFirstChild("StickerOverride")) -- equivalent call inferred; original call site unknown

		if v3 then
			return v3 + Vector3.new(0, Y, 0)
		end

		return instance.Position + Vector3.new(0, Y + 2, 0)
	end
end

local function destroyEffect(k)
	local v3 = v[k]

	if not v3 then
		return
	end

	v[k] = nil
	v2 -= 1

	for _, star in ipairs(v3.stars) do
		star.attachment:Destroy()
	end

	if v2 == 0 and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local function burst(part)
	local burst2 = LOOK.Burst
	local attachment = Instance.new("Attachment")
	attachment.Name = "StunBurst"
	attachment.Parent = part
	attachment.WorldPosition = anchorPoint(part)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = burst2.Texture
	particleEmitter.Color = burst2.Color
	particleEmitter.LightEmission = burst2.LightEmission
	particleEmitter.LightInfluence = 0
	particleEmitter.Size = burst2.Size
	particleEmitter.Transparency = burst2.Transparency
	particleEmitter.Lifetime = burst2.Lifetime
	particleEmitter.Speed = burst2.Speed
	particleEmitter.SpreadAngle = burst2.SpreadAngle
	particleEmitter.Acceleration = burst2.Acceleration
	particleEmitter.Rate = 0
	particleEmitter.Enabled = false
	particleEmitter.Parent = attachment
	particleEmitter:Emit(burst2.Count)
	Debris:AddItem(attachment, burst2.Lifetime.Max + 0.5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flipbookFrameOffset(p)
	local starFlipbook = LOOK.StarFlipbook
	return Vector2.new(p % starFlipbook.Grid, p // starFlipbook.Grid) * starFlipbook.CellPixels + starFlipbook.CropOffset
end

local function buildStar(part, i)
	local attachment = Instance.new("Attachment")
	attachment.Name = "StunStar" .. i
	attachment.Parent = part
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "StunStar"
	billboardGui.Size = UDim2.new(LOOK.StarSize, 0, LOOK.StarSize, 0)
	billboardGui.LightInfluence = 0
	billboardGui.Brightness = LOOK.StarBrightness
	billboardGui.AlwaysOnTop = false
	billboardGui.MaxDistance = LOOK.MaxDistance
	billboardGui.ResetOnSpawn = false
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Image = LOOK.StarImage
	imageLabel.ImageRectSize = Vector2.new(LOOK.StarFlipbook.CropPixels, LOOK.StarFlipbook.CropPixels)
	imageLabel.ImageRectOffset = flipbookFrameOffset(0)
	imageLabel.ImageColor3 = LOOK.StarColor
	imageLabel.ImageTransparency = 1
	imageLabel.Parent = billboardGui
	billboardGui.Parent = attachment
	return {
		attachment = attachment,
		gui = billboardGui,
		image = imageLabel
	}
end

local function step()
	local serverTimeNow = workspace:GetServerTimeNow()
	local now = os.clock()

	for k, v3 in pairs(v) do
		local root = v3.root

		if k.Parent and root.Parent then
			local remaining = StunCore.remaining(v3.endsAt, serverTimeNow)
			local v4 = now - v3.startedAt

			if remaining <= 0 and LOOK.FadeIn <= v4 then
				destroyEffect(k)
			else
				local fade = StunCore.fade(v4, remaining, LOOK.FadeIn, LOOK.FadeOut)
				local v5 = anchorPoint(root) + Vector3.new(0, LOOK.Lift, 0)
				local v6 = LOOK.StarFlipbook.Grid * LOOK.StarFlipbook.Grid
				local v7 = math.floor(v4 * LOOK.StarFlipbook.Fps)

				for i, star in ipairs(v3.stars) do
					local image = star.image
					image.ImageRectOffset = flipbookFrameOffset((v7 + (i - 1) * v6 // #v3.stars) % v6)
					local orbitOffset, v9, v10 = StunCore.orbitOffset(
						i,
						#v3.stars,
						v4,
						v3.radius,
						LOOK.Spin,
						LOOK.Bob,
						LOOK.BobSpeed
					)
					star.attachment.WorldPosition = v5 + Vector3.new(orbitOffset, v9, v10)
					local v11 = LOOK.StarSize * (1 + LOOK.Twinkle * math.sin(v4 * LOOK.TwinkleSpeed + i * 1.7)) * fade
					star.gui.Size = UDim2.new(v11, 0, v11, 0)
					star.image.ImageTransparency = 1 - fade * (1 - LOOK.StarTransparency)
					star.image.Rotation = v4 * LOOK.StarSpin + i * 40
				end
			end
		else
			destroyEffect(k)
		end
	end
end

function StunFx.show(instance, endsAt)
	if typeof(instance) ~= "Instance" or not instance.Parent or typeof(endsAt) ~= "number" then
		return
	end

	local v3 = v[instance]

	if v3 then
		v3.endsAt = math.max(v3.endsAt, endsAt)
		return
	end

	if v2 >= LOOK.MaxActive then
		return
	end

	local part = rootOf(instance) -- equivalent call inferred; original call site unknown

	if not (part and part:IsA("BasePart")) then
		return
	end

	local part2 = headOf(instance) -- equivalent call inferred; original call site unknown
	local v4 = {
		root = part,
		endsAt = endsAt,
		startedAt = os.clock(),
		radius = StunCore.ringRadius(not (part2 and part2:IsA("BasePart")) and 2 or part2.Size.X),
		stars = {}
	}

	for i = 1, LOOK.Stars do
		v4.stars[i] = buildStar(part, i)
	end

	v[instance] = v4
	v2 += 1
	burst(part)

	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(step)
	end
end

function StunFx.hide(p)
	local v3 = v[p]

	if not v3 then
		return
	end

	v3.endsAt = math.min(v3.endsAt, workspace:GetServerTimeNow() + LOOK.FadeOut)
end

function StunFx.isShowing(p)
	return v[p] ~= nil
end

return StunFx