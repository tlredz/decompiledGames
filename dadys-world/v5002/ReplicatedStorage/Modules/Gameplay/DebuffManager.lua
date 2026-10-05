local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DebuffConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Gameplay"):WaitForChild("DebuffConfig"))
local DebuffImmunityFeedback = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Gameplay"):WaitForChild("DebuffImmunityFeedback"))
local DebuffManager = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function isTargetLive(character)
	if not (character and character.Parent) then
		return false
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(character)
	return not playerFromCharacter or playerFromCharacter.Character == character
end

local function now()
	return workspace:GetServerTimeNow()
end

local v = {}
local v2 = {}

local function debugLog(...) end

local function updateDebuffTimerAttributes(instance, p)
	if not (instance and instance.Parent) then
		return
	end

	local v3 = v2[instance] and v2[instance][p]

	if v3 then
		instance:SetAttribute("Debuff_" .. p .. "_EndTime", v3.endTime)
		instance:SetAttribute("Debuff_" .. p .. "_Strength", v3.strength)
		instance:SetAttribute("Debuff_" .. p .. "_Source", v3.source or p)
	else
		instance:SetAttribute("Debuff_" .. p .. "_EndTime", nil)
		instance:SetAttribute("Debuff_" .. p .. "_Strength", nil)
		instance:SetAttribute("Debuff_" .. p .. "_Source", nil)
	end

	local v4 = v[instance] and v[instance][p]

	if not (v4 and #v4 > 0) then
		instance:SetAttribute("Debuff_" .. p .. "_Pending", nil)
		return
	end

	local v5 = {}

	for _, v6 in ipairs(v4) do
		local source = v6.options and v6.options.source or p .. "_" .. v6.strength
		table.insert(v5, string.format("%d:%.2f:%s", v6.strength, v6.endTime, source))
	end

	instance:SetAttribute("Debuff_" .. p .. "_Pending", table.concat(v5, ","))
end

local function queuePendingDebuff(p, p2, strength, duration, options)
	if not v[p] then
		v[p] = {}
	end

	if not v[p][p2] then
		v[p][p2] = {}
	end

	local endTime = workspace:GetServerTimeNow() + duration
	local source = options and options.source

	for _, v4 in ipairs(v[p][p2]) do
		local source2 = v4.options and v4.options.source

		if not (v4.strength == strength and source2 == source) then
			continue
		end

		v4.endTime = math.max(v4.endTime, endTime)
		v4.duration = duration
		debugLog("Extended pending", p2, "strength", strength, "source", tostring(source), "for", p.Name)
		updateDebuffTimerAttributes(p, p2)
		return
	end

	table.insert(v[p][p2], {
		strength = strength,
		duration = duration,
		options = options,
		endTime = endTime
	})
	debugLog("Queued pending", p2, "strength", strength, "source", tostring(source), "for", p.Name)
	updateDebuffTimerAttributes(p, p2)
end

local function getStrongestPendingDebuff(p, p2)
	local v3 = v[p] and v[p][p2]

	if not v3 or #v3 == 0 then
		return nil
	end

	local v4 = nil
	local v5 = nil

	for i, v6 in ipairs(v3) do
		if not (not v4 or v6.strength > v4.strength) then
			continue
		end

		v5 = i
		v4 = v6
	end

	if v4 then
		table.remove(v3, v5)
	end

	return v4
end

local function clearPendingDebuffs(p, p2)
	if v[p] then
		if p2 then
			v[p][p2] = nil
		else
			v[p] = nil
		end
	end
end

local function clearPendingDebuffBySource(p, p2, p3)
	if not (v[p] and v[p][p2]) then
		return false
	end

	local v3 = v[p][p2]
	local flag = false

	for i = #v3, 1, -1 do
		local v4 = v3[i]
		local source = v4.options and v4.options.source or ""

		if not string.find(source, p3) then
			continue
		end

		debugLog("Clearing pending", p2, "from source matching:", p3)
		table.remove(v3, i)
		flag = true
	end

	if flag then
		updateDebuffTimerAttributes(p, p2)
	end

	return flag
end

local function setActiveDebuffInfo(instance, p, endTime, strength, source)
	if not v2[instance] then
		v2[instance] = {}
	end

	v2[instance][p] = {
		endTime = endTime,
		strength = strength,
		source = source or p .. "_" .. strength
	}
	updateDebuffTimerAttributes(instance, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearActiveDebuffInfo(p, p2)
	if v2[p] then
		v2[p][p2] = nil
		updateDebuffTimerAttributes(p, p2)
	end
end

local function createDebuffScript(parent, name, p2, p3)
	debugLog("createDebuffScript called:", parent.Name, name, "strength:", p2, "duration:", p3)
	local stats = parent:FindFirstChild("Stats")

	if stats and name == "Slow" then
		local speedModifier = stats:FindFirstChild("SpeedModifier")
		local runSpeedModifier = stats:FindFirstChild("RunSpeedModifier")

		if speedModifier then
			debugLog("  SpeedModifier BEFORE new debuff:", speedModifier.Value)
		end

		if runSpeedModifier then
			debugLog("  RunSpeedModifier BEFORE new debuff:", runSpeedModifier.Value)
		end
	end

	local stringValue = Instance.new("StringValue")
	stringValue.Name = name
	local stringValue2 = Instance.new("StringValue")
	stringValue2.Name = "DebuffType"
	stringValue2.Value = name
	stringValue2.Parent = stringValue
	local intValue = Instance.new("IntValue")
	intValue.Name = "DebuffStrength"
	intValue.Value = p2
	intValue.Parent = stringValue
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "Duration"
	numberValue.Value = p3
	numberValue.Parent = stringValue

	if DebuffConfig.IsRefreshable(name) then
		local numberValue2 = Instance.new("NumberValue")
		numberValue2.Name = "RefreshTime"
		numberValue2.Value = tick()
		numberValue2.Parent = stringValue
	end

	stringValue.Parent = parent
	local clone = game.ServerStorage.Scripts.DebuffScript:Clone()
	clone.DebuffType.Value = name
	clone.DebuffStrength.Value = p2
	clone.Duration.Value = p3
	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "DebuffValueRef"
	objectValue.Value = stringValue
	objectValue.Parent = clone
	clone.Parent = parent
	clone.Disabled = false
	debugLog("createDebuffScript complete, script enabled")
	return clone
end

local v3 = { "IndicatorOnly", "SpringFever" }

-- equivalent calls inferred from this helper; original call sites unknown
local function isIndicatorOnly(stringValue)
	for _, attributeName in ipairs(v3) do
		if stringValue:GetAttribute(attributeName) then
			return true
		end
	end

	return false
end

local function checkExistingDebuff(instance, p)
	for _, stringValue in ipairs(instance:GetChildren()) do
		if not (stringValue:IsA("StringValue") and stringValue.Name == p) then
			continue
		end

		-- equivalent call inferred; original call site unknown
		if isIndicatorOnly(stringValue) then
			continue
		end

		debugLog("checkExistingDebuff found:", p, "on", instance.Name)
		return stringValue
	end

	return nil
end

function DebuffManager.ApplySlowness(instance, strength, duration2, options)
	if not instance then
		return false
	end

	debugLog("ApplySlowness called on", instance.Name, "strength:", strength, "duration:", duration2)
	local stats = instance:FindFirstChild("Stats")

	if stats then
		local speedModifier = stats:FindFirstChild("SpeedModifier")
		local runSpeedModifier = stats:FindFirstChild("RunSpeedModifier")

		if speedModifier then
			debugLog("  Current SpeedModifier:", speedModifier.Value)
		end

		if runSpeedModifier then
			debugLog("  Current RunSpeedModifier:", runSpeedModifier.Value)
		end
	end

	if instance:GetAttribute("SlownessImmunity") or instance:GetAttribute("DebuffImmune") then
		debugLog("  Target has SlownessImmunity or DebuffImmune, returning false")
		DebuffImmunityFeedback.Notify(instance, "Slow")
		return false
	else
		local options2 = options or {}
		local allowRefreshOnEqual = options2.allowRefreshOnEqual ~= false
		local source = options2.source or "Slow_" .. strength
		local v5 = checkExistingDebuff(instance, "Slow")

		if v5 then
			local debuffStrength = v5:FindFirstChild("DebuffStrength")
			local duration = v5:FindFirstChild("Duration")

			if debuffStrength then
				debugLog("  Found existing Slow debuff, strength:", debuffStrength.Value)

				if strength < debuffStrength.Value then
					debugLog("  Existing debuff is stronger, queuing weaker debuff for later")
					queuePendingDebuff(instance, "Slow", strength, duration2, options2)
					return false
				elseif debuffStrength.Value == strength then
					local slow = v2[instance] and v2[instance].Slow
					local source2 = slow and slow.source

					if allowRefreshOnEqual and (not source2 or source2 == source or source2 == source .. "_Linger" or source == (source2 or "") .. "_Linger" or source2:gsub(
						"_Linger$",
						""
					) == source:gsub("_Linger$", "")) then
						debugLog("  Same source, refreshing Slow duration to", duration2)
						DebuffManager.RefreshDebuff(instance, "Slow", duration2)
						setActiveDebuffInfo(
							instance,
							"Slow",
							workspace:GetServerTimeNow() + duration2,
							strength,
							source
						)
						return false
					else
						if not allowRefreshOnEqual then
							debugLog("  Equal strength but refresh not allowed, returning false")
							return false
						end

						debugLog(
							"  Equal strength Slow from different source, queuing:",
							source,
							"vs existing:",
							source2
						)
						queuePendingDebuff(instance, "Slow", strength, duration2, options2)
						return false
					end
				else
					local source2 = nil
					local slow = v2[instance] and v2[instance].Slow
					local value

					if duration then
						if slow and slow.endTime then
							value = math.max(0, slow.endTime - workspace:GetServerTimeNow())
							source2 = slow.source
						else
							value = duration.Value
						end
					else
						value = 0
					end

					if value > 1 then
						debugLog(
							"  Queuing weaker debuff (strength",
							debuffStrength.Value,
							") with",
							value,
							"s remaining, source:",
							source2 or "none"
						)
						queuePendingDebuff(instance, "Slow", debuffStrength.Value, value, {
							allowRefreshOnEqual = false,
							source = source2
						})
					end

					debugLog(
						"  Destroying weaker debuff (strength",
						debuffStrength.Value,
						") to apply stronger (strength",
						strength,
						")"
					)
					v5:Destroy()
					clearActiveDebuffInfo(instance, "Slow") -- equivalent call inferred; original call site unknown
				end
			else
				debugLog("  WARNING: Existing Slow debuff has no DebuffStrength child!")
			end
		end

		debugLog("  Creating new Slow debuff, strength:", strength)
		createDebuffScript(instance, "Slow", strength, duration2)
		setActiveDebuffInfo(instance, "Slow", workspace:GetServerTimeNow() + duration2, strength, source)
		return true
	end
end

function DebuffManager.ApplyTiredness(instance, strength, duration2, options)
	if not instance then
		return false
	end

	if instance:GetAttribute("DebuffImmune") then
		debugLog("  Target has DebuffImmune, returning false")
		DebuffImmunityFeedback.Notify(instance, "Tired")
		return false
	else
		local options2 = options or {}
		local allowRefreshOnEqual = options2.allowRefreshOnEqual ~= false
		local source = options2.source or "Tired_" .. strength
		local v5 = checkExistingDebuff(instance, "Tired")

		if v5 then
			local debuffStrength = v5:FindFirstChild("DebuffStrength")
			local duration = v5:FindFirstChild("Duration")

			if debuffStrength then
				if strength < debuffStrength.Value then
					debugLog("  Existing Tired is stronger, queuing weaker for later")
					queuePendingDebuff(instance, "Tired", strength, duration2, options2)
					return false
				elseif debuffStrength.Value == strength then
					local tired = v2[instance] and v2[instance].Tired
					local source2 = tired and tired.source

					if allowRefreshOnEqual and (not source2 or source2 == source or source2 == source .. "_Linger" or source == (source2 or "") .. "_Linger" or source2:gsub(
						"_Linger$",
						""
					) == source:gsub("_Linger$", "")) then
						debugLog("  Same source, refreshing Tired duration to", duration2)
						DebuffManager.RefreshDebuff(instance, "Tired", duration2)
						setActiveDebuffInfo(
							instance,
							"Tired",
							workspace:GetServerTimeNow() + duration2,
							strength,
							source
						)
					elseif allowRefreshOnEqual then
						debugLog(
							"  Equal strength Tired from different source, queuing:",
							source,
							"vs existing:",
							source2
						)
						queuePendingDebuff(instance, "Tired", strength, duration2, options2)
					end

					return false
				else
					local source2 = nil
					local tired = v2[instance] and v2[instance].Tired
					local value

					if duration then
						if tired and tired.endTime then
							value = math.max(0, tired.endTime - workspace:GetServerTimeNow())
							source2 = tired.source
						else
							value = duration.Value
						end
					else
						value = 0
					end

					if value > 1 then
						debugLog(
							"  Queuing weaker Tired (strength",
							debuffStrength.Value,
							") with",
							value,
							"s remaining, source:",
							source2 or "none"
						)
						queuePendingDebuff(instance, "Tired", debuffStrength.Value, value, {
							allowRefreshOnEqual = false,
							source = source2
						})
					end

					v5:Destroy()
					clearActiveDebuffInfo(instance, "Tired") -- equivalent call inferred; original call site unknown
				end
			end
		end

		createDebuffScript(instance, "Tired", strength, duration2)
		setActiveDebuffInfo(instance, "Tired", workspace:GetServerTimeNow() + duration2, strength, source)
		return true
	end
end

function DebuffManager.ApplyConfusion(instance, strength, duration2, options)
	if not instance then
		return false
	end

	if instance:GetAttribute("DebuffImmune") then
		debugLog("  Target has DebuffImmune, returning false")
		DebuffImmunityFeedback.Notify(instance, "Confused")
		return false
	else
		local options2 = options or {}
		local source = options2.source or "Confused_" .. strength
		local v5 = checkExistingDebuff(instance, "Confused")

		if v5 then
			local debuffStrength = v5:FindFirstChild("DebuffStrength")
			local duration = v5:FindFirstChild("Duration")

			if debuffStrength then
				if strength < debuffStrength.Value then
					debugLog("  Existing Confused is stronger, queuing weaker for later")
					queuePendingDebuff(instance, "Confused", strength, duration2, options2)
					return false
				else
					if debuffStrength.Value == strength then
						return false
					end

					local source2 = nil
					local confused = v2[instance] and v2[instance].Confused
					local value

					if duration then
						if confused and confused.endTime then
							value = math.max(0, confused.endTime - workspace:GetServerTimeNow())
							source2 = confused.source
						else
							value = duration.Value
						end
					else
						value = 0
					end

					if value > 1 then
						debugLog(
							"  Queuing weaker Confused (strength",
							debuffStrength.Value,
							") with",
							value,
							"s remaining, source:",
							source2 or "none"
						)
						queuePendingDebuff(instance, "Confused", debuffStrength.Value, value, {
							allowRefreshOnEqual = false,
							source = source2
						})
					end

					v5:Destroy()
					clearActiveDebuffInfo(instance, "Confused") -- equivalent call inferred; original call site unknown
				end
			end
		end

		createDebuffScript(instance, "Confused", strength, duration2)
		setActiveDebuffInfo(instance, "Confused", workspace:GetServerTimeNow() + duration2, strength, source)
		return true
	end
end

function DebuffManager.ApplyIllness(instance, strength, duration2, options)
	if not instance then
		return false
	end

	if instance:GetAttribute("DebuffImmune") then
		debugLog("  Target has DebuffImmune, returning false")
		DebuffImmunityFeedback.Notify(instance, "Illness")
		return false
	else
		local options2 = options or {}
		local allowRefreshOnEqual = options2.allowRefreshOnEqual ~= false
		local source = options2.source or "Illness_" .. strength
		local v5 = checkExistingDebuff(instance, "Illness")

		if v5 then
			local debuffStrength = v5:FindFirstChild("DebuffStrength")
			local duration = v5:FindFirstChild("Duration")

			if debuffStrength then
				if strength < debuffStrength.Value then
					debugLog("  Existing Illness is stronger, queuing weaker for later")
					queuePendingDebuff(instance, "Illness", strength, duration2, options2)
					return false
				elseif debuffStrength.Value == strength then
					local illness = v2[instance] and v2[instance].Illness
					local source2 = illness and illness.source

					if allowRefreshOnEqual and (not source2 or source2 == source or source2 == source .. "_Linger" or source == (source2 or "") .. "_Linger" or source2:gsub(
						"_Linger$",
						""
					) == source:gsub("_Linger$", "")) then
						debugLog("  Same source, refreshing Illness duration to", duration2)
						DebuffManager.RefreshDebuff(instance, "Illness", duration2)
						setActiveDebuffInfo(
							instance,
							"Illness",
							workspace:GetServerTimeNow() + duration2,
							strength,
							source
						)
					elseif allowRefreshOnEqual then
						debugLog(
							"  Equal strength Illness from different source, queuing:",
							source,
							"vs existing:",
							source2
						)
						queuePendingDebuff(instance, "Illness", strength, duration2, options2)
					end

					return false
				else
					local source2 = nil
					local illness = v2[instance] and v2[instance].Illness
					local value

					if duration then
						if illness and illness.endTime then
							value = math.max(0, illness.endTime - workspace:GetServerTimeNow())
							source2 = illness.source
						else
							value = duration.Value
						end
					else
						value = 0
					end

					if value > 1 then
						debugLog(
							"  Queuing weaker Illness (strength",
							debuffStrength.Value,
							") with",
							value,
							"s remaining, source:",
							source2 or "none"
						)
						queuePendingDebuff(instance, "Illness", debuffStrength.Value, value, {
							allowRefreshOnEqual = false,
							source = source2
						})
					end

					v5:Destroy()
					clearActiveDebuffInfo(instance, "Illness") -- equivalent call inferred; original call site unknown
				end
			end
		end

		createDebuffScript(instance, "Illness", strength, duration2)
		setActiveDebuffInfo(instance, "Illness", workspace:GetServerTimeNow() + duration2, strength, source)
		return true
	end
end

function DebuffManager.ApplyTreadmillDazed(instance, strength, duration2, options)
	if not instance then
		return false
	end

	if instance:GetAttribute("DebuffImmune") then
		debugLog("  Target has DebuffImmune, returning false")
		DebuffImmunityFeedback.Notify(instance, "TreadmillDazed")
		return false
	else
		local options2 = options or {}
		local source = options2.source or "TreadmillDazed"
		local lastTreadmillDazedTime = instance:GetAttribute("LastTreadmillDazedTime") or 0
		local now2 = tick()

		if now2 - lastTreadmillDazedTime < 5 then
			return false
		end

		local v5 = checkExistingDebuff(instance, "TreadmillDazed")

		if v5 then
			local debuffStrength = v5:FindFirstChild("DebuffStrength")
			local duration = v5:FindFirstChild("Duration")

			if debuffStrength then
				if strength < debuffStrength.Value then
					debugLog("  Existing TreadmillDazed is stronger, queuing weaker for later")
					queuePendingDebuff(instance, "TreadmillDazed", strength, duration2, options2)
					return false
				else
					if debuffStrength.Value == strength then
						return false
					end

					local source2 = nil
					local treadmillDazed = v2[instance] and v2[instance].TreadmillDazed
					local value

					if duration then
						if treadmillDazed and treadmillDazed.endTime then
							value = math.max(0, treadmillDazed.endTime - workspace:GetServerTimeNow())
							source2 = treadmillDazed.source
						else
							value = duration.Value
						end
					else
						value = 0
					end

					if value > 1 then
						debugLog(
							"  Queuing weaker TreadmillDazed (strength",
							debuffStrength.Value,
							") with",
							value,
							"s remaining, source:",
							source2 or "none"
						)
						queuePendingDebuff(instance, "TreadmillDazed", debuffStrength.Value, value, {
							allowRefreshOnEqual = false,
							source = source2
						})
					end

					v5:Destroy()
					clearActiveDebuffInfo(instance, "TreadmillDazed") -- equivalent call inferred; original call site unknown
				end
			end
		end

		instance:SetAttribute("LastTreadmillDazedTime", now2)
		createDebuffScript(instance, "TreadmillDazed", strength, duration2)
		setActiveDebuffInfo(instance, "TreadmillDazed", workspace:GetServerTimeNow() + duration2, strength, source)
		return true
	end
end

function DebuffManager.ApplyDebuff(instance, p, p2, p3, p4)
	if instance:GetAttribute("DebuffImmune") then
		DebuffImmunityFeedback.Notify(instance, p)
		return false
	end

	if p == "Slow" then
		return DebuffManager.ApplySlowness(instance, p2, p3, p4)
	elseif p == "Tired" then
		return DebuffManager.ApplyTiredness(instance, p2, p3, p4)
	elseif p == "Confused" then
		return DebuffManager.ApplyConfusion(instance, p2, p3, p4)
	elseif p == "Illness" then
		return DebuffManager.ApplyIllness(instance, p2, p3, p4)
	elseif p == "TreadmillDazed" then
		return DebuffManager.ApplyTreadmillDazed(instance, p2, p3, p4)
	end

	warn("Unknown debuff type:", p)
	return false
end

function DebuffManager.RefreshDebuff(p, p2, p3)
	if not p then
		return false
	end

	local v4 = checkExistingDebuff(p, p2)
	local refreshTime = v4 and v4:FindFirstChild("RefreshTime")

	if not refreshTime then
		return false
	end

	refreshTime.Value = tick()
	local duration = p3 and v4:FindFirstChild("Duration")

	if duration then
		duration.Value = p3
		debugLog("RefreshDebuff: Updated Duration.Value to", p3, "for", p2)
	end

	return true
end

function DebuffManager.RemoveDebuff(p, p2, p3)
	if not p then
		return false
	end

	local v4 = checkExistingDebuff(p, p2)

	if not v4 then
		return false
	end

	v4:Destroy()
	clearActiveDebuffInfo(p, p2) -- equivalent call inferred; original call site unknown
	local v5 = not p3 and getStrongestPendingDebuff(p, p2)

	if v5 then
		debugLog("Applying pending", p2, "strength", v5.strength, "for", p.Name)
		task.defer(function()
			-- equivalent call inferred; original call site unknown
			if isTargetLive(p) then
				DebuffManager.ApplyDebuff(p, p2, v5.strength, v5.duration, v5.options)
			end
		end)
	end

	return true
end

function DebuffManager.RemoveDebuffCompletely(p, p2)
	if not p then
		return false
	end

	if v[p] then
		if p2 then
			v[p][p2] = nil
		else
			v[p] = nil
		end
	end

	clearActiveDebuffInfo(p, p2) -- equivalent call inferred; original call site unknown
	local v4 = checkExistingDebuff(p, p2)

	if not v4 then
		return false
	end

	v4:Destroy()
	return true
end

function DebuffManager.HasDebuff(p, p2)
	if p then
		return checkExistingDebuff(p, p2) ~= nil
	end

	return false
end

function DebuffManager.GetDebuffStrength(p, p2)
	if not p then
		return 0
	end

	local v4 = checkExistingDebuff(p, p2)
	local debuffStrength = v4 and v4:FindFirstChild("DebuffStrength")

	if debuffStrength then
		return debuffStrength.Value
	end

	return 0
end

function DebuffManager.GetRemainingTime(p, p2)
	if not p then
		return 0
	end

	local v4 = v2[p] and v2[p][p2]

	if v4 and v4.endTime then
		return (math.max(0, v4.endTime - workspace:GetServerTimeNow()))
	end

	return 0
end

function DebuffManager.GetDebuffInfo(p, p2)
	if not p then
		return nil
	end

	local v4 = v2[p] and v2[p][p2]

	if v4 then
		return {
			strength = v4.strength,
			endTime = v4.endTime,
			remainingTime = math.max(0, v4.endTime - workspace:GetServerTimeNow()),
			source = v4.source
		}
	end

	return nil
end

function DebuffManager.GetAllDebuffInfo(p)
	if not p then
		return {}
	end

	local result = {}
	local v4 = v2[p]

	if v4 then
		for k, v5 in pairs(v4) do
			result[k] = {
				strength = v5.strength,
				endTime = v5.endTime,
				remainingTime = math.max(0, v5.endTime - workspace:GetServerTimeNow()),
				source = v5.source
			}
		end
	end

	return result
end

function DebuffManager.OnDebuffNaturalExpiry(p, p2)
	if not p then
		return
	end

	debugLog("OnDebuffNaturalExpiry called for", p2, "on", p.Name)
	clearActiveDebuffInfo(p, p2) -- equivalent call inferred; original call site unknown

	while true do
		local strongestPendingDebuff = getStrongestPendingDebuff(p, p2)

		if not strongestPendingDebuff then
			break
		end

		local v4 = math.max(0, strongestPendingDebuff.endTime - workspace:GetServerTimeNow())
		debugLog(
			"Applying pending",
			p2,
			"strength",
			strongestPendingDebuff.strength,
			"remaining time:",
			v4,
			"for",
			p.Name
		)

		if v4 > 0.5 then
			local v5 = strongestPendingDebuff
			local v6 = v4
			task.defer(function()
				-- equivalent call inferred; original call site unknown
				if isTargetLive(p) then
					DebuffManager.ApplyDebuff(p, p2, v5.strength, v6, v5.options)
				end
			end)
			return
		else
			debugLog("Pending debuff expired while queued, checking for next one")
		end
	end

	updateDebuffTimerAttributes(p, p2)
end

function DebuffManager.CleanupCharacter(p)
	if not p then
		return
	end

	v[p] = nil
	v2[p] = nil
end

function DebuffManager.ClearPendingDebuffBySource(p, p2, p3)
	return (clearPendingDebuffBySource(p, p2, p3))
end

function DebuffManager.QueuePendingDebuff(p, p2, strength, duration, options)
	queuePendingDebuff(p, p2, strength, duration, options)
end

return DebuffManager