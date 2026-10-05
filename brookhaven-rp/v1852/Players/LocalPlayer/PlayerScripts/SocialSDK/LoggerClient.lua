local LoggerClient = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoggerShared = require(ReplicatedStorage.SocialSDK.LoggerShared)
local StarterGui = game:GetService("StarterGui")
local loggerOwnerNotification = ReplicatedStorage.SocialSDK:WaitForChild("LoggerOwnerNotification", 5)

function LoggerClient.outputMessage(p, p2, p3)
	local config = LoggerShared.getConfig()

	if config.customOutputFunction then
		config.customOutputFunction(p, p2, p3)
	elseif config.outputToConsole then
		if p2 == "ERROR" or p2 == "WARN" then
			warn(p)
		else
			print(p)
		end
	end
end

function LoggerClient.displayNotification(data)
	local level = data.level
	local message = data.message
	local _ = data.timestamp
	local v = string.format("[%s] %s", level, message)
	StarterGui:SetCore("SendNotification", {
		Title = "Debug",
		Text = message,
		Duration = 10,
		Type = level == "ERROR" and "Error" or "Warning"
	})

	if level == "ERROR" then
		warn(v)
	else
		print(v)
	end
end

if loggerOwnerNotification == nil then
	warn("LoggerClient: Owner notification remote not found")
	return LoggerClient
end

loggerOwnerNotification.OnClientEvent:Connect(function(p)
	LoggerClient.displayNotification(p)
end)
return LoggerClient