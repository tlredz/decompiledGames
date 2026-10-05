local HttpService = game:GetService("HttpService")
local v = {
	animation = true,
	label = true,
	m1hitreg = true,
	m1end = true
}
local CustomM1StyleUtil = {}

local function trimString(value)
	if type(value) ~= "string" then
		return nil
	end

	local v2 = value:gsub("^%s+", ""):gsub("%s+$", "")

	if v2 == "" then
		return nil
	end

	return v2
end

function CustomM1StyleUtil.trimString(value)
	if type(value) ~= "string" then
		return nil
	end

	local v2 = value:gsub("^%s+", ""):gsub("%s+$", "")

	if v2 == "" then
		return nil
	end

	return v2
end

function CustomM1StyleUtil.decodeStyleValue(value)
	local v2

	if type(value) == "string" then
		v2 = value:gsub("^%s+", ""):gsub("%s+$", "")

		if v2 == "" then
			v2 = nil
		end
	end

	if not (v2 and string.sub(string.lower(v2), 1, 4) == "m1::") then
		return nil
	end

	local v3 = string.sub(v2, 5)

	if type(v3) ~= "string" then
		return nil
	end

	local v4 = v3:gsub("^%s+", ""):gsub("%s+$", "")

	if v4 == "" then
		return nil
	end

	return v4
end

function CustomM1StyleUtil.encodeStyleValue(value)
	local v2

	if type(value) == "string" then
		v2 = value:gsub("^%s+", ""):gsub("%s+$", "")

		if v2 == "" then
			v2 = nil
		end
	end

	if not v2 then
		return nil
	end

	local decodeStyleValue = CustomM1StyleUtil.decodeStyleValue(v2)

	if decodeStyleValue then
		return "m1::" .. decodeStyleValue
	end

	return "m1::" .. v2
end

local sanitizeAnimationId

sanitizeAnimationId = function(value)
	local v2 = nil

	if type(value) == "number" then
		v2 = math.floor(value + 0.5)
	elseif type(value) == "string" then
		local match = value:match("%d+")

		if match then
			v2 = tonumber(match)

			if type(v2) == "number" then
				v2 = math.floor(v2 + 0.5)
			end
		end
	elseif type(value) == "table" then
		v2 = sanitizeAnimationId(value.AnimationId or value.animationId)
	end

	if type(v2) == "number" and v2 > 0 then
		return v2
	end

	return nil
end

local function normalizeSlotToken(p, p2)
	if p == nil then
		return nil
	end

	local v2 = tostring(p):lower():gsub("^%s+", ""):gsub("%s+$", "")

	if v2 == "" then
		return nil
	end

	local v3 = v2:gsub("[%s_%-]", "")

	if v3 == "uppercut" then
		return "uppercut"
	end

	if v3 == "downslam" or v3 == "slam" then
		return "downslam"
	end

	local v4 = tonumber(v3:match("^m1(%d+)$")) or tonumber(v3:match("^m(%d+)$")) or tonumber(v3:match("^hit(%d+)$")) or tonumber(v3)

	if type(v4) ~= "number" then
		return nil
	end

	local v5 = math.floor(v4)

	if v5 < 1 or p2 < v5 then
		return nil
	end

	return v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeSlotMode(value)
	if string.lower((tostring(value or ""))):gsub("^%s+", ""):gsub("%s+$", "") == "custom" then
		return "Custom"
	end

	return "Traditional"
end

local function sanitizeNumberish(p)
	local v2 = tonumber(p)

	if type(v2) == "number" and v2 == v2 then
		return v2
	end

	return nil
end

local function sanitizeRuntimeEventType(value)
	local v2

	if type(value) == "string" then
		v2 = value:gsub("^%s+", ""):gsub("%s+$", "")

		if v2 == "" then
			v2 = nil
		end
	end

	if not v2 then
		return nil
	end

	local v3 = string.lower(v2)

	if v[v3] then
		return nil
	end

	if v3 == "damage" then
		return "Damage"
	elseif v3 == "sound" then
		return "Sound"
	end

	return v2
end

local sanitizeRuntimePropValue

sanitizeRuntimePropValue = function(list, value)
	local v2 = value or 0

	if v2 > 6 then
		return nil
	end

	local typeName = type(list)

	if typeName == "boolean" then
		return list
	end

	if typeName == "number" then
		local v3 = tonumber(list)

		if type(v3) == "number" and v3 == v3 and v3 ~= 1e999 and v3 ~= -1e999 then
			return v3
		end

		return nil
	else
		if typeName == "string" then
			return list
		end

		if typeName ~= "table" then
			return nil
		end

		local count = 0
		local v3 = 0
		local v4 = true

		for k in pairs(list) do
			count += 1

			if type(k) == "number" and not (k < 1) and k % 1 == 0 then
				if v3 < k then
					v3 = k
				end
			else
				v4 = false
				break
			end
		end

		if v4 and count > 0 and v3 == count then
			local result = {}
			local flag = false

			for i = 1, v3 do
				local v6 = sanitizeRuntimePropValue(list[i], v2 + 1)

				if v6 == nil then
					continue
				end

				result[i] = v6
				flag = true
			end

			if flag then
				return result
			end

			return nil
		else
			local result = {}
			local flag = false

			for k, v6 in pairs(list) do
				local v7 = nil

				if type(k) == "string" then
					if type(k) == "string" then
						v7 = k:gsub("^%s+", ""):gsub("%s+$", "")

						if v7 == "" then
							v7 = nil
						end
					end
				elseif type(k) == "number" and k == k then
					v7 = tostring(k)
				end

				if not v7 then
					continue
				end

				local v8 = sanitizeRuntimePropValue(v6, v2 + 1)

				if v8 == nil then
					continue
				end

				result[v7] = v8
				flag = true
			end

			if flag then
				return result
			end

			return nil
		end
	end
end

