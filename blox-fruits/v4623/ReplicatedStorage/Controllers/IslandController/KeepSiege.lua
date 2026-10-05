local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CannonIdle = require(game.ReplicatedStorage.Controllers.IslandController.CannonIdle)
local Effect = require(game.ReplicatedStorage.Effect)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Util = require(game.ReplicatedStorage.Util)
local frozen = table.freeze({
	ISLAND_MODEL = "MarineBase",
	LOCATIONS_NAME = "BonusMoment_Locations",
	MAIN_BASE_NAME = "MainBase",
	DESTRUCTIBLE_NAME = "Destructible",
	CAROUSEL_NAME = "MainCannons",
	TIER_NAMES = { "1", "2", "3" },
	ARMED_ATTRIBUTE = "KeepSiegeArmed",
	ARMED_AT_ATTRIBUTE = "KeepSiegeArmedAt",
	ACTIVE_ATTRIBUTE = "KeepSiegeActive",
	DAMAGE_ATTRIBUTE = "KeepSiegeDamage",
	HITS_ATTRIBUTE = "KeepSiegeHits",
	FELL_ATTRIBUTE = "KeepSiegeFellAt",
	WRECKED_ATTRIBUTE = "KeepSiegeWreckedAt",
	IMPACT_ATTRIBUTE = "KeepSiegeImpact",
	HIT_AT_ATTRIBUTE = "KeepSiegeHitAt",
	HIT_IMPACT_ATTRIBUTE = "KeepSiegeHitImpact",
	HIT_POWER_ATTRIBUTE = "KeepSiegeHitPower",
	IDLE_COLOR = Color3.fromRGB(255, 168, 62),
	HIT_COLOR = Color3.fromRGB(236, 74, 46),
	DUST_COLOR = Color3.fromRGB(168, 152, 132),
	SMOKE_COLOR = Color3.fromRGB(48, 42, 38),
	PULSE_PERIOD = 1.6,
	FILL_RANGE = NumberRange.new(0.5, 0.78),
	OUTLINE_RANGE = NumberRange.new(0, 0.32),
	RETICLE_IMAGE = "rbxassetid://74338464342669",
	RETICLE_COLOR = Color3.fromRGB(236, 74, 46),
	RETICLE_SIZE = 72,
	MARKER_MAX_DISTANCE = 900,
	BUSTER_CANNON_NAME = "MarineBusterCannon",
	BUSTER_SEAT_NAME = "Seat",
	BUSTER_SCAN_INTERVAL = 4,
	BUSTER_COLOR = Color3.fromRGB(122, 206, 255),
	BUSTER_FILL_RANGE = NumberRange.new(0.58, 0.88),
	BUSTER_OUTLINE_RANGE = NumberRange.new(0.05, 0.42),
	BUSTER_PULSE_PERIOD = 1.15,
	BUSTER_MAX_DISTANCE = 420,
	BUSTER_HEIGHT = 8,
	BUSTER_BOB = 0.8,
	BUSTER_PROMPT_WIDTH = 230,
	BUSTER_PROMPT_HEIGHT = 40,
	BUSTER_PROMPT_FONT = "rbxasset://fonts/families/HighwayGothic.json",
	BUSTER_PROMPT_TITLE = "MAN THE CANNON",
	BUSTER_PROMPT_SIZE = 34,
	BUSTER_PROMPT_STROKE = 2.5,
	SHAKE_DURATION = 0.9,
	SHAKE_AMPLITUDE = NumberRange.new(2.6, 5),
	SHAKE_FREQUENCY = 11,
	SHAKE_DAMPING = 9,
	SHAKE_HEAVE_FREQUENCY = 2.6,
	SHAKE_HEAVE_DAMPING = 3.4,
	SHAKE_HEAVE_MIX = 1.15,
	SHAKE_SWAY = 0.4,
	SHAKE_SWAY_DETUNE = 1.37,
	SHAKE_LIFT = 0.3,
	SHAKE_TWIST = 0.027925268031909273,
	SHAKE_FALLOFF = 0.7,
	SHAKE_CAMERA = NumberRange.new(4.5, 9),
	SHAKE_CAMERA_ROUGHNESS = 8,
	SHAKE_CAMERA_FADE = 0.7,
	SHAKE_CAMERA_RANGE = 700,
	COLLAPSE_SHUDDER = 0.55,
	COLLAPSE_FALL = 1.7,
	COLLAPSE_JITTER = 1.8,
	COLLAPSE_TILT = NumberRange.new(0.12217304763960307, 0.2617993877991494),
	COLLAPSE_TWIST = 0.12217304763960307,
	COLLAPSE_SINK = 0.94,
	COLLAPSE_SLIDE = 0.24,
	COLLAPSE_FADE_START = 0.55,
	COLLAPSE_DUST_INTERVAL = 0.16,
	COLLAPSE_DUST_SIZE = 120,
	COLLAPSE_SHAKE = 11,
	STUMP_FIRES = 5,
	SHATTER_MAX = 30,
	SHATTER_PER_PART = 7,
	SHATTER_SCALE = NumberRange.new(0.04, 0.11),
	SHATTER_SIZE = NumberRange.new(4, 22),
	SHATTER_SPEED = NumberRange.new(55, 130),
	SHATTER_LIFT = NumberRange.new(35, 90),
	SHATTER_SPIN = 9,
	SHATTER_FADE = 2.4,
	SHATTER_LIFETIME = 3.4,
	POLL_INTERVAL = 0.4,
	ALARM_COLOR = Color3.fromRGB(180, 20, 20),
	ALARM_PEAK = 0.65,
	ALARM_RISE = 0.2,
	ALARM_HOLD = 0.28,
	ALARM_FALL = 0.35,
	ALARM_SPACING = 0.42,
	ALARM_PULSES = 3,
	ALARM_GAP = 3.5,
	ALARM_DISPLAY_ORDER = 40
})
local flag = false
local maid = Maid.new()
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = 0
local v6 = -1
local v7 = nil
local v8 = nil
local thread = nil
local v9 = {}
local v10 = {}
local v11 = 0
local v12 = {}
local v13 = {}
local now = 0
local unit = createVector(0, 0, 0)
local v14 = createVector(0, 0, 0)
local v15 = 0
local v16 = 0
local v17 = {}
local v18 = {}
local v19 = {}
local v20 = {}
local v21 = {}
local renderSteppedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function randRange(range: NumberRange)
	return range.Min + math.random() * (range.Max - range.Min)
