local RunService = game:GetService("RunService")
local parent = script.Parent
local eMPChargeBar = parent:WaitForChild("EMPChargeBar")
local barHolder = eMPChargeBar:WaitForChild("BarHolder")
local icon = barHolder:WaitForChild("Icon")
local glowImage = icon:WaitForChild("GlowImage")
local progressHolder = barHolder:WaitForChild("ProgressHolder")
local barBG = barHolder:WaitForChild("BarBG")
local bar = barBG:WaitForChild("Bar")
local phantomBar = barBG:WaitForChild("PhantomBar")
local decor = barBG:WaitForChild("Decor")
local frame = eMPChargeBar:WaitForChild("Frame")
local v = {
	LIGHTNING_AT = 30,
	BAR_LIGHTNING = true,
	REARM_BELOW = 99,
	FILL_SPEED = 9,
	TEXT_HZ = 20,
	KICK_DEGREES = 1.6,
	KICK_FULL_DEGREES = 4,
	KICK_MAX_DEGREES = 5,
	KICK_HZ = 6.5,
	KICK_DAMPING = 0.3,
	KICK_MIN_GAP = 0.08,
	TREMBLE_PX = { 1, 3.5 },
	TREMBLE_DEGREES = { 2, 6 },
	TREMBLE_HZ = 30,
	FLICKER = { 0.04, 0.05, 0.035 },
	FLICKER_FULL = {
		0.06,
		0.04,
		0.05,
		0.05,
		0.035,
		0.07,
		0.09
	},
	FLICKER_MIN_GAP = 0.22,
	ENERGY_CORE_COLOR = Color3.fromRGB(0, 170, 255),
	ENERGY_LINE_COLOR = Color3.fromRGB(200, 250, 255),
	ENERGY_CORE_TRANSPARENCY = 0.72,
	ENERGY_LINE_TRANSPARENCY = 0.2,
	ENERGY_LINE_WIDTH = 0.06,
	ENERGY_EMPTY = 0.1,
	ENERGY_FULL = 1.08,
	GLOW_REST = 0.15,
	HALO_COLOR = Color3.fromRGB(70, 210, 255),
	HALO_SCALE = 1.16,
	HALO_EMPTY = 0.92,
	HALO_FULL = 0.4,
	LINE_TOP = 0.92,
	HUM = 0.06,
	HUM_HZ = 1.6,
	SURGE = 0.35,
	SURGE_FULL = 0.7,
	SURGE_DECAY = 5
}
local random = Random.new()
local v2 = parent:FindFirstChild("Fired")

if not (v2 and v2:IsA("BindableEvent")) then
	v2 = Instance.new("BindableEvent")
	v2.Name = "Fired"
	v2.Parent = parent
end

local v3 = nil

for _, label in frame:GetChildren() do
	if not (label:IsA("TextLabel") and (not v3 or label.Position.Y.Scale > v3.Position.Y.Scale)) then
		continue
	end

	v3 = label
end

local ENERGY_LINE_WIDTH = v.ENERGY_LINE_WIDTH
local uIGradient = glowImage:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
uIGradient.Rotation = -90
uIGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, v.ENERGY_CORE_COLOR),
	ColorSequenceKeypoint.new(0.5 - ENERGY_LINE_WIDTH, v.ENERGY_CORE_COLOR),
	ColorSequenceKeypoint.new(0.49, v.ENERGY_LINE_COLOR),
	ColorSequenceKeypoint.new(1, v.ENERGY_LINE_COLOR)
})
uIGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, v.ENERGY_CORE_TRANSPARENCY),
	NumberSequenceKeypoint.new(0.5 - ENERGY_LINE_WIDTH, v.ENERGY_CORE_TRANSPARENCY),
	NumberSequenceKeypoint.new(0.485, v.ENERGY_LINE_TRANSPARENCY),
	NumberSequenceKeypoint.new(0.52, 1),
	NumberSequenceKeypoint.new(1, 1)
})
uIGradient.Parent = glowImage
glowImage.ImageColor3 = Color3.new(1, 1, 1)
local imageLabel = Instance.new("ImageLabel")
imageLabel.Name = "EnergyHalo"
imageLabel.BackgroundTransparency = 1
imageLabel.Image = glowImage.Image
imageLabel.ScaleType = glowImage.ScaleType
imageLabel.ImageColor3 = v.HALO_COLOR
imageLabel.ImageTransparency = 1
imageLabel.AnchorPoint = icon.AnchorPoint
imageLabel.Position = icon.Position
imageLabel.Size = UDim2.new(
	icon.Size.X.Scale * v.HALO_SCALE,
	icon.Size.X.Offset * v.HALO_SCALE,
	icon.Size.Y.Scale * v.HALO_SCALE,
	icon.Size.Y.Offset * v.HALO_SCALE
)
imageLabel.ZIndex = icon.ZIndex - 1
imageLabel.Visible = false
imageLabel.Parent = barHolder
local rotation = barHolder.Rotation
local position = icon.Position
local rotation2 = icon.Rotation
local Y = bar.Size.Y
local Y2 = phantomBar.Size.Y

