local v = {
	ERROR = 1,
	WARN = 2,
	INFO = 3,
	DEBUG = 4,
	TRACE = 5
}
local v2 = {
	enabled = true,
	logLevel = "WARN",
	enabledCategories = {},
	defaultCategoryState = true,
	includeTimestamp = true,
	includeCategory = true,
	includeLevel = true,
	outputToConsole = true,
	customOutputFunction = nil
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isCategoryEnabled(p)
	if v2.enabledCategories[p] == nil then
		return v2.defaultCategoryState
	end

	return v2.enabledCategories[p]
end

local function shouldLog(p, p2)
	if not v2.enabled then
		return false
	end

	-- equivalent call inferred; original call site unknown
	if isCategoryEnabled(p) then
		return (v[v2.logLevel] or 3) >= (v[p2] or 3)
	end

	return false
end

local function formatMessage(p, p2, formatString, ...)
	local v3 = {}

	if v2.includeTimestamp then
		table.insert(v3, string.format("[%s]", os.date("%Y-%m-%d %H:%M:%S")))
	end

	if v2.includeLevel then
		table.insert(v3, string.format("[%s]", p))
	end

	if v2.includeCategory then
		table.insert(v3, string.format("[%s]", p2))
	end

	table.insert(v3, string.format(formatString, ...))
	return table.concat(v3, " ")
end

local function outputMessage(p, p2, p3)
	if v2.customOutputFunction then
		v2.customOutputFunction(p, p2, p3)
	elseif v2.outputToConsole then
		if p2 == "ERROR" or p2 == "WARN" then
			warn(p)
		else
			print(p)
		end
	end
end

local Logger = {}
Logger.LogLevels = {
	ERROR = "ERROR",
	WARN = "WARN",
	INFO = "INFO",
	DEBUG = "DEBUG",
	TRACE = "TRACE"
}

function Logger.error(p, p2, ...)
	local v3

	if v2.enabled then
		-- equivalent call inferred; original call site unknown
		if isCategoryEnabled(p) then
			v3 = (v[v2.logLevel] or v.INFO) >= (v.ERROR or v.INFO)
		else
			v3 = false
		end
	else
		v3 = false
	end

	if v3 then
		local v4 = formatMessage("ERROR", p, p2, ...)

		if v2.customOutputFunction then
			v2.customOutputFunction(v4, "ERROR", p)
		elseif v2.outputToConsole then
			warn(v4)
		end
	end
end

function Logger.warn(p, p2, ...)
	local v3

	if v2.enabled then
		-- equivalent call inferred; original call site unknown
		if isCategoryEnabled(p) then
			v3 = (v[v2.logLevel] or v.INFO) >= (v.WARN or v.INFO)
		else
			v3 = false
		end
	else
		v3 = false
	end

	if v3 then
		local v4 = formatMessage("WARN", p, p2, ...)

		if v2.customOutputFunction then
			v2.customOutputFunction(v4, "WARN", p)
		elseif v2.outputToConsole then
			warn(v4)
		end
	end
end

function Logger.info(p, p2, ...)
	local v3

	if v2.enabled then
		-- equivalent call inferred; original call site unknown
		if isCategoryEnabled(p) then
			v3 = (v[v2.logLevel] or v.INFO) >= (v.INFO or v.INFO)
		else
			v3 = false
		end
	else
		v3 = false
	end

	if v3 then
		local v4 = formatMessage("INFO", p, p2, ...)

		if v2.customOutputFunction then
			v2.customOutputFunction(v4, "INFO", p)
		elseif v2.outputToConsole then
			print(v4)
		end
	end
end

function Logger.debug(p, p2, ...)
	local v3

	if v2.enabled then
		-- equivalent call inferred; original call site unknown
		if isCategoryEnabled(p) then
			v3 = (v[v2.logLevel] or v.INFO) >= (v.DEBUG or v.INFO)
		else
			v3 = false
		end
	else
		v3 = false
	end

	if v3 then
		local v4 = formatMessage("DEBUG", p, p2, ...)

		if v2.customOutputFunction then
			v2.customOutputFunction(v4, "DEBUG", p)
		elseif v2.outputToConsole then
			print(v4)
		end
	end
end

function Logger.trace(p, p2, ...)
	local v3

	if v2.enabled then
		-- equivalent call inferred; original call site unknown
		if isCategoryEnabled(p) then
			v3 = (v[v2.logLevel] or v.INFO) >= (v.TRACE or v.INFO)
		else
			v3 = false
		end
	else
		v3 = false
	end

	if v3 then
		local v4 = formatMessage("TRACE", p, p2, ...)

		if v2.customOutputFunction then
			v2.customOutputFunction(v4, "TRACE", p)
		elseif v2.outputToConsole then
			print(v4)
		end
	end
end

function Logger.setConfig(data)
	if data.enabled ~= nil then
		v2.enabled = data.enabled
	end

	if data.logLevel ~= nil then
		if v[data.logLevel] then
			v2.logLevel = data.logLevel
		else
			warn("Logger: Invalid log level:", data.logLevel)
		end
	end

	if data.defaultCategoryState ~= nil then
		v2.defaultCategoryState = data.defaultCategoryState
	end

	if data.enabledCategories then
		for k, enabledCategory in pairs(data.enabledCategories) do
			v2.enabledCategories[k] = enabledCategory
		end
	end

	if data.outputToConsole ~= nil then
		v2.outputToConsole = data.outputToConsole
	end

	if data.customOutputFunction ~= nil then
		v2.customOutputFunction = data.customOutputFunction
	end
end

return Logger