local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local Blend = require(script.Blend)
local Solver = require(script.Solver)
local fn = not workspace.StreamingEnabled and function(p)
	return p
end or require(game.ReplicatedStorage.Util.EncodeObj)
local v = {
	Kind = "Spring",
	DampingRatio = 1,
	Frequency = 4
}
local v2 = RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false
local isServer = RunService:IsServer()
local total = 0
local v3 = {}
local springEvent = script.SpringEvent
local simulatedSpringEvent = script.SimulatedSpringEvent

-- equivalent calls inferred from this helper; original call sites unknown
local function serializeTweenInfo(data)
	return {
		data.Time,
		data.EasingStyle,
		data.EasingDirection,
		data.RepeatCount,
		data.Reverses,
		data.DelayTime
	}
end

local function deserializeTweenInfo(list)
	return TweenInfo.new(list[1], list[2], list[3], list[4], list[5], list[6])
end

local function normalizeEase(data)
	if data and data.Kind == "Tween" then
		return {
			Kind = "Tween",
			TweenInfo = data.TweenInfo or TweenInfo.new()
		}
	end

	if data and data.Kind == "Instant" then
		return {
			Kind = "Instant"
		}
	end

	return {
		Kind = "Spring",
		DampingRatio = not (data and data.DampingRatio) and 1 or data.DampingRatio,
		Frequency = not (data and data.Frequency) and 4 or data.Frequency
	}
end

local function normalizeMotion(motion)
	if motion and motion.Kind == "Motor" then
		return {
			Kind = "Motor",
			Motion = normalizeEase(motion.Motion),
			Rate = motion.Rate == nil and 1 or motion.Rate
		}
	end

	return (normalizeEase(motion))
end

local function motorEase(p)
	local motion = p.Motion
	return motion or v
end

local serializeMotion

serializeMotion = function(data)
	local v4 = {
		Kind = data.Kind,
		DampingRatio = data.DampingRatio,
		Frequency = data.Frequency,
		Rate = data.Rate,
		TweenInfo = 0,
		Motion = 0
	}
	local tweenInfo

	if data.TweenInfo then
		tweenInfo = serializeTweenInfo(data.TweenInfo)
	end

	v4.TweenInfo = tweenInfo
	local motion

	if data.Motion then
		motion = serializeMotion(data.Motion)
	end

	v4.Motion = motion
	return v4
end

local deserializeMotion

deserializeMotion = function(motion)
	if not motion then
		return {
			Kind = "Spring",
			DampingRatio = 1,
			Frequency = 4
		}
	end

	local v5 = {
		Kind = motion.Kind,
		DampingRatio = motion.DampingRatio,
		Frequency = motion.Frequency,
		Rate = motion.Rate,
		TweenInfo = 0,
		Motion = 0
	}
	local tweenInfo

	if motion.TweenInfo then
		local tweenInfo2 = motion.TweenInfo
		tweenInfo = TweenInfo.new(
			tweenInfo2[1],
			tweenInfo2[2],
			tweenInfo2[3],
			tweenInfo2[4],
			tweenInfo2[5],
			tweenInfo2[6]
		)
	end

	v5.TweenInfo = tweenInfo
	local motion2

	if motion.Motion then
		motion2 = deserializeMotion(motion.Motion)
	end

	v5.Motion = motion2
	return (normalizeMotion(v5))
end

local function tweenProgress(tweenInfo, p: number)
	local time = tweenInfo.Time
	local v4 = p - tweenInfo.DelayTime

	if v4 <= 0 then
		return 0, false
	end

	if time <= 0 then
		return 1, true
	end

	local reverses = tweenInfo.Reverses
	local v5 = time * (reverses and 2 or 1)
	local repeatCount = tweenInfo.RepeatCount
	local v6 = false
	local v7

	if repeatCount < 0 then
		v7 = v4 % v5
	elseif v5 * (repeatCount + 1) <= v4 then
		v6 = true

		if reverses then
			v7 = 0
		else
			v7 = time
		end
	else
		v7 = v4 % v5
	end

	if reverses and time < v7 then
		local v8 = 1 - (v7 - time) / time
		return TweenService:GetValue(math.clamp(v8, 0, 1), tweenInfo.EasingStyle, tweenInfo.EasingDirection), v6
	end

	local v8 = v7 / time
	return TweenService:GetValue(math.clamp(v8, 0, 1), tweenInfo.EasingStyle, tweenInfo.EasingDirection), v6
