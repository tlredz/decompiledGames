local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Shared.Action)
require3(script.Parent.GreenTea)
local v2 = nil
local v3 = 0

local function createServerAction(server)
	local v4 = v3 + 1
	v3 = v4
	local input = server.Input()
	local output = server.Output()
	local remoteFunction = v:RemoteFunction((`{utf8.char(3)}/{utf8.char(v4)}`))
	return {
		Config = server,
		SetFunction = function(p, callback)
			assert(RunService:IsServer(), "Attempt to call ServerAction:SetFunction in Client")

			remoteFunction.OnServerInvoke = function(p2, ...)
				if v2 and not v2(p, p2, ...) then
					return
				else
					return output:assert(callback(p2, input:assert(...)))
				end
			end
		end,
		Call = function(_, ...)
			assert(RunService:IsClient(), "Attempt to call ServerAction:Call in Server")
			return output:assert(remoteFunction:InvokeServer(input:assert(...)))
		end
	}
end

local function createClientAction(client)
	local v4 = v3 + 1
	v3 = v4
	local input = client.Input()
	local remoteEvent = v:RemoteEvent((`{utf8.char(3)}/{utf8.char(v4)}`))
	return {
		Config = client,
		Listen = function(_, callback)
			assert(RunService:IsClient(), "Attempt to call ClientAction:Listen in Server")
			return remoteEvent.OnClientEvent:Connect(function(...)
				debug.profilebegin("Client action")
				callback(input:assert(...))
				debug.profileend()
			end)
		end,
		Send = function(p, player, ...)
			assert(RunService:IsServer(), "Attempt to call ClientAction:Send in Client")

			if v2 and not v2(p, player, ...) then
				return
			else
				return remoteEvent:FireClient(player, input:assert(...))
			end
		end
	}
end

local Actions = {}
Actions.createServerAction = createServerAction
Actions.createClientAction = createClientAction

function Actions.createSharedAction(p)
	return {
		Server = createServerAction(p.Server),
		Client = createClientAction(p.Client)
	}
end

function Actions.createActions(p)
	return p
end

function Actions.setFilterFunction(p)
	v2 = p
end

return Actions