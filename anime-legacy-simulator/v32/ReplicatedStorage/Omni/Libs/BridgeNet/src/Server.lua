require(script.Parent.Types)
local isEditMode = require(script.Parent.Utilities.isEditMode)
local PlayerContainers = require(script.PlayerContainers)
local ServerBridge = require(script.ServerBridge)
local ServerIdentifiers = require(script.ServerIdentifiers)
local ServerProcess = require(script.ServerProcess)
local v = {}
local Src = {}

function Src.start()
	if isEditMode then
		return
	end

	ServerIdentifiers.start()
	ServerProcess.start()
end

function Src.makeBridge(p: string)
	if v[p] then
		return v[p]
	end

	local serverBridge = ServerBridge(p)
	v[p] = serverBridge
	return serverBridge
end

function Src.ser(p: string)
	return ServerIdentifiers.ser(p)
end

function Src.deser(p: string)
	return ServerIdentifiers.deser(p)
end

function Src.makeIdentifier(p: string)
	return ServerIdentifiers.ref(p)
end

function Src.playerContainers()
	return PlayerContainers
end

function Src.invalidPlayerhandler(p)
	ServerProcess.setInvalidPlayerFunction(p)
end

return Src