local function buildOffsets(state)
	local X = state.cells.X
	local imageRectSize = state.image.ImageRectSize
	local vectors = table.create(state.frames)

	for i = 0, state.frames - 1 do
		vectors[i + 1] = Vector2.new(imageRectSize.X * (i % X), imageRectSize.Y * math.floor(i / X))
	end

	state.offsets = vectors
end

local function makeSheet(instance, cells, FPS)
	local cells2 = cells or Vector2.new(1, 1)
	instance.Visible = false
	instance.ImageRectOffset = Vector2.zero
	return {
		image = instance,
		cells = cells2,
		offsets = nil,
		frames = math.max(1, cells2.X * cells2.Y),
		frameTime = 1 / (FPS or 24),
		frame = 1,
		acc = 0,
		on = false,
		startAt = instance:GetAttribute("StartAt") or v.LIGHTNING_AT
	}
end

local v4 = {}
local sheets = {}
local v5 = nil
local v6 = nil

for _, descendant in eMPChargeBar:GetDescendants() do
	if descendant:IsA("LocalScript") and descendant.Name == "PlaySprite" then
		descendant.Enabled = false
	end

	if v4[descendant.Parent] and descendant:IsA("LocalScript") then
		continue
	end

	if descendant:IsA("ImageLabel") and descendant:GetAttribute("ChargeLine") and descendant:IsDescendantOf(icon) then
		v4[descendant] = true
		local localScript = descendant:FindFirstChildOfClass("LocalScript")

		if localScript then
			localScript.Enabled = false
		end

		local v7 = localScript and localScript:GetAttribute("Cells") and localScript or descendant
		v5 = makeSheet(descendant, v7:GetAttribute("Cells"), v7:GetAttribute("FPS"))
	elseif descendant:IsA("LocalScript") and descendant:GetAttribute("Cells") and descendant.Parent:IsA("ImageLabel") and not descendant.Parent:GetAttribute("ChargeLine") then
		descendant.Enabled = false
		local parent2 = descendant.Parent
		v4[parent2] = true
		local sheet = makeSheet(parent2, descendant:GetAttribute("Cells"), descendant:GetAttribute("FPS"))

		if parent2:IsDescendantOf(bar) then
			v6 = sheet
		elseif parent2:IsDescendantOf(icon) or v.BAR_LIGHTNING then
			table.insert(sheets, sheet)
		end
	end
end

local X = v5 and v5.image.Position.X
local v7 = nil
local v8 = nil

local function buildTremble()
	local v9 = table.create(4)
	local v10 = table.create(4)
	v7 = v9
	v8 = v10
	local X2 = icon.AbsoluteSize.X

	for i = 1, 4 do
		local v11 = (i - 1) / 3
		local v12 = X2 * (v.TREMBLE_PX[1] + (v.TREMBLE_PX[2] - v.TREMBLE_PX[1]) * v11) / 100
		local v13 = v.TREMBLE_DEGREES[1] + (v.TREMBLE_DEGREES[2] - v.TREMBLE_DEGREES[1]) * v11
		local v14 = table.create(12)
		local v15 = table.create(12)

		for i2 = 1, 12 do
			local v16 = i2 / 12 * 3.141592653589793 * 2 + random:NextNumber(-0.4, 0.4)
			local v17 = v12 * random:NextNumber(0.45, 1)
			v14[i2] = position + UDim2.fromOffset(math.round(math.cos(v16) * v17), (math.round(math.sin(v16) * v17)))
			v15[i2] = rotation2 + v13 * random:NextNumber(-1, 1)
		end

		local v16 = v8
		v7[i] = v14
		v16[i] = v15
	end
end

local parent2 = icon
local parents = {}

while parent2 do
	table.insert(parents, parent2)

	if parent2:IsA("LayerCollector") then
		break
	else
		parent2 = parent2.Parent
	end
end

