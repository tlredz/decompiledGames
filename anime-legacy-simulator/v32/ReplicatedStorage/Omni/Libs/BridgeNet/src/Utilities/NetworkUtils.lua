local HttpService = game:GetService("HttpService")
local Output = require(script.Parent.Output)
local NetworkUtils = {}

function NetworkUtils.CreateUUID()
	return (string.gsub(HttpService:GenerateGUID(false), "-", ""))
end

function NetworkUtils.FromHex(value: string)
	return (string.gsub(value, "..", function(p)
		return (string.char((tonumber(p, 16))))
	end))
end

function NetworkUtils.ToHex(value: string)
	Output.fatalAssert(typeof(value) == "string", (`ToHex takes string, got {value}`))
	return (string.gsub(value, ".", function(value2)
		return string.format("%02X", string.byte(value2))
	end))
end

function NetworkUtils.ToReadableHex(value: string)
	Output.fatalAssert(typeof(value) == "string", (`ToReadableHex takes string, got {value}`))
	return string.format(string.rep("%02X ", #value), string.byte(value, 1, -1))
end

return NetworkUtils