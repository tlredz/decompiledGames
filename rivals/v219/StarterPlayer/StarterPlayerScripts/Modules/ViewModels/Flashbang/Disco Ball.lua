local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Flashbang = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Flashbang)
local object = setmetatable({}, Flashbang)
object.__index = object

function object.new(...)
	local self = setmetatable(Flashbang.new(...), object)
	self:_Init()
	return self
end

function object.PlayFlashSound(p, p2)
	Flashbang.PlayFlashSound(p, p2)
	Utility:CreateSound("rbxassetid://17643323391", 1, 1, p2, true, 10)
end

function object.PlayRingingSound(_)
	return Utility:CreateSound("rbxassetid://17643323267", 1, 0.85, script, true, 10)
end

function object:_Init() end

return object