local function sanitizeRuntimeEventProps(p, props)
	if type(props) ~= "table" then
		return nil
	end

	local result = sanitizeRuntimePropValue(props, 0)

	if type(result) ~= "table" then
		return nil
	end

	if p == "Damage" then
		for _, v2 in ipairs({
			"Damage",
			"Hitbox",
			"SideHitbox",
			"Offset",
			"Knockback",
			"Stun",
			"KnockbackUp",
			"RagdollTime",
			"LoopDuration",
			"LoopInterval"
		}) do
			local v3 = tonumber(result[v2])

			if type(v3) ~= "number" or v3 ~= v3 then
				v3 = nil
			end

			if type(v3) ~= "number" then
				continue
			end

			if v2 == "RagdollTime" then
				v3 = math.max(0, v3)
			end

			result[v2] = v3
		end

		if type(result.Offset) ~= "number" then
			local rayOffset = tonumber(result.RayOffset)

			if type(rayOffset) ~= "number" or rayOffset ~= rayOffset then
				rayOffset = nil
			end

			if type(rayOffset) == "number" then
				result.Offset = rayOffset
			end
		end

		result.RayOffset = nil

		for _, v2 in ipairs({
			"Bypass",
			"UseChargeMultiplier",
			"VictimTarget",
			"AllVictims",
			"IsLooped",
			"AllowRagdoll"
		}) do
			if result[v2] == true then
				result[v2] = true
			elseif result[v2] == false then
				result[v2] = false
			end
		end

		if result.AllowRagdoll == true and type(result.RagdollTime) ~= "number" then
			result.RagdollTime = 1
		end

		result.AllowRagdoll = nil
	elseif p == "Sound" then
		for _, v2 in ipairs({ "SoundName", "CustomSoundId", "AnchorAttachment" }) do
			local v3 = result[v2]
			local v4

			if type(v3) == "string" then
				v4 = v3:gsub("^%s+", ""):gsub("%s+$", "")

				if v4 == "" then
					v4 = nil
				end
			end

			if v4 then
				result[v2] = v4
			end
		end

		for _, v2 in ipairs({
			"Volume",
			"PlaybackSpeed",
			"FadeInTime",
			"FadeOutTime",
			"SkipBeginningSecs",
			"SkipEndSecs"
		}) do
			local v3 = tonumber(result[v2])

			if type(v3) ~= "number" or v3 ~= v3 then
				v3 = nil
			end

			if type(v3) == "number" then
				result[v2] = v3
			end
		end

		for _, v2 in ipairs({
			"Global",
			"VictimTarget",
			"AllVictims",
			"Cancellable",
			"Looped",
			"DontMove"
		}) do
			if result[v2] == true then
				result[v2] = true
			elseif result[v2] == false then
				result[v2] = false
			end
		end
	end

	if next(result) == nil then
		return nil
	end

	return result
end

local function sanitizeRuntimeEvents(events)
	if type(events) ~= "table" then
		return nil
	end

	local result = {}

	for _, v2 in ipairs(events) do
		if type(v2) ~= "table" then
			continue
		end

		local type2 = v2.type or v2.Type
		local v3

		if type(type2) == "string" then
			v3 = type2:gsub("^%s+", ""):gsub("%s+$", "")

			if v3 == "" then
				v3 = nil
			end
		end

		local v4

		if v3 then
			local v5 = string.lower(v3)

			if not v[v5] then
				v4 = v5 == "damage" and "Damage" or v5 == "sound" and "Sound" or v3
			end
		end

		if not v4 then
			continue
		end

		local offset = tonumber(v2.offset or v2.Offset)

		if type(offset) ~= "number" or offset ~= offset then
			offset = nil
		end

		if not (type(offset) == "number" and offset >= 0) then
			continue
		end

		local v5 = {
			type = v4,
			offset = offset
		}
		local category = v2.category or v2.Category
		local category2

		if type(category) == "string" then
			category2 = category:gsub("^%s+", ""):gsub("%s+$", "")

			if category2 == "" then
				category2 = nil
			end
		end

		if category2 then
			v5.category = category2
		end

		local branch = v2.branch or v2.Branch
		local branch2

		if type(branch) == "string" then
			branch2 = branch:gsub("^%s+", ""):gsub("%s+$", "")

			if branch2 == "" then
				branch2 = nil
			end
		end

		if branch2 then
			v5.branch = branch2
		end

		local props = sanitizeRuntimeEventProps(v4, v2.props or v2.Properties)

		if props then
			v5.props = props
		end

		table.insert(result, v5)
	end

	if #result == 0 then
		return nil
	end

	table.sort(result, function(a, b)
		local offset = tonumber(a and a.offset) or 0
		local offset2 = tonumber(b and b.offset) or 0

		if offset == offset2 then
			return tostring(a and a.type or "") < tostring(b and b.type or "")
		end

		return offset < offset2
	end)
	return result
end

local function decodeSlotMetadataContext(json, p)
	if type(json) ~= "string" or json == "" then
		return nil
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(json)
	end)

	if not success or type(result) ~= "table" or type(result.Slots) ~= "table" then
		return nil
	end

	local slotTokens = {}
	local slotTokens2 = {}
	local slotModes = {}

	for i, slot in ipairs(result.Slots) do
		if type(slot) ~= "table" then
			continue
		end

		local slotToken = normalizeSlotToken(slot.slot or slot.Slot, p)

		if slotToken == nil then
			continue
		end

		slotTokens[i] = slotToken
		local branch = slot.branch or slot.Branch
		local v3

		if type(branch) == "string" then
			v3 = branch:gsub("^%s+", ""):gsub("%s+$", "")

			if v3 == "" then
				v3 = nil
			end
		end

		if v3 then
			slotTokens2[string.lower(v3)] = slotToken
		end

		if type(slotToken) == "number" then
			slotToken = tostring(slotToken)
		end

		local mode = slot.mode or slot.Mode
		slotModes[slotToken] = normalizeSlotMode(mode)
	end

	if next(slotModes) == nil and next(slotTokens) == nil and next(slotTokens2) == nil then
		return nil
	end

	if next(slotModes) == nil or not slotModes then
		slotModes = nil
	end

	if next(slotTokens) == nil or not slotTokens then
		slotTokens = nil
	end

	if next(slotTokens2) == nil or not slotTokens2 then
		slotTokens2 = nil
	end

	return {
		slotModes = slotModes,
		slotByLayer = slotTokens,
		slotByBranchLower = slotTokens2
	}
end

local function decodeSlotModesFromSlotsMetadata(p, p2)
	local v2 = decodeSlotMetadataContext(p, p2)

	if type(v2) == "table" then
		return v2.slotModes
	end

	return nil
end

local function mergeStyleSlotModes(p, slotModes)
	if type(p) ~= "table" or type(slotModes) ~= "table" then
		return p
	end

	local slotModes3 = {}
	local slotModes2

	if type(p.slotModes) == "table" then
		slotModes2 = p.slotModes or nil
	end

	if type(slotModes2) == "table" then
		for k, slotMode in pairs(slotModes2) do
			slotModes3[k] = normalizeSlotMode(slotMode)
		end
	end

	for k, item in pairs(slotModes) do
		slotModes3[k] = normalizeSlotMode(item)
	end

	if next(slotModes3) ~= nil then
		p.slotModes = slotModes3
	end

	return p