end

local function holdsSections(instance)
	for _, childName in frozen.TIER_NAMES do
		local model = instance:FindFirstChild(childName)

		if not (model and model:IsA("Model")) then
			return false
		end
	end

	return true
end

local function getFolder()
	local v22 = v7

	if v22 and v22:IsDescendantOf(workspace) and holdsSections(v22) then
		return v22
	end

	v7 = nil
	local map = workspace:FindFirstChild("Map")
	local folder

	if map then
		folder = map:FindFirstChild(frozen.ISLAND_MODEL)
	end

	if not folder then
		return nil
	end

	local child = folder:FindFirstChild(frozen.LOCATIONS_NAME, true)
	local child2

	if child then
		child2 = child:FindFirstChild(frozen.MAIN_BASE_NAME)
	end

	local child3

	if child2 then
		child3 = child2:FindFirstChild(frozen.DESTRUCTIBLE_NAME)
	end

	if child3 and holdsSections(child3) then
		v7 = child3
		return child3
	end

	for _, descendant in folder:GetDescendants() do
		if not (descendant.Name == frozen.DESTRUCTIBLE_NAME and holdsSections(descendant)) then
			continue
		end

		v7 = descendant
		return descendant
	end

	return nil
end

local function getTier(p: number)
	local folder = getFolder()
	local v22 = frozen.TIER_NAMES[p]

	if not (folder and v22) then
		return nil
	end

	local model = folder:FindFirstChild(v22)

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

local function keepAxis()
	local map = workspace:FindFirstChild("Map")
	local child

	if map then
		child = map:FindFirstChild(frozen.ISLAND_MODEL)
	end

	local model

	if child then
		model = child:FindFirstChild(frozen.CAROUSEL_NAME)
	end

	if model and model:IsA("Model") then
		return CannonIdle.getSpinCenter(model)
	end

	local v22 = #frozen.TIER_NAMES
	local folder = getFolder()
	local v23 = frozen.TIER_NAMES[v22]
	local model2

	if folder and v23 then
		model2 = folder:FindFirstChild(v23)

		if not (model2 and model2:IsA("Model")) then
			model2 = nil
		end
	end

	if not model2 then
		return nil
	end

	local boundingBox, v24 = model2:GetBoundingBox()
	return boundingBox.Position - createVector(0, 1, 0) * v24.Y * 0.5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function outwardOf(vector2: Vector3)
	local v22 = keepAxis()

	if not v22 then
		return createVector(0, 0, 1)
	end

	local vector3 = Vector3.new(vector2.X - v22.X, 0, vector2.Z - v22.Z)

	if vector3.Magnitude > 0.001 then
		return vector3.Unit
	end

	return createVector(0, 0, 1)
end

local function largestPart(folder)
	local v22 = -1
	local v23 = nil

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local size = part.Size
		local v24 = size.X * size.Y * size.Z

		if not (v22 < v24) then
			continue
		end

		v23 = part
		v22 = v24
	end

	return v23
end

local function ensureFolder()
	local v22 = v

	if v22 and v22.Parent then
		return v22
	end

	local folder = Instance.new("Folder")
	folder.Name = "KeepSiege"
	folder.Parent = workspace
	v = folder
	return folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopAlarm()
	local v22 = thread
	thread = nil

	if v22 and coroutine.status(v22) == "suspended" then
		pcall(task.cancel, v22)
	end

	local v23 = v8
	v8 = nil

	if v23 then
		v23:Destroy()
	end
end

