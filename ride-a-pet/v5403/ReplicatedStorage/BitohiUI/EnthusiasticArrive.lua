local Spring = require(script.Parent:WaitForChild("Spring"))
local Fade = require(script.Parent:WaitForChild("Fade"))
local Store = require(script.Parent:WaitForChild("Store"))
local spr = Spring.spr
local EnthusiasticArrive = {}
Spring.extend({
	ArrivePose = { 0.7, 3.6 },
	ArriveOut = { 1, 7 },
	Anticipate = { 0.85, 9 }
})
EnthusiasticArrive.Poses = {
	Panel = {
		S = 0.66,
		R = -8,
		Y = 0.07,
		Tune = "Open"
	},
	Drop = {
		S = 0.5,
		R = 8,
		Y = -0.12
	},
	Rise = {
		S = 0.5,
		R = -4,
		Y = 0.1
	},
	Spin = {
		S = 0,
		R = -200,
		Tune = "Pop"
	},
	Soft = {
		S = 0.92,
		Y = 0.03,
		Tune = "Soft"
	},
	Left = {
		S = 0.5,
		R = -10,
		X = -0.3
	},
	Right = {
		S = 0.6,
		R = 10,
		X = 0.12
	},
	Below = {
		S = 0.6,
		Y = 0.1
	},
	Pop = {
		S = 0,
		R = -12,
		Tune = "Pop"
	},
	Card = {
		S = 0,
		R = -10,
		Tune = "Card"
	},
	Cell = {
		S = 0.2,
		R = -6,
		Y = 0.12,
		Tune = "Card"
	},
	Row = {
		S = 0.9,
		X = 0.08,
		Tune = "Row"
	}
}
local defaults = {
	Delay = 0,
	Step = 0.055,
	Sub = 0.035,
	MaxTotal = 0.8,
	Order = "List",
	Mirror = true,
	Fade = true,
	FadeTuning = "RowFade",
	ScaleName = "AnimScale",
	Tune = "Row",
	PoseTune = "ArrivePose",
	Reverse = false,
	Wind = 0.07,
	WindScale = 1.06,
	ScaleTo = 0,
	Spin = 10,
	Pull = 0.35,
	OutTuning = "ArriveOut"
}

local function opt(p, p2)
	local selected = p and p[p2]

	if selected == nil then
		return defaults[p2]
	end

	return selected
end

-- equivalent calls inferred from this helper; original call sites unknown
local function poseOf(value)
	if type(value) ~= "string" then
		return value or EnthusiasticArrive.Poses.Pop
	end

	local pos = EnthusiasticArrive.Poses[value]

	if not pos then
		error("Arrive: unknown pose " .. value, 3)
	end

	return pos
end

local v2 = Store.new()

local function homeOf(p)
	local v3 = v2[p]

	if not v3 then
		v3 = {
			Position = p.Position,
			Rotation = p.Rotation
		}
		v2[p] = v3
	end

	return v3
end

function EnthusiasticArrive.mark(instance)
	if typeof(instance) == "Instance" then
		if not v2[instance] then
			v2[instance] = {
				Position = instance.Position,
				Rotation = instance.Rotation
			}
		end
	else
		for _, v3 in ipairs(instance) do
			if not v2[v3] then
				v2[v3] = {
					Position = v3.Position,
					Rotation = v3.Rotation
				}
			end
		end
	end
end

