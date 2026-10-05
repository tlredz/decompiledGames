local Util = require(script.Parent.Util)
require(script.Parent.Types)
local Promise = require(script.Parent.Parent.Promise)
local ClientRemoteSignal = require(script.ClientRemoteSignal)
local ClientRemoteProperty = require(script.ClientRemoteProperty)
local Comm = {}

function Comm.GetFunction(p, childName: string, flag: boolean, list, list2)
	assert(not Util.IsServer, "GetFunction must be called from the client")
	local child = Util.GetCommSubFolder(p, "RF"):Expect("Failed to get Comm RF folder"):WaitForChild(
		childName,
		Util.WaitForChildTimeout
	)
	assert(child ~= nil, "Failed to find RemoteFunction: " .. childName)
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

	local function ProcessOutbound(list3)
		for _, v3 in ipairs(list2) do
			local v4 = table.pack(v3(list3))

			if not v4[1] then
				return table.unpack(v4, 2, v4.n)
			end

			list3.n = #list3
		end

		return table.unpack(list3, 1, list3.n)
	end

	if v then
		if flag then
			return function(...)
				local v3 = table.pack(...)
				return Promise.new(function(callback, callback2)
					local success, result = pcall(function()
						if v2 then
							return table.pack(child:InvokeServer(ProcessOutbound(v3)))
						end

						return table.pack(child:InvokeServer(table.unpack(v3, 1, v3.n)))
					end)

					if not success then
						callback2(result)
						return
					end

					for _, v4 in ipairs(list) do
						local v5 = table.pack(v4(result))

						if not v5[1] then
							return table.unpack(v5, 2, v5.n)
						end

						result.n = #result
					end

					callback(table.unpack(result, 1, result.n))
				end)
			end
		end

		return function(...)
			local v3

			if v2 then
				v3 = table.pack(child:InvokeServer(ProcessOutbound(table.pack(...))))
			else
				v3 = table.pack(child:InvokeServer(...))
			end

			for _, v4 in ipairs(list) do
				local v5 = table.pack(v4(v3))

				if not v5[1] then
					return table.unpack(v5, 2, v5.n)
				end

				v3.n = #v3
			end

			return table.unpack(v3, 1, v3.n)
		end
	else
		if flag then
			return function(...)
				local v3 = table.pack(...)
				return Promise.new(function(callback, callback2)
					local success, result = pcall(function()
						if v2 then
							return table.pack(child:InvokeServer(ProcessOutbound(v3)))
						end

						return table.pack(child:InvokeServer(table.unpack(v3, 1, v3.n)))
					end)

					if success then
						callback(table.unpack(result, 1, result.n))
					else
						callback2(result)
					end
				end)
			end
		end

		if v2 then
			return function(...)
				return child:InvokeServer(ProcessOutbound(table.pack(...)))
			end
		end

		return function(...)
			return child:InvokeServer(...)
		end
	end
end

function Comm.GetSignal(p, childName: string, p2, p3)
	assert(not Util.IsServer, "GetSignal must be called from the client")
	local child = Util.GetCommSubFolder(p, "RE"):Expect("Failed to get Comm RE folder"):WaitForChild(
		childName,
		Util.WaitForChildTimeout
	)
	assert(child ~= nil, "Failed to find RemoteEvent: " .. childName)
	return ClientRemoteSignal.new(child, p2, p3)
end

function Comm.GetProperty(p, childName: string, p2, p3)
	assert(not Util.IsServer, "GetProperty must be called from the client")
	local child = Util.GetCommSubFolder(p, "RP"):Expect("Failed to get Comm RP folder"):WaitForChild(
		childName,
		Util.WaitForChildTimeout
	)
	assert(child ~= nil, "Failed to find RemoteEvent for RemoteProperty: " .. childName)
	return ClientRemoteProperty.new(child, p2, p3)
end

return Comm