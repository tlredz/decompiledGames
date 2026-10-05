local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not ReplicatedStorage:FindFirstChild("PostieSent") then
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "PostieSent"
	remoteEvent.Parent = ReplicatedStorage
end

if not ReplicatedStorage:FindFirstChild("PostieReceived") then
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "PostieReceived"
	remoteEvent.Parent = ReplicatedStorage
end

local postieSent = ReplicatedStorage.PostieSent
local postieReceived = ReplicatedStorage.PostieReceived
local isServer = RunService:IsServer()
local v = {}
local v2 = {}

if isServer then
	postieReceived.OnServerEvent:Connect(function(p, p2, p3, ...)
		local v3 = v2[p2]

		if not v3 then
			return
		end

		v3(p, p3, ...)
	end)
	postieSent.OnServerEvent:Connect(function(player, p, p2, ...)
		local v3 = v[p]

		if v3 then
			postieReceived:FireClient(player, p2, true, v3(player, ...))
		else
			postieReceived:FireClient(player, p2, false)
		end
	end)
else
	postieReceived.OnClientEvent:Connect(function(p, p2, ...)
		local v3 = v2[p]

		if not v3 then
			return
		end

		v3(p2, ...)
	end)
	postieSent.OnClientEvent:Connect(function(p, p2, ...)
		local v3 = v[p]

		if v3 then
			postieReceived:FireServer(p2, true, v3(...))
		else
			postieReceived:FireServer(p2, false)
		end
	end)
end

local Postie = {}

function Postie.invokeClient(p: string, player, duration: number, ...)
	assert(isServer, "Postie.invokeClient can only be called from the server")
	local thread = coroutine.running()
	local flag = false
	local GUID = HttpService:GenerateGUID(false)

	v2[GUID] = function(p2, p3, ...)
		if p2 ~= player then
			return
		end

		flag = true
		v2[GUID] = nil

		if p3 then
			task.spawn(thread, true, ...)
		else
			task.spawn(thread, false)
		end
	end

	task.delay(duration, function()
		if flag then
			return
		end

		v2[GUID] = nil
		task.spawn(thread, false)
	end)
	postieSent:FireClient(player, p, GUID, ...)
	return coroutine.yield()
end

function Postie.invokeServer(p: string, duration: number, ...)
	assert(not isServer, "Postie.invokeServer can only be called from the client")
	local thread = coroutine.running()
	local flag = false
	local GUID = HttpService:GenerateGUID(false)

	v2[GUID] = function(p2, ...)
		flag = true
		v2[GUID] = nil

		if p2 then
			task.spawn(thread, true, ...)
		else
			task.spawn(thread, false)
		end
	end

	task.delay(duration, function()
		if flag then
			return
		end

		v2[GUID] = nil
		task.spawn(thread, false)
	end)
	postieSent:FireServer(p, GUID, ...)
	return coroutine.yield()
end

function Postie.setCallback(p: string, callback)
	v[p] = callback
end

function Postie.getCallback(p: string)
	return v[p]
end

return Postie