end

local function styleDefinitionLooksIncomplete(p)
	if type(p) ~= "table" then
		return true
	end

	local slotModes = p.slotModes

	if type(slotModes) ~= "table" or next(slotModes) == nil then
		return true
	end

	local v2 = false

	for _, slotMode in pairs(slotModes) do
		if normalizeSlotMode(slotMode) ~= "Custom" then
			continue
		end

		v2 = true
		break
	end

	if not v2 then
		return false
	end

	local custom = p.custom

	if type(custom) ~= "table" then
		return true
	end

	for k, slotMode in pairs(slotModes) do
		if normalizeSlotMode(slotMode) == "Custom" and type(custom[k]) ~= "table" then
			return true
		end
	end

	return false
end

local function normalizeBranch(value)
	if type(value) ~= "string" then
		return nil
	end

	local v2 = value:gsub("^%s+", ""):gsub("%s+$", "")

	if v2 == "" then
		return nil
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function slotKeyForStorage(slotToken)
	if type(slotToken) == "number" then
		return (tostring(slotToken))
	end

	if type(slotToken) == "string" then
		return slotToken
	end

	return nil
end

local function countMapEntries(items)
	if type(items) ~= "table" then
		return 0
	end

	local count = 0

	for _ in pairs(items) do
		count += 1
	end

	return count
end

local function sanitizeHitregPayload(props)
	if type(props) ~= "table" then
		return nil
	end

	local result = {}
	local flag = false

	for _, v2 in ipairs({
		"Damage",
		"Hitbox",
		"SideHitbox",
		"Offset",
		"Knockback",
		"Stun",
		"KnockbackUp",
		"RagdollTime"
	}) do
		local v3 = tonumber(props[v2])

		if type(v3) ~= "number" or v3 ~= v3 then
			v3 = nil
		end

		if type(v3) ~= "number" then
			continue
		end

		if v2 == "RagdollTime" then
			v3 = math.max(0, v3)
		end

		result[v2] = v3
		flag = true
	end

	if type(result.Offset) ~= "number" then
		local rayOffset = tonumber(props.RayOffset)

		if type(rayOffset) ~= "number" or rayOffset ~= rayOffset then
			rayOffset = nil
		end

		if type(rayOffset) == "number" then
			result.Offset = rayOffset
			flag = true
		end
	end

	if props.AllowRagdoll == true and type(result.RagdollTime) ~= "number" then
		result.RagdollTime = 1
		flag = true
	end

	local hitBranch = props.HitBranch
	local hitBranch2

	if type(hitBranch) == "string" then
		hitBranch2 = hitBranch:gsub("^%s+", ""):gsub("%s+$", "")

		if hitBranch2 == "" then
			hitBranch2 = nil
		end
	end

	if hitBranch2 then
		result.HitBranch = hitBranch2
		flag = true
	end

	local missBranch = props.MissBranch
	local missBranch2

	if type(missBranch) == "string" then
		missBranch2 = missBranch:gsub("^%s+", ""):gsub("%s+$", "")

		if missBranch2 == "" then
			missBranch2 = nil
		end
	end

	if missBranch2 then
		result.MissBranch = missBranch2
		flag = true
	end

	if flag then
		return result
	end

	return nil
end

local function cloneShallowTable(items)
	if type(items) ~= "table" then
		return nil
	end

	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local function collectTimelineContext(list, p, p2)
	if type(list) ~= "table" then
		return nil
	end

	local function resolveSlotToken(data, value, layer)
		local slotToken = normalizeSlotToken(data and (data.M1Slot or data.Slot or data.EventSlot or data.Name), p)

		if slotToken ~= nil then
			return slotToken
		end

		local slotByBranchLower

		if type(p2) == "table" then
			slotByBranchLower = p2.slotByBranchLower or nil
		end

		if type(slotByBranchLower) == "table" and value then
			local v2 = slotByBranchLower[string.lower(value)]

			if v2 ~= nil then
				return v2
			end
		end

		local slotByLayer

		if type(p2) == "table" then
			slotByLayer = p2.slotByLayer or nil
		end

		if type(slotByLayer) == "table" then
			local v2 = slotByLayer[layer]

			if v2 ~= nil then
				return v2
			end
		end

		return (normalizeSlotToken(value, p))
	end

	local companions = {}
	local otherByBranch = {}
	local otherByLayer = {}
	local otherBySlot = {}
	local slotEntries = {}

	for _, v6 in ipairs(list) do
		if type(v6) ~= "table" then
			continue
		end

		local eventType = v6.EventType
		local props = type(v6.Properties) ~= "table" and {} or v6.Properties or {}
		local layer = tonumber(v6.Layer) or 0
		local time = tonumber(v6.Time) or 0
		local _branch = props._branch
		local branch

		if type(_branch) == "string" then
			branch = _branch:gsub("^%s+", ""):gsub("%s+$", "")

			if branch == "" then
				branch = nil
			end
		end

		local slotToken = resolveSlotToken(props, branch, layer)
		local slotKey = slotKeyForStorage(slotToken) -- equivalent call inferred; original call site unknown

		if eventType == "Animation" then
			if sanitizeAnimationId(props.AnimationId) then
				table.insert(slotEntries, {
					time = time,
					layer = layer,
					slot = slotToken,
					slotKey = slotKey,
					branch = branch,
					editorUid = tonumber(props.__EditorUid)
				})
			end
		elseif eventType == "M1Hitreg" or eventType == "M1End" then
			table.insert(companions, {
				eventType = eventType,
				time = time,
				layer = layer,
				branch = branch,
				ownerUid = tonumber(props.__M1TraditionalOwnerUid),
				props = props
			})
		else
			local v10

			if type(eventType) == "string" then
				v10 = eventType:gsub("^%s+", ""):gsub("%s+$", "")

				if v10 == "" then
					v10 = nil
				end
			end

			local eventType2

			if v10 then
				local v12 = string.lower(v10)

				if not v[v12] then
					eventType2 = v12 == "damage" and "Damage" or v12 == "sound" and "Sound" or v10
				end
			end

			if eventType2 then
				local eventCategory = v6.EventCategory
				local eventCategory2

				if type(eventCategory) == "string" then
					eventCategory2 = eventCategory:gsub("^%s+", ""):gsub("%s+$", "")

					if eventCategory2 == "" then
						eventCategory2 = nil
					end
				end

				local v12 = {
					eventType = eventType2,
					eventCategory = eventCategory2,
					time = time,
					layer = layer,
					branch = branch,
					slot = slotToken,
					props = props
				}

				if branch then
					otherByBranch[branch] = otherByBranch[branch] or {}
					table.insert(otherByBranch[branch], v12)
				end

				otherByLayer[layer] = otherByLayer[layer] or {}
				table.insert(otherByLayer[layer], v12)

				if type(slotKey) == "string" and slotKey ~= "" then
					otherBySlot[slotKey] = otherBySlot[slotKey] or {}
					table.insert(otherBySlot[slotKey], v12)
				end
			end
		end
	end

	if #slotEntries == 0 then
		return nil
	end

	table.sort(slotEntries, function(a, b)
		if a.time == b.time then
			return a.layer < b.layer
		end

		return a.time < b.time
	end)
	local v6 = {}
	local slot2 = 1

	for _, v8 in ipairs(slotEntries) do
		if type(v8.slot) == "number" then
			v6[v8.slot] = true
		end
	end

	for _, v8 in ipairs(slotEntries) do
		if v8.slot == nil then
			while slot2 <= p and v6[slot2] do
				slot2 += 1
			end

			if slot2 <= p then
				v8.slot = slot2
				v8.slotKey = tostring(slot2)
				v6[slot2] = true
				slot2 += 1
			end
		end

		if not (type(v8.slotKey) ~= "string" or v8.slotKey == "") then
			continue
		end

		local slot = v8.slot

		if type(slot) == "number" then
			slot = tostring(slot)
		elseif type(slot) ~= "string" then
			slot = nil
		end

		v8.slotKey = slot
	end

	return {
		animations = slotEntries,
		companions = companions,
		otherByBranch = otherByBranch,
		otherByLayer = otherByLayer,
		otherBySlot = otherBySlot
	}
