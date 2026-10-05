local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local GUI = require(ReplicatedStorage.Client.GUI)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local SammyEvent = require(ReplicatedStorage.Data.SammyEvent)
require(ReplicatedStorage.Packages.Trove)
local v = { 0.04, 0.05, 0.035 }
local v2 = {
	0.06,
	0.04,
	0.05,
	0.05,
	0.035,
	0.07,
	0.09
}
local color = Color3.fromRGB(0, 170, 255)
local color2 = Color3.fromRGB(200, 250, 255)
local color3 = Color3.fromRGB(70, 210, 255)
local random = Random.new()
local v3 = nil
local v4 = false
local flag = false
local v5 = false
local v6 = 0
local v7 = 0
local v8 = 0
local v9 = true
local v10 = -1
local v11 = ""
local v12 = ""
local v13 = ""
local total = 0
local total2 = 0
local v14 = 0
local v15 = 0
local v16 = -1
local v17 = nil
local v18 = 0
local v19 = 0
local v20 = false
local v21 = -1
local v22 = 0
local v23 = 0
local v24 = -1
local v25 = -1
local v26 = -1
local v27 = nil
local v28 = false
local v29 = 0
local v30 = 1
local v31 = -1

local function makeSheet(instance, instance2)
	local cells = instance2:GetAttribute("Cells")
	local FPS = instance2:GetAttribute("FPS")
	local v32

	if typeof(cells) == "Vector2" then
		v32 = type(FPS) == "number"
	else
		v32 = false
	end

	assert(v32, (`{instance2:GetFullName()} needs Cells and FPS attributes`))
	local startAt = instance:GetAttribute("StartAt")
	instance.Visible = false
	instance.ImageRectOffset = Vector2.zero
	return {
		Image = instance,
		Cells = cells,
		Offsets = nil,
		Frames = math.max(1, cells.X * cells.Y),
		FrameTime = 1 / FPS,
		Frame = 1,
		Acc = 0,
		On = false,
		StartAt = type(startAt) ~= "number" and 30 or startAt
	}
end

local function resolveUi()
	local v32 = v3

	if v32 then
		return v32
	end

	local sammyEventUI = GUI.SammyEventUI()
	local eMPChargeBar = sammyEventUI.EMPChargeBar
	local barHolder = eMPChargeBar.BarHolder
	local icon = barHolder.Icon
	local glowImage = icon.GlowImage
	local barBG = barHolder.BarBG
	local bar = barBG.Bar
	local lightningSheets = {}

	for _, script in eMPChargeBar:GetDescendants() do
		if not (script:IsA("LocalScript") and script.Name == "PlaySprite") then
			continue
		end

		assert(not script.Enabled, (`{script:GetFullName()} must be disabled`))
		local parent = script.Parent
		assert(parent and parent:IsA("ImageLabel"), (`{script:GetFullName()} must sit under an ImageLabel`))

		if parent ~= bar.BarCharge then
			table.insert(lightningSheets, (makeSheet(parent, script)))
		end
	end

	local sheet = makeSheet(bar.BarCharge, bar.BarCharge.PlaySprite)
	local sheet2 = makeSheet(icon.ChargeLine, icon.ChargeLine)
	local clone = table.clone(lightningSheets)
	table.insert(clone, sheet)
	table.insert(clone, sheet2)
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = -90
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.44, color),
		ColorSequenceKeypoint.new(0.49, color2),
		ColorSequenceKeypoint.new(1, color2)
	})
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.72),
		NumberSequenceKeypoint.new(0.44, 0.72),
		NumberSequenceKeypoint.new(0.485, 0.2),
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
	imageLabel.ImageColor3 = color3
	imageLabel.ImageTransparency = 1
	imageLabel.AnchorPoint = icon.AnchorPoint
	imageLabel.Position = icon.Position
	imageLabel.Size = UDim2.new(
		icon.Size.X.Scale * 1.16,
		icon.Size.X.Offset * 1.16,
		icon.Size.Y.Scale * 1.16,
		icon.Size.Y.Offset * 1.16
	)
	imageLabel.ZIndex = icon.ZIndex - 1
	imageLabel.Visible = false
	imageLabel.Parent = barHolder
	local v34 = {
		Gui = sammyEventUI,
		Holder = barHolder,
		Icon = icon,
		Glow = glowImage,
		Halo = imageLabel,
		EnergyGradient = uIGradient,
		Percent = barHolder.ProgressHolder,
		Title = eMPChargeBar.TitleHolder.BossName,
		TitleText = eMPChargeBar.TitleHolder.BossName.Text,
		Timer = eMPChargeBar.TimeLeftHolder.TimeLeft,
		BarBG = barBG,
		Bar = bar,
		Phantom = barBG.PhantomBar,
		Decor = barBG.Decor,
		BaseHolderRotation = barHolder.Rotation,
		BaseIconPosition = icon.Position,
		BaseIconRotation = icon.Rotation,
		BarSizeY = bar.Size.Y,
		PhantomSizeY = barBG.PhantomBar.Size.Y,
		LineBaseX = icon.ChargeLine.Position.X,
		FillSheet = sheet,
		LineSheet = sheet2,
		LightningSheets = lightningSheets,
		AllSheets = clone
	}
	v3 = v34
	return v34
