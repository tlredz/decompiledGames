local MockConnection = require(script.Parent.MockConnection)
local Constants = require(script.Parent.Parent.Constants)
local Output = require(script.Parent.Parent.Utilities.Output)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local RemotePacketSizeCounter = require(script.Parent.Parent.Parent.RemotePacketSizeCounter)
require(script.Parent.Parent.Types)
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

function v:Fire(p2)
	Output.fatalAssert(tostring(self) == "ClientBridge", "Fire called with . instead of :")

	if self.Logging then
		local v3 = string.format(
			Constants.CLIENT_FIRE_LOG,
			self._name,
			tostringData(p2),
			RemotePacketSizeCounter.GetDataByteSize(p2)
		)
		Output.log(v3)
	end
end

function v.Connect(p, callback)
	Output.fatalAssert(tostring(p) == "ClientBridge", "connect called with . instead of :")
	Output.typecheck("function", "Connect", "callback", callback)
	return MockConnection()
end

function v:Wait()
	Output.fatalAssert(tostring(self) == "ClientBridge", "Wait called with . instead of :")
	local thread = coroutine.running()
	self:Once(function(p)
		task.spawn(thread, p)
	end)
	return coroutine.yield()
end

function v.InvokeServerAsync(p, _)
	Output.fatalAssert(tostring(p) == "ClientBridge", "InvokeServerAsync called with . instead of :")
	return coroutine.yield()
end

function v:Once(_)
	Output.fatalAssert(tostring(self) == "ClientBridge", "Once called with . instead of :")
	return MockConnection()
end

function v.Destroy(list)
	Output.fatalAssert(tostring(list) == "ClientBridge", "Destroy called with . instead of :")
	table.clear(list)
	setmetatable(list, nil)
end

return function(p: string)
	return (setmetatable({
		Logging = false,
		_identifier = p,
		_name = p,
		_inboundMiddleware = {},
		_outboundMiddleware = {}
	}, v2))
end