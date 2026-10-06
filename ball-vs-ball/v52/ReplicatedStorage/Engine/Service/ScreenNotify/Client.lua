local parent = script.Parent
local module = require(parent)
parent.RemoteEvent.OnClientEvent:Connect(module.Play)