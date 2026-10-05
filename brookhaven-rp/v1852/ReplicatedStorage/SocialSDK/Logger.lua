local Logger = {}
Logger.__index = Logger
local RunService = game:GetService("RunService")
local LoggerShared = require(script.Parent.LoggerShared)
Logger.LogLevels = {
	ERROR = "ERROR",
	WARN = "WARN",
	INFO = "INFO",
	DEBUG = "DEBUG",
	TRACE = "TRACE"
}
local LoggerServer = nil
local LoggerClient = nil

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	LoggerServer = require(ServerScriptService.SocialSDK.LoggerServer)
	LoggerServer.initialize()
else
	local starterPlayerScripts = game.StarterPlayer.StarterPlayerScripts
	LoggerClient = require(starterPlayerScripts.SocialSDK.LoggerClient)
end

local function outputMessage(p, p2, p3)
	if LoggerServer then
		LoggerServer.outputMessage(p, p2, p3)
	elseif LoggerClient then
		LoggerClient.outputMessage(p, p2, p3)
	end
end

function Logger.error(p, p2, ...)
	if LoggerShared.shouldLog(p, "ERROR") then
		local formatMessage = LoggerShared.formatMessage("ERROR", p, p2, ...)

		if LoggerServer then
			LoggerServer.outputMessage(formatMessage, "ERROR", p)
		elseif LoggerClient then
			LoggerClient.outputMessage(formatMessage, "ERROR", p)
		end
	end
end

function Logger.warn(p, p2, ...)
	if LoggerShared.shouldLog(p, "WARN") then
		local formatMessage = LoggerShared.formatMessage("WARN", p, p2, ...)

		if LoggerServer then
			LoggerServer.outputMessage(formatMessage, "WARN", p)
		elseif LoggerClient then
			LoggerClient.outputMessage(formatMessage, "WARN", p)
		end
	end
end

function Logger.info(p, p2, ...)
	if LoggerShared.shouldLog(p, "INFO") then
		local formatMessage = LoggerShared.formatMessage("INFO", p, p2, ...)

		if LoggerServer then
			LoggerServer.outputMessage(formatMessage, "INFO", p)
		elseif LoggerClient then
			LoggerClient.outputMessage(formatMessage, "INFO", p)
		end
	end
end

function Logger.debug(p, p2, ...)
	if LoggerShared.shouldLog(p, "DEBUG") then
		local formatMessage = LoggerShared.formatMessage("DEBUG", p, p2, ...)

		if LoggerServer then
			LoggerServer.outputMessage(formatMessage, "DEBUG", p)
		elseif LoggerClient then
			LoggerClient.outputMessage(formatMessage, "DEBUG", p)
		end
	end
end

function Logger.trace(p, p2, ...)
	if LoggerShared.shouldLog(p, "TRACE") then
		local formatMessage = LoggerShared.formatMessage("TRACE", p, p2, ...)

		if LoggerServer then
			LoggerServer.outputMessage(formatMessage, "TRACE", p)
		elseif LoggerClient then
			LoggerClient.outputMessage(formatMessage, "TRACE", p)
		end
	end
end

function Logger.setConfig(data)
	if data.enabled ~= nil then
		LoggerShared.setEnabled(data.enabled)
	end

	if data.logLevel ~= nil then
		LoggerShared.setLogLevel(data.logLevel)
	end

	if data.defaultCategoryState ~= nil then
		LoggerShared.setDefaultCategoryState(data.defaultCategoryState)
	end

	if data.enabledCategories then
		for k, enabledCategory in pairs(data.enabledCategories) do
			LoggerShared.setCategoryState(k, enabledCategory)
		end
	end

	if data.outputToConsole ~= nil then
		LoggerShared.setOutputToConsole(data.outputToConsole)
	end

	if data.customOutputFunction ~= nil then
		LoggerShared.setCustomOutput(data.customOutputFunction)
	end

	if data.notifyClientOnServerWarnings ~= nil or data.notifyClientOnServerErrors ~= nil then
		LoggerShared.setOwnerNotificationEnabled(data.notifyClientOnServerWarnings, data.notifyClientOnServerErrors)
	end

	if data.logNotificationCooldown ~= nil then
		LoggerShared.setLogNotificationCooldown(data.logNotificationCooldown)
	end

	if data.customNotificationUserId ~= nil then
		LoggerShared.setCustomNotificationUserId(data.customNotificationUserId)
	end
end

return Logger