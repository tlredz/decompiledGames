local Network = {}
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local remoteEvent, remoteFunction

if isServer then
	remoteEvent = script:FindFirstChild("RemoteEvent") or Instance.new("RemoteEvent", script)
	remoteFunction = script:FindFirstChild("RemoteFunction") or Instance.new("RemoteFunction", script)
	remoteEvent.Name = "RemoteEvent"
	remoteFunction.Name = "RemoteFunction"
else
	remoteEvent = script:WaitForChild("RemoteEvent", 30)
	remoteFunction = script:WaitForChild("RemoteFunction", 30)

	if not (remoteEvent and remoteFunction) then
		warn("[Network] Failed to find RemoteEvent/RemoteFunction after 30s")
	end
end

local v = {}

function Network.AddAction(_, p, p2)
	if v[p] then
		warn("network key already exists " .. tostring(p))
	else
		v[p] = p2
	end
end

function Network:FireAllClients(...)
	if isServer then
		remoteEvent:FireAllClients(...)
	end
end

function Network.Post(_, ...)
	if isServer then
		remoteEvent:FireClient(...)
	else
		remoteEvent:FireServer(...)
	end
end

function Network.Get(_, ...)
	if isServer then
		return remoteFunction:InvokeClient(...)
	end

	return remoteFunction:InvokeServer(...)
end

function Network:Start()
	local function intercept(p, ...)
		local v2 = v[p]

		if not v2 then
			return
		end

		local success, result, v3, v4, v5, v6, v7, v8, v9 = pcall(v2, ...)

		if success then
			return result, v3, v4, v5, v6, v7, v8, v9
		end

		warn(result)
	end

	if isServer then
		local ServerScriptService = game:GetService("ServerScriptService")
		local RemoteFloodCheck = require(ServerScriptService.Modules.RemoteFloodCheck)
		remoteEvent.OnServerEvent:Connect(function(p, p2, ...)
			if not RemoteFloodCheck:Check(p, remoteEvent, 10) then
				return
			end

			intercept(p2, p, ...)
		end)

		remoteFunction.OnServerInvoke = function(p, p2, ...)
			if RemoteFloodCheck:Check(p, remoteFunction, 10) then
				return intercept(p2, p, ...)
			end
		end
	else
		remoteEvent.OnClientEvent:Connect(function(p, ...)
			intercept(p, ...)
		end)

		remoteFunction.OnClientInvoke = function(p, ...)
			return intercept(p, ...)
		end
	end
end

Network:Start()
return Network