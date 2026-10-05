local RunService = game:GetService("RunService")
local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
local TweenCoordinator = {}
TweenCoordinator.__index = TweenCoordinator
TweenCoordinator.ease = {
	linear = function(p)
		return p
	end,
	quadIn = function(p)
		return p * p
	end,
	quadOut = function(p)
		return 1 - (1 - p) * (1 - p)
	end,
	quadInOut = function(p)
		if p < 0.5 then
			return 2 * p * p
		end

		return 1 - (-2 * p + 2) ^ 2 / 2
	end,
	cubicOut = function(p)
		return 1 - (1 - p) ^ 3
	end,
	sineOut = function(p)
		return (math.sin(p * 3.141592653589793 * 0.5))
	end
}
local v2 = {}
local v3 = {}
local count = 0
local total = 0
local v4 = 30
local v5 = 1 / v4
local heartbeatConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function _ensureConn()
	if heartbeatConnection then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < v5 then
			return
		end

		local v6 = total
		total = 0

		for i = #v2, 1, -1 do
			if v2[i].update(v6) == false then
				table.remove(v2, i)
			end
		end

		for k, v7 in pairs(v3) do
			if not v7.paused then
				v7.t += v6
			end

			local v8 = not (v7.d > 0) and 1 or v7.t / v7.d or 1
			local v9 = v8 >= 1 and 1 or v8
			local ease = v7.ease(v9)
			local from = v7.from
			local to = v7.to

			if typeof(from) == "number" then
				from += (to - from) * ease
			elseif typeof(from) == "Vector3" then
				from = from:Lerp(to, ease)
			elseif typeof(from) == "Color3" then
				from = from:Lerp(to, ease)
			elseif typeof(from) == "UDim2" then
				from = UDim2.new(
					from.X.Scale + (to.X.Scale - from.X.Scale) * ease,
					from.X.Offset + (to.X.Offset - from.X.Offset) * ease,
					from.Y.Scale + (to.Y.Scale - from.Y.Scale) * ease,
					from.Y.Offset + (to.Y.Offset - from.Y.Offset) * ease
				)
			elseif typeof(from) == "CFrame" then
				from = from:Lerp(to, ease)
			elseif typeof(from) == "NumberRange" then
				from = NumberRange.new(from.Min + (to.Min - from.Min) * ease, from.Max + (to.Max - from.Max) * ease)
			elseif typeof(from) == "ColorSequence" then
				local lerped = from.Keypoints[1].Value:Lerp(to.Keypoints[1].Value, ease)
				local lerped2 = from.Keypoints[#from.Keypoints].Value:Lerp(to.Keypoints[#to.Keypoints].Value, ease)
				from = ColorSequence.new(lerped, lerped2)
			elseif v9 >= 1 then
				from = to or from
			end

			if v7.inst and v7.inst[v7.prop] ~= nil then
				v7.inst[v7.prop] = from
			end

			if not (v9 >= 1) then
				continue
			end

			if v7._completedSignal then
				v7._completedSignal:Fire(v7.inst)
			end

			if v7.done then
				pcall(v7.done, v7.inst)
			end

			v3[k] = nil
		end

		if next(v3) == nil and #v2 == 0 then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)
end

function TweenCoordinator.addHandler(update)
	table.insert(v2, {
		update = update
	})
	_ensureConn() -- equivalent call inferred; original call site unknown
	return #v2
end

function TweenCoordinator.tweenProperty(inst, prop: string, to, value: number?, callback, callback2)
	_ensureConn() -- equivalent call inferred; original call site unknown
	count += 1
	local id = count
	v3[id] = {
		id = id,
		inst = inst,
		prop = prop,
		from = inst[prop],
		to = to,
		d = math.max(value or 0.2, 0.008333333333333333),
		ease = callback or TweenCoordinator.ease.quadOut,
		t = 0,
		paused = false,
		done = callback2
	}
	return id
end

function TweenCoordinator.pause(p: number)
	local v6 = v3[p]

	if v6 then
		v6.paused = true
	end
end

function TweenCoordinator.resume(p: number)
	local v6 = v3[p]

	if v6 then
		v6.paused = false
	end
end

function TweenCoordinator.isPaused(p: number)
	local v6 = v3[p]
	return v6 and v6.paused or false
end

function TweenCoordinator.cancel(p: number)
	v3[p] = nil
end

function TweenCoordinator.setRate(value: number)
	v4 = math.clamp(value or 30, 10, 240)
	v5 = 1 / v4
end

function TweenCoordinator.spinGroup(list, p: number, p2: number?)
	local total2 = 0
	return TweenCoordinator.addHandler(function(p3)
		total2 += p3

		if p2 and p2 <= total2 then
			return false
		end

		local v6 = math.rad(p) * p3

		for i = 1, #list do
			list[i].CFrame *= CFrame.Angles(0, v6, 0)
		end

		return true
	end)
end

function TweenCoordinator.newTween(p, items, p2: number?, callback)
	local tweenProperties = {}
	local v6 = false
	local v7 = Signal2.new()

	local function onAnyDone()
		local count2 = 0

		for _, v8 in ipairs(tweenProperties) do
			if v3[v8] then
				count2 += 1
			end
		end

		if count2 == 0 then
			v7:Fire(p)
		end
	end

	local function play()
		tweenProperties = {}

		for k, item in pairs(items) do
			local tweenProperty = TweenCoordinator.tweenProperty(p, k, item, p2, callback, onAnyDone)
			v3[tweenProperty]._completedSignal = v7
			table.insert(tweenProperties, tweenProperty)
		end

		v6 = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function pause()
		for _, v8 in ipairs(tweenProperties) do
			TweenCoordinator.pause(v8)
		end

		v6 = true
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resume()
		for _, v8 in ipairs(tweenProperties) do
			TweenCoordinator.resume(v8)
		end

		v6 = false
	end

	local function cancel()
		for _, v8 in ipairs(tweenProperties) do
			TweenCoordinator.cancel(v8)
		end

		tweenProperties = {}
	end

	return {
		Play = function(_)
			play()
		end,
		Pause = function(_)
			pause() -- equivalent call inferred; original call site unknown
		end,
		Resume = function(_)
			resume() -- equivalent call inferred; original call site unknown
		end,
		Cancel = function(_)
			cancel()
		end,
		Completed = v7
	}
end

return TweenCoordinator