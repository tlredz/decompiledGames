local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Environment = require(ReplicatedStorage.Packages["UI-Labs"].Environment)
local Common = {}
local v = 0
local random = Random.new(tick() * 1000)

function Common.IsServer()
	return RunService:IsServer()
end

function Common.IsStudio()
	return RunService:IsStudio()
end

function Common.IsClient()
	return RunService:IsClient()
end

function Common.IsPlugin()
	return plugin ~= nil or Environment.IsStory()
end

function Common.GetLocalPlayer()
	assert(Common.IsClient(), "Cannot GetLocalPlayer on Server.")
	return Players.LocalPlayer
end

function Common.GetDeltatime()
	return v
end

function Common.GetRandom()
	return random
end

function Common._NewFrameBegin(p: number)
	v = p
end

return Common