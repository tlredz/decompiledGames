local Constants = require(script.Parent.Parent.Constants)
local wallyInstanceManager = require(script.Parent.Parent.Parent.wallyInstanceManager)
require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)
local ServerIdentifiers = {}
local count = 0
local v = {}
local v2 = {}
local v3 = nil

function ServerIdentifiers.start()
	local identifierStorage = wallyInstanceManager.get(script.Parent.Parent.Parent, "identifierStorage")

	if identifierStorage then
		v3 = identifierStorage
	else
		v3 = Instance.new("Folder")
		v3.Name = "identifierStorage"
		wallyInstanceManager.add(script.Parent.Parent.Parent, v3)
	end

	ServerIdentifiers.ref("NIL_VALUE")
	ServerIdentifiers.ref("REQUEST")
end

function ServerIdentifiers.ref(p: string)
	if v[p] ~= nil then
		return v[p]
	end

	Output.fatalAssert(
		count <= Constants.IDENTIFIER_CAP,
		(`cannot create any more identifiers - over {Constants.IDENTIFIER_CAP_STRING} cap.`)
	)
	local selected

	if count <= 255 then
		selected = string.pack("B", count)
	else
		selected = string.pack("H", count)
	end

	count += 1
	v3:SetAttribute(p, selected)
	v[p] = selected
	v2[selected] = p
	return selected
end

function ServerIdentifiers.deser(value)
	Output.fatalAssert(typeof(value) == "string", string.format("Deserialize takes string, got %*", (typeof(value))))
	return v2[value]
end

function ServerIdentifiers.ser(value)
	Output.fatalAssert(typeof(value) == "string", string.format("Serialize takes string, got %*", (typeof(value))))
	return v[value]
end

return ServerIdentifiers