local function startAlarm()
	if v8 then
		return
	end

	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "KeepSiegeAlarm"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = frozen.ALARM_DISPLAY_ORDER
	screenGui.Parent = playerGui
	v8 = screenGui
	local frame = Instance.new("Frame")
	frame.Name = "Flash"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = frozen.ALARM_COLOR
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	thread = task.spawn(function()
		while screenGui.Parent do
			for _ = 1, frozen.ALARM_PULSES do
				TweenService:Create(frame, TweenInfo.new(frozen.ALARM_RISE), {
					BackgroundTransparency = frozen.ALARM_PEAK
				}):Play()
				task.wait(frozen.ALARM_HOLD)
				TweenService:Create(frame, TweenInfo.new(frozen.ALARM_FALL), {
					BackgroundTransparency = 1
				}):Play()
				task.wait(frozen.ALARM_SPACING)
			end

			task.wait(frozen.ALARM_GAP)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unmark()
	v5 = 0
	v6 = -1

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	if v3 then
		v3:Destroy()
		v3 = nil
	end

	v4 = nil
end

local function mark(attribute: number, attribute2: number, attribute3: number)
	if v5 == attribute and v6 == attribute2 then
		return
	end

	local folder = getFolder()
	local v22 = frozen.TIER_NAMES[attribute]
	local model

	if folder and v22 then
		model = folder:FindFirstChild(v22)

		if not (model and model:IsA("Model")) then
			model = nil
		end
	end

	local adornee

	if model then
		adornee = largestPart(model)
	end

	if not (model and adornee) then
		return
	end

	unmark() -- equivalent call inferred; original call site unknown
	v5 = attribute
	v6 = attribute2
	local parent = v

	if not (parent and parent.Parent) then
		parent = Instance.new("Folder")
		parent.Name = "KeepSiege"
		parent.Parent = workspace
		v = parent
	end

	local lerped = frozen.IDLE_COLOR:Lerp(frozen.HIT_COLOR, (math.clamp(attribute2 / math.max(attribute3, 1), 0, 1)))
	local highlight = Instance.new("Highlight")
	highlight.Name = "KeepSectionTarget"
	highlight.Adornee = model
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = lerped
	highlight.FillTransparency = frozen.FILL_RANGE.Min
	highlight.OutlineColor = lerped
	highlight.OutlineTransparency = frozen.OUTLINE_RANGE.Min
	highlight.Parent = parent
	v2 = highlight
	local boundingBox = model:GetBoundingBox()
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "KeepSectionReticle"
	billboardGui.Adornee = adornee
	billboardGui.Size = UDim2.fromOffset(frozen.RETICLE_SIZE, frozen.RETICLE_SIZE)
	billboardGui.StudsOffsetWorldSpace = Vector3.new(0, boundingBox.Position.Y - adornee.Position.Y, 0)
	billboardGui.MaxDistance = frozen.MARKER_MAX_DISTANCE
	billboardGui.LightInfluence = 0
	billboardGui.AlwaysOnTop = true
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Reticle"
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Image = frozen.RETICLE_IMAGE
	imageLabel.ImageColor3 = frozen.RETICLE_COLOR
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = billboardGui
	billboardGui.Parent = parent
	v3 = billboardGui
	v4 = imageLabel
end

local function locationsOf(parent)
	while parent do
		if parent.Name == frozen.LOCATIONS_NAME then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

local function busterSeat(model)
	if not model:IsA("Model") or model.Name ~= frozen.BUSTER_CANNON_NAME then
		return nil
	end

	local part = model:FindFirstChild(frozen.BUSTER_SEAT_NAME)

	if part and part:IsA("BasePart") then
		return part
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function seatTaken(seat)
	if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
		return seat.Occupant ~= nil
	end

	return false
end

local function busterCannons(parent)
	if os.clock() < v11 then
		return v10
	end

	v11 = os.clock() + frozen.BUSTER_SCAN_INTERVAL
	local models = {}

	while true do
		if not parent then
			parent = nil
			break
		end

		if parent.Name == frozen.LOCATIONS_NAME then
			break
		else
			parent = parent.Parent
		end
	end

	if parent then
		for _, model in parent:GetChildren() do
			local part

			if model:IsA("Model") and model.Name == frozen.BUSTER_CANNON_NAME then
				part = model:FindFirstChild(frozen.BUSTER_SEAT_NAME)

				if not (part and part:IsA("BasePart")) then
					part = nil
				end
			end

			if part then
				table.insert(models, model)
			end
		end

		if #models == 0 then
			for _, model in parent:GetDescendants() do
				local part

				if model:IsA("Model") and model.Name == frozen.BUSTER_CANNON_NAME then
					part = model:FindFirstChild(frozen.BUSTER_SEAT_NAME)

					if not (part and part:IsA("BasePart")) then
						part = nil
					end
				end

				if part then
					table.insert(models, model)
				end
			end
		end
	end

	v10 = models
	return models
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unmarkBuster(p)
	local v22 = v9[p]

	if not v22 then
		return
	end

	v9[p] = nil
	v22.highlight:Destroy()
	v22.billboard:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unmarkBusters()
	for k in v9 do
		unmarkBuster(k) -- equivalent call inferred; original call site unknown
	end

	table.clear(v9)
end

local function markBuster(model, part)
	if v9[model] then
		return
	end

	local parent = v

	if not (parent and parent.Parent) then
		parent = Instance.new("Folder")
		parent.Name = "KeepSiege"
		parent.Parent = workspace
		v = parent
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "KeepSiegeBuster"
	highlight.Adornee = model
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = frozen.BUSTER_COLOR
	highlight.FillTransparency = frozen.BUSTER_FILL_RANGE.Min
	highlight.OutlineColor = frozen.BUSTER_COLOR
	highlight.OutlineTransparency = frozen.BUSTER_OUTLINE_RANGE.Min
	highlight.Parent = parent
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "KeepSiegeBusterPrompt"
	billboardGui.Adornee = part
	billboardGui.Size = UDim2.fromOffset(frozen.BUSTER_PROMPT_WIDTH, frozen.BUSTER_PROMPT_HEIGHT)
	billboardGui.StudsOffsetWorldSpace = Vector3.new(0, frozen.BUSTER_HEIGHT, 0)
	billboardGui.MaxDistance = frozen.BUSTER_MAX_DISTANCE
	billboardGui.LightInfluence = 0
	billboardGui.AlwaysOnTop = true
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = Font.new(frozen.BUSTER_PROMPT_FONT, Enum.FontWeight.Bold)
	textLabel.TextScaled = true
	textLabel.TextColor3 = frozen.BUSTER_COLOR
	textLabel.Text = frozen.BUSTER_PROMPT_TITLE
	textLabel.Parent = billboardGui
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = frozen.BUSTER_PROMPT_STROKE
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.Parent = textLabel
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MaxTextSize = frozen.BUSTER_PROMPT_SIZE
	uITextSizeConstraint.Parent = textLabel
	billboardGui.Parent = parent
	v9[model] = {
		highlight = highlight,
		billboard = billboardGui,
		seat = part
	}
end

local function refreshBusters(folder)
	local v22 = {}

	for _, model in busterCannons(folder) do
		local part

		if model:IsA("Model") and model.Name == frozen.BUSTER_CANNON_NAME then
			part = model:FindFirstChild(frozen.BUSTER_SEAT_NAME)

			if not (part and part:IsA("BasePart")) then
				part = nil
			end
		end

		if not (part and model:IsDescendantOf(workspace)) then
			continue
		end

		v22[model] = true
		markBuster(model, part)
	end

	local v23 = {}

	for k in v9 do
		if not v22[k] then
			table.insert(v23, k)
		end
	end

	for _, v24 in v23 do
		unmarkBuster(v24) -- equivalent call inferred; original call site unknown
	end
end

local function stepBusters(now2: number)
	local v22 = (math.sin(now2 * 6.283185307179586 / frozen.BUSTER_PULSE_PERIOD) + 1) * 0.5
	local BUSTER_FILL_RANGE = frozen.BUSTER_FILL_RANGE
	local BUSTER_OUTLINE_RANGE = frozen.BUSTER_OUTLINE_RANGE

	for _, v23 in v9 do
		local enabled

		if v23.seat.Parent == nil then
			enabled = false
		else
			local v25 = seatTaken(v23.seat) -- equivalent call inferred; original call site unknown
			enabled = not v25
		end

		v23.highlight.Enabled = enabled
		v23.billboard.Enabled = enabled

		if not enabled then
			continue
		end

		v23.highlight.FillTransparency = BUSTER_FILL_RANGE.Min + (BUSTER_FILL_RANGE.Max - BUSTER_FILL_RANGE.Min) * v22
		v23.highlight.OutlineTransparency = BUSTER_OUTLINE_RANGE.Min + (BUSTER_OUTLINE_RANGE.Max - BUSTER_OUTLINE_RANGE.Min) * v22
		v23.billboard.StudsOffsetWorldSpace = Vector3.new(0, frozen.BUSTER_HEIGHT + frozen.BUSTER_BOB * v22, 0)
	end
end

local function stopShake()
	for _, v22 in v12 do
		if v22.model.Parent then
			v22.model:PivotTo(v22.origin)
		end
	end

	table.clear(v12)
end

local function shakeCamera(vector2: Vector3, p: number)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local magnitude = (currentCamera.CFrame.Position - vector2).Magnitude

	if frozen.SHAKE_CAMERA_RANGE <= magnitude then
		return
	end

	local SHAKE_CAMERA = frozen.SHAKE_CAMERA
	local v22 = (SHAKE_CAMERA.Min + (SHAKE_CAMERA.Max - SHAKE_CAMERA.Min) * p) * (1 - magnitude / frozen.SHAKE_CAMERA_RANGE)
	pcall(function()
		Util.CameraShaker:ShakeOnce(
			v22,
			frozen.SHAKE_CAMERA_ROUGHNESS,
			0.05,
			frozen.SHAKE_CAMERA_FADE,
			createVector(1, 1, 1),
			createVector(1, 1, 3)
		)
	end)
end

local function startShake(k: number, attribute: Vector3, attribute2: number)
	stopShake()
	local v22 = outwardOf(attribute) -- equivalent call inferred; original call site unknown
	local SHAKE_AMPLITUDE = frozen.SHAKE_AMPLITUDE
	local v23 = math.clamp(attribute2, 0, 1)
	now = os.clock()
	unit = (-v22 + createVector(0, 1, 0) * frozen.SHAKE_LIFT).Unit
	v14 = unit:Cross(createVector(0, 1, 0))
	v14 = not (v14.Magnitude > 0.001) and createVector(1, 0, 0) or v14.Unit
	v15 = SHAKE_AMPLITUDE.Min + (SHAKE_AMPLITUDE.Max - SHAKE_AMPLITUDE.Min) * v23
	local v24

	if math.random() < 0.5 then
		v24 = -frozen.SHAKE_TWIST
	else
		v24 = frozen.SHAKE_TWIST
	end

	v16 = v24
	shakeCamera(attribute, v23)

	for i = k, #frozen.TIER_NAMES do
		if v21[i] or v20[i] then
			continue
		end

		local folder = getFolder()
		local v25 = frozen.TIER_NAMES[i]
		local model

		if folder and v25 then
			model = folder:FindFirstChild(v25)

			if not (model and model:IsA("Model")) then
				model = nil
			end
		end

		if model then
			table.insert(v12, {
				model = model,
				origin = model:GetPivot(),
				falloff = frozen.SHAKE_FALLOFF ^ (i - k)
			})
		end
	end
end

local function stepShake()
	if #v12 == 0 then
		return
	end

	local v22 = os.clock() - now

	if frozen.SHAKE_DURATION <= v22 then
		stopShake()
		return
	end

	local v23 = math.sin(v22 * frozen.SHAKE_FREQUENCY * 3.141592653589793 * 2) * math.exp(-v22 * frozen.SHAKE_DAMPING)
	local v24 = math.sin(v22 * frozen.SHAKE_HEAVE_FREQUENCY * 3.141592653589793 * 2) * math.exp(-v22 * frozen.SHAKE_HEAVE_DAMPING) * frozen.SHAKE_HEAVE_MIX
	local v25 = math.sin(v22 * frozen.SHAKE_FREQUENCY * frozen.SHAKE_SWAY_DETUNE * 3.141592653589793 * 2) * math.exp(-v22 * frozen.SHAKE_DAMPING) * frozen.SHAKE_SWAY
	local v26 = v23 + v24

	for _, v27 in v12 do
		if not v27.model.Parent then
			continue
		end

		local v28 = v26 * v27.falloff
		local v29 = unit * (v15 * v28) + v14 * (v15 * v25 * v27.falloff)
		local position = v27.origin.Position
		local v30 = CFrame.new(position) * CFrame.Angles(0, v16 * v28, 0) * CFrame.new(-position)
		v27.model:PivotTo(CFrame.new(v29) * v30 * v27.origin)
	end
end

local function watchHits(instance)
	for k, childName in frozen.TIER_NAMES do
		local model = instance:FindFirstChild(childName)

		if not (model and model:IsA("Model")) then
			continue
		end

		local attribute = tonumber(model:GetAttribute(frozen.HIT_AT_ATTRIBUTE))

		if attribute then
			if v13[k] ~= attribute then
				v13[k] = attribute

				if not (v21[k] or v20[k] or workspace:GetServerTimeNow() - attribute > frozen.SHAKE_DURATION) then
					local attribute2 = model:GetAttribute(frozen.HIT_IMPACT_ATTRIBUTE)

					if typeof(attribute2) ~= "Vector3" then
						attribute2 = model:GetBoundingBox().Position
					end

					startShake(k, attribute2, tonumber(model:GetAttribute(frozen.HIT_POWER_ATTRIBUTE)) or 0)
				end
			end
		else
			v13[k] = nil
		end
	end
end

local function hideTier(p: number, folder)
	if v17[p] then
		return
	end

	local parts = {}

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.LocalTransparencyModifier = 1
		table.insert(parts, part)
	end

	v17[p] = parts
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unhideTier(p: number)
	local v22 = v17[p]
	v17[p] = nil

	if not v22 then
		return
	end

	for _, v23 in v22 do
		if v23.Parent then
			v23.LocalTransparencyModifier = 0
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearEmbers(p: number)
	local v22 = v18[p]
	v18[p] = nil

	if not v22 then
		return
	end

	for _, v23 in v22 do
		v23:Destroy()
	end
end

local function restoreAllHidden()
	for k in v17 do
		unhideTier(k) -- equivalent call inferred; original call site unknown
	end

	table.clear(v17)

	for k in v18 do
		clearEmbers(k) -- equivalent call inferred; original call site unknown
	end

	table.clear(v18)
end

local function buildEmber(p: number, position: Vector3, size: number, size2: number)
	local part = Instance.new("Part")
	part.Name = "KeepEmber"
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(position)
	local parent = v

	if not (parent and parent.Parent) then
		parent = Instance.new("Folder")
		parent.Name = "KeepSiege"
		parent.Parent = workspace
		v = parent
	end

	part.Parent = parent
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local fire = Instance.new("Fire")
	fire.Heat = 14
	fire.Size = size
	fire.Color = frozen.IDLE_COLOR
	fire.SecondaryColor = frozen.HIT_COLOR
	fire.Parent = attachment
	local smoke = Instance.new("Smoke")
	smoke.Color = frozen.SMOKE_COLOR
	smoke.Opacity = 0.45
	smoke.RiseVelocity = 22
	smoke.Size = size2
	smoke.Parent = attachment
	local v23 = v18[p]

	if not v23 then
		v23 = {}
		v18[p] = v23
	end

	table.insert(v23, part)
end

local function retireEmbersAbove(p: number)
	local v22 = {}

	for k in v18 do
		if k < p then
			table.insert(v22, k)
		end
	end

	for _, v23 in v22 do
		clearEmbers(v23) -- equivalent call inferred; original call site unknown
	end
end

local function emberRing(p: number, vector2: Vector3, p2: number)
	retireEmbersAbove(p)

	for i = 1, frozen.STUMP_FIRES do
		local v22 = i / frozen.STUMP_FIRES * 3.141592653589793 * 2 + math.random() * 0.5
		buildEmber(p, vector2 + Vector3.new(math.cos(v22) * p2 * 0.72, 2, math.sin(v22) * p2 * 0.72), 30, 40)
	end
end

local function shatterTier(folder)
	local parent = v

	if not (parent and parent.Parent) then
		parent = Instance.new("Folder")
		parent.Name = "KeepSiege"
		parent.Parent = workspace
		v = parent
	end

	local count = 0

	for _, part in folder:GetDescendants() do
		if frozen.SHATTER_MAX <= count then
			break
		end

		if not part:IsA("BasePart") or part.Transparency >= 1 then
			continue
		end

		for _ = 1, frozen.SHATTER_PER_PART do
			if frozen.SHATTER_MAX <= count then
				break
			end

			count += 1
			local clone = part:Clone()

			for _, descendant in clone:GetDescendants() do
				descendant:Destroy()
			end

			local v23 = part.Size * 0.5
			local cFrame = part.CFrame * CFrame.new(
				(math.random() - 0.5) * 2 * v23.X,
				(math.random() - 0.5) * 2 * v23.Y,
				(math.random() - 0.5) * 2 * v23.Z
			)
			local size = part.Size * randRange(frozen.SHATTER_SCALE)
			local v26 = math.max(size.X, size.Y, size.Z)

			if frozen.SHATTER_SIZE.Max < v26 then
				size *= frozen.SHATTER_SIZE.Max / v26
			elseif v26 < frozen.SHATTER_SIZE.Min then
				size *= frozen.SHATTER_SIZE.Min / v26
			end

			clone.Name = "KeepRubble"
			clone.Size = size
			clone.CFrame = cFrame
			clone.Transparency = 0
			clone.Anchored = false
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.Massless = true
			clone.CastShadow = false
			clone.LocalTransparencyModifier = 0
			clone.Parent = parent
			local v27 = outwardOf(cFrame.Position) -- equivalent call inferred; original call site unknown
			local v28 = v27 * randRange(frozen.SHATTER_SPEED)
			local SHATTER_LIFT = frozen.SHATTER_LIFT
			clone.AssemblyLinearVelocity = v28 + Vector3.new(0, randRange(SHATTER_LIFT), 0)
			clone.AssemblyAngularVelocity = Vector3.new(
				(math.random() - 0.5) * 2 * frozen.SHATTER_SPIN,
				(math.random() - 0.5) * 2 * frozen.SHATTER_SPIN,
				(math.random() - 0.5) * 2 * frozen.SHATTER_SPIN
			)
			TweenService:Create(clone, TweenInfo.new(frozen.SHATTER_FADE, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			Util.Debris:AddItem(clone, frozen.SHATTER_LIFETIME)
		end
	end
end

local function collapseDust(vector2: Vector3, p: number, p2: number)
	local v22 = math.random() * 3.141592653589793 * 2
	local v23 = vector2 + Vector3.new(math.cos(v22) * p * 0.85, 0, math.sin(v22) * p * 0.85)
	Effect.new("DustExplosion"):play({
		CFrame = CFrame.new(v23),
		Size = { p2 * 8, frozen.COLLAPSE_DUST_SIZE * p2 },
		Duration = 1.7,
		ColorSequence = ColorSequence.new(frozen.DUST_COLOR, frozen.SMOKE_COLOR)
	})
	Effect.new("ExpandRing"):play({
		Origin = CFrame.lookAt(vector2, vector2 + createVector(0, 1, 0), createVector(0, 0, 1)),
		Color = frozen.DUST_COLOR,
		Size = { Vector3.new(p * 0.5, p * 0.5, 1), (Vector3.new(p * 2.2 * p2, p * 2.2 * p2, 1)) },
		Duration = 0.7
	})
end

local function settleTier(i: number)
	if v21[i] then
		return
	end

	v21[i] = true
	local folder = getFolder()
	local v22 = frozen.TIER_NAMES[i]
	local model

	if folder and v22 then
		model = folder:FindFirstChild(v22)

		if not (model and model:IsA("Model")) then
			model = nil
		end
	end

	if not model then
		return
	end

	stopShake()
	local boundingBox, v23 = model:GetBoundingBox()
	local position = boundingBox.Position
	hideTier(i, model)
	emberRing(i, Vector3.new(position.X, position.Y - v23.Y * 0.5, position.Z), math.max(v23.X, v23.Z) * 0.5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function finishCollapse(p: number, instance)
	local connection = v20[p]
	v20[p] = nil

	if connection then
		connection:Disconnect()
	end

	if instance then
		instance:Destroy()
	end
end

local function collapseTier(i: number, attribute: Vector3, p: number)
	if v20[i] or v21[i] then
		return
	end

	local folder = getFolder()
	local v22 = frozen.TIER_NAMES[i]
	local model

	if folder and v22 then
		model = folder:FindFirstChild(v22)

		if not (model and model:IsA("Model")) then
			model = nil
		end
	end

	if not model then
		return
	end

	stopShake()
	retireEmbersAbove(i)
	local boundingBox, v23 = model:GetBoundingBox()
	local position = boundingBox.Position
	local v24 = math.max(v23.X, v23.Z) * 0.5
	local vector2 = Vector3.new(position.X, position.Y - v23.Y * 0.5, position.Z)
	v21[i] = true
	shatterTier(model)
	local clone = model:Clone()
	local descendants = {}
	local transparenciesByDescendant = {}

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.CastShadow = false
			table.insert(descendants, descendant)
			transparenciesByDescendant[descendant] = descendant.Transparency
		elseif descendant:IsA("JointInstance") or descendant:IsA("Constraint") or descendant:IsA("Sound") then
			descendant:Destroy()
		end
	end

	clone.Name = "CollapsingKeepSection"
	local parent = v

	if not (parent and parent.Parent) then
		parent = Instance.new("Folder")
		parent.Name = "KeepSiege"
		parent.Parent = workspace
		v = parent
	end

	clone.Parent = parent
	hideTier(i, model)
	local pivot = clone:GetPivot()
	local v26 = v23.Y * frozen.COLLAPSE_SINK
	local v27 = v24 * frozen.COLLAPSE_SLIDE
	local v28 = -randRange(frozen.COLLAPSE_TILT)
	local v29 = (math.random() - 0.5) * 2 * frozen.COLLAPSE_TWIST
	local v30 = outwardOf(attribute) -- equivalent call inferred; original call site unknown
	local vector3 = Vector3.new(-v30.Z, 0, v30.X)
	local v31 = not (vector3.Magnitude > 0.001) and createVector(1, 0, 0) or vector3.Unit
	local v32 = os.clock() - math.max(p, 0)
	local v33 = 0
	v20[i] = RunService.RenderStepped:Connect(function()
		local v34 = os.clock() - v32

		if v34 < frozen.COLLAPSE_SHUDDER then
			local v35 = frozen.COLLAPSE_JITTER * (v34 / frozen.COLLAPSE_SHUDDER)
			clone:PivotTo(CFrame.new(
				(math.random() - 0.5) * 2 * v35,
				(math.random() - 0.5) * v35,
				(math.random() - 0.5) * 2 * v35
			) * pivot)

			if v33 <= v34 then
				v33 = v34 + frozen.COLLAPSE_DUST_INTERVAL
				collapseDust(vector2, v24, 0.45)
			end
		else
			local v35 = math.clamp((v34 - frozen.COLLAPSE_SHUDDER) / frozen.COLLAPSE_FALL, 0, 1)
			local v36 = v26 * v35 * v35
			local v37 = v30 * (v27 * v35 * v35) - Vector3.new(0, v36, 0)
			local v38 = CFrame.fromAxisAngle(v31, v28 * v35) * CFrame.Angles(0, v29 * v35, 0)
			clone:PivotTo(CFrame.new(vector2 + v37) * v38 * CFrame.new(-vector2) * pivot)
			local v39 = math.clamp((v35 - frozen.COLLAPSE_FADE_START) / (1 - frozen.COLLAPSE_FADE_START), 0, 1)

			for _, v40 in descendants do
				local v41 = transparenciesByDescendant[v40] or 0
				v40.Transparency = v41 + (1 - v41) * v39
			end

			if v33 <= v34 then
				v33 = v34 + frozen.COLLAPSE_DUST_INTERVAL
				collapseDust(vector2 + v37, v24, v35 * 0.7 + 0.8)
			end

			if v35 < 1 then
				return
			end

			finishCollapse(i, clone) -- equivalent call inferred; original call site unknown
			emberRing(i, vector2, v24)
			pcall(function()
				Util.CameraShaker:ShakeOnce(frozen.COLLAPSE_SHAKE, 9, 0.07, 2.2)
			end)
		end
	end)
end

local function clearAll()
	unmark() -- equivalent call inferred; original call site unknown
	unmarkBusters() -- equivalent call inferred; original call site unknown
	table.clear(v10)
	v11 = 0
	stopShake()
	table.clear(v13)

	for k in v20 do
		finishCollapse(k) -- equivalent call inferred; original call site unknown
	end

	table.clear(v20)
	table.clear(v21)
	table.clear(v19)
	restoreAllHidden()
	stopAlarm() -- equivalent call inferred; original call site unknown
	v7 = nil
	local v22 = v
	v = nil

	if v22 then
		v22:Destroy()
	end

	CannonIdle.setAgitated(nil)
	CannonIdle.setWrecked(nil)
end

local function poll()
	local folder = getFolder()

	if not folder then
		return
	end

	local v22 = folder:GetAttribute(frozen.ARMED_ATTRIBUTE) == true
	local attribute = tonumber(folder:GetAttribute(frozen.ACTIVE_ATTRIBUTE)) or 0
	local attribute2 = tonumber(folder:GetAttribute(frozen.DAMAGE_ATTRIBUTE)) or 0
	local attribute3 = tonumber(folder:GetAttribute(frozen.HITS_ATTRIBUTE)) or 1
	local attribute4 = tonumber(folder:GetAttribute(frozen.ARMED_AT_ATTRIBUTE))
	local attribute5 = tonumber(folder:GetAttribute(frozen.WRECKED_ATTRIBUTE))
	CannonIdle.setWrecked(attribute5)
	local setAgitated = CannonIdle.setAgitated

	if not v22 or attribute5 then
		attribute4 = nil
	end

	setAgitated(attribute4)
	local serverTimeNow = workspace:GetServerTimeNow()

	for i = 1, #frozen.TIER_NAMES do
		local folder2 = getFolder()
		local v23 = frozen.TIER_NAMES[i]
		local model

		if folder2 and v23 then
			model = folder2:FindFirstChild(v23)

			if not (model and model:IsA("Model")) then
				model = nil
			end
		end

		if not model then
			continue
		end

		local attribute6 = tonumber(model:GetAttribute(frozen.FELL_ATTRIBUTE))

		if attribute6 then
			if v19[i] ~= attribute6 then
				v19[i] = attribute6
				local v24 = serverTimeNow - attribute6
				local attribute7 = model:GetAttribute(frozen.IMPACT_ATTRIBUTE)

				if typeof(attribute7) ~= "Vector3" then
					attribute7 = model:GetBoundingBox().Position
				end

				if v24 <= frozen.COLLAPSE_SHUDDER + frozen.COLLAPSE_FALL then
					collapseTier(i, attribute7, v24)
				else
					settleTier(i)
				end
			end
		elseif v19[i] then
			v19[i] = nil
			v21[i] = nil
			finishCollapse(i) -- equivalent call inferred; original call site unknown
			clearEmbers(i) -- equivalent call inferred; original call site unknown
			unhideTier(i) -- equivalent call inferred; original call site unknown
		end
	end

	if v22 and attribute > 0 and not attribute5 then
		mark(attribute, attribute2, attribute3)
		startAlarm()
		refreshBusters(folder)
	else
		unmark() -- equivalent call inferred; original call site unknown
		stopAlarm() -- equivalent call inferred; original call site unknown
		unmarkBusters() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startLoop()
	if renderSteppedConnection then
		return
	end

	local v22 = 0
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local now2 = os.clock()

		if v22 <= now2 then
			v22 = now2 + frozen.POLL_INTERVAL
			pcall(poll)
		end

		local v23 = v7

		if v23 then
			CannonIdle.setWrecked((tonumber(v23:GetAttribute(frozen.WRECKED_ATTRIBUTE))))
			watchHits(v23)
		end

		stepShake()
		stepBusters(now2)
		local v24 = v2

		if v24 then
			local v25 = (math.sin(now2 * 6.283185307179586 / frozen.PULSE_PERIOD) + 1) * 0.5
			local FILL_RANGE = frozen.FILL_RANGE
			local OUTLINE_RANGE = frozen.OUTLINE_RANGE
			v24.FillTransparency = FILL_RANGE.Min + (FILL_RANGE.Max - FILL_RANGE.Min) * v25
			v24.OutlineTransparency = OUTLINE_RANGE.Min + (OUTLINE_RANGE.Max - OUTLINE_RANGE.Min) * v25
			local v26 = v4

			if v26 then
				v26.ImageTransparency = OUTLINE_RANGE.Min + (OUTLINE_RANGE.Max - OUTLINE_RANGE.Min) * v25
			end
		end
	end)
	maid:GiveTask(renderSteppedConnection)
end

local KeepSiege = {
	LoadForLocations = { "Marine Fortress" },
	Maid = Maid.new(),
	start = function()
		if flag then
			return
		end

		flag = true
		startLoop() -- equivalent call inferred; original call site unknown
	end,
	stop = function()
		flag = false
		renderSteppedConnection = nil
		maid:DoCleaning()
		clearAll()
	end
}

function KeepSiege.RegionEntered(_)
	KeepSiege.start()
end

function KeepSiege.RegionLeaving(_)
	KeepSiege.stop()
end

return KeepSiege