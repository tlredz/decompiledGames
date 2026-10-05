local Spring = require(script.Parent:WaitForChild("Spring"))
local Fade = require(script.Parent:WaitForChild("Fade"))
local Store = require(script.Parent:WaitForChild("Store"))
local spr = Spring.spr
local Stagger = {}
local defaults = {
	Delay = 0.08,
	Step = 0.06,
	MaxTotal = 0.9,
	Order = "List",
	ScaleFrom = 0.84,
	RotationFrom = -5,
	Fade = true,
	Tuning = "Row",
	FadeTuning = "RowFade",
	OutTuning = "PopOut",
	ScaleName = "AnimScale",
	From = "Left",
	Alternate = true,
	Distance = 1.15,
	Reverse = false
}

local function opt(p, p2)
	local selected = p and p[p2]

	if selected == nil then
		return defaults[p2]
	end

	return selected
end

local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function play(p)
	if not p then
		return
	end

	v2 = v2 or require(script.Parent:WaitForChild("SFX"))
	v2.play(p)
end

local function flip(clone)
	local count = #clone

	for i = 1, math.floor(count / 2) do
		local v3 = count - i + 1
		local v4 = clone[count - i + 1]
		local v5 = clone[i]
		clone[i] = v4
		clone[v3] = v5
	end

	return clone
end

local function ordered(p, p2, p3)
	local clone = table.clone(p)

	if p2 == "Reverse" then
		flip(clone)
	elseif p2 == "Random" then
		local random = Random.new()

		for i = #clone, 2, -1 do
			local integer = random:NextInteger(1, i)
			local v3 = clone[integer]
			local v4 = clone[i]
			clone[i] = v3
			clone[integer] = v4
		end
	elseif p2 == "Grid" then
		local v3 = {}

		for _, v4 in ipairs(clone) do
			local absolutePosition = v4.AbsolutePosition
			v3[v4] = absolutePosition.X + absolutePosition.Y * 1.35
		end

		table.sort(clone, function(a, b)
			return v3[a] < v3[b]
		end)
	elseif p2 == "Center" then
		local magnitudes = {}

		for _, v3 in ipairs(clone) do
			local parent = v3.Parent
			local v4 = parent and parent.AbsolutePosition + parent.AbsoluteSize * 0.5 or Vector2.zero
			magnitudes[v3] = (v3.AbsolutePosition + v3.AbsoluteSize * 0.5 - v4).Magnitude
		end

		table.sort(clone, function(a, b)
			return magnitudes[a] < magnitudes[b]
		end)
	end

	if p3 then
		flip(clone)
	end

	return clone
end

local function stepFor(data, count)
	local delay = data and data.Delay

	if delay == nil then
		delay = defaults.Delay
	end

	local step = data and data.Step

	if step == nil then
		step = defaults.Step
	end

	local maxTotal = data and data.MaxTotal

	if maxTotal == nil then
		maxTotal = defaults.MaxTotal
	end

	if count > 1 and maxTotal and maxTotal < delay + step * (count - 1) then
		step = math.max(0, (maxTotal - delay) / (count - 1))
	end

	return delay, step
end

local class = {}
class.__index = class

-- equivalent calls inferred from this helper; original call sites unknown
local function newRun()
	local self = setmetatable({}, class)
	self.alive = true
	self.done = false
	self.waiting = nil
	return self
end

function class:Cancel()
	self.alive = false
end

function class:Wait()
	if self.done then
		return
	end

	self.waiting = self.waiting or Instance.new("BindableEvent")
	self.waiting.Event:Wait()
end

function class:_finish()
	self.done = true

	if self.waiting then
		self.waiting:Fire()
		self.waiting:Destroy()
		self.waiting = nil
	end
end

local function schedule(list, p, fn)
	local run = newRun() -- equivalent call inferred; original call site unknown
	local count = #list

	if count == 0 then
		run:_finish()
		return run
	end

	local v4, v5 = stepFor(p, count)
	local onItem = p and p.OnItem
	local sound = p and p.Sound
	task.spawn(function()
		if v4 > 0 then
			task.wait(v4)
		end

		for i, v6 in ipairs(list) do
			if not run.alive then
				break
			end

			if v6.Parent then
				fn(v6, i)
				play(sound) -- equivalent call inferred; original call site unknown

				if onItem then
					onItem(v6, i)
				end
			end

			if i < count and v5 > 0 then
				task.wait(v5)
			end
		end

		run:_finish()
	end)
	return run
