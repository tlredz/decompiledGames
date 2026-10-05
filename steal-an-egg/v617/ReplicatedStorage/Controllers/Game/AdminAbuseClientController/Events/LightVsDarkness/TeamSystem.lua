local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local GUI = require(ReplicatedStorage.Client.GUI)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
require(ReplicatedStorage.Packages.Trove)
local v = {
	LightTeam = "Light",
	DarkTeam = "Darkness"
}
local v2 = {
	["rbxassetid://90736891527931"] = "ChooseTeam_Hover",
	["rbxassetid://135310337267680"] = "ChooseTeam_Select",
	["rbxassetid://91838958509194"] = "ChooseTeam_Deselect"
}
local localPlayer = Players.LocalPlayer
local v3 = nil
local v4 = nil
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = nil
local v9 = {}
local v10 = {}
local preRenderConnection = nil
local v11 = false
local count = 0

local function easeOutBack(p: number)
	local v12 = p - 1
	return v12 * 2.70158 * v12 * v12 + 1 + v12 * 1.70158 * v12
end

local function easeOutQuad(p: number)
	local v12 = 1 - p
	return 1 - v12 * v12
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
	local v12 = p > 0.1 and 0.1 or p

	for i = #v10, 1, -1 do
		local v13 = v10[i]

		if not (v13.dead or not v13.update(v13, v12)) then
			continue
		end

		v13.running = false
		table.remove(v10, i)
	end

	if #v10 == 0 and preRenderConnection then
		preRenderConnection:Disconnect()
		preRenderConnection = nil
	end
end

local function wake(state)
	if state.running or state.dead then
		return
	end

	state.running = true
	table.insert(v10, state)

	if not preRenderConnection then
		preRenderConnection = RunService.PreRender:Connect(frame)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function play(soundId: string)
	local v12 = v9[soundId]

	if v12 == nil then
		v12 = Instance.new("Sound")
		v12.Name = v2[soundId] or "ChooseTeam_SFX"
		v12.SoundId = soundId
		v12.Volume = 0.5
		v12.Parent = SoundService
		v9[soundId] = v12
	end

	v12.TimePosition = 0
	v12:Play()
end

local function restCard(state)
	state.card.Size = state.cardSize
	state.card.ZIndex = state.cardZ
	state.hover.Visible = false
	state.hover.Position = state.idlePos
	state.hover.Size = state.idleSize
	state.hover.ImageTransparency = state.hoverAlpha
	state.idle.ImageTransparency = state.idleAlpha

	for k, v12 in state.fx do
		v12.ImageTransparency = state.fxAlpha[k]
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
	local v12 = state.pressed and 0.95 or 1
	state.press += (v12 - state.press) * (1 - math.exp(-p / 0.09))
	local v13 = math.abs(state.press - 1) > 0.001

	if not v13 then
		state.press = 1
	end

	if p2 <= 0 and not (state.on or v13) then
		restCard(state)
		return false
	end

	local v14

	if state.on then
		local v15 = p2 - 1
		v14 = v15 * 2.70158 * v15 * v15 + 1 + v15 * 1.70158 * v15
	else
		local v15 = 1 - p2
		v14 = 1 - v15 * v15
	end

	local card = state.card
	local cardSize = state.cardSize
	local v15 = (v14 * 0.050000000000000044 + 1) * state.press
	card.Size = UDim2.new(
		cardSize.X.Scale * v15,
		cardSize.X.Offset * v15,
		cardSize.Y.Scale * v15,
		cardSize.Y.Offset * v15
	)
	state.phase = (state.phase + p * 0.9 * 6.283185307179586) % 6.283185307179586
	local v16 = math.sin(state.phase)
	local hover = state.hover
	local lerped = state.idlePos:Lerp(state.hoverPos, v14)
	local v17 = v16 * 0.014 * v14
	hover.Position = UDim2.new(lerped.X.Scale, lerped.X.Offset, lerped.Y.Scale + v17, lerped.Y.Offset)
	local hover2 = state.hover
	local lerped2 = state.idleSize:Lerp(state.hoverSize, v14)
	local v18 = v16 * 0.012 * v14 + 1
	hover2.Size = UDim2.new(
		lerped2.X.Scale * v18,
		lerped2.X.Offset * v18,
		lerped2.Y.Scale * v18,
		lerped2.Y.Offset * v18
	)
	local v19 = math.min(1, p2 * 1.35)
	state.hover.ImageTransparency = state.hoverAlpha + (1 - state.hoverAlpha) * (1 - v19)
	state.idle.ImageTransparency = state.idleAlpha + (1 - state.idleAlpha) * v19

	for k, v20 in state.fx do
		local v21 = state.fxAlpha[k]
		v20.ImageTransparency = v21 + (1 - v21) * (1 - v19)
	end

	return true
end