end

local function estimateSettleTime(p)
	local motion = p.Motion

	if motion.Kind == "Motor" then
		return 1e999
	end

	if motion.Kind == "Instant" then
		return 0
	end

	if motion.Kind == "Tween" then
		local tweenInfo = motion.TweenInfo

		if tweenInfo.RepeatCount < 0 then
			return 1e999
		end

		local v4 = tweenInfo.Time * (tweenInfo.Reverses and 2 or 1)
		return tweenInfo.DelayTime + v4 * (tweenInfo.RepeatCount + 1)
	else
		local dampingRatio = motion.DampingRatio or 1
		local frequency = motion.Frequency or 4

		if dampingRatio <= 0 or frequency <= 0 then
			return 1e999
		end

		return 8.253227645581772 / (6.283185307179586 * frequency * dampingRatio)
	end
end

local function assignProperties(p, items)
	for k, item in items do
		p[k] = item
	end
end

local function getCullPosition(instance)
	if instance:IsA("BasePart") then
		return instance.Position
	end

	if instance:IsA("Attachment") then
		return instance.WorldPosition
	end

	if instance:IsA("JointInstance") then
		local part0 = instance.Part0 or instance.Part1

		if part0 then
			return part0.Position
		end

		return nil
	else
		local parent = instance.Parent

		if parent and parent:IsA("BasePart") then
			return parent.Position
		end

		return nil
	end
end

local function getBaseValue(p, p2: string)
	local v4 = p.Base[p2]

	if v4 == nil then
		v4 = p.Instance[p2]
		p.Base[p2] = v4
	end

	return v4
end

local function sortLayers(p)
	local order = p.Order
	table.clear(order)

	for _, layer in p.Layers do
		table.insert(order, layer)
	end

	table.sort(order, function(a, b)
		if a.Priority == b.Priority then
			return a.Id < b.Id
		end

		return a.Priority < b.Priority
	end)
end

local function easedValue(data, p, p2: string, p3)
	if p.Kind == "Instant" then
		return p3
	end

	if p.Kind == "Tween" then
		local v4 = data.TweenFrom[p2]

		if v4 == nil then
			return p3
		end

		local v5 = tweenProgress(p.TweenInfo, total - data.TweenClock)
		return Blend.lerp(v4, p3, v5)
	else
		local spring = data.Springs[p2]

		if spring then
			return (spring:getPosition())
		end

		return p3
	end
end

local function steppedEasedValue(p, motion, k: string, goal, p2: number)
	if motion.Kind == "Instant" or motion.Kind == "Tween" then
		return easedValue(p, motion, k, goal)
	end

	local spring = p.Springs[k]

	if not spring then
		return goal
	end

	if not spring:canSleep() then
		return spring:step(p2)
	end

	spring:setPosition(goal)
	return goal
end

-- equivalent calls inferred from this helper; original call sites unknown
local function motorRate(layer, motion)
	if motion.Kind == "Instant" then
		return layer.MotorRateGoal
	end

	if motion.Kind == "Tween" then
		local v4 = tweenProgress(motion.TweenInfo, total - layer.TweenClock)
		return layer.MotorRateFrom + (layer.MotorRateGoal - layer.MotorRateFrom) * v4
	end

	local motorRateSpring = layer.MotorRateSpring

	if motorRateSpring then
		return (motorRateSpring:getPosition())
	end

	return layer.MotorRateGoal
end

