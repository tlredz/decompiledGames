local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.SocialSDK.Utils)
local Logger = require(ReplicatedStorage.SocialSDK:WaitForChild("Logger"))
local v = nil
local v2 = false

function waitForRemoteEvents()
	local socialSDK = ReplicatedStorage:WaitForChild("SocialSDK", 10)

	if not socialSDK then
		Logger.error("INIT", "SocialSDKClient: Remote events not found")
		return false
	end

	v = {
		updateActivity = socialSDK:WaitForChild("UpdateActivity", 5),
		updateDevice = socialSDK:WaitForChild("UpdateDevice", 5)
	}

	if not v.updateActivity then
		Logger.error("INIT", "SocialSDKClient: updateActivity event not found")
		return false
	end

	if v.updateDevice then
		return true
	end

	Logger.error("INIT", "SocialSDKClient: updateDevice event not found")
	return false
end

function init()
	if not waitForRemoteEvents() then
		Logger.error("INIT", "SocialSDKClient: Failed to initialize")
		return
	end

	v.updateDevice:FireServer(getDevice())
	Logger.info("INIT", "SocialSDKClient: Ready")
	v2 = true
end

function updateActivity(p)
	if v and v.updateActivity then
		v.updateActivity:FireServer(p)
		return true
	end

	Logger.warn("NETWORK", "SocialSDKClient: Remote events not available")
	return false
end

function getDevice()
	local UserInputService = game:GetService("UserInputService")
	local GuiService = game:GetService("GuiService")

	if GuiService:IsTenFootInterface() then
		return "console"
	end

	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		return "mobile"
	end

	return "desktop"
end

init()
local SocialSDK = {}

function SocialSDK.isReady()
	return v2
end

function SocialSDK.setActivity(details, state, assets, p4, party, secret)
	local gameActivity = Utils.createGameActivity({
		details = details,
		state = state,
		assets = assets,
		type = p4,
		party = party,
		secret = secret
	})
	return updateActivity(gameActivity)
end

return SocialSDK