end

local function findTraditionalCompanion(ownerAnimationForSlot, p, companions)
	if type(ownerAnimationForSlot) ~= "table" or type(companions) ~= "table" then
		return nil
	end

	if type(ownerAnimationForSlot.editorUid) == "number" then
		for _, v2 in ipairs(companions) do
			if v2.eventType == p and v2.ownerUid == ownerAnimationForSlot.editorUid then
				return v2
			end
		end
	end

	local branch = ownerAnimationForSlot.branch

	if type(branch) ~= "string" or branch == "" then
		return nil
	end

	local v2 = 1e999
	local v3 = nil

	for _, v4 in ipairs(companions) do
		if not (v4.eventType == p and v4.branch == branch) then
			continue
		end

		local v5 = math.abs((tonumber(v4.time) or 0) - (tonumber(ownerAnimationForSlot.time) or 0))

		if not (v5 < v2) then
			continue
		end

		v3 = v4
		v2 = v5
	end

	return v3
end

local function findOwnerAnimationForSlot(k, animations)
	if type(animations) ~= "table" then
		return nil
	end

	local v2 = tonumber(k)

	if type(v2) ~= "number" then
		return nil
	end

	local v3 = math.floor(v2 + 0.5)

	for _, v4 in ipairs(animations) do
		if v4.slot == v3 then
			return v4
		end
	end

	local v4 = {}

	for _, v5 in ipairs(animations) do
		if type(v5.slot) == "number" then
			table.insert(v4, v5)
		end
	end

	table.sort(v4, function(a, b)
		if a.time == b.time then
			return a.layer < b.layer
		end

		return a.time < b.time
	end)
	return v4[v3]
end

local function findNextAnimationTime(data, animations)
	if type(data) ~= "table" or type(animations) ~= "table" then
		return nil
	end

	local branch = data.branch
	local slotKey = data.slotKey

	if not slotKey then
		slotKey = data.slot

		if type(slotKey) == "number" then
			slotKey = tostring(slotKey)
		elseif type(slotKey) ~= "string" then
			slotKey = nil
		end
	end

	if (type(branch) ~= "string" or branch == "") and (type(slotKey) ~= "string" or slotKey == "") then
		return nil
	end

	local time = tonumber(data.time) or 0
	local layer = tonumber(data.layer) or 0
	local v2 = nil

	for _, v3 in ipairs(animations) do
		local v4

		if type(branch) == "string" and branch ~= "" and v3 ~= data then
			v4 = v3.branch == branch
		else
			v4 = false
		end

		local v5 = not v4

		if v5 then
			if type(slotKey) == "string" and slotKey ~= "" and v3 ~= data then
				local slotKey2 = v3.slotKey

				if not slotKey2 then
					slotKey2 = v3.slot

					if type(slotKey2) == "number" then
						slotKey2 = tostring(slotKey2)
					elseif type(slotKey2) ~= "string" then
						slotKey2 = nil
					end
				end

				v5 = slotKey2 == slotKey
			else
				v5 = false
			end
		end

		if not (v4 or v5) then
			continue
		end

		local time2 = tonumber(v3.time) or 0

		if not ((time < time2 or time2 == time and layer < (tonumber(v3.layer) or 0)) and (v2 == nil or time2 < v2)) then
			continue
		end

		v2 = time2
	end

	return v2
end

