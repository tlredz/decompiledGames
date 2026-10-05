local UserInputService = game:GetService("UserInputService")
local Ticker = require(script.Parent:WaitForChild("Ticker"))
local v = nil
local FX = {}
local abs = math.abs
local floor = math.floor
local cos = math.cos
local sin = math.sin
FX.Hz = UserInputService.TouchEnabled and 30 or 60
FX.enabled = true
local vectors = table.create(91)

for i = 0, 90 do
	vectors[i + 1] = Vector2.new(i * 1.5 / 90 + -0.75, 0)
end

local offset = vectors[91]
local random = Random.new()
local v3 = {
	beam = {},
	line = {},
	shine = {},
	glow = {},
	dots = {}
}
local v4 = table.create(64)
local idx2 = 0
local number = random:NextNumber(0, 100)
local v6 = nil

local function step(p)
	number += p
	local v7 = number

	for i = 1, idx2 do
		local v8 = v4[i]
		local kind = v8.kind

		if kind == 1 then
			local v9 = (v7 * v8.speed + v8.phase) % 360

			if abs(v9 - v8.last) >= 0.3 then
				v8.inst.Rotation = v9
				v8.last = v9
			end
		elseif kind == 2 then
			local v9 = (v7 + v8.phase) % v8.period
			local last

			if v9 < v8.sweep then
				last = floor(v9 / v8.sweep * 90) + 1 or 91
			else
				last = 91
			end

			if last ~= v8.last then
				v8.inst.Offset = vectors[last]
				v8.last = last
			end
		elseif kind == 3 then
			local last = v8.from + v8.span * (0.5 - cos(v7 * v8.speed + v8.phase) * 0.5)

			if abs(last - v8.last) >= 0.004 then
				v8.inst[v8.prop] = last
				v8.last = last
			end
		elseif kind == 5 then
			local last = floor((0.5 - cos(v7 * v8.speed + v8.phase) * 0.5) * 24 + 0.5) + 1

			if last ~= v8.last then
				v8.inst[v8.prop] = v8.steps[last]
				v8.last = last
			end
		else
			local scales = v8.scales
			local objs = v8.objs
			local props = v8.props
			local rest = v8.rest
			local lasts = v8.lasts
			local v9 = v7 * v8.speed + v8.phase

			for i2 = 1, v8.n do
				local v10 = (v9 - (i2 - 1) * v8.gap) % 1
				local v11

				if v10 < 0.4 then
					v11 = sin(v10 * 2.5 * 3.141592653589793) or 0
				else
					v11 = 0
				end

				if not (abs(v11 - lasts[i2]) >= 0.01) then
					continue
				end

				lasts[i2] = v11
				scales[i2].Scale = 1 + v8.amount * v11
				local v13 = rest[i2]
				objs[i2][props[i2]] = v13 + (1 - v13) * v8.dim * (1 - v11)
			end
		end
	end
end

FX._step = step

local function wake()
	if v6 or idx2 == 0 then
		return
	end

	v6 = FX.Hz >= 60 and Ticker.add(step) or Ticker.every(1 / FX.Hz, step)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sleep()
	if v6 then
		v6:Stop()
		v6 = nil
	end
end

local function park(state)
	local kind = state.kind

	if kind == 1 then
		state.stroke.Enabled = false
	elseif kind == 2 then
		state.inst.Offset = offset
		state.last = 91

		if state.stroke then
			state.stroke.Enabled = false
		end
	elseif kind == 3 then
		state.inst[state.prop] = state.from
		state.last = state.from
	elseif kind == 5 then
		state.inst[state.prop] = state.from
		state.last = 1
	else
		for i = 1, state.n do
			state.scales[i].Scale = 1
			state.objs[i][state.props[i]] = state.rest[i]
			state.lasts[i] = -1
		end
	end
end

local function unpark(p)
	if p.kind == 1 then
		p.stroke.Enabled = true
	elseif p.kind == 2 and p.stroke then
		p.stroke.Enabled = true
	end
end

local function enter(state)
	if state.idx ~= 0 then
		return
	end

	idx2 += 1
	v4[idx2] = state
	state.idx = idx2

	if state.kind == 1 then
		state.stroke.Enabled = true
	elseif state.kind == 2 and state.stroke then
		state.stroke.Enabled = true
	end

	if not v6 then
		if idx2 == 0 then
			return
		else
			v6 = FX.Hz >= 60 and Ticker.add(step) or Ticker.every(1 / FX.Hz, step)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function leave(p)
	local idx = p.idx

	if idx == 0 then
		return
	end

	local v7 = v4[idx2]
	v4[idx] = v7
	v7.idx = idx
	v4[idx2] = nil
	idx2 -= 1
	p.idx = 0
	park(p)

	if idx2 == 0 and v6 then
		v6:Stop()
		v6 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sync(state)
	if state.shown and state.on and FX.enabled then
		if state.idx ~= 0 then
			return
		end

		idx2 += 1
		v4[idx2] = state
		state.idx = idx2

		if state.kind == 1 then
			state.stroke.Enabled = true
		elseif state.kind == 2 and state.stroke then
			state.stroke.Enabled = true
		end

		if not v6 then
			if idx2 == 0 then
				return
			end

			v6 = FX.Hz >= 60 and Ticker.add(step) or Ticker.every(1 / FX.Hz, step)
		end
	else
		leave(state) -- equivalent call inferred; original call site unknown
	end
