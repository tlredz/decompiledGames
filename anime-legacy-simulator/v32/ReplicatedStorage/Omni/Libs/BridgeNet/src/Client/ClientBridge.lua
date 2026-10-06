local ClientConnection = require(script.Parent.ClientConnection)
local ClientIdentifiers = require(script.Parent.ClientIdentifiers)
local ClientProcess = require(script.Parent.ClientProcess)
local Constants = require(script.Parent.Parent.Constants)
local Output = require(script.Parent.Parent.Utilities.Output)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local RemotePacketSizeCounter = require(script.Parent.Parent.Parent.RemotePacketSizeCounter)
require(script.Parent.Parent.Types)
local NetworkUtils = require(script.Parent.Parent.Utilities.NetworkUtils)
local tostringData = require(script.Parent.Parent.Utilities.tostringData)
local v = {}
local v2 = {
	__index = v,
	__tostring = function(_)
		return "ClientBridge"
	end
}

function v.RateLimit(_)
	Output.warn("cannot call :RateLimit() from client")
end

function v.DisableRateLimit(_)
	Output.warn("cannot call :DisableRateLimit() from client")
end

function v:InboundMiddleware(inboundMiddleware)
	Output.fatalAssert(tostring(self) == "ClientBridge", "InboundMiddleware called with . instead of :")
	Output.fatalAssert(
		typeof(inboundMiddleware) == "table",
		string.format("InboundMiddleware takes table, got %*", (typeof(inboundMiddleware)))
	)
	Output.warnAssert(TableKit.IsArray(inboundMiddleware), "InboundMiddleware takes array, got dictionary.")
	self._inboundMiddleware = inboundMiddleware
end

function v:OutboundMiddleware(outboundMiddleware)
	Output.fatalAssert(tostring(self) == "ClientBridge", "OutboundMiddleware called with . instead of :")
	Output.fatalAssert(
		typeof(outboundMiddleware) == "table",
		string.format("OutboundMiddleware takes table, got %*", (typeof(outboundMiddleware)))
	)
	Output.warnAssert(TableKit.IsArray(outboundMiddleware), "InboundMiddleware takes array, got dictionary.")
	self._outboundMiddleware = outboundMiddleware
end

function v:Fire(p)
	Output.fatalAssert(tostring(self) == "ClientBridge", "Fire called with . instead of :")

	if self._outboundMiddleware ~= nil then
		for _, v3 in self._outboundMiddleware do
			local v4 = v3(p)

			if typeof(v4) == "table" then
				p = v4
			else
				Output.silent(string.format(
					"Inbound middleware on bridge %* did not return a table; ignoring the return.",
					self._name
				))
			end
		end
	end

	if self.Logging then
		Output.log((`{debug.info(2, "s")}:{debug.info(2, "l")}`))
		local v3 = string.format(
			Constants.CLIENT_FIRE_LOG,
			self._name,
			tostringData(p),
			RemotePacketSizeCounter.GetDataByteSize(p)
		)
		Output.log(v3)
	end

	ClientProcess.addToQueue(self._identifier, p)
end

function v:Connect(callback, p: string?)
	Output.fatalAssert(tostring(self) == "ClientBridge", "connect called with . instead of :")
	Output.typecheck("function", "Connect", "callback", callback)
	local v3 = debug.info(2, "l")
	local v4 = debug.info(2, "s")
	return ClientConnection(self._identifier, function(list)
		if typeof(list) == "table" and list[1] == ClientIdentifiers.ref("REQUEST", 3, false) then
			return
		end

		if self._inboundMiddleware == nil then
			if self.Logging then
				local v5 = string.format(
					Constants.CLIENT_CONNECT_LOG,
					p or self._name,
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

			callback(list)

			if p then
				debug.profileend()
			end
		else
			for _, v5 in self._inboundMiddleware do
				local v6 = v5(list)

				if typeof(v6) == "table" then
					list = v6
				else
					Output.silent(string.format(
						"Inbound middleware on bridge %* did not return a table; ignoring the return.",
						self._name
					))
				end
			end

			if self.Logging then
				local v5 = string.format(
					Constants.CLIENT_CONNECT_LOG,
					p or self._name,
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

			callback(list)

			if p then
				debug.profileend()
			end
		end
	end)
end

function v:Wait()
	Output.fatalAssert(tostring(self) == "ClientBridge", "Wait called with . instead of :")
	local thread = coroutine.running()
	self:Once(function(p)
		task.spawn(thread, p)
	end)
	return coroutine.yield()
end

function v:InvokeServerAsync(p)
	Output.fatalAssert(tostring(self) == "ClientBridge", "InvokeServerAsync called with . instead of :")
	local v3 = NetworkUtils.FromHex(NetworkUtils.CreateUUID())
	self:Fire({ ClientIdentifiers.ref("REQUEST", 3, false), v3, p })
	local thread = coroutine.running()
	local v4 = nil
	v4 = ClientProcess.connect(self._identifier, function(list)
		if typeof(list) ~= "table" then
			return
		end

		if list[1] == ClientIdentifiers.ref("REQUEST", 3, false) and list[2] == v3 then
			v4()
			task.spawn(thread, list[3])
		end
	end)
	return coroutine.yield()
end

function v:Once(callback)
	Output.fatalAssert(tostring(self) == "ClientBridge", "Once called with . instead of :")
	local connection = nil
	connection = self:Connect(function(p)
		connection:Disconnect()
		callback(p)
	end)
	return connection
end

function v.Destroy(list)
	Output.fatalAssert(tostring(list) == "ClientBridge", "Destroy called with . instead of :")
	table.clear(list)
	setmetatable(list, nil)
end

return function(name: string)
	local self = setmetatable({
		Logging = false,
		_identifier = ClientIdentifiers.ref(name, 3, true),
		_name = name,
		_inboundMiddleware = {},
		_outboundMiddleware = {}
	}, v2)
	ClientProcess.registerBridge(self._identifier)
	return self
end