end

function Stagger.hide(list, data)
	local scaleFrom = data and data.ScaleFrom

	if scaleFrom == nil then
		scaleFrom = defaults.ScaleFrom
	end

	local rotationFrom = data and data.RotationFrom

	if rotationFrom == nil then
		rotationFrom = defaults.RotationFrom
	end

	local fade = data and data.Fade

	if fade == nil then
		fade = defaults.Fade
	end

	local scaleName = data and data.ScaleName

	if scaleName == nil then
		scaleName = defaults.ScaleName
	end

	for _, v3 in ipairs(list) do
		local scaled = Spring.scale(v3, scaleName)
		spr.stop(scaled)
		scaled.Scale = scaleFrom

		if rotationFrom ~= 0 then
			spr.stop(v3, "Rotation")
			v3.Rotation = rotationFrom
		end

		if fade then
			Fade.group(v3):Apply(1)
		end
	end
end

function Stagger.pop(p, data)
	if data and data.Reset ~= false then
		Stagger.hide(p, data)
	end

	local tuning = data and data.Tuning

	if tuning == nil then
		tuning = defaults.Tuning
	end

	local fadeTuning = data and data.FadeTuning

	if fadeTuning == nil then
		fadeTuning = defaults.FadeTuning
	end

	local fade = data and data.Fade

	if fade == nil then
		fade = defaults.Fade
	end

	local rotationFrom = data and data.RotationFrom

	if rotationFrom == nil then
		rotationFrom = defaults.RotationFrom
	end

	local scaleName = data and data.ScaleName

	if scaleName == nil then
		scaleName = defaults.ScaleName
	end

	local order = data and data.Order

	if order == nil then
		order = defaults.Order
	end

	local reverse = data and data.Reverse

	if reverse == nil then
		reverse = defaults.Reverse
	end

	return (schedule(ordered(p, order, reverse), data, function(p2)
		Spring.to(Spring.scale(p2, scaleName), tuning, {
			Scale = 1
		})

		if rotationFrom ~= 0 then
			Spring.to(p2, tuning, {
				Rotation = 0
			})
		end

		if fade then
			Fade.group(p2):Spring(0, fadeTuning)
		end
	end))
end

function Stagger.out(p, options)
	local v3 = options or {}
	local tuning = v3.Tuning or defaults.OutTuning
	local fadeTuning = v3.FadeTuning or defaults.OutTuning
	local scaleTo = v3.ScaleTo or 0.6
	local rotationTo = v3.RotationTo or 0
	local fade = v3 and v3.Fade

	if fade == nil then
		fade = defaults.Fade
	end

	local scaleName = v3 and v3.ScaleName

	if scaleName == nil then
		scaleName = defaults.ScaleName
	end

	local order = v3 and v3.Order

	if order == nil then
		order = defaults.Order
	end

	local reverse = v3 and v3.Reverse

	if reverse == nil then
		reverse = defaults.Reverse
	end

	local v11 = schedule(ordered(p, order, reverse), {
		Delay = v3.Delay or 0,
		Step = v3.Step or 0.03,
		MaxTotal = v3.MaxTotal or 0.4,
		OnItem = v3.OnItem,
		Sound = v3.Sound
	}, function(p2)
		Spring.to(Spring.scale(p2, scaleName), tuning, {
			Scale = scaleTo
		})

		if rotationTo ~= 0 then
			Spring.to(p2, tuning, {
				Rotation = rotationTo
			})
		end

		if fade then
			Fade.group(p2):Spring(1, fadeTuning)
		end
	end)

	if v3.OnDone then
		task.spawn(function()
			v11:Wait()
			task.wait(v3.Settle or 0.18)

			if v11.alive then
				v3.OnDone()
			end
		end)
	end

	return v11
end