local function steppedMotorRate(data, motion, p: number)
	if motion.Kind == "Instant" or motion.Kind == "Tween" then
		if motion.Kind == "Instant" then
			return data.MotorRateGoal
		end

		if motion.Kind == "Tween" then
			local v4 = tweenProgress(motion.TweenInfo, total - data.TweenClock)
			return data.MotorRateFrom + (data.MotorRateGoal - data.MotorRateFrom) * v4
		end

		local motorRateSpring = data.MotorRateSpring

		if motorRateSpring then
			return (motorRateSpring:getPosition())
		end

		return data.MotorRateGoal
	else
		local motorRateSpring = data.MotorRateSpring

		if not motorRateSpring then
			return data.MotorRateGoal
		end

		if not motorRateSpring:canSleep() then
			return motorRateSpring:step(p)
		end

		motorRateSpring:setPosition(data.MotorRateGoal)
		return data.MotorRateGoal
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isMotorIdle(data)
	local motion = data.Motion.Motion or v

	if motion.Kind == "Instant" then
		return true
	end

	if motion.Kind == "Tween" then
		local tweenInfo = motion.TweenInfo
		return total - data.TweenClock >= tweenInfo.DelayTime + tweenInfo.Time
	end

	local motorRateSpring = data.MotorRateSpring
	return not motorRateSpring or motorRateSpring:canSleep()
end

local function contributionOf(p, p2: string, goal)
	local motion = p.Motion

	if motion.Kind ~= "Motor" then
		return easedValue(p, motion, p2, goal)
	end

	local v4 = p.MotorValue[p2]

	if v4 == nil then
		return (Blend.neutral("Add", goal))
	end

	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function motionSignature(motion)
	if motion.Kind == "Motor" then
		return (`Motor:{(motion.Motion or v).Kind}`)
	end

	return motion.Kind
end

local function composeBelow(data, p, p2: string)
	local v4 = data.Base[p2]

	if v4 == nil then
		v4 = data.Instance[p2]
		data.Base[p2] = v4
	end

	for _, v5 in data.Order do
		if v5 == p then
			break
		end

		local goal = v5.Goals[p2]

		if goal ~= nil then
			v4 = Blend.apply(v5.Blend, v4, contributionOf(v5, p2, goal))
		end
	end

	return v4
end

local function startValueFor(p, p2, p3: string, p4, p5)
	local v4 = p5[p3]

	if v4 ~= nil then
		return v4
	end

	if p2.Blend == "Set" then
		return (composeBelow(p, p2, p3))
	end

	return Blend.neutral(p2.Blend, p4)
end

