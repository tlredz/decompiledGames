local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberLib = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.NumberLib)
local total = 0
local total2 = 0
local v = 0
local v2 = 0
local v3 = -1
local v4 = -1
local v5 = 0
local total3 = 0
local v6 = 0
local v7 = false
local FakeVoteCounters = {}

local function setTaggedCounter(tag: string, p: number)
	for _, label in CollectionService:GetTagged(tag) do
		if label:IsA("TextLabel") then
			label.Text = NumberLib.toShort(p)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function renderCounters()
	local v8 = math.round(v)
	local v9 = math.round(v2)

	if v8 ~= v3 then
		v3 = v8
		setTaggedCounter("FabAACounter1", v8)
	end

	if v9 ~= v4 then
		v4 = v9
		setTaggedCounter("FabAACounter2", v9)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function chooseUpdateDelay()
	return math.random() * 0.1 + 0.04
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addFakeVotes(p: number)
	local v8 = math.max(p - (total + total2), 0)
	local v9 = 2956782 - total
	local v10 = 1195370 - total2
	local v11 = 0.62 + math.random() * 0.16000000000000003
	local v12 = math.max(v8 - v10, 0)
	local v13 = math.min(v8, v9)
	local v14 = math.clamp(math.round(v8 * v11), v12, v13)
	total += v14
	total2 += v8 - v14
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getNoisyTargetTotal()
	local v8 = math.clamp(total3 / 20, 0, 1)
	local v9 = -0.015 + math.random() * 0.04
	local v10 = total3 < 20 and 4152151 or 4152152
	return (math.clamp(math.round(4152152 * (v8 + v9)), total + total2, v10))
end

function FakeVoteCounters.start()
	total = 0
	total2 = 0
	v = 0
	v2 = 0
	v3 = -1
	v4 = -1
	total3 = 0
	v6 = 0
	v5 = chooseUpdateDelay()
	v7 = true
	renderCounters() -- equivalent call inferred; original call site unknown
end

function FakeVoteCounters.update(p: number)
	if not v7 then
		return
	end

	total3 += p
	v6 += p

	while v5 <= v6 and total3 < 20 do
		v6 -= v5
		addFakeVotes(getNoisyTargetTotal()) -- equivalent call inferred; original call site unknown
		v5 = chooseUpdateDelay()
	end

	local v8 = 1 - math.exp(p * -20)
	v = math.lerp(v, total, v8)
	v2 = math.lerp(v2, total2, v8)
	renderCounters() -- equivalent call inferred; original call site unknown

	if total3 >= 20 then
		total = 2956782
		total2 = 1195370
		v = total
		v2 = total2
		renderCounters() -- equivalent call inferred; original call site unknown
		FakeVoteCounters.finish()
	end
end

function FakeVoteCounters.finish()
	v7 = false
	total3 = 0
	v6 = 0
end

return FakeVoteCounters