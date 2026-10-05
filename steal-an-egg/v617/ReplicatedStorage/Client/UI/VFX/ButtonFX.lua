local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.Shared.Audio)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local GUI = require(ReplicatedStorage.Client.GUI)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local v = {
	bound = "PressBound",
	glyph = "PressGlyph",
	silent = "MuteSounds",
	ownedScale = "PressScaleOwner"
}
local vector = Vector2.new(0.5, 0.5)
local uDim = UDim2.fromScale(0, 0.08)
local tweenInfo = TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v2 = {
	intoSunk = 42,
	outOfSunk = 26,
	hover = 22
}
local v3 = {
	id = Constants.BUTTON_FX.BUTTON_MOUSE_DOWN_SOUND,
	volume = 3.4,
	pitch = NumberRange.new(0.93, 1.06)
}
local random = Random.new()
local count = 0
local v4 = {}
local v5 = {}
local preRenderConnection = nil

local function noop() end

local function stepMotions(p: number)
	for k, v6 in v5 do
		if k.Parent == nil then
			v5[k] = nil
		else
			local v7 = k.Scale - v6.target
			local v8 = math.exp(-v6.stiffness * p)
			local v9 = (v6.velocity + v6.stiffness * v7) * p
			local v10 = (v7 + v9) * v8
			v6.velocity = (v6.velocity - v6.stiffness * v9) * v8

			if math.abs(v10) < 0.0005 and math.abs(v6.velocity) < 0.0005 then
				k.Scale = v6.target
				v5[k] = nil
			else
				k.Scale = v6.target + v10
			end
		end
	end

	if preRenderConnection and next(v5) == nil then
		preRenderConnection:Disconnect()
		preRenderConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function drive(scale, target: number, intoSunk: number)
	local v6 = v5[scale]

	if v6 then
		v6.target = target
		v6.stiffness = intoSunk
	else
		v5[scale] = {
			target = target,
			velocity = 0,
			stiffness = intoSunk
		}
	end

	if preRenderConnection == nil then
		preRenderConnection = RunService.PreRender:Connect(stepMotions)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function accepting(p)
	return p.host.Active and p.input.GuiState ~= Enum.GuiState.NonInteractable
end

local function poseOf(data)
	if not accepting(data) then
		return "Rest"
	end

	local guiState = data.input.GuiState

	if data.gamepadHeld or guiState == Enum.GuiState.Press then
		return "Sunk"
	end

	if guiState == Enum.GuiState.Hover and PlatformController.IsDesktop() then
		return "Raised"
	end

	return "Rest"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaleFor(state, p: string)
	if p == "Sunk" then
		return state.sunkScale
	elseif p == "Raised" then
		return state.raisedScale
	end

	return 1
end

local function stiffnessFor(p: string, p2: string)
	if p2 == "Sunk" then
		return 42
	end

	if p == "Sunk" then
		return 26
	end

	return 22
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playPressCue(cueGain: number)
	Audio.Play(v3.id, script, {
		PlaybackSpeed = random:NextNumber(v3.pitch.Min, v3.pitch.Max),
		Volume = cueGain
	})
end

local function placeGlyph(state, p: string)
	local glyph = state.glyph

	if glyph == nil then
		return
	end

	local position

	if p == "Sunk" then
		position = state.glyphRest + uDim
	else
		position = state.glyphRest
	end

	TweenService:Create(glyph, tweenInfo, {
		Position = position
	}):Play()
end

local function refresh(state)
	local pose = state.pose
	local pose2

	if accepting(state) then
		local guiState = state.input.GuiState
		pose2 = (state.gamepadHeld or guiState == Enum.GuiState.Press) and "Sunk" or guiState == Enum.GuiState.Hover and PlatformController.IsDesktop() and "Raised" or "Rest"
	else
		pose2 = "Rest"
	end

	if pose == pose2 then
		return
	end

	state.pose = pose2

	if pose2 == "Sunk" and state.cueGain then
		playPressCue(state.cueGain) -- equivalent call inferred; original call site unknown
	end

	local scale = state.scale
	local target = scaleFor(state, pose2) -- equivalent call inferred; original call site unknown
	local intoSunk

	if pose2 == "Sunk" then
		intoSunk = v2.intoSunk
	elseif pose == "Sunk" then
		intoSunk = v2.outOfSunk
	else
		intoSunk = v2.hover
	end

	drive(scale, target, intoSunk) -- equivalent call inferred; original call site unknown
	placeGlyph(state, pose2)
end

local function centerAnchor(host)
	local anchorPoint = host.AnchorPoint

	if anchorPoint == vector then
		return
	end

	local position = host.Position
	local size = host.Size
	local v6 = vector - anchorPoint
	host.AnchorPoint = vector
	local parent = host.Parent
	local v7 = host:FindFirstChildWhichIsA("UIAspectRatioConstraint") ~= nil or host:FindFirstChildWhichIsA("UISizeConstraint") ~= nil
	local absoluteSize = host.AbsoluteSize
	local zero

	if parent == nil or not parent:IsA("GuiBase2d") then
		zero = Vector2.zero
	else
		zero = parent.AbsoluteSize
	end

	if v7 and absoluteSize.X > 0 and absoluteSize.Y > 0 and zero.X > 0 and zero.Y > 0 then
		host.Position = UDim2.new(
			position.X.Scale + absoluteSize.X * v6.X / zero.X,
			position.X.Offset,
			position.Y.Scale + absoluteSize.Y * v6.Y / zero.Y,
			position.Y.Offset
		)
	else
		host.Position = UDim2.new(
			position.X.Scale + size.X.Scale * v6.X,
			position.X.Offset + size.X.Offset * v6.X,
			position.Y.Scale + size.Y.Scale * v6.Y,
			position.Y.Offset + size.Y.Offset * v6.Y
		)
	end