local function panelShown()
	return v4 ~= nil and v4.Visible
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshCard(state)
	local hovered = state.hovered or state.selected

	if hovered then
		local v12 = v4

		if v12 == nil then
			hovered = false
		else
			hovered = v12.Visible
		end
	end

	if state.on ~= hovered then
		state.on = hovered

		if hovered then
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
		table.insert(v10, state)

		if not preRenderConnection then
			preRenderConnection = RunService.PreRender:Connect(frame)
		end
	end
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
		local v12

		if state.on then
			local v13 = p2 - 1
			v12 = v13 * 2.70158 * v13 * v13 + 1 + v13 * 1.70158 * v13
		else
			local v13 = 1 - p2
			v12 = 1 - v13 * v13
		end

		state.stroke.Enabled = true
		state.stroke.Thickness = math.max(0, state.thickness * v12)
		state.stroke.Transparency = state.transparency + (1 - state.transparency) * (1 - p2)
		return true
	end
end

local function select(state)
	if v8 == state then
		state = nil
	end

	v8 = state
	play(v8 and "rbxassetid://135310337267680" or "rbxassetid://91838958509194") -- equivalent call inferred; original call site unknown

	for k, v13 in v7 do
		local on = k == v8

		if v13.on == on then
			continue
		end

		v13.on = on

		if v13.running or v13.dead then
			continue
		end

		v13.running = true
		table.insert(v10, v13)

		if not preRenderConnection then
			preRenderConnection = RunService.PreRender:Connect(frame)
		end
	end

	for k, v13 in v6 do
		v13.selected = k == v8
		refreshCard(v13) -- equivalent call inferred; original call site unknown
	end
end

local function cardParts(instance)
	local idleIcon = instance:FindFirstChild("IdleIcon")
	local hoverIcon = instance:FindFirstChild("HoverIcon")
	assert(
		idleIcon and idleIcon:IsA("ImageLabel") and hoverIcon and hoverIcon:IsA("ImageLabel"),
		(`{instance:GetFullName()} needs an IdleIcon and a HoverIcon`)
	)
	local strokeHolder = instance:FindFirstChild("StrokeHolder")
	local selectedUIStroke

	if strokeHolder then
		selectedUIStroke = strokeHolder:FindFirstChild("SelectedUIStroke")
	end

	assert(
		selectedUIStroke and selectedUIStroke:IsA("UIStroke"),
		(`{instance:GetFullName()} needs a StrokeHolder.SelectedUIStroke`)
	)
	return idleIcon, hoverIcon, selectedUIStroke
end

local function authoredFor(p)
	local v12 = v5[p]

	if v12 then
		return v12
	end

	local v13, folder, v14 = cardParts(p)
	local imageTransparenciesByImage = {}

	for _, image in folder:GetDescendants() do
		if image:IsA("ImageLabel") then
			imageTransparenciesByImage[image] = image.ImageTransparency
		end
	end

	local v15 = {
		CardSize = p.Size,
		CardZ = p.ZIndex,
		IdleAlpha = v13.ImageTransparency,
		IdlePos = v13.Position,
		IdleSize = v13.Size,
		HoverAlpha = folder.ImageTransparency,
		HoverPos = folder.Position,
		HoverSize = folder.Size,
		FxAlpha = imageTransparenciesByImage,
		StrokeThickness = v14.Thickness,
		StrokeTransparency = v14.Transparency
	}
	v5[p] = v15
	return v15
end

