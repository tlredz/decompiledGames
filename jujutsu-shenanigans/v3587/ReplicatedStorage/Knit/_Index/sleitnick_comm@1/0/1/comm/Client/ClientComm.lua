local parentModule = require(script.Parent)
require(script.Parent.Parent.Types)
local Util = require(script.Parent.Parent.Util)
local ClientComm = {}
ClientComm.__index = ClientComm

function ClientComm.new(instance, usePromise: boolean, p: string?)
	assert(not Util.IsServer, "ClientComm must be constructed from the client")
	assert(typeof(instance) == "Instance", "Parent must be of type Instance")
	local defaultCommFolderName = Util.DefaultCommFolderName
	local v = p or defaultCommFolderName
	local child = instance:WaitForChild(v, Util.WaitForChildTimeout)
	assert(child ~= nil, "Could not find namespace for ClientComm in parent: " .. v)
	local object = setmetatable({}, ClientComm)
	object._instancesFolder = child
	object._usePromise = usePromise
	return object
end

function ClientComm:GetFunction(p2: string, p3, p4)
	return parentModule.GetFunction(self._instancesFolder, p2, self._usePromise, p3, p4)
end

function ClientComm:GetSignal(p2: string, p3, p4)
	return parentModule.GetSignal(self._instancesFolder, p2, p3, p4)
end

function ClientComm:GetProperty(p2: string, p3, p4)
	return parentModule.GetProperty(self._instancesFolder, p2, p3, p4)
end

function ClientComm:BuildObject(p, p2)
	local result = {}
	local RF = self._instancesFolder:FindFirstChild("RF")
	local RE = self._instancesFolder:FindFirstChild("RE")
	local RP = self._instancesFolder:FindFirstChild("RP")

	if RF then
		for _, remoteFunction in RF:GetChildren() do
			if not remoteFunction:IsA("RemoteFunction") then
				continue
			end

			local v2 = self:GetFunction(remoteFunction.Name, p, p2)

			result[remoteFunction.Name] = function(p3, ...)
				return v2(...)
			end
		end
	end

	if RE then
		for _, child in RE:GetChildren() do
			if child:IsA("RemoteEvent") or child:IsA("UnreliableRemoteEvent") then
				result[child.Name] = self:GetSignal(child.Name, p, p2)
			end
		end
	end

	if RP then
		for _, remoteEvent in RP:GetChildren() do
			if remoteEvent:IsA("RemoteEvent") then
				result[remoteEvent.Name] = self:GetProperty(remoteEvent.Name, p, p2)
			end
		end
	end

	return result
end

function ClientComm.Destroy(_) end

return ClientComm