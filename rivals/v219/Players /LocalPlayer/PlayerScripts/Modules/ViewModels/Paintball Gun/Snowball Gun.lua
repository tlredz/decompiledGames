local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local PaintballGun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Paintball Gun"])
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(253, 234, 141)
local object = setmetatable({}, PaintballGun)
object.__index = object

function object.new(...)
	local self = setmetatable(PaintballGun.new(...), object)
	self:_Init()
	return self
end

function object.GetPaintballColor(_)
	return math.random() < 0.001 and color2 or color
end

function object.PlaySplatSound(_, p)
	Utility:CreateSound("rbxassetid://11800684590", 0.5, 0.9 + 0.2 * math.random(), p, true, 5)
end

function object:_Init() end

return object