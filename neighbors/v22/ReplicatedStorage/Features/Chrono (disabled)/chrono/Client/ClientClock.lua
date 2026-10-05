local RunService = game:GetService("RunService")
local Warn = require(script.Parent.Parent.Shared.Warn)
local Config = require(script.Parent.Parent.Shared.Config)
require(script.Parent.Parent.Shared.Types)
local InterpolationBuffer = require(script.Parent.InterpolationBuffer)
local clientClocks = {}
local serverOwnedClocks = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetBuffer(data)
	if data.buffer then
		return InterpolationBuffer.GetBuffer(data.buffer, data.tickRate)
	end

	return data.bufferConst or 0
end

local function Clear(p)
	p.lastClockAt = nil
	p.lastClockDuration = 0
	p.renderAt = nil

	if p.buffer then
		p.buffer.init = false
	end
end

local function GetTargetRenderTime(p)
	if p.renderAt then
		return p.renderAt
	end

	Warn.low("ClientClock: Render time not yet established for", p.name)
	return 0
end

local function GetEstimatedServerTime(data)
	if data.lastClockAt then
		return data.lastClockAt + (os.clock() - data.lastClockDuration)
	end

	Warn.low("ClientClock: Estimated server time not yet established for", data.name)
	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckHasLastClockAt(p, lastClockAt: number)
	if not p.lastClockAt then
		p.lastClockAt = lastClockAt
		p.lastClockDuration = os.clock()
		p.renderAt = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Refresh(state, lastClockAt: number)
	if state.lastClockAt then
		if state.lastClockAt < lastClockAt then
			state.lastClockAt = lastClockAt
			state.lastClockDuration = os.clock()
			return true
		else
			return false
		end
	else
		CheckHasLastClockAt(state, lastClockAt) -- equivalent call inferred; original call site unknown
		return false
	end
end

local function OnSnapShot(state, lastClockAt: number)
	if state.lastClockAt then
		if state.buffer then
			InterpolationBuffer.Register(state.buffer, lastClockAt)
		end

		local refresh = Refresh(state, lastClockAt) -- equivalent call inferred; original call site unknown

		if refresh and not state.renderAt then
			local buffer = GetBuffer(state) -- equivalent call inferred; original call site unknown
			state.renderAt = lastClockAt - buffer
		end
	else
		CheckHasLastClockAt(state, lastClockAt) -- equivalent call inferred; original call site unknown
	end
end

local function SetTickRate(p, tickRate: number)
	if p.tickRate == tickRate then
		return
	end

	p.tickRate = tickRate
end

local function Destroy(p)
	clientClocks[p] = nil

	if serverOwnedClocks[p] then
		serverOwnedClocks[p] = nil
	end
end

local function Update(state, p: number)
	local now = os.clock()
	local buffer = GetBuffer(state) -- equivalent call inferred; original call site unknown

	if not state.lastClockAt then
		return
	end

	local v4 = state.lastClockAt + (now - state.lastClockDuration)
	local renderAt = (state.renderAt or v4 - buffer) + p
	local v6 = buffer - (v4 - renderAt)

	if math.abs(v6) > 0.1 then
		renderAt = v4 - buffer
	elseif v6 > 0.01 then
		renderAt = math.max(v4 - buffer, renderAt - p * 0.1)
	elseif v6 < -0.01 then
		renderAt = math.min(v4 - buffer, renderAt + p * 0.1)
	end

	state.renderAt = renderAt
end

local function new(p: number, name: string, BUFFER: number?, owner)
	local v3 = {
		name = name,
		lastClockAt = nil,
		lastClockDuration = 0,
		renderAt = nil,
		tickRate = p,
		_baseTickRate = p,
		_owner = owner,
		buffer = nil,
		bufferConst = BUFFER,
		OnSnapShot = OnSnapShot,
		Refresh = Refresh,
		GetEstimatedServerTime = GetEstimatedServerTime,
		GetTargetRenderTime = GetTargetRenderTime,
		Clear = Clear,
		SetTickRate = SetTickRate,
		Destroy = Destroy
	}

	if not BUFFER then
		v3.buffer = InterpolationBuffer.new(v3)
	end

	if not owner then
		serverOwnedClocks[v3] = true
	end

	clientClocks[v3] = true
	return v3
end

Config._WaitForLock(function()
	if RunService:IsServer() then
		return
	end

	for k, _EntityConfig in Config._EntityConfigs do
		local CLIENT_CLOCK = _EntityConfig.CLIENT_CLOCK

		if not CLIENT_CLOCK then
			Warn.high("Entity Config", k, "is missing client clocks")
			break
		end

		CLIENT_CLOCK.NORMAL = new(_EntityConfig.TICK_RATE, k .. "_NORMAL", _EntityConfig.BUFFER)

		if _EntityConfig.HALF_TICK_DISTANCE < 1e999 then
			CLIENT_CLOCK.HALF = new(_EntityConfig.TICK_RATE * 2, k .. "_HALF", _EntityConfig.BUFFER)
		end
	end
end)
return {
	_getBuffer = GetBuffer,
	new = new,
	clientClocks = clientClocks,
	serverOwnedClocks = serverOwnedClocks,
	UpdateAll = function(p: number)
		for k, _ in clientClocks do
			Update(k, p)
		end
	end
}