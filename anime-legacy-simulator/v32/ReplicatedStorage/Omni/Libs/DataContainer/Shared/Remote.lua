local RunService = game:GetService("RunService")
local v = {}
local v2 = {}
local v3 = {}
local isServer = RunService:IsServer()
local Remote = {}
local parent = script:FindFirstChild("__Remotes__Folder__")

if not parent then
	if isServer then
		parent = Instance.new("Folder")
		parent.Name = "__Remotes__Folder__"
		parent.Parent = script
	else
		task.spawn(function()
			local lastTime = tick()

			while not (tick() - lastTime >= 60) do
				parent = script:FindFirstChild("__Remotes__Folder__")

				if parent then
					return
				else
					task.wait()
				end
			end

			warn("[REMOTE]: Folder not found, timeout reached")
		end)
	end
end

local function WaitForFolder()
	local lastTime = tick()

	while not parent do
		if tick() - lastTime >= 60 then
			warn("[REMOTE]: Folder not found, timeout reached")
			break
		else
			task.wait()
		end
	end

	return parent ~= nil
end

local function WaitForRemote(name: string)
	local lastTime = tick()
	local child = nil

	while not child do
		if tick() - lastTime >= 60 then
			warn("[REMOTE]: Remote not found, timeout reached")
			return child
		else
			child = parent:FindFirstChild(name)
			task.wait()
		end
	end

	return child
end

function Remote.New(p)
	if not WaitForFolder() then
		return
	end

	if not p or typeof(p) ~= "table" then
		warn("[REMOTE]: RemoteSettings is nil or not a table")
		return
	end

	if not p.Name or typeof(p.Name) ~= "string" then
		warn("[REMOTE]: RemoteSettings.Name is nil or not a string")
		return
	end

	if v[p.Name] then
		return v[p.Name]
	end

	local instance = parent:FindFirstChild(p.Name)

	if not instance then
		if isServer then
			if not instance then
				instance = Instance.new(p.Unreliable and "UnreliableRemoteEvent" or "RemoteEvent")
				instance.Name = p.Name
				instance.Parent = parent
			end
		else
			instance = WaitForRemote(p.Name)
		end
	end

	if not instance then
		return
	end

	local object = setmetatable({
		Name = p.Name,
		Instance = instance,
		Connections = {}
	}, {
		__index = v2
	})

	if isServer then
		object.EventConnection = instance.OnServerEvent:Connect(function(p2, list)
			if object.PreCall then
				list = object.PreCall(list)

				if not list then
					return
				end
			end

			for _, connection in object.Connections do
				if connection.IsConnected then
					task.defer(connection.Callback, p2, table.unpack(list))
				end
			end
		end)
	else
		object.EventConnection = instance.OnClientEvent:Connect(function(list)
			if object.PreCall then
				list = object.PreCall(list)

				if not list then
					return
				end
			end

			for _, connection in object.Connections do
				if connection.IsConnected then
					task.defer(connection.Callback, table.unpack(list))
				end
			end
		end)
	end

	v[p.Name] = object
	return object
end

function Remote.Get(value: string)
	if value and typeof(value) == "string" then
		return v[value]
	end

	warn("[REMOTE]: Name is nil or not a string")
end

function v3.New(callback)
	return (setmetatable({
		IsConnected = true,
		Callback = callback
	}, {
		__index = v3
	}))
end

function v3:Disconnect()
	self.IsConnected = false
end

function v3:Reconnect()
	self.IsConnected = true
end

function v2.Fire(p, ...)
	local v5 = { ... }

	if not isServer then
		p.Instance:FireServer(v5)
		return
	end

	local player = v5[1]

	if not player or typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[REMOTE]: Player not found")
		return
	end

	table.remove(v5, 1)

	if p.PreFire then
		v5 = p.PreFire(v5)

		if not v5 then
			return
		end
	end

	p.Instance:FireClient(player, v5)
end

function v2.FireAll(p, ...)
	if not isServer then
		warn("[REMOTE]: Can't use FireAll on client-side")
		return
	end

	local v5 = { ... }

	if p.PreFire then
		v5 = p.PreFire(v5)

		if not v5 then
			return
		end
	end

	p.Instance:FireAllClients(v5)
end

function v2:Connect(callback)
	if typeof(callback) == "function" then
		table.insert(self.Connections, v3.New(callback))
	else
		warn("[REMOTE]: Callback should be a function")
	end
end

function v2:RegisterPreFire(preFire)
	if typeof(preFire) ~= "function" then
		warn("[REMOTE]: Callback should be a function")
	elseif self.PreFire then
		warn("[REMOTE]: PreFire already registered")
	else
		self.PreFire = preFire
	end
end

function v2:RegisterPreCall(preCall)
	if typeof(preCall) ~= "function" then
		warn("[REMOTE]: Callback should be a function")
	elseif self.PreCall then
		warn("[REMOTE]: PreCall already registered")
	else
		self.PreCall = preCall
	end
end

function v2:Destroy()
	for _, connection in self.Connections do
		connection:Disconnect()
	end

	table.clear(self.Connections)

	if isServer then
		self.Instance:Destroy()
	end

	v[self.Name] = nil
end

return Remote