local function setLayer(record, id: string, data)
	local motion = normalizeMotion(data.Motion)
	local blend = data.Blend or "Set"
	local priority = data.Priority or id == "Base" and -1000000000 or 0
	local v4 = {}
	local motorRateGoal = nil
	local layer = record.Layers[id]

	if layer then
		local motion2, v5, motion3, v6, motorRateSpring

		if layer.Blend == blend then
			local v7 = motionSignature(layer.Motion) -- equivalent call inferred; original call site unknown
			local v8 = motionSignature(motion) -- equivalent call inferred; original call site unknown

			if v7 ~= v8 then
				for k, goal in layer.Goals do
					motion2 = layer.Motion

					if motion2.Kind == "Motor" then
						v5 = layer.MotorValue[k]

						if v5 == nil then
							v5 = Blend.neutral("Add", goal)
						end
					else
						v5 = easedValue(layer, motion2, k, goal)
					end

					v4[k] = v5
				end

				if layer.Motion.Kind == "Motor" then
					motion3 = layer.Motion.Motion or v

					if motion3.Kind == "Instant" then
						motorRateGoal = layer.MotorRateGoal
					elseif motion3.Kind == "Tween" then
						v6 = tweenProgress(motion3.TweenInfo, total - layer.TweenClock)
						motorRateGoal = layer.MotorRateFrom + (layer.MotorRateGoal - layer.MotorRateFrom) * v6
					else
						motorRateSpring = layer.MotorRateSpring

						if motorRateSpring then
							motorRateGoal = motorRateSpring:getPosition()
						else
							motorRateGoal = layer.MotorRateGoal
						end
					end
				end

				record.Layers[id] = nil
				layer = nil
			end
		else
			for k, goal in layer.Goals do
				motion2 = layer.Motion

				if motion2.Kind == "Motor" then
					v5 = layer.MotorValue[k]

					if v5 == nil then
						v5 = Blend.neutral("Add", goal)
					end
				else
					v5 = easedValue(layer, motion2, k, goal)
				end

				v4[k] = v5
			end

			if layer.Motion.Kind == "Motor" then
				motion3 = layer.Motion.Motion or v

				if motion3.Kind == "Instant" then
					motorRateGoal = layer.MotorRateGoal
				elseif motion3.Kind == "Tween" then
					v6 = tweenProgress(motion3.TweenInfo, total - layer.TweenClock)
					motorRateGoal = layer.MotorRateFrom + (layer.MotorRateGoal - layer.MotorRateFrom) * v6
				else
					motorRateSpring = layer.MotorRateSpring

					if motorRateSpring then
						motorRateGoal = motorRateSpring:getPosition()
					else
						motorRateGoal = layer.MotorRateGoal
					end
				end
			end

			record.Layers[id] = nil
			layer = nil
		end
	end

	local v5 = layer == nil

	if v5 then
		layer = {
			Id = id,
			Priority = priority,
			Blend = blend,
			Motion = motion,
			Goals = {},
			Springs = {},
			TweenFrom = {},
			MotorValue = {},
			MotorRate = 0,
			MotorRateGoal = 0,
			MotorRateFrom = 0,
			TweenClock = total,
			Retiring = false
		}
		record.Layers[id] = layer
	end

	assert(layer, "bad layer")
	local v6 = v5 or layer.Priority ~= priority
	layer.Priority = priority
	layer.Retiring = false

	if v6 then
		sortLayers(record)
	end

	local goals = layer.Goals
	local goals2 = {}

	for k, goal in data.Goals do
		goals2[k] = goal
	end

	for k in goals do
		if goals2[k] ~= nil then
			continue
		end

		layer.Springs[k] = nil
		layer.TweenFrom[k] = nil
		layer.MotorValue[k] = nil
	end

	if motion.Kind == "Motor" then
		local motion2 = motion.Motion or v
		local v7 = motion.Rate == nil and 1 or motion.Rate
		local motorValue = {}
		local tweenFrom = {}

		for k, v10 in goals2 do
			local v11 = layer.MotorValue[k]

			if v11 == nil then
				v11 = v4[k]

				if v11 == nil then
					if layer.Blend == "Set" then
						v11 = composeBelow(record, layer, k)
					else
						v11 = Blend.neutral(layer.Blend, v10)
					end
				end
			end

			motorValue[k] = v11
			local goal = goals[k]

			if goal ~= nil then
				v10 = easedValue(layer, motion2, k, goal)
			end

			tweenFrom[k] = v10
		end

		if motorRateGoal == nil then
			if motion2.Kind == "Instant" then
				motorRateGoal = layer.MotorRateGoal
			elseif motion2.Kind == "Tween" then
				local v10 = tweenProgress(motion2.TweenInfo, total - layer.TweenClock)
				motorRateGoal = layer.MotorRateFrom + (layer.MotorRateGoal - layer.MotorRateFrom) * v10
			else
				local motorRateSpring = layer.MotorRateSpring

				if motorRateSpring then
					motorRateGoal = motorRateSpring:getPosition()
				else
					motorRateGoal = layer.MotorRateGoal
				end
			end
		end

		layer.MotorRateFrom = motorRateGoal
		layer.Motion = motion
		layer.Goals = goals2
		layer.MotorValue = motorValue
		layer.MotorRateGoal = v7

		if motion2.Kind == "Instant" then
			layer.MotorRate = v7
			layer.MotorRateSpring = nil
			layer.TweenFrom = tweenFrom
		elseif motion2.Kind == "Tween" then
			layer.MotorRateSpring = nil
			layer.TweenFrom = tweenFrom
			layer.TweenClock = total
		else
			local dampingRatio = motion2.DampingRatio or 1
			local frequency = motion2.Frequency or 4
			local motorRateSpring = layer.MotorRateSpring

			if motorRateSpring then
				motorRateSpring:setGoal(v7)
				motorRateSpring:setDampingRatio(dampingRatio)
				motorRateSpring:setFrequency(frequency)
			else
				layer.MotorRateSpring = Solver.new(dampingRatio, frequency, layer.MotorRateFrom, v7)
			end

			for k, v10 in goals2 do
				local spring = layer.Springs[k]

				if spring then
					spring:setGoal(v10)
					spring:setDampingRatio(dampingRatio)
					spring:setFrequency(frequency)
				else
					layer.Springs[k] = Solver.new(dampingRatio, frequency, tweenFrom[k], v10)
				end
			end
		end
	elseif motion.Kind == "Tween" then
		local tweenFrom = {}

		for k, v8 in goals2 do
			local goal = goals[k]

			if goal == nil then
				local v9 = v4[k]

				if v9 == nil then
					if layer.Blend == "Set" then
						v9 = composeBelow(record, layer, k)
					else
						v9 = Blend.neutral(layer.Blend, v8)
					end
				end

				tweenFrom[k] = v9
			else
				local motion2 = layer.Motion
				local v9

				if motion2.Kind == "Motor" then
					v9 = layer.MotorValue[k]

					if v9 == nil then
						v9 = Blend.neutral("Add", goal)
					end
				else
					v9 = easedValue(layer, motion2, k, goal)
				end

				tweenFrom[k] = v9
			end
		end

		layer.Motion = motion
		layer.Goals = goals2
		layer.TweenFrom = tweenFrom
		layer.TweenClock = total
	elseif motion.Kind == "Spring" then
		local dampingRatio = motion.DampingRatio or 1
		local frequency = motion.Frequency or 4
		layer.Motion = motion
		layer.Goals = goals2

		for k, v7 in goals2 do
			local spring = layer.Springs[k]

			if spring then
				spring:setGoal(v7)
				spring:setDampingRatio(dampingRatio)
				spring:setFrequency(frequency)
			else
				local v8 = v4[k]

				if v8 == nil then
					if layer.Blend == "Set" then
						v8 = composeBelow(record, layer, k)
					else
						v8 = Blend.neutral(layer.Blend, v7)
					end
				end

				layer.Springs[k] = Solver.new(dampingRatio, frequency, v8, v7)
			end
		end
	else
		layer.Motion = motion
		layer.Goals = goals2
	end
