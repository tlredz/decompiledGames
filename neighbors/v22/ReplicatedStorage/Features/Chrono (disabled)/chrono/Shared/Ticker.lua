local Ticker = {}

local function popSwap(list, _, tickerIndex)
	local count = #list

	if tickerIndex ~= count then
		local v = list[count]
		list[tickerIndex] = v
		v._tickerIndex = tickerIndex
	end

	list[count] = nil
end

require(script.Parent.Types)
local Warn = require(script.Parent.Warn)

function Ticker.new(config)
	return {
		tickedHalf = false,
		tickHalfRate = config.TICK_RATE * 2,
		tickRate = config.TICK_RATE,
		lastTicked = 0,
		tickedFrame = 0,
		objects = {},
		callbacks = {},
		config = config,
		dt = 0,
		halfdt = 0
	}
end

function Ticker.AddCallback(p, callback)
	table.insert(p.callbacks, callback)
end

function Ticker.RemoveCallback(p, callback)
	local index = table.find(p.callbacks, callback)

	if index then
		table.remove(p.callbacks, index)
	end
end

function Ticker.Add(ticker, p)
	table.insert(ticker.objects, p)
	p._ticker = ticker
	p._tickerIndex = #ticker.objects
end

function Ticker.Remove(p, state)
	local _tickerIndex = state._tickerIndex

	if not _tickerIndex then
		Warn.low("Ticker.remove called on object not in ticker", state.id)
		return
	end

	local objects = p.objects
	local count = #objects

	if _tickerIndex ~= count then
		local object = objects[count]
		objects[_tickerIndex] = object
		object._tickerIndex = _tickerIndex
	end

	objects[count] = nil
	state._ticker = nil
	state._tickerIndex = nil
end

function Ticker:move(p2)
	local _ticker = self._ticker

	if _ticker then
		Ticker.Remove(_ticker, self)
	end

	Ticker.Add(p2, self)
end

function Ticker:CheckUpdate()
	local v = os.clock() - self.lastTicked

	if not (self.tickRate <= v) then
		return false
	end

	self.lastTicked = os.clock()
	self.tickedFrame = time()
	self.tickedHalf = not self.tickedHalf

	if self.tickedHalf then
		self.halfdt = v + self.dt
	else
		self.halfdt = v
	end

	self.dt = v

	if #self.callbacks > 0 then
		for _, callback in self.callbacks do
			callback(self, v)
		end
	end

	return true
end

return Ticker