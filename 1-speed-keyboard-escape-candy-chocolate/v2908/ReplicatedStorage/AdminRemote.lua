local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local remo = require(ReplicatedStorage.Packages.remo)
require(ReplicatedStorage.Utilities.Promise)
local WebhookLogger

if RunService:IsServer() then
	WebhookLogger = require(ServerScriptService.WebhookLogger)
else
	WebhookLogger = nil
end

local remotes = remo.createRemotes({
	SendInfo = remo.remote(),
	RequestInfo = remo.remote().returns()
})
local v = {}
local v2 = {}
local flag = false

local function Setup()
	if flag then
		return
	end

	flag = true

	if RunService:IsClient() then
		remotes.SendInfo:connect(function(p, p2)
			local v3 = v2[p]

			if v3 == nil then
				return
			end

			v3(Players.LocalPlayer, p2)
		end)
	else
		remotes.RequestInfo:onRequest(function(p, p2, p3)
			local v3 = v[p2]

			if v3 == nil then
				return
			else
				return (v3(p, p3))
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayerHasAdminAccess(p)
	if RunService:IsClient() then
		return true
	end

	local AdminConfig = require(ServerScriptService.AdminConfig)
	return AdminConfig:HasPermission(p, "cmdr")
end

local AdminRemote = {}

function AdminRemote.RegisterClientEvent(p: string, flag2: boolean, callback)
	Setup()
	assert(
		type(flag2) == "boolean",
		(`[STAFF REMOTE] Client event with key {p} must explicitly choose whether it should be logged!`)
	)

	if RunService:IsClient() then
		return {
			Fire = function(_, p2)
				return remotes.RequestInfo:request(p, p2)
			end
		}
	end

	assert(callback ~= nil, (`[STAFF REMOTE] Client event with key {p} needs a server callback!`))
	assert(v[p] == nil, (`[STAFF REMOTE] Client event with key {p} already exists!`))

	v[p] = function(p2, p3)
		-- equivalent call inferred; original call site unknown
		if PlayerHasAdminAccess(p2) then
			if flag2 and WebhookLogger then
				local success, result = pcall(WebhookLogger.LogAdminEvent, WebhookLogger, p2, p, p3)

				if not success then
					warn((`[STAFF REMOTE] Failed to log {p}: {tostring(result)}`))
				end
			end

			return callback(p2, p3)
		else
			if RunService:IsStudio() then
				warn((`[STAFF REMOTE] Player doesn't have permission to run the {p} client remote!`))
			end

			return nil
		end
	end

	return nil
end

function AdminRemote.RegisterServerEvent(p: string, callback)
	Setup()

	if not RunService:IsClient() then
		return {
			Fire = function(_, p2, p3)
				-- equivalent call inferred; original call site unknown
				if not PlayerHasAdminAccess(p2) then
					return
				end

				remotes.SendInfo:fire(p2, p, p3)
			end,
			FireAll = function(_, p2)
				for _, v3 in ipairs(Players:GetPlayers()) do
					-- equivalent call inferred; original call site unknown
					if PlayerHasAdminAccess(v3) then
						remotes.SendInfo:fire(v3, p, p2)
					end
				end
			end
		}
	end

	assert(callback ~= nil, (`[STAFF REMOTE] Server event with key {p} needs a client callback!`))
	assert(v2[p] == nil, (`[STAFF REMOTE] Server event with key {p} already exists!`))

	v2[p] = function(p2, p3)
		callback(p2, p3)
	end

	return nil
end

return AdminRemote