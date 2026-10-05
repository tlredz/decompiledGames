local ReplicatedStorage = game:GetService("ReplicatedStorage")
local discord = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Discord")
local RemoteEvents = require(discord:WaitForChild("RemoteEvents"))
local Logger = require(discord:WaitForChild("Logger"))
local Utils = require(discord:WaitForChild("Utils"))
local v = nil
local v2 = false
local v3 = false

local function getDevice()
	local UserInputService = game:GetService("UserInputService")

	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		return "mobile"
	end

	return "desktop"
end

local function init()
	v = {
		updateDevice = RemoteEvents.waitFor("UpdateDevice")
	}
	local updateDevice = v.updateDevice
	local UserInputService = game:GetService("UserInputService")
	updateDevice:FireServer(UserInputService.TouchEnabled and not UserInputService.MouseEnabled and "mobile" or "desktop")
	Logger.info("INIT", "SocialSDKClient: Ready")
	v2 = true
end

local function updateActivity(p)
	if not v3 then
		v.updateActivity = RemoteEvents.tryGet("UpdateActivity", 2)
		v3 = true
	end

	if v.updateActivity then
		v.updateActivity:FireServer(p)
		return true
	end

	Logger.error("NETWORK", "SocialSDKClient: updateActivity remote event not available")
	return false
end

local DiscordClient = {}

function DiscordClient.isReady()
	return v2
end

function DiscordClient.setActivity(details, ...)
	if type(details) ~= "table" then
		local state, assets, v6, party, secret = ...
		details = {
			details = details,
			state = state,
			assets = assets,
			type = v6,
			party = party,
			secret = secret
		}
	end

	local gameActivity = Utils.createGameActivity(details)

	if not v3 then
		v.updateActivity = RemoteEvents.tryGet("UpdateActivity", 2)
		v3 = true
	end

	if v.updateActivity then
		v.updateActivity:FireServer(gameActivity)
		return true
	end

	Logger.error("NETWORK", "SocialSDKClient: updateActivity remote event not available")
	return false
end

return DiscordClient