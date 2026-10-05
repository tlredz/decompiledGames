local StarcallerCryClient = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local module = require("./PassiveHandler")
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("StarcallerCry/PerfectLost", -1)

function StarcallerCryClient.Morph(p, _, p2)
	p.reelTrove:Add(p2.OnFishExitBar:Once(function()
		remoteEvent:FireServer()
	end))
end

setmetatable(StarcallerCryClient, module)
return StarcallerCryClient