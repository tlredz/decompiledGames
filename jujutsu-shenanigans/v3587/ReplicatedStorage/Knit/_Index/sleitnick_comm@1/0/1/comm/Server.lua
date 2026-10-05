local RemoteProperty = require(script.RemoteProperty)
local RemoteSignal = require(script.RemoteSignal)
require(script.Parent.Types)
local Util = require(script.Parent.Util)
local Comm = {
	BindFunction = function(p, name: string, onServerInvoke, list, list2)
		assert(Util.IsServer, "BindFunction must be called from the server")
		local expect = Util.GetCommSubFolder(p, "RF"):Expect("Failed to get Comm RF folder")
		local remoteFunction = Instance.new("RemoteFunction")
		remoteFunction.Name = name
		local v

		if type(list) == "table" then
			v = #list > 0
		else
			v = false
		end

		local v2

		if type(list2) == "table" then
			v2 = #list2 > 0
		else
			v2 = false
		end

		local function ProcessOutbound(p2, ...)
			local v3 = table.pack(...)

			for _, v4 in ipairs(list2) do
				local v5 = table.pack(v4(p2, v3))

				if not v5[1] then
					return table.unpack(v5, 2, v5.n)
				end

				v3.n = #v3
			end

			return table.unpack(v3, 1, v3.n)
		end

		if v and v2 then
			remoteFunction.OnServerInvoke = function(p2, ...)
				local v3 = table.pack(...)

				for _, v4 in ipairs(list) do
					local v5 = table.pack(v4(p2, v3))

					if not v5[1] then
						return table.unpack(v5, 2, v5.n)
					end

					v3.n = #v3
				end

				return ProcessOutbound(p2, onServerInvoke(p2, table.unpack(v3, 1, v3.n)))
			end
		elseif v then
			remoteFunction.OnServerInvoke = function(p2, ...)
				local v3 = table.pack(...)

				for _, v4 in ipairs(list) do
					local v5 = table.pack(v4(p2, v3))

					if not v5[1] then
						return table.unpack(v5, 2, v5.n)
					end

					v3.n = #v3
				end

				return onServerInvoke(p2, table.unpack(v3, 1, v3.n))
			end
		elseif v2 then
			remoteFunction.OnServerInvoke = function(p2, ...)
				return ProcessOutbound(p2, onServerInvoke(p2, ...))
			end
		else
			remoteFunction.OnServerInvoke = onServerInvoke
		end

		remoteFunction.Parent = expect
		return remoteFunction
	end
}

function Comm.WrapMethod(p, p2, p3: string, p4, p5)
	assert(Util.IsServer, "WrapMethod must be called from the server")
	local v = p2[p3]
	assert(type(v) == "function", "Value at index " .. p3 .. " must be a function; got " .. type(v))
	return Comm.BindFunction(p, p3, function(...)
		return v(p2, ...)
	end, p4, p5)
end

function Comm.CreateSignal(p, p2: string, flag: boolean?, p3, p4)
	assert(Util.IsServer, "CreateSignal must be called from the server")
	local expect = Util.GetCommSubFolder(p, "RE"):Expect("Failed to get Comm RE folder")
	return (RemoteSignal.new(expect, p2, flag, p3, p4))
end

function Comm.CreateProperty(p, p2: string, p3, p4, p5)
	assert(Util.IsServer, "CreateProperty must be called from the server")
	local expect = Util.GetCommSubFolder(p, "RP"):Expect("Failed to get Comm RP folder")
	return (RemoteProperty.new(expect, p2, p3, p4, p5))
end

return Comm