end

local function retireLayer(p, p2: string)
	local layer = p.Layers[p2]

	if not layer then
		return
	end

	if layer.Motion.Kind == "Motor" then
		local motion = layer.Motion.Motion or v
		local motorRateFrom = motorRate(layer, motion) -- equivalent call inferred; original call site unknown
		layer.MotorRateFrom = motorRateFrom
		layer.MotorRateGoal = 0
		layer.Retiring = true
		local motorRateSpring = layer.MotorRateSpring

		if motorRateSpring then
			motorRateSpring:setGoal(0)
		end

		if motion.Kind == "Instant" then
			layer.MotorRate = 0
		elseif motion.Kind == "Tween" then
			for k, goal in layer.Goals do
				layer.TweenFrom[k] = goal
			end

			layer.TweenClock = total
		end
	elseif layer.Blend == "Set" or layer.Motion.Kind ~= "Spring" then
		p.Layers[p2] = nil
		sortLayers(p)
	else
		layer.Retiring = true

		for k, goal in layer.Goals do
			local neutral = Blend.neutral(layer.Blend, goal)
			layer.Goals[k] = neutral
			local spring = layer.Springs[k]

			if spring then
				spring:setGoal(neutral)
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeLayer(record, id: string, flag: boolean?)
	if flag then
		retireLayer(record, id)
		return
	end

	if record.Layers[id] == nil then
		return
	end

	record.Layers[id] = nil
	sortLayers(record)
end