end

local class = {}
class.__index = class

function class:SetActive(p2)
	local _r = self._r

	if _r.dead then
		return self
	end

	_r.on = p2 and true or false
	sync(_r) -- equivalent call inferred; original call site unknown
	return self
end

function class:IsRunning()
	return self._r.idx ~= 0
end

function class:Stop()
	local _r = self._r

	if _r.dead then
		return
	end

	_r.dead = true
	leave(_r) -- equivalent call inferred; original call site unknown
	_r.watch:Stop()
	_r.destroying:Disconnect()

	if _r.textConn then
		_r.textConn:Disconnect()
	end

	for _, v7 in ipairs(_r.made) do
		v7:Destroy()
	end

	table.clear(_r.made)
	v3[_r.reg][_r.key] = nil
end

class.Destroy = class.Stop

local function owner(p)
	local parent = p

	while parent and not parent:IsA("GuiObject") do
		parent = parent.Parent
	end

	return parent or p
end

local function track(state, reg, instance, active)
	state.reg = reg
	state.key = instance
	state.idx = 0
	state.on = active ~= false
	state.shown = false
	state.phase = state.phase or 0
	local object = setmetatable({
		_r = state
	}, class)
	state.handle = object
	v3[reg][instance] = state
	park(state)
	state.destroying = instance.Destroying:Connect(function()
		object:Stop()
	end)
	state.watch = Ticker.watchVisible(state.target, function(shown)
		state.shown = shown
		sync(state) -- equivalent call inferred; original call site unknown
	end)
	return object
end

-- equivalent calls inferred from this helper; original call sites unknown
local function existing(p, p2, p3)
	local v7 = v3[p][p2]

	if not v7 then
		return nil
	end

	if p3 and p3.Active ~= nil then
		v7.handle:SetActive(p3.Active)
	end

	return v7.handle
end

local function firstChild(instance, className)
	for _, child in ipairs(instance:GetChildren()) do
		if child:IsA(className) and child.Name ~= "FXBeam" and child.Name ~= "FXShine" then
			return child
		end
	end

	return nil
end

local function band(width, p)
	local v7 = width * 0.5
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5 - v7, 1),
		NumberSequenceKeypoint.new(0.5, p),
		NumberSequenceKeypoint.new(0.5 + v7, 1),
		NumberSequenceKeypoint.new(1, 1)
	})
end

local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.55, 1),
	NumberSequenceKeypoint.new(0.85, 0.55),
	NumberSequenceKeypoint.new(1, 0)
})
local numberSequence2 = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.22, 1),
	NumberSequenceKeypoint.new(0.78, 1),
	NumberSequenceKeypoint.new(1, 0)
})

function FX.beam(parent, options)
	local v7 = options or {}
	local mode = v7.Mode or "Loop"
	local v8 = mode == "Line" and 2 or 1
	local reg = v8 == 2 and "line" or "beam"
	local v10 = existing(reg, parent, v7) -- equivalent call inferred; original call site unknown

	if v10 then
		return v10
	end

	local v11 = firstChild(parent, "UIStroke")
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Name = "FXBeam"
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.LineJoinMode = Enum.LineJoinMode.Round
	uIStroke.Color = v7.Color or Color3.new(1, 1, 1)
	uIStroke.Enabled = false

	if v11 then
		uIStroke.StrokeSizingMode = v11.StrokeSizingMode
		uIStroke.Thickness = v7.Thickness or v11.Thickness
		uIStroke.BorderStrokePosition = v11.BorderStrokePosition
		uIStroke.ZIndex = v11.ZIndex + 1
	else
		uIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
		uIStroke.Thickness = v7.Thickness or 0.03
	end

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Parent = uIStroke
	uIStroke.Parent = parent
	local v12

	if v8 == 2 then
		uIGradient.Transparency = band(v7.Width or 0.12, 0)
		uIGradient.Offset = offset
		local period = v7.Period or 1.6
		v12 = {
			kind = 2,
			target = parent,
			inst = uIGradient,
			stroke = uIStroke,
			period = period,
			sweep = period,
			last = 91,
			made = { uIStroke }
		}
	else
		uIGradient.Transparency = mode == "Double" and numberSequence2 or numberSequence
		v12 = {
			kind = 1,
			target = parent,
			inst = uIGradient,
			stroke = uIStroke,
			speed = 360 / (v7.Period or 2),
			last = -1,
			made = { uIStroke },
			phase = random:NextNumber(0, 360)
		}
	end

	return (track(v12, reg, parent, v7.Active))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function glowProperty(instance)
	if instance:IsA("UIShadow") or instance:IsA("UIStroke") then
		return "Transparency"
	end

	if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		return "ImageTransparency"
	end

	return "BackgroundTransparency"
