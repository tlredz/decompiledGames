local parentModule = require(script.Parent)
require(script.Parent.Parent.Types)
local Util = require(script.Parent.Parent.Util)
local ServerComm = {}
ServerComm.__index = ServerComm

function ServerComm.new(parent, p: string?)
	assert(Util.IsServer, "ServerComm must be constructed from the server")
	assert(typeof(parent) == "Instance", "Parent must be of type Instance")
	local defaultCommFolderName = Util.DefaultCommFolderName
	local name = p or defaultCommFolderName
	assert(not parent:FindFirstChild(name), "Parent already has another ServerComm bound to namespace " .. name)
	local object = setmetatable({}, ServerComm)
	object._instancesFolder = Instance.new("Folder")
	object._instancesFolder.Name = name
	object._instancesFolder.Parent = parent
	return object
end

function ServerComm:BindFunction(p2: string, p3, p4, p5)
	return parentModule.BindFunction(self._instancesFolder, p2, p3, p4, p5)
end

function ServerComm:WrapMethod(p2, p3: string, p4, p5)
	return parentModule.WrapMethod(self._instancesFolder, p2, p3, p4, p5)
end

function ServerComm:CreateSignal(p2: string, flag: boolean?, p3, p4)
	return parentModule.CreateSignal(self._instancesFolder, p2, flag, p3, p4)
end

function ServerComm:CreateProperty(p2: string, p3, p4, p5)
	return parentModule.CreateProperty(self._instancesFolder, p2, p3, p4, p5)
end

function ServerComm:Destroy()
	self._instancesFolder:Destroy()
end

return ServerComm