local function resolve(data, p: number, flag: boolean)
	local v4 = total
	local result = {}
	local v5 = true

	for _, v6 in data.Order do
		local motion = v6.Motion
		local motion2

		if motion.Kind == "Motor" then
			motion2 = motion.Motion or v
		end

		local v7 = not flag and p > 0

		if motion2 then
			if v7 then
				v6.MotorRate = steppedMotorRate(v6, motion2, p)
			end

			if v6.MotorRate == 0 then
				-- equivalent call inferred; original call site unknown
				if not isMotorIdle(v6) then
					v5 = false
				end
			else
				v5 = false
			end
		end

		for k, goal in v6.Goals do
			local lerped

			if motion2 then
				lerped = v6.MotorValue[k]

				if lerped == nil then
					lerped = Blend.neutral("Add", goal)
				end

				if v7 then
					local v8 = steppedEasedValue(v6, motion2, k, goal, p)
					lerped = Blend.add(lerped, Blend.scale(v8, v6.MotorRate * p))
				end

				v6.MotorValue[k] = lerped
			elseif flag or motion.Kind == "Instant" then
				lerped = goal
			elseif motion.Kind == "Tween" then
				local v8, v9 = tweenProgress(motion.TweenInfo, v4 - v6.TweenClock)

				if not v9 then
					v5 = false
				end

				local v10 = v6.TweenFrom[k]

				if v10 == nil then
					lerped = goal
				else
					lerped = Blend.lerp(v10, goal, v8)
				end
			else
				local spring = v6.Springs[k]

				if spring then
					if spring:canSleep() then
						spring:setPosition(goal)
						lerped = goal
					else
						lerped = spring:step(p)
						v5 = false
					end
				else
					lerped = goal
				end
			end

			local v8 = result[k]

			if v8 == nil then
				v8 = data.Base[k]

				if v8 == nil then
					v8 = data.Instance[k]
					data.Base[k] = v8
				end
			end

			result[k] = Blend.apply(v6.Blend, v8, lerped)
		end
	end

	return result, v5
end

local function destroyRecord(p)
	local v4 = v3[p]

	if not v4 then
		return
	end

	v3[p] = nil

	if v4.Connection then
		v4.Connection:Disconnect()
		v4.Connection = nil
	end

	if v4.SettleThread then
		task.cancel(v4.SettleThread)
		v4.SettleThread = nil
	end

	table.clear(v4.Layers)
	table.clear(v4.Order)
	table.clear(v4.Base)
	table.clear(v4.Composed)
end

local function getRecord(instance, mode: string, range: number?)
	local v4 = v3[instance]

	if v4 then
		if mode == "Simulate" and v4.Mode ~= "Simulate" then
			v4.Mode = "Simulate"

			if v4.SettleThread then
				task.cancel(v4.SettleThread)
				v4.SettleThread = nil
			end
		end

		if range then
			v4.Range = range
		end

		return v4
	else
		local v5 = {
			Instance = instance,
			Mode = mode,
			Base = {},
			Composed = {},
			Layers = {},
			Order = {},
			Active = true,
			Range = range or 900
		}
		v3[instance] = v5
		v5.Connection = instance.Destroying:Once(function()
			destroyRecord(instance)
		end)
		return v5
	end
end

local function scheduleSettle(record)
	if record.SettleThread then
		task.cancel(record.SettleThread)
		record.SettleThread = nil
	end

	local v4 = 0

	for _, v5 in record.Order do
		v4 = math.max(v4, (estimateSettleTime(v5)))
	end

	local v5 = math.min(v4, 30)
	record.SettleThread = task.delay(v5, function()
		record.SettleThread = nil

		if v3[record.Instance] ~= record then
			return
		end

		local composed = resolve(record, 0, true)
		record.Composed = composed
		local instance = record.Instance

		for k, v7 in composed do
			instance[k] = v7
		end
	end)
end

