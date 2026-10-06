local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local Libs = {
	Hittox = require(script.Hittox),
	BridgeNet = require(script.BridgeNet),
	Promise = require(script.Promise),
	ThreadSaver = require(script.ThreadSaver),
	GoodSignal = require(script.GoodSignal),
	Spring = require(script.Spring),
	Charm = require(script.Charm)
}

if isServer then
	Libs.Savit = require(script.Savit)
	Libs.ViscoServer = require(script.Visco.Server)
	Libs.DataContainerServer = require(script.DataContainer.Server)
end

if not isClient then
	return Libs
end

Libs.Text = require(script.Text)
Libs.Shake = require(script.Shake)
Libs.RockModule = require(script.RockModule)
Libs.Vide = require(script.Vide)
Libs.Fusion = require(script.Fusion)
Libs.UILabs = require(script.UILabs)
Libs.NeoHover = require(script.NeoHover)
Libs.TopBarPlus = require(script.TopBarPlus)
Libs.ViscoClient = require(script.Visco.Client)
Libs.DataContainerClient = require(script.DataContainer.Client)
return Libs