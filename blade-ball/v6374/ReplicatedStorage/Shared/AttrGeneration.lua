local v = {}

local function contextKey(items)
	if items == nil then
		return ""
	end

	if type(items) ~= "table" then
		return (tostring(items))
	end

	local v2 = {}

	for k, item in items do
		table.insert(v2, (`{k}={tostring(item)}`))
	end

	return table.concat(v2, "&")
end

local function keyToContext(value: string)
	if value == "" then
		return nil
	end

	local result = {}

	for _, v2 in string.split(value, "&") do
		local v3, v4 = string.match(v2, "(.-)=(.+)")
		result[v3] = v4
	end

	return result
end

return {
	scope = function(p: string)
		local v2 = v[p]

		if v2 then
			return v2
		end

		local formatted = `_generation_{p}`
		local formatted2 = `_generationCtx_{p}`

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bump(instance, p2: string)
			local v3 = (instance:GetAttribute(formatted) or 0) + 1
			instance:SetAttribute(formatted, v3)
			instance:SetAttribute(formatted2, p2)
			return v3
		end

		local v3 = {
			get = function(instance)
				return instance:GetAttribute(formatted) or 0
			end,
			begin = function(instance, p2)
				local v4 = contextKey(p2)

				if v4 ~= "" and instance:GetAttribute(formatted2) == v4 then
					return nil
				end

				return bump(instance, v4)
			end,
			beginForced = function(instance, p2)
				return bump(instance, contextKey(p2))
			end,
			isCurrent = function(instance, p2: number)
				return instance.Parent ~= nil and (instance:GetAttribute(formatted) or 0) == p2
			end,
			cancel = function(instance)
				bump(instance, "") -- equivalent call inferred; original call site unknown
			end
		}
		v[p] = v3
		return v3
	end
}