end

function FX.glow(guiObject, options)
	local v7 = options or {}
	local target = v7.Target

	if not target then
		if guiObject:IsA("GuiObject") then
			target = firstChild(guiObject, "UIShadow") or firstChild(guiObject, "UIStroke") or guiObject
		else
			target = guiObject
		end
	end

	local v8 = existing("glow", target, v7) -- equivalent call inferred; original call site unknown

	if v8 then
		return v8
	end

	local property = v7.Property or glowProperty(target)
	local v9 = target[property]
	local v10

	if typeof(v9) == "UDim" then
		local to = v7.To or v9.Scale == 0 and v9.Offset == 0 and UDim.new(0.25, 0) or UDim.new(
			v9.Scale * 1.8,
			v9.Offset * 1.8
		)
		local steps = table.create(25)

		for i = 0, 24 do
			local v12 = i / 24
			local v13 = i + 1
			steps[v13] = UDim.new(
				v9.Scale + (to.Scale - v9.Scale) * v12,
				(floor(v9.Offset + (to.Offset - v9.Offset) * v12 + 0.5))
			)
		end

		local parent = target
		v10 = {
			kind = 5,
			target = 0,
			inst = 0,
			prop = 0,
			from = 0,
			steps = 0,
			speed = 0,
			last = 1,
			made = 0,
			phase = 0
		}

		while parent and not parent:IsA("GuiObject") do
			parent = parent.Parent
		end

		v10.target = parent or target
		v10.inst = target
		v10.prop = property
		v10.from = v9
		v10.steps = steps
		v10.speed = 6.283185307179586 / (v7.Period or 1.6)
		v10.made = {}
	else
		local to = v7.To or v9 > 0.5 and v9 - 0.35 or math.min(1, v9 + 0.35)
		local parent = target
		v10 = {
			kind = 3,
			target = 0,
			inst = 0,
			prop = 0,
			from = 0,
			span = 0,
			speed = 0,
			last = 0,
			made = 0,
			phase = 0
		}

		while parent and not parent:IsA("GuiObject") do
			parent = parent.Parent
		end

		v10.target = parent or target
		v10.inst = target
		v10.prop = property
		v10.from = v9
		v10.span = to - v9
		v10.speed = 6.283185307179586 / (v7.Period or 1.6)
		v10.last = v9
		v10.made = {}
	end

	return (track(v10, "glow", target, v7.Active))
end

local v7 = {
	"Text",
	"FontFace",
	"TextScaled",
	"TextSize",
	"TextWrapped",
	"TextXAlignment",
	"TextYAlignment",
	"RichText",
	"LineHeight",
	"TextTruncate"
}

function FX.shine(instance, options)
	local v8 = options or {}
	local v9 = existing("shine", instance, v8) -- equivalent call inferred; original call site unknown

	if v9 then
		return v9
	end

	local v10 = (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) and instance.Text ~= ""
	local parent

	if v10 then
		parent = Instance.new("TextLabel")

		for _, v12 in ipairs(v7) do
			parent[v12] = instance[v12]
		end

		parent.TextColor3 = v8.Color or Color3.new(1, 1, 1)
		parent.TextStrokeTransparency = 1
		parent.BackgroundTransparency = 1
	else
		parent = Instance.new("Frame")
		parent.BackgroundColor3 = v8.Color or Color3.new(1, 1, 1)
		parent.BackgroundTransparency = 0
		local v12 = firstChild(instance, "UICorner")

		if v12 then
			local clone = v12:Clone()
			clone.Parent = parent
		end
	end

	parent.Name = "FXShine"
	parent.BorderSizePixel = 0
	parent.AnchorPoint = Vector2.new(0.5, 0.5)
	parent.Position = UDim2.fromScale(0.5, 0.5)
	parent.Size = UDim2.fromScale(1, 1)
	parent.ZIndex = instance.ZIndex + 1
	parent.Active = false
	parent.Interactable = false
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Transparency = band(v8.Width or 0.08, v8.Strength or 0.35)
	uIGradient.Rotation = v8.Angle or 20
	uIGradient.Offset = offset
	uIGradient.Parent = parent
	parent.Parent = instance
	local sweep = v8.Sweep or 0.6
	local v12 = {
		kind = 2,
		target = instance,
		inst = uIGradient,
		period = sweep + (v8.Pause or 2.4),
		sweep = sweep,
		last = 91,
		made = { parent },
		phase = random:NextNumber(0, 3)
	}

	if v10 then
		v12.textConn = instance:GetPropertyChangedSignal("Text"):Connect(function()
			parent.Text = instance.Text
		end)
	end

	return (track(v12, "shine", instance, v8.Active))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dotProperty(guiObject)
	if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
		return "ImageTransparency"
	end

	return "BackgroundTransparency"