local v3 = {
	Left = Vector2.new(-1, 0),
	Right = Vector2.new(1, 0),
	Top = Vector2.new(0, -1),
	Bottom = Vector2.new(0, 1)
}
local v4 = {
	Left = "Right",
	Right = "Left",
	Top = "Bottom",
	Bottom = "Top"
}
local v5 = Store.new()

local function hiddenPosition(p, p2, p3)
	local selected = v5[p] or p.Position
	v5[p] = selected
	local v7 = v3[p2] * p3
	return UDim2.new(selected.X.Scale + v7.X, selected.X.Offset, selected.Y.Scale + v7.Y, selected.Y.Offset), selected
end

function Stagger.hideSlide(list, data)
	local from = data and data.From

	if from == nil then
		from = defaults.From
	end

	local alternate = data and data.Alternate

	if alternate == nil then
		alternate = defaults.Alternate
	end

	local distance = data and data.Distance

	if distance == nil then
		distance = defaults.Distance
	end

	local fade = data and data.Fade

	if fade == nil then
		fade = defaults.Fade
	end

	for i, v6 in ipairs(list) do
		local v7

		if alternate and i % 2 == 0 then
			v7 = v4[from] or from
		else
			v7 = from
		end

		local v8 = v5[v6] or v6.Position
		v5[v6] = v8
		local v9 = v3[v7] * distance
		local uDim = UDim2.new(v8.X.Scale + v9.X, v8.X.Offset, v8.Y.Scale + v9.Y, v8.Y.Offset)
		spr.stop(v6, "Position")
		v6.Position = uDim

		if fade then
			Fade.group(v6):Apply(1)
		end
	end
end

function Stagger.slide(p, data)
	if data and data.Reset ~= false then
		Stagger.hideSlide(p, data)
	end

	local v6 = not data and "Slide" or data.Tuning or "Slide"
	local fadeTuning = data and data.FadeTuning

	if fadeTuning == nil then
		fadeTuning = defaults.FadeTuning
	end

	local fade = data and data.Fade

	if fade == nil then
		fade = defaults.Fade
	end

	return (schedule(p, data, function(p2)
		local position = v5[p2] or p2.Position
		v5[p2] = position
		local v8 = v3.Left * 0
		UDim2.new(position.X.Scale + v8.X, position.X.Offset, position.Y.Scale + v8.Y, position.Y.Offset)
		Spring.to(p2, v6, {
			Position = position
		})

		if fade then
			Fade.group(p2):Spring(0, fadeTuning)
		end
	end))
end

function Stagger.slideOut(p, options)
	local v6 = options or {}
	local from = v6 and v6.From

	if from == nil then
		from = defaults.From
	end

	local alternate = v6 and v6.Alternate

	if alternate == nil then
		alternate = defaults.Alternate
	end

	local distance = v6 and v6.Distance

	if distance == nil then
		distance = defaults.Distance
	end

	local fade = v6 and v6.Fade

	if fade == nil then
		fade = defaults.Fade
	end

	local tuning = v6.Tuning or "Out"
	return (schedule(p, {
		Delay = v6.Delay or 0,
		Step = v6.Step or 0,
		MaxTotal = v6.MaxTotal,
		OnItem = v6.OnItem
	}, function(p2, p3)
		local v8 = alternate and p3 % 2 == 0 and v4[from] or from
		local v10 = v5[p2] or p2.Position
		v5[p2] = v10
		local v11 = v3[v8] * distance
		local uDim = UDim2.new(v10.X.Scale + v11.X, v10.X.Offset, v10.Y.Scale + v11.Y, v10.Y.Offset)
		Spring.to(p2, tuning, {
			Position = uDim
		})

		if fade then
			Fade.group(p2):Spring(1, tuning)
		end
	end))
end

function Stagger.reset(list, p)
	local scaleName = p and p.ScaleName

	if scaleName == nil then
		scaleName = defaults.ScaleName
	end

	for _, v6 in ipairs(list) do
		spr.stop(v6)
		local position = v5[v6]

		if position then
			v6.Position = position
		end

		local scale = Spring.findScale(v6, scaleName)

		if scale then
			spr.stop(scale)
			scale.Scale = 1
		end

		v6.Rotation = 0

		if Fade.has(v6) then
			Fade.group(v6):Apply(0)
		end
	end
end

Stagger.Defaults = defaults
return Stagger