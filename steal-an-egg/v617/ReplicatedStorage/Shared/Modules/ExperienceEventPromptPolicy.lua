local v = {
	Id = "string",
	HasStarted = "boolean",
	HasEnded = "boolean"
}

local function coerce(p)
	local result = {}

	for k, v2 in v do
		local v3

		if type(p) == "table" then
			v3 = p[k]
		end

		if type(v3) ~= v2 then
			return nil
		end

		result[k] = v3
	end

	return result
end

local function isUsableId(value)
	return type(value) == "string" and #value > 0 and #value <= 128
end

local function countKeys(items)
	local count = 0

	for _ in items do
		count += 1
	end

	return count
end

return table.freeze({
	PromptDelaySeconds = 300,
	RetryDelaySeconds = 30,
	MaxAttempts = 5,
	IsValidEventId = isUsableId,
	IsSafeToPrompt = function(flag: boolean, flag2: boolean)
		return flag and not flag2
	end,
	IsReturningPlayer = function(p: number, p2: number, p3: number)
		local v3

		if p > 1 and p2 >= 0 then
			v3 = p2 <= p3
		else
			v3 = false
		end

		if v3 then
			local v4 = p3 // 86400
			return p2 // 86400 < v4
		end

		return v3
	end,
	GetSoonestUnseenEvent = function(p, p2)
		for _, v3 in type(p) ~= "table" and {} or p do
			local v4 = coerce(v3)
			local v5

			if v4 == nil then
				v5 = false
			else
				v5 = not (v4.HasStarted or v4.HasEnded)
			end

			if v5 and not p2[v4.Id] then
				return v4
			end
		end

		return nil
	end,
	TryMarkSeen = function(self, value, p: number)
		local v3

		if type(value) == "string" and #value > 0 then
			v3 = #value <= 128
		else
			v3 = false
		end

		if not v3 then
			return false
		end

		assert(type(value) == "string")
		local v4 = self[value] == true

		if not v4 then
			local count = 0

			for _ in self do
				count += 1
			end

			if count < p then
				v4 = true
			else
				v4 = false
			end
		end

		self[value] = v4 and true or self[value]
		return v4
	end
})