local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")

if not script:FindFirstChild("Sent") then
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "Sent"
	remoteEvent.Parent = script
end

if not script:FindFirstChild("Received") then
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "Received"
	remoteEvent.Parent = script
end

local sent = script.Sent
local received = script.Received
local isServer = RunService:IsServer()
local v = {}
local v2 = {}

local function spawnNow(fn, ...)
	local bindableEvent = Instance.new("BindableEvent")
	local v3 = table.pack(...)
	bindableEvent.Event:Connect(function()
		fn(table.unpack(v3, 1, v3.n))
	end)
	bindableEvent:Fire()
	bindableEvent:Destroy()
end

if isServer then
	received.OnServerEvent:Connect(function(...)
		for _, v3 in ipairs(v2) do
			if v3(...) then
				break
			end
		end
	end)
	sent.OnServerEvent:Connect(function(player, p, p2, ...)
		local v3 = v[p]
		received:FireClient(player, p2, v3 and v3(player, ...))
	end)
else
	received.OnClientEvent:Connect(function(...)
		for _, v3 in ipairs(v2) do
			if v3(...) then
				break
			end
		end
	end)
	sent.OnClientEvent:Connect(function(p, p2, ...)
		local v3 = v[p]
		received:FireServer(p2, v3 and v3(...))
	end)
end

local Postie = {}

function Postie.InvokeClient(value, player, value2, ...)
	assert(isServer, "Postie.InvokeClient can only be called from the server")
	assert(typeof(value) == "string", "bad argument #1 to Postie.InvokeClient, expects string")
	local v3

	if typeof(player) == "Instance" then
		v3 = player:IsA("Player")
	else
		v3 = false
	end

	assert(v3, "bad argument #2 to Postie.InvokeClient, expects Instance<Player>")
	assert(typeof(value2) == "number", "bad argument #3 to Postie.InvokeClient, expects number")
	local bindableEvent = Instance.new("BindableEvent")
	local flag = false
	local v4 = #v2 + 1
	local GUID = HttpService:GenerateGUID(false)

	v2[v4] = function(p, p2, ...)
		if p ~= player or p2 ~= GUID then
			return false
		end

		flag = true
		table.remove(v2, v4)
		bindableEvent:Fire(true, ...)
		return true
	end

	spawnNow(function()
		wait(value2)

		if flag then
			return
		end

		table.remove(v2, v4)
		bindableEvent:Fire(false)
	end)
	sent:FireClient(player, value, GUID, ...)
	return bindableEvent.Event:Wait()
end

function Postie.InvokeServer(value, value2, ...)
	assert(not isServer, "Postie.InvokeServer can only be called from the client")
	assert(typeof(value) == "string", "bad argument #1 to Postie.InvokeServer, expects string")
	assert(typeof(value2) == "number", "bad argument #2 to Postie.InvokeServer, expects number")
	local bindableEvent = Instance.new("BindableEvent")
	local flag = false
	local v3 = #v2 + 1
	local GUID = HttpService:GenerateGUID(false)

	v2[v3] = function(p, ...)
		if p ~= GUID then
			return false
		end

		flag = true
		table.remove(v2, v3)
		bindableEvent:Fire(true, ...)
		return true
	end

	spawnNow(function()
		wait(value2)

		if flag then
			return
		end

		table.remove(v2, v3)
		bindableEvent:Fire(false)
	end)
	sent:FireServer(value, GUID, ...)
	return bindableEvent.Event:Wait()
end

function Postie.SetCallback(value, p)
	assert(typeof(value) == "string", "bad argument #1 to Postie.SetCallback, expects string")
	v[value] = p
end

function Postie.GetCallback(value)
	assert(typeof(value) == "string", "bad argument #1 to Postie.GetCallback, expects string")
	return v[value]
end

return Postie