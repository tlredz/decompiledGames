local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Save = require(ReplicatedStorage.Shared.Save)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.number)
local SpeedPowerProjection = {
	Changed = Signal.new()
}
local DEFAULT_BASE_SPEED_POWER = TreadmillUtil.DEFAULT_BASE_SPEED_POWER
local v = DEFAULT_BASE_SPEED_POWER
local v2 = nil
local flag = false
local v3 = DEFAULT_BASE_SPEED_POWER
local total = 0

local function readSavedPower()
	local v4 = Save.Await()
	local normalizeSpeedPower = TreadmillUtil.NormalizeSpeedPower
	local v5

	if v4 ~= nil then
		v5 = v4.SpeedPower
	end

	return normalizeSpeedPower(v5)
end

local function readOverride(attributeName: string)
	local attribute = Workspace:GetAttribute(attributeName)

	if type(attribute) == "number" and attribute > 0 then
		return attribute
	end

	return nil
end

local function runTotal()
	local v4 = v3 + total

	if v2 == nil then
		return DEFAULT_BASE_SPEED_POWER
	end

	if flag then
		return v4
	end

	return (math.max(DEFAULT_BASE_SPEED_POWER, v4))
end

local function computeShown()
	local equalisedSpeedPower = Workspace:GetAttribute("EqualisedSpeedPower")

	if type(equalisedSpeedPower) ~= "number" or not (equalisedSpeedPower > 0) then
		equalisedSpeedPower = nil
	end

	if equalisedSpeedPower ~= nil then
		return equalisedSpeedPower
	end

	local v4 = v3 + total

	if v2 == nil then
		v4 = DEFAULT_BASE_SPEED_POWER
	elseif not flag then
		v4 = math.max(DEFAULT_BASE_SPEED_POWER, v4)
	end

	local minimumSpeedPower = Workspace:GetAttribute("MinimumSpeedPower")

	if type(minimumSpeedPower) ~= "number" or not (minimumSpeedPower > 0) then
		minimumSpeedPower = nil
	end

	if minimumSpeedPower == nil then
		return v4
	end

	return (math.max(v4, minimumSpeedPower))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function republish()
	local equalisedSpeedPower = Workspace:GetAttribute("EqualisedSpeedPower")

	if type(equalisedSpeedPower) ~= "number" or not (equalisedSpeedPower > 0) then
		equalisedSpeedPower = nil
	end

	if equalisedSpeedPower == nil then
		equalisedSpeedPower = v3 + total

		if v2 == nil then
			equalisedSpeedPower = DEFAULT_BASE_SPEED_POWER
		elseif not flag then
			equalisedSpeedPower = math.max(DEFAULT_BASE_SPEED_POWER, equalisedSpeedPower)
		end

		local minimumSpeedPower = Workspace:GetAttribute("MinimumSpeedPower")

		if type(minimumSpeedPower) ~= "number" or not (minimumSpeedPower > 0) then
			minimumSpeedPower = nil
		end

		if minimumSpeedPower ~= nil then
			equalisedSpeedPower = math.max(equalisedSpeedPower, minimumSpeedPower)
		end
	end

	if equalisedSpeedPower ~= v then
		v = equalisedSpeedPower
		SpeedPowerProjection.Changed:Fire(v)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncWithSave()
	local v4 = Save.Await()
	local normalizeSpeedPower = TreadmillUtil.NormalizeSpeedPower
	local v5

	if v4 ~= nil then
		v5 = v4.SpeedPower
	end

	DEFAULT_BASE_SPEED_POWER = normalizeSpeedPower(v5)
	local v6 = not flag

	if v6 then
		if v2 == nil then
			v6 = false
		else
			local v7 = DEFAULT_BASE_SPEED_POWER
			v6 = v3 + total <= v7
		end
	end

	if v6 then
		v2 = nil
		v3 = DEFAULT_BASE_SPEED_POWER
		total = 0
	end

	republish() -- equivalent call inferred; original call site unknown
end

function SpeedPowerProjection.ReadProjected()
	return v
end

function SpeedPowerProjection.OpenSession(p: number)
	strict(p)
	local v4 = Save.Await()
	local normalizeSpeedPower = TreadmillUtil.NormalizeSpeedPower
	local v5

	if v4 ~= nil then
		v5 = v4.SpeedPower
	end

	DEFAULT_BASE_SPEED_POWER = normalizeSpeedPower(v5)
	flag = true
	v2 = p
	v3 = math.max(DEFAULT_BASE_SPEED_POWER, v)
	total = 0
	republish() -- equivalent call inferred; original call site unknown
end

function SpeedPowerProjection.CreditRevealedGain(p: number, p2: number)
	strict(p)
	strict(p2)
	local v4

	if v2 == p then
		v4 = p2 > 0
	else
		v4 = false
	end

	if v4 then
		total += p2
		republish() -- equivalent call inferred; original call site unknown
	end

	return v4
end

function SpeedPowerProjection.CloseSession(p: number)
	strict(p)

	if v2 == p then
		flag = false
		syncWithSave() -- equivalent call inferred; original call site unknown
	end
end

local v4 = Save.Await()
local normalizeSpeedPower = TreadmillUtil.NormalizeSpeedPower
local v5

if v4 ~= nil then
	v5 = v4.SpeedPower
end

DEFAULT_BASE_SPEED_POWER = normalizeSpeedPower(v5)
local v6 = not flag

if v6 then
	if v2 == nil then
		v6 = false
	else
		v6 = v3 + total <= DEFAULT_BASE_SPEED_POWER
	end
end

if v6 then
	v2 = nil
	v3 = DEFAULT_BASE_SPEED_POWER
	total = 0
end

republish() -- equivalent call inferred; original call site unknown
Save.Watch("SpeedPower"):Connect(syncWithSave)
Workspace:GetAttributeChangedSignal("EqualisedSpeedPower"):Connect(republish)
Workspace:GetAttributeChangedSignal("MinimumSpeedPower"):Connect(republish)
return SpeedPowerProjection