end

function FX.dots(parent, options)
	local v8 = options or {}
	local v9 = existing("dots", parent, v8) -- equivalent call inferred; original call site unknown

	if v9 then
		return v9
	end

	local objs = {}
	local made = {}

	for _, guiObject in ipairs(parent:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			objs[#objs + 1] = guiObject
		end
	end

	if #objs == 0 then
		local count = v8.Count or 3
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uIListLayout.Padding = UDim.new(0.25 / count, 0)
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = parent
		made[#made + 1] = uIListLayout

		for i = 1, count do
			local frame = Instance.new("Frame")
			frame.Name = "FXDot" .. i
			frame.LayoutOrder = i
			frame.BorderSizePixel = 0
			frame.BackgroundColor3 = v8.Color or Color3.new(1, 1, 1)
			frame.Size = UDim2.fromScale(0.75 / count, 0.75 / count)
			frame.SizeConstraint = Enum.SizeConstraint.RelativeXX
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0.5, 0)
			uICorner.Parent = frame
			frame.Parent = parent
			made[#made + 1] = frame
			objs[i] = frame
		end
	else
		table.sort(objs, function(a, b)
			if a.LayoutOrder == b.LayoutOrder then
				return a.Name < b.Name
			end

			return a.LayoutOrder < b.LayoutOrder
		end)
	end

	local count = #objs
	local scales = table.create(count)
	local props = table.create(count)
	local rest = table.create(count)
	local lasts = table.create(count)

	for i = 1, count do
		local guiObject = objs[i]
		v = v or require(script.Parent:WaitForChild("Spring"))
		local scale = v.findScale(guiObject, "FXScale")

		if not scale then
			scale = v.scale(guiObject, "FXScale")
			made[#made + 1] = scale
		end

		scales[i] = scale
		props[i] = dotProperty(guiObject)
		rest[i] = guiObject[props[i]]
		lasts[i] = -1
	end

	return (track({
		kind = 4,
		target = parent,
		objs = objs,
		scales = scales,
		props = props,
		rest = rest,
		lasts = lasts,
		n = count,
		speed = 1 / (v8.Period or 1.1),
		gap = 0.16,
		amount = v8.Amount or 0.35,
		dim = v8.Dim or 0.55,
		made = made,
		phase = 0
	}, "dots", parent, v8.Active))
end

local v8 = nil
local v9 = nil

function FX.reveal(p, options)
	local v10 = options or {}
	v8 = v8 or require(script.Parent:WaitForChild("Spring"))
	v9 = v9 or require(script.Parent:WaitForChild("Fade"))
	local scaled = v8.scale(p)
	v8.snap(scaled, {
		Scale = v10.From or 0.6
	})
	local scope = v9.group(p)
	scope:Apply(1)
	scope:Spring(0, v10.FadeTuning or "OpenFade")
	v8.to(scaled, v10.Tuning or "Pop", {
		Scale = 1
	})
end

function FX.setEnabled(p)
	local enabled = p and true or false

	if FX.enabled == enabled then
		return
	end

	FX.enabled = enabled

	for _, v11 in pairs(v3) do
		for _, v12 in pairs(v11) do
			sync(v12) -- equivalent call inferred; original call site unknown
		end
	end
end

function FX.setHz(hz)
	FX.Hz = hz

	if v6 then
		sleep() -- equivalent call inferred; original call site unknown

		if not v6 then
			if idx2 == 0 then
				return
			else
				v6 = FX.Hz >= 60 and Ticker.add(step) or Ticker.every(1 / FX.Hz, step)
			end
		end
	end
end

function FX.count()
	return idx2
end

function FX.registered()
	local count = 0

	for _, v10 in pairs(v3) do
		for _ in pairs(v10) do
			count += 1
		end
	end

	return count
end

function FX.stopAll()
	for _, v10 in pairs(v3) do
		local handles = {}

		for _, v11 in pairs(v10) do
			handles[#handles + 1] = v11.handle
		end

		for _, v11 in ipairs(handles) do
			v11:Stop()
		end
	end
end

return FX