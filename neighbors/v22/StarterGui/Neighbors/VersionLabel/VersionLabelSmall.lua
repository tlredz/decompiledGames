game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local version = workspace:GetAttribute("Version")
local Server = require(ReplicatedStorage.Modules.Server)
local localPlayer = Players.LocalPlayer

if RunService:IsStudio() then
	version = `Studio {version}`
elseif Server:IsTestServer() then
	version = `Test {version}`
elseif Server:IsAdultServer() then
	version = `18+ {version}`
end

local MarketplaceService = game:GetService("MarketplaceService")
local name = MarketplaceService:GetProductInfo(game.PlaceId).Name
script.Parent.Text = `{name} | Version {version} | {localPlayer.Name}`