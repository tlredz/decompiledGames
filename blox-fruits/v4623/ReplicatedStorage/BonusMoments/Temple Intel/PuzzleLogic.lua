local PuzzleLogic = {
	LinkKey = function(p: string, p2: string)
		if p < p2 then
			return p .. "|" .. p2
		end

		return p2 .. "|" .. p
	end,
	SplitKey = function(value: string)
		local v, v2 = string.match(value, "^(.-)|(.*)$")
		return v, v2
	end,
	NormalizeState = function(value)
		if type(value) == "string" then
			return {
				Targets = { value }
			}
		end

		if value.Target then
			return {
				Targets = { value.Target },
				Angle = value.Angle
			}
		end

		return {
			Targets = value.Targets or {},
			Angle = value.Angle
		}
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function targetsOf(p, p2, p3)
	local coil = p.Coils[p2]

	if not coil then
		return nil
	end

	local state = coil.States[p3[p2] or coil.Start or 1]

	if state then
		return PuzzleLogic.NormalizeState(state).Targets
	end

	return nil
end

local function listHas(list, p)
	for _, v in ipairs(list) do
		if v == p then
			return true
		end
	end

	return false
end

function PuzzleLogic.GetActiveLinks(p, p2)
	local result = {}

	for k in pairs(p.Coils) do
		local v = targetsOf(p, k, p2) -- equivalent call inferred; original call site unknown

		if not v then
			continue
		end

		for _, v2 in ipairs(v) do
			if not (v2 ~= k and p.Coils[v2]) then
				continue
			end

			local flag

			if p.RequireMutual then
				local v3 = targetsOf(p, v2, p2) -- equivalent call inferred; original call site unknown

				if v3 == nil then
					flag = false
				else
					local flag2 = true

					for _, v4 in ipairs(v3) do
						if v4 ~= k then
							continue
						end

						flag = true
						flag2 = false
						break
					end

					if flag2 then
						flag = false
					end
				end
			else
				flag = true
			end

			if flag then
				result[PuzzleLogic.LinkKey(k, v2)] = true
			end
		end
	end

	return result
end

function PuzzleLogic.GetPossibleLinks(p)
	local result = {}

	for k, coil in pairs(p.Coils) do
		for _, state in ipairs(coil.States) do
			for _, target in ipairs(PuzzleLogic.NormalizeState(state).Targets) do
				if target ~= k and p.Coils[target] then
					result[PuzzleLogic.LinkKey(k, target)] = true
				end
			end
		end
	end

	return result
end

function PuzzleLogic.GetRequiredLinks(p)
	local result = {}

	for _, v in ipairs(p.RequiredLinks or {}) do
		result[PuzzleLogic.LinkKey(v[1], v[2])] = true
	end

	return result
end

local function allConnected(p, items)
	local v = {}
	local v2 = {}

	for k in pairs(p.Coils) do
		v[k] = {}
		table.insert(v2, k)
	end

	if #v2 == 0 then
		return false
	end

	for k in pairs(items) do
		local splitKey, v3 = PuzzleLogic.SplitKey(k)

		if not (v[splitKey] and v[v3]) then
			continue
		end

		table.insert(v[splitKey], v3)
		table.insert(v[v3], splitKey)
	end

	local v3 = {
		[v2[1]] = true
	}
	local v4 = { v2[1] }
	local v5 = 1

	while #v4 > 0 do
		local v6 = table.remove(v4)

		for _, v7 in ipairs(v[v6]) do
			if v3[v7] then
				continue
			end

			v3[v7] = true
			v5 += 1
			table.insert(v4, v7)
		end
	end

	return v5 == #v2
end

function PuzzleLogic.IsSolved(p, p2, p3)
	local v = p3 or PuzzleLogic.GetActiveLinks(p, p2)
	local winMode = p.WinMode or "ExactSet"

	if winMode == "AllConnected" then
		return allConnected(p, v), "connectivity"
	end

	local requiredLinks = PuzzleLogic.GetRequiredLinks(p)

	for k in pairs(requiredLinks) do
		if not v[k] then
			return false, "missing " .. k
		end
	end

	if winMode == "ExactSet" then
		for k in pairs(v) do
			if not requiredLinks[k] then
				return false, "extra " .. k
			end
		end
	end

	return true, "solved"
end

return PuzzleLogic