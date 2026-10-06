local ClientBridge = require(script.ClientBridge)
local ClientIdentifiers = require(script.ClientIdentifiers)
local ClientProcess = require(script.ClientProcess)
require(script.Parent.Types)
local isEditMode = require(script.Parent.Utilities.isEditMode)
local v = {}
local Src = {}

function Src.start()
	if isEditMode then
		return
	end

	ClientProcess.start()
	ClientIdentifiers.start()
end

function Src.ser(p)
	if isEditMode then
		return p
	end

	return ClientIdentifiers.ser(p)
end

function Src.deser(p)
	if isEditMode then
		return p
	end

	return ClientIdentifiers.deser(p)
end

function Src.makeIdentifier(p: string, p2: number?)
	if isEditMode then
		return p
	end

	return ClientIdentifiers.ref(p, p2, false)
end

function Src.makeBridge(p: string)
	if v[p] then
		return v[p]
	end

	local clientBridge = ClientBridge(p)
	v[p] = clientBridge
	return clientBridge
end

return Src