local function collectCustomEventsForOwner(ownerAnimationForSlot, data)
	if type(ownerAnimationForSlot) ~= "table" or type(data) ~= "table" then
		return nil
	end

	local v2 = {}
	local v3 = {}

	if type(ownerAnimationForSlot.branch) == "string" and ownerAnimationForSlot.branch ~= "" then
		local v4 = data.otherByBranch and data.otherByBranch[ownerAnimationForSlot.branch]

		if type(v4) == "table" then
			for _, v5 in ipairs(v4) do
				if v3[v5] then
					continue
				end

				v3[v5] = true
				table.insert(v2, v5)
			end
		end
	end

	local v4 = data.otherByLayer and data.otherByLayer[tonumber(ownerAnimationForSlot.layer) or 0]

	if type(v4) == "table" then
		for _, v5 in ipairs(v4) do
			if v3[v5] then
				continue
			end

			v3[v5] = true
			table.insert(v2, v5)
		end
	end

	local slotKey = ownerAnimationForSlot.slotKey

	if not slotKey then
		slotKey = ownerAnimationForSlot.slot

		if type(slotKey) == "number" then
			slotKey = tostring(slotKey)
		elseif type(slotKey) ~= "string" then
			slotKey = nil
		end
	end

	local v5

	if type(slotKey) == "string" and slotKey ~= "" and data.otherBySlot then
		v5 = data.otherBySlot[slotKey] or nil
	end

	if type(v5) == "table" then
		for _, v6 in ipairs(v5) do
			if v3[v6] then
				continue
			end

			v3[v6] = true
			table.insert(v2, v6)
		end
	end

	if #v2 == 0 then
		return nil
	end

	local time = tonumber(ownerAnimationForSlot.time) or 0
	local nextAnimationTime = findNextAnimationTime(ownerAnimationForSlot, data.animations)
	local result = {}

	for _, v6 in ipairs(v2) do
		local eventType = v6 and v6.eventType
		local v7

		if type(eventType) == "string" then
			v7 = eventType:gsub("^%s+", ""):gsub("%s+$", "")

			if v7 == "" then
				v7 = nil
			end
		end

		local v8

		if v7 then
			local v9 = string.lower(v7)

			if not v[v9] then
				v8 = v9 == "damage" and "Damage" or v9 == "sound" and "Sound" or v7
			end
		end

		local time2 = tonumber(v6 and v6.time) or 0

		if not v8 or time2 < time or not (type(nextAnimationTime) ~= "number" or not (nextAnimationTime <= time2)) then
			continue
		end

		local v9 = {
			type = v8,
			offset = time2 - time
		}
		local eventCategory = v6 and v6.eventCategory
		local category

		if type(eventCategory) == "string" then
			category = eventCategory:gsub("^%s+", ""):gsub("%s+$", "")

			if category == "" then
				category = nil
			end
		end

		if category then
			v9.category = category
		end

		local branch = v6 and v6.branch
		local branch2

		if type(branch) == "string" then
			branch2 = branch:gsub("^%s+", ""):gsub("%s+$", "")

			if branch2 == "" then
				branch2 = nil
			end
		end

		if branch2 then
			v9.branch = branch2
		end

		local props = sanitizeRuntimeEventProps(v8, v6 and v6.props)

		if props then
			v9.props = props
		end

		table.insert(result, v9)
	end

	if #result == 0 then
		return nil
	end

	table.sort(result, function(a, b)
		local offset = tonumber(a and a.offset) or 0
		local offset2 = tonumber(b and b.offset) or 0

		if offset == offset2 then
			return tostring(a and a.type or "") < tostring(b and b.type or "")
		end

		return offset < offset2
	end)
	return result
end

local function enrichCustomSlotsFromTimeline(state, p, p2, p3)
	if type(state) ~= "table" then
		return state
	end

	local slotModes

	if type(state.slotModes) == "table" then
		slotModes = state.slotModes or nil
	end

	if type(slotModes) ~= "table" then
		return state
	end

	local v2 = collectTimelineContext(p, p2, p3)

	if type(v2) ~= "table" then
		return state
	end

	local custom2

	if type(state.custom) == "table" then
		local custom = state.custom

		if type(custom) == "table" then
			custom2 = {}

			for k, v4 in pairs(custom) do
				custom2[k] = v4
			end
		end

		if not custom2 then
			custom2 = {}
		end
	else
		custom2 = {}
	end

	local count = 0
	local count2 = 0

	for k, slotMode in pairs(slotModes) do
		if normalizeSlotMode(slotMode) ~= "Custom" then
			continue
		end

		count += 1
		local ownerAnimationForSlot = findOwnerAnimationForSlot(k, v2.animations)

		if type(ownerAnimationForSlot) == "table" then
			local v4

			if type(custom2[k]) == "table" then
				local v5 = custom2[k]

				if type(v5) == "table" then
					v4 = {}

					for k2, v6 in pairs(v5) do
						v4[k2] = v6
					end
				end

				if not v4 then
					v4 = {}
				end
			else
				v4 = {}
			end

			local events = collectCustomEventsForOwner(ownerAnimationForSlot, v2)

			if events and type(v4.events) ~= "table" then
				v4.events = events
			end

			if type(v4.hitreg) ~= "table" then
				local traditionalCompanion = findTraditionalCompanion(ownerAnimationForSlot, "M1Hitreg", v2.companions)

				if traditionalCompanion then
					local hitreg = sanitizeHitregPayload(traditionalCompanion.props) or {}
					hitreg.offset = (tonumber(traditionalCompanion.time) or 0) - (tonumber(ownerAnimationForSlot.time) or 0)
					v4.hitreg = hitreg
				elseif type(v4.events) == "table" then
					for _, event in ipairs(v4.events) do
						if event.type ~= "Damage" then
							continue
						end

						local v7 = type(event.props) ~= "table" and {} or event.props or {}
						local hitreg = {}

						for _, v9 in ipairs({
							"Damage",
							"Hitbox",
							"SideHitbox",
							"Offset",
							"Knockback",
							"Stun",
							"KnockbackUp",
							"RagdollTime"
						}) do
							local v10 = tonumber(v7[v9])

							if type(v10) ~= "number" or v10 ~= v10 then
								v10 = nil
							end

							if type(v10) ~= "number" then
								continue
							end

							if v9 == "RagdollTime" then
								v10 = math.max(0, v10)
							end

							hitreg[v9] = v10
						end

						if type(hitreg.Offset) ~= "number" then
							local rayOffset = tonumber(v7.RayOffset)

							if type(rayOffset) ~= "number" or rayOffset ~= rayOffset then
								rayOffset = nil
							end

							if type(rayOffset) == "number" then
								hitreg.Offset = rayOffset
							end
						end

						local offset = tonumber(event.offset)

						if type(offset) ~= "number" or offset ~= offset then
							offset = nil
						end

						hitreg.offset = offset or 0

						if v7.AllowRagdoll == true and type(hitreg.RagdollTime) ~= "number" then
							hitreg.RagdollTime = 1
						end

						if next(hitreg) ~= nil then
							v4.hitreg = hitreg
						end

						break
					end
				end
			end

			local v6 = type(v4["end"]) ~= "table" and findTraditionalCompanion(
				ownerAnimationForSlot,
				"M1End",
				v2.companions
			)

			if v6 then
				local v7 = {
					offset = (tonumber(v6.time) or 0) - (tonumber(ownerAnimationForSlot.time) or 0),
					buffer = 0
				}
				local endBuffer = tonumber(v6.props and v6.props.EndBuffer)

				if type(endBuffer) ~= "number" or endBuffer ~= endBuffer then
					endBuffer = nil
				end

				v7.buffer = endBuffer or 0
				v4["end"] = v7
			end

			if next(v4) ~= nil then
				custom2[k] = v4
				count2 += 1
			end
		else
			warn(string.format(
				"[CustomM1PersistDiag][Server] stage=enrich_slot_owner_missing slot=%s mode=%s",
				tostring(k),
				(tostring(slotMode))
			))
		end
	end

	if next(custom2) ~= nil then
		state.custom = custom2
	end

	if not (count > 0) then
		return state
	end

	local v5 = tonumber(count) or 0
	local v6 = tonumber(count2) or 0
	local custom = state.custom
	local count3

	if type(custom) == "table" then
		count3 = 0

		for _ in pairs(custom) do
			count3 += 1
		end
	else
		count3 = 0
	end

	warn(string.format(
		"[CustomM1PersistDiag][Server] stage=enrich_custom_from_timeline customSlots=%d filledSlots=%d customCount=%d",
		v5,
		v6,
		tonumber(count3) or 0
	))
	return state
