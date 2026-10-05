local RunService = game:GetService("RunService")
local SaneValue = require(script.Parent:WaitForChild("SaneValue"))
local isServer = RunService:IsServer()
local _ = table.find
local _ = table.remove
script:WaitForChild("DeletedNotifier")
local event = script:WaitForChild("Event")
local v = script:WaitForChild("Function")
local v2 = {
	CurrentConnections = isServer and {} or nil,
	CurrentListeners = not isServer and ({} or nil) or nil
}
local v3 = {
	ToClient = function(p, ...)
		event:FireClient(p.Player, p.ConnectionName, ...)
	end,
	YieldToClient = function(p, ...)
		return v:InvokeClient(p.Player, p.ConnectionName, ...)
	end,
	Call = function(self, ...)
		if self.Callback == nil then
			return
		end

		if not self.__DeleteAfterCall then
			return self.Callback(...)
		end

		local callback = self.Callback
		self:Destroy()
		return callback(...)
	end,
	Connect = function(self, callback)
		self.Callback = callback
	end,
	Once = function(p, callback)
		p.Callback = callback
		p.__DeleteAfterCall = true
	end,
	Destroy = function(self)
		if not self.__Active then
			return
		end

		v2.CurrentConnections[self.KeyName] = nil
		script.DeletedNotifier:FireClient(self.Player, self.ConnectionName)
		self.Player = nil
		self.KeyName = nil
		self.ConnectionName = nil
		self.__DeleteAfterCall = nil
		self.Callback = nil
		self.__Active = nil
		setmetatable(self, nil)
	end
}
v3.__index = v3
local v4 = {
	Server = function(p, ...)
		event:FireServer(p.ConnectionName, ...)
	end,
	YieldServer = function(p, ...)
		return v:InvokeServer(p.ConnectionName, ...)
	end,
	Call = function(self, ...)
		if self.Callback == nil then
			return
		end

		if not self.__DeleteAfterCall then
			return self.Callback(...)
		end

		local callback = self.Callback
		self:Destroy()
		return callback(...)
	end,
	OnDestroyed = function(p, onDestroyedCallback)
		p.OnDestroyedCallback = onDestroyedCallback
	end,
	Connect = function(self, callback)
		self.Callback = callback
	end,
	Once = function(p, callback)
		p.Callback = callback
		p.__DeleteAfterCall = true
	end,
	Destroy = function(self)
		if not self.__Active then
			return
		end

		v2.CurrentListeners[self.ConnectionName] = nil
		self.ConnectionName = nil
		self.Callback = nil
		self.OnDestroyedCallback = nil
		self.__DeleteAfterCall = nil
		self.__Active = nil
		setmetatable(self, nil)
	end
}
v4.__index = v4

function v2.Create(player, connectionName: string, value: number?)
	if connectionName == nil then
		return
	end

	local v5 = value or 5
	local object = setmetatable({
		__Active = true,
		Player = player,
		ConnectionName = connectionName,
		KeyName = `{player.Name}-{player.UserId}-{connectionName}`
	}, v3)

	if v5 >= 0 then
		task.delay(v5, function()
			if object.__Active then
				object:Destroy()
			end
		end)
	end

	if v2.CurrentConnections[object.KeyName] ~= nil then
		v2.CurrentConnections[object.KeyName]:Destroy()
	end

	v2.CurrentConnections[object.KeyName] = object
	return object
end

function v2.Link(connectionName: string, value: number?)
	if connectionName == nil then
		return
	end

	local v5 = value or 5
	local object = setmetatable({
		__Active = true,
		ConnectionName = connectionName
	}, v4)

	if v5 >= 0 then
		task.delay(v5, function()
			if object.__Active then
				object:Destroy()
			end
		end)
	end

	if v2.CurrentListeners[connectionName] ~= nil then
		v2.CurrentListeners[connectionName]:Destroy()
	end

	v2.CurrentListeners[connectionName] = object
	return object
end

