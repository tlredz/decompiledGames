local RunService = game:GetService("RunService")
local Client = require(script.Client)
require(script.PublicTypes)
local Server = require(script.Server)
local MockBridge = require(script.Studio.MockBridge)
local NetworkUtils = require(script.Utilities.NetworkUtils)
local Output = require(script.Utilities.Output)
local isEditMode = require(script.Utilities.isEditMode)
local version = require(script.version)
local isServer = RunService:IsServer()
task.spawn(function()
	if not isEditMode then
		if isServer then
			Server.start()
		else
			Client.start()
		end
	end
end)
local Src = {
	ToHex = NetworkUtils.ToHex,
	ToReadableHex = NetworkUtils.ToReadableHex,
	FromHex = NetworkUtils.FromHex,
	CreateUUID = NetworkUtils.CreateUUID,
	ReferenceIdentifier = 0,
	Deserialize = 0,
	Serialize = 0,
	AllPlayers = 0,
	PlayersExcept = 0,
	Players = 0,
	ReferenceBridge = 0,
	ServerBridge = 0,
	ClientBridge = 0,
	Types = 0,
	HandleInvalidPlayer = 0,
	version = 0
}
local referenceIdentifier

if isServer then
	referenceIdentifier = Server.makeIdentifier
else
	referenceIdentifier = Client.makeIdentifier
end

Src.ReferenceIdentifier = referenceIdentifier
local deserialize

if isServer then
	deserialize = Server.deser
else
	deserialize = Client.deser
end

Src.Deserialize = deserialize
local serialize

if isServer then
	serialize = Server.ser
else
	serialize = Client.ser
end

Src.Serialize = serialize
Src.AllPlayers = Server.playerContainers().All
Src.PlayersExcept = Server.playerContainers().Except
Src.Players = Server.playerContainers().Players
local referenceBridge

if isServer then
	referenceBridge = Server.makeBridge
else
	referenceBridge = Client.makeBridge
end

Src.ReferenceBridge = referenceBridge
local serverBridge

if isServer then
	serverBridge = Server.makeBridge
end

Src.ServerBridge = serverBridge
local clientBridge

if not isServer then
	clientBridge = Client.makeBridge
end

Src.ClientBridge = clientBridge
Src.Types = script.ExportedTypes

function Src.HandleInvalidPlayer(callback)
	Output.fatalAssert(isServer, "Cannot call from client")
	Server.invalidPlayerhandler(callback)
end

Src.version = version

if isEditMode then
	Output.log("running BridgeNet2 in mock mode")
	Src.ClientBridge = MockBridge
	Src.ServerBridge = nil
	Src.ReferenceBridge = MockBridge

	function Src.ReferenceIdentifier(p)
		return p
	end

	function Src.Serialize(p)
		return p
	end

	function Src.Deserialize(p)
		return p
	end
end

table.freeze(Src)
return Src