local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self:_Init()
	return self
end

function object.PlayFlashSound(_, p)
	Utility:CreateSound("rbxassetid://14778230670", 1, 1, p, true, 10)
end

function object.PlayRingingSound(_)
	return Utility:CreateSound("rbxassetid://14778230632", 1, 1, script, true, 10)
end

function object:_Init() end

return object