end

local function sanitizeStyleDefinition(p, max)
	if type(p) ~= "table" then
		return nil
	end

	local v2 = {}
	local uppercut2 = nil
	local downslam2 = nil
	local comboLength = p.comboLength or p.ComboLength or p.length

	-- equivalent calls inferred from this helper; original call sites unknown
	local function assignSlot(slotToken, p2)
		local v5 = sanitizeAnimationId(p2)

		if not v5 then
			return
		end

		if slotToken == "uppercut" then
			if not uppercut2 then
				uppercut2 = v5
			end
		elseif slotToken == "downslam" then
			if not downslam2 then
				downslam2 = v5
			end
		elseif type(slotToken) == "number" and not v2[slotToken] then
			v2[slotToken] = v5
		end
	end

	local hits = p.hits or p.Hits

	if type(hits) == "table" then
		for k, hit in pairs(hits) do
			local slotToken = normalizeSlotToken(k, max)

			if type(slotToken) ~= "number" then
				slotToken = normalizeSlotToken(hit and hit.slot, max)
			end

			if type(slotToken) ~= "number" then
				slotToken = tonumber(k)
			end

			assignSlot(slotToken, hit) -- equivalent call inferred; original call site unknown
		end
	end

	for k, v5 in pairs(p) do
		local slotToken = normalizeSlotToken(k, max)

		if not slotToken then
			continue
		end

		assignSlot(slotToken, v5) -- equivalent call inferred; original call site unknown
	end

	local uppercut = p.uppercut or p.Uppercut
	local v5 = sanitizeAnimationId(uppercut)

	if v5 and not uppercut2 then
		uppercut2 = v5
	end

	local downslam = p.downslam or p.Downslam
	local v6 = sanitizeAnimationId(downslam)

	if v6 and not downslam2 then
		downslam2 = v6
	end

	local v7 = 0

	for i = 1, max do
		if v2[i] then
			v7 = i
		end
	end

	local v8 = tonumber(comboLength)
	local v9

	if type(v8) == "number" then
		v9 = math.floor(v8 + 0.5)
	else
		v9 = v7
	end

	if v9 < v7 then
		v9 = v7
	end

	if v9 < 1 then
		return nil
	end

	local comboLength2 = math.clamp(v9, 1, max)
	local v11 = nil

	for i = 1, max do
		if not v2[i] then
			continue
		end

		v11 = v2[i]
		break
	end

	if not v11 then
		return nil
	end

	local hits2 = {}

	for i = 1, comboLength2 do
		hits2[i] = v2[i] or v11
	end

	local v13 = {
		comboLength = comboLength2,
		hits = hits2,
		uppercut = uppercut2,
		downslam = downslam2
	}
	local slotModes2 = {}
	local slotModes = p.slotModes or p.SlotModes

	if type(slotModes) == "table" then
		for k, slotMode in pairs(slotModes) do
			local slotToken = normalizeSlotToken(k, max)

			if slotToken == nil then
				continue
			end

			if type(slotToken) == "number" then
				slotToken = tostring(slotToken)
			end

			slotModes2[slotToken] = normalizeSlotMode(slotMode)
		end
	end

	if next(slotModes2) ~= nil then
		v13.slotModes = slotModes2
	end

	local traditional2 = {}
	local traditional = p.traditional or p.Traditional

	if type(traditional) == "table" then
		for k, v16 in pairs(traditional) do
			local slotToken = normalizeSlotToken(k, max)

			if not (slotToken ~= nil and type(v16) == "table") then
				continue
			end

			if type(slotToken) == "number" then
				slotToken = tostring(slotToken)
			end

			local v17 = {}
			local hitreg = v16.hitreg or v16.Hitreg

			if type(hitreg) == "table" then
				local hitreg2 = {}

				for _, v19 in ipairs({
					"Damage",
					"Hitbox",
					"SideHitbox",
					"Offset",
					"Knockback",
					"Stun",
					"KnockbackUp",
					"RagdollTime"
				}) do
					local v20 = tonumber(hitreg[v19])

					if type(v20) ~= "number" or v20 ~= v20 then
						v20 = nil
					end

					if type(v20) ~= "number" then
						continue
					end

					if v19 == "RagdollTime" then
						v20 = math.max(0, v20)
					end

					hitreg2[v19] = v20
				end

				if type(hitreg2.Offset) ~= "number" then
					local rayOffset = tonumber(hitreg.RayOffset)

					if type(rayOffset) ~= "number" or rayOffset ~= rayOffset then
						rayOffset = nil
					end

					if type(rayOffset) == "number" then
						hitreg2.Offset = rayOffset
					end
				end

				local offset = tonumber(hitreg.offset or hitreg.Offset)

				if type(offset) ~= "number" or offset ~= offset then
					offset = nil
				end

				if type(offset) == "number" then
					hitreg2.offset = offset
				end

				if hitreg.AllowRagdoll == true and type(hitreg2.RagdollTime) ~= "number" then
					hitreg2.RagdollTime = 1
				end

				local hitBranch = hitreg.HitBranch
				local hitBranch2

				if type(hitBranch) == "string" then
					hitBranch2 = hitBranch:gsub("^%s+", ""):gsub("%s+$", "")

					if hitBranch2 == "" then
						hitBranch2 = nil
					end
				end

				if hitBranch2 then
					hitreg2.HitBranch = hitBranch2
				end

				local missBranch = hitreg.MissBranch
				local missBranch2

				if type(missBranch) == "string" then
					missBranch2 = missBranch:gsub("^%s+", ""):gsub("%s+$", "")

					if missBranch2 == "" then
						missBranch2 = nil
					end
				end

				if missBranch2 then
					hitreg2.MissBranch = missBranch2
				end

				if next(hitreg2) ~= nil then
					v17.hitreg = hitreg2
				end
			end

			local v18 = v16["end"] or v16.End

			if type(v18) == "table" then
				local v19 = {}
				local offset = tonumber(v18.offset or v18.Offset)

				if type(offset) ~= "number" or offset ~= offset then
					offset = nil
				end

				if type(offset) == "number" then
					v19.offset = offset
				end

				local buffer = tonumber(v18.buffer or v18.EndBuffer)

				if type(buffer) ~= "number" or buffer ~= buffer then
					buffer = nil
				end

				if type(buffer) == "number" then
					v19.buffer = buffer
				end

				if next(v19) ~= nil then
					v17["end"] = v19
				end
			end

			local events = sanitizeRuntimeEvents(v16.events or v16.Events)

			if events then
				v17.events = events
			end

			if next(v17) ~= nil then
				traditional2[slotToken] = v17
			end
		end
	end

	if next(traditional2) ~= nil then
		v13.traditional = traditional2
	end

	local custom2 = {}
	local custom = p.custom or p.Custom

	if type(custom) == "table" then
		for k, v17 in pairs(custom) do
			local slotToken = normalizeSlotToken(k, max)

			if not (slotToken ~= nil and type(v17) == "table") then
				continue
			end

			if type(slotToken) == "number" then
				slotToken = tostring(slotToken)
			end

			local v18 = {}
			local hitreg = v17.hitreg or v17.Hitreg

			if type(hitreg) == "table" then
				local hitreg2 = {}

				for _, v20 in ipairs({
					"Damage",
					"Hitbox",
					"SideHitbox",
					"Offset",
					"Knockback",
					"Stun",
					"KnockbackUp",
					"RagdollTime"
				}) do
					local v21 = tonumber(hitreg[v20])

					if type(v21) ~= "number" or v21 ~= v21 then
						v21 = nil
					end

					if type(v21) ~= "number" then
						continue
					end

					if v20 == "RagdollTime" then
						v21 = math.max(0, v21)
					end

					hitreg2[v20] = v21
				end

				if type(hitreg2.Offset) ~= "number" then
					local rayOffset = tonumber(hitreg.RayOffset)

					if type(rayOffset) ~= "number" or rayOffset ~= rayOffset then
						rayOffset = nil
					end

					if type(rayOffset) == "number" then
						hitreg2.Offset = rayOffset
					end
				end

				local offset = tonumber(hitreg.offset or hitreg.Offset)

				if type(offset) ~= "number" or offset ~= offset then
					offset = nil
				end

				if type(offset) == "number" then
					hitreg2.offset = offset
				end

				if hitreg.AllowRagdoll == true and type(hitreg2.RagdollTime) ~= "number" then
					hitreg2.RagdollTime = 1
				end

				local hitBranch = hitreg.HitBranch
				local hitBranch2

				if type(hitBranch) == "string" then
					hitBranch2 = hitBranch:gsub("^%s+", ""):gsub("%s+$", "")

					if hitBranch2 == "" then
						hitBranch2 = nil
					end
				end

				if hitBranch2 then
					hitreg2.HitBranch = hitBranch2
				end

				local missBranch = hitreg.MissBranch
				local missBranch2

				if type(missBranch) == "string" then
					missBranch2 = missBranch:gsub("^%s+", ""):gsub("%s+$", "")

					if missBranch2 == "" then
						missBranch2 = nil
					end
				end

				if missBranch2 then
					hitreg2.MissBranch = missBranch2
				end

				if next(hitreg2) ~= nil then
					v18.hitreg = hitreg2
				end
			end

			local v19 = v17["end"] or v17.End

			if type(v19) == "table" then
				local v20 = {}
				local offset = tonumber(v19.offset or v19.Offset)

				if type(offset) ~= "number" or offset ~= offset then
					offset = nil
				end

				if type(offset) == "number" then
					v20.offset = offset
				end

				local buffer = tonumber(v19.buffer or v19.EndBuffer)

				if type(buffer) ~= "number" or buffer ~= buffer then
					buffer = nil
				end

				if type(buffer) == "number" then
					v20.buffer = buffer
				end

				if next(v20) ~= nil then
					v18["end"] = v20
				end
			end

			local events = sanitizeRuntimeEvents(v17.events or v17.Events)

			if events then
				v18.events = events
			end

			if next(v18) ~= nil then
				custom2[slotToken] = v18
			end
		end
	end

	if next(custom2) ~= nil then
		v13.custom = custom2
	end

	return v13
