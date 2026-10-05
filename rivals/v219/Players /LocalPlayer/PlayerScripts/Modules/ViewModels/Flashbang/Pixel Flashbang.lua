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

function object.PlayFlashSound(_, p)
	Utility:CreateSound("rbxassetid://94088948330527", 1, 1, p, true, 10)
end

function object:_Init() end

return object