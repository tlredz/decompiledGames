local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TeleportService")
local Players = game:GetService("Players")
local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)
local functions = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Functions")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class:FireAsync(p, ...)
	local module = require(functions[EnumLibrary:FromEnum(p)])
	module(...)
end

function class.FireSync(p, ...)
	task.spawn(p.FireAsync, p, ...)
end

function class:_Init()
	ReplicatedStorage.Remotes.Misc.TeleportFailed.OnClientEvent:Connect(function(p)
		local v = {
			Text = "[SERVER] Teleport failed, please try again. Error: " .. tostring(p),
			Color = Color3.fromRGB(255, 50, 50)
		}
		self:FireAsync(EnumLibrary:ToEnum("SendChat"), v)
	end)
	ReplicatedStorage.Remotes.Misc.Functions.OnClientEvent:Connect(function(...)
		self:FireAsync(...)
	end)
	ReplicatedStorage.Remotes.Misc.FunctionsUnreliable.OnClientEvent:Connect(function(...)
		self:FireAsync(...)
	end)
end

return class._new()