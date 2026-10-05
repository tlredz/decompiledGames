local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local MessagingServiceManager = require(ReplicatedStorage._FRAMEWORK.Features.MessagingServiceManager)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = nil

local function checkRequestReady(p)
	if not RunService:IsServer() then
		return false, nil, "Admin teleport requests are server-only"
	end

	if not v then
		return false, nil, "Admin teleport messaging is not ready"
	end

	if RunService:IsStudio() or game.JobId == "" then
		return false, nil, "Cross-server teleportation requires a published Roblox server"
	end

	if game.PrivateServerId == "" or game.PrivateServerOwnerId ~= 0 then
		return true, nil, ""
	end

	local DataManager = require(ServerScriptService.DataManager)
	local profile = DataManager.Profiles[p]
	local VIP_ID = profile and profile.Data.VIP_ID

	if VIP_ID and VIP_ID.privateServerId == game.PrivateServerId and VIP_ID.code ~= "" then
		return true, VIP_ID.code, ""
	end

	return false, nil, "Your reserved server access code is not available yet"
end

local function teleportTarget(data)
	local playerByUserId = Players:GetPlayerByUserId(data.targetUserId)

	if not playerByUserId or data.placeId == game.PlaceId and data.jobId == game.JobId then
		return
	end

	local success, result = pcall(function()
		if data.reservedAccessCode then
			local Teleport = require(ServerScriptService.VIPServer.Teleport)
			local v2, v3 = Teleport:TeleportInPrivateServer({ playerByUserId }, data.reservedAccessCode, data.placeId):await()

			if not v2 then
				error(v3)
			end
		else
			TeleportService:TeleportToPlaceInstance(data.placeId, data.jobId, playerByUserId)
		end
	end)

	if not success then
		logger.warn(
			logger,
			string.format(
				"Failed to teleport player %d to the administrator's server: %s",
				data.targetUserId,
				(tostring(result))
			)
		)
	end
end

local AdminTeleport = {
	requestToServer = function(p, targetUserId: number)
		local v2, reservedAccessCode, v4 = checkRequestReady(p)

		if not v2 then
			return false, v4
		end

		local v5, v6 = v.send({
			targetUserId = targetUserId,
			placeId = game.PlaceId,
			jobId = game.JobId,
			reservedAccessCode = reservedAccessCode
		}):await()

		if v5 then
			return v5, "Teleport request sent to the player's server"
		end

		return v5, (string.format("Cross-server teleport request failed: %s", (tostring(v6))))
	end
}
FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() then
			return
		end

		local messageHandler = MessagingServiceManager.createMessageHandler("AdminTpToMe")
		v = messageHandler
		local connection = messageHandler.connect(teleportTarget)
		game:BindToClose(function()
			connection:Disconnect()
		end)
	end
})
return AdminTeleport