end

local function adoptScale(parent)
	local uIScale = parent:FindFirstChildOfClass("UIScale")

	if uIScale and uIScale:IsA("UIScale") then
		return uIScale
	end

	local uIScale2 = Instance.new("UIScale")
	uIScale2.Name = "PressScale"
	uIScale2.Parent = parent
	return uIScale2
end

local function findGlyph(instance)
	local pressGlyph = instance:GetAttribute("PressGlyph")

	if type(pressGlyph) ~= "string" then
		return nil
	end

	local guiObject = instance:FindFirstChild(pressGlyph)

	if guiObject and guiObject:IsA("GuiObject") then
		return guiObject
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function mirrorActive(p)
	local host = p.host
	local input = p.input

	if input ~= host then
		input.Active = host.Active
		input.Selectable = host.Active
	end
end

local function liveBinding(instance)
	local pressBound = instance:GetAttribute("PressBound")

	if type(pressBound) ~= "number" then
		return nil
	end

	local v6 = v4[pressBound]

	if v6 and v6.host == instance then
		return v6
	end

	return nil
end

local function unbind(state)
	if v4[state.serial] ~= state then
		return
	end

	v4[state.serial] = nil

	for _, link in state.links do
		link:Disconnect()
	end

	table.clear(state.links)
	local activation = state.activation

	if activation then
		activation:Disconnect()
		state.activation = nil
	end

	local host = state.host

	if host:GetAttribute("PressBound") == state.serial then
		host:SetAttribute("PressBound", nil)
	end

	v5[state.scale] = nil

	if state.scale.Parent then
		state.scale.Scale = 1
	end

	local glyph = state.glyph

	if glyph then
		glyph.Position = state.glyphRest
	end

	if state.ownsInput then
		state.input:Destroy()
	end
end

local function wire(state)
	local host = state.host
	local input = state.input
	local links = state.links
	table.insert(links, input:GetPropertyChangedSignal("GuiState"):Connect(function()
		refresh(state)
	end))
	table.insert(links, input.InputBegan:Connect(function(input2)
		if input2.KeyCode == Enum.KeyCode.ButtonA then
			state.gamepadHeld = true
			refresh(state)
		end
	end))
	table.insert(links, input.InputEnded:Connect(function(input2)
		if input2.KeyCode == Enum.KeyCode.ButtonA then
			state.gamepadHeld = false
			refresh(state)
		end
	end))
	table.insert(links, host:GetPropertyChangedSignal("Active"):Connect(function()
		mirrorActive(state) -- equivalent call inferred; original call site unknown
		refresh(state)
	end))
	table.insert(links, host.Destroying:Connect(function()
		unbind(state)
	end))
	local onActivate = state.onActivate

	if onActivate then
		state.activation = GUI.OnActivated(input, function()
			if accepting(state) then
				onActivate()
			end
		end)
	end
end

local function bind(data)
	local host = data.host
	local attribute = host:GetAttribute(v.bound)
	local v6

	if type(attribute) == "number" then
		v6 = v4[attribute]

		if not v6 or v6.host ~= host then
			v6 = nil
		end
	end

	if v6 then
		return noop
	end

	centerAnchor(host)
	local scale = host:FindFirstChildOfClass("UIScale")

	if not (scale and scale:IsA("UIScale")) then
		scale = Instance.new("UIScale")
		scale.Name = "PressScale"
		scale.Parent = host
	end

	scale:SetAttribute("PressScaleOwner", true)
	local attribute2 = host:GetAttribute(v.glyph)
	local guiObject

	if type(attribute2) == "string" then
		guiObject = host:FindFirstChild(attribute2)

		if not (guiObject and guiObject:IsA("GuiObject")) then
			guiObject = nil
		end
	end

	local v8 = data.silent == true or host:GetAttribute("MuteSounds") == true
	count += 1
	local v9 = {
		serial = count,
		host = host,
		input = data.input,
		scale = scale,
		glyph = guiObject,
		glyphRest = 0,
		raisedScale = 0,
		sunkScale = 0,
		pose = "Rest",
		gamepadHeld = false,
		cueGain = 0,
		onActivate = 0,
		ownsInput = 0,
		links = 0,
		activation = nil
	}
	local glyphRest

	if guiObject then
		glyphRest = guiObject.Position
	else
		glyphRest = UDim2.new()
	end

	v9.glyphRest = glyphRest
	v9.raisedScale = data.peakScale or 1.07
	v9.sunkScale = data.pressedScale or 0.94
	local cueGain

	if not v8 then
		cueGain = data.cueGain or v3.volume
	end

	v9.cueGain = cueGain
	v9.onActivate = data.onActivate
	v9.ownsInput = data.ownsInput == true
	v9.links = {}
	v4[v9.serial] = v9
	host:SetAttribute("PressBound", v9.serial)
	mirrorActive(v9) -- equivalent call inferred; original call site unknown
	wire(v9)
	return function()
		unbind(v9)
	end
end

return function(button, peakScale: number?, onActivate, silent: boolean?)
	if typeof(button) == "table" then
		return (bind(button))
	end

	local v6

	if typeof(button) == "Instance" then
		v6 = button:IsA("GuiButton")
	else
		v6 = false
	end

	assert(v6, "ButtonFX needs a GuiButton")
	assert(peakScale == nil or type(peakScale) == "number", "ButtonFX peak scale must be a number")
	assert(onActivate == nil or type(onActivate) == "function", "ButtonFX activation handler must be a function")
	return (bind({
		host = button,
		input = button,
		peakScale = peakScale,
		onActivate = onActivate,
		silent = silent
	}))
end