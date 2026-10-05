-- equivalent calls inferred from this helper; original call sites unknown
local function trim(value)
	return (value:match("^%s*(.-)%s*$"))
end

local function validateChoices(value, p)
	local v = string.split(value, ",")
	local v2 = {}

	if #v > 4 then
		return false, "Use at most 4 choices."
	end

	for k, v3 in v do
		local v4 = trim(v3) -- equivalent call inferred; original call site unknown

		if v4 == "" then
			if p or k ~= #v then
				return false, "Choices cannot be empty."
			end
		else
			if #v4 > 40 or v4:find("[%c]") then
				return false, "Each choice must be 1-40 bytes."
			end

			if v2[v4:lower()] then
				return false, "Each choice must be different."
			else
				v2[v4:lower()] = true
			end
		end
	end

	if p and #v < 2 then
		return false, "Add a comma and a second choice (2-4 total)."
	end

	return true
end

return function(registry)
	registry:RegisterType("pollQuestion", {
		Validate = function(value)
			return
				#value:match("^%s*(.-)%s*$") > 0 and #value <= 160,
				"Enter a question (up to 160 bytes). Put multiword questions in double quotes."
		end,
		Parse = function(value)
			return (value:match("^%s*(.-)%s*$"))
		end
	})
	registry:RegisterType("pollChoices", {
		Validate = function(p)
			return validateChoices(p, false)
		end,
		ValidateOnce = function(p)
			return validateChoices(p, true)
		end,
		Parse = function(p)
			return p
		end
	})
	registry:RegisterType("pollTime", {
		Validate = function(p)
			local v = tonumber(p)
			return
				v ~= nil and v == math.floor(v) and v >= 1 and v <= 300,
				"Use whole seconds from 1 to 300. Omit this argument for 15 seconds."
		end,
		Parse = tonumber
	})
end