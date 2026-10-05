local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
require(ReplicatedStorage.Utilities.Promise)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local WebhookLogger

if RunService:IsServer() then
	WebhookLogger = require(ServerScriptService.WebhookLogger)
else
	WebhookLogger = nil
end

local AdminRemote = {
	remotes = remo.createRemotes({
		SendInfo = remo.remote(),
		RequestInfo = remo.remote(t.string, t.optional(t.any)).returns()
	})
}
local v = {}
local v2 = {}
local flag = false

local function setup()
	if flag then
		return
	end

	flag = true

	if RunService:IsClient() then
		AdminRemote.remotes.SendInfo:connect(function(p, p2)
			local v3 = v2[p]

			if v3 then
				v3(Players.LocalPlayer, p2)
			end
		end)
	else
		AdminRemote.remotes.RequestInfo:onRequest(function(p, p2, p3)
			local v3 = v[p2]

			if v3 then
				return (v3(p, p3))
			end

			return nil
		end)
	end
end

local function playerHasPermission(p, p2: string)
	return AdminPermissions.hasPermission(p.UserId, p2)
end

function AdminRemote.RegisterClientEvent(p: string, p2: string, flag2: boolean, callback)
	setup()
	assert(
		AdminPermissions.registerPermission(p2),
		(`[STAFF REMOTE] Client event with key {p} needs a valid permission!`)
	)
	assert(
		type(flag2) == "boolean",
		(`[STAFF REMOTE] Client event with key {p} must explicitly choose whether it should be logged!`)
	)

	if RunService:IsClient() then
		return {
			Fire = function(_, p3)
				return (AdminRemote.remotes.RequestInfo:request(p, p3))
			end
		}
	end

	assert(callback ~= nil, (`[STAFF REMOTE] Client event with key {p} needs a server callback!`))
	assert(v[p] == nil, (`[STAFF REMOTE] Client event with key {p} already exists!`))

	v[p] = function(p3, p4)
		if AdminPermissions.hasPermission(p3.UserId, p2) then
			if flag2 and WebhookLogger then
				local success, result = pcall(WebhookLogger.LogAdminEvent, WebhookLogger, p3, p, p4)

				if not success then
					warn((`[STAFF REMOTE] Failed to log {p}: {tostring(result)}`))
				end
			end

			return callback(p3, p4)
		else
			if RunService:IsStudio() then
				warn((`[STAFF REMOTE] Player doesn't have permission to run the {p} client remote!`))
			end

			return nil
		end
	end

	return nil
end

function AdminRemote.RegisterServerEvent(p: string, p2: string, callback)
	setup()
	assert(
		AdminPermissions.registerPermission(p2),
		(`[STAFF REMOTE] Server event with key {p} needs a valid permission!`)
	)

	if not RunService:IsClient() then
		return {
			Fire = function(_, p3, p4)
				if AdminPermissions.hasPermission(p3.UserId, p2) then
					AdminRemote.remotes.SendInfo:fire(p3, p, p4)
				end
			end,
			FireAll = function(_, p3)
				for _, v3 in Players:GetPlayers() do
					if AdminPermissions.hasPermission(v3.UserId, p2) then
						AdminRemote.remotes.SendInfo:fire(v3, p, p3)
					end
				end
			end
		}
	end

	assert(callback ~= nil, (`[STAFF REMOTE] Server event with key {p} needs a client callback!`))
	assert(v2[p] == nil, (`[STAFF REMOTE] Server event with key {p} already exists!`))

	v2[p] = function(p3, p4)
		callback(p3, p4)
	end

	return nil
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = setup
})
return AdminRemote