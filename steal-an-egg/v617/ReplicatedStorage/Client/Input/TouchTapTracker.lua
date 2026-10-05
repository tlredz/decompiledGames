local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = require(ReplicatedStorage.Packages.Log)
local t = require(ReplicatedStorage.Packages.t)
local TouchTapTracker = {}
TouchTapTracker.__index = TouchTapTracker
TouchTapTracker.__class = "TouchTapTracker"
local strict = t.strict(t.optional(t.table))
local strict2 = t.strict(t.optional(t.number))
local v = Log.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function requireTouch(p)
	assert(p.UserInputType == Enum.UserInputType.Touch)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function travelled(p, p2)
	local origin = p.origin

	if origin then
		return (p2.Position - origin).Magnitude
	end

	return nil
end

function TouchTapTracker.new(options)
	strict(options)

	if options then
		strict2(options.MaxMovement)
		strict2(options.MaxDuration)
	end

	local v2 = options or {}
	local object = setmetatable({}, TouchTapTracker)
	object.slop = v2.MaxMovement or 16
	object.holdLimit = v2.MaxDuration or 0.35
	object.claimed = nil
	object.pressedAt = 0
	object.origin = nil
	object.aborted = false
	v:AtDebug():Log("tap tracker ready")
	return object
end

function TouchTapTracker:Reset()
	self.claimed = nil
	self.pressedAt = 0
	self.origin = nil
	self.aborted = false
end

function TouchTapTracker.IsTrackingInput(p, p2)
	return p.claimed == p2
end

function TouchTapTracker.IsCancelled(p)
	return p.aborted
end

function TouchTapTracker:Begin(claimed)
	requireTouch(claimed) -- equivalent call inferred; original call site unknown
	self.claimed = claimed
	self.pressedAt = os.clock()
	self.origin = claimed.Position
	self.aborted = false
end

function TouchTapTracker:Update(p)
	requireTouch(p) -- equivalent call inferred; original call site unknown

	if self.claimed ~= p or self.aborted then
		return false
	end

	local v2 = travelled(self, p) -- equivalent call inferred; original call site unknown
	local aborted = v2 == nil or self.slop < v2
	self.aborted = aborted
	return not aborted
end

function TouchTapTracker:Evaluate(p, flag: boolean)
	requireTouch(p) -- equivalent call inferred; original call site unknown
	local v2 = travelled(self, p) -- equivalent call inferred; original call site unknown
	local pressedAt = self.pressedAt
	local v3 = not flag

	if v3 then
		if self.claimed == p then
			v3 = not self.aborted

			if v3 then
				if v2 == nil or not (pressedAt > 0 and os.clock() - pressedAt <= self.holdLimit) then
					v3 = false
				else
					v3 = v2 <= self.slop
				end
			end
		else
			v3 = false
		end
	end

	self:Reset()
	return v3
end

return TouchTapTracker