end

function CustomM1StyleUtil.sanitizeStyleDefinition(p, value)
	return (sanitizeStyleDefinition(p, value or 8))
end

function CustomM1StyleUtil.decodeStyleMetadata(json, value)
	if type(json) ~= "string" or json == "" or #json > 4096 then
		return nil
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(json)
	end)

	if success then
		return (sanitizeStyleDefinition(result, value or 8))
	end

	return nil
end

function CustomM1StyleUtil.inferStyleDefinitionFromMoveData(list, value, data)
	local v2 = value or 8

	if type(list) ~= "table" then
		return nil
	end

	local v3 = {}

	for _, v4 in ipairs(list) do
		if not (type(v4) == "table" and v4.EventType == "Animation") then
			continue
		end

		local v5 = type(v4.Properties) ~= "table" and {} or v4.Properties or {}
		local animId = sanitizeAnimationId(v5.AnimationId)

		if not animId then
			continue
		end

		local _branch = v5._branch
		local v7

		if type(_branch) == "string" then
			v7 = _branch:gsub("^%s+", ""):gsub("%s+$", "")

			if v7 == "" then
				v7 = nil
			end
		end

		local layer = tonumber(v4.Layer) or 0
		local slotToken = normalizeSlotToken(v5.M1Slot or v5.Slot or v5.EventSlot or v5.Name, v2)

		if slotToken == nil then
			local slotByBranchLower

			if type(data) == "table" then
				slotByBranchLower = data.slotByBranchLower or nil
			end

			if type(slotByBranchLower) == "table" and v7 then
				slotToken = slotByBranchLower[string.lower(v7)]
			end
		end

		if slotToken == nil then
			local slotByLayer

			if type(data) == "table" then
				slotByLayer = data.slotByLayer or nil
			end

			if type(slotByLayer) == "table" then
				slotToken = slotByLayer[layer]
			end
		end

		if slotToken == nil then
			slotToken = normalizeSlotToken(v7, v2)
		end

		local v8 = {
			time = tonumber(v4.Time) or 0,
			layer = layer,
			animId = animId,
			slot = slotToken,
			mode = normalizeSlotMode(v5.M1Mode)
		}
		table.insert(v3, v8)
	end

	if #v3 == 0 then
		return nil
	end

	table.sort(v3, function(a, b)
		if a.time == b.time then
			return a.layer < b.layer
		end

		return a.time < b.time
	end)
	local v4 = 1
	local v5 = {
		hits = {},
		slotModes = {}
	}

	for _, v6 in ipairs(v3) do
		local slot = v6.slot
		local v7 = nil

		if slot == "uppercut" then
			if v5.uppercut == nil then
				v5.uppercut = v6.animId
			end

			v7 = "uppercut"
		elseif slot == "downslam" then
			if v5.downslam == nil then
				v5.downslam = v6.animId
			end

			v7 = "downslam"
		elseif type(slot) == "number" then
			if v5.hits[slot] == nil then
				v5.hits[slot] = v6.animId
			end

			v7 = tostring(slot)
		else
			while v4 <= v2 and v5.hits[v4] ~= nil do
				v4 += 1
			end

			if v4 <= v2 then
				v5.hits[v4] = v6.animId
				v7 = tostring(v4)
				v4 += 1
			elseif v5.uppercut == nil then
				v5.uppercut = v6.animId
				v7 = "uppercut"
			elseif v5.downslam == nil then
				v5.downslam = v6.animId
				v7 = "downslam"
			end
		end

		if not (type(v7) == "string" and v7 ~= "") then
			continue
		end

		local v8

		if type(data) == "table" and type(data.slotModes) == "table" then
			v8 = data.slotModes[v7]
		end

		local slotModes = v5.slotModes
		local mode = v6.mode or v8
		slotModes[v7] = normalizeSlotMode(mode)
	end

	local v6 = sanitizeStyleDefinition(v5, v2)

	if type(v6) == "table" then
		local v7 = enrichCustomSlotsFromTimeline(v6, list, v2, data) or v6
		return sanitizeStyleDefinition(v7, v2) or v7
	end

	return v6