local function setupCard(button, assetTrove)
	local idle, folder = cardParts(button)
	local v13 = authoredFor(button)
	local images = {}
	local fxAlpha = {}

	for _, image in folder:GetDescendants() do
		if not image:IsA("ImageLabel") then
			continue
		end

		table.insert(images, image)
		table.insert(fxAlpha, v13.FxAlpha[image] or image.ImageTransparency)
	end

	local v15 = {
		card = button,
		idle = idle,
		hover = folder,
		fx = images,
		fxAlpha = fxAlpha,
		idleAlpha = v13.IdleAlpha,
		hoverAlpha = v13.HoverAlpha,
		cardSize = v13.CardSize,
		cardZ = v13.CardZ,
		idlePos = v13.IdlePos,
		idleSize = v13.IdleSize,
		hoverPos = v13.HoverPos,
		hoverSize = v13.HoverSize,
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
	folder.ZIndex = 999
	folder.Active = false
	restCard(v15)
	assetTrove:Connect(button.MouseEnter, function()
		v15.hovered = true
		play("rbxassetid://90736891527931") -- equivalent call inferred; original call site unknown
		refreshCard(v15) -- equivalent call inferred; original call site unknown
	end)
	assetTrove:Connect(button.MouseLeave, function()
		v15.hovered = false
		v15.pressed = false
		refreshCard(v15) -- equivalent call inferred; original call site unknown
	end)
	assetTrove:Connect(button.MouseButton1Down, function()
		v15.pressed = true
		local v16 = v15

		if not v16.running then
			if v16.dead then
				return
			end

			v16.running = true
			table.insert(v10, v16)

			if not preRenderConnection then
				preRenderConnection = RunService.PreRender:Connect(frame)
			end
		end
	end)
	assetTrove:Connect(button.MouseButton1Up, function()
		v15.pressed = false
		local v16 = v15

		if not v16.running then
			if v16.dead then
				return
			end

			v16.running = true
			table.insert(v10, v16)

			if not preRenderConnection then
				preRenderConnection = RunService.PreRender:Connect(frame)
			end
		end
	end)
	assetTrove:Connect(button.TouchTap, function()
		v15.pressed = false
		local v16 = v15

		if not v16.running then
			if v16.dead then
				return
			end

			v16.running = true
			table.insert(v10, v16)

			if not preRenderConnection then
				preRenderConnection = RunService.PreRender:Connect(frame)
			end
		end
	end)
	button.Active = true
	assetTrove:Connect(button.Activated, function()
		select(button)
	end)
	return v15
end

local function setupStroke(button)
	local _, _, stroke = cardParts(button)
	local v13 = authoredFor(button)
	local v14 = {
		stroke = stroke,
		thickness = v13.StrokeThickness,
		transparency = v13.StrokeTransparency,
		p = 0,
		on = false,
		running = false,
		dead = false,
		update = updateStroke
	}
	stroke.Enabled = false
	return v14
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasTeam()
	return type(localPlayer:GetAttribute("LvdTeam")) == "string"
end

local function autoPick(p: number)
	local v12 = v8

	if p == count and v11 then
		local v13 = v4
		local v14

		if v13 == nil then
			v14 = false
		else
			v14 = v13.Visible
		end

		if v14 and type(localPlayer:GetAttribute("LvdTeam")) ~= "string" then
			Remotes.LightVsDarkness.AskSelectTeam:FireServer(not v12 and "Random" or v[v12.Name])
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPanelShown(visible: boolean)
	local v12 = v4

	if v12 == nil or v12.Visible == visible then
		return
	end

	v12.Visible = visible
	count += 1

	if visible then
		task.delay(20, autoPick, count)
	end

	for _, v13 in v6 do
		if not visible then
			v13.hovered = false
			v13.pressed = false
		end

		refreshCard(v13) -- equivalent call inferred; original call site unknown
	end
end

local function confirm()
	local v12 = v8

	if not v11 or v12 == nil or type(localPlayer:GetAttribute("LvdTeam")) == "string" then
		return
	end

	Remotes.LightVsDarkness.AskSelectTeam:FireServer(v[v12.Name])
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh()
	local v13 = v11

	if v13 then
		local team = hasTeam() -- equivalent call inferred; original call site unknown
		v13 = not team
	end

	setPanelShown(v13)
end

local function start()
	local assetTrove = v3.AssetTrove
	local teamSelection = GUI.LightVsDarknessUI():FindFirstChild("TeamSelection")
	assert(teamSelection and teamSelection:IsA("Frame"), "LightVsDarknessUI.TeamSelection must be a Frame")
	v4 = teamSelection
	v11 = true
	v8 = nil
	table.clear(v6)
	table.clear(v7)
	local teamHolder = teamSelection:FindFirstChild("TeamHolder")
	assert(teamHolder, "TeamSelection.TeamHolder is missing")

	for _, button in teamHolder:GetChildren() do
		if not (button:IsA("ImageButton") and v[button.Name] ~= nil) then
			continue
		end

		v6[button] = setupCard(button, assetTrove)
		v7[button] = setupStroke(button)
	end

	local confirmBTN = teamSelection:FindFirstChild("ConfirmBTN")
	assert(confirmBTN and confirmBTN:IsA("ImageButton"), "TeamSelection.ConfirmBTN must be an ImageButton")
	GUI.OnActivated(confirmBTN, confirm)
	assetTrove:Connect(localPlayer:GetAttributeChangedSignal("LvdTeam"), refresh)
	assetTrove:Add(function()
		v11 = false
		setPanelShown(false) -- equivalent call inferred; original call site unknown

		for _, v12 in v6 do
			v12.dead = true
			restCard(v12)
		end

		for _, v12 in v7 do
			v12.dead = true
			v12.stroke.Enabled = false
			v12.stroke.Thickness = v12.thickness
			v12.stroke.Transparency = v12.transparency
		end

		table.clear(v6)
		table.clear(v7)
		v8 = nil

		if preRenderConnection then
			preRenderConnection:Disconnect()
			preRenderConnection = nil
		end

		table.clear(v10)

		for _, v12 in v9 do
			v12:Destroy()
		end

		table.clear(v9)
	end)
	refresh() -- equivalent call inferred; original call site unknown
end

local function stop()
	v11 = false
	local v12 = v4

	if v12 ~= nil then
		if v12.Visible == false then
			return
		end

		v12.Visible = false
		count += 1

		for _, v13 in v6 do
			v13.hovered = false
			v13.pressed = false
			refreshCard(v13) -- equivalent call inferred; original call site unknown
		end
	end
end

return function(p)
	v3 = p
	return {
		Start = start,
		Stop = stop
	}
end