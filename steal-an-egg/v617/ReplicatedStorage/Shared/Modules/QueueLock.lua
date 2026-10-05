local QueueLock = {}
QueueLock.__index = QueueLock
local class = {}
class.__index = class

-- equivalent calls inferred from this helper; original call sites unknown
local function newLease(lock)
	return (setmetatable({
		lock = lock,
		takenAt = os.clock()
	}, class))
end

local function nextInLine(lock)
	local line = lock.line

	while lock.head < lock.tail do
		local v = line[lock.head]
		line[lock.head] = nil
		lock.head += 1

		if coroutine.status(v) == "suspended" then
			return v
		end
	end

	lock.head = 1
	lock.tail = 1
	return nil
end

local function failureReport(p)
	return debug.traceback(`QueueLock body raised: {tostring(p)}`, 2)
end

local function settle(object, flag: boolean, ...)
	object:GiveBack()

	if not flag then
		error(..., 0)
	end

	return ...
end

function QueueLock.new()
	return (setmetatable({
		occupant = nil,
		line = {},
		head = 1,
		tail = 1
	}, QueueLock))
end

function QueueLock:TryTake()
	if self.occupant then
		return nil
	end

	local occupant = newLease(self) -- equivalent call inferred; original call site unknown
	self.occupant = occupant
	return occupant
end

function QueueLock:Take()
	local v = self:TryTake()

	if v then
		return v
	end

	self.line[self.tail] = coroutine.running()
	self.tail += 1
	return coroutine.yield()
end

function QueueLock:WithLock(callback, ...)
	return settle(self:Take(), xpcall(callback, failureReport, ...))
end

function QueueLock.Destroy(list)
	if list.occupant then
		return
	end

	table.clear(list)
	setmetatable(list, nil)
end

function class:GiveBack()
	local lock = self.lock

	if lock.occupant ~= self then
		error("GiveBack: this lease does not hold its lock", 2)
	end

	local v = nextInLine(lock)

	if v == nil then
		lock.occupant = nil
		return
	end

	local occupant = newLease(lock) -- equivalent call inferred; original call site unknown
	lock.occupant = occupant
	task.defer(v, occupant)
end

return QueueLock