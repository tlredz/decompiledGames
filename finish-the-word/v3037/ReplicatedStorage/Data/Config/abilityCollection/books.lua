local function childLetter(p)
	return (p.n or {})[1]
end

local function configLanguageIdToBankLanguageId(p)
	return p + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeLanguages(value)
	if value == nil then
		return {}
	end

	if type(value) == "number" then
		return { value }
	end

	return value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function countForLanguage(p, p2)
	if type(p) == "table" then
		return p[p2] or 0
	end

	return 0
end

local function wordExistsInLanguage(p, p2)
	if p["$"] ~= 1 then
		return false
	end

	for _, v in ipairs(normalizeLanguages(p.l)) do
		if v + 1 == p2 then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function density(p, p2, p3, p4)
	local c = p.c
	return (math.max(countForLanguage(c, p3) + (wordExistsInLanguage(p, p3) and 1 or 0) - (p4[p2] or 0), 0))
end

local function childHasWordsInLanguage(p, p2, p3, p4)
	local c = p.c
	return math.max(countForLanguage(c, p3) + (wordExistsInLanguage(p, p3) and 1 or 0) - (p4[p2] or 0), 0) > 0
end

local function weightedChoice(list)
	local total = 0

	for _, v in ipairs(list) do
		total += v.Weight
	end

	if total <= 0 then
		return
	end

	local v = math.random() * total
	local total2 = 0

	for _, v2 in ipairs(list) do
		total2 += v2.Weight

		if v <= total2 then
			return v2
		end
	end

	return list[#list]
end

local function pickWeightedNode(nodes, path, p, p2)
	local v = {}

	for _, node in ipairs(nodes) do
		local weight = density(node, path, p, p2) -- equivalent call inferred; original call site unknown

		if weight > 0 then
			table.insert(v, {
				Node = node,
				Weight = weight
			})
		end
	end

	local v2 = weightedChoice(v)
	return v2 and v2.Node
end

local hasDepth

hasDepth = function(p, p2, p3, p4, p5)
	if p5 <= 0 then
		local c = p.c
		return math.max(countForLanguage(c, p3) + (wordExistsInLanguage(p, p3) and 1 or 0) - (p4[p2] or 0), 0) > 0
	end

	local n = p.n or {}

	for i = 2, #n do
		local v = n[i]
		local v2 = p2 .. (v.n or {})[1]
		local c = v.c

		if math.max(countForLanguage(c, p3) + (wordExistsInLanguage(v, p3) and 1 or 0) - (p4[v2] or 0), 0) > 0 and hasDepth(
			v,
			v2,
			p3,
			p4,
			p5 - 1
		) then
			return true
		end
	end

	return false
end

local function pickWeightedChild(node, path, p, p2, p3)
	local n = node.n or {}
	local v = {}

	for i = 2, #n do
		local node2 = n[i]
		local letter = (node2.n or {})[1]
		local path2 = path .. letter
		local c = node2.c

		if not (math.max(countForLanguage(c, p) + (wordExistsInLanguage(node2, p) and 1 or 0) - (p2[path2] or 0), 0) > 0) then
			continue
		end

		if not hasDepth(node2, path2, p, p2, p3) then
			continue
		end

		local v5 = {
			Node = node2,
			Path = path2,
			Letter = letter,
			Weight = density(node2, path2, p, p2)
		}
		table.insert(v, v5)
	end

	return weightedChoice(v)
end

local function buildWeightedHint(object, path, playerLanguageId, usedPrefixCounts, p)
	local nodes = object:getNodes(path)

	if not nodes then
		return
	end

	local node = pickWeightedNode(nodes, path, playerLanguageId, usedPrefixCounts)

	if not (node and hasDepth(node, path, playerLanguageId, usedPrefixCounts, p)) then
		return
	end

	local letters = {}

	for i = 1, p do
		local v = pickWeightedChild(node, path, playerLanguageId, usedPrefixCounts, p - i)

		if not v then
			return
		end

		table.insert(letters, v.Letter)
		node = v.Node
		path = v.Path
	end

	return table.concat(letters)
end

local function buildHint(object)
	local currentPrefix = object.CurrentPrefix or ""

	if currentPrefix == "" then
		return
	end

	local playerLanguageId = object:getPlayerLanguageId((game.Players:GetPlayerByUserId((tonumber(object:getPlayer(object.TurnPlayer))))))
	local import = _G.import("bank")
	local usedPrefixCounts = object.UsedPrefixCounts or {}
	local weightedHint = buildWeightedHint(import, currentPrefix, playerLanguageId, usedPrefixCounts, 3)

	if weightedHint then
		return weightedHint
	end

	local weightedHint2 = buildWeightedHint(import, currentPrefix, playerLanguageId, usedPrefixCounts, 2)

	if weightedHint2 then
		return weightedHint2
	end

	local weightedHint3 = buildWeightedHint(import, currentPrefix, playerLanguageId, usedPrefixCounts, 1)

	if weightedHint3 then
		return weightedHint3
	end
end

return {
	Hint = {
		Info = {
			DisplayName = "Hint",
			Description = "Reveal a hint",
			PetDescription = "Every 10 rounds, reveal a hint",
			RotationCooldown = 10,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function()
						return true
					end
				}
			}
		end,
		Execute = function(_, object, _)
			local hint = buildHint(object)

			if not hint then
				return
			end

			object:note("<font size=\"5\">hint:</font> " .. (object.CurrentPrefix or "") .. hint)
		end
	}
}