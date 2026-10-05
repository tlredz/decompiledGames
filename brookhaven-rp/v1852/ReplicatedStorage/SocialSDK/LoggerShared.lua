local LoggerShared = {}
local v = {
	enabled = true,
	logLevel = "WARN",
	enabledCategories = {},
	defaultCategoryState = true,
	includeTimestamp = true,
	includeCategory = true,
	includeLevel = true,
	outputToConsole = true,
	customOutputFunction = nil,
	notifyClientOnServerWarnings = false,
	notifyClientOnServerErrors = false,
	logNotificationCooldown = 0.2,
	maxOwnerNotificationQueue = 10,
	customNotificationUserId = nil
}
local v2 = {
	ERROR = 1,
	WARN = 2,
	INFO = 3,
	DEBUG = 4,
	TRACE = 5
}

function LoggerShared.isCategoryEnabled(p)
	if v.enabledCategories[p] == nil then
		return v.defaultCategoryState
	end

	return v.enabledCategories[p]
end

function LoggerShared.shouldLog(p, p2)
	if not v.enabled then
		return false
	end

	if LoggerShared.isCategoryEnabled(p) then
		return (v2[v.logLevel] or v2.INFO) >= (v2[p2] or v2.INFO)
	end

	return false
end

function LoggerShared.formatMessage(p, p2, formatString, ...)
	local v3 = {}

	if v.includeTimestamp then
		table.insert(v3, string.format("[%s]", os.date("%Y-%m-%d %H:%M:%S")))
	end

	if v.includeLevel then
		table.insert(v3, string.format("[%s]", p))
	end

	if v.includeCategory then
		table.insert(v3, string.format("[%s]", p2))
	end

	table.insert(v3, (string.format(formatString, ...)))
	return table.concat(v3, " ")
end

function LoggerShared.getConfig()
	return v
end

function LoggerShared.getLogLevels()
	return v2
end

function LoggerShared.setEnabled(enabled)
	v.enabled = enabled
end

function LoggerShared.setLogLevel(logLevel)
	if v2[logLevel] then
		v.logLevel = logLevel
	else
		warn("Logger: Invalid log level:", logLevel)
	end
end

function LoggerShared.setCustomOutput(customOutputFunction)
	v.customOutputFunction = customOutputFunction
end

function LoggerShared.setOutputToConsole(outputToConsole)
	v.outputToConsole = outputToConsole
end

function LoggerShared.setTimestampEnabled(includeTimestamp)
	v.includeTimestamp = includeTimestamp
end

function LoggerShared.setCategoryEnabled(includeCategory)
	v.includeCategory = includeCategory
end

function LoggerShared.setLevelEnabled(includeLevel)
	v.includeLevel = includeLevel
end

function LoggerShared.setOwnerNotificationEnabled(notifyClientOnServerWarnings, notifyClientOnServerErrors)
	if notifyClientOnServerWarnings ~= nil then
		v.notifyClientOnServerWarnings = notifyClientOnServerWarnings
	end

	if notifyClientOnServerErrors ~= nil then
		v.notifyClientOnServerErrors = notifyClientOnServerErrors
	end
end

function LoggerShared.setLogNotificationCooldown(logNotificationCooldown)
	if logNotificationCooldown and logNotificationCooldown > 0 then
		v.logNotificationCooldown = logNotificationCooldown
	end
end

function LoggerShared.setCustomNotificationUserId(customNotificationUserId)
	if customNotificationUserId and type(customNotificationUserId) == "number" and customNotificationUserId > 0 then
		v.customNotificationUserId = customNotificationUserId
	elseif customNotificationUserId == nil then
		v.customNotificationUserId = nil
	else
		warn("Logger: Invalid user ID provided:", customNotificationUserId)
	end
end

function LoggerShared.enableCategory(p)
	v.enabledCategories[p] = true
end

function LoggerShared.disableCategory(p)
	v.enabledCategories[p] = false
end

function LoggerShared.setCategoryState(p, p2)
	v.enabledCategories[p] = p2
end

function LoggerShared.setDefaultCategoryState(defaultCategoryState)
	v.defaultCategoryState = defaultCategoryState
end

return LoggerShared