end

local function isRaiding()
	local sammyWeaponRequired = Workspace:GetAttribute("SammyWeaponRequired")
	return type(sammyWeaponRequired) == "number" and sammyWeaponRequired > 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSavingBen()
	return Workspace:GetAttribute("SammyPhase") == "SaveBen"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function readCharge()
	local sammyEmpCharge = Workspace:GetAttribute("SammyEmpCharge")

	if type(sammyEmpCharge) == "number" then
		return (math.clamp(sammyEmpCharge / SammyEvent.ChargeMax, 0, 1))
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeFill(data, flag2: boolean)
	local v32 = math.round(v8 * data.BarBG.AbsoluteSize.X)

	if flag2 or v32 ~= v10 then
		v10 = v32
		data.Bar.Size = UDim2.new(v8, 0, data.BarSizeY.Scale, data.BarSizeY.Offset)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writePhantom(p)
	p.Phantom.Size = UDim2.new(v7, 0, p.PhantomSizeY.Scale, p.PhantomSizeY.Offset)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeText(data)
	local text = string.format("%.2f%%", v8 * 100)

	if text ~= v11 then
		v11 = text
		data.Percent.Text = text
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeTitle(p)
	local text

	if isSavingBen() then
		text = "Save Ben from Mind Controlled Sammy!"
	else
		local sammyWeaponRequired = Workspace:GetAttribute("SammyWeaponRequired")
		text = type(sammyWeaponRequired) == "number" and sammyWeaponRequired > 0 and "Bring Brainrots to the Laser Gun!" or p.TitleText
	end

	if text ~= v12 then
		v12 = text
		p.Title.Text = text
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeTimer(p)
	local v32 = math.max(0, (math.floor(v6 - Workspace:GetServerTimeNow())))
	local text = string.format("%02d:%02d", v32 // 60, v32 % 60)

	if text ~= v13 then
		v13 = text
		p.Timer.Text = text
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSheet(state, flag2: boolean)
	if state.On == flag2 then
		return
	end

	state.On = flag2
	state.Image.Visible = flag2

	if not flag2 then
		return
	end

	local offsets = state.Offsets

	if offsets == nil then
		offsets = table.create(state.Frames)
		local imageRectSize = state.Image.ImageRectSize

		for i = 0, state.Frames - 1 do
			offsets[i + 1] = Vector2.new(imageRectSize.X * (i % state.Cells.X), imageRectSize.Y * (i // state.Cells.X))
		end

		state.Offsets = offsets
	end

	state.Frame = 1
	state.Acc = 0
	state.Image.ImageRectOffset = offsets[1]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setDecorOff(data, flag2: boolean)
	if flag2 == v20 then
		return
	end

	v20 = flag2
	data.Decor.Visible = not flag2
end

local function writeEnergy(data, flag2: boolean)
	local v32 = v8 * 0.9800000000000001 + 0.1

	if flag2 or math.abs(v32 - v24) >= 0.002 then
		v24 = v32
		data.EnergyGradient.Offset = Vector2.new(0, 0.5 - v32)
		data.LineSheet.Image.Position = UDim2.new(
			data.LineBaseX.Scale,
			data.LineBaseX.Offset,
			1 - math.min(v32, 0.92),
			0
		)
	end

	setSheet(data.LineSheet, v8 > 0 and v8 < 1)
	local v35 = not v28 and 0 or math.sin(v23 * 1.6 * 3.141592653589793 * 2) * 0.06
	local imageTransparency = math.clamp((1 - v22) * 0.15 + v35, 0, 1)

	if flag2 or math.abs(imageTransparency - v25) >= 0.01 then
		v25 = imageTransparency
		data.Glow.ImageTransparency = imageTransparency
	end

	local v37 = v8 * -0.52 + 0.92
	local imageTransparency2 = math.clamp(v37 - v22 * (v37 - 0.1) + v35, 0, 1)

	if flag2 or math.abs(imageTransparency2 - v26) >= 0.01 then
		v26 = imageTransparency2
		data.Halo.ImageTransparency = imageTransparency2
	end

	local visible = v8 > 0

	if flag2 or data.Glow.Visible ~= visible then
		data.Glow.Visible = visible
		data.Halo.Visible = visible
	end
end

local function buildTremble(data, X: number)
	local positions = {}
	local rotations = {}

	for i = 1, 4 do
		local v34 = (i - 1) / 3
		local v35 = X * (v34 * 2.5 + 1) / 100
		local v36 = v34 * 4 + 2
		local v37 = {}
		local v38 = {}

		for i2 = 1, 12 do
			local v39 = i2 / 12 * 3.141592653589793 * 2 + random:NextNumber(-0.4, 0.4)
			local v40 = v35 * random:NextNumber(0.45, 1)
			v37[i2] = data.BaseIconPosition + UDim2.fromOffset(
				math.round(math.cos(v39) * v40),
				(math.round(math.sin(v39) * v40))
			)
			v38[i2] = data.BaseIconRotation + v36 * random:NextNumber(-1, 1)
		end

		positions[i] = v37
		rotations[i] = v38
	end

	return {
		Positions = positions,
		Rotations = rotations,
		Width = X
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTremble(data, flag2: boolean)
	if v28 == flag2 then
		return
	end

	v28 = flag2
	v29 = 0

	if not flag2 then
		data.Icon.Position = data.BaseIconPosition
		data.Icon.Rotation = data.BaseIconRotation
	end
end

local function rest(data)
	total2 = 0
	v14 = 0
	v15 = 0
	data.Holder.Rotation = data.BaseHolderRotation
	v17 = nil

	if v20 ~= false then
		v20 = false
		data.Decor.Visible = true
	end

	v22 = 0
	v23 = 0
	setTremble(data, false) -- equivalent call inferred; original call site unknown

	for _, allSheet in data.AllSheets do
		setSheet(allSheet, false) -- equivalent call inferred; original call site unknown
		allSheet.Offsets = nil
	end

	data.Glow.Visible = false
	data.Halo.Visible = false
	v27 = nil
	v31 = -1
	v24 = -1
	v25 = -1
	v26 = -1
	v10 = -1
	v11 = ""
	v12 = ""
	v13 = ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function kick(p: number)
	local v32 = random:NextNumber() < 0.5 and -1 or 1
	v14 = math.clamp(
		v14 + v32 * p * random:NextNumber(0.8, 1) * 40.840704496667314 / 0.7,
		-291.719317833338,
		291.719317833338
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flicker(p, list)
	v17 = list
	v18 = 1
	v19 = list[1]

	if v20 == true then
		return
	end

	v20 = true
	p.Decor.Visible = false
end

local function beat(p, flag2: boolean)
	local now = os.clock()

	if flag2 then
		v16 = now
		v21 = now
		kick(4) -- equivalent call inferred; original call site unknown
		flicker(p, v2) -- equivalent call inferred; original call site unknown
		v22 = 0.7
	else
		if now - v16 >= 0.08 then
			v16 = now
			kick(1.6) -- equivalent call inferred; original call site unknown
		end

		v22 = math.max(v22, 0.35)

		if v17 == nil and now - v21 >= 0.22 then
			v21 = now
			flicker(p, v) -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateTarget(data)
	local charge = readCharge() -- equivalent call inferred; original call site unknown

	if charge == v7 then
		return
	end

	v7 = charge

	if charge < 0.99 then
		v9 = true
	elseif v9 and charge >= 1 then
		v9 = false
		local now = os.clock()
		v16 = now
		v21 = now
		kick(4) -- equivalent call inferred; original call site unknown
		flicker(data, v2) -- equivalent call inferred; original call site unknown
		v22 = 0.7
	end

	writePhantom(data) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function snapBar(data)
	v7 = readCharge()
	v8 = v7
	v10 = math.round(v8 * data.BarBG.AbsoluteSize.X)
	data.Bar.Size = UDim2.new(v8, 0, data.BarSizeY.Scale, data.BarSizeY.Offset)
	writePhantom(data) -- equivalent call inferred; original call site unknown
	writeText(data) -- equivalent call inferred; original call site unknown
	writeEnergy(data, true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function show(data)
	flag = true
	data.Gui.Enabled = true
	snapBar(data) -- equivalent call inferred; original call site unknown
	writeTitle(data) -- equivalent call inferred; original call site unknown
	writeTimer(data) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setBarShown(data, visible: boolean)
	if v5 == visible then
		return
	end

	v5 = visible

	if visible then
		snapBar(data) -- equivalent call inferred; original call site unknown
	else
		rest(data)
	end

	data.Holder.Visible = visible
end

local function stepBar(data, p: number)
	updateTarget(data) -- equivalent call inferred; original call site unknown

	if v8 ~= v7 then
		v8 += (v7 - v8) * (1 - math.exp(p * -9))

		if math.abs(v7 - v8) < 0.0004 then
			v8 = v7
		end

		writeFill(data, false) -- equivalent call inferred; original call site unknown
		total += p

		if v8 == v7 or total >= 0.05 then
			total = 0
			writeText(data) -- equivalent call inferred; original call site unknown
		end
	end

	if total2 ~= 0 or v14 ~= 0 then
		local v32 = math.max(math.ceil(p * 120), 1)
		local v33 = p / v32

		for _ = 1, v32 do
			v14 += (-1667.9631437841017 * total2 - 24.504422698000386 * v14) * v33
			total2 += v14 * v33
		end

		if math.abs(total2) < 0.02 and math.abs(v14) < 0.3 then
			total2 = 0
			v14 = 0
		end

		if math.abs(total2 - v15) >= 0.02 or total2 == 0 then
			v15 = total2
			data.Holder.Rotation = data.BaseHolderRotation + total2
		end
	end

	local v32 = v17

	if v32 then
		v19 -= p

		while v19 <= 0 do
			v18 += 1
			local v33 = v32[v18]

			if v33 == nil then
				v17 = nil

				if v20 == false then
					break
				end

				v20 = false
				data.Decor.Visible = true
				break
			else
				v19 += v33
				setDecorOff(data, v18 % 2 == 1) -- equivalent call inferred; original call site unknown
			end
		end
	end

	local v33 = v8 * 100

	if v33 ~= v31 then
		v31 = v33
		setTremble(data, v33 >= 30) -- equivalent call inferred; original call site unknown

		for _, lightningSheet in data.LightningSheets do
			setSheet(lightningSheet, lightningSheet.StartAt <= v33)
		end

		setSheet(data.FillSheet, v8 > 0)
	end

	if v22 > 0 then
		v22 *= math.exp(p * -5)

		if v22 < 0.01 then
			v22 = 0
		end
	end

	v23 = not v28 and 0 or v23 + p
	writeEnergy(data, false)

	if v28 then
		local X = data.Icon.AbsoluteSize.X
		local v34 = v27

		if v34 == nil or v34.Width ~= X then
			v34 = buildTremble(data, X)
			v27 = v34
		end

		v29 += p

		if v29 >= 0.03333333333333333 then
			v29 %= 0.03333333333333333
			local v35 = math.clamp(math.floor((v33 - 30) / 70 * 3 + 0.5) + 1, 1, 4)
			v30 = (v30 + random:NextInteger(3, 9) - 1) % 12 + 1
			data.Icon.Position = v34.Positions[v35][v30]
			data.Icon.Rotation = v34.Rotations[v35][v30]
		end
	end

	for _, allSheet in data.AllSheets do
		local offsets = allSheet.Offsets

		if not (allSheet.On and offsets ~= nil) then
			continue
		end

		local acc = allSheet.Acc + p

		if allSheet.FrameTime <= acc then
			local v35 = acc // allSheet.FrameTime
			acc -= v35 * allSheet.FrameTime
			allSheet.Frame = (allSheet.Frame - 1 + v35) % allSheet.Frames + 1
			allSheet.Image.ImageRectOffset = offsets[allSheet.Frame]
		end

		allSheet.Acc = acc
	end
end

local function step(p: number)
	local v32 = v3

	if not v4 or v32 == nil then
		return
	end

	if HiddenUIHandler.IsHidden() then
		if flag then
			flag = false
			v5 = false
			rest(v32)
			v32.Gui.Enabled = false
		end
	else
		if not flag then
			show(v32) -- equivalent call inferred; original call site unknown
		end

		local v33 = math.min(p, 0.1)
		local sammyWeaponRequired = Workspace:GetAttribute("SammyWeaponRequired")
		local v35 = type(sammyWeaponRequired) ~= "number" or not (sammyWeaponRequired > 0)

		if v35 then
			local savingBen = isSavingBen() -- equivalent call inferred; original call site unknown
			v35 = not savingBen
		end

		setBarShown(v32, v35) -- equivalent call inferred; original call site unknown

		if v5 then
			stepBar(v32, v33)
		end

		writeTitle(v32) -- equivalent call inferred; original call site unknown
		writeTimer(v32) -- equivalent call inferred; original call site unknown
	end
end

local function stop()
	if not v4 then
		return
	end

	v4 = false
	flag = false
	v5 = false
	local v32 = v3

	if v32 == nil then
		return
	end

	rest(v32)
	v32.Gui.Enabled = false
end

local function pickupArrived(_: Vector3)
	local v32 = v3

	if v4 and flag and v32 ~= nil then
		local now = os.clock()

		if now - v16 >= 0.08 then
			v16 = now
			kick(1.6) -- equivalent call inferred; original call site unknown
		end

		v22 = math.max(v22, 0.35)

		if v17 == nil and now - v21 >= 0.22 then
			v21 = now
			flicker(v32, v) -- equivalent call inferred; original call site unknown
		end
	end
end

local function start(object, p: number)
	resolveUi()
	v4 = true
	flag = false
	v5 = false
	v6 = p
	v7 = readCharge()
	v8 = v7
	v9 = v7 < 0.99
	object:Connect(RunService.PreRender, step)
	object:Add(stop)
end

return {
	Start = start,
	Stop = stop,
	PickupArrived = pickupArrived
}