local v9 = false
local heartbeatConnection = nil
local v10 = 0
local v11 = 0
local v12 = true
local flag = false
local X2 = barBG.AbsoluteSize.X
local v13 = -1
local v14 = nil
local total = 0
local v15 = nil
local total2 = 0
local v16 = 0
local v17 = 0
local v18 = -1
local v19 = nil
local v20 = 0
local v21 = 0
local v22 = false
local v23 = -1
local SURGE_FULL = 0
local total3 = 0
local v24 = -1
local v25 = -1
local v26 = -1
local v27 = false
local v28 = 0
local v29 = 1
local v30 = -1
local clone = table.clone(sheets)

if v6 then
	table.insert(clone, v6)
end

if v5 then
	table.insert(clone, v5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeFill(p)
	local v31 = math.round(v11 * X2)

	if p or v31 ~= v13 then
		v13 = v31
		bar.Size = UDim2.new(v11, 0, Y.Scale, Y.Offset)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writePhantom()
	phantomBar.Size = UDim2.new(v10, 0, Y2.Scale, Y2.Offset)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writePercent()
	local text = string.format("%.2f%%", v11 * 100)

	if text ~= v14 then
		v14 = text
		progressHolder.Text = text
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeTimer()
	local timeLeft = parent:GetAttribute("TimeLeft")

	if type(timeLeft) ~= "number" or not v3 then
		return
	end

	local v31 = math.max(0, (math.floor(timeLeft)))
	local text = string.format("%02d:%02d", v31 // 60, v31 % 60)

	if text ~= v15 then
		v15 = text
		v3.Text = text
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSheet(state, p)
	if state.on == p then
		return
	end

	state.on = p
	state.image.Visible = p

	if p then
		if not state.offsets then
			buildOffsets(state)
		end

		state.frame = 1
		state.acc = 0
		state.image.ImageRectOffset = state.offsets[1]
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setDecorOff(p)
	if p == v22 then
		return
	end

	v22 = p
	decor.Visible = not p
end

local function writeEnergy(p)
	local v31 = v.ENERGY_EMPTY + (v.ENERGY_FULL - v.ENERGY_EMPTY) * v11

	if p or math.abs(v31 - v24) >= 0.002 then
		v24 = v31
		uIGradient.Offset = Vector2.new(0, 0.5 - v31)

		if v5 then
			v5.image.Position = UDim2.new(X.Scale, X.Offset, 1 - math.min(v31, v.LINE_TOP), 0)
		end
	end

	if v5 then
		setSheet(v5, v11 > 0 and v11 < 1) -- equivalent call inferred; original call site unknown
	end

	local v32 = v27 and v.HUM * math.sin(total3 * v.HUM_HZ * 3.141592653589793 * 2) or 0
	local imageTransparency = math.clamp(v.GLOW_REST * (1 - SURGE_FULL) + v32, 0, 1)

	if p or math.abs(imageTransparency - v25) >= 0.01 then
		v25 = imageTransparency
		glowImage.ImageTransparency = imageTransparency
	end

	local v34 = v.HALO_EMPTY + (v.HALO_FULL - v.HALO_EMPTY) * v11
	local imageTransparency2 = math.clamp(v34 - SURGE_FULL * (v34 - 0.1) + v32, 0, 1)

	if p or math.abs(imageTransparency2 - v26) >= 0.01 then
		v26 = imageTransparency2
		imageLabel.ImageTransparency = imageTransparency2
	end

	local visible = v11 > 0

	if p or glowImage.Visible ~= visible then
		glowImage.Visible = visible
		imageLabel.Visible = visible
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTremble(p)
	if v27 == p then
		return
	end

	v27 = p
	v28 = 0

	if not p then
		icon.Position = position
		icon.Rotation = rotation2
	end
end

local function rest()
	total2 = 0
	v16 = 0
	v17 = 0
	barHolder.Rotation = rotation
	v19 = nil

	if v22 ~= false then
		v22 = false
		decor.Visible = true
	end

	SURGE_FULL = 0
	total3 = 0
	setTremble(false) -- equivalent call inferred; original call site unknown

	for _, v31 in clone do
		setSheet(v31, false) -- equivalent call inferred; original call site unknown
		v31.offsets = nil
	end

	glowImage.Visible = false
	imageLabel.Visible = false
	v7 = nil
	v8 = nil
	v30 = -1
	v24 = -1
	v25 = -1
	v26 = -1
	v13 = -1
	v14 = nil
end

local v31 = v.KICK_HZ * 2 * 3.141592653589793

local function step(p)
	local v32 = p > 0.1 and 0.1 or p
	local v33

	if v11 == v10 then
		v33 = false
	else
		v11 += (v10 - v11) * (1 - math.exp(-v.FILL_SPEED * v32))

		if math.abs(v10 - v11) < 0.0004 then
			v11 = v10
		end

		writeFill(false) -- equivalent call inferred; original call site unknown
		total += v32

		if v11 == v10 or total >= 1 / v.TEXT_HZ then
			total = 0
			local text = string.format("%.2f%%", v11 * 100)

			if text ~= v14 then
				v14 = text
				progressHolder.Text = text
			end
		end

		v33 = true
	end

	if total2 ~= 0 or v16 ~= 0 then
		local v34 = math.ceil(v32 * 120)
		local v35 = v32 / v34
		local v36 = v31
		local KICK_DAMPING = v.KICK_DAMPING

		for _ = 1, v34 do
			v16 += (-v36 * v36 * total2 - 2 * KICK_DAMPING * v36 * v16) * v35
			total2 += v16 * v35
		end

		if math.abs(total2) < 0.02 and math.abs(v16) < 0.3 then
			total2 = 0
			v16 = 0
		end

		if math.abs(total2 - v17) >= 0.02 or total2 == 0 then
			v17 = total2
			barHolder.Rotation = rotation + total2
		end

		v33 = true
	end

	if v19 then
		v21 -= v32

		while v19 and v21 <= 0 do
			v20 += 1
			local v34 = v19[v20]

			if v34 then
				v21 += v34
				setDecorOff(v20 % 2 == 1) -- equivalent call inferred; original call site unknown
			else
				v19 = nil

				if v22 ~= false then
					v22 = false
					decor.Visible = true
				end
			end
		end

		v33 = true
	end

	local v34 = v11 * 100

	if v34 ~= v30 then
		v30 = v34
		setTremble(v.LIGHTNING_AT <= v34) -- equivalent call inferred; original call site unknown

		for _, v36 in sheets do
			setSheet(v36, v36.startAt <= v34) -- equivalent call inferred; original call site unknown
		end

		if v6 then
			setSheet(v6, v11 > 0) -- equivalent call inferred; original call site unknown
		end
	end

	local v35 = SURGE_FULL > 0 or (v27 or v24 < 0)

	if SURGE_FULL > 0 then
		SURGE_FULL *= math.exp(-v.SURGE_DECAY * v32)

		if SURGE_FULL < 0.01 then
			SURGE_FULL = 0
		end
	end

	if v27 then
		total3 += v32
	else
		total3 = 0
	end

	if v35 or v33 then
		writeEnergy(false)
	end

	local v36 = SURGE_FULL > 0 or v33

	if v27 then
		v28 += v32

		if v28 >= 1 / v.TREMBLE_HZ then
			v28 %= 1 / v.TREMBLE_HZ
			local v37 = math.clamp(math.floor((v34 - v.LIGHTNING_AT) / (100 - v.LIGHTNING_AT) * 3 + 0.5) + 1, 1, 4)
			v29 = (v29 + random:NextInteger(3, 9) - 1) % 12 + 1
			icon.Position = v7[v37][v29]
			icon.Rotation = v8[v37][v29]
		end

		v36 = true
	end

	for _, v37 in clone do
		if not v37.on then
			continue
		end

		v36 = true
		local acc = v37.acc + v32
		local frameTime = v37.frameTime

		if frameTime <= acc then
			local v39 = acc // frameTime
			acc -= v39 * frameTime
			v37.frame = (v37.frame - 1 + v39) % v37.frames + 1
			v37.image.ImageRectOffset = v37.offsets[v37.frame]
		end

		v37.acc = acc
	end

	if not v36 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wake()
	if v9 and not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(step)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function kick(p)
	local v32 = random:NextNumber() < 0.5 and -1 or 1
	local v33 = v.KICK_MAX_DEGREES * v31 / 0.7
	v16 = math.clamp(v16 + v32 * p * random:NextNumber(0.8, 1) * v31 / 0.7, -v33, v33)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flicker(list)
	v19 = list
	v20 = 1
	v21 = list[1]

	if v22 == true then
		return
	end

	v22 = true
	decor.Visible = false
end

local function onCharged(p)
	if not v9 then
		return
	end

	local now = os.clock()

	if p then
		v18 = now
		v23 = now
		kick(v.KICK_FULL_DEGREES) -- equivalent call inferred; original call site unknown
		flicker(v.FLICKER_FULL) -- equivalent call inferred; original call site unknown
		SURGE_FULL = v.SURGE_FULL
	else
		if now - v18 >= v.KICK_MIN_GAP then
			v18 = now
			kick(v.KICK_DEGREES) -- equivalent call inferred; original call site unknown
		end

		SURGE_FULL = math.max(SURGE_FULL, v.SURGE)

		if not v19 and now - v23 >= v.FLICKER_MIN_GAP then
			v23 = now
			flicker(v.FLICKER) -- equivalent call inferred; original call site unknown
		end
	end

	wake() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function readCharge()
	local charge = parent:GetAttribute("Charge")

	if type(charge) == "number" and charge == charge then
		return math.clamp(charge, 0, 100) / 100
	end

	return nil
end

local function onChargeChanged()
	local charge = readCharge() -- equivalent call inferred; original call site unknown

	if not charge then
		return
	end

	if flag then
		if charge == v10 then
			return
		end

		local v33 = v10 < charge
		v10 = charge

		if charge < v.REARM_BELOW / 100 then
			v12 = true
		end

		local v34 = v12 and charge >= 1

		if v34 then
			v12 = false
			v2:Fire()
		end

		if not v9 then
			return
		end

		writePhantom() -- equivalent call inferred; original call site unknown

		if v33 then
			onCharged(v34)
		end

		wake() -- equivalent call inferred; original call site unknown
	else
		flag = true
		v10 = charge
		v11 = charge
		v12 = charge < v.REARM_BELOW / 100

		if v9 then
			writePhantom() -- equivalent call inferred; original call site unknown
			v13 = math.round(v11 * X2)
			bar.Size = UDim2.new(v11, 0, Y.Scale, Y.Offset)
			writePercent() -- equivalent call inferred; original call site unknown
			writeEnergy(true)
			wake() -- equivalent call inferred; original call site unknown
		end
	end
end

local function isShown()
	if not parent.Parent then
		return false
	end

	for _, layerCollector in parents do
		if layerCollector:IsA("LayerCollector") then
			if not layerCollector.Enabled then
				return false
			end
		elseif not layerCollector.Visible then
			return false
		end
	end

	return true
end

local function refreshGate()
	local shown = isShown()

	if shown == v9 then
		return
	end

	v9 = shown

	if v9 then
		buildTremble()
		v11 = v10
		v13 = math.round(v11 * X2)
		bar.Size = UDim2.new(v11, 0, Y.Scale, Y.Offset)
		writePhantom() -- equivalent call inferred; original call site unknown
		writePercent() -- equivalent call inferred; original call site unknown
		writeTimer() -- equivalent call inferred; original call site unknown
		writeEnergy(true)
		wake() -- equivalent call inferred; original call site unknown
	else
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end

		rest()
	end
end

local charge2 = readCharge() -- equivalent call inferred; original call site unknown

if charge2 then
	flag = true
	v10 = charge2
	v11 = charge2

	if charge2 < v.REARM_BELOW / 100 then
		v12 = true
	else
		v12 = false
	end
end

local connections = {
	parent:GetAttributeChangedSignal("Charge"):Connect(onChargeChanged),
	parent:GetAttributeChangedSignal("TimeLeft"):Connect(function()
		if v9 then
			local timeLeft = parent:GetAttribute("TimeLeft")

			if type(timeLeft) == "number" then
				if not v3 then
					return
				end

				local v33 = math.max(0, (math.floor(timeLeft)))
				local text = string.format("%02d:%02d", v33 // 60, v33 % 60)

				if text ~= v15 then
					v15 = text
					v3.Text = text
				end
			end
		end
	end),
	barBG:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		X2 = barBG.AbsoluteSize.X
	end),
	icon:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if v9 then
			buildTremble()
		end
	end)
}

for _, layerCollector in parents do
	table.insert(
		connections,
		layerCollector:GetPropertyChangedSignal(layerCollector:IsA("LayerCollector") and "Enabled" or "Visible"):Connect(refreshGate)
	)
end

table.insert(connections, parent.AncestryChanged:Connect(refreshGate))
v13 = math.round(v11 * X2)
bar.Size = UDim2.new(v11, 0, Y.Scale, Y.Offset)
writePhantom() -- equivalent call inferred; original call site unknown
writePercent() -- equivalent call inferred; original call site unknown
writeTimer() -- equivalent call inferred; original call site unknown
refreshGate()
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	v9 = false
	rest()
	imageLabel:Destroy()
end)