local function snap(record, id: string?)
	for _, v4 in record.Order do
		if not (id == nil or v4.Id == id) then
			continue
		end

		v4.TweenClock = -30000
		v4.MotorRate = v4.MotorRateGoal
		local motorRateSpring = v4.MotorRateSpring

		if motorRateSpring then
			motorRateSpring:setPosition(v4.MotorRateGoal)
		end

		for k, goal in v4.Goals do
			local spring = v4.Springs[k]

			if spring then
				spring:setPosition(goal)
			end
		end
	end
end

local function impulse(record, id: string, velocities)
	local layer = record.Layers[id]

	if not layer then
		return
	end

	for k, item in velocities do
		local spring = layer.Springs[k]

		if spring then
			spring:addVelocity(item)
		end
	end
end

local function applyEvent(mode: string, instance, p3: string, options)
	if p3 == "Destroy" then
		destroyRecord(instance)
	elseif p3 == "DestroyLayers" then
		local v4 = v3[instance]

		if not v4 then
			return
		end

		for _, v5 in options and options.Ids or {} do
			v4.Layers[v5] = nil
		end

		sortLayers(v4)

		if next(v4.Layers) == nil then
			destroyRecord(instance)
		else
			v4.Active = true
		end
	else
		local v4 = options or {}
		local record = getRecord(instance, mode, v4.Range)

		if p3 == "SetLayer" then
			setLayer(record, v4.Id, {
				Priority = v4.Priority,
				Blend = v4.Blend,
				Motion = deserializeMotion(v4.Motion),
				Goals = v4.Goals or {}
			})
		elseif p3 == "RemoveLayer" then
			local id = v4.Id

			if v4.Fade then
				retireLayer(record, id)
			else
				removeLayer(record, id, false) -- equivalent call inferred; original call site unknown
			end
		elseif p3 == "ClearLayers" then
			table.clear(record.Layers)
			table.clear(record.Order)
		elseif p3 == "Snap" then
			snap(record, v4.Id)
		elseif p3 == "Impulse" then
			impulse(record, v4.Id, v4.Velocities or {})
		end

		record.Active = true

		if record.Mode == "Settle" then
			scheduleSettle(record)
		end
	end
end

local ReplicatedSpring = {
	BaseLayerId = "Base",
	_SimulatedOnSpring = simulatedSpringEvent,
	Spring = function(value: number?, value2: number?)
		return {
			Kind = "Spring",
			DampingRatio = value or 1,
			Frequency = value2 or 4
		}
	end,
	Tween = function(tweenInfo)
		return {
			Kind = "Tween",
			TweenInfo = tweenInfo
		}
	end,
	Instant = function()
		return {
			Kind = "Instant"
		}
	end,
	Motor = function(p, p2: number?)
		return {
			Kind = "Motor",
			Motion = normalizeEase(p),
			Rate = p2 == nil and 1 or p2
		}
	end
}

