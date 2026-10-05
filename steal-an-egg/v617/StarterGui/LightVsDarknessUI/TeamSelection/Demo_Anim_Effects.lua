local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local v = {
	["rbxassetid://90736891527931"] = "ChooseTeam_Hover",
	["rbxassetid://135310337267680"] = "ChooseTeam_Select",
	["rbxassetid://91838958509194"] = "ChooseTeam_Deselect"
}
local parent = script.Parent.Parent
local main = parent:WaitForChild("Main")
local v2 = {}
local preRenderConnection = nil

local function easeOutBack(p: number)
	local v3 = p - 1
	return v3 * 2.70158 * v3 * v3 + 1 + v3 * 1.70158 * v3
end

local function easeOutQuad(p: number)
	local v3 = 1 - p
	return 1 - v3 * v3
end

local function grown(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

local function raised(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale, udim.X.Offset, udim.Y.Scale + p, udim.Y.Offset)
end

local function advance(state, p: number, p2: number, p3: number)
	if state.on then
		state.p = math.min(1, state.p + p / p2)
	else
		state.p = math.max(0, state.p - p / p3)
	end

	return state.p
end

local function frame(p: number)
	local v3 = p > 0.1 and 0.1 or p

	for i = #v2, 1, -1 do
		local v4 = v2[i]

		if not (v4.dead or not v4.update(v4, v3)) then
			continue
		end

		v4.running = false
		table.remove(v2, i)
	end

	if #v2 == 0 and preRenderConnection then
		preRenderConnection:Disconnect()
		preRenderConnection = nil
	end
end

local function wake(state)
	if state.running or state.dead then
		return
	end

	state.running = true
	table.insert(v2, state)

	if not preRenderConnection then
		preRenderConnection = RunService.PreRender:Connect(frame)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bind(instance, p)
	instance.Destroying:Connect(function()
		p.dead = true
	end)
end

local v3 = {}

local function loadSound(soundId: string)
	local sound = Instance.new("Sound")
	sound.Name = v[soundId] or "ChooseTeam_SFX"
	sound.SoundId = soundId
	sound.Volume = 0.5
	sound.Parent = SoundService
	v3[soundId] = sound
	return sound
end

-- equivalent calls inferred from this helper; original call sites unknown
local function play(soundId: string)
	local v4 = v3[soundId]

	if not v4 then
		v4 = Instance.new("Sound")
		v4.Name = v[soundId] or "ChooseTeam_SFX"
		v4.SoundId = soundId
		v4.Volume = 0.5
		v4.Parent = SoundService
		v3[soundId] = v4
	end

	v4.TimePosition = 0
	v4:Play()
end

for _, soundId in { "rbxassetid://90736891527931", "rbxassetid://135310337267680", "rbxassetid://91838958509194" } do
	local sound = Instance.new("Sound")
	sound.Name = v[soundId] or "ChooseTeam_SFX"
	sound.SoundId = soundId
	sound.Volume = 0.5
	sound.Parent = SoundService
	v3[soundId] = sound
end

script.Destroying:Connect(function()
	for _, v4 in v3 do
		v4:Destroy()
	end

	table.clear(v3)
end)

local function restCard(state)
	state.card.Size = state.cardSize
	state.card.ZIndex = state.cardZ
	state.hover.Visible = false
	state.hover.Position = state.idlePos
	state.hover.Size = state.idleSize
	state.hover.ImageTransparency = state.hoverAlpha
	state.idle.ImageTransparency = state.idleAlpha

	for k, v4 in state.fx do
		v4.ImageTransparency = state.fxAlpha[k]
	end

	state.phase = 0
	state.press = 1
end

local function updateCard(state, p: number)
	if state.on then
		state.p = math.min(1, state.p + p / 0.22)
	else
		state.p = math.max(0, state.p - p / 0.16)
	end

	local p2 = state.p
	local v4 = state.pressed and 0.95 or 1
	state.press += (v4 - state.press) * (1 - math.exp(-p / 0.09))
	local v5 = math.abs(state.press - 1) > 0.001

	if not v5 then
		state.press = 1
	end

	if p2 <= 0 and not (state.on or v5) then
		restCard(state)
		return false
	end

	local v6

	if state.on then
		local v7 = p2 - 1
		v6 = v7 * 2.70158 * v7 * v7 + 1 + v7 * 1.70158 * v7
	else
		local v7 = 1 - p2
		v6 = 1 - v7 * v7
	end

	local card = state.card
	local cardSize = state.cardSize
	local v7 = (v6 * 0.050000000000000044 + 1) * state.press
	card.Size = UDim2.new(cardSize.X.Scale * v7, cardSize.X.Offset * v7, cardSize.Y.Scale * v7, cardSize.Y.Offset * v7)
	state.phase = (state.phase + p * 0.9 * 6.283185307179586) % 6.283185307179586
	local v8 = math.sin(state.phase)
	local hover = state.hover
	local lerped = state.idlePos:Lerp(state.hoverPos, v6)
	local v9 = v8 * 0.014 * v6
	hover.Position = UDim2.new(lerped.X.Scale, lerped.X.Offset, lerped.Y.Scale + v9, lerped.Y.Offset)
	local hover2 = state.hover
	local lerped2 = state.idleSize:Lerp(state.hoverSize, v6)
	local v10 = v8 * 0.012 * v6 + 1
	hover2.Size = UDim2.new(
		lerped2.X.Scale * v10,
		lerped2.X.Offset * v10,
		lerped2.Y.Scale * v10,
		lerped2.Y.Offset * v10
	)
	local v11 = math.min(1, p2 * 1.35)
	state.hover.ImageTransparency = state.hoverAlpha + (1 - state.hoverAlpha) * (1 - v11)
	state.idle.ImageTransparency = state.idleAlpha + (1 - state.idleAlpha) * v11

	for k, v12 in state.fx do
		local v13 = state.fxAlpha[k]
		v12.ImageTransparency = v13 + (1 - v13) * (1 - v11)
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshCard(state)
	local enabled = (state.hovered or state.selected) and parent.Enabled

	if state.on ~= enabled then
		state.on = enabled

		if enabled then
			updateCard(state, 0)
			state.hover.Visible = true
			state.card.ZIndex = 100
		end
	end

	if not state.running then
		if state.dead then
			return
		end

		state.running = true
		table.insert(v2, state)

		if not preRenderConnection then
			preRenderConnection = RunService.PreRender:Connect(frame)
		end
	end
end

local function setupCard(button)
	local idleIcon = button:FindFirstChild("IdleIcon")
	local hoverIcon = button:FindFirstChild("HoverIcon")

	if not (idleIcon and idleIcon:IsA("ImageLabel") and hoverIcon and hoverIcon:IsA("ImageLabel")) then
		return nil
	end

	local images = {}
	local imageTransparencies = {}

	for _, image in hoverIcon:GetDescendants() do
		if not image:IsA("ImageLabel") then
			continue
		end

		table.insert(images, image)
		table.insert(imageTransparencies, image.ImageTransparency)
	end

	local v4 = {
		card = button,
		idle = idleIcon,
		hover = hoverIcon,
		fx = images,
		fxAlpha = imageTransparencies,
		idleAlpha = idleIcon.ImageTransparency,
		hoverAlpha = hoverIcon.ImageTransparency,
		cardSize = button.Size,
		cardZ = button.ZIndex,
		idlePos = idleIcon.Position,
		idleSize = idleIcon.Size,
		hoverPos = hoverIcon.Position,
		hoverSize = hoverIcon.Size,
		p = 0,
		phase = 0,
		press = 1,
		on = false,
		hovered = false,
		selected = false,
		pressed = false,
		running = false,
		dead = false,
		update = updateCard
	}
	hoverIcon.ZIndex = 999
	hoverIcon.Active = false
	restCard(v4)
	button.MouseEnter:Connect(function()
		v4.hovered = true
		play("rbxassetid://90736891527931") -- equivalent call inferred; original call site unknown
		refreshCard(v4) -- equivalent call inferred; original call site unknown
	end)
	button.MouseLeave:Connect(function()
		v4.hovered = false
		v4.pressed = false
		refreshCard(v4) -- equivalent call inferred; original call site unknown
	end)
	button.MouseButton1Down:Connect(function()
		v4.pressed = true
		local v5 = v4

		if not v5.running then
			if v5.dead then
				return
			end

			v5.running = true
			table.insert(v2, v5)

			if not preRenderConnection then
				preRenderConnection = RunService.PreRender:Connect(frame)
			end
		end
	end)
	button.MouseButton1Up:Connect(function()
		v4.pressed = false
		local v5 = v4

		if not v5.running then
			if v5.dead then
				return
			end

			v5.running = true
			table.insert(v2, v5)

			if not preRenderConnection then
				preRenderConnection = RunService.PreRender:Connect(frame)
			end
		end
	end)
	button.TouchTap:Connect(function()
		v4.pressed = false
		local v5 = v4

		if not v5.running then
			if v5.dead then
				return
			end

			v5.running = true
			table.insert(v2, v5)

			if not preRenderConnection then
				preRenderConnection = RunService.PreRender:Connect(frame)
			end
		end
	end)
	bind(button, v4) -- equivalent call inferred; original call site unknown
	return v4
end

local function updateStroke(state, p: number)
	if state.on then
		state.p = math.min(1, state.p + p / 0.26)
	else
		state.p = math.max(0, state.p - p / 0.18)
	end

	local p2 = state.p

	if p2 <= 0 and not state.on then
		state.stroke.Enabled = false
		state.stroke.Thickness = state.thickness
		state.stroke.Transparency = state.transparency
		return false
	else
		local v4

		if state.on then
			local v5 = p2 - 1
			v4 = v5 * 2.70158 * v5 * v5 + 1 + v5 * 1.70158 * v5
		else
			local v5 = 1 - p2
			v4 = 1 - v5 * v5
		end

		state.stroke.Enabled = true
		state.stroke.Thickness = math.max(0, state.thickness * v4)
		state.stroke.Transparency = state.transparency + (1 - state.transparency) * (1 - p2)
		return true
	end
end

local function setupStroke(button)
	local strokeHolder = button:FindFirstChild("StrokeHolder")
	local selectedUIStroke = strokeHolder and strokeHolder:FindFirstChild("SelectedUIStroke")

	if not (selectedUIStroke and selectedUIStroke:IsA("UIStroke")) then
		return nil
	end

	local v4 = {
		stroke = selectedUIStroke,
		thickness = selectedUIStroke.Thickness,
		transparency = selectedUIStroke.Transparency,
		p = 0,
		on = false,
		running = false,
		dead = false,
		update = updateStroke
	}
	selectedUIStroke.Enabled = false
	bind(button, v4) -- equivalent call inferred; original call site unknown
	return v4
end

local v4 = {}
local v5 = {}
local v6 = nil

local function select(p)
	if v6 == p then
		p = nil
	end

	v6 = p
	play(v6 and "rbxassetid://135310337267680" or "rbxassetid://91838958509194") -- equivalent call inferred; original call site unknown

	for k, v8 in v5 do
		local on = k == v6

		if v8.on == on then
			continue
		end

		v8.on = on

		if v8.running or v8.dead then
			continue
		end

		v8.running = true
		table.insert(v2, v8)

		if not preRenderConnection then
			preRenderConnection = RunService.PreRender:Connect(frame)
		end
	end

	for k, v8 in v4 do
		v8.selected = k == v6
		refreshCard(v8) -- equivalent call inferred; original call site unknown
	end
end

local teamHolder = main:FindFirstChild("TeamHolder")

if teamHolder then
	for _, button in teamHolder:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v7 = setupCard(button)

		if v7 then
			v4[button] = v7
		end

		local v8 = setupStroke(button)

		if v8 then
			v5[button] = v8
		end

		button.Active = true
		local v9 = button
		button.Activated:Connect(function()
			select(v9)
		end)
	end
end

parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	for _, v7 in v4 do
		if not parent.Enabled then
			v7.hovered = false
			v7.pressed = false
		end

		refreshCard(v7) -- equivalent call inferred; original call site unknown
	end
end)