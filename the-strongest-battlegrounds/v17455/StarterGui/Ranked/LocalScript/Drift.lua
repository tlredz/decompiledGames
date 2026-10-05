local RunService = game:GetService("RunService")
local Drift = {}
Drift.__index = Drift
local v = {}

local function isVisible(guiObject)
	if not guiObject.Visible or (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) and guiObject.ImageTransparency and guiObject.ImageTransparency >= 1 then
		return false
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function smoothAlpha(dt: number, halfLife: number)
	if halfLife <= 0 then
		return 1
	end

	return 1 - math.exp(dt * -0.6931471805599453 / halfLife)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function defaultOpts()
	return {
		style = "sine",
		speed = 0.3,
		amplitude = 0.18,
		autoScale = true,
		bleed = 0.18,
		pauseWhenInvisible = true,
		halfLife = 0.12,
		noiseFreq = 0.8
	}
end

local function ensureState(instance, options)
	if v[instance] then
		return v[instance]
	end

	local imageLabel = instance:FindFirstChildOfClass("ImageLabel")

	if not imageLabel then
		error("PanInsideMask: Mask has no ImageLabel child")
	end

	local opts = defaultOpts() -- equivalent call inferred; original call site unknown

	for k, v3 in pairs(options or {}) do
		opts[k] = v3
	end

	local v3 = {
		mask = instance,
		image = imageLabel,
		opts = opts,
		t = 0,
		seedX = math.random() * 1000,
		seedY = math.random() * 1000,
		maskSize = Vector2.zero,
		imgSize = Vector2.zero,
		maxPx = Vector2.zero,
		targetN = Vector2.zero,
		smoothN = Vector2.zero,
		conn = nil,
		maskSizeConn = nil,
		imgSizeConn = nil
	}
	v[instance] = v3
	local flag = false

	local function recompute()
		local absoluteSize = instance.AbsoluteSize

		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end

		if opts.autoScale then
			local v4 = absoluteSize.X * (1 + opts.bleed * 2)
			local v5 = absoluteSize.Y * (1 + opts.bleed * 2)
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.Size = UDim2.fromOffset(v4, v5)
		end

		v3.maskSize = Vector2.new(instance.AbsoluteSize.X, instance.AbsoluteSize.Y)
		v3.imgSize = Vector2.new(imageLabel.AbsoluteSize.X, imageLabel.AbsoluteSize.Y)
		v3.maxPx = Vector2.new(math.max(0, v3.imgSize.X - v3.maskSize.X), (math.max(0, v3.imgSize.Y - v3.maskSize.Y))) * opts.amplitude
	end

	local function scheduleRecompute()
		if flag then
			return
		end

		flag = true
		RunService.Heartbeat:Once(function()
			flag = false
			local _ = v3.maxPx
			recompute()
		end)
	end

	recompute()
	v3.maskSizeConn = instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(scheduleRecompute)
	v3.imgSizeConn = imageLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(scheduleRecompute)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stepSine(dt: number)
		v3.t += dt * v3.opts.speed
		return Vector2.new(math.sin(v3.t * 1.2), (math.cos(v3.t * 0.9)))
	end

	local function p1(p: number, p2: number)
		return math.noise(p + p2)
	end

	local function stepJitter(p: number)
		v3.t += p * v3.opts.speed
		local noiseFreq = v3.opts.noiseFreq
		local v5 = v3.t * noiseFreq
		local seedX = v3.seedX
		local v6 = math.noise(v5 + seedX) * 2
		local v7 = v3.t * noiseFreq
		local seedY = v3.seedY
		return Vector2.new(v6, math.noise(v7 + seedY) * 2)
	end

	v3.conn = RunService.Heartbeat:Connect(function(dt)
		if not instance.Parent then
			Drift.Stop(instance)
			return
		end

		if v3.opts.pauseWhenInvisible then
			local guiObject = instance
			local v4

			if guiObject.Visible then
				v4 = not (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) or not (guiObject.ImageTransparency and guiObject.ImageTransparency >= 1)
			else
				v4 = false
			end

			if not v4 then
				return
			end
		end

		if v3.maskSize.X <= 0 or v3.maskSize.Y <= 0 then
			return
		end

		if v3.opts.style == "jitter" then
			local v4 = v3
			v3.t += dt * v3.opts.speed
			local noiseFreq = v3.opts.noiseFreq
			local v6 = v3.t * noiseFreq
			local seedX = v3.seedX
			local v7 = math.noise(v6 + seedX) * 2
			local v8 = v3.t * noiseFreq
			local seedY = v3.seedY
			v4.targetN = Vector2.new(v7, math.noise(v8 + seedY) * 2)
		else
			v3.targetN = stepSine(dt)
		end

		v3.targetN = Vector2.new(math.clamp(v3.targetN.X, -1, 1), (math.clamp(v3.targetN.Y, -1, 1)))
		local v4 = smoothAlpha(dt, v3.opts.halfLife) -- equivalent call inferred; original call site unknown
		v3.smoothN += (v3.targetN - v3.smoothN) * v4
		local v5 = v3.smoothN.X * v3.maxPx.X
		local v6 = v3.smoothN.Y * v3.maxPx.Y
		local v7 = v3.maskSize.X == 0 and 0 or v5 / v3.maskSize.X or 0
		local v8 = v3.maskSize.Y == 0 and 0 or v6 / v3.maskSize.Y or 0
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(0.5 + v7, 0.5 + v8)
	end)
	return v3
end

function Drift.Start(mask, items)
	local v2 = v[mask]

	if not v2 then
		ensureState(mask, items)
	elseif items then
		for k, item in pairs(items) do
			v2.opts[k] = item
		end
	end
end

function Drift.Stop(p)
	local v2 = v[p]

	if not v2 then
		return false
	end

	if v2.conn then
		v2.conn:Disconnect()
	end

	if v2.maskSizeConn then
		v2.maskSizeConn:Disconnect()
	end

	if v2.imgSizeConn then
		v2.imgSizeConn:Disconnect()
	end

	v[p] = nil
	return true
end

return Drift