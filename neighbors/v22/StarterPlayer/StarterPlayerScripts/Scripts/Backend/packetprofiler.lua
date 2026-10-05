local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Admin = require(ReplicatedStorage.Modules.Admin)
local localPlayer = Players.LocalPlayer

if not Admin:IsLocalPlayerDeveloper() then
	return
end

print("User is a developer -- packet sniffer available with CTRL+F5")
local components = script.Components
local modules = script.Modules
local Packages = require(modules.Packages)
Packages.IsPlugin = false
local Roact = require(Packages.Directory.Roact)
local MainPlugin = require(components.MainPlugin)
local element = Roact.createElement(MainPlugin)
Roact.mount(element, localPlayer.PlayerGui, "PacketProfiler")