end

function CustomM1StyleUtil.decodeStyleDefinitionFromEncodedMove(p, object, value)
	if typeof(p) ~= "buffer" or (type(object) ~= "table" or type(object.decode) ~= "function") then
		return nil
	end

	local success, result = pcall(function()
		return object:decode(p)
	end)

	if not success or type(result) ~= "table" or type(result[1]) ~= "table" then
		return nil
	end

	local v2 = result[1]
	local metadata = v2.Metadata
	local v3 = value or 8
	local v4, slotModes

	if type(metadata) == "table" then
		v4 = decodeSlotMetadataContext(metadata.M1StyleSlotsV1, v3)

		if v4 then
			slotModes = v4.slotModes or nil
		else
			slotModes = nil
		end

		if type(slotModes) == "table" then
			local count

			if type(slotModes) == "table" then
				count = 0

				for _ in pairs(slotModes) do
					count += 1
				end
			else
				count = 0
			end

			warn(string.format("[CustomM1PersistDiag][Server] stage=decode_slot_modes slots=%d", tonumber(count) or 0))
		end
	else
		v4 = nil
		slotModes = nil
	end

	local function buildInferredFromTimeline()
		local inferStyleDefinitionFromMoveData = CustomM1StyleUtil.inferStyleDefinitionFromMoveData(v2.Data, v3, v4)

		if type(inferStyleDefinitionFromMoveData) ~= "table" then
			return nil
		end

		local v5 = mergeStyleSlotModes(inferStyleDefinitionFromMoveData, slotModes)
		local v6 = enrichCustomSlotsFromTimeline(v5, v2.Data, v3, v4) or v5
		return sanitizeStyleDefinition(v6, v3) or v6
	end

	if type(metadata) ~= "table" then
		return (buildInferredFromTimeline())
	end

	local decodeStyleMetadata = CustomM1StyleUtil.decodeStyleMetadata(metadata.M1StyleData, value)

	if not decodeStyleMetadata then
		warn("[CustomM1PersistDiag][Server] stage=decode_style_metadata_missing_fallback")
		return (buildInferredFromTimeline())
	end

	local v5 = mergeStyleSlotModes(decodeStyleMetadata, slotModes)
	local v6 = enrichCustomSlotsFromTimeline(v5, v2.Data, v3, v4) or v5
	local v7 = sanitizeStyleDefinition(v6, v3) or v6

	if not styleDefinitionLooksIncomplete(v7) then
		return v7
	end

	local inferredFromTimeline = buildInferredFromTimeline()

	if type(inferredFromTimeline) ~= "table" then
		return v7
	end

	local comboLength = tostring(inferredFromTimeline.comboLength)
	local slotModes2 = inferredFromTimeline.slotModes
	local count

	if type(slotModes2) == "table" then
		count = 0

		for _ in pairs(slotModes2) do
			count += 1
		end
	else
		count = 0
	end

	local v9 = tonumber(count) or 0
	local traditional = inferredFromTimeline.traditional
	local count2

	if type(traditional) == "table" then
		count2 = 0

		for _ in pairs(traditional) do
			count2 += 1
		end
	else
		count2 = 0
	end

	local v10 = tonumber(count2) or 0
	local custom = inferredFromTimeline.custom
	local count3

	if type(custom) == "table" then
		count3 = 0

		for _ in pairs(custom) do
			count3 += 1
		end
	else
		count3 = 0
	end

	warn(string.format(
		"[CustomM1PersistDiag][Server] stage=decode_style_recovered_from_timeline comboLength=%s slotModes=%d traditional=%d custom=%d",
		comboLength,
		v9,
		v10,
		tonumber(count3) or 0
	))
	return inferredFromTimeline
end

function CustomM1StyleUtil.resolveStyleDefinitionFromMoveEditor(p, value, p2, p3)
	local v2

	if type(value) == "string" then
		v2 = value:gsub("^%s+", ""):gsub("%s+$", "")

		if v2 == "" then
			v2 = nil
		end
	end

	if not (v2 and (p and p.Parent) and type(p2) == "table") then
		return nil
	end

	local v3 = nil

	if type(p2.getMoveData) == "function" then
		for _ = 1, 8 do
			local success, result = pcall(p2.getMoveData, p.UserId, v2)

			if success and typeof(result) == "buffer" then
				v3 = result
				break
			end

			if not p.Parent then
				break
			end

			task.wait(0.05)
		end
	end

	if v3 == nil and type(p2.getLoadedMoves) == "function" then
		for _ = 1, 8 do
			local success, result = pcall(p2.getLoadedMoves, p)

			if success and type(result) == "table" and typeof(result[v2]) == "buffer" then
				v3 = result[v2]
				break
			end

			if not p.Parent then
				break
			end

			task.wait(0.05)
		end
	end

	if v3 == nil then
		return nil
	end

	local Schemas = require(game.ReplicatedStorage:WaitForChild("Schemas"))
	local moveDataSchema = Schemas and Schemas.moveDataSchema
	return CustomM1StyleUtil.decodeStyleDefinitionFromEncodedMove(v3, moveDataSchema, p3)
end

return CustomM1StyleUtil