function ReplicatedSpring.Create(_, instance, p2)
	local v4

	if p2 then
		v4 = p2.AssignServer == true
	else
		v4 = false
	end

	local v5 = true
	local v6 = {}
	local v7 = {
		Instance = instance,
		Range = not (p2 and p2.Range) and 900 or p2.Range
	}

	local function dispatch(p3: string, options, player)
		assert(v5, "dead spring controller")
		local v8 = options or {}
		v8.Range = v7.Range

		if v2 then
			if player then
				springEvent:FireClient(player, p3, fn(instance), v8)
				return
			end

			if not isServer then
				applyEvent("Simulate", instance, p3, v8)
				return
			end

			springEvent:FireAllClients(p3, fn(instance), v8)

			if v4 then
				applyEvent("Settle", instance, p3, v8)
			end
		else
			simulatedSpringEvent:Fire(p3, fn(instance), v8)
		end
	end

	function v7:SetLayer(id: string, data, p4)
		v6[id] = true
		dispatch("SetLayer", {
			Id = id,
			Priority = data.Priority,
			Blend = data.Blend or "Set",
			Motion = serializeMotion((normalizeMotion(data.Motion))),
			Goals = data.Goals
		}, p4)
	end

	function v7:SetBase(goals, motion, p5)
		v7:SetLayer("Base", {
			Priority = -1000000000,
			Blend = "Set",
			Motion = motion,
			Goals = goals
		}, p5)
	end

	function v7.SetTween(_, p3, p4, p5)
		v7:SetBase(p4, ReplicatedSpring.Tween(p3), p5)
	end

	function v7.RemoveLayer(_, id: string, fade: boolean?, p4)
		dispatch("RemoveLayer", {
			Id = id,
			Fade = fade
		}, p4)
	end

	function v7.ClearLayers(_, p3)
		dispatch("ClearLayers", {}, p3)
	end

	function v7.Impulse(_, id: string, velocities, p5)
		dispatch("Impulse", {
			Id = id,
			Velocities = velocities
		}, p5)
	end

	function v7.Snap(_, id: string?, p4)
		dispatch("Snap", {
			Id = id
		}, p4)
	end

	function v7.GetGoals(_, p3: string)
		local v8 = v3[instance]

		if not v8 then
			return nil
		end

		local layer = v8.Layers[p3]

		if layer then
			return table.clone(layer.Goals)
		end

		return nil
	end

	function v7:GetValue(p3: string)
		local v8 = v3[instance]

		if not v8 then
			return instance[p3]
		end

		local v9 = v8.Composed[p3]

		if v9 == nil then
			return instance[p3]
		end

		return v9
	end

	function v7.Destroy(_)
		if not v5 then
			return
		end

		local ids = {}

		for k in v6 do
			table.insert(ids, k)
		end

		dispatch("DestroyLayers", {
			Ids = ids
		})
		table.clear(v6)
		v5 = false
	end

	return v7
end

function ReplicatedSpring._OnSpringUpdate(p: string, p2, p3)
	if not p2 then
		return
	end

	local instance = fn(p2)

	if not instance then
		return
	end

	applyEvent("Simulate", instance, p, p3)
end

function ReplicatedSpring._Step(p: number)
	total += p
	local currentCamera = workspace.CurrentCamera
	local position

	if currentCamera then
		position = currentCamera.CFrame.Position
	end

	local v4 = nil

	for k, v5 in v3 do
		if k.Parent == nil then
			v4 = v4 or {}
			assert(v4, "bad list")
			table.insert(v4, k)
		elseif v5.Mode == "Simulate" and v5.Active then
			if position and v5.Range < 1e999 then
				local cullPosition = getCullPosition(k)

				if cullPosition and (cullPosition - position).Magnitude > v5.Range then
					continue
				end
			end

			local composed, v7 = resolve(v5, p, false)
			v5.Composed = composed

			for k2, v8 in composed do
				k[k2] = v8
			end

			v5.Active = not v7
			local v8 = nil

			for k2, layer in v5.Layers do
				if not layer.Retiring then
					continue
				end

				local v9

				if layer.Motion.Kind == "Motor" then
					local motion = layer.Motion.Motion or v

					if motion.Kind == "Instant" then
						v9 = true
					elseif motion.Kind == "Tween" then
						local tweenInfo = motion.TweenInfo
						v9 = total - layer.TweenClock >= tweenInfo.DelayTime + tweenInfo.Time
					else
						local motorRateSpring = layer.MotorRateSpring
						v9 = not motorRateSpring or motorRateSpring:canSleep()
					end
				else
					v9 = v7
				end

				if not v9 then
					continue
				end

				v8 = v8 or {}
				assert(v8, "bad list")
				table.insert(v8, k2)
			end

			if v8 then
				for _, v9 in v8 do
					v5.Layers[v9] = nil
				end

				sortLayers(v5)
			end
		end
	end

	if v4 then
		for _, v5 in v4 do
			destroyRecord(v5)
		end
	end
end

if v2 and RunService:IsClient() then
	springEvent.OnClientEvent:Connect(ReplicatedSpring._OnSpringUpdate)
end

if GlobalUtil.FFlags.IsUnitTest == false then
	RunService.Heartbeat:Connect(ReplicatedSpring._Step)
end

return ReplicatedSpring