local function childrenOf(instance)
	local guiObjects = {}

	for _, guiObject in ipairs(instance:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject.Visible then
			table.insert(guiObjects, guiObject)
		end
	end

	table.sort(guiObjects, function(a, b)
		local v3 = v2[a]

		if not v3 then
			v3 = {
				Position = a.Position,
				Rotation = a.Rotation
			}
			v2[a] = v3
		end

		local scale = v3.Position.Y.Scale
		local v4 = v2[b]

		if not v4 then
			v4 = {
				Position = b.Position,
				Rotation = b.Rotation
			}
			v2[b] = v4
		end

		return scale < v4.Position.Y.Scale
	end)
	return guiObjects
end

function EnthusiasticArrive:set(value, data)
	local v3 = poseOf(value) -- equivalent call inferred; original call site unknown
	local v4 = v2[self]

	if not v4 then
		v4 = {
			Position = self.Position,
			Rotation = self.Rotation
		}
		v2[self] = v4
	end

	local flip = data and data.Flip
	local scale = Spring.scale
	local scaleName = data and data.ScaleName

	if scaleName == nil then
		scaleName = defaults.ScaleName
	end

	local scaled = scale(self, scaleName)
	spr.stop(scaled)
	scaled.Scale = v3.S or 1
	local v5 = (v3.R or 0) * (flip and -1 or 1)

	if v5 ~= 0 then
		spr.stop(self, "Rotation")
		self.Rotation = v4.Rotation + v5
	end

	if v3.X or v3.Y then
		spr.stop(self, "Position")
		self.Position = v4.Position + UDim2.fromScale(v3.X or 0, v3.Y or 0)
	end

	local fade = data and data.Fade

	if fade == nil then
		fade = defaults.Fade
	end

	if fade then
		Fade.group(self):Apply(1)
	end
end

function EnthusiasticArrive.play(p, value, data)
	local v3 = poseOf(value) -- equivalent call inferred; original call site unknown

	if not data or data.Reset ~= false then
		EnthusiasticArrive.set(p, v3, data)
	end

	local v4 = v2[p]

	if not v4 then
		v4 = {
			Position = p.Position,
			Rotation = p.Rotation
		}
		v2[p] = v4
	end

	local scale = Spring.scale
	local scaleName = data and data.ScaleName

	if scaleName == nil then
		scaleName = defaults.ScaleName
	end

	local scaled = scale(p, scaleName)
	Spring.to(scaled, data and data.Tune or v3.Tune or defaults.Tune, {
		Scale = 1
	})
	Spring.to(p, data and data.PoseTune or v3.PoseTune or defaults.PoseTune, {
		Rotation = v4.Rotation,
		Position = v4.Position
	})
	local fade = data and data.Fade

	if fade == nil then
		fade = defaults.Fade
	end

	if fade then
		local scope = Fade.group(p)
		local fadeTuning = data and data.FadeTuning

		if fadeTuning == nil then
			fadeTuning = defaults.FadeTuning
		end

		scope:Spring(0, fadeTuning)
	end
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
	return (setmetatable({
		alive = true,
		done = false,
		waiting = nil
	}, class))
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

function EnthusiasticArrive.cascade(p, value, data)
	local v3 = poseOf(value) -- equivalent call inferred; original call site unknown
	local mirror = data and data.Mirror

	if mirror == nil then
		mirror = defaults.Mirror
	end

	local children = data and data.Children
	local sub = data and data.Sub

	if sub == nil then
		sub = defaults.Sub
	end

	local fade = data and data.Fade

	if fade == nil then
		fade = defaults.Fade
	end

	local order = data and data.Order

	if order == nil then
		order = defaults.Order
	end

	local reverse = data and data.Reverse

	if reverse == nil then
		reverse = defaults.Reverse
	end

	local v5 = ordered(p, order, reverse)

	for i, v6 in ipairs(v5) do
		if children then
			for i2, v7 in ipairs((childrenOf(v6))) do
				local set = EnthusiasticArrive.set
				local v8 = {
					Flip = mirror and i2 % 2 == 0,
					Fade = false,
					ScaleName = 0
				}
				local scaleName = data and data.ScaleName

				if scaleName == nil then
					scaleName = defaults.ScaleName
				end

				v8.ScaleName = scaleName
				set(v7, v3, v8)
			end

			if fade then
				Fade.group(v6):Apply(1)
			end
		else
			local set = EnthusiasticArrive.set
			local v7 = {
				Flip = mirror and i % 2 == 0,
				Fade = fade,
				ScaleName = 0
			}
			local scaleName = data and data.ScaleName

			if scaleName == nil then
				scaleName = defaults.ScaleName
			end

			v7.ScaleName = scaleName
			set(v6, v3, v7)
		end
	end

	return (schedule(v5, data, function(p2, p3)
		if children then
			for i, v6 in ipairs((childrenOf(p2))) do
				local v7 = v6
				local v8 = i

				local function fn()
					local play = EnthusiasticArrive.play
					local v11 = {
						Reset = false,
						Flip = mirror and v8 % 2 == 0,
						Fade = false,
						Tune = data and data.Tune,
						PoseTune = data and data.PoseTune,
						ScaleName = 0
					}
					local scaleName = data and data.ScaleName

					if scaleName == nil then
						scaleName = defaults.ScaleName
					end

					v11.ScaleName = scaleName
					play(v7, v3, v11)
				end

				if sub > 0 and i > 1 then
					task.delay(sub * (i - 1), fn)
				else
					fn()
				end
			end

			if fade then
				local scope = Fade.group(p2)
				local fadeTuning = data and data.FadeTuning

				if fadeTuning == nil then
					fadeTuning = defaults.FadeTuning
				end

				scope:Spring(0, fadeTuning)
			end
		else
			local play = EnthusiasticArrive.play
			local v7 = {
				Reset = false,
				Flip = mirror and p3 % 2 == 0,
				Fade = fade,
				FadeTuning = 0,
				Tune = 0,
				PoseTune = 0,
				ScaleName = 0
			}
			local fadeTuning = data and data.FadeTuning

			if fadeTuning == nil then
				fadeTuning = defaults.FadeTuning
			end

			v7.FadeTuning = fadeTuning
			v7.Tune = data and data.Tune
			v7.PoseTune = data and data.PoseTune
			local scaleName = data and data.ScaleName

			if scaleName == nil then
				scaleName = defaults.ScaleName
			end

			v7.ScaleName = scaleName
			play(p2, v3, v7)
		end
	end))
end

function EnthusiasticArrive.timeline(list, p)
	local run = newRun() -- equivalent call inferred; original call site unknown
	local v4 = {}

	for _, v5 in ipairs(list) do
		local clone = table.clone(v5)
		clone.Delay = 0
		local at = v5.At or 0
		local v6 = v5

		local function fn()
			if not run.alive then
				return
			end

			if v6.Obj then
				EnthusiasticArrive.play(v6.Obj, v6.Pose, clone)
			elseif v6.Items then
				table.insert(v4, EnthusiasticArrive.cascade(v6.Items, v6.Pose, clone))
			end
		end

		if v5.Obj then
			EnthusiasticArrive.set(v5.Obj, v5.Pose, clone)
		end

		if at > 0 then
			task.delay(at, fn)
		elseif run.alive then
			if v5.Obj then
				EnthusiasticArrive.play(v5.Obj, v5.Pose, clone)
			elseif v5.Items then
				table.insert(v4, EnthusiasticArrive.cascade(v5.Items, v5.Pose, clone))
			end
		end
	end

	if p and p.OnDone then
		task.spawn(function()
			task.wait(p.Settle or 0.9)

			if run.alive then
				p.OnDone()
			end
		end)
	end

	function run:Cancel()
		self.alive = false

		for _, v5 in ipairs(v4) do
			v5:Cancel()
		end
	end

	return run
end

function EnthusiasticArrive.out(instance, data)
	local v3 = typeof(instance) == "Instance" and { instance } or instance
	local wind = data and data.Wind

	if wind == nil then
		wind = defaults.Wind
	end

	local windScale = data and data.WindScale

	if windScale == nil then
		windScale = defaults.WindScale
	end

	local scaleTo = data and data.ScaleTo

	if scaleTo == nil then
		scaleTo = defaults.ScaleTo
	end

	local spin = data and data.Spin

	if spin == nil then
		spin = defaults.Spin
	end

	local pull = data and data.Pull

	if pull == nil then
		pull = defaults.Pull
	end

	local outTuning = data and data.OutTuning

	if outTuning == nil then
		outTuning = defaults.OutTuning
	end

	local scaleName = data and data.ScaleName

	if scaleName == nil then
		scaleName = defaults.ScaleName
	end

	local fade = data and data.Fade

	if fade == nil then
		fade = defaults.Fade
	end

	local order = data and data.Order

	if order == nil then
		order = defaults.Order
	end

	local reverse = data and data.Reverse

	if reverse == nil then
		reverse = defaults.Reverse
	end

	local v7 = nil
	v7 = schedule(ordered(v3, order, reverse), {
		Delay = not data and 0 or data.Delay or 0,
		Step = not data and 0.012 or data.Step or 0.012,
		MaxTotal = not data and 0.12 or data.MaxTotal or 0.12,
		OnItem = data and data.OnItem
	}, function(instance2)
		local scaled = Spring.scale(instance2, scaleName)
		local v8 = v2[instance2]

		if not v8 then
			v8 = {
				Position = instance2.Position,
				Rotation = instance2.Rotation
			}
			v2[instance2] = v8
		end

		Spring.to(scaled, "Anticipate", {
			Scale = windScale
		})
		task.delay(wind, function()
			if not instance2.Parent or v7 and not v7.alive then
				return
			end

			Spring.to(scaled, outTuning, {
				Scale = scaleTo
			})
			local uDim = UDim2.fromScale((0.5 - v8.Position.X.Scale) * pull, (0.5 - v8.Position.Y.Scale) * pull)
			Spring.to(instance2, outTuning, {
				Rotation = v8.Rotation + spin,
				Position = v8.Position + uDim
			})

			if fade then
				Fade.group(instance2):Spring(1, outTuning)
			end
		end)
	end)

	if data and data.OnDone then
		task.spawn(function()
			v7:Wait()
			task.wait(data.Settle or 0.22)

			if v7.alive then
				data.OnDone()
			end
		end)
	end

	return v7
end

function EnthusiasticArrive.reset(instance, p)
	local v3 = typeof(instance) == "Instance" and { instance } or instance
	local scaleName = p and p.ScaleName

	if scaleName == nil then
		scaleName = defaults.ScaleName
	end

	for _, v4 in ipairs(v3) do
		spr.stop(v4)
		local v5 = v2[v4]

		if v5 then
			v4.Position = v5.Position
			v4.Rotation = v5.Rotation
		end

		local scale = Spring.findScale(v4, scaleName)

		if scale then
			spr.stop(scale)
			scale.Scale = 1
		end

		if Fade.has(v4) then
			Fade.group(v4):Apply(0)
		end
	end
end

EnthusiasticArrive.Defaults = defaults
return EnthusiasticArrive