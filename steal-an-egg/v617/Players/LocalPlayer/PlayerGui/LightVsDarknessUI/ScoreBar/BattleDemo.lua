local RunService = game:GetService("RunService")
local parent = script.Parent
local barHolder = parent.BarHolder
local barBG = barHolder.BarBG
local lightBar = barBG.LightBar
local darkBar = barBG.DarkBar
local vSIcon = barHolder.VSIcon
local vSText = barHolder:FindFirstChild("VSText")
local angelWing = parent.AngelWing
local demonWing = parent.DemonWing
local leftTeamAmountLabel = parent.LeftTeamAmountLabel
local rightTeamAmountLabel = parent.RightTeamAmountLabel
local v = lightBar.Size.X.Scale + darkBar.Size.X.Scale
local v2 = (1 - v) * 0.5

-- equivalent calls inferred from this helper; original call sites unknown
local function spring()
	return {
		p = 0,
		v = 0
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stepSpring(state, p: number)
	state.v += (state.p * -260 - state.v * 14) * p
	state.p += state.v * p
end

local function takeOverSprite(instance)
	local vector = Vector2.new(8, 4)
	local FPS = 24
	local playSprite = instance:FindFirstChild("PlaySprite")

	if playSprite and playSprite:IsA("LocalScript") then
		vector = playSprite:GetAttribute("Cells") or vector
		FPS = playSprite:GetAttribute("FPS") or FPS
		playSprite.Disabled = true
	end

	return {
		image = instance,
		columns = vector.X,
		frames = vector.X * vector.Y,
		baseFps = FPS,
		fps = FPS,
		frame = 0,
		accum = 0,
		baseSize = instance.Size,
		punch = spring()
	}
end

local function advanceSprite(state, p: number)
	state.accum += p
	local v3 = 1 / state.fps
	local flag = false

	while v3 <= state.accum do
		state.accum -= v3
		state.frame = (state.frame + 1) % state.frames
		flag = true
	end

	if flag then
		local imageRectSize = state.image.ImageRectSize
		state.image.ImageRectOffset = Vector2.new(
			imageRectSize.X * (state.frame % state.columns),
			imageRectSize.Y * math.floor(state.frame / state.columns)
		)
	end

	stepSpring(state.punch, p) -- equivalent call inferred; original call site unknown
	local v4 = state.punch.p + 1
	local baseSize = state.baseSize
	state.image.Size = UDim2.new(baseSize.X.Scale * v4, baseSize.X.Offset, baseSize.Y.Scale * v4, baseSize.Y.Offset)
	state.image.Rotation = state.punch.p * 40
end

local v3 = takeOverSprite(angelWing)
local v4 = takeOverSprite(demonWing)
local position = barHolder.Position
local position2 = vSIcon.Position
local size = vSIcon.Size
local position3 = vSText and vSText.Position
local size2 = vSText and vSText.Size
local size3 = leftTeamAmountLabel.Size
local size4 = rightTeamAmountLabel.Size
local textColor3 = leftTeamAmountLabel.TextColor3
local textColor32 = rightTeamAmountLabel.TextColor3
local color = Color3.fromRGB(255, 245, 190)
local color2 = Color3.fromRGB(255, 150, 150)

local function comma(p: number)
	local v5 = tostring((math.floor(p + 0.5)))

	repeat
		local v6
		v5, v6 = v5:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until v6 == 0

	return v5
end

local v5 = math.random() * 1000
local total = 0
local v6 = 0.5
local v7 = 0.5
local v8 = 0
local total2 = 0
local v9 = 0
local v10 = 1.5
local total3 = 0
local total4 = 0.5
local v11 = -1
local v12 = spring() -- equivalent call inferred; original call site unknown
local v13 = spring() -- equivalent call inferred; original call site unknown
local v14 = spring() -- equivalent call inferred; original call site unknown
local v15 = 0
local v16 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRatio(p: number)
	lightBar.Size = UDim2.new(v * p, 0, 1, 0)
	darkBar.Size = UDim2.new(v * (1 - p), 0, 1, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clash(p: number, flag: boolean)
	v15 = math.min(7, v15 + p * 7)
	v12.v += p * 9
	v16 += (flag and 1 or -1) * 26 * p

	if flag then
		v3.punch.v += p * 7
	else
		v4.punch.v += p * 7
	end
end

local function step(p: number)
	if not parent.Visible then
		return
	end

	local v17 = math.min(p, 0.1)
	total += v17
	v10 -= v17

	if v10 <= 0 then
		v10 = 1.5 + math.random() * 3
		local v18 = 0.5 + math.random()
		local v19 = math.random() < 0.5
		v9 = (v19 and 1 or -1) * 0.22 * v18
		clash(math.min(v18, 1), v19) -- equivalent call inferred; original call site unknown
	end

	v9 -= v9 * math.min(v17 * 1.6, 1)
	v6 = math.clamp(0.5 + math.noise(total * 0.32, v5) * 2 * 0.34 + v9, 0.12, 0.88)
	v8 += (v6 - v7) * 55 * v17
	v8 *= math.exp(v17 * -7)
	v7 = math.clamp(v7 + v8 * v17, 0.05, 0.95)
	applyRatio(v7) -- equivalent call inferred; original call site unknown
	total2 += (v8 - total2) * (1 - math.exp(v17 * -8))
	local v19 = math.clamp(total2 / 0.5, -1, 1)
	v3.fps = v3.baseFps + (90 - v3.baseFps) * math.max(v19, 0)
	v4.fps = v4.baseFps + (90 - v4.baseFps) * math.max(-v19, 0)
	advanceSprite(v3, v17)
	advanceSprite(v4, v17)
	local v20 = v * v7 + v2
	total4 += (v20 - total4) * (1 - math.exp(v17 * -22))
	stepSpring(v12, v17) -- equivalent call inferred; original call site unknown
	v16 -= v16 * math.min(v17 * 6, 1)
	local v22 = v12.p + 1
	local rotation = v19 * 10 + v16
	vSIcon.Position = UDim2.new(total4, position2.X.Offset, position2.Y.Scale, position2.Y.Offset)
	vSIcon.Size = UDim2.new(size.X.Scale * v22, size.X.Offset, size.Y.Scale * v22, size.Y.Offset)
	vSIcon.Rotation = rotation

	if vSText and position3 and size2 then
		vSText.Position = UDim2.new(total4, position3.X.Offset, position3.Y.Scale, position3.Y.Offset)
		vSText.Size = UDim2.new(size2.X.Scale * v22, size2.X.Offset, size2.Y.Scale * v22, size2.Y.Offset)
		vSText.Rotation = rotation
	end

	v15 -= v15 * math.min(v17 * 6, 1)

	if v15 > 0.05 then
		barHolder.Position = UDim2.new(
			position.X.Scale,
			position.X.Offset + (math.random() - 0.5) * 2 * v15,
			position.Y.Scale,
			position.Y.Offset + (math.random() - 0.5) * v15
		)
	elseif barHolder.Position ~= position then
		barHolder.Position = position
	end

	stepSpring(v13, v17) -- equivalent call inferred; original call site unknown
	stepSpring(v14, v17) -- equivalent call inferred; original call site unknown
	total3 += v17

	if total3 >= 0.08333333333333333 then
		total3 = 0
		local v26 = math.floor(v7 * 200000 + 0.5)

		if v11 >= 0 then
			local v27 = math.abs(v26 - v11) / 200000

			if v27 > 0.004 then
				local v28 = math.min(v27 * 60, 1) * 5

				if v11 < v26 then
					v13.v += v28
				else
					v14.v += v28
				end
			end
		end

		v11 = v26
		local text = comma(v26)
		local text2 = comma(200000 - v26)

		if leftTeamAmountLabel.Text ~= text then
			leftTeamAmountLabel.Text = text
		end

		if rightTeamAmountLabel.Text ~= text2 then
			rightTeamAmountLabel.Text = text2
		end
	end

	local v26 = v13.p * 0.5 + 1
	leftTeamAmountLabel.Size = UDim2.new(size3.X.Scale * v26, size3.X.Offset, size3.Y.Scale * v26, size3.Y.Offset)
	leftTeamAmountLabel.TextColor3 = textColor3:Lerp(color, (math.clamp(v13.p * 4, 0, 1)))
	local v27 = v14.p * 0.5 + 1
	rightTeamAmountLabel.Size = UDim2.new(size4.X.Scale * v27, size4.X.Offset, size4.Y.Scale * v27, size4.Y.Offset)
	rightTeamAmountLabel.TextColor3 = textColor32:Lerp(color2, (math.clamp(v14.p * 4, 0, 1)))
end

applyRatio(v7) -- equivalent call inferred; original call site unknown
local renderSteppedConnection = RunService.RenderStepped:Connect(step)
script.Destroying:Connect(function()
	renderSteppedConnection:Disconnect()
	barHolder.Position = position
	vSIcon.Position = position2
	vSIcon.Size = size
	vSIcon.Rotation = 0
	leftTeamAmountLabel.Size = size3
	rightTeamAmountLabel.Size = size4
	leftTeamAmountLabel.TextColor3 = textColor3
	rightTeamAmountLabel.TextColor3 = textColor32
	angelWing.Size = v3.baseSize
	demonWing.Size = v4.baseSize
	angelWing.Rotation = 0
	demonWing.Rotation = 0
end)