if isServer then
	function v2.ToClient(player, p: string, ...)
		if player == nil or p == nil then
			return
		end

		event:FireClient(player, p, ...)
	end

	function v2.YieldToClient(player, p: string, ...)
		if player == nil or p == nil then
			return
		else
			return v:InvokeClient(player, p, ...)
		end
	end

	function v2.ToAllClients(p: string, ...)
		if p == nil then
			return
		end

		for _, player in ipairs(game.Players:GetPlayers()) do
			event:FireClient(player, p, ...)
		end
	end
else
	function v2.Server(p: string, ...)
		if p == nil then
			return
		end

		event:FireServer(p, ...)
	end

	function v2.YieldServer(p: string, ...)
		if p == nil then
			return
		else
			return v:InvokeServer(p, ...)
		end
	end
end

function v2.Destroy(p, p2: string?)
	if p2 == nil then
		p2 = p
		p = nil
	end

	if isServer then
		if p == nil or p2 == nil then
			for _, currentConnection in pairs(v2.CurrentConnections) do
				currentConnection:Destroy()
			end
		else
			local formatted = `{p.Name}-{p.UserId}-{p2}`

			if v2.CurrentConnections[formatted] ~= nil then
				v2.CurrentConnections[formatted]:Destroy()
			end
		end
	elseif p2 == nil then
		for _, currentListener in pairs(v2.CurrentListeners) do
			currentListener:Destroy()
		end
	elseif v2.CurrentListeners[p2] ~= nil then
		v2.CurrentListeners[p2]:Destroy()
	end
end

if isServer then
	local object = setmetatable({}, {
		__mode = "k"
	})

	local function allowed(p, value)
		if typeof(value) ~= "string" then
			return false
		end

		local now = os.clock()
		local v5 = object[p]

		if v5 == nil then
			v5 = {
				tokens = 90,
				at = now
			}
			object[p] = v5
		end

		v5.tokens = math.min(90, v5.tokens + (now - v5.at) * 30)
		v5.at = now

		if v5.tokens < 1 then
			return false
		end

		v5.tokens -= 1
		return true
	end

	local function saneArgs(...)
		for i = 1, select("#", ...) do
			local v5 = select(i, ...)

			if typeof(v5) == "table" then
				local count = 0

				for _, v6 in v5 do
					count += 1

					if count > 16 or not SaneValue(v6) then
						return false
					end
				end
			elseif not SaneValue(v5) then
				return false
			end
		end

		return true
	end

	v.OnServerInvoke = function(p, p2: string, ...)
		if not (allowed(p, p2) and saneArgs(...)) then
			return
		end

		local formatted = `{p.Name}-{p.UserId}-{p2}`

		if v2.CurrentConnections[formatted] == nil then
			return
		else
			return v2.CurrentConnections[formatted]:Call(...)
		end
	end

	event.OnServerEvent:Connect(function(p, p2: string, ...)
		if not (allowed(p, p2) and saneArgs(...)) then
			return
		end

		local formatted = `{p.Name}-{p.UserId}-{p2}`

		if v2.CurrentConnections[formatted] ~= nil then
			v2.CurrentConnections[formatted]:Call(...)
		end
	end)
	return v2
else
	v.OnClientInvoke = function(p: string, ...)
		if v2.CurrentListeners[p] == nil then
			return
		else
			return v2.CurrentListeners[p]:Call(...)
		end
	end

	event.OnClientEvent:Connect(function(p: string, ...)
		if v2.CurrentListeners[p] ~= nil then
			v2.CurrentListeners[p]:Call(...)
		end
	end)
	script.DeletedNotifier.OnClientEvent:Connect(function(p: string)
		local currentListener = v2.CurrentListeners[p]

		if currentListener == nil then
			return
		end

		if currentListener.OnDestroyedCallback then
			currentListener.OnDestroyedCallback()
		end

		if currentListener.__Active then
			currentListener:Destroy()
		end
	end)
	return v2
end