local Constants = require(script.Parent.Parent.Constants)
local RemotePacketSizeCounter = require(script.Parent.Parent.Parent.RemotePacketSizeCounter)
local ServerProcess = require(script.Parent.ServerProcess)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)
local tostringData = require(script.Parent.Parent.Utilities.tostringData)
local PlayerContainers = require(script.Parent.PlayerContainers)
local ServerConnection = require(script.Parent.ServerConnection)
local ServerIdentifiers = require(script.Parent.ServerIdentifiers)
local v = {}
local v2 = {
	__index = v,
	__tostring = function(_)
		return "ServerBridge"
	end
}

function v:InboundMiddleware(inboundMiddleware)
	Output.fatalAssert(tostring(self) == "ServerBridge", "InboundMiddleware called with . instead of :")
	self._inboundMiddleware = inboundMiddleware
end

function v:OutboundMiddleware(outboundMiddleware)
	Output.fatalAssert(tostring(self) == "ServerBridge", "OutboundMiddleware called with . instead of :")
	self._outboundMiddleware = outboundMiddleware
end

function v:Connect(callback, p: string?)
	Output.fatalAssert(tostring(self) == "ServerBridge", "Connect called with . instead of :")
	Output.typecheck("function", "Connect", "callback", callback)
	local v3 = debug.info(2, "l")
	local v4 = debug.info(2, "s")
	return ServerConnection(self._identifier, function(p2, list)
		if typeof(list) == "table" and list[1] == ServerIdentifiers.ref("REQUEST") then
			return
		end

		if self.RateLimitActive then
			local v5 = math.round(os.clock() - os.clock() % 1)

			if self._rateMap[p2] == nil then
				self._rateMap[p2] = { v5, 1 }
			elseif (self._rateMap[p2][1] or 0) == v5 then
				self._rateMap[p2][2] += 1
			else
				self._rateMap[p2][2] = 0
				self._rateMap[p2][1] = v5
			end

			if self._rateMap[p2][2] >= self._maxRate and not self._overflowFunction(p2) then
				return
			end
		end

		if self._inboundMiddleware == nil then
			if self.Logging then
				local v5 = string.format(
					Constants.SERVER_CONNECT_LOG,
					p or self._name,
					p2.Name,
					tostringData(list),
					RemotePacketSizeCounter.GetDataByteSize(list),
					v4,
					v3
				)
				Output.log(v5)
			end

			if p then
				debug.profilebegin(p)
			end

			callback(p2, list)

			if p then
				debug.profileend()
			end
		else
			local v5 = list

			for _, v6 in self._inboundMiddleware do
				local v7 = v6(p2, v5)

				if typeof(v7) == "table" then
					v5 = v7
				else
					Output.silent(string.format(
						"Inbound middleware on bridge %* did not return a table; ignoring the return.",
						self._name
					))
				end
			end

			if self.Logging then
				local v6 = string.format(
					Constants.SERVER_CONNECT_LOG,
					p or self._name,
					p2.Name,
					tostringData(list),
					RemotePacketSizeCounter.GetDataByteSize(list),
					v4,
					v3
				)
				Output.log(v6)
			end

			if p then
				debug.profilebegin(p)
			end

			callback(p2, v5)

			if p then
				debug.profileend()
			end
		end
	end)
end

function v:RateLimit(maxRate: number, overflowFunction)
	Output.fatalAssert(tostring(self) == "ServerBridge", "RateLimit called with . instead of :")
	self.RateLimitActive = true
	self._overflowFunction = overflowFunction
	self._maxRate = maxRate
end

function v:DisableRateLimit()
	Output.fatalAssert(tostring(self) == "ServerBridge", "DisableRateLimit called with . instead of :")
	self.RateLimitActive = false
end

function v:Wait()
	Output.fatalAssert(tostring(self) == "ServerBridge", "Wait called with . instead of :")
	local thread = coroutine.running()
	self:Connect(function(p, p2)
		task.spawn(thread, p, p2)
	end)
	return coroutine.yield()
end

function v:Once(callback)
	Output.fatalAssert(tostring(self) == "ServerBridge", "Once called with . instead of :")
	Output.typecheck("function", "Once", "callback", callback)
	local connection = nil
	connection = self:Connect(function(p, p2)
		connection:Disconnect()
		callback(p, p2)
	end)
	return connection
end

function v:Fire(player, p)
	Output.fatalAssert(tostring(self) == "ServerBridge", "Fire called with . instead of :")
	local v3 = nil

	if typeof(player) == "Instance" then
		if player:IsA("Player") then
			v3 = PlayerContainers.Single(player)
		else
			Output.fatal("non-player instance passed into :Fire()")
		end
	else
		if typeof(player) == "nil" then
			Output.fatal("target parameter passed into ServerBridge:Fire() is nil")
		end

		Output.typecheck("table", "Fire", "target", player)
		v3 = player
	end

	if self._outboundMiddleware ~= nil then
		for _, v4 in self._outboundMiddleware do
			local v5 = v4(p)

			if typeof(v5) == "table" then
				p = v5
			else
				Output.silent(string.format(
					"Outbound middleware on bridge %* did not return a table; ignoring the return.",
					self._name
				))
			end
		end
	end

	if self.Logging then
		Output.log((`{debug.info(2, "s")}:{debug.info(2, "l")}`))
		local SERVER_FIRE_LOG = Constants.SERVER_FIRE_LOG
		local _name = self._name
		local name

		if v3.kind == "all" then
			name = "{all}"
		elseif v3.kind == "single" then
			name = v3.value.Name
		else
			name = TableKit.ToArrayString(v3.value)
		end

		local v4 = string.format(
			SERVER_FIRE_LOG,
			_name,
			name,
			tostringData(p),
			RemotePacketSizeCounter.GetDataByteSize(p)
		)
		Output.log(v4)
	end

	ServerProcess.addToQueue(v3, self._identifier, p)
end

return function(name: string)
	local object = setmetatable({
		_identifier = ServerIdentifiers.ref(name),
		_outboundMiddleware = nil,
		_inboundMiddleware = nil,
		_name = name,
		Logging = false,
		OnServerInvoke = function() end,
		RateLimitActive = false,
		_maxRate = 500,
		_rateMap = {},
		_overflowFunction = function()
			return false
		end
	}, v2)
	ServerProcess.registerBridge(object._identifier)
	ServerProcess.connect(object._identifier, function(p2, list)
		if typeof(list) ~= "table" then
			return
		end

		if object.OnServerInvoke ~= nil and list[1] == ServerIdentifiers.ref("REQUEST") then
			local v3 = object.OnServerInvoke(p2, list[3])
			object:Fire(p2, { ServerIdentifiers.ref("REQUEST"